defmodule Nadia.InputRichMessage do
  @moduledoc """
  Typed builders for Telegram `InputRichMessage` objects.

  `html/2` and `markdown/2` fix the selected formatting mode and validate the
  locally enforceable rich-message limits. Nadia validates valid UTF-8, the
  32,768-character source limit, and Boolean flags. Nadia does not parse or
  otherwise validate HTML or Markdown formatting.

  Telegram enforces up to 500 blocks, 16 nesting levels, 50 media attachments,
  and 20 table columns, as well as the supported syntax, block structure,
  media URLs and MIME types, rendering, and chat media permissions.

  Telegram permits thinking blocks only in rich-message drafts. Context
  validation conservatively detects the case-insensitive literal
  `<tg-thinking` prefix anywhere in the source. This can reject escaped or
  otherwise non-tag text containing that literal because Nadia intentionally
  does not include an HTML or Markdown parser.
  """

  @enforce_keys [:mode, :fields]
  defstruct [:mode, :fields]

  @typedoc "A typed Telegram InputRichMessage value. Its representation is opaque."
  @opaque t :: %__MODULE__{mode: :html | :markdown, fields: map}

  @type options :: keyword | map
  @type context :: :send | :draft | :edit | :inline_content

  @modes [:html, :markdown]
  @contexts [:send, :draft, :edit, :inline_content]
  @optional_fields [:is_rtl, :skip_entity_detection]
  @maximum_characters 32_768

  @doc """
  Builds a rich message described with Telegram's supported HTML formatting.

  The source must be valid UTF-8 and contain at most 32,768 Unicode
  characters. Empty source is accepted because the Bot API does not document
  a non-empty minimum.
  """
  @spec html(binary, options) :: t
  def html(content, options \\ []), do: build(:html, content, options)

  @doc """
  Builds a rich message described with Telegram's supported Markdown
  formatting.

  The source must be valid UTF-8 and contain at most 32,768 Unicode
  characters. Empty source is accepted because the Bot API does not document
  a non-empty minimum.
  """
  @spec markdown(binary, options) :: t
  def markdown(content, options \\ []), do: build(:markdown, content, options)

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{mode: mode, fields: fields} = input) do
    with :ok <- validate_struct_fields(input),
         :ok <- validate_mode(mode),
         :ok <- validate_fields_map(fields),
         :ok <- validate_allowed_fields(fields),
         {:ok, content} <- validate_mode_fields(mode, fields),
         :ok <- validate_content(content, mode),
         :ok <- validate_boolean(fields[:is_rtl], :is_rtl),
         :ok <- validate_boolean(fields[:skip_entity_detection], :skip_entity_detection) do
      {:ok, reject_nil_values(fields)}
    end
  end

  def to_map(_input), do: {:error, :invalid_input_rich_message}

  @doc false
  @spec validate_context(term, context) :: :ok | {:error, term}
  def validate_context(input, context) when context in @contexts do
    with {:ok, fields} <- to_map(input),
         :ok <- validate_draft_only_construct(fields, context) do
      :ok
    end
  end

  def validate_context(_input, context), do: {:error, {:invalid_context, context}}

  defp build(mode, content, options) do
    fields =
      options
      |> normalize_options!()
      |> Enum.reduce(%{mode => content}, fn {key, value}, fields ->
        if key in @optional_fields do
          Map.put(fields, key, value)
        else
          raise ArgumentError, "unsupported Nadia.InputRichMessage option: #{inspect(key)}"
        end
      end)

    input = %__MODULE__{mode: mode, fields: fields}

    case to_map(input) do
      {:ok, _map} -> input
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

  defp normalize_options!(options) when is_map(options) do
    options
    |> Map.to_list()
    |> Enum.sort()
  end

  defp normalize_options!(options) when is_list(options) do
    if Keyword.keyword?(options) do
      options
    else
      raise ArgumentError, "Nadia.InputRichMessage options must be a keyword list or map"
    end
  end

  defp normalize_options!(_options),
    do: raise(ArgumentError, "Nadia.InputRichMessage options must be a keyword list or map")

  defp validate_struct_fields(input) do
    validate_keys(input, [:__struct__, :fields, :mode])
  end

  defp validate_mode(mode) when mode in @modes, do: :ok
  defp validate_mode(mode), do: {:error, {:invalid_discriminator, mode}}

  defp validate_fields_map(fields) when is_map(fields), do: :ok
  defp validate_fields_map(fields), do: {:error, {:invalid_fields, fields}}

  defp validate_allowed_fields(fields) do
    validate_keys(fields, @modes ++ @optional_fields)
  end

  defp validate_keys(map, allowed) do
    case map |> Map.keys() |> Enum.sort() |> Enum.find(&(&1 not in allowed)) do
      nil -> :ok
      field -> {:error, {:unsupported_field, field}}
    end
  end

  defp validate_mode_fields(mode, fields) do
    case {Map.has_key?(fields, :html), Map.has_key?(fields, :markdown)} do
      {true, true} ->
        {:error, {:invalid_content_fields, :both}}

      {false, false} ->
        {:error, {:invalid_content_fields, :neither}}

      {true, false} when mode == :html ->
        {:ok, fields.html}

      {false, true} when mode == :markdown ->
        {:ok, fields.markdown}

      {true, false} ->
        {:error, {:mode_mismatch, mode, :html}}

      {false, true} ->
        {:error, {:mode_mismatch, mode, :markdown}}
    end
  end

  defp validate_content(content, mode) when is_binary(content) do
    cond do
      not String.valid?(content) ->
        {:error, {:invalid_utf8, mode}}

      String.length(content) > @maximum_characters ->
        {:error, {:content_too_long, mode, @maximum_characters}}

      true ->
        :ok
    end
  end

  defp validate_content(_content, mode), do: {:error, {:binary_required, mode}}

  defp validate_boolean(nil, _field), do: :ok
  defp validate_boolean(value, _field) when is_boolean(value), do: :ok
  defp validate_boolean(_value, field), do: {:error, {:boolean_required, field}}

  defp validate_draft_only_construct(_fields, :draft), do: :ok

  defp validate_draft_only_construct(fields, context) do
    content = Map.get(fields, :html) || Map.get(fields, :markdown)

    if content
       |> String.downcase()
       |> String.contains?("<tg-thinking") do
      {:error, {:unsupported_context, context, :tg_thinking}}
    else
      :ok
    end
  end

  defp reject_nil_values(map) do
    for {key, value} <- map, not is_nil(value), into: %{}, do: {key, value}
  end

  defp error_message({:invalid_utf8, mode}),
    do: "Nadia.InputRichMessage #{mode} content must be valid UTF-8"

  defp error_message({:content_too_long, mode, @maximum_characters}),
    do:
      "Nadia.InputRichMessage #{mode} content must contain at most #{@maximum_characters} Unicode characters"

  defp error_message({:binary_required, mode}),
    do: "Nadia.InputRichMessage #{mode} content must be a binary"

  defp error_message({:boolean_required, field}),
    do: "Nadia.InputRichMessage #{field} must be a boolean"

  defp error_message(reason),
    do: "invalid Nadia.InputRichMessage value: #{inspect(reason)}"
end
