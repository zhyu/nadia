defmodule Nadia.HTTPCase do
  use ExUnit.CaseTemplate

  import ExUnit.Assertions

  alias Nadia.HTTPRequest
  alias Nadia.HTTPResponse

  @token "123:test-token"
  @env_keys [
    :http_client,
    :token,
    :base_url,
    :file_base_url,
    :api_environment,
    :recv_timeout,
    :proxy,
    :proxy_auth,
    :socks5_user,
    :socks5_pass,
    :bots
  ]

  defmodule StubHTTPClient do
    @behaviour Nadia.HTTPClient

    @impl Nadia.HTTPClient
    def post(%HTTPRequest{} = request) do
      send(self(), {:nadia_http_request, request})

      case Process.get(:nadia_http_response) do
        nil -> raise "missing stub HTTP response"
        response -> response
      end
    end
  end

  using do
    quote do
      import Nadia.HTTPCase

      alias Nadia.HTTPRequest
      alias Nadia.HTTPResponse
    end
  end

  setup do
    previous_env = for key <- @env_keys, do: {key, Application.get_env(:nadia, key)}

    Application.put_env(:nadia, :http_client, StubHTTPClient)
    Application.put_env(:nadia, :token, @token)
    Application.delete_env(:nadia, :base_url)
    Application.delete_env(:nadia, :file_base_url)
    Application.delete_env(:nadia, :api_environment)
    Application.delete_env(:nadia, :recv_timeout)
    Application.delete_env(:nadia, :proxy)
    Application.delete_env(:nadia, :proxy_auth)
    Application.delete_env(:nadia, :socks5_user)
    Application.delete_env(:nadia, :socks5_pass)
    Application.delete_env(:nadia, :bots)

    on_exit(fn ->
      for {key, value} <- previous_env do
        restore_env(key, value)
      end
    end)

    :ok
  end

  def stub_http_response(response) do
    Process.put(:nadia_http_response, response)
  end

  def stub_telegram_result(result) do
    stub_http_response({:ok, %HTTPResponse{status_code: 200, body: encode_result(result)}})
  end

  def stub_telegram_error(description) do
    stub_http_response({:ok, %HTTPResponse{status_code: 400, body: encode_error(description)}})
  end

  def stub_transport_error(reason) do
    stub_http_response({:error, reason})
  end

  def assert_telegram_request(api_method, expected \\ []) do
    defaults = [
      method: :post,
      url: telegram_url(api_method),
      headers: []
    ]

    assert_http_request(Keyword.merge(defaults, expected))
  end

  def assert_http_request(expected) when is_list(expected) do
    assert_received {:nadia_http_request, %HTTPRequest{} = request}

    for {field, expected_value} <- expected do
      assert Map.fetch!(request, field) == expected_value
    end

    request
  end

  def form_params(%HTTPRequest{body: {:form, params}}), do: Map.new(params)

  def telegram_url(api_method) do
    "https://api.telegram.org/bot#{@token}/#{api_method}"
  end

  defp encode_result(result), do: Jason.encode!(%{ok: true, result: result})
  defp encode_error(description), do: Jason.encode!(%{ok: false, description: description})

  defp restore_env(key, nil), do: Application.delete_env(:nadia, key)
  defp restore_env(key, value), do: Application.put_env(:nadia, key, value)
end
