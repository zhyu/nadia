defmodule NadiaTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  doctest Nadia, only: [get_file_link: 1]
  alias Nadia.Model.User

  setup_all do
    unless Application.get_env(:nadia, :token) do
      Application.put_env(:nadia, :token, {:system, "ENV_TOKEN", "TEST_TOKEN"})
    end

    :ok
  end

  setup do
    ExVCR.Config.filter_sensitive_data("bot[^/]+/", "bot<TOKEN>/")
    ExVCR.Config.filter_sensitive_data("id\":\\d+", "id\":666")
    ExVCR.Config.filter_sensitive_data("id=\\d+", "id=666")
    ExVCR.Config.filter_sensitive_data("_id=@w+", "_id=@group")
    :ok
  end

  test "get_me" do
    use_cassette "get_me" do
      {:ok, me} = Nadia.get_me()
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

  test "send_contact" do
    use_cassette "send_contact" do
      {:ok, message} = Nadia.send_contact(666, 10_123_800_555, "Test")
      refute is_nil(message.contact)
      assert message.contact.phone_number == "10123800555"
      assert message.contact.first_name == "Test"
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

  test "send_venue" do
    use_cassette "send_venue" do
      {:ok, message} = Nadia.send_venue(666, 1, 2, "Test", "teststreet")
      refute is_nil(message.venue)
      assert_in_delta message.venue.location.latitude, 1, 1.0e-3
      assert_in_delta message.venue.location.longitude, 2, 1.0e-3
      assert message.venue.title == "Test"
      assert message.venue.address == "teststreet"
    end
  end

  test "delete_message" do
    use_cassette "delete_message" do
      assert Nadia.delete_message(1, 666) == :ok
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

  test "get webhook info" do
    use_cassette "get_webhook_info" do
      webhook_info = %Nadia.Model.WebhookInfo{
        allowed_updates: [],
        has_custom_certificate: false,
        last_error_date: nil,
        last_error_message: nil,
        max_connections: nil,
        pending_update_count: 0,
        url: ""
      }

      assert Nadia.get_webhook_info() == {:ok, webhook_info}
    end
  end

  test "delete webhook" do
    use_cassette "delete_webhook" do
      assert Nadia.delete_webhook() == :ok
    end
  end

  test "get_file" do
    use_cassette "get_file" do
      {:ok, file} = Nadia.get_file("BQADBQADBgADmEjsA1aqdSxtzvvVAg")
      refute is_nil(file.file_path)
      assert file.file_id == "BQADBQADBgADmEjsA1aqdSxtzvvVAg"
    end
  end

  test "get_file_link" do
    file = %Nadia.Model.File{
      file_id: "BQADBQADBgADmEjsA1aqdSxtzvvVAg",
      file_path: "document/file_10",
      file_size: 17680
    }

    {:ok, file_link} = Nadia.get_file_link(file)

    assert file_link ==
             "https://api.telegram.org/file/bot#{Nadia.Config.token()}/document/file_10"
  end

  test "get_chat" do
    use_cassette "get_chat" do
      {:ok, chat} = Nadia.get_chat("@group")
      assert chat.username == "group"
    end
  end

  test "get_chat_member" do
    use_cassette "get_chat_member" do
      {:ok, chat_member} = Nadia.get_chat_member("@group", 666)
      assert chat_member.user.username == "nadia_bot"
      assert chat_member.status == "member"
    end
  end

  test "get_chat_administrators" do
    use_cassette "get_chat_administrators" do
      {:ok, [admin | [creator]]} = Nadia.get_chat_administrators("@group")
      assert admin.status == "administrator"
      assert admin.user.username == "nadia_bot"
      assert creator.status == "creator"
      assert creator.user.username == "group_creator"
    end
  end

  test "get_chat_members_count" do
    use_cassette "get_chat_members_count" do
      {:ok, count} = Nadia.get_chat_members_count("@group")
      assert count == 2
    end
  end

  test "leave_chat" do
    use_cassette "leave_chat" do
      assert Nadia.leave_chat("@group") == :ok
    end
  end

  test "answer_inline_query" do
    photo = %Nadia.Model.InlineQueryResult.Photo{
      id: "1",
      photo_url:
        "http://vignette1.wikia.nocookie.net/cardfight/images/5/53/Monokuma.jpg/revision/latest?cb=20130928103410",
      thumb_url:
        "http://vignette1.wikia.nocookie.net/cardfight/images/5/53/Monokuma.jpg/revision/latest?cb=20130928103410"
    }

    use_cassette "answer_inline_query" do
      assert :ok == Nadia.answer_inline_query(666, [photo])
    end
  end

  test "get_sticker_set" do
    use_cassette "get_sticker_set" do
      {:ok, sticker_set} = Nadia.get_sticker_set("TomNJerry")
      assert sticker_set.name == "TomNJerry"
      assert is_list(sticker_set.stickers)
    end
  end

  test "upload_sticker_file" do
    use_cassette "upload_sticker_file" do
      {:ok, file} = Nadia.upload_sticker_file(666, "BQADBAADzwADZgctUjisl0we_2qGAg")
      assert file.file_id == "BQADBAADzwADZgctUjisl0we_2qGAg"
    end
  end

  test "create_new_sticker_set" do
    use_cassette "create_new_sticker_set" do
      assert :ok =
               Nadia.create_new_sticker_set(
                 666,
                 "test_sticker_set_by_nadia_bot",
                 "nadia test",
                 "BQADBAADzwADZgctUjisl0we_2qGAg",
                 "😂"
               )
    end
  end

  test "add_sticker_to_set" do
    use_cassette "add_sticker_to_set" do
      assert :ok =
               Nadia.add_sticker_to_set(
                 666,
                 "test_sticker_set_by_nadia_bot",
                 "BQADBAADqgADVTwsUrIHnx5jZ0XkAg",
                 "🤔"
               )
    end
  end

  test "set_sticker_position_in_set" do
    use_cassette "set_sticker_position_in_set" do
      assert :ok = Nadia.set_sticker_position_in_set("CAADBQADLgADmEjsA7jm5QOy8WxsAg", 0)
    end
  end

  test "delete_sticker_from_set" do
    use_cassette "delete_sticker_from_set" do
      assert :ok = Nadia.delete_sticker_from_set("CAADBQADLgADmEjsA7jm5QOy8WxsAg")
    end
  end

  test "pin_chat_message" do
    use_cassette "pin_chat_message" do
      assert :ok = Nadia.pin_chat_message(666, 666)
    end
  end

  test "unpin_chat_message" do
    use_cassette "unpin_chat_message" do
      assert :ok = Nadia.unpin_chat_message(666)
    end
  end
end
