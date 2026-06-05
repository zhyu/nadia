defmodule Nadia.APITest do
  use Nadia.HTTPCase

  doctest Nadia.API

  alias Nadia.API
  alias Nadia.Client
  alias Nadia.HTTPResponse
  alias Nadia.Model.Error
  alias Nadia.Model.{ReplyKeyboardRemove, User}

  defmodule BotAHTTPClient do
    @behaviour Nadia.HTTPClient

    @impl Nadia.HTTPClient
    def post(request) do
      send(self(), {:bot_a_request, request})
      {:ok, %Nadia.HTTPResponse{status_code: 200, body: Jason.encode!(%{ok: true, result: true})}}
    end
  end

  defmodule BotBHTTPClient do
    @behaviour Nadia.HTTPClient

    @impl Nadia.HTTPClient
    def post(request) do
      send(self(), {:bot_b_request, request})
      {:ok, %Nadia.HTTPResponse{status_code: 200, body: Jason.encode!(%{ok: true, result: true})}}
    end
  end

  test "request_with_map" do
    stub_telegram_result([])

    assert [] == API.request?("getUpdates", %{"limit" => 4})

    assert_telegram_request("getUpdates",
      body: {:form, [{"limit", "4"}]},
      options: [recv_timeout: 5000]
    )
  end

  test "public method uses the HTTP boundary and parses successful responses" do
    stub_telegram_result(%{id: 123, first_name: "Nadia"})

    assert {:ok, %User{id: 123, first_name: "Nadia"}} = Nadia.get_me()

    assert_telegram_request("getMe",
      body: {:form, []},
      options: [recv_timeout: 5000]
    )
  end

  test "request ignores unknown Telegram response fields without creating atoms" do
    unknown_key = "telegram_unknown_#{System.unique_integer([:positive])}"
    refute existing_atom?(unknown_key)

    stub_http_response(
      {:ok,
       %HTTPResponse{
         status_code: 200,
         body:
           Jason.encode!(%{
             "ok" => true,
             "result" => %{
               "id" => 123,
               "first_name" => "Nadia",
               unknown_key => "ignored"
             }
           })
       }}
    )

    assert {:ok, %User{id: 123, first_name: "Nadia"}} = Nadia.get_me()
    refute existing_atom?(unknown_key)
  end

  test "request builds form body from keyword list params" do
    stub_telegram_result(true)

    assert :ok == API.request("sendMessage", chat_id: 123, text: "hello")

    assert_telegram_request("sendMessage",
      body: {:form, [{"chat_id", "123"}, {"text", "hello"}]},
      options: [recv_timeout: 5000]
    )
  end

  test "request JSON-encodes reply markup" do
    stub_telegram_result(true)

    assert :ok ==
             API.request("sendMessage",
               chat_id: 123,
               text: "hello",
               reply_markup: %ReplyKeyboardRemove{selective: true}
             )

    request =
      assert_telegram_request("sendMessage",
        options: [recv_timeout: 5000]
      )

    params = form_params(request)

    assert params["chat_id"] == "123"
    assert params["text"] == "hello"

    assert Jason.decode!(params["reply_markup"]) == %{
             "remove_keyboard" => true,
             "selective" => true
           }
  end

  test "request filters nil params" do
    stub_telegram_result(true)

    assert :ok ==
             API.request("sendMessage",
               chat_id: 123,
               text: "hello",
               parse_mode: nil,
               disable_notification: true
             )

    request = assert_telegram_request("sendMessage", options: [recv_timeout: 5000])
    params = form_params(request)

    assert params["chat_id"] == "123"
    assert params["text"] == "hello"
    assert params["disable_notification"] == "true"
    refute Map.has_key?(params, "parse_mode")
  end

  test "request builds multipart body when file field points to a local file" do
    file_path =
      Path.join(System.tmp_dir!(), "nadia-api-test-#{System.unique_integer([:positive])}.txt")

    File.write!(file_path, "photo")
    on_exit(fn -> File.rm(file_path) end)

    stub_telegram_result(true)

    assert :ok ==
             API.request(
               "sendPhoto",
               [chat_id: 123, photo: file_path, caption: "hello"],
               :photo
             )

    request = assert_telegram_request("sendPhoto", options: [recv_timeout: 5000])

    assert {:multipart, parts} = request.body
    assert {"chat_id", "123"} in parts
    assert {"caption", "hello"} in parts

    assert {:file, file_path, {"form-data", [{"name", "photo"}, {"filename", file_path}]}, []} in parts
  end

  test "request includes per-request timeout in HTTP options" do
    stub_telegram_result([])

    assert [] == API.request?("getUpdates", timeout: 2)

    assert_telegram_request("getUpdates",
      body: {:form, [{"timeout", "2"}]},
      options: [recv_timeout: 7000]
    )
  end

  test "request propagates proxy options" do
    proxy = {:http, "localhost", 8080}
    proxy_auth = {"proxy-user", "proxy-password"}

    Application.put_env(:nadia, :proxy, proxy)
    Application.put_env(:nadia, :proxy_auth, proxy_auth)

    stub_telegram_result(true)

    assert :ok == API.request("sendChatAction", chat_id: 123, action: "typing")

    request = assert_telegram_request("sendChatAction")

    assert Keyword.get(request.options, :recv_timeout) == 5000
    assert Keyword.get(request.options, :proxy) == proxy
    assert Keyword.get(request.options, :proxy_auth) == proxy_auth
  end

  test "request/4 uses explicit clients independently of application config" do
    Application.put_env(:nadia, :token, "global-token")
    Application.put_env(:nadia, :recv_timeout, 30)

    bot_a =
      Client.new(
        token: "111:bot-a",
        recv_timeout: 1,
        proxy: "http://bot-a-proxy.test",
        http_client: BotAHTTPClient
      )

    bot_b =
      Client.new(
        token: "222:bot-b",
        recv_timeout: 3,
        proxy_auth: {"bot-b-user", "bot-b-pass"},
        http_client: BotBHTTPClient
      )

    assert :ok ==
             API.request(
               bot_a,
               "sendChatAction",
               [chat_id: 123, action: "typing", timeout: 2],
               nil
             )

    assert :ok == API.request(bot_b, "setWebhook", [url: "https://example.test/webhook"], nil)

    assert_received {:bot_a_request, bot_a_request}
    assert_received {:bot_b_request, bot_b_request}

    assert bot_a_request.url == "https://api.telegram.org/bot111:bot-a/sendChatAction"

    assert bot_a_request.body ==
             {:form, [{"chat_id", "123"}, {"action", "typing"}, {"timeout", "2"}]}

    assert Keyword.get(bot_a_request.options, :recv_timeout) == 3000
    assert Keyword.get(bot_a_request.options, :proxy) == "http://bot-a-proxy.test"
    refute Keyword.has_key?(bot_a_request.options, :proxy_auth)

    assert bot_b_request.url == "https://api.telegram.org/bot222:bot-b/setWebhook"
    assert bot_b_request.body == {:form, [{"url", "https://example.test/webhook"}]}
    assert Keyword.get(bot_b_request.options, :recv_timeout) == 3000
    assert Keyword.get(bot_b_request.options, :proxy_auth) == {"bot-b-user", "bot-b-pass"}
    refute Keyword.has_key?(bot_b_request.options, :proxy)
  end

  test "request/4 builds test environment API URLs" do
    client =
      Client.new(
        token: "123:test-token",
        api_environment: :test,
        http_client: Nadia.HTTPCase.StubHTTPClient
      )

    stub_telegram_result(true)

    assert :ok == API.request(client, "setWebhook", [], nil)

    assert_http_request(
      method: :post,
      url: "https://api.telegram.org/bot123:test-token/test/setWebhook",
      body: {:form, []},
      headers: [],
      options: [recv_timeout: 5000]
    )
  end

  test "request returns :ok for true responses" do
    stub_telegram_result(true)

    assert :ok == API.request("setWebhook")
  end

  test "request normalizes Telegram error responses" do
    stub_telegram_error("Bad Request: chat not found")

    assert {:error, %Error{reason: "Bad Request: chat not found"}} =
             API.request("sendMessage", chat_id: 1, text: "hello")
  end

  test "request normalizes transport errors" do
    stub_transport_error(:timeout)

    assert {:error, %Error{reason: :timeout}} = API.request("getMe")
  end

  test "request normalizes malformed JSON responses" do
    stub_http_response({:ok, %HTTPResponse{status_code: 200, body: "not json"}})

    assert {:error, %Error{reason: %Jason.DecodeError{}}} = API.request("getMe")
  end

  test "build_file_url uses the configured token and default file base URL" do
    assert API.build_file_url("document/file_10") ==
             "https://api.telegram.org/file/bot#{Nadia.Config.token()}/document/file_10"
  end

  test "build_file_url uses custom file base URL" do
    Application.put_env(:nadia, :file_base_url, "https://files.example/bot")

    assert API.build_file_url("document/file_10") ==
             "https://files.example/bot123:test-token/document/file_10"
  end

  test "build_file_url/2 uses explicit client file settings" do
    client =
      Client.new(
        token: "999:file-token",
        file_base_url: "https://files.example/bot"
      )

    assert API.build_file_url(client, "document/file_10") ==
             "https://files.example/bot999:file-token/document/file_10"
  end

  defp existing_atom?(name) do
    _ = String.to_existing_atom(name)
    true
  rescue
    ArgumentError -> false
  end
end
