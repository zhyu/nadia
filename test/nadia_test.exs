defmodule NadiaTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  doctest Nadia, only: [get_file_link: 1]
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

  test "send_photo" do
    use_cassette "send_photo" do
      file_id = "AgADBQADq6cxG7Vg2gSIF48DtOpj4-edszIABGGN5AM6XKzcLjwAAgI"
      {:ok, message} = Nadia.send_photo(666, file_id)
      assert is_list(message.photo)
      assert Enum.any?(message.photo, &(&1.file_id == file_id))
    end
  end

  test "send_sticker" do
    use_cassette "send_sticker" do
      {:ok, message} = Nadia.send_sticker(666, "BQADBQADBgADmEjsA1aqdSxtzvvVAg")
      refute is_nil(message.sticker)
      assert message.sticker.file_id == "BQADBQADBgADmEjsA1aqdSxtzvvVAg"
    end
  end

  test "send_location" do
    use_cassette "send_location" do
      {:ok, message} = Nadia.send_location(666, 1, 2)
      refute is_nil(message.location)
      assert_in_delta message.location.latitude, 1, 1.0e-3
      assert_in_delta message.location.longitude, 2, 1.0e-3
    end
  end

  test "send_chat_action" do
    use_cassette "send_chat_action" do
      assert Nadia.send_chat_action(666, "typing") == :ok
    end
  end

  test "get_user_profile_photos" do
    use_cassette "get_user_profile_photos" do
      {:ok, user_profile_photos} = Nadia.get_user_profile_photos(666)
      assert user_profile_photos.total_count == 1
      refute is_nil(user_profile_photos.photos)
    end
  end

  test "get_updates" do
    use_cassette "get_updates" do
      {:ok, updates} = Nadia.get_updates(limit: 1)
      assert length(updates) == 1
    end
  end

  test "set webhook" do
    use_cassette "set_webhook" do
      assert Nadia.set_webhook(url: "https://telegram.org/") == :ok
    end
  end

  test "delete webhook" do
    use_cassette "delete_webhook" do
      assert Nadia.set_webhook == :ok
    end
  end

  test "get_file" do
    use_cassette "get_file" do
      {:ok, file} = Nadia.get_file("BQADBQADBgADmEjsA1aqdSxtzvvVAg")
      refute is_nil(file.file_path)
      assert file.file_id == "BQADBQADBgADmEjsA1aqdSxtzvvVAg"
    end
  end

  test "answer_inline_query" do
    photo = %Nadia.Model.InlineQueryResult.Photo{id: "1", photo_url: "http://vignette1.wikia.nocookie.net/cardfight/images/5/53/Monokuma.jpg/revision/latest?cb=20130928103410", thumb_url: "http://vignette1.wikia.nocookie.net/cardfight/images/5/53/Monokuma.jpg/revision/latest?cb=20130928103410"}
    use_cassette "answer_inline_query" do
      assert :ok == Nadia.answer_inline_query(666, [photo])
    end
  end
end
