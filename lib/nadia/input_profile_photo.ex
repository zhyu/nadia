defmodule Nadia.InputProfilePhoto do
  @moduledoc """
  Typed builders for Telegram `InputProfilePhoto` objects.

  Profile photos can't be reused: `photo` and `animation` accept only new
  multipart uploads created with `Nadia.InputFile.path/2`, `bytes/3`, or a
  known-size `stream/3`. File IDs, URLs, bare binaries, and manual
  `attach://` references are rejected.

  Nadia fixes the Telegram `type` discriminator, omits `nil` options, and
  validates metadata it can inspect. Telegram still enforces the actual file
  format: static profile photos must be JPG images and animated profile photos
  must be MPEG4 videos. Nadia does not decode uploads to inspect their format
  or other media properties.
  """

  alias Nadia.InputFile

  @enforce_keys [:variant, :fields]
  defstruct [:variant, :fields]

  @typedoc "A typed Telegram InputProfilePhoto value. Its representation is opaque."
  @opaque t :: %__MODULE__{variant: :static | :animated, fields: map}

  @type upload :: InputFile.t()
  @type options :: keyword | map

  @doc "Builds a static JPG profile-photo upload."
  @spec static(upload) :: t
  def static(photo), do: build(:static, %{photo: photo}, [])

  @doc """
  Builds an animated MPEG4 profile-photo upload.

  `:main_frame_timestamp` is the nonnegative timestamp, in seconds, of the
  frame Telegram should use as the static profile photo.
  """
  @spec animated(upload, options) :: t
  def animated(animation, options \\ []) do
    build(:animated, %{animation: animation}, options)
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
          raise ArgumentError, "unsupported Nadia.InputProfilePhoto option: #{inspect(key)}"
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
      raise ArgumentError, "Nadia.InputProfilePhoto options must be a keyword list or map"
    end
  end

  defp normalize_options!(_options),
    do: raise(ArgumentError, "Nadia.InputProfilePhoto options must be a keyword list or map")

  defp validate_variant(variant) when variant in [:static, :animated], do: :ok
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

  defp validate_options(:static, _fields), do: :ok

  defp validate_options(:animated, fields) do
    validate_nonnegative_number(fields[:main_frame_timestamp], :main_frame_timestamp)
  end

  defp validate_nonnegative_number(nil, _field), do: :ok

  defp validate_nonnegative_number(value, _field) when is_number(value) and value >= 0,
    do: :ok

  defp validate_nonnegative_number(_value, field),
    do: {:error, {:nonnegative_number_required, field}}

  defp required_field(:static), do: :photo
  defp required_field(:animated), do: :animation

  defp allowed_optional_fields(:static), do: []
  defp allowed_optional_fields(:animated), do: [:main_frame_timestamp]

  defp reject_nil_values(map) do
    for {key, value} <- map, not is_nil(value), into: %{}, do: {key, value}
  end

  defp error_message({:upload_required, field}),
    do:
      "Nadia.InputProfilePhoto #{field} must be an InputFile path, bytes, or known-size stream upload"

  defp error_message({:nonnegative_number_required, field}),
    do: "Nadia.InputProfilePhoto #{field} must be a nonnegative number"

  defp error_message(reason),
    do: "invalid Nadia.InputProfilePhoto value: #{inspect(reason)}"
end
