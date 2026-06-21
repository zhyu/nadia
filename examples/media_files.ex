defmodule Nadia.Examples.MediaFiles do
  @moduledoc """
  Explicit helpers for choosing between Telegram file IDs, URLs, and local
  uploads.

  Nadia accepts a binary for all three cases. Tagging the source at the
  application boundary lets local path errors be reported before a request is
  sent.
  """

  alias Nadia.Client

  @type source :: {:file_id, binary} | {:url, binary} | {:path, Path.t()}

  @spec send_document(Client.t(), integer | binary, source, keyword) :: term
  def send_document(client, chat_id, source, options \\ [])

  def send_document(%Client{} = client, chat_id, {:file_id, file_id}, options)
      when is_binary(file_id) do
    Nadia.send_document(client, chat_id, file_id, options)
  end

  def send_document(%Client{} = client, chat_id, {:url, url}, options) when is_binary(url) do
    case URI.parse(url) do
      %URI{scheme: scheme, host: host} when scheme in ["http", "https"] and is_binary(host) ->
        Nadia.send_document(client, chat_id, url, options)

      _ ->
        {:error, {:invalid_file_url, url}}
    end
  end

  def send_document(%Client{} = client, chat_id, {:path, path}, options)
      when is_binary(path) do
    case File.stat(path) do
      {:ok, %File.Stat{type: :regular}} ->
        Nadia.send_document(client, chat_id, path, options)

      {:ok, %File.Stat{}} ->
        {:error, {:file_error, :not_regular}}

      {:error, reason} ->
        {:error, {:file_error, reason}}
    end
  end

  def send_document(%Client{}, _chat_id, source, _options),
    do: {:error, {:invalid_file_source, source}}

  @doc """
  Uploads bytes through a temporary file and removes it after the request.

  Nadia has no in-memory `InputFile` abstraction. This helper intentionally
  makes the extra disk copy visible and is suitable only after the application
  has imposed its own input and storage limits.
  """
  @spec upload_bytes(Client.t(), integer | binary, iodata, binary, keyword) :: term
  def upload_bytes(%Client{} = client, chat_id, bytes, filename, options \\ [])
      when is_binary(filename) do
    path = temporary_path(filename)

    case File.write(path, bytes, [:exclusive]) do
      :ok ->
        try do
          send_document(client, chat_id, {:path, path}, options)
        after
          File.rm(path)
        end

      {:error, reason} ->
        {:error, {:file_error, reason}}
    end
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

  defp temporary_path(filename) do
    basename = Path.basename(filename)
    unique = System.unique_integer([:positive, :monotonic])
    Path.join(System.tmp_dir!(), "nadia-upload-#{unique}-#{basename}")
  end
end
