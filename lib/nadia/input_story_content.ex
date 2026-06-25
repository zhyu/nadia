defmodule Nadia.InputStoryContent do
  @moduledoc """
  Typed builders for Telegram `InputStoryContent` objects.

  Story media can't be reused: `photo` and `video` accept only new multipart
  uploads created with `Nadia.InputFile.path/2`, `bytes/3`, or a known-size
  `stream/3`. File IDs, URLs, bare binaries, and manual `attach://` references
  are rejected.

  Nadia fixes the Telegram `type` discriminator, omits `nil` options, preserves
  explicit `false`, and validates metadata it can inspect. Telegram still
  enforces the media itself: story photos must be 1080x1920 and at most 10 MB;
  story videos must be 720x1280, streamable MPEG4 encoded with H.265, include a
  key frame each second, and be at most 30 MB. Nadia does not decode uploads to
  verify dimensions, format, codec, streamability, keyframes, sound, or size.
  """

  alias Nadia.InputFile

  @enforce_keys [:variant, :fields]
  defstruct [:variant, :fields]

  @typedoc "A typed Telegram InputStoryContent value. Its representation is opaque."
  @opaque t :: %__MODULE__{variant: :photo | :video, fields: map}

  @type upload :: InputFile.t()
  @type options :: keyword | map

  @doc "Builds a story-photo upload."
  @spec photo(upload) :: t
  def photo(photo), do: build(:photo, %{photo: photo}, [])

  @doc """
  Builds a story-video upload.

  `:duration` accepts a number from 0 through 60 seconds.
  `:cover_frame_timestamp` must be nonnegative and, when duration is supplied,
  no greater than the duration. `:is_animation` must be a boolean and tells
  Telegram that the video has no sound.
  """
  @spec video(upload, options) :: t
  def video(video, options \\ []) do
    build(:video, %{video: video}, options)
  end

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{variant: variant, fields: fields}) do
    with :ok <- validate_variant(variant),
         :ok <- validate_fields_map(fields),
         :ok <- validate_allowed_fields(variant, fields),
         :ok <- validate_required_upload(variant, fields),
         :ok <- validate_options(variant, fields) do
      {:ok,
       fields
       |> reject_nil_values()
       |> Map.put(:type, Atom.to_string(variant))}
    end
  end

  defp build(variant, required, options) do
    fields =
      options
      |> normalize_options!()
      |> Enum.reduce(required, fn {key, value}, fields ->
        if key in allowed_optional_fields(variant) do
          Map.put(fields, key, value)
        else
          raise ArgumentError, "unsupported Nadia.InputStoryContent option: #{inspect(key)}"
        end
      end)

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
      raise ArgumentError, "Nadia.InputStoryContent options must be a keyword list or map"
    end
  end

  defp normalize_options!(_options),
    do: raise(ArgumentError, "Nadia.InputStoryContent options must be a keyword list or map")

  defp validate_variant(variant) when variant in [:photo, :video], do: :ok
  defp validate_variant(variant), do: {:error, {:invalid_discriminator, variant}}

  defp validate_fields_map(fields) when is_map(fields), do: :ok
  defp validate_fields_map(_fields), do: {:error, :invalid_fields}

  defp validate_allowed_fields(variant, fields) do
    allowed = [required_field(variant) | allowed_optional_fields(variant)]

    case fields |> Map.keys() |> Enum.sort() |> Enum.find(&(&1 not in allowed)) do
      nil -> :ok
      field -> {:error, {:unsupported_field, field}}
    end
  end

  defp validate_required_upload(variant, fields) do
    field = required_field(variant)
    validate_upload(Map.get(fields, field), field)
  end

  defp validate_upload(%InputFile{source: {:path, _path}}, _field), do: :ok
  defp validate_upload(%InputFile{source: {:bytes, _bytes}}, _field), do: :ok

  defp validate_upload(
         %InputFile{source: {:stream, _stream}, size: size},
         _field
       )
       when is_integer(size) and size >= 0,
       do: :ok

  defp validate_upload(_upload, field), do: {:error, {:upload_required, field}}

  defp validate_options(:photo, _fields), do: :ok

  defp validate_options(:video, fields) do
    with :ok <- validate_duration(fields[:duration]),
         :ok <-
           validate_nonnegative_number(fields[:cover_frame_timestamp], :cover_frame_timestamp),
         :ok <- validate_boolean(fields[:is_animation], :is_animation),
         :ok <-
           validate_cover_not_after_duration(
             fields[:cover_frame_timestamp],
             fields[:duration]
           ) do
      :ok
    end
  end

  defp validate_duration(nil), do: :ok
  defp validate_duration(value) when is_number(value) and value >= 0 and value <= 60, do: :ok
  defp validate_duration(_value), do: {:error, {:number_out_of_range, :duration, 0, 60}}

  defp validate_nonnegative_number(nil, _field), do: :ok

  defp validate_nonnegative_number(value, _field) when is_number(value) and value >= 0,
    do: :ok

  defp validate_nonnegative_number(_value, field),
    do: {:error, {:nonnegative_number_required, field}}

  defp validate_boolean(nil, _field), do: :ok
  defp validate_boolean(value, _field) when is_boolean(value), do: :ok
  defp validate_boolean(_value, field), do: {:error, {:boolean_required, field}}

  defp validate_cover_not_after_duration(nil, _duration), do: :ok
  defp validate_cover_not_after_duration(_cover, nil), do: :ok

  defp validate_cover_not_after_duration(cover, duration) when cover <= duration, do: :ok

  defp validate_cover_not_after_duration(cover, duration),
    do: {:error, {:cover_frame_after_duration, cover, duration}}

  defp required_field(:photo), do: :photo
  defp required_field(:video), do: :video

  defp allowed_optional_fields(:photo), do: []
  defp allowed_optional_fields(:video), do: [:duration, :cover_frame_timestamp, :is_animation]

  defp reject_nil_values(map) do
    for {key, value} <- map, not is_nil(value), into: %{}, do: {key, value}
  end

  defp error_message({:upload_required, field}),
    do:
      "Nadia.InputStoryContent #{field} must be an InputFile path, bytes, or known-size stream upload"

  defp error_message({:number_out_of_range, :duration, 0, 60}),
    do: "Nadia.InputStoryContent duration must be a number from 0 through 60"

  defp error_message({:nonnegative_number_required, field}),
    do: "Nadia.InputStoryContent #{field} must be a nonnegative number"

  defp error_message({:boolean_required, field}),
    do: "Nadia.InputStoryContent #{field} must be a boolean"

  defp error_message({:cover_frame_after_duration, _cover, _duration}),
    do: "Nadia.InputStoryContent cover_frame_timestamp can't be greater than duration"

  defp error_message(reason),
    do: "invalid Nadia.InputStoryContent value: #{inspect(reason)}"
end
