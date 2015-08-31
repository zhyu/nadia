defmodule NadiaTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Nadia.User

  setup_all do
    ExVCR.Config.filter_sensitive_data("bot[^/]+/", "bot<TOKEN>/")
    :ok
  end

  test "get_me" do
    use_cassette "get_me" do
      {:ok, me} = Nadia.get_me
      assert me == %User{id: 81420469, first_name: "Nadia", username: "nadia_bot"}
    end
  end

  test "get_updates" do
    use_cassette "get_updates" do
      {:ok, updates} = Nadia.get_updates(limit: 1)
      assert length(updates) == 1
    end
  end
end
