defmodule Nadia.InputPollOption do
  @moduledoc """
  Typed builder for a Telegram poll option.

  Poll-option text must contain 1 to 100 valid UTF-8 characters. Optional
  formatting can be supplied with either `:text_parse_mode` or
  `:text_entities`, but not both.

  Typed media is checked against Telegram's poll-option media families.
  `Nadia.InputMedia` audio and document values are rejected, while raw media
  values remain available as compatibility inputs. Telegram currently permits
  only custom emoji entities in option text and remains responsible for
  validating entity offsets and formatting semantics.
  """

  @enforce_keys [:fields]
  defstruct [:fields]

  @typedoc "A typed Telegram InputPollOption value. Its representation is opaque."
  @opaque t :: %__MODULE__{fields: map}

  @type options :: keyword | map

  @optional_fields [:text_parse_mode, :text_entities, :media]
  @allowed_fields [:text | @optional_fields]

  @doc """
  Builds a poll option.

  Supported options are `:text_parse_mode`, `:text_entities`, and `:media`.
  Options whose value is `nil` are omitted.
  """
  @spec new(binary, options) :: t
  def new(text, options \\ []) do
    fields =
      options
      |> normalize_options!()
      |> Enum.reduce(%{text: text}, fn {key, value}, fields ->
        if key in @optional_fields do
          if is_nil(value), do: fields, else: Map.put(fields, key, value)
        else
          raise ArgumentError, "unsupported Nadia.InputPollOption option: #{inspect(key)}"
        end
      end)

    input = %__MODULE__{fields: fields}

    case to_map(input) do
      {:ok, _map} -> input
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{fields: fields}) do
    with :ok <- validate_fields_map(fields),
         :ok <- validate_allowed_fields(fields),
         :ok <- validate_text(fields[:text]),
         :ok <- validate_text_parse_mode(fields[:text_parse_mode]),
         :ok <- validate_text_entities(fields[:text_entities]),
         :ok <- validate_text_formatting(fields),
         :ok <- validate_media(fields[:media]) do
      {:ok, reject_nil_values(fields)}
    end
  end

  defp normalize_options!(options) when is_map(options), do: Map.to_list(options)

  defp normalize_options!(options) when is_list(options) do
    if Keyword.keyword?(options) do
      options
    else
      raise ArgumentError, "Nadia.InputPollOption options must be a keyword list or map"
    end
  end

  defp normalize_options!(_options),
    do: raise(ArgumentError, "Nadia.InputPollOption options must be a keyword list or map")

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

  defp validate_text(text) when is_binary(text) do
    if String.valid?(text) and String.length(text) in 1..100 do
      :ok
    else
      {:error, :invalid_text}
    end
  end

  defp validate_text(_text), do: {:error, :invalid_text}

  defp validate_text_parse_mode(nil), do: :ok

  defp validate_text_parse_mode(mode)
       when is_binary(mode) and byte_size(mode) > 0 do
    if String.valid?(mode), do: :ok, else: {:error, :invalid_text_parse_mode}
  end

  defp validate_text_parse_mode(_mode), do: {:error, :invalid_text_parse_mode}

  defp validate_text_entities(nil), do: :ok
  defp validate_text_entities(entities) when is_list(entities), do: :ok
  defp validate_text_entities(_entities), do: {:error, :invalid_text_entities}

  defp validate_text_formatting(%{
         text_parse_mode: text_parse_mode,
         text_entities: text_entities
       })
       when not is_nil(text_parse_mode) and not is_nil(text_entities),
       do: {:error, :text_formatting_conflict}

  defp validate_text_formatting(_fields), do: :ok

  defp validate_media(nil), do: :ok
  defp validate_media(media), do: Nadia.InputPollMedia.validate_context(media, :option)

  defp reject_nil_values(map) do
    for {key, value} <- map, not is_nil(value), into: %{}, do: {key, value}
  end

  defp error_message(:invalid_text),
    do: "Nadia.InputPollOption text must be valid UTF-8 with 1 to 100 characters"

  defp error_message(:invalid_text_parse_mode),
    do: "Nadia.InputPollOption text_parse_mode must be a non-empty valid UTF-8 binary"

  defp error_message(:invalid_text_entities),
    do: "Nadia.InputPollOption text_entities must be a list"

  defp error_message(:text_formatting_conflict),
    do: "Nadia.InputPollOption text_parse_mode and text_entities are mutually exclusive"

  defp error_message(reason),
    do: "invalid Nadia.InputPollOption value: #{inspect(reason)}"
end
