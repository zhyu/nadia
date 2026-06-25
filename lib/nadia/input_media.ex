defmodule Nadia.InputMedia do
  @moduledoc """
  Typed builders for Telegram `InputMedia` objects.

  The builder fixes the Telegram `type` discriminator, omits `nil` options,
  and preserves explicit `false` values. Values can be passed directly to
  `Nadia.send_media_group/3,4`, `Nadia.edit_message_media/2,3`, and compatible
  media positions in `Nadia.send_poll/3,4`.

  Media and cover fields accept Telegram file IDs, supported HTTP URLs, or
  `Nadia.InputFile` values. Thumbnails are new JPEG multipart uploads only;
  use `Nadia.InputFile.path/2`, `bytes/3`, or `stream/3`. Live-photo video and
  photo fields do not support URLs.

  `sendMediaGroup` accepts 2-10 audio, document, live-photo, photo, or video
  items. Audio and document albums must be homogeneous. Animation is supported
  by `editMessageMedia`, but not by `sendMediaGroup`.

  Poll descriptions and quiz explanations accept every variant in this module.
  Poll options accept animation, live photo, photo, and video; audio and
  document are rejected locally when used as typed option media. See
  `Nadia.InputPollMedia` for typed link, location, sticker, and venue values.
  """

  alias Nadia.InputFile

  @enforce_keys [:variant, :fields]
  defstruct [:variant, :fields]

  @typedoc "A typed Telegram InputMedia value. Its representation is opaque."
  @opaque t :: %__MODULE__{variant: variant, fields: map}

  @type variant :: :animation | :audio | :document | :live_photo | :photo | :video
  @type source :: binary | InputFile.t()
  @type options :: keyword | map

  @common_caption_options [
    :caption,
    :parse_mode,
    :caption_entities
  ]

  @doc "Builds an animation media object."
  @spec animation(source, options) :: t
  def animation(media, options \\ []) do
    build(:animation, %{media: required_source!(media, :media)}, options, [
      :thumbnail,
      :show_caption_above_media,
      :width,
      :height,
      :duration,
      :has_spoiler
      | @common_caption_options
    ])
  end

  @doc "Builds an audio media object."
  @spec audio(source, options) :: t
  def audio(media, options \\ []) do
    build(:audio, %{media: required_source!(media, :media)}, options, [
      :thumbnail,
      :duration,
      :performer,
      :title
      | @common_caption_options
    ])
  end

  @doc "Builds a document media object."
  @spec document(source, options) :: t
  def document(media, options \\ []) do
    build(:document, %{media: required_source!(media, :media)}, options, [
      :thumbnail,
      :disable_content_type_detection
      | @common_caption_options
    ])
  end

  @doc "Builds a live-photo media object from its video and static photo."
  @spec live_photo(source, source, options) :: t
  def live_photo(media, photo, options \\ []) do
    media = media |> required_source!(:media) |> reject_url!(:media)
    photo = photo |> required_source!(:photo) |> reject_url!(:photo)

    build(:live_photo, %{media: media, photo: photo}, options, [
      :show_caption_above_media,
      :has_spoiler
      | @common_caption_options
    ])
  end

  @doc "Builds a photo media object."
  @spec photo(source, options) :: t
  def photo(media, options \\ []) do
    build(:photo, %{media: required_source!(media, :media)}, options, [
      :show_caption_above_media,
      :has_spoiler
      | @common_caption_options
    ])
  end

  @doc "Builds a video media object."
  @spec video(source, options) :: t
  def video(media, options \\ []) do
    build(:video, %{media: required_source!(media, :media)}, options, [
      :thumbnail,
      :cover,
      :start_timestamp,
      :show_caption_above_media,
      :width,
      :height,
      :duration,
      :supports_streaming,
      :has_spoiler
      | @common_caption_options
    ])
  end

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{variant: variant, fields: fields})
      when variant in [:animation, :audio, :document, :live_photo, :photo, :video] and
             is_map(fields) do
    with :ok <- validate_required_fields(variant, fields),
         :ok <- validate_thumbnail(fields) do
      {:ok, Map.put(fields, :type, Atom.to_string(variant))}
    end
  end

  def to_map(%__MODULE__{variant: variant}), do: {:error, {:invalid_discriminator, variant}}

  @doc false
  @spec validate_media_group(term) :: :ok | {:error, term}
  def validate_media_group([]), do: {:error, {:media_group_size, 0}}

  def validate_media_group(media) when is_list(media) do
    if Enum.all?(media, &match?(%__MODULE__{}, &1)) do
      variants = Enum.map(media, & &1.variant)

      cond do
        length(media) not in 2..10 ->
          {:error, {:media_group_size, length(media)}}

        :animation in variants ->
          {:error, {:media_group_variant, :animation}}

        :audio in variants and Enum.any?(variants, &(&1 != :audio)) ->
          {:error, :mixed_audio_media_group}

        :document in variants and Enum.any?(variants, &(&1 != :document)) ->
          {:error, :mixed_document_media_group}

        true ->
          validate_all(media)
      end
    else
      :ok
    end
  end

  def validate_media_group(_media), do: :ok

  defp validate_all(media) do
    Enum.reduce_while(media, :ok, fn item, :ok ->
      case to_map(item) do
        {:ok, _map} -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp build(variant, required, options, allowed) do
    fields =
      options
      |> normalize_options!()
      |> Enum.reduce(required, fn {key, value}, fields ->
        if key in allowed do
          if is_nil(value), do: fields, else: Map.put(fields, key, value)
        else
          raise ArgumentError, "unsupported Nadia.InputMedia option: #{inspect(key)}"
        end
      end)

    case validate_thumbnail(fields) do
      :ok -> %__MODULE__{variant: variant, fields: fields}
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

  defp normalize_options!(options) when is_map(options), do: Map.to_list(options)

  defp normalize_options!(options) when is_list(options) do
    if Keyword.keyword?(options) do
      options
    else
      raise ArgumentError, "Nadia.InputMedia options must be a keyword list or map"
    end
  end

  defp normalize_options!(_options),
    do: raise(ArgumentError, "Nadia.InputMedia options must be a keyword list or map")

  defp required_source!(%InputFile{} = source, _field), do: source

  defp required_source!(source, _field) when is_binary(source) and byte_size(source) > 0,
    do: source

  defp required_source!(_source, field),
    do: raise(ArgumentError, "Nadia.InputMedia #{field} must be a non-empty binary or InputFile")

  defp reject_url!(%InputFile{source: {:url, _url}}, field),
    do: raise(ArgumentError, "Nadia.InputMedia #{field} does not support URLs")

  defp reject_url!(source, field) when is_binary(source) do
    if http_url?(source) do
      raise ArgumentError, "Nadia.InputMedia #{field} does not support URLs"
    else
      source
    end
  end

  defp reject_url!(source, _field), do: source

  defp validate_required_fields(:live_photo, fields) do
    with :ok <- validate_source(fields[:media], :media),
         :ok <- validate_source(fields[:photo], :photo),
         :ok <- validate_not_url(fields[:media], :media),
         :ok <- validate_not_url(fields[:photo], :photo) do
      :ok
    end
  end

  defp validate_required_fields(_variant, fields), do: validate_source(fields[:media], :media)

  defp validate_source(%InputFile{}, _field), do: :ok

  defp validate_source(source, _field) when is_binary(source) and byte_size(source) > 0,
    do: :ok

  defp validate_source(_source, field), do: {:error, {:required, field}}

  defp validate_not_url(%InputFile{source: {:url, _url}}, field),
    do: {:error, {:url_not_supported, field}}

  defp validate_not_url(source, field) when is_binary(source) do
    if http_url?(source), do: {:error, {:url_not_supported, field}}, else: :ok
  end

  defp validate_not_url(_source, _field), do: :ok

  defp validate_thumbnail(%{thumbnail: thumbnail}) do
    case thumbnail do
      %InputFile{source: {kind, _value}} when kind in [:path, :bytes, :stream] -> :ok
      "attach://" <> name when byte_size(name) > 0 -> :ok
      _ -> {:error, :thumbnail_must_be_uploaded}
    end
  end

  defp validate_thumbnail(_fields), do: :ok

  defp http_url?(value) do
    case URI.parse(value) do
      %URI{scheme: scheme, host: host}
      when scheme in ["http", "https"] and is_binary(host) and byte_size(host) > 0 ->
        true

      _other ->
        false
    end
  end

  defp error_message(:thumbnail_must_be_uploaded),
    do: "Nadia.InputMedia thumbnail must be a new multipart upload"
end
