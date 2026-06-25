defmodule Nadia.InputPaidMedia do
  @moduledoc """
  Typed builders for Telegram `InputPaidMedia` objects.

  The builder fixes the Telegram `type` discriminator, omits `nil` options,
  and preserves explicit `false` values.

  Media and cover fields accept Telegram file IDs, supported HTTP URLs, or
  `Nadia.InputFile` values. Thumbnails must be fresh JPEG multipart uploads;
  use `Nadia.InputFile.path/2`, `bytes/3`, or `stream/3`. A non-empty manual
  `attach://` reference is also accepted for compatibility. Live-photo video
  and photo fields do not support URLs.
  """

  alias Nadia.InputFile

  @enforce_keys [:variant, :fields]
  defstruct [:variant, :fields]

  @typedoc "A typed Telegram InputPaidMedia value. Its representation is opaque."
  @opaque t :: %__MODULE__{variant: variant, fields: map}

  @type variant :: :live_photo | :photo | :video
  @type source :: binary | InputFile.t()
  @type options :: keyword | map

  @video_options [
    :thumbnail,
    :cover,
    :start_timestamp,
    :width,
    :height,
    :duration,
    :supports_streaming
  ]

  @doc "Builds a paid live-photo object from its video and static photo."
  @spec live_photo(source, source) :: t
  def live_photo(video, photo) do
    build(:live_photo, %{
      media: video |> required_source!(:media) |> reject_url!(:media),
      photo: photo |> required_source!(:photo) |> reject_url!(:photo)
    })
  end

  @doc "Builds a paid photo object."
  @spec photo(source) :: t
  def photo(media), do: build(:photo, %{media: required_source!(media, :media)})

  @doc "Builds a paid video object."
  @spec video(source, options) :: t
  def video(media, options \\ []) do
    fields =
      options
      |> normalize_options!()
      |> Enum.reduce(%{media: required_source!(media, :media)}, fn {key, value}, fields ->
        if key in @video_options do
          if is_nil(value), do: fields, else: Map.put(fields, key, value)
        else
          raise ArgumentError, "unsupported Nadia.InputPaidMedia option: #{inspect(key)}"
        end
      end)

    build(:video, fields)
  end

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{variant: variant, fields: fields}) do
    with :ok <- validate_variant(variant),
         :ok <- validate_fields_container(fields),
         :ok <- validate_field_names(variant, fields),
         :ok <- validate_required_fields(variant, fields),
         :ok <- validate_optional_sources(fields),
         :ok <- validate_thumbnail(fields) do
      {:ok, Map.put(fields, :type, Atom.to_string(variant))}
    end
  end

  @doc false
  @spec validate_media(term) :: :ok | {:error, term}
  def validate_media([]), do: {:error, {:media_size, 0}}

  def validate_media(media) when is_list(media) do
    if Enum.any?(media, &match?(%__MODULE__{}, &1)) do
      if length(media) in 1..10 do
        validate_typed_members(media)
      else
        {:error, {:media_size, length(media)}}
      end
    else
      :ok
    end
  end

  def validate_media(_media), do: :ok

  defp build(variant, fields) do
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
      raise ArgumentError, "Nadia.InputPaidMedia options must be a keyword list or map"
    end
  end

  defp normalize_options!(_options),
    do: raise(ArgumentError, "Nadia.InputPaidMedia options must be a keyword list or map")

  defp required_source!(%InputFile{} = source, _field), do: source

  defp required_source!(source, _field) when is_binary(source) and byte_size(source) > 0,
    do: source

  defp required_source!(_source, field),
    do:
      raise(
        ArgumentError,
        "Nadia.InputPaidMedia #{field} must be a non-empty binary or InputFile"
      )

  defp reject_url!(%InputFile{source: {:url, _url}}, field),
    do: raise(ArgumentError, "Nadia.InputPaidMedia #{field} does not support URLs")

  defp reject_url!(source, field) when is_binary(source) do
    if http_url?(source) do
      raise ArgumentError, "Nadia.InputPaidMedia #{field} does not support URLs"
    else
      source
    end
  end

  defp reject_url!(source, _field), do: source

  defp validate_variant(variant) when variant in [:live_photo, :photo, :video], do: :ok
  defp validate_variant(variant), do: {:error, {:invalid_discriminator, variant}}

  defp validate_fields_container(fields) when is_map(fields), do: :ok
  defp validate_fields_container(fields), do: {:error, {:invalid_fields, fields}}

  defp validate_field_names(:live_photo, fields),
    do: validate_allowed_fields(fields, [:media, :photo])

  defp validate_field_names(:photo, fields), do: validate_allowed_fields(fields, [:media])

  defp validate_field_names(:video, fields),
    do: validate_allowed_fields(fields, [:media | @video_options])

  defp validate_allowed_fields(fields, allowed) do
    case Enum.find(Map.keys(fields), &(&1 not in allowed)) do
      nil -> :ok
      field -> {:error, {:unsupported_field, field}}
    end
  end

  defp validate_required_fields(:live_photo, fields) do
    with :ok <- validate_source(fields[:media], :media),
         :ok <- validate_source(fields[:photo], :photo),
         :ok <- validate_not_url(fields[:media], :media),
         :ok <- validate_not_url(fields[:photo], :photo) do
      :ok
    end
  end

  defp validate_required_fields(_variant, fields), do: validate_source(fields[:media], :media)

  defp validate_optional_sources(fields) do
    with :ok <- validate_optional_source(fields, :cover) do
      :ok
    end
  end

  defp validate_optional_source(fields, field) do
    case Map.fetch(fields, field) do
      :error -> :ok
      {:ok, source} -> validate_source(source, field)
    end
  end

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

  defp validate_typed_members(media) do
    Enum.reduce_while(media, :ok, fn
      %__MODULE__{} = item, :ok ->
        case to_map(item) do
          {:ok, _map} -> {:cont, :ok}
          {:error, reason} -> {:halt, {:error, reason}}
        end

      _raw, :ok ->
        {:cont, :ok}
    end)
  end

  defp http_url?(value) do
    case URI.parse(value) do
      %URI{scheme: scheme, host: host}
      when scheme in ["http", "https"] and is_binary(host) and byte_size(host) > 0 ->
        true

      _other ->
        false
    end
  end

  defp error_message({:required, field}),
    do: "Nadia.InputPaidMedia #{field} must be a non-empty binary or InputFile"

  defp error_message({:url_not_supported, field}),
    do: "Nadia.InputPaidMedia #{field} does not support URLs"

  defp error_message(:thumbnail_must_be_uploaded),
    do: "Nadia.InputPaidMedia thumbnail must be a new multipart upload"

  defp error_message(reason), do: "invalid Nadia.InputPaidMedia value: #{inspect(reason)}"
end
