defmodule Nadia.InputVenueMessageContent do
  @moduledoc """
  Typed builder for Telegram `InputVenueMessageContent`.

  Coordinates are validated as ordinary latitude and longitude degree values.
  Venue text fields must be valid UTF-8; required text fields must be
  non-empty.
  """

  @enforce_keys [:fields]
  defstruct [:fields]

  @typedoc "Typed inline-query content containing a venue."
  @opaque t :: %__MODULE__{fields: map}

  @type options :: keyword | map

  @provider_fields [
    :foursquare_id,
    :foursquare_type,
    :google_place_id,
    :google_place_type
  ]
  @allowed_fields [:latitude, :longitude, :title, :address | @provider_fields]

  @doc """
  Builds venue content for an inline-query result.

  Supported options are `:foursquare_id`, `:foursquare_type`,
  `:google_place_id`, and `:google_place_type`. Options whose value is `nil`
  are omitted.
  """
  @spec new(number, number, binary, binary, options) :: t
  def new(latitude, longitude, title, address, options \\ []) do
    fields =
      options
      |> normalize_options!()
      |> Enum.reduce(
        %{latitude: latitude, longitude: longitude, title: title, address: address},
        fn {key, value}, fields ->
          if key in @provider_fields do
            if is_nil(value), do: fields, else: Map.put(fields, key, value)
          else
            raise ArgumentError,
                  "unsupported Nadia.InputVenueMessageContent option: #{inspect(key)}"
          end
        end
      )

    content = %__MODULE__{fields: fields}

    case to_map(content) do
      {:ok, _map} -> content
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{fields: fields} = content) do
    with :ok <- validate_struct_fields(content),
         :ok <- validate_fields_map(fields),
         :ok <- validate_allowed_fields(fields),
         :ok <- validate_coordinate(:latitude, fields[:latitude], -90, 90),
         :ok <- validate_coordinate(:longitude, fields[:longitude], -180, 180),
         :ok <- validate_required_text(:title, fields[:title]),
         :ok <- validate_required_text(:address, fields[:address]),
         :ok <- validate_provider_fields(fields) do
      {:ok, reject_nil_values(fields)}
    end
  end

  def to_map(_content), do: {:error, :invalid_input_venue_message_content}

  defp normalize_options!(options) when is_map(options), do: Map.to_list(options)

  defp normalize_options!(options) when is_list(options) do
    if Keyword.keyword?(options) do
      options
    else
      raise ArgumentError, "Nadia.InputVenueMessageContent options must be a keyword list or map"
    end
  end

  defp normalize_options!(_options),
    do:
      raise(ArgumentError, "Nadia.InputVenueMessageContent options must be a keyword list or map")

  defp validate_struct_fields(content) do
    case content
         |> Map.keys()
         |> Enum.sort()
         |> Enum.find(&(&1 not in [:__struct__, :fields])) do
      nil -> :ok
      field -> {:error, {:unsupported_field, field}}
    end
  end

  defp validate_fields_map(fields) when is_map(fields), do: :ok
  defp validate_fields_map(fields), do: {:error, {:invalid_fields, fields}}

  defp validate_allowed_fields(fields) do
    case fields
         |> Map.keys()
         |> Enum.sort()
         |> Enum.find(&(&1 not in @allowed_fields)) do
      nil -> :ok
      field -> {:error, {:unsupported_field, field}}
    end
  end

  defp validate_coordinate(_field, value, minimum, maximum)
       when is_number(value) and value >= minimum and value <= maximum,
       do: :ok

  defp validate_coordinate(field, value, minimum, maximum),
    do: {:error, {:out_of_range, field, value, minimum, maximum}}

  defp validate_required_text(field, value) when is_binary(value) and byte_size(value) > 0 do
    if String.valid?(value), do: :ok, else: {:error, {:invalid_utf8, field}}
  end

  defp validate_required_text(field, _value), do: {:error, {:required, field}}

  defp validate_optional_text(field, value) when is_binary(value) do
    if String.valid?(value), do: :ok, else: {:error, {:invalid_utf8, field}}
  end

  defp validate_optional_text(field, _value), do: {:error, {:invalid_string, field}}

  defp validate_provider_fields(fields) do
    Enum.reduce_while(@provider_fields, :ok, fn field, :ok ->
      case Map.fetch(fields, field) do
        :error ->
          {:cont, :ok}

        {:ok, nil} ->
          {:cont, :ok}

        {:ok, value} ->
          case validate_optional_text(field, value) do
            :ok -> {:cont, :ok}
            {:error, _reason} = error -> {:halt, error}
          end
      end
    end)
  end

  defp reject_nil_values(map) do
    for {key, value} <- map, not is_nil(value), into: %{}, do: {key, value}
  end

  defp error_message({:out_of_range, field, _value, minimum, maximum}),
    do: "Nadia.InputVenueMessageContent #{field} must be a number from #{minimum} to #{maximum}"

  defp error_message({:required, field}),
    do: "Nadia.InputVenueMessageContent #{field} must be a non-empty valid UTF-8 binary"

  defp error_message({:invalid_utf8, field}),
    do: "Nadia.InputVenueMessageContent #{field} must be valid UTF-8"

  defp error_message({:invalid_string, field}),
    do: "Nadia.InputVenueMessageContent #{field} must be a valid UTF-8 binary"

  defp error_message(reason),
    do: "invalid Nadia.InputVenueMessageContent value: #{inspect(reason)}"
end
