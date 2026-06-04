defmodule NadiaTest do
  use Nadia.HTTPCase

  doctest Nadia, only: [get_file_link: 1]

  alias Nadia.Model.{
    File,
    InlineQueryResult,
    Message,
    User,
    UserProfilePhotos,
    WebhookInfo
  }

  test "get_me parses the current bot user" do
    {:ok, me} =
      assert_wrapper_call(
        "getMe",
        [],
        %{id: 666, first_name: "Nadia", username: "nadia_bot"},
        fn ->
          Nadia.get_me()
        end
      )

    assert me == %User{id: 666, first_name: "Nadia", username: "nadia_bot"}
  end

  test "message sending wrappers build requests and parse message results" do
    {:ok, message} =
      assert_wrapper_call(
        "sendMessage",
        [{"chat_id", "666"}, {"text", "aloha"}],
        message_result(%{text: "aloha"}),
        fn -> Nadia.send_message(666, "aloha") end
      )

    assert message.text == "aloha"

    {:ok, message} =
      assert_wrapper_call(
        "forwardMessage",
        [{"chat_id", "666"}, {"from_chat_id", "667"}, {"message_id", "668"}],
        message_result(%{forward_date: 1_700_000_001, forward_from: user_result()}),
        fn -> Nadia.forward_message(666, 667, 668) end
      )

    assert message.forward_date == 1_700_000_001
    assert message.forward_from == %User{id: 666, first_name: "Nadia", username: "nadia_bot"}

    file_id = "AgADBQADq6cxG7Vg2gSIF48DtOpj4-edszIABGGN5AM6XKzcLjwAAgI"

    {:ok, message} =
      assert_wrapper_call(
        "sendPhoto",
        [{"chat_id", "666"}, {"photo", file_id}],
        message_result(%{photo: [%{file_id: file_id, width: 90, height: 90}]}),
        fn -> Nadia.send_photo(666, file_id) end
      )

    assert Enum.any?(message.photo, &(&1.file_id == file_id))

    {:ok, message} =
      assert_wrapper_call(
        "sendSticker",
        [{"chat_id", "666"}, {"sticker", "BQADBQADBgADmEjsA1aqdSxtzvvVAg"}],
        message_result(%{sticker: %{file_id: "BQADBQADBgADmEjsA1aqdSxtzvvVAg"}}),
        fn -> Nadia.send_sticker(666, "BQADBQADBgADmEjsA1aqdSxtzvvVAg") end
      )

    assert message.sticker.file_id == "BQADBQADBgADmEjsA1aqdSxtzvvVAg"

    {:ok, message} =
      assert_wrapper_call(
        "sendAnimation",
        [{"chat_id", "666"}, {"animation", "BQADBAADhQEAArKi5FCHKeOFAAEsKQkWBA"}],
        message_result(%{document: %{file_id: "BQADBAADhQEAArKi5FCHKeOFAAEsKQkWBA"}}),
        fn -> Nadia.send_animation(666, "BQADBAADhQEAArKi5FCHKeOFAAEsKQkWBA") end
      )

    assert message.document.file_id == "BQADBAADhQEAArKi5FCHKeOFAAEsKQkWBA"
  end

  test "profile, contact, location, and venue wrappers parse structured message results" do
    {:ok, message} =
      assert_wrapper_call(
        "sendContact",
        [{"chat_id", "666"}, {"phone_number", "10123800555"}, {"first_name", "Test"}],
        message_result(%{contact: %{phone_number: "10123800555", first_name: "Test"}}),
        fn -> Nadia.send_contact(666, 10_123_800_555, "Test") end
      )

    assert message.contact.phone_number == "10123800555"
    assert message.contact.first_name == "Test"

    {:ok, message} =
      assert_wrapper_call(
        "sendLocation",
        [{"chat_id", "666"}, {"latitude", "1"}, {"longitude", "2"}],
        message_result(%{location: %{latitude: 1.0, longitude: 2.0}}),
        fn -> Nadia.send_location(666, 1, 2) end
      )

    assert_in_delta(message.location.latitude, 1.0, 1.0e-3)
    assert_in_delta(message.location.longitude, 2.0, 1.0e-3)

    {:ok, message} =
      assert_wrapper_call(
        "sendVenue",
        [
          {"chat_id", "666"},
          {"latitude", "1"},
          {"longitude", "2"},
          {"title", "Test"},
          {"address", "teststreet"}
        ],
        message_result(%{
          venue: %{
            location: %{latitude: 1.0, longitude: 2.0},
            title: "Test",
            address: "teststreet"
          }
        }),
        fn -> Nadia.send_venue(666, 1, 2, "Test", "teststreet") end
      )

    assert_in_delta(message.venue.location.latitude, 1.0, 1.0e-3)
    assert_in_delta(message.venue.location.longitude, 2.0, 1.0e-3)
    assert message.venue.title == "Test"
    assert message.venue.address == "teststreet"

    {:ok, user_profile_photos} =
      assert_wrapper_call(
        "getUserProfilePhotos",
        [{"user_id", "666"}],
        %{total_count: 1, photos: [[%{file_id: "photo-1", width: 90, height: 90}]]},
        fn -> Nadia.get_user_profile_photos(666) end
      )

    assert %UserProfilePhotos{total_count: 1, photos: [[photo]]} = user_profile_photos
    assert photo.file_id == "photo-1"
  end

  test "update, webhook, file, and chat lookup wrappers parse response models" do
    {:ok, updates} =
      assert_wrapper_call(
        "getUpdates",
        [{"limit", "1"}],
        [
          %{
            update_id: 790_000_001,
            message: message_result(%{message_id: 11, text: "hello"})
          }
        ],
        fn -> Nadia.get_updates(limit: 1) end
      )

    assert [%Nadia.Model.Update{message: %Message{text: "hello"}}] = updates

    webhook_info = %{
      allowed_updates: [],
      has_custom_certificate: false,
      last_error_date: nil,
      last_error_message: nil,
      max_connections: nil,
      pending_update_count: 0,
      url: ""
    }

    assert {:ok, %WebhookInfo{} = parsed_webhook_info} =
             assert_wrapper_call("getWebhookInfo", [], webhook_info, fn ->
               Nadia.get_webhook_info()
             end)

    assert parsed_webhook_info.pending_update_count == 0

    file_id = "BQADBQADBgADmEjsA1aqdSxtzvvVAg"

    {:ok, file} =
      assert_wrapper_call(
        "getFile",
        [{"file_id", file_id}],
        %{file_id: file_id, file_path: "document/file_10", file_size: 17680},
        fn -> Nadia.get_file(file_id) end
      )

    assert %File{file_id: ^file_id, file_path: "document/file_10"} = file

    {:ok, chat} =
      assert_wrapper_call(
        "getChat",
        [{"chat_id", "@group"}],
        %{id: -100, type: "supergroup", username: "group"},
        fn -> Nadia.get_chat("@group") end
      )

    assert chat.username == "group"

    {:ok, chat_member} =
      assert_wrapper_call(
        "getChatMember",
        [{"chat_id", "@group"}, {"user_id", "666"}],
        %{status: "member", user: user_result()},
        fn -> Nadia.get_chat_member("@group", 666) end
      )

    assert chat_member.status == "member"
    assert chat_member.user.username == "nadia_bot"

    {:ok, [admin, creator]} =
      assert_wrapper_call(
        "getChatAdministrators",
        [{"chat_id", "@group"}],
        [
          %{status: "administrator", user: user_result()},
          %{status: "creator", user: %{id: 667, first_name: "Creator", username: "group_creator"}}
        ],
        fn -> Nadia.get_chat_administrators("@group") end
      )

    assert admin.status == "administrator"
    assert admin.user.username == "nadia_bot"
    assert creator.status == "creator"
    assert creator.user.username == "group_creator"

    assert {:ok, 2} =
             assert_wrapper_call("getChatMembersCount", [{"chat_id", "@group"}], 2, fn ->
               Nadia.get_chat_members_count("@group")
             end)
  end

  test "boolean result wrappers return ok and build expected request bodies" do
    assert :ok =
             assert_wrapper_call(
               "deleteMessage",
               [{"chat_id", "1"}, {"message_id", "666"}],
               true,
               fn -> Nadia.delete_message(1, 666) end
             )

    assert :ok =
             assert_wrapper_call(
               "sendChatAction",
               [{"chat_id", "666"}, {"action", "typing"}],
               true,
               fn -> Nadia.send_chat_action(666, "typing") end
             )

    assert :ok =
             assert_wrapper_call("setWebhook", [{"url", "https://telegram.org/"}], true, fn ->
               Nadia.set_webhook(url: "https://telegram.org/")
             end)

    assert :ok =
             assert_wrapper_call("deleteWebhook", [], true, fn ->
               Nadia.delete_webhook()
             end)

    assert :ok =
             assert_wrapper_call("leaveChat", [{"chat_id", "@group"}], true, fn ->
               Nadia.leave_chat("@group")
             end)

    assert :ok =
             assert_wrapper_call(
               "pinChatMessage",
               [{"chat_id", "666"}, {"message_id", "666"}],
               true,
               fn -> Nadia.pin_chat_message(666, 666) end
             )

    assert :ok =
             assert_wrapper_call("unpinChatMessage", [{"chat_id", "666"}], true, fn ->
               Nadia.unpin_chat_message(666)
             end)
  end

  test "inline query and sticker wrappers encode requests and parse results" do
    photo = %InlineQueryResult.Photo{
      id: "1",
      photo_url: "https://example.test/photo.jpg",
      thumb_url: "https://example.test/thumb.jpg"
    }

    stub_telegram_result(true)

    assert :ok == Nadia.answer_inline_query(666, [photo], cache_time: 10)

    request = assert_telegram_request("answerInlineQuery", options: [recv_timeout: 5000])
    params = form_params(request)

    assert params["inline_query_id"] == "666"
    assert params["cache_time"] == "10"
    assert [encoded_result] = Jason.decode!(params["results"])
    assert encoded_result["id"] == "1"
    assert encoded_result["photo_url"] == "https://example.test/photo.jpg"
    assert encoded_result["thumb_url"] == "https://example.test/thumb.jpg"

    {:ok, sticker_set} =
      assert_wrapper_call(
        "getStickerSet",
        [{"name", "TomNJerry"}],
        %{
          name: "TomNJerry",
          title: "Tom and Jerry",
          stickers: [%{file_id: "sticker-1", width: 512, height: 512}]
        },
        fn -> Nadia.get_sticker_set("TomNJerry") end
      )

    assert sticker_set.name == "TomNJerry"
    assert hd(sticker_set.stickers).file_id == "sticker-1"

    assert {:ok, %File{file_id: "BQADBAADzwADZgctUjisl0we_2qGAg"}} =
             assert_wrapper_call(
               "uploadStickerFile",
               [{"user_id", "666"}, {"png_sticker", "BQADBAADzwADZgctUjisl0we_2qGAg"}],
               %{file_id: "BQADBAADzwADZgctUjisl0we_2qGAg"},
               fn -> Nadia.upload_sticker_file(666, "BQADBAADzwADZgctUjisl0we_2qGAg") end
             )

    assert :ok =
             assert_wrapper_call(
               "createNewStickerSet",
               [
                 {"user_id", "666"},
                 {"name", "test_sticker_set_by_nadia_bot"},
                 {"title", "nadia test"},
                 {"png_sticker", "BQADBAADzwADZgctUjisl0we_2qGAg"},
                 {"emojis", ":)"}
               ],
               true,
               fn ->
                 Nadia.create_new_sticker_set(
                   666,
                   "test_sticker_set_by_nadia_bot",
                   "nadia test",
                   "BQADBAADzwADZgctUjisl0we_2qGAg",
                   ":)"
                 )
               end
             )

    assert :ok =
             assert_wrapper_call(
               "addStickerToSet",
               [
                 {"user_id", "666"},
                 {"name", "test_sticker_set_by_nadia_bot"},
                 {"png_sticker", "BQADBAADqgADVTwsUrIHnx5jZ0XkAg"},
                 {"emojis", ";)"}
               ],
               true,
               fn ->
                 Nadia.add_sticker_to_set(
                   666,
                   "test_sticker_set_by_nadia_bot",
                   "BQADBAADqgADVTwsUrIHnx5jZ0XkAg",
                   ";)"
                 )
               end
             )

    assert :ok =
             assert_wrapper_call(
               "setStickerPositionInSet",
               [{"sticker", "CAADBQADLgADmEjsA7jm5QOy8WxsAg"}, {"position", "0"}],
               true,
               fn -> Nadia.set_sticker_position_in_set("CAADBQADLgADmEjsA7jm5QOy8WxsAg", 0) end
             )

    assert :ok =
             assert_wrapper_call(
               "deleteStickerFromSet",
               [{"sticker", "CAADBQADLgADmEjsA7jm5QOy8WxsAg"}],
               true,
               fn -> Nadia.delete_sticker_from_set("CAADBQADLgADmEjsA7jm5QOy8WxsAg") end
             )
  end

  test "get_file_link builds a download URL from the configured token" do
    file = %File{
      file_id: "BQADBQADBgADmEjsA1aqdSxtzvvVAg",
      file_path: "document/file_10",
      file_size: 17680
    }

    {:ok, file_link} = Nadia.get_file_link(file)

    assert file_link ==
             "https://api.telegram.org/file/bot#{Nadia.Config.token()}/document/file_10"
  end

  defp assert_wrapper_call(api_method, expected_params, result, invoke) do
    stub_telegram_result(result)

    response = invoke.()

    assert_telegram_request(api_method,
      body: {:form, expected_params},
      options: [recv_timeout: 5000]
    )

    response
  end

  defp message_result(overrides) do
    Map.merge(
      %{
        message_id: 1,
        date: 1_700_000_000,
        chat: %{id: 666, type: "private", username: "nadia_bot"},
        from: user_result()
      },
      overrides
    )
  end

  defp user_result do
    %{id: 666, first_name: "Nadia", username: "nadia_bot"}
  end
end
