defmodule Nadia.HTTPClient do
  @moduledoc """
  Behaviour for Nadia HTTP adapters.

  Custom adapters receive a `Nadia.HTTPRequest` and return either
  `{:ok, %Nadia.HTTPResponse{}}` or `{:error, reason}`. Applications usually do
  not call this module directly, but tests and custom transports may pass an
  adapter module through `Nadia.Client.new/1`.
  """

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
