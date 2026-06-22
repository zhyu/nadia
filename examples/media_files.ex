defmodule Nadia.Examples.MediaFiles do
  @moduledoc """
  Explicit helpers for choosing between Telegram file IDs, URLs, and local
  uploads.

  `Nadia.InputFile` makes source intent explicit and reports malformed URLs or
  local path errors before a request is sent.
  """

  alias Nadia.Client
  alias Nadia.InputFile

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
  Resolves a Telegram file ID to a credential-bearing download URL.

  This does not download the file. The caller owns the HTTP GET, destination
  streaming, size limits, and URL secrecy.
  """
  @spec download_url(Client.t(), binary) :: {:ok, binary} | {:error, term}
  def download_url(%Client{} = client, file_id) when is_binary(file_id) do
    with {:ok, file} <- Nadia.get_file(client, file_id),
         {:ok, url} <- Nadia.get_file_link(client, file) do
      {:ok, url}
    end
  end
end
