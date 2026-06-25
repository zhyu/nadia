defmodule Nadia.InputPaidMediaTest do
  use ExUnit.Case, async: true

  alias Nadia.InputFile
  alias Nadia.InputPaidMedia

  test "builders cover every variant, omit nil, and preserve false" do
    assert {:ok, %{type: "live_photo", media: "video-id", photo: "photo-id"}} =
             InputPaidMedia.live_photo("video-id", "photo-id") |> InputPaidMedia.to_map()

    assert {:ok, %{type: "photo", media: %InputFile{source: {:file_id, "photo-id"}}}} =
             InputPaidMedia.photo(InputFile.file_id("photo-id")) |> InputPaidMedia.to_map()

    assert {:ok, video} =
             InputPaidMedia.video("video-id",
               thumbnail: InputFile.bytes("jpg", "thumb.jpg"),
               cover: InputFile.url("https://cdn.example.test/cover.jpg"),
               start_timestamp: nil,
               supports_streaming: false
             )
             |> InputPaidMedia.to_map()

    assert video.type == "video"
    assert video.media == "video-id"
    assert video.supports_streaming == false
    assert %InputFile{source: {:bytes, "jpg"}} = video.thumbnail
    assert %InputFile{source: {:url, "https://cdn.example.test/cover.jpg"}} = video.cover
    refute Map.has_key?(video, :start_timestamp)
  end

  test "ordinary media and cover sources accept references, URLs, and uploads" do
    sources = [
      "file-id",
      "https://cdn.example.test/media.jpg",
      InputFile.file_id("file-id"),
      InputFile.url("https://cdn.example.test/media.jpg"),
      InputFile.path("/tmp/media.jpg"),
      InputFile.bytes("bytes", "media.jpg"),
      InputFile.stream(Stream.map(["data"], & &1), "media.jpg", size: 4)
    ]

    Enum.each(sources, fn source ->
      assert {:ok, %{media: ^source}} =
               InputPaidMedia.photo(source) |> InputPaidMedia.to_map()

      assert {:ok, %{cover: ^source}} =
               InputPaidMedia.video("video-id", cover: source) |> InputPaidMedia.to_map()
    end)
  end

  test "live photos reject HTTP and HTTPS URLs in both fields" do
    for url <- [
          "http://cdn.example.test/live.mp4",
          "https://cdn.example.test/live.mp4",
          InputFile.url("https://cdn.example.test/live.mp4")
        ] do
      assert_raise ArgumentError, ~r/media does not support URLs/, fn ->
        InputPaidMedia.live_photo(url, "photo-id")
      end

      assert_raise ArgumentError, ~r/photo does not support URLs/, fn ->
        InputPaidMedia.live_photo("video-id", url)
      end
    end
  end

  test "video thumbnails require fresh uploads or non-empty manual attach references" do
    for thumbnail <- [
          InputFile.path("/tmp/thumb.jpg"),
          InputFile.bytes("jpg", "thumb.jpg"),
          InputFile.stream(Stream.map(["jpg"], & &1), "thumb.jpg", size: 3),
          "attach://manual-thumbnail"
        ] do
      assert {:ok, %{thumbnail: ^thumbnail}} =
               InputPaidMedia.video("video-id", thumbnail: thumbnail)
               |> InputPaidMedia.to_map()
    end

    for thumbnail <- [
          "",
          "thumbnail-file-id",
          "https://cdn.example.test/thumb.jpg",
          "attach://",
          InputFile.file_id("thumbnail-file-id"),
          InputFile.url("https://cdn.example.test/thumb.jpg")
        ] do
      assert_raise ArgumentError, ~r/thumbnail must be a new multipart upload/, fn ->
        InputPaidMedia.video("video-id", thumbnail: thumbnail)
      end
    end
  end

  test "constructors reject invalid sources, options, and option containers" do
    assert_raise ArgumentError, ~r/media must be a non-empty/, fn ->
      InputPaidMedia.photo("")
    end

    assert_raise ArgumentError, ~r/cover must be a non-empty/, fn ->
      InputPaidMedia.video("video-id", cover: "")
    end

    assert_raise ArgumentError, ~r/unsupported Nadia.InputPaidMedia option/, fn ->
      InputPaidMedia.video("video-id", future_field: true)
    end

    assert_raise ArgumentError, ~r/options must be a keyword list or map/, fn ->
      InputPaidMedia.video("video-id", [:not_a_keyword])
    end
  end

  test "to_map returns reasons for malformed opaque discriminators and fields" do
    assert {:error, {:invalid_discriminator, :future}} =
             struct(InputPaidMedia, variant: :future, fields: %{media: "file-id"})
             |> InputPaidMedia.to_map()

    assert {:error, {:invalid_fields, :not_a_map}} =
             struct(InputPaidMedia, variant: :photo, fields: :not_a_map)
             |> InputPaidMedia.to_map()

    assert {:error, {:required, :media}} =
             struct(InputPaidMedia, variant: :photo, fields: %{})
             |> InputPaidMedia.to_map()

    assert {:error, {:required, :photo}} =
             struct(InputPaidMedia, variant: :live_photo, fields: %{media: "video-id"})
             |> InputPaidMedia.to_map()

    assert {:error, {:url_not_supported, :photo}} =
             struct(InputPaidMedia,
               variant: :live_photo,
               fields: %{media: "video-id", photo: "https://cdn.example.test/photo.jpg"}
             )
             |> InputPaidMedia.to_map()

    assert {:error, {:required, :cover}} =
             struct(InputPaidMedia,
               variant: :video,
               fields: %{media: "video-id", cover: ""}
             )
             |> InputPaidMedia.to_map()

    assert {:error, :thumbnail_must_be_uploaded} =
             struct(InputPaidMedia,
               variant: :video,
               fields: %{media: "video-id", thumbnail: InputFile.file_id("thumb-id")}
             )
             |> InputPaidMedia.to_map()

    assert {:error, {:unsupported_field, :caption}} =
             struct(InputPaidMedia,
               variant: :photo,
               fields: %{media: "photo-id", caption: "not supported here"}
             )
             |> InputPaidMedia.to_map()
  end

  test "validate_media enforces 1 to 10 items when typed values are present" do
    typed = InputPaidMedia.photo("photo-id")
    raw = %{type: "photo", media: "raw-photo-id"}

    assert {:error, {:media_size, 0}} = InputPaidMedia.validate_media([])
    assert :ok = InputPaidMedia.validate_media([typed])
    assert :ok = InputPaidMedia.validate_media(List.duplicate(typed, 10))

    assert {:error, {:media_size, 11}} =
             InputPaidMedia.validate_media(List.duplicate(typed, 11))

    assert :ok = InputPaidMedia.validate_media([raw])
    assert :ok = InputPaidMedia.validate_media(List.duplicate(raw, 11))
    assert :ok = InputPaidMedia.validate_media(:raw)

    assert :ok = InputPaidMedia.validate_media([typed, raw])

    assert {:error, {:media_size, 11}} =
             InputPaidMedia.validate_media([typed | List.duplicate(raw, 10)])
  end

  test "validate_media validates every typed member in mixed structured lists" do
    malformed =
      struct(InputPaidMedia,
        variant: :video,
        fields: %{media: "video-id", thumbnail: "thumb-id"}
      )

    assert {:error, :thumbnail_must_be_uploaded} =
             InputPaidMedia.validate_media([
               %{type: "photo", media: "raw-photo-id"},
               InputPaidMedia.photo("photo-id"),
               malformed
             ])
  end
end
