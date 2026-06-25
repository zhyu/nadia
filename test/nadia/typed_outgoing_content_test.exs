defmodule Nadia.TypedOutgoingContentTest do
  use Nadia.HTTPCase

  alias Nadia.Client
  alias Nadia.InputFile
  alias Nadia.InputMedia
  alias Nadia.InputPaidMedia
  alias Nadia.InputPollMedia
  alias Nadia.InputProfilePhoto
  alias Nadia.InputStoryContent
  alias Nadia.Model.Error

  defmodule LegacyProfilePhoto do
    defstruct [:type, :photo, :future_nil]
  end

  test "typed paid media discovers multiple uploads and collision-safe binary names" do
    stub_telegram_result(message_result())
    video = temporary_file("paid.mp4", "video")
    collision = "paid_attachment_#{System.unique_integer([:positive])}"
    refute existing_atom?(collision)

    media = [
      InputPaidMedia.video(
        InputFile.path(video, attach_name: "chat_id"),
        thumbnail: InputFile.bytes("thumb", "thumb.jpg", attach_name: collision),
        cover:
          InputFile.stream(Stream.map(["co", "ver"], & &1), "cover.jpg",
            size: 5,
            attach_name: collision
          ),
        supports_streaming: false
      )
    ]

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_paid_media(123, 25, media,
               caption_entities: [%{type: "bold", offset: 0, length: 4}],
               suggested_post_parameters: %{price: 10},
               reply_parameters: %{message_id: 7},
               show_caption_above_media: false
             )

    request = assert_telegram_request("sendPaidMedia")
    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})
    assert [item] = Jason.decode!(params["media"])
    assert item["supports_streaming"] == false

    assert Jason.decode!(params["caption_entities"]) == [
             %{"type" => "bold", "offset" => 0, "length" => 4}
           ]

    assert Jason.decode!(params["suggested_post_parameters"]) == %{"price" => 10}
    assert Jason.decode!(params["reply_parameters"]) == %{"message_id" => 7}
    assert params["show_caption_above_media"] == "false"

    names =
      Map.new(
        for {:file, _source, {"form-data", disposition}, _headers} <- parts do
          {List.keyfind(disposition, "filename", 0) |> elem(1),
           List.keyfind(disposition, "name", 0) |> elem(1)}
        end
      )

    assert item["media"] == "attach://chat_id_1"
    assert item["thumbnail"] == "attach://#{names["thumb.jpg"]}"
    assert item["cover"] == "attach://#{names["cover.jpg"]}"

    assert MapSet.new([names["thumb.jpg"], names["cover.jpg"]]) ==
             MapSet.new([collision, collision <> "_1"])

    refute existing_atom?(collision)
  end

  test "typed paid media validates size and malformed values before HTTP" do
    stub_telegram_result(message_result())

    assert {:error, %Error{reason: {:input_paid_media, {:media_size, 0}}}} =
             Nadia.send_paid_media(123, 25, [])

    assert {:error, %Error{reason: {:input_paid_media, {:media_size, 11}}}} =
             Nadia.send_paid_media(
               123,
               25,
               List.duplicate(InputPaidMedia.photo("photo-id"), 11)
             )

    invalid = struct(InputPaidMedia, variant: :future, fields: %{media: "file-id"})

    assert {:error, %Error{reason: {:input_paid_media, {:invalid_discriminator, :future}}}} =
             Nadia.send_paid_media(123, 25, [invalid])

    refute_receive {:nadia_http_request, _request}

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_paid_media(123, 25, [%{type: "photo", media: "raw"}])

    assert_telegram_request("sendPaidMedia")
  end

  test "typed poll media enforces description, explanation, and option contexts" do
    stub_telegram_result(message_result())

    options = [
      %{
        text: "Docs",
        media: InputPollMedia.link("https://example.test/docs")
      },
      [
        text: "Sticker",
        media: InputPollMedia.sticker(InputFile.bytes("webp", "poll.webp"))
      ]
    ]

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_poll(123, "Choose",
               type: "quiz",
               options: options,
               correct_option_ids: [0],
               question_entities: [%{type: "bold", offset: 0, length: 6}],
               explanation_entities: [%{type: "italic", offset: 0, length: 3}],
               description_entities: [%{type: "code", offset: 0, length: 3}],
               country_codes: ["US", "FT"],
               media: InputPollMedia.location(35.0, 139.0, horizontal_accuracy: 0),
               explanation_media: InputMedia.audio("audio-id"),
               reply_parameters: %{message_id: 8},
               allows_revoting: false
             )

    request = assert_telegram_request("sendPoll")
    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})
    assert params["allows_revoting"] == "false"
    assert Jason.decode!(params["correct_option_ids"]) == [0]
    assert Jason.decode!(params["country_codes"]) == ["US", "FT"]
    assert Jason.decode!(params["question_entities"]) |> hd() |> Map.get("type") == "bold"
    assert Jason.decode!(params["explanation_entities"]) |> hd() |> Map.get("type") == "italic"
    assert Jason.decode!(params["description_entities"]) |> hd() |> Map.get("type") == "code"
    assert Jason.decode!(params["reply_parameters"]) == %{"message_id" => 8}
    assert Jason.decode!(params["media"])["type"] == "location"
    assert Jason.decode!(params["explanation_media"])["type"] == "audio"
    assert [link, sticker] = Jason.decode!(params["options"])
    assert link["media"]["type"] == "link"
    assert sticker["media"]["type"] == "sticker"
    assert String.starts_with?(sticker["media"]["media"], "attach://")

    assert {:file, {:bytes, "webp", 4}, {"form-data", disposition}, []} =
             List.keyfind(parts, :file, 0)

    assert List.keyfind(disposition, "filename", 0) == {"filename", "poll.webp"}
  end

  test "invalid typed poll contexts fail locally while raw values remain compatible" do
    stub_telegram_result(message_result())

    assert {:error,
            %Error{
              reason: {:input_poll_media, {:unsupported_context, :description, :link}}
            }} =
             Nadia.send_poll(123, "Question",
               options: [%{text: "One"}],
               media: InputPollMedia.link("https://example.test")
             )

    assert {:error, %Error{reason: {:input_poll_media, :explanation_media_requires_quiz}}} =
             Nadia.send_poll(123, "Question",
               options: [%{text: "One"}],
               explanation_media: InputMedia.photo("photo-id")
             )

    assert {:error,
            %Error{
              reason: {:input_poll_media, {:unsupported_context, :option, :audio}}
            }} =
             Nadia.send_poll(123, "Question",
               options: [%{text: "One", media: InputMedia.audio("audio-id")}]
             )

    typed_options =
      List.duplicate(
        %{text: "One", media: InputPollMedia.link("https://example.test")},
        13
      )

    assert {:error, %Error{reason: {:input_poll_media, {:poll_option_size, 13}}}} =
             Nadia.send_poll(123, "Question", options: typed_options)

    refute_receive {:nadia_http_request, _request}

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_poll(123, "Question",
               options: [%{text: "One", media: %{type: "audio", media: "raw"}}],
               media: %{type: "link", url: "https://raw.example"}
             )

    assert_telegram_request("sendPoll")
  end

  test "typed profile photos require uploads and integrate with both wrappers" do
    stub_telegram_result(true)
    path = temporary_file("profile.jpg", "jpg")

    assert :ok =
             Nadia.set_my_profile_photo(
               InputProfilePhoto.static(InputFile.path(path, attach_name: "photo"))
             )

    request = assert_telegram_request("setMyProfilePhoto")
    assert {:multipart, parts} = request.body
    assert {"photo", encoded} = List.keyfind(parts, "photo", 0)
    assert Jason.decode!(encoded) == %{"type" => "static", "photo" => "attach://photo_1"}

    stub_telegram_result(true)

    assert :ok =
             Nadia.set_business_account_profile_photo(
               "business-1",
               InputProfilePhoto.animated(
                 InputFile.bytes("mp4", "profile.mp4", attach_name: "business_connection_id"),
                 main_frame_timestamp: 0.0
               ),
               is_public: false
             )

    request = assert_telegram_request("setBusinessAccountProfilePhoto")
    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})
    assert params["is_public"] == "false"

    assert Jason.decode!(params["photo"]) == %{
             "type" => "animated",
             "animation" => "attach://business_connection_id_1",
             "main_frame_timestamp" => 0.0
           }

    invalid =
      struct(InputProfilePhoto,
        variant: :static,
        fields: %{photo: InputFile.file_id("not-an-upload")}
      )

    stub_telegram_result(true)

    assert {:error, %Error{reason: {:input_profile_photo, {:upload_required, :photo}}}} =
             Nadia.set_my_profile_photo(invalid)

    refute_receive {:nadia_http_request, _request}
  end

  test "typed stories upload paths, bytes, and streams and reject tampered values" do
    stub_telegram_result(%{
      chat: %{id: -1001, type: "channel", title: "Story"},
      id: 1
    })

    stream = Stream.map(["pho", "to"], & &1)

    assert {:ok, %Nadia.Model.Story{id: 1}} =
             Nadia.post_story(
               "business-1",
               InputStoryContent.photo(
                 InputFile.stream(stream, "story.jpg", size: 5, attach_name: "content")
               ),
               86_400,
               protect_content: false
             )

    request = assert_telegram_request("postStory")
    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})
    assert params["protect_content"] == "false"

    assert Jason.decode!(params["content"]) == %{
             "type" => "photo",
             "photo" => "attach://content_1"
           }

    assert {:file, {:stream, ^stream, 5}, _disposition, []} = List.keyfind(parts, :file, 0)

    client = Client.new(token: "999:story", http_client: Nadia.HTTPCase.StubHTTPClient)

    stub_telegram_result(%{
      chat: %{id: -1001, type: "channel", title: "Story"},
      id: 2
    })

    assert {:ok, %Nadia.Model.Story{id: 2}} =
             Nadia.edit_story(
               client,
               "business-1",
               1,
               InputStoryContent.video(
                 InputFile.bytes("video", "story.mp4"),
                 duration: 60,
                 cover_frame_timestamp: 0,
                 is_animation: false
               )
             )

    request =
      assert_http_request(
        method: :post,
        url: "https://api.telegram.org/bot999:story/editStory",
        headers: [],
        options: [recv_timeout: 5000]
      )

    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})

    assert Jason.decode!(params["content"]) == %{
             "type" => "video",
             "video" => "attach://nadia_file_0",
             "duration" => 60,
             "cover_frame_timestamp" => 0,
             "is_animation" => false
           }

    invalid =
      struct(InputStoryContent,
        variant: :video,
        fields: %{video: InputFile.file_id("not-an-upload")}
      )

    stub_telegram_result(%{chat: %{id: -1001, type: "channel"}, id: 3})

    assert {:error, %Error{reason: {:input_story_content, {:upload_required, :video}}}} =
             Nadia.edit_story("business-1", 2, invalid)

    refute_receive {:nadia_http_request, _request}
  end

  test "raw profile and story payload compatibility remains pass-through" do
    stub_telegram_result(true)

    raw_profile = %LegacyProfilePhoto{
      type: "static",
      photo: "legacy-file-id",
      future_nil: nil
    }

    assert :ok = Nadia.set_my_profile_photo(raw_profile)
    request = assert_telegram_request("setMyProfilePhoto")

    assert Jason.decode!(form_params(request)["photo"]) == %{
             "type" => "static",
             "photo" => "legacy-file-id"
           }

    stub_telegram_result(%{chat: %{id: -1001, type: "channel"}, id: 4})
    preencoded = Jason.encode!(%{type: "video", video: "attach://legacy"})

    assert {:ok, %Nadia.Model.Story{id: 4}} =
             Nadia.edit_story("business-1", 3, preencoded)

    request = assert_telegram_request("editStory")
    assert form_params(request)["content"] == preencoded

    stub_telegram_result(message_result())
    paid_json = Jason.encode!([%{type: "photo", media: "already-json"}])

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_paid_media(123, 25, paid_json)

    request = assert_telegram_request("sendPaidMedia")
    assert form_params(request)["media"] == paid_json
  end

  defp message_result do
    %{
      message_id: 1,
      date: 1_700_000_000,
      chat: %{id: 123, type: "private"}
    }
  end

  defp temporary_file(filename, contents) do
    directory =
      Path.join(System.tmp_dir!(), "nadia-typed-outgoing-#{System.unique_integer([:positive])}")

    File.mkdir_p!(directory)
    path = Path.join(directory, filename)
    File.write!(path, contents)
    on_exit(fn -> File.rm_rf(directory) end)
    path
  end

  defp existing_atom?(name) do
    _ = String.to_existing_atom(name)
    true
  rescue
    ArgumentError -> false
  end
end
