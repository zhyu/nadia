defmodule Nadia.APITest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  doctest Nadia.API

  setup_all do
    unless Application.get_env(:nadia, :token) do
      Application.put_env(:nadia, :token, "304884665:AAE1ItId1gf9MsM-Smrv9sPc0glmB2HkMAo")
    end

    :ok
  end

  setup do
    ExVCR.Config.filter_sensitive_data("bot[^/]+/", "bot<TOKEN>/")
    :ok
  end

  test "request_with_map" do
    use_cassette "api_request_with_map", match_requests_on: [:request_body] do
      assert [] == Nadia.API.request?("getUpdates", %{"limit" => 4})
    end
  end
end
