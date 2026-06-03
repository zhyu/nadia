defmodule Nadia.HTTPClient.HTTPoison do
  @moduledoc false

  @behaviour Nadia.HTTPClient

  alias Nadia.HTTPRequest
  alias Nadia.HTTPResponse

  @impl Nadia.HTTPClient
  def post(%HTTPRequest{method: :post, url: url, body: body, headers: headers, options: options}) do
    case HTTPoison.post(url, body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: status_code, body: body, headers: headers}} ->
        {:ok, %HTTPResponse{status_code: status_code, body: body, headers: headers}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
