defmodule Nadia.InputLocationMessageContent do
  @moduledoc """
  Typed builder for Telegram `InputLocationMessageContent`.

  Coordinates are validated as ordinary latitude and longitude degree values.
  Optional live-location fields enforce the bounds documented by Telegram.
  """

  @enforce_keys [:fields]
  defstruct [:fields]

  @typedoc "Typed inline-query content containing a location."
  @opaque t :: %__MODULE__{fields: map}

  @type options :: keyword | map

  @optional_fields [
    :horizontal_accuracy,
    :live_period,
    :heading,
    :proximity_alert_radius
  ]
  @allowed_fields [:latitude, :longitude | @optional_fields]
  @indefinite_live_period 0x7FFFFFFF

  @doc """
  Builds location content for an inline-query result.

  Supported options are `:horizontal_accuracy`, `:live_period`, `:heading`,
  and `:proximity_alert_radius`. Options whose value is `nil` are omitted.
  """
  @spec new(number, number, options) :: t
  def new(latitude, longitude, options \\ []) do
    fields =
      options
      |> normalize_options!()
      |> Enum.reduce(%{latitude: latitude, longitude: longitude}, fn {key, value}, fields ->
        if key in @optional_fields do
          if is_nil(value), do: fields, else: Map.put(fields, key, value)
        else
          raise ArgumentError,
                "unsupported Nadia.InputLocationMessageContent option: #{inspect(key)}"
        end
      end)

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
         :ok <- validate_horizontal_accuracy(fields[:horizontal_accuracy]),
         :ok <- validate_live_period(fields[:live_period]),
         :ok <- validate_integer_range(:heading, fields[:heading], 1, 360),
         :ok <-
           validate_integer_range(
             :proximity_alert_radius,
             fields[:proximity_alert_radius],
             1,
             100_000
           ) do
      {:ok, reject_nil_values(fields)}
    end
  end

  def to_map(_content), do: {:error, :invalid_input_location_message_content}

  defp normalize_options!(options) when is_map(options), do: Map.to_list(options)

  defp normalize_options!(options) when is_list(options) do
    if Keyword.keyword?(options) do
      options
    else
      raise ArgumentError,
            "Nadia.InputLocationMessageContent options must be a keyword list or map"
    end
  end

  defp normalize_options!(_options),
    do:
      raise(
        ArgumentError,
        "Nadia.InputLocationMessageContent options must be a keyword list or map"
      )

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

  defp validate_horizontal_accuracy(nil), do: :ok

  defp validate_horizontal_accuracy(value) when is_number(value) and value >= 0 and value <= 1500,
    do: :ok

  defp validate_horizontal_accuracy(value),
    do: {:error, {:out_of_range, :horizontal_accuracy, value, 0, 1500}}

  defp validate_live_period(nil), do: :ok
  defp validate_live_period(@indefinite_live_period), do: :ok
  defp validate_live_period(value) when is_integer(value) and value in 60..86_400, do: :ok

  defp validate_live_period(value),
    do: {:error, {:out_of_range, :live_period, value, 60, 86_400}}

  defp validate_integer_range(_field, nil, _minimum, _maximum), do: :ok

  defp validate_integer_range(_field, value, minimum, maximum)
       when is_integer(value) and value >= minimum and value <= maximum,
       do: :ok

  defp validate_integer_range(field, value, minimum, maximum),
    do: {:error, {:out_of_range, field, value, minimum, maximum}}

  defp reject_nil_values(map) do
    for {key, value} <- map, not is_nil(value), into: %{}, do: {key, value}
  end

  defp error_message({:out_of_range, :live_period, _value, minimum, maximum}),
    do:
      "Nadia.InputLocationMessageContent live_period must be an integer from #{minimum} to #{maximum}, or 0x7FFFFFFF"

  defp error_message({:out_of_range, field, _value, minimum, maximum}),
    do:
      "Nadia.InputLocationMessageContent #{field} must be a number from #{minimum} to #{maximum}"

  defp error_message(reason),
    do: "invalid Nadia.InputLocationMessageContent value: #{inspect(reason)}"
end
