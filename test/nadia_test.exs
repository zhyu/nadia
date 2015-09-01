defmodule NadiaTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Nadia.Model.User

  setup_all do
    unless Application.get_env(:nadia, :token) do
      Application.put_env(:nadia, :token, "TEST_TOKEN")
    end
    ExVCR.Config.filter_sensitive_data("bot[^/]+/", "bot<TOKEN>/")
    ExVCR.Config.filter_sensitive_data("id\":\\d+", "id\":666")
    ExVCR.Config.filter_sensitive_data("id=\\d+", "id=666")
    :ok
  end

  test "get_me" do
    use_cassette "get_me" do
      {:ok, me} = Nadia.get_me
      assert me == %User{id: 666, first_name: "Nadia", username: "nadia_bot"}
    end
  end

  test "send_message" do
    use_cassette "send_message" do
      {:ok, message} = Nadia.send_message(666, "aloha")
      assert message.text == "aloha"
    end
  end

  test "forward_message" do
    use_cassette "forward_message" do
      {:ok, message} = Nadia.forward_message(666, 666, 666)
      refute is_nil(message.forward_date)
      refute is_nil(message.forward_from)
    end
  end

  test "send_sticker" do
    use_cassette "send_sticker" do
      {:ok, message} = Nadia.send_sticker(666, "BQADBQADBgADmEjsA1aqdSxtzvvVAg")
      refute is_nil(message.sticker)
      assert message.sticker.file_id == "BQADBQADBgADmEjsA1aqdSxtzvvVAg"
    end
  end

  test "send_chat_action" do
    use_cassette "send_chat_action" do
      assert Nadia.send_chat_action(666, "typing") == :ok
    end
  end

  test "get_updates" do
    use_cassette "get_updates" do
      {:ok, updates} = Nadia.get_updates(limit: 1)
      assert length(updates) == 1
    end
  end
end
