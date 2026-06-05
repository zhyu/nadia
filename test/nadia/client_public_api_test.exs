defmodule Nadia.ClientPublicAPITest do
  use Nadia.HTTPCase

  alias Nadia.Client
  alias Nadia.Model.File, as: TelegramFile
  alias Nadia.Model.InlineQueryResult

  test "client-aware public wrappers build form request contracts" do
    client = client()

    assert_client_call(client, "getMe", [], fn ->
      Nadia.get_me(client)
    end)

    assert_client_call(client, "sendMessage", [{"chat_id", "123"}, {"text", "hello"}], fn ->
      Nadia.send_message(client, 123, "hello")
    end)

    assert_client_call(
      client,
      "forwardMessage",
      [{"chat_id", "123"}, {"from_chat_id", "456"}, {"message_id", "789"}],
      fn -> Nadia.forward_message(client, 123, 456, 789) end
    )

    assert_client_call(
      client,
      "sendChatAction",
      [{"chat_id", "123"}, {"action", "typing"}],
      fn -> Nadia.send_chat_action(client, 123, "typing") end
    )

    assert_client_call(client, "getUpdates", [], fn ->
      Nadia.get_updates(client)
    end)

    assert_client_call(client, "getUpdates", [{"limit", "1"}], fn ->
      Nadia.get_updates(client, limit: 1)
    end)

    assert_client_call(client, "setWebhook", [], fn ->
      Nadia.set_webhook(client)
    end)

    assert_client_call(client, "setWebhook", [{"url", "https://example.test/webhook"}], fn ->
      Nadia.set_webhook(client, url: "https://example.test/webhook")
    end)

    assert_client_call(client, "deleteWebhook", [], fn ->
      Nadia.delete_webhook(client)
    end)

    assert_client_call(client, "getWebhookInfo", [], fn ->
      Nadia.get_webhook_info(client)
    end)

    assert_client_call(client, "getFile", [{"file_id", "file-1"}], fn ->
      Nadia.get_file(client, "file-1")
    end)
  end

  test "client-aware chat and moderation wrappers build form request contracts" do
    client = client()

    assert_client_call(client, "banChatMember", [{"chat_id", "123"}, {"user_id", "456"}], fn ->
      Nadia.ban_chat_member(client, 123, 456)
    end)

    assert_client_call(
      client,
      "banChatMember",
      [{"chat_id", "123"}, {"user_id", "456"}, {"until_date", "1"}],
      fn -> Nadia.ban_chat_member(client, 123, 456, until_date: 1) end
    )

    assert_client_call(client, "leaveChat", [{"chat_id", "@group"}], fn ->
      Nadia.leave_chat(client, "@group")
    end)

    assert_client_call(client, "unbanChatMember", [{"chat_id", "123"}, {"user_id", "456"}], fn ->
      Nadia.unban_chat_member(client, 123, 456)
    end)

    assert_client_call(client, "getChat", [{"chat_id", "@group"}], fn ->
      Nadia.get_chat(client, "@group")
    end)

    assert_client_call(client, "getChatAdministrators", [{"chat_id", "@group"}], fn ->
      Nadia.get_chat_administrators(client, "@group")
    end)

    assert_client_call(client, "getChatMemberCount", [{"chat_id", "@group"}], fn ->
      Nadia.get_chat_member_count(client, "@group")
    end)

    assert_client_call(client, "getChatMember", [{"chat_id", "@group"}, {"user_id", "456"}], fn ->
      Nadia.get_chat_member(client, "@group", 456)
    end)

    assert_client_call(
      client,
      "deleteMessage",
      [{"chat_id", "123"}, {"message_id", "456"}],
      fn -> Nadia.delete_message(client, 123, 456) end
    )

    assert_client_call(
      client,
      "pinChatMessage",
      [{"chat_id", "123"}, {"message_id", "456"}, {"disable_notification", "true"}],
      fn -> Nadia.pin_chat_message(client, 123, 456, disable_notification: true) end
    )

    assert_client_call(client, "unpinChatMessage", [{"chat_id", "123"}], fn ->
      Nadia.unpin_chat_message(client, 123)
    end)
  end

  test "client-aware media wrappers build form request contracts" do
    client = client()

    assert_client_call(
      client,
      "sendPhoto",
      [{"chat_id", "123"}, {"photo", "photo-id"}, {"caption", "hello"}],
      fn -> Nadia.send_photo(client, 123, "photo-id", caption: "hello") end
    )

    assert_client_call(client, "sendAudio", [{"chat_id", "123"}, {"audio", "audio-id"}], fn ->
      Nadia.send_audio(client, 123, "audio-id")
    end)

    assert_client_call(
      client,
      "sendDocument",
      [{"chat_id", "123"}, {"document", "document-id"}],
      fn -> Nadia.send_document(client, 123, "document-id") end
    )

    assert_client_call(
      client,
      "sendSticker",
      [{"chat_id", "123"}, {"sticker", "sticker-id"}],
      fn -> Nadia.send_sticker(client, 123, "sticker-id") end
    )

    assert_client_call(client, "sendVideo", [{"chat_id", "123"}, {"video", "video-id"}], fn ->
      Nadia.send_video(client, 123, "video-id")
    end)

    assert_client_call(client, "sendVoice", [{"chat_id", "123"}, {"voice", "voice-id"}], fn ->
      Nadia.send_voice(client, 123, "voice-id")
    end)

    assert_client_call(
      client,
      "sendAnimation",
      [{"chat_id", "123"}, {"animation", "animation-id"}],
      fn -> Nadia.send_animation(client, 123, "animation-id") end
    )
  end

  test "client-aware profile, location, edit, inline, and sticker wrappers build form request contracts" do
    client = client()

    assert_client_call(
      client,
      "sendLocation",
      [{"chat_id", "123"}, {"latitude", "1.5"}, {"longitude", "2.5"}],
      fn -> Nadia.send_location(client, 123, 1.5, 2.5) end
    )

    assert_client_call(
      client,
      "sendVenue",
      [
        {"chat_id", "123"},
        {"latitude", "1.5"},
        {"longitude", "2.5"},
        {"title", "Venue"},
        {"address", "Address"}
      ],
      fn -> Nadia.send_venue(client, 123, 1.5, 2.5, "Venue", "Address") end
    )

    assert_client_call(
      client,
      "sendContact",
      [{"chat_id", "123"}, {"phone_number", "5550100"}, {"first_name", "Ada"}],
      fn -> Nadia.send_contact(client, 123, "5550100", "Ada") end
    )

    assert_client_call(client, "getUserProfilePhotos", [{"user_id", "456"}, {"limit", "1"}], fn ->
      Nadia.get_user_profile_photos(client, 456, limit: 1)
    end)

    assert_client_call(
      client,
      "answerCallbackQuery",
      [{"callback_query_id", "callback-1"}, {"text", "done"}],
      fn -> Nadia.answer_callback_query(client, "callback-1", text: "done") end
    )

    assert_client_call(
      client,
      "editMessageText",
      [{"chat_id", "123"}, {"message_id", "456"}, {"text", "updated"}],
      fn -> Nadia.edit_message_text(client, 123, 456, nil, "updated") end
    )

    assert_client_call(
      client,
      "editMessageCaption",
      [{"chat_id", "123"}, {"message_id", "456"}, {"caption", "caption"}],
      fn -> Nadia.edit_message_caption(client, 123, 456, nil, caption: "caption") end
    )

    assert_client_call(
      client,
      "editMessageReplyMarkup",
      [{"chat_id", "123"}, {"message_id", "456"}],
      fn -> Nadia.edit_message_reply_markup(client, 123, 456, nil) end
    )

    assert_client_call(client, "getStickerSet", [{"name", "stickers"}], fn ->
      Nadia.get_sticker_set(client, "stickers")
    end)

    assert_client_call(
      client,
      "uploadStickerFile",
      [{"user_id", "456"}, {"png_sticker", "sticker-file"}],
      fn -> Nadia.upload_sticker_file(client, 456, "sticker-file") end
    )

    assert_client_call(
      client,
      "createNewStickerSet",
      [
        {"user_id", "456"},
        {"name", "set_name"},
        {"title", "Set Title"},
        {"png_sticker", "sticker-file"},
        {"emojis", ":)"}
      ],
      fn ->
        Nadia.create_new_sticker_set(client, 456, "set_name", "Set Title", "sticker-file", ":)")
      end
    )

    assert_client_call(
      client,
      "addStickerToSet",
      [
        {"user_id", "456"},
        {"name", "set_name"},
        {"png_sticker", "sticker-file"},
        {"emojis", ":)"}
      ],
      fn -> Nadia.add_sticker_to_set(client, 456, "set_name", "sticker-file", ":)") end
    )

    assert_client_call(
      client,
      "setStickerPositionInSet",
      [{"sticker", "sticker-id"}, {"position", "2"}],
      fn -> Nadia.set_sticker_position_in_set(client, "sticker-id", 2) end
    )

    assert_client_call(client, "deleteStickerFromSet", [{"sticker", "sticker-id"}], fn ->
      Nadia.delete_sticker_from_set(client, "sticker-id")
    end)
  end

  test "answer_inline_query/4 keeps encoded result parameters on explicit clients" do
    client = client()

    result = %InlineQueryResult.Photo{
      id: "photo-1",
      photo_url: "https://example.test/photo.jpg",
      thumb_url: "https://example.test/thumb.jpg"
    }

    stub_telegram_result(true)

    assert :ok == Nadia.answer_inline_query(client, "inline-1", [result], cache_time: 10)

    request =
      assert_http_request(
        method: :post,
        url: api_url(client, "answerInlineQuery"),
        headers: [],
        options: [recv_timeout: 5000]
      )

    params = form_params(request)

    assert params["inline_query_id"] == "inline-1"
    assert params["cache_time"] == "10"
    assert [encoded_result] = Jason.decode!(params["results"])
    assert encoded_result["id"] == "photo-1"
    assert encoded_result["photo_url"] == "https://example.test/photo.jpg"
    assert encoded_result["thumb_url"] == "https://example.test/thumb.jpg"
    refute Map.has_key?(encoded_result, "caption")
  end

  test "client-aware upload wrappers build multipart requests for local files" do
    client = client()

    file_path =
      Path.join(
        System.tmp_dir!(),
        "nadia-public-api-test-#{System.unique_integer([:positive])}.txt"
      )

    File.write!(file_path, "photo")
    on_exit(fn -> File.rm(file_path) end)

    stub_telegram_result(true)

    assert :ok == Nadia.send_photo(client, 123, file_path, caption: "hello")

    request =
      assert_http_request(
        method: :post,
        url: api_url(client, "sendPhoto"),
        headers: [],
        options: [recv_timeout: 5000]
      )

    assert {:multipart, parts} = request.body
    assert {"chat_id", "123"} in parts
    assert {"caption", "hello"} in parts

    assert {:file, file_path, {"form-data", [{"name", "photo"}, {"filename", file_path}]}, []} in parts
  end

  test "get_file_link/2 uses explicit client file URL settings" do
    client = client(token: "999:file-token", file_base_url: "https://files.example/bot")
    file = %TelegramFile{file_id: "file-1", file_path: "documents/file_1.txt", file_size: 123}

    assert Nadia.get_file_link(client, file) ==
             {:ok, "https://files.example/bot999:file-token/documents/file_1.txt"}
  end

  defp assert_client_call(%Client{} = client, api_method, expected_params, invoke) do
    stub_telegram_result(true)

    assert :ok == invoke.()

    assert_http_request(
      method: :post,
      url: api_url(client, api_method),
      body: {:form, expected_params},
      headers: [],
      options: [recv_timeout: client.recv_timeout * 1000]
    )
  end

  defp client(opts \\ []) do
    opts
    |> Keyword.put_new(:token, "999:client-token")
    |> Keyword.put_new(:http_client, Nadia.HTTPCase.StubHTTPClient)
    |> Client.new()
  end

  defp api_url(%Client{} = client, method), do: client.base_url <> client.token <> "/" <> method
end
