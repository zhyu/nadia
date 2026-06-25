defmodule Nadia.HTTPClient do
  @moduledoc """
  Behaviour for Nadia HTTP adapters.

  Custom adapters receive a `Nadia.HTTPRequest` and return either
  `{:ok, %Nadia.HTTPResponse{}}` or `{:error, reason}`. Applications usually do
  not call this module directly, but tests and custom transports may pass an
  adapter module through `Nadia.Client.new/1`.

  `download/1` is optional so existing adapters remain compatible. Adapters
  that implement it must stream through `Nadia.HTTPDownloadRequest.sink`,
  disable redirects and retries, avoid whole-response buffering, and never log
  or return the token-bearing request URL.
  """

  alias Nadia.HTTPRequest
  alias Nadia.HTTPResponse
  alias Nadia.HTTPDownloadRequest
  alias Nadia.HTTPDownloadResponse

  @default_adapter Nadia.HTTPClient.Req

  @callback post(HTTPRequest.t()) :: {:ok, HTTPResponse.t()} | {:error, term}
  @callback download(HTTPDownloadRequest.t()) ::
              {:ok, HTTPDownloadResponse.t()} | {:error, term}

  @optional_callbacks download: 1

  @spec post(HTTPRequest.t()) :: {:ok, HTTPResponse.t()} | {:error, term}
  def post(%HTTPRequest{} = request) do
    adapter().post(request)
  end

  @spec post(module, HTTPRequest.t()) :: {:ok, HTTPResponse.t()} | {:error, term}
  def post(adapter, %HTTPRequest{} = request) do
    adapter.post(request)
  end

  @doc """
  Streams a bounded file response through an adapter's optional capability.

  Existing post-only adapters remain valid. They return
  `{:error, :unsupported_http_adapter}` when used for downloads.
  """
  @spec download(module, HTTPDownloadRequest.t()) ::
          {:ok, HTTPDownloadResponse.t()} | {:error, term}
  def download(adapter, %HTTPDownloadRequest{} = request) do
    if function_exported?(adapter, :download, 1) do
      adapter.download(request)
    else
      {:error, :unsupported_http_adapter}
    end
  end

  @spec default_adapter() :: module
  def default_adapter, do: @default_adapter

  def adapter do
    Application.get_env(:nadia, :http_client, @default_adapter)
  end
end
