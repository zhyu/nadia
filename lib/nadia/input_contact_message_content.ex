defmodule Nadia.InputContactMessageContent do
  @moduledoc """
  Typed builder for Telegram `InputContactMessageContent`.

  Contact text fields must be valid UTF-8. Required text fields must be
  non-empty, and `:vcard` is validated against Telegram's 0 to 2048 byte
  limit.
  """

  @enforce_keys [:fields]
  defstruct [:fields]

  @typedoc "Typed inline-query content containing a contact."
  @opaque t :: %__MODULE__{fields: map}

  @type options :: keyword | map

  @optional_fields [:last_name, :vcard]
  @allowed_fields [:phone_number, :first_name | @optional_fields]

  @doc """
  Builds contact content for an inline-query result.

  Supported options are `:last_name` and `:vcard`. Options whose value is
  `nil` are omitted.
  """
  @spec new(binary, binary, options) :: t
  def new(phone_number, first_name, options \\ []) do
    fields =
      options
      |> normalize_options!()
      |> Enum.reduce(%{phone_number: phone_number, first_name: first_name}, fn {key, value},
                                                                               fields ->
        if key in @optional_fields do
          if is_nil(value), do: fields, else: Map.put(fields, key, value)
        else
          raise ArgumentError,
                "unsupported Nadia.InputContactMessageContent option: #{inspect(key)}"
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
         :ok <- validate_required_text(:phone_number, fields[:phone_number]),
         :ok <- validate_required_text(:first_name, fields[:first_name]),
         :ok <- validate_optional_text(:last_name, fields[:last_name]),
         :ok <- validate_vcard(fields[:vcard]) do
      {:ok, reject_nil_values(fields)}
    end
  end

  def to_map(_content), do: {:error, :invalid_input_contact_message_content}

  defp normalize_options!(options) when is_map(options), do: Map.to_list(options)

  defp normalize_options!(options) when is_list(options) do
    if Keyword.keyword?(options) do
      options
    else
      raise ArgumentError,
            "Nadia.InputContactMessageContent options must be a keyword list or map"
    end
  end

  defp normalize_options!(_options),
    do:
      raise(
        ArgumentError,
        "Nadia.InputContactMessageContent options must be a keyword list or map"
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

  defp validate_required_text(field, value) when is_binary(value) and byte_size(value) > 0 do
    if String.valid?(value), do: :ok, else: {:error, {:invalid_utf8, field}}
  end

  defp validate_required_text(field, _value), do: {:error, {:required, field}}

  defp validate_optional_text(_field, nil), do: :ok

  defp validate_optional_text(field, value) when is_binary(value) do
    if String.valid?(value), do: :ok, else: {:error, {:invalid_utf8, field}}
  end

  defp validate_optional_text(field, _value), do: {:error, {:invalid_string, field}}

  defp validate_vcard(nil), do: :ok

  defp validate_vcard(vcard) when is_binary(vcard) and byte_size(vcard) <= 2048 do
    if String.valid?(vcard), do: :ok, else: {:error, {:invalid_utf8, :vcard}}
  end

  defp validate_vcard(_vcard), do: {:error, :invalid_vcard}

  defp reject_nil_values(map) do
    for {key, value} <- map, not is_nil(value), into: %{}, do: {key, value}
  end

  defp error_message({:required, field}),
    do: "Nadia.InputContactMessageContent #{field} must be a non-empty valid UTF-8 binary"

  defp error_message({:invalid_utf8, field}),
    do: "Nadia.InputContactMessageContent #{field} must be valid UTF-8"

  defp error_message({:invalid_string, field}),
    do: "Nadia.InputContactMessageContent #{field} must be a valid UTF-8 binary"

  defp error_message(:invalid_vcard),
    do: "Nadia.InputContactMessageContent vcard must be valid UTF-8 with 0 to 2048 bytes"

  defp error_message(reason),
    do: "invalid Nadia.InputContactMessageContent value: #{inspect(reason)}"
end
