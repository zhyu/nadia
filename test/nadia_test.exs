defmodule NadiaTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Nadia.User
  alias Nadia.Message
  alias Nadia.Update

  setup_all do
    Application.put_env(:nadia, :token, "TEST_TOKEN")
  end

  test "get_me" do
    use_cassette "get_me" do
      {:ok, me} = Nadia.get_me
      assert me == %User{id: 666, first_name: "Nadia", username: "nadia_bot"}
    end
  end

  test "get_updates" do
    use_cassette "get_updates" do
      {:ok, updates} = Nadia.get_updates
      assert length(updates) == 1

      user = %User{id: 777, first_name: "Tester", username: "tester"}
      assert hd(updates) == %Update{
        update_id: 1,
        message: %Message{
          chat: user, from: user, date: 1440926322, message_id: 1, text: "test"}}
    end
  end
end
