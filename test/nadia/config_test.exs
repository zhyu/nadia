defmodule Nadia.ConfigTest do
  use ExUnit.Case
  alias Nadia.Config

  describe "base_url/0" do
    test "returns config value when present" do
      :ok = Application.put_env(:nadia, :base_url, "http://something.com/api")

      assert Config.base_url() == "http://something.com/api"
    end

    test "returns environment variable" do
      :ok = Application.put_env(:nadia, :base_url, {:system, "PHONY_BASE_URL"})
      :ok = System.put_env("PHONY_BASE_URL", "http://somethingelse.com/api")

      assert Config.base_url() == "http://somethingelse.com/api"
    end

    test "returns environment variable default" do
      :ok = Application.put_env(:nadia, :base_url,
        {:system, "PHONY_BASE_URL", "http://somedefault.com/api"})
      :ok = System.delete_env("PHONY_BASE_URL")

      assert Config.base_url() == "http://somedefault.com/api"
    end
    test "returns default when unset" do
      :ok = Application.delete_env(:nadia, :base_url)

      assert Config.base_url() == "https://api.telegram.org/bot"
    end
  end

  describe "graph_base_url/0" do
    test "returns config value when present" do
      :ok = Application.put_env(:nadia, :graph_base_url, "http://something.com/api")

      assert Config.graph_base_url() == "http://something.com/api"
    end

    test "returns environment variable" do
      :ok = Application.put_env(:nadia, :graph_base_url, {:system, "PHONY_BASE_URL"})
      :ok = System.put_env("PHONY_BASE_URL", "http://somethingelse.com/api")

      assert Config.graph_base_url() == "http://somethingelse.com/api"
    end

    test "returns environment variable default" do
      :ok = Application.put_env(:nadia, :graph_base_url,
        {:system, "PHONY_BASE_URL", "http://somedefault.com/api"})
      :ok = System.delete_env("PHONY_BASE_URL")

      assert Config.graph_base_url() == "http://somedefault.com/api"
    end
    test "returns default when unset" do
      :ok = Application.delete_env(:nadia, :graph_base_url)

      assert Config.graph_base_url() == "https://api.telegra.ph"
    end
  end
end
