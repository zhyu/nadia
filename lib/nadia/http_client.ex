defmodule Nadia.HTTPClient do
  @moduledoc false

  alias Nadia.HTTPRequest
  alias Nadia.HTTPResponse

  @default_adapter Nadia.HTTPClient.HTTPoison

  @callback post(HTTPRequest.t()) :: {:ok, HTTPResponse.t()} | {:error, term}

  @spec post(HTTPRequest.t()) :: {:ok, HTTPResponse.t()} | {:error, term}
  def post(%HTTPRequest{} = request) do
    adapter().post(request)
  end

  defp adapter do
    Application.get_env(:nadia, :http_client, @default_adapter)
  end
end
