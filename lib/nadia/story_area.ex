defmodule Nadia.StoryArea do
  @moduledoc """
  Typed builders for Telegram story areas and their nested position and address
  objects.

  Story-area percentage values are deliberately not range-limited. Telegram
  documents them as percentages but does not define a local validity range.
  Rotation is limited to 0 through 360 degrees.

  Telegram's story-area documentation describes latitude and longitude in
  degrees without publishing bounds. Nadia applies the locally conventional
  geographic ranges of -90 through 90 latitude and -180 through 180 longitude
  so clearly invalid coordinates fail before a request is sent.

  Builders omit `nil` options and preserve explicit `false` values.
  Typed lists passed to `postStory` or `editStory` are limited to 10 location,
  5 suggested-reaction, 3 link, 3 weather, and 1 unique-gift area.
  """

  alias Nadia.ReactionType

  @enforce_keys [:variant, :fields]
  defstruct [:variant, :fields]

  @typedoc """
  A typed story area, position, or location address. Its representation is
  opaque.
  """
  @opaque t :: %__MODULE__{variant: variant, fields: map}

  @type variant ::
          :position
          | :location_address
          | :location
          | :suggested_reaction
          | :link
          | :weather
          | :unique_gift
  @type options :: keyword | map

  @variants [
    :position,
    :location_address,
    :location,
    :suggested_reaction,
    :link,
    :weather,
    :unique_gift
  ]
  @area_variants [:location, :suggested_reaction, :link, :weather, :unique_gift]
  @position_fields [
    :x_percentage,
    :y_percentage,
    :width_percentage,
    :height_percentage,
    :rotation_angle,
    :corner_radius_percentage
  ]
  @address_options [:state, :city, :street]
  @area_limits [
    location: 10,
    suggested_reaction: 5,
    link: 3,
    weather: 3,
    unique_gift: 1
  ]

  @doc """
  Builds a story-area position.

  All six values must be numeric. Percentage values may be negative or greater
  than 100; only `rotation_angle` is range-limited.
  """
  @spec position(number, number, number, number, number, number) :: t
  def position(
        x_percentage,
        y_percentage,
        width_percentage,
        height_percentage,
        rotation_angle,
        corner_radius_percentage
      ) do
    build(:position, %{
      x_percentage: x_percentage,
      y_percentage: y_percentage,
      width_percentage: width_percentage,
      height_percentage: height_percentage,
      rotation_angle: rotation_angle,
      corner_radius_percentage: corner_radius_percentage
    })
  end

  @doc "Builds a physical location address."
  @spec location_address(binary, options) :: t
  def location_address(country_code, options \\ []) do
    build_with_options(
      :location_address,
      %{country_code: country_code},
      options,
      @address_options
    )
  end

  @doc "Builds a story area pointing to a geographic location."
  @spec location(t, number, number, options) :: t
  def location(position, latitude, longitude, options \\ []) do
    build_with_options(
      :location,
      %{position: position, latitude: latitude, longitude: longitude},
      options,
      [:address]
    )
  end

  @doc "Builds a story area containing a suggested reaction."
  @spec suggested_reaction(t, ReactionType.t(), options) :: t
  def suggested_reaction(position, reaction, options \\ []) do
    build_with_options(
      :suggested_reaction,
      %{position: position, reaction_type: reaction},
      options,
      [:is_dark, :is_flipped]
    )
  end

  @doc "Builds a story area pointing to an HTTP, HTTPS, or `tg://` URL."
  @spec link(t, binary) :: t
  def link(position, url), do: build(:link, %{position: position, url: url})

  @doc "Builds a story area containing weather information."
  @spec weather(t, number, binary, non_neg_integer) :: t
  def weather(position, temperature, emoji, background_color) do
    build(:weather, %{
      position: position,
      temperature: temperature,
      emoji: emoji,
      background_color: background_color
    })
  end

  @doc "Builds a story area pointing to a unique gift."
  @spec unique_gift(t, binary) :: t
  def unique_gift(position, name), do: build(:unique_gift, %{position: position, name: name})

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{variant: variant, fields: fields}) do
    with :ok <- validate_variant(variant),
         :ok <- validate_fields_map(fields),
         :ok <- validate_allowed_fields(variant, fields),
         :ok <- validate_fields(variant, fields) do
      encode(variant, fields)
    end
  end

  @doc false
  @spec validate_areas(term) :: :ok | {:error, term}
  def validate_areas(areas) when is_list(areas) do
    if Enum.any?(areas, &match?(%__MODULE__{}, &1)) do
      with :ok <- validate_typed_members(areas),
           :ok <- validate_area_limits(areas) do
        :ok
      end
    else
      :ok
    end
  end

  def validate_areas(_areas), do: :ok

  defp build_with_options(variant, required, options, allowed) do
    fields =
      options
      |> normalize_options!()
      |> Enum.reduce(required, fn {key, value}, fields ->
        if key in allowed do
          if is_nil(value), do: fields, else: Map.put(fields, key, value)
        else
          raise ArgumentError, "unsupported Nadia.StoryArea option: #{inspect(key)}"
        end
      end)

    build(variant, fields)
  end

  defp build(variant, fields) do
    area = %__MODULE__{variant: variant, fields: fields}

    case to_map(area) do
      {:ok, _map} -> area
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

  defp normalize_options!(options) when is_map(options), do: Map.to_list(options)

  defp normalize_options!(options) when is_list(options) do
    if Keyword.keyword?(options) do
      options
    else
      raise ArgumentError, "Nadia.StoryArea options must be a keyword list or map"
    end
  end

  defp normalize_options!(_options),
    do: raise(ArgumentError, "Nadia.StoryArea options must be a keyword list or map")

  defp validate_variant(variant) when variant in @variants, do: :ok
  defp validate_variant(variant), do: {:error, {:invalid_discriminator, variant}}

  defp validate_fields_map(fields) when is_map(fields), do: :ok
  defp validate_fields_map(fields), do: {:error, {:invalid_fields, fields}}

  defp validate_allowed_fields(variant, fields) do
    allowed =
      case variant do
        :position -> @position_fields
        :location_address -> [:country_code | @address_options]
        :location -> [:position, :latitude, :longitude, :address]
        :suggested_reaction -> [:position, :reaction_type, :is_dark, :is_flipped]
        :link -> [:position, :url]
        :weather -> [:position, :temperature, :emoji, :background_color]
        :unique_gift -> [:position, :name]
      end

    case fields |> Map.keys() |> Enum.sort() |> Enum.find(&(&1 not in allowed)) do
      nil -> :ok
      field -> {:error, {:unsupported_field, field}}
    end
  end

  defp validate_fields(:position, fields) do
    with :ok <- validate_numbers(fields, @position_fields),
         :ok <- validate_rotation(fields[:rotation_angle]) do
      :ok
    end
  end

  defp validate_fields(:location_address, fields) do
    with :ok <- validate_country_code(fields[:country_code]),
         :ok <- validate_optional_strings(fields, @address_options) do
      :ok
    end
  end

  defp validate_fields(:location, fields) do
    with :ok <- validate_position(fields[:position]),
         :ok <- validate_coordinate(:latitude, fields[:latitude], -90, 90),
         :ok <- validate_coordinate(:longitude, fields[:longitude], -180, 180),
         :ok <- validate_address(fields[:address]) do
      :ok
    end
  end

  defp validate_fields(:suggested_reaction, fields) do
    with :ok <- validate_position(fields[:position]),
         :ok <- validate_reaction(fields[:reaction_type]),
         :ok <- validate_optional_boolean(fields[:is_dark], :is_dark),
         :ok <- validate_optional_boolean(fields[:is_flipped], :is_flipped) do
      :ok
    end
  end

  defp validate_fields(:link, fields) do
    with :ok <- validate_position(fields[:position]),
         :ok <- validate_url(fields[:url]) do
      :ok
    end
  end

  defp validate_fields(:weather, fields) do
    with :ok <- validate_position(fields[:position]),
         :ok <- validate_number(fields[:temperature], :temperature),
         :ok <- validate_string(fields[:emoji], :emoji),
         :ok <- validate_argb(fields[:background_color]) do
      :ok
    end
  end

  defp validate_fields(:unique_gift, fields) do
    with :ok <- validate_position(fields[:position]),
         :ok <- validate_string(fields[:name], :name) do
      :ok
    end
  end

  defp validate_numbers(fields, field_names) do
    Enum.reduce_while(field_names, :ok, fn field, :ok ->
      case validate_number(fields[field], field) do
        :ok -> {:cont, :ok}
        {:error, _reason} = error -> {:halt, error}
      end
    end)
  end

  defp validate_number(value, _field) when is_number(value), do: :ok
  defp validate_number(_value, field), do: {:error, {:number_required, field}}

  defp validate_rotation(value) when is_number(value) and value >= 0 and value <= 360, do: :ok

  defp validate_rotation(value),
    do: {:error, {:out_of_range, :rotation_angle, value, 0, 360}}

  defp validate_coordinate(_field, value, minimum, maximum)
       when is_number(value) and value >= minimum and value <= maximum,
       do: :ok

  defp validate_coordinate(field, value, minimum, maximum),
    do: {:error, {:out_of_range, field, value, minimum, maximum}}

  defp validate_country_code(<<first, second>>)
       when first in ?A..?Z and second in ?A..?Z,
       do: :ok

  defp validate_country_code(value), do: {:error, {:invalid_country_code, value}}

  defp validate_optional_strings(fields, field_names) do
    Enum.reduce_while(field_names, :ok, fn field, :ok ->
      case Map.fetch(fields, field) do
        :error ->
          {:cont, :ok}

        {:ok, nil} ->
          {:cont, :ok}

        {:ok, value} ->
          case validate_string(value, field) do
            :ok -> {:cont, :ok}
            {:error, _reason} = error -> {:halt, error}
          end
      end
    end)
  end

  defp validate_string(value, _field)
       when is_binary(value) and byte_size(value) > 0,
       do: if(String.valid?(value), do: :ok, else: {:error, :invalid_utf8})

  defp validate_string(_value, field), do: {:error, {:required, field}}

  defp validate_optional_boolean(nil, _field), do: :ok
  defp validate_optional_boolean(value, _field) when is_boolean(value), do: :ok
  defp validate_optional_boolean(_value, field), do: {:error, {:boolean_required, field}}

  defp validate_position(%__MODULE__{variant: :position} = position) do
    case to_map(position) do
      {:ok, _map} -> :ok
      {:error, _reason} = error -> error
    end
  end

  defp validate_position(_position), do: {:error, :position_required}

  defp validate_address(nil), do: :ok

  defp validate_address(%__MODULE__{variant: :location_address} = address) do
    case to_map(address) do
      {:ok, _map} -> :ok
      {:error, _reason} = error -> error
    end
  end

  defp validate_address(_address), do: {:error, :invalid_location_address}

  defp validate_reaction(%ReactionType{} = reaction) do
    case ReactionType.to_map(reaction) do
      {:ok, _map} -> :ok
      {:error, _reason} = error -> error
    end
  end

  defp validate_reaction(_reaction), do: {:error, :reaction_type_required}

  defp validate_url(url) when is_binary(url) do
    if String.valid?(url) do
      case URI.new(url) do
        {:ok, %URI{scheme: scheme, host: host}}
        when scheme in ["http", "https"] and is_binary(host) and byte_size(host) > 0 ->
          :ok

        {:ok, %URI{scheme: "tg"} = uri} ->
          if tg_target?(url, uri), do: :ok, else: {:error, :invalid_url}

        _other ->
          {:error, :invalid_url}
      end
    else
      {:error, :invalid_url}
    end
  end

  defp validate_url(_url), do: {:error, :invalid_url}

  defp tg_target?(url, %URI{host: host, path: path}) do
    String.starts_with?(String.downcase(url), "tg://") and
      ((is_binary(host) and byte_size(host) > 0) or
         (is_binary(path) and String.trim(path, "/") != ""))
  end

  defp validate_argb(value) when is_integer(value) and value >= 0 and value <= 0xFFFFFFFF,
    do: :ok

  defp validate_argb(value), do: {:error, {:invalid_argb, value}}

  defp encode(:position, fields), do: {:ok, reject_nil_values(fields)}
  defp encode(:location_address, fields), do: {:ok, reject_nil_values(fields)}

  defp encode(variant, fields) when variant in @area_variants do
    with {:ok, position} <- to_map(fields.position),
         {:ok, area_type} <- encode_area_type(variant, fields) do
      {:ok, %{position: position, type: area_type}}
    end
  end

  defp encode_area_type(:location, fields) do
    with {:ok, address} <- encode_address(fields[:address]) do
      {:ok,
       fields
       |> Map.take([:latitude, :longitude])
       |> maybe_put(:address, address)
       |> Map.put(:type, "location")}
    end
  end

  defp encode_area_type(:suggested_reaction, fields) do
    with {:ok, reaction} <- ReactionType.to_map(fields.reaction_type) do
      {:ok,
       fields
       |> Map.take([:is_dark, :is_flipped])
       |> reject_nil_values()
       |> Map.put(:reaction_type, reaction)
       |> Map.put(:type, "suggested_reaction")}
    end
  end

  defp encode_area_type(:link, fields),
    do: {:ok, %{type: "link", url: fields.url}}

  defp encode_area_type(:weather, fields) do
    {:ok,
     %{
       type: "weather",
       temperature: fields.temperature,
       emoji: fields.emoji,
       background_color: fields.background_color
     }}
  end

  defp encode_area_type(:unique_gift, fields),
    do: {:ok, %{type: "unique_gift", name: fields.name}}

  defp encode_address(nil), do: {:ok, nil}
  defp encode_address(address), do: to_map(address)

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp validate_typed_members(areas) do
    Enum.reduce_while(areas, :ok, fn
      %__MODULE__{variant: variant} = area, :ok ->
        case to_map(area) do
          {:ok, _map} when variant in @area_variants ->
            {:cont, :ok}

          {:ok, _map} ->
            {:halt, {:error, {:invalid_area_variant, variant}}}

          {:error, _reason} = error ->
            {:halt, error}
        end

      _raw, :ok ->
        {:cont, :ok}
    end)
  end

  defp validate_area_limits(areas) do
    Enum.reduce_while(@area_limits, :ok, fn {variant, limit}, :ok ->
      count = Enum.count(areas, &match?(%__MODULE__{variant: ^variant}, &1))

      if count <= limit do
        {:cont, :ok}
      else
        {:halt, {:error, {:area_count, variant, count, limit}}}
      end
    end)
  end

  defp reject_nil_values(map) do
    for {key, value} <- map, not is_nil(value), into: %{}, do: {key, value}
  end

  defp error_message({:number_required, field}),
    do: "Nadia.StoryArea #{field} must be a number"

  defp error_message({:out_of_range, field, _value, minimum, maximum}),
    do: "Nadia.StoryArea #{field} must be a number from #{minimum} to #{maximum}"

  defp error_message({:invalid_country_code, _value}),
    do: "Nadia.StoryArea country_code must be two uppercase ASCII letters"

  defp error_message({:required, field}),
    do: "Nadia.StoryArea #{field} must be a non-empty valid UTF-8 string"

  defp error_message(:invalid_utf8),
    do: "Nadia.StoryArea string values must be valid UTF-8"

  defp error_message({:boolean_required, field}),
    do: "Nadia.StoryArea #{field} must be a boolean"

  defp error_message(:position_required),
    do: "Nadia.StoryArea position must be built with Nadia.StoryArea.position/6"

  defp error_message(:invalid_location_address),
    do: "Nadia.StoryArea address must be built with Nadia.StoryArea.location_address/2"

  defp error_message(:reaction_type_required),
    do: "Nadia.StoryArea reaction must be a Nadia.ReactionType value"

  defp error_message(:invalid_url),
    do: "Nadia.StoryArea URL must be HTTP or HTTPS with a host, or tg:// with a target"

  defp error_message({:invalid_argb, _value}),
    do: "Nadia.StoryArea background_color must be an ARGB integer from 0 to 4294967295"

  defp error_message(reason), do: "invalid Nadia.StoryArea value: #{inspect(reason)}"
end
