defmodule Nadia.InputTextMessageContent do
  @moduledoc """
  Typed builder for Telegram `InputTextMessageContent`.

  Message text must contain 1 to 4096 valid UTF-8 characters. Optional
  formatting can be supplied with either `:parse_mode` or `:entities`, but not
  both. `:link_preview_options` accepts the current fixed Telegram
  `LinkPreviewOptions` shape and preserves explicit `false` values.
  """

  @enforce_keys [:fields]
  defstruct [:fields]

  @typedoc "Typed inline-query content containing a text message."
  @opaque t :: %__MODULE__{fields: map}

  @type options :: keyword | map

  @optional_fields [:parse_mode, :entities, :link_preview_options]
  @allowed_fields [:message_text | @optional_fields]
  @link_preview_fields [
    :is_disabled,
    :url,
    :prefer_small_media,
    :prefer_large_media,
    :show_above_text
  ]
  @link_preview_boolean_fields [
    :is_disabled,
    :prefer_small_media,
    :prefer_large_media,
    :show_above_text
  ]

  @doc """
  Builds text content for an inline-query result.

  Supported options are `:parse_mode`, `:entities`, and
  `:link_preview_options`. Options whose value is `nil` are omitted.
  """
  @spec new(binary, options) :: t
  def new(message_text, options \\ []) do
    fields =
      options
      |> normalize_options!()
      |> Enum.reduce(%{message_text: message_text}, fn {key, value}, fields ->
        if key in @optional_fields do
          if is_nil(value), do: fields, else: Map.put(fields, key, value)
        else
          raise ArgumentError, "unsupported Nadia.InputTextMessageContent option: #{inspect(key)}"
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
         :ok <- validate_message_text(fields[:message_text]),
         :ok <- validate_parse_mode(fields[:parse_mode]),
         :ok <- validate_entities(fields[:entities]),
         :ok <- validate_formatting(fields),
         {:ok, link_preview_options} <-
           normalize_link_preview_options(fields[:link_preview_options]) do
      fields =
        if Map.has_key?(fields, :link_preview_options) do
          Map.put(fields, :link_preview_options, link_preview_options)
        else
          fields
        end

      {:ok, reject_nil_values(fields)}
    end
  end

  def to_map(_content), do: {:error, :invalid_input_text_message_content}

  defp normalize_options!(options) when is_map(options), do: Map.to_list(options)

  defp normalize_options!(options) when is_list(options) do
    if Keyword.keyword?(options) do
      options
    else
      raise ArgumentError, "Nadia.InputTextMessageContent options must be a keyword list or map"
    end
  end

  defp normalize_options!(_options),
    do:
      raise(ArgumentError, "Nadia.InputTextMessageContent options must be a keyword list or map")

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

  defp validate_message_text(message_text) when is_binary(message_text) do
    if String.valid?(message_text) and String.length(message_text) in 1..4096 do
      :ok
    else
      {:error, :invalid_message_text}
    end
  end

  defp validate_message_text(_message_text), do: {:error, :invalid_message_text}

  defp validate_parse_mode(nil), do: :ok

  defp validate_parse_mode(parse_mode) when is_binary(parse_mode) and byte_size(parse_mode) > 0 do
    if String.valid?(parse_mode), do: :ok, else: {:error, :invalid_parse_mode}
  end

  defp validate_parse_mode(_parse_mode), do: {:error, :invalid_parse_mode}

  defp validate_entities(nil), do: :ok
  defp validate_entities(entities) when is_list(entities), do: :ok
  defp validate_entities(_entities), do: {:error, :invalid_entities}

  defp validate_formatting(%{parse_mode: parse_mode, entities: entities})
       when not is_nil(parse_mode) and not is_nil(entities),
       do: {:error, :text_formatting_conflict}

  defp validate_formatting(_fields), do: :ok

  defp normalize_link_preview_options(nil), do: {:ok, nil}

  defp normalize_link_preview_options(options) when is_list(options) do
    if Keyword.keyword?(options) do
      options
      |> Map.new()
      |> normalize_link_preview_options()
    else
      {:error, :invalid_link_preview_options}
    end
  end

  defp normalize_link_preview_options(%_{} = options) do
    options
    |> Map.from_struct()
    |> normalize_link_preview_options()
  end

  defp normalize_link_preview_options(options) when is_map(options) do
    options = reject_nil_values(options)

    with :ok <- validate_link_preview_fields(options),
         :ok <- validate_link_preview_booleans(options),
         :ok <- validate_link_preview_url(options[:url]) do
      {:ok, options}
    end
  end

  defp normalize_link_preview_options(_options), do: {:error, :invalid_link_preview_options}

  defp validate_link_preview_fields(options) do
    case options
         |> Map.keys()
         |> Enum.sort()
         |> Enum.find(&(&1 not in @link_preview_fields)) do
      nil -> :ok
      field -> {:error, {:link_preview_options, {:unsupported_field, field}}}
    end
  end

  defp validate_link_preview_booleans(options) do
    Enum.reduce_while(@link_preview_boolean_fields, :ok, fn field, :ok ->
      case Map.fetch(options, field) do
        :error ->
          {:cont, :ok}

        {:ok, value} when is_boolean(value) ->
          {:cont, :ok}

        {:ok, value} ->
          {:halt, {:error, {:link_preview_options, {:boolean_required, field, value}}}}
      end
    end)
  end

  defp validate_link_preview_url(nil), do: :ok

  defp validate_link_preview_url(url) when is_binary(url) do
    if String.valid?(url), do: :ok, else: {:error, {:link_preview_options, :invalid_url}}
  end

  defp validate_link_preview_url(_url), do: {:error, {:link_preview_options, :invalid_url}}

  defp reject_nil_values(map) do
    for {key, value} <- map, not is_nil(value), into: %{}, do: {key, value}
  end

  defp error_message(:invalid_message_text),
    do: "Nadia.InputTextMessageContent message_text must be valid UTF-8 with 1 to 4096 characters"

  defp error_message(:invalid_parse_mode),
    do: "Nadia.InputTextMessageContent parse_mode must be a non-empty valid UTF-8 binary"

  defp error_message(:invalid_entities),
    do: "Nadia.InputTextMessageContent entities must be a list"

  defp error_message(:text_formatting_conflict),
    do: "Nadia.InputTextMessageContent parse_mode and entities are mutually exclusive"

  defp error_message(:invalid_link_preview_options),
    do:
      "Nadia.InputTextMessageContent link_preview_options must be a keyword list, map, or struct"

  defp error_message({:link_preview_options, {:unsupported_field, field}}),
    do:
      "Nadia.InputTextMessageContent link_preview_options does not support field #{inspect(field)}"

  defp error_message({:link_preview_options, {:boolean_required, field, _value}}),
    do: "Nadia.InputTextMessageContent link_preview_options #{field} must be a boolean"

  defp error_message({:link_preview_options, :invalid_url}),
    do: "Nadia.InputTextMessageContent link_preview_options url must be valid UTF-8"

  defp error_message(reason),
    do: "invalid Nadia.InputTextMessageContent value: #{inspect(reason)}"
end
