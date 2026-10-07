defmodule Nadia.InputRichBlock do
  @moduledoc """
  Typed builders for Telegram `InputRichBlock` objects.

  One constructor exists per official block type. Each builder fixes the
  Telegram `type` discriminator, omits `nil` options, and preserves explicit
  `false` values. Blocks compose: `list/2` items, `details/2` content,
  `collage/2` and `slideshow/2` items, `table/2` and `buttons/2` rows, and
  `expandable_block_quotation/2` and `section_heading/2` content accept both
  plain maps and values built in this module. Telegram enforces nesting and
  structural limits; Nadia validates types locally.
  """

  @enforce_keys [:type, :fields]
  defstruct [:type, :fields]

  @typedoc "A typed Telegram InputRichBlock value. Its representation is opaque."
  @opaque t :: %__MODULE__{type: type, fields: map}

  @type type ::
          :paragraph
          | :section_heading
          | :preformatted
          | :footer
          | :divider
          | :mathematical_expression
          | :anchor
          | :list
          | :block_quotation
          | :pull_quotation
          | :expandable_block_quotation
          | :collage
          | :slideshow
          | :table
          | :details
          | :map
          | :animation
          | :audio
          | :photo
          | :video
          | :voice_note
          | :thinking
          | :buttons

  @type options :: keyword | map

  @doc "Builds a text paragraph block."
  @spec paragraph(term, options) :: t
  def paragraph(text, options \\ []) do
    build(:paragraph, %{text: text}, options, [:is_expandable])
  end

  @doc "Builds a section heading block."
  @spec section_heading(term, options) :: t
  def section_heading(text, options \\ []) do
    build(:section_heading, %{text: text}, options, [])
  end

  @doc "Builds a preformatted code block."
  @spec preformatted(binary, options) :: t
  def preformatted(text, options \\ []) do
    build(:preformatted, %{text: text}, options, [:language])
  end

  @doc "Builds a footer block."
  @spec footer(term, options) :: t
  def footer(text, options \\ []) do
    build(:footer, %{text: text}, options, [])
  end

  @doc "Builds a divider block."
  @spec divider() :: t
  def divider, do: build(:divider, %{}, [], [])

  @doc "Builds a mathematical expression block."
  @spec mathematical_expression(binary, options) :: t
  def mathematical_expression(expression, options \\ []) do
    build(:mathematical_expression, %{expression: expression}, options, [])
  end

  @doc "Builds an anchor block."
  @spec anchor(binary) :: t
  def anchor(name), do: build(:anchor, %{name: name}, [], [])

  @doc "Builds a list block of `InputRichBlockListItem` values."
  @spec list(list, options) :: t
  def list(items, options \\ []) when is_list(items) do
    build(:list, %{items: items}, options, [])
  end

  @doc "Builds a block quotation block."
  @spec block_quotation(term, options) :: t
  def block_quotation(text, options \\ []) do
    build(:block_quotation, %{text: text}, options, [])
  end

  @doc "Builds a pull quotation block."
  @spec pull_quotation(term, options) :: t
  def pull_quotation(text, options \\ []) do
    build(:pull_quotation, %{text: text}, options, [])
  end

  @doc "Builds an expandable block quotation block."
  @spec expandable_block_quotation(term, options) :: t
  def expandable_block_quotation(text, options \\ []) do
    build(:expandable_block_quotation, %{text: text}, options, [])
  end

  @doc "Builds a collage block of `InputMedia` values."
  @spec collage(list, options) :: t
  def collage(items, options \\ []) when is_list(items) do
    build(:collage, %{items: items}, options, [])
  end

  @doc "Builds a slideshow block of `InputMedia` values."
  @spec slideshow(list, options) :: t
  def slideshow(items, options \\ []) when is_list(items) do
    build(:slideshow, %{items: items}, options, [])
  end

  @doc """
  Builds a table block. `rows` is a list of row lists; each cell is a plain
  map or a value built in this module.
  """
  @spec table(list, options) :: t
  def table(rows, options \\ []) when is_list(rows) do
    build(:table, %{rows: rows}, options, [:is_compact])
  end

  @doc """
  Builds a details (collapsible) block.

  `content` is a list of blocks; `title` is a plain map or rich text value
  built in this module.
  """
  @spec details(term, list, options) :: t
  def details(title, content, options \\ []) when is_list(content) do
    build(:details, %{title: title, content: content}, options, [:is_open])
  end

  @doc "Builds a map location block."
  @spec map(float, float, options) :: t
  def map(latitude, longitude, options \\ []) do
    build(:map, %{latitude: latitude, longitude: longitude}, options, [
      :width,
      :height,
      :x,
      :y
    ])
  end

  @doc "Builds an animation media block. `media` is an `Nadia.InputMedia` value or map."
  @spec map_media(term, options) :: t
  def map_media(media, options \\ []) do
    build(:animation, %{media: media}, options, [:duration, :width, :height])
  end

  @doc "Builds an audio media block. `media` is an `Nadia.InputMedia` value or map."
  @spec audio_media(term, options) :: t
  def audio_media(media, options \\ []) do
    build(:audio, %{media: media}, options, [:duration])
  end

  @doc "Builds a photo media block. `media` is an `Nadia.InputMedia` value or map."
  @spec photo_media(term, options) :: t
  def photo_media(media, options \\ []) do
    build(:photo, %{media: media}, options, [:is_above_text])
  end

  @doc "Builds a video media block. `media` is an `Nadia.InputMedia` value or map."
  @spec video_media(term, options) :: t
  def video_media(media, options \\ []) do
    build(:video, %{media: media}, options, [:duration, :width, :height])
  end

  @doc "Builds a voice-note media block. `media` is an `Nadia.InputMedia` value or map."
  @spec voice_note_media(term, options) :: t
  def voice_note_media(media, options \\ []) do
    build(:voice_note, %{media: media}, options, [:duration])
  end

  @doc "Builds a thinking block, allowed in drafts only."
  @spec thinking(options) :: t
  def thinking(options \\ []) do
    build(:thinking, %{}, options, [])
  end

  @doc """
  Builds a buttons block. `rows` is a list of lists of button maps
  (`RichMessageButton`-shaped) or `Nadia.Model.InlineKeyboardButton` values.
  """
  @spec buttons(list, options) :: t
  def buttons(rows, options \\ []) when is_list(rows) do
    build(:buttons, %{rows: rows}, options, [])
  end

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{type: type, fields: fields})
      when is_atom(type) and is_map(fields) do
    fields = Map.new(fields, fn {key, value} -> {key, media_value_to_map(value)} end)
    {:ok, Map.put(fields, :type, Atom.to_string(type))}
  end

  def to_map(_block), do: {:error, :invalid_input_rich_block}

  defp media_value_to_map(%Nadia.InputMedia{} = media) do
    case Nadia.InputMedia.to_map(media) do
      {:ok, map} -> map
      {:error, _reason} -> media
    end
  end

  defp media_value_to_map(%Nadia.InputRichBlock{} = block) do
    case to_map(block) do
      {:ok, map} -> map
      {:error, _reason} -> block
    end
  end

  defp media_value_to_map(value) when is_list(value),
    do: Enum.map(value, &media_value_to_map/1)

  defp media_value_to_map(value) when is_map(value),
    do: Map.new(value, fn {key, item} -> {key, media_value_to_map(item)} end)

  defp media_value_to_map(value), do: value

  defp build(type, required, options, allowed) do
    fields =
      options
      |> normalize_options!()
      |> Enum.reduce(required, fn {key, value}, fields ->
        if key in allowed do
          if is_nil(value), do: fields, else: Map.put(fields, key, value)
        else
          raise ArgumentError, "unsupported Nadia.InputRichBlock option: #{inspect(key)}"
        end
      end)

    %__MODULE__{type: type, fields: fields}
  end

  defp normalize_options!(options) when is_map(options), do: Map.to_list(options)

  defp normalize_options!(options) when is_list(options) do
    if Keyword.keyword?(options) do
      options
    else
      raise ArgumentError, "Nadia.InputRichBlock options must be a keyword list or map"
    end
  end

  defp normalize_options!(_options),
    do: raise(ArgumentError, "Nadia.InputRichBlock options must be a keyword list or map")
end
