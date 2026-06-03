defmodule Nadia.APITest do
  use ExUnit.Case

  doctest Nadia.API

  alias Nadia.API
  alias Nadia.HTTPRequest
  alias Nadia.HTTPResponse
  alias Nadia.Model.Error
  alias Nadia.Model.User

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

  setup do
    env_keys = [
      :http_client,
      :token,
      :base_url,
      :file_base_url,
      :recv_timeout,
      :proxy,
      :proxy_auth,
      :socks5_user,
      :socks5_pass
    ]

    previous_env = for key <- env_keys, do: {key, Application.get_env(:nadia, key)}

    Application.put_env(:nadia, :http_client, StubHTTPClient)
    Application.put_env(:nadia, :token, "123:test-token")
    Application.delete_env(:nadia, :base_url)
    Application.delete_env(:nadia, :file_base_url)
    Application.delete_env(:nadia, :recv_timeout)
    Application.delete_env(:nadia, :proxy)
    Application.delete_env(:nadia, :proxy_auth)
    Application.delete_env(:nadia, :socks5_user)
    Application.delete_env(:nadia, :socks5_pass)

    on_exit(fn ->
      for {key, value} <- previous_env do
        restore_env(key, value)
      end
    end)

    :ok
  end

  defp restore_env(key, nil), do: Application.delete_env(:nadia, key)
  defp restore_env(key, value), do: Application.put_env(:nadia, key, value)

  defp stub_response(response) do
    Process.put(:nadia_http_response, response)
  end

  defp telegram_response(result) do
    {:ok, %HTTPResponse{status_code: 200, body: Jason.encode!(%{ok: true, result: result})}}
  end

  defp telegram_error(description) do
    {:ok,
     %HTTPResponse{status_code: 400, body: Jason.encode!(%{ok: false, description: description})}}
  end

  test "request_with_map" do
    stub_response(telegram_response([]))

    assert [] == API.request?("getUpdates", %{"limit" => 4})

    assert_received {:nadia_http_request,
                     %HTTPRequest{
                       method: :post,
                       url: "https://api.telegram.org/bot123:test-token/getUpdates",
                       body: {:form, [{"limit", "4"}]},
                       headers: [],
                       options: [recv_timeout: 5000]
                     }}
  end

  test "public method uses the HTTP boundary and parses successful responses" do
    stub_response(telegram_response(%{id: 123, first_name: "Nadia"}))

    assert {:ok, %User{id: 123, first_name: "Nadia"}} = Nadia.get_me()

    assert_received {:nadia_http_request,
                     %HTTPRequest{
                       method: :post,
                       url: "https://api.telegram.org/bot123:test-token/getMe",
                       body: {:form, []},
                       headers: [],
                       options: [recv_timeout: 5000]
                     }}
  end

  test "request returns :ok for true responses" do
    stub_response(telegram_response(true))

    assert :ok == API.request("setWebhook")
  end

  test "request normalizes Telegram error responses" do
    stub_response(telegram_error("Bad Request: chat not found"))

    assert {:error, %Error{reason: "Bad Request: chat not found"}} =
             API.request("sendMessage", chat_id: 1, text: "hello")
  end

  test "request normalizes transport errors" do
    stub_response({:error, :timeout})

    assert {:error, %Error{reason: :timeout}} = API.request("getMe")
  end

  test "request normalizes malformed JSON responses" do
    stub_response({:ok, %HTTPResponse{status_code: 200, body: "not json"}})

    assert {:error, %Error{reason: %Jason.DecodeError{}}} = API.request("getMe")
  end

  test "build_file_url" do
    assert API.build_file_url("document/file_10") ==
             "https://api.telegram.org/file/bot#{Nadia.Config.token()}/document/file_10"
  end
end
