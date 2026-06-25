defmodule Nadia.InputPollMedia do
  @moduledoc """
  Typed builders for media that is specific to Telegram polls.

  Poll descriptions and quiz explanations support locations and venues in
  addition to selected `Nadia.InputMedia` variants. Poll options additionally
  support links and stickers.

  Builders fix the Telegram `type` discriminator and omit options whose value
  is `nil`. Sticker uploads must use `.webp`, `.tgs`, or `.webm` filenames;
  HTTP sticker URLs must use a `.webp` URL path.
  """

  alias Nadia.InputFile

  @enforce_keys [:variant, :fields]
  defstruct [:variant, :fields]

  @typedoc "A typed poll-media value. Its representation is opaque."
  @opaque t :: %__MODULE__{variant: variant, fields: map}

  @type variant :: :link | :location | :sticker | :venue
  @type source :: binary | InputFile.t()
  @type options :: keyword | map
  @type context :: :description | :explanation | :option

  @variants [:link, :location, :sticker, :venue]
  @contexts [:description, :explanation, :option]
  @provider_options [
    :foursquare_id,
    :foursquare_type,
    :google_place_id,
    :google_place_type
  ]
  @upload_extensions [".webp", ".tgs", ".webm"]

  @doc "Builds an HTTP or HTTPS link for a poll option."
  @spec link(binary) :: t
  def link(url), do: build(:link, %{url: url}, [], [])

  @doc "Builds a location for a poll description, explanation, or option."
  @spec location(number, number, options) :: t
  def location(latitude, longitude, options \\ []) do
    build(
      :location,
      %{latitude: latitude, longitude: longitude},
      options,
      [:horizontal_accuracy]
    )
  end

  @doc "Builds a sticker for a poll option."
  @spec sticker(source, options) :: t
  def sticker(media, options \\ []) do
    build(:sticker, %{media: media}, options, [:emoji])
  end

  @doc "Builds a venue for a poll description, explanation, or option."
  @spec venue(number, number, binary, binary, options) :: t
  def venue(latitude, longitude, title, address, options \\ []) do
    build(
      :venue,
      %{
        latitude: latitude,
        longitude: longitude,
        title: title,
        address: address
      },
      options,
      @provider_options
    )
  end

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{variant: variant, fields: fields}) do
    with :ok <- validate_variant(variant),
         :ok <- validate_fields_map(fields),
         :ok <- validate_allowed_fields(variant, fields),
         :ok <- validate_fields(variant, fields) do
      {:ok,
       fields
       |> reject_nil_values()
       |> Map.put(:type, Atom.to_string(variant))}
    end
  end

  @doc false
  @spec validate_context(term, context) :: :ok | {:error, term}
  def validate_context(media, context) when context in @contexts do
    validate_typed_context(media, context)
  end

  def validate_context(_media, context), do: {:error, {:invalid_context, context}}

  defp validate_typed_context(%__MODULE__{} = media, context) do
    with {:ok, _map} <- to_map(media),
         true <- poll_variant_allowed?(media.variant, context) do
      :ok
    else
      false -> {:error, {:unsupported_context, context, media.variant}}
      {:error, _reason} = error -> error
    end
  end

  defp validate_typed_context(%Nadia.InputMedia{} = media, context) do
    with {:ok, %{type: type}} <- Nadia.InputMedia.to_map(media),
         true <- input_media_allowed?(type, context) do
      :ok
    else
      false -> {:error, {:unsupported_context, context, media.variant}}
      {:error, _reason} = error -> error
    end
  end

  defp validate_typed_context(_media, _context), do: :ok

  defp poll_variant_allowed?(variant, context)
       when context in [:description, :explanation],
       do: variant in [:location, :venue]

  defp poll_variant_allowed?(variant, :option), do: variant in @variants

  defp input_media_allowed?(type, context) when context in [:description, :explanation],
    do: type in ["animation", "audio", "document", "live_photo", "photo", "video"]

  defp input_media_allowed?(type, :option),
    do: type in ["animation", "live_photo", "photo", "video"]

  defp build(variant, required, options, allowed) do
    fields =
      options
      |> normalize_options!()
      |> Enum.reduce(required, fn {key, value}, fields ->
        if key in allowed do
          if is_nil(value), do: fields, else: Map.put(fields, key, value)
        else
          raise ArgumentError, "unsupported Nadia.InputPollMedia option: #{inspect(key)}"
        end
      end)

    input = %__MODULE__{variant: variant, fields: fields}

    case to_map(input) do
      {:ok, _map} -> input
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

  defp normalize_options!(options) when is_map(options), do: Map.to_list(options)

  defp normalize_options!(options) when is_list(options) do
    if Keyword.keyword?(options) do
      options
    else
      raise ArgumentError, "Nadia.InputPollMedia options must be a keyword list or map"
    end
  end

  defp normalize_options!(_options),
    do: raise(ArgumentError, "Nadia.InputPollMedia options must be a keyword list or map")

  defp validate_variant(variant) when variant in @variants, do: :ok
  defp validate_variant(variant), do: {:error, {:invalid_discriminator, variant}}

  defp validate_fields_map(fields) when is_map(fields), do: :ok
  defp validate_fields_map(fields), do: {:error, {:invalid_fields, fields}}

  defp validate_allowed_fields(variant, fields) do
    allowed =
      case variant do
        :link -> [:url]
        :location -> [:latitude, :longitude, :horizontal_accuracy]
        :sticker -> [:media, :emoji]
        :venue -> [:latitude, :longitude, :title, :address | @provider_options]
      end

    case Enum.find(Map.keys(fields), &(&1 not in allowed)) do
      nil -> :ok
      field -> {:error, {:unsupported_field, field}}
    end
  end

  defp validate_fields(:link, fields), do: validate_link_url(fields[:url])

  defp validate_fields(:location, fields) do
    with :ok <- validate_coordinate(:latitude, fields[:latitude], -90, 90),
         :ok <- validate_coordinate(:longitude, fields[:longitude], -180, 180),
         :ok <- validate_accuracy(fields[:horizontal_accuracy]) do
      :ok
    end
  end

  defp validate_fields(:sticker, fields) do
    with {:ok, uploaded?} <- validate_sticker_source(fields[:media]),
         :ok <- validate_emoji(fields[:emoji], uploaded?) do
      :ok
    end
  end

  defp validate_fields(:venue, fields) do
    with :ok <- validate_coordinate(:latitude, fields[:latitude], -90, 90),
         :ok <- validate_coordinate(:longitude, fields[:longitude], -180, 180),
         :ok <- validate_nonempty_string(:title, fields[:title]),
         :ok <- validate_nonempty_string(:address, fields[:address]),
         :ok <- validate_provider_options(fields) do
      :ok
    end
  end

  defp validate_link_url(url) when is_binary(url) do
    case parse_http_url(url) do
      {:ok, _uri} -> :ok
      :error -> {:error, :invalid_link_url}
    end
  end

  defp validate_link_url(_url), do: {:error, :invalid_link_url}

  defp validate_coordinate(_field, value, minimum, maximum)
       when is_number(value) and value >= minimum and value <= maximum,
       do: :ok

  defp validate_coordinate(field, value, minimum, maximum),
    do: {:error, {:out_of_range, field, value, minimum, maximum}}

  defp validate_accuracy(nil), do: :ok

  defp validate_accuracy(value) when is_number(value) and value >= 0 and value <= 1500,
    do: :ok

  defp validate_accuracy(value),
    do: {:error, {:out_of_range, :horizontal_accuracy, value, 0, 1500}}

  defp validate_nonempty_string(_field, value)
       when is_binary(value) and byte_size(value) > 0,
       do: :ok

  defp validate_nonempty_string(field, _value), do: {:error, {:required, field}}

  defp validate_provider_options(fields) do
    Enum.reduce_while(@provider_options, :ok, fn field, :ok ->
      case Map.fetch(fields, field) do
        :error ->
          {:cont, :ok}

        {:ok, nil} ->
          {:cont, :ok}

        {:ok, value} ->
          case validate_nonempty_string(field, value) do
            :ok -> {:cont, :ok}
            {:error, _reason} = error -> {:halt, error}
          end
      end
    end)
  end

  defp validate_sticker_source(%InputFile{source: {:file_id, file_id}}) do
    with :ok <- validate_nonempty_string(:media, file_id), do: {:ok, false}
  end

  defp validate_sticker_source(%InputFile{source: {:url, url}}) do
    with :ok <- validate_sticker_url(url), do: {:ok, false}
  end

  defp validate_sticker_source(%InputFile{source: {:path, path}, filename: filename}) do
    with :ok <- validate_nonempty_string(:media, path),
         :ok <- validate_upload_filename(filename || path) do
      {:ok, true}
    end
  end

  defp validate_sticker_source(%InputFile{source: {kind, _value}, filename: filename})
       when kind in [:bytes, :stream] do
    with :ok <- validate_upload_filename(filename), do: {:ok, true}
  end

  defp validate_sticker_source(%InputFile{}), do: {:error, :invalid_sticker_source}

  defp validate_sticker_source("attach://" <> name) when byte_size(name) > 0,
    do: {:ok, true}

  defp validate_sticker_source(media) when is_binary(media) and byte_size(media) > 0 do
    case URI.parse(media) do
      %URI{scheme: nil} ->
        {:ok, false}

      %URI{scheme: scheme} when is_binary(scheme) ->
        if String.downcase(scheme) in ["http", "https"] do
          with :ok <- validate_sticker_url(media), do: {:ok, false}
        else
          {:error, :invalid_sticker_url}
        end
    end
  end

  defp validate_sticker_source(_media), do: {:error, :invalid_sticker_source}

  defp validate_sticker_url(url) when is_binary(url) do
    with {:ok, %URI{path: path}} <- parse_http_url(url),
         true <- is_binary(path) and String.downcase(Path.extname(path)) == ".webp" do
      :ok
    else
      _other -> {:error, :invalid_sticker_url}
    end
  end

  defp validate_sticker_url(_url), do: {:error, :invalid_sticker_url}

  defp validate_upload_filename(filename) when is_binary(filename) and byte_size(filename) > 0 do
    if String.downcase(Path.extname(filename)) in @upload_extensions do
      :ok
    else
      {:error, :invalid_sticker_upload_extension}
    end
  end

  defp validate_upload_filename(_filename), do: {:error, :invalid_sticker_upload_extension}

  defp validate_emoji(nil, _uploaded?), do: :ok

  defp validate_emoji(emoji, true)
       when is_binary(emoji) and byte_size(emoji) > 0,
       do: :ok

  defp validate_emoji(emoji, true), do: {:error, {:invalid_emoji, emoji}}
  defp validate_emoji(_emoji, false), do: {:error, :emoji_requires_upload}

  defp parse_http_url(url) do
    case URI.parse(url) do
      %URI{scheme: scheme, host: host} = uri
      when is_binary(scheme) and is_binary(host) and byte_size(host) > 0 ->
        if String.downcase(scheme) in ["http", "https"], do: {:ok, uri}, else: :error

      _other ->
        :error
    end
  end

  defp reject_nil_values(map) do
    for {key, value} <- map, not is_nil(value), into: %{}, do: {key, value}
  end

  defp error_message(:invalid_link_url),
    do: "Nadia.InputPollMedia link URL must be an HTTP or HTTPS URL with a host"

  defp error_message({:out_of_range, field, _value, minimum, maximum}),
    do: "Nadia.InputPollMedia #{field} must be a number from #{minimum} to #{maximum}"

  defp error_message({:required, field}),
    do: "Nadia.InputPollMedia #{field} must be a non-empty string"

  defp error_message(:invalid_sticker_source),
    do: "Nadia.InputPollMedia sticker media must be a non-empty binary or InputFile"

  defp error_message(:invalid_sticker_url),
    do: "Nadia.InputPollMedia sticker HTTP URLs must have a .webp path"

  defp error_message(:invalid_sticker_upload_extension),
    do: "Nadia.InputPollMedia sticker uploads must use a .webp, .tgs, or .webm filename"

  defp error_message({:invalid_emoji, _emoji}),
    do: "Nadia.InputPollMedia sticker emoji must be a non-empty string"

  defp error_message(:emoji_requires_upload),
    do: "Nadia.InputPollMedia sticker emoji is allowed only for a newly uploaded sticker"

  defp error_message(reason), do: "invalid Nadia.InputPollMedia value: #{inspect(reason)}"
end
