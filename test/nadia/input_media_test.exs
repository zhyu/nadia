defmodule Nadia.InputMediaTest do
  use Nadia.HTTPCase

  alias Nadia.InputFile
  alias Nadia.InputMedia
  alias Nadia.Model.Error

  test "builders cover every InputMedia variant and preserve false values" do
    assert {:ok, animation} =
             InputMedia.animation("animation-id",
               thumbnail: InputFile.bytes("jpg", "thumb.jpg"),
               show_caption_above_media: false,
               has_spoiler: false,
               caption: nil
             )
             |> InputMedia.to_map()

    assert animation.type == "animation"
    assert animation.media == "animation-id"
    assert animation.show_caption_above_media == false
    assert animation.has_spoiler == false
    refute Map.has_key?(animation, :caption)

    assert {:ok, %{type: "audio", performer: "Nadia"}} =
             InputMedia.audio("audio-id", performer: "Nadia") |> InputMedia.to_map()

    assert {:ok, %{type: "document", disable_content_type_detection: false}} =
             InputMedia.document("document-id", disable_content_type_detection: false)
             |> InputMedia.to_map()

    assert {:ok, %{type: "live_photo", media: "live-video", photo: "live-photo"}} =
             InputMedia.live_photo("live-video", "live-photo") |> InputMedia.to_map()

    assert {:ok, %{type: "photo", has_spoiler: false}} =
             InputMedia.photo("photo-id", has_spoiler: false) |> InputMedia.to_map()

    assert {:ok,
            %{
              type: "video",
              media: "video-id",
              cover: "cover-id",
              supports_streaming: false
            }} =
             InputMedia.video("video-id", cover: "cover-id", supports_streaming: false)
             |> InputMedia.to_map()
  end

  test "builders reject malformed sources, unsupported URLs, thumbnails, and options" do
    assert_raise ArgumentError, ~r/media must be a non-empty/, fn ->
      InputMedia.photo("")
    end

    assert_raise ArgumentError, ~r/does not support URLs/, fn ->
      InputMedia.live_photo("https://cdn.example/live.mp4", "photo-id")
    end

    assert_raise ArgumentError, ~r/thumbnail must be a new multipart upload/, fn ->
      InputMedia.video("video-id", thumbnail: InputFile.file_id("thumb-id"))
    end

    assert_raise ArgumentError, ~r/unsupported Nadia.InputMedia option/, fn ->
      InputMedia.photo("photo-id", future_field: true)
    end
  end

  test "malformed opaque values return local wrapper errors" do
    stub_telegram_result(true)

    invalid = struct(InputMedia, variant: :future_media, fields: %{media: "file-id"})

    assert {:error, %Error{reason: {:input_media, {:invalid_discriminator, :future_media}}}} =
             Nadia.edit_message_media(invalid, inline_message_id: "inline-1")

    refute_receive {:nadia_http_request, _request}
  end

  test "typed media groups discover paths, bytes, streams, URLs, and collision-safe names" do
    stub_telegram_result([])
    path = temporary_file("video.mp4", "video")
    collision = "typed_media_#{System.unique_integer([:positive])}"
    refute existing_atom?(collision)

    stream = Stream.map(["co", "ver"], & &1)

    media = [
      InputMedia.video(
        InputFile.path(path, attach_name: "chat_id"),
        thumbnail: InputFile.bytes("jpg", "thumb.jpg", attach_name: collision),
        cover: InputFile.stream(stream, "cover.jpg", size: 5, attach_name: collision),
        supports_streaming: false
      ),
      InputMedia.photo(InputFile.url("https://cdn.example.test/photo.jpg"))
    ]

    assert {:ok, []} = Nadia.send_media_group(123, media, protect_content: false)
    request = assert_telegram_request("sendMediaGroup")
    assert {:multipart, [{"chat_id", "123"}, {"media", encoded} | parts]} = request.body

    assert [video, photo] = Jason.decode!(encoded)
    assert video["type"] == "video"
    assert video["supports_streaming"] == false
    assert photo == %{"type" => "photo", "media" => "https://cdn.example.test/photo.jpg"}

    names =
      Map.new(
        for {:file, _source, {"form-data", disposition}, _headers} <- parts do
          {List.keyfind(disposition, "filename", 0) |> elem(1),
           List.keyfind(disposition, "name", 0) |> elem(1)}
        end
      )

    assert video["media"] == "attach://chat_id_1"
    assert video["thumbnail"] == "attach://#{names["thumb.jpg"]}"
    assert video["cover"] == "attach://#{names["cover.jpg"]}"

    assert MapSet.new([names["thumb.jpg"], names["cover.jpg"]]) ==
             MapSet.new([collision, collision <> "_1"])

    refute existing_atom?(collision)
  end

  test "typed group validation enforces Telegram album families without changing raw inputs" do
    stub_telegram_result([])

    assert {:error, %Error{reason: {:input_media, {:media_group_size, 1}}}} =
             Nadia.send_media_group(123, [InputMedia.photo("photo-id")])

    assert {:error, %Error{reason: {:input_media, {:media_group_size, 0}}}} =
             Nadia.send_media_group(123, [])

    assert {:error, %Error{reason: {:input_media, {:media_group_size, 11}}}} =
             Nadia.send_media_group(123, List.duplicate(InputMedia.photo("photo-id"), 11))

    assert {:error, %Error{reason: {:input_media, {:media_group_variant, :animation}}}} =
             Nadia.send_media_group(123, [
               InputMedia.animation("animation-id"),
               InputMedia.photo("photo-id")
             ])

    assert {:error, %Error{reason: {:input_media, :mixed_document_media_group}}} =
             Nadia.send_media_group(123, [
               InputMedia.document("document-id"),
               InputMedia.photo("photo-id")
             ])

    refute_receive {:nadia_http_request, _request}

    assert {:ok, []} = Nadia.send_media_group(123, [%{type: "photo", media: "legacy-id"}])
    assert_telegram_request("sendMediaGroup")
  end

  test "typed media integrates with edits and poll media encoding" do
    stub_telegram_result(true)

    assert :ok =
             Nadia.edit_message_media(
               InputMedia.animation(InputFile.file_id("animation-id"), has_spoiler: false),
               inline_message_id: "inline-1"
             )

    request = assert_telegram_request("editMessageMedia")
    params = form_params(request)

    assert Jason.decode!(params["media"]) == %{
             "type" => "animation",
             "media" => "animation-id",
             "has_spoiler" => false
           }

    stub_telegram_result(true)

    assert :ok =
             Nadia.send_poll(123, "Pick one",
               options: [%{text: "One"}],
               media: InputMedia.photo("photo-id", has_spoiler: false)
             )

    request = assert_telegram_request("sendPoll")
    params = form_params(request)
    assert Jason.decode!(params["media"])["type"] == "photo"
  end

  defp temporary_file(filename, contents) do
    directory =
      Path.join(System.tmp_dir!(), "nadia-input-media-#{System.unique_integer([:positive])}")

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
