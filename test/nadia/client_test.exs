defmodule Nadia.ClientTest do
  use ExUnit.Case

  alias Nadia.Client
  alias Nadia.HTTPClient.Req

  defp restore_env!(key, value) do
    if value do
      :ok = Application.put_env(:nadia, key, value)
    else
      :ok = Application.delete_env(:nadia, key)
    end
  end

  setup do
    keys = [
      :token,
      :base_url,
      :file_base_url,
      :api_environment,
      :recv_timeout,
      :proxy,
      :proxy_auth,
      :http_client,
      :bots
    ]

    previous_env = for key <- keys, do: {key, Application.get_env(:nadia, key)}

    on_exit(fn ->
      for {key, value} <- previous_env do
        restore_env!(key, value)
      end
    end)

    :ok
  end

  test "new/1 builds a client with legacy-compatible defaults" do
    client = Client.new(token: "123:test-token")

    assert client.token == "123:test-token"
    assert client.base_url == "https://api.telegram.org/bot"
    assert client.file_base_url == "https://api.telegram.org/file/bot"
    assert client.api_environment == :production
    assert client.recv_timeout == 5
    assert client.proxy == nil
    assert client.proxy_auth == nil
    assert client.http_client == Req
  end

  test "new/1 resolves system environment tuples" do
    System.put_env("NADIA_CLIENT_TOKEN", "env-token")
    System.put_env("NADIA_CLIENT_BASE_URL", "https://example.test/bot")

    on_exit(fn ->
      System.delete_env("NADIA_CLIENT_TOKEN")
      System.delete_env("NADIA_CLIENT_BASE_URL")
    end)

    client =
      Client.new(
        token: {:system, "NADIA_CLIENT_TOKEN"},
        base_url: {:system, "NADIA_CLIENT_BASE_URL"},
        file_base_url: {:system, "NADIA_CLIENT_FILE_BASE_URL", "https://files.test/bot"},
        api_environment: "test",
        recv_timeout: 10
      )

    assert client.token == "env-token"
    assert client.base_url == "https://example.test/bot"
    assert client.file_base_url == "https://files.test/bot"
    assert client.api_environment == :test
    assert client.recv_timeout == 10
  end

  test "default/0 builds a client from top-level config" do
    Application.put_env(:nadia, :token, "global-token")
    Application.put_env(:nadia, :base_url, "https://global.test/bot")
    Application.put_env(:nadia, :file_base_url, "https://global-files.test/bot")
    Application.put_env(:nadia, :api_environment, :test)
    Application.put_env(:nadia, :recv_timeout, 12)
    Application.put_env(:nadia, :proxy, "http://proxy.test")
    Application.put_env(:nadia, :proxy_auth, {"user", "pass"})
    Application.put_env(:nadia, :http_client, __MODULE__.TopLevelHTTPClient)

    client = Client.default()

    assert client.token == "global-token"
    assert client.base_url == "https://global.test/bot"
    assert client.file_base_url == "https://global-files.test/bot"
    assert client.api_environment == :test
    assert client.recv_timeout == 12
    assert client.proxy == "http://proxy.test"
    assert client.proxy_auth == {"user", "pass"}
    assert client.http_client == __MODULE__.TopLevelHTTPClient
  end

  test "from_config/1 builds a named client from bot config" do
    System.put_env("SUPPORT_BOT_TOKEN", "support-token")
    on_exit(fn -> System.delete_env("SUPPORT_BOT_TOKEN") end)

    Application.put_env(:nadia, :bots,
      support: [
        token: {:system, "SUPPORT_BOT_TOKEN"},
        recv_timeout: 9,
        proxy: {:http, "proxy.test", 8080},
        http_client: __MODULE__.NamedHTTPClient
      ]
    )

    client = Client.from_config(:support)

    assert client.token == "support-token"
    assert client.recv_timeout == 9
    assert client.proxy == {:http, "proxy.test", 8080}
    assert client.http_client == __MODULE__.NamedHTTPClient
  end

  test "inspect output redacts token" do
    inspected = inspect(Client.new(token: "secret-token"))

    assert inspected =~ "[REDACTED]"
    refute inspected =~ "secret-token"
  end
end
