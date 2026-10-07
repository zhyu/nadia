defmodule Nadia.InputRichMessageMedia do
  @moduledoc """
  Typed builder for Telegram `InputRichMessageMedia` objects.

  Each media entry binds the `id` used by `tg://photo?id=`, `tg://video?id=`,
  `tg://document?id=`, or `tg://audio?id=` links to an `Nadia.InputMedia`
  value. When no id is given, one is derived from the media file name or
  string source. Nadia validates id shape (1-64 ASCII letters, digits,
  underscore, or hyphen) and the media value; Telegram validates the
  referenced media types.
  """

  alias Nadia.InputMedia

  @enforce_keys [:fields]
  defstruct [:fields]

  @typedoc "A typed Telegram InputRichMessageMedia value. Its representation is opaque."
  @opaque t :: %__MODULE__{fields: map}

  @id_pattern ~r/^[A-Za-z0-9_-]+$/

  @doc """
  Builds an embedded rich-message media entry.

  `id` may be omitted; it is then derived from the media source. `media` is an
  `Nadia.InputMedia` value, a map, or a pre-encoded JSON binary.
  """
  @spec new(binary | nil, InputMedia.t() | map | binary) :: t
  def new(id \\ nil, media)

  def new(id, %InputMedia{} = media) when is_binary(id) do
    validate_id!(id)

    case InputMedia.to_map(media) do
      {:ok, map} -> %__MODULE__{fields: %{id: id, media: map}}
      {:error, reason} -> raise ArgumentError, error_message({:input_media, reason})
    end
  end

  def new(nil, %InputMedia{} = media) do
    case InputMedia.to_map(media) do
      {:ok, map} ->
        %__MODULE__{fields: %{id: media_id_from(map[:media]), media: map}}

      {:error, reason} ->
        raise ArgumentError, error_message({:input_media, reason})
    end
  end

  def new(id, %{} = media) when is_binary(id) or is_nil(id) do
    if is_binary(id), do: validate_id!(id)

    if is_map_key(media, :media) or is_map_key(media, "media") do
      %__MODULE__{fields: reject_nil_values(%{id: id, media: media})}
    else
      raise ArgumentError, "Nadia.InputRichMessageMedia media entry must have a media key"
    end
  end

  def new(id, media) when is_binary(media) and (is_binary(id) or is_nil(id)) do
    %__MODULE__{fields: reject_nil_values(%{id: id, media: media})}
  end

  @doc false
  @spec to_map(t) :: {:ok, map} | {:error, term}
  def to_map(%__MODULE__{fields: %{} = fields}) do
    if is_map_key(fields, :media) do
      {:ok, reject_nil_values(fields)}
    else
      {:error, :media_entry_requires_map}
    end
  end

  defp validate_id!(id) do
    unless is_binary(id) and byte_size(id) in 1..64 and id =~ @id_pattern do
      raise ArgumentError,
            "Nadia.InputRichMessageMedia id must be 1-64 characters of A-Z, a-z, 0-9, _ or -"
    end
  end

  defp media_id_from(%Nadia.InputFile{source: {kind, value}}),
    do: media_id_from_source(kind, value)

  defp media_id_from(source) when is_binary(source), do: media_id_from_source(:binary, source)
  defp media_id_from(_source), do: nil

  defp media_id_from_source(_kind, value) when is_binary(value) do
    base = value |> String.split("/") |> List.last()
    base = if base == "", do: value, else: base
    id = base |> String.replace(~r/[^A-Za-z0-9_-]+/, "_") |> String.slice(0, 64)

    if id == "", do: nil, else: id
  end

  defp media_id_from_source(_kind, _value), do: nil

  defp reject_nil_values(map) do
    for {key, value} <- map, not is_nil(value), into: %{}, do: {key, value}
  end

  defp error_message({:input_media, reason}),
    do: "invalid Nadia.InputMedia media: #{inspect(reason)}"
end
