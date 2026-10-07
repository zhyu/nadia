defmodule Nadia.InputRichMessage do
  @moduledoc """
  Typed builders for Telegram `InputRichMessage` objects.

  `html/2` and `markdown/2` fix the selected formatting mode and validate the
  locally enforceable rich-message limits. `blocks/2` builds block-based
  content and `with_media/2` attaches explicit embedded media. Nadia validates
  valid UTF-8, the 32,768-character source limit, the 500-block and 50-media
  limits, media ids, and Boolean flags. Nadia does not parse or otherwise
  validate HTML or Markdown formatting.

  Telegram enforces up to 500 blocks, 16 nesting levels, 50 media attachments,
  and 20 table columns, as well as the supported syntax, block structure,
  media URLs and MIME types, rendering, and chat media permissions.

  Telegram permits thinking blocks only in rich-message drafts. Context
  validation conservatively detects the case-insensitive literal
  `<tg-thinking` prefix anywhere in the source. This can reject escaped or
  otherwise non-tag text containing that literal because Nadia intentionally
  does not include an HTML or Markdown parser.
  """

  alias Nadia.InputFile
  alias Nadia.InputMedia
  alias Nadia.InputRichBlock

  @enforce_keys [:mode, :fields]
  defstruct [:mode, :fields]

  @typedoc "A typed Telegram InputRichMessage value. Its representation is opaque."
  @opaque t :: %__MODULE__{mode: :html | :markdown | :blocks, fields: map}

  @type options :: keyword | map
  @type context :: :send | :draft | :edit | :inline_content

  @modes [:html, :markdown]
  @contexts [:send, :draft, :edit, :inline_content]
  @optional_fields [:is_rtl, :skip_entity_detection]
  @maximum_characters 32_768
  @maximum_media 50

  @doc """
  Builds a rich message described with Telegram's supported block entities.

  Each block is a map or `Nadia.InputRichBlock` value carrying the official
  `type` discriminator. Telegram enforces up to 500 blocks and 16 nesting
  levels. Nadia validates the 500-block limit locally; block structure is
  validated by Telegram.
  """
  @spec blocks(list, options) :: t
  def blocks(blocks, options \\ []) when is_list(blocks) do
    with :ok <- validate_blocks(blocks, :blocks) do
      input = build_fields(%{blocks: Enum.map(blocks, &block_to_map/1)}, options)

      case to_map(input) do
        {:ok, _map} -> input
        {:error, reason} -> raise ArgumentError, error_message(reason)
      end
    else
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

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

  @doc """
  Builds a rich message with explicit embedded media plus HTML or Markdown
  source.

  Media are referenced from the source with `tg://photo?id=`, `tg://video?id=`,
  `tg://document?id=`, or `tg://audio?id=` links. Each media entry is a map
  with `id` and `media` keys, a `Nadia.InputRichMessageMedia` value, or a
  `Nadia.InputMedia` value (whose `id` is derived from `media`). Nadia
  validates the 50-media limit, unique non-empty ASCII ids where given, and
  typed media values; the referenced media types are validated by Telegram.
  """
  @spec with_media(t, list) :: t
  def with_media(%__MODULE__{mode: mode, fields: fields}, media) when is_list(media) do
    with :ok <- validate_media_list(media, :media) do
      media_map = Enum.map(media, &media_entry_to_map/1)
      enriched = %__MODULE__{mode: mode, fields: Map.put(fields, :media, media_map)}

      case to_map(enriched) do
        {:ok, _map} -> enriched
        {:error, reason} -> raise ArgumentError, error_message(reason)
      end
    else
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

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

  defp build_fields(required, options) do
    fields =
      options
      |> normalize_options!()
      |> Enum.reduce(required, fn {key, value}, fields ->
        if key in @optional_fields and not is_nil(value) do
          Map.put(fields, key, value)
        else
          raise ArgumentError, "unsupported Nadia.InputRichMessage option: #{inspect(key)}"
        end
      end)

    %__MODULE__{mode: :blocks, fields: fields}
  end

  defp validate_blocks([], _field), do: {:error, {:block_count, 0}}

  defp validate_blocks(blocks, _field) when is_list(blocks) do
    if length(blocks) > 500 do
      {:error, {:block_count, length(blocks)}}
    else
      :ok
    end
  end

  defp block_to_map(%Nadia.InputRichBlock{} = block) do
    case InputRichBlock.to_map(block) do
      {:ok, map} -> map
      {:error, reason} -> raise ArgumentError, error_message({:input_rich_block, reason})
    end
  end

  defp block_to_map(%{} = block), do: block
  defp block_to_map(block), do: block

  defp validate_media_list([], :media), do: {:error, {:media_count, 0}}

  defp validate_media_list(media, :media) when is_list(media) do
    if length(media) > @maximum_media do
      {:error, {:media_count, length(media)}}
    else
      media
      |> Enum.with_index()
      |> Enum.reduce_while(:ok, fn {entry, index}, :ok ->
        case validate_media_entry(entry, index) do
          :ok -> {:cont, :ok}
          {:error, _reason} = error -> {:halt, error}
        end
      end)
    end
  end

  defp validate_media_list(_media, field), do: {:error, {:media_required, field}}

  defp validate_media_entry(%Nadia.InputRichMessageMedia{} = entry, _index) do
    with :ok <- validate_media_id(entry.fields[:id]),
         :ok <- validate_media_value(Map.get(entry.fields, :media)) do
      :ok
    end
  end

  defp validate_media_entry(%Nadia.InputMedia{} = _entry, _index), do: :ok

  defp validate_media_entry(%{} = entry, _index) do
    with :ok <- validate_media_id(entry[:id]),
         :ok <- validate_media_value(entry[:media]) do
      :ok
    end
  end

  defp validate_media_entry(_entry, _index), do: {:error, :invalid_media_entry}

  defp validate_media_id(nil), do: :ok

  defp validate_media_id(id) when is_binary(id) do
    if byte_size(id) in 1..64 and id =~ ~r/^[A-Za-z0-9_-]+$/ do
      :ok
    else
      {:error, {:invalid_media_id, id}}
    end
  end

  defp validate_media_id(id), do: {:error, {:invalid_media_id, id}}

  defp validate_media_value(%Nadia.InputMedia{} = media) do
    case InputMedia.to_map(media) do
      {:ok, %{} = _map} -> :ok
      {:error, reason} -> {:error, {:input_media, reason}}
    end
  end

  defp validate_media_value(%{} = _media), do: :ok
  defp validate_media_value(_media), do: {:error, :media_entry_requires_map}

  defp media_entry_to_map(%Nadia.InputRichMessageMedia{} = entry) do
    reject_nil_values(%{
      id: entry.fields[:id],
      media: media_value_to_map(Map.get(entry.fields, :media))
    })
  end

  defp media_entry_to_map(%Nadia.InputMedia{} = entry) do
    case InputMedia.to_map(entry) do
      {:ok, %{} = map} ->
        id = media_id_from_media(map[:media])
        reject_nil_values(%{id: id, media: map})
    end
  end

  defp media_entry_to_map(%{} = entry) do
    entry
    |> Map.new(fn {key, value} -> {key, media_value_to_map(value)} end)
    |> reject_nil_values()
  end

  defp media_value_to_map(%Nadia.InputMedia{} = media) do
    case InputMedia.to_map(media) do
      {:ok, map} -> map
      {:error, reason} -> raise ArgumentError, error_message({:input_media, reason})
    end
  end

  defp media_value_to_map(value), do: value

  defp media_id_from_media(%InputFile{source: {kind, value}}),
    do: media_id_from_source(kind, value)

  defp media_id_from_media(source) when is_binary(source),
    do: media_id_from_source(:binary, source)

  defp media_id_from_media(_source), do: nil

  defp media_id_from_source(_kind, value) when is_binary(value) do
    base = value |> String.split("/") |> List.last()
    base = if base == "", do: value, else: base
    id = base |> String.replace(~r/[^A-Za-z0-9_-]+/, "_") |> String.slice(0, 64)

    if id == "", do: nil, else: id
  end

  defp media_id_from_source(_kind, _value), do: nil

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

  @valid_modes [:html, :markdown, :blocks]

  defp validate_mode(mode) when mode in @valid_modes, do: :ok
  defp validate_mode(mode), do: {:error, {:invalid_discriminator, mode}}

  defp validate_fields_map(fields) when is_map(fields), do: :ok
  defp validate_fields_map(fields), do: {:error, {:invalid_fields, fields}}

  defp validate_allowed_fields(fields) do
    validate_keys(fields, @modes ++ [:blocks, :media] ++ @optional_fields)
  end

  defp validate_keys(map, allowed) do
    case map |> Map.keys() |> Enum.sort() |> Enum.find(&(&1 not in allowed)) do
      nil -> :ok
      field -> {:error, {:unsupported_field, field}}
    end
  end

  defp validate_mode_fields(mode, fields) do
    with :ok <- validate_single_content_field(fields) do
      case mode do
        :html -> typed_content(fields, :html)
        :markdown -> typed_content(fields, :markdown)
        :blocks -> {:ok, nil}
      end
    end
  end

  defp validate_single_content_field(fields) do
    content_keys =
      Enum.count(fields, &match?({key, _} when key in [:html, :markdown, :blocks], &1))

    case content_keys do
      1 -> :ok
      0 -> {:error, {:invalid_content_fields, :neither}}
      _ -> {:error, {:invalid_content_fields, :multiple}}
    end
  end

  defp typed_content(fields, key) do
    if Map.has_key?(fields, key) do
      {:ok, Map.fetch!(fields, key)}
    else
      {:error, {:mode_mismatch, key, :blocks}}
    end
  end

  defp validate_content(nil, :blocks), do: :ok

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
    content = Map.get(fields, :html) || Map.get(fields, :markdown) || ""

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
