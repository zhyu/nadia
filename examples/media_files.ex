defmodule Nadia.Examples.MediaFiles do
  @moduledoc """
  Explicit helpers for choosing between Telegram file IDs, URLs, and local
  uploads.

  `Nadia.InputFile` makes source intent explicit and reports malformed URLs or
  local path errors before a request is sent.
  """

  alias Nadia.Client
  alias Nadia.InputFile
  alias Nadia.InputMedia
  alias Nadia.InputSticker

  @type source :: {:file_id, binary} | {:url, binary} | {:path, Path.t()}

  @spec send_document(Client.t(), integer | binary, source, keyword) :: term
  def send_document(client, chat_id, source, options \\ [])

  def send_document(%Client{} = client, chat_id, {:file_id, file_id}, options)
      when is_binary(file_id) do
    Nadia.send_document(client, chat_id, InputFile.file_id(file_id), options)
  end

  def send_document(%Client{} = client, chat_id, {:url, url}, options) when is_binary(url) do
    case URI.parse(url) do
      %URI{scheme: scheme, host: host} when scheme in ["http", "https"] and is_binary(host) ->
        Nadia.send_document(client, chat_id, InputFile.url(url), options)

      _ ->
        {:error, {:invalid_file_url, url}}
    end
  end

  def send_document(%Client{} = client, chat_id, {:path, path}, options)
      when is_binary(path) do
    Nadia.send_document(client, chat_id, InputFile.path(path), options)
  end

  def send_document(%Client{}, _chat_id, source, _options),
    do: {:error, {:invalid_file_source, source}}

  @doc """
  Uploads bounded iodata directly without flattening it or copying it to disk.

  `:max_bytes` defaults to 10 MB and is consumed by this helper rather than
  sent to Telegram. The application still owns the original in-memory data.
  """
  @spec upload_bytes(Client.t(), integer | binary, iodata, binary, keyword) :: term
  def upload_bytes(%Client{} = client, chat_id, bytes, filename, options \\ [])
      when is_binary(filename) do
    {max_bytes, options} = Keyword.pop(options, :max_bytes, 10_000_000)
    {content_type, options} = Keyword.pop(options, :content_type)

    input_file =
      InputFile.bytes(bytes, filename,
        max_bytes: max_bytes,
        content_type: content_type
      )

    Nadia.send_document(client, chat_id, input_file, options)
  end

  @doc """
  Sends a typed two-item album with a reusable photo and a bounded path upload.
  """
  @spec send_album(Client.t(), integer | binary, binary, Path.t()) :: term
  def send_album(%Client{} = client, chat_id, photo_file_id, video_path) do
    media = [
      InputMedia.photo(InputFile.file_id(photo_file_id)),
      InputMedia.video(InputFile.path(video_path, max_bytes: 50_000_000),
        supports_streaming: true
      )
    ]

    Nadia.send_media_group(client, chat_id, media)
  end

  @doc """
  Adds a typed static sticker from a bounded local upload.
  """
  @spec add_static_sticker(Client.t(), integer, binary, Path.t(), binary) :: term
  def add_static_sticker(%Client{} = client, user_id, set_name, path, emoji) do
    sticker =
      InputSticker.static(
        InputFile.path(path, max_bytes: 512_000),
        [emoji]
      )

    Nadia.add_sticker_to_set(client, user_id, set_name, sticker)
  end

  @doc """
  Downloads a Telegram file to a destination under a mandatory byte limit.

  Nadia streams to a same-directory temporary file, refuses an existing
  destination, and publishes the completed file atomically where supported.
  """
  @spec download_file(Client.t(), binary, Path.t(), non_neg_integer) ::
          {:ok, Path.t()} | {:error, term}
  def download_file(%Client{} = client, file_id, destination, max_bytes)
      when is_binary(file_id) do
    Nadia.download_file(client, file_id, destination, max_bytes)
  end
end
