defmodule Nadia.ConfigTest do
  use ExUnit.Case
  alias Nadia.Config

  defp restore_env!(key, value) do
    if value do
      :ok = Application.put_env(:nadia, key, value)
    else
      :ok = Application.delete_env(:nadia, key)
    end
  end

  setup do
    base_url = Application.get_env(:nadia, :base_url)
    graph_base_url = Application.get_env(:nadia, :graph_base_url)
    file_base_url = Application.get_env(:nadia, :file_base_url)

    on_exit(fn ->
      restore_env!(:base_url, base_url)
      restore_env!(:graph_base_url, graph_base_url)
      restore_env!(:file_base_url, file_base_url)
    end)
  end

  test "Config.base_url/0 returns config value when present" do
    :ok = Application.put_env(:nadia, :base_url, "http://something.com/api")

    assert Config.base_url() == "http://something.com/api"
  end

  test "Config.proxy/0 returns config value when present" do
    :ok = Application.put_env(:nadia, :proxy, {:socks5, ~c"localhost", 1080})

    assert Config.proxy() == {:socks5, ~c"localhost", 1080}
  end

  test "Config.socks5_user/0 returns config value when present" do
    :ok = Application.put_env(:nadia, :socks5_user, "user")

    assert Config.socks5_user() == "user"
  end

  test "Config.socks5_pass/0 returns config value when present" do
    :ok = Application.put_env(:nadia, :socks5_pass, "password")

    assert Config.socks5_pass() == "password"
  end

  test "Config.base_url/0 returns environment variable" do
    :ok = Application.put_env(:nadia, :base_url, {:system, "PHONY_BASE_URL"})
    :ok = System.put_env("PHONY_BASE_URL", "http://somethingelse.com/api")

    assert Config.base_url() == "http://somethingelse.com/api"
  end

  test "Config.base_url/0 returns environment variable default" do
    :ok =
      Application.put_env(
        :nadia,
        :base_url,
        {:system, "PHONY_BASE_URL", "http://somedefault.com/api"}
      )

    :ok = System.delete_env("PHONY_BASE_URL")

    assert Config.base_url() == "http://somedefault.com/api"
  end

  test "Config.base_url/0 returns default when unset" do
    :ok = Application.delete_env(:nadia, :base_url)

    assert Config.base_url() == "https://api.telegram.org/bot"
  end

  test "Config.graph_base_url/0 returns config value when present" do
    :ok = Application.put_env(:nadia, :graph_base_url, "http://something.com/api")

    assert Config.graph_base_url() == "http://something.com/api"
  end

  test "Config.graph_base_url/0 returns environment variable" do
    :ok = Application.put_env(:nadia, :graph_base_url, {:system, "PHONY_BASE_URL"})
    :ok = System.put_env("PHONY_BASE_URL", "http://somethingelse.com/api")

    assert Config.graph_base_url() == "http://somethingelse.com/api"
  end

  test "Config.graph_base_url/0 returns environment variable default" do
    :ok =
      Application.put_env(
        :nadia,
        :graph_base_url,
        {:system, "PHONY_BASE_URL", "http://somedefault.com/api"}
      )

    :ok = System.delete_env("PHONY_BASE_URL")

    assert Config.graph_base_url() == "http://somedefault.com/api"
  end

  test "Config.graph_base_url/0 returns default when unset" do
    :ok = Application.delete_env(:nadia, :graph_base_url)

    assert Config.graph_base_url() == "https://api.telegra.ph"
  end

  test "Config.file_base_url/0 returns config value when present" do
    :ok = Application.put_env(:nadia, :file_base_url, "http://foobar.com/api")

    assert Config.file_base_url() == "http://foobar.com/api"
  end

  test "Config.file_base_url/0 returns environment variable" do
    :ok = Application.put_env(:nadia, :file_base_url, {:system, "FILE_BASE_URL"})
    :ok = System.put_env("FILE_BASE_URL", "http://somethingelse.com/api")

    assert Config.file_base_url() == "http://somethingelse.com/api"
  end

  test "Config.file_base_url/0 returns environment variable default" do
    :ok =
      Application.put_env(
        :nadia,
        :file_base_url,
        {:system, "FILE_BASE_URL", "http://somedefault.com/api"}
      )

    :ok = System.delete_env("FILE_BASE_URL")

    assert Config.file_base_url() == "http://somedefault.com/api"
  end

  test "Config.file_base_url/0 returns default when unset" do
    :ok = Application.delete_env(:nadia, :file_base_url)

    assert Config.file_base_url() == "https://api.telegram.org/file/bot"
  end
end
