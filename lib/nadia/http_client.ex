defmodule Nadia.HTTPClient do
  @moduledoc false

  alias Nadia.HTTPRequest
  alias Nadia.HTTPResponse

  @default_adapter Nadia.HTTPClient.Req

  @callback post(HTTPRequest.t()) :: {:ok, HTTPResponse.t()} | {:error, term}

  @spec post(HTTPRequest.t()) :: {:ok, HTTPResponse.t()} | {:error, term}
  def post(%HTTPRequest{} = request) do
    adapter().post(request)
  end

  @spec post(module, HTTPRequest.t()) :: {:ok, HTTPResponse.t()} | {:error, term}
  def post(adapter, %HTTPRequest{} = request) do
    adapter.post(request)
  end

  @spec default_adapter() :: module
  def default_adapter, do: @default_adapter

  def adapter do
    Application.get_env(:nadia, :http_client, @default_adapter)
  end
end
