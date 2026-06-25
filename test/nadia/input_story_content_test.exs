defmodule Nadia.InputStoryContentTest do
  use ExUnit.Case, async: true

  alias Nadia.InputFile
  alias Nadia.InputStoryContent

  test "photo and video builders fix discriminators, omit nil, and preserve false" do
    photo = InputFile.bytes("jpg", "story.jpg")
    video = InputFile.bytes("mp4", "story.mp4")

    assert {:ok, %{type: "photo", photo: ^photo}} =
             photo |> InputStoryContent.photo() |> InputStoryContent.to_map()

    assert {:ok, content} =
             video
             |> InputStoryContent.video(
               duration: nil,
               cover_frame_timestamp: nil,
               is_animation: false
             )
             |> InputStoryContent.to_map()

    assert content == %{type: "video", video: video, is_animation: false}
  end

  test "all supported upload source kinds are accepted" do
    uploads = [
      InputFile.path("/tmp/story.jpg"),
      InputFile.bytes(["sto", "ry"], "story.jpg"),
      InputFile.stream(Stream.map(["sto", "ry"], & &1), "story.jpg", size: 5)
    ]

    for upload <- uploads do
      assert {:ok, %{photo: ^upload, type: "photo"}} =
               upload |> InputStoryContent.photo() |> InputStoryContent.to_map()

      assert {:ok, %{video: ^upload, type: "video"}} =
               upload |> InputStoryContent.video() |> InputStoryContent.to_map()
    end
  end

  test "constructors reject references, bare binaries, and malformed streams" do
    invalid_uploads = [
      InputFile.file_id("file-id"),
      InputFile.url("https://example.test/story.jpg"),
      "attach://story",
      "/tmp/story.jpg",
      %InputFile{source: {:stream, Stream.cycle(["x"])}, filename: "story.mp4"},
      %InputFile{source: {:stream, Stream.cycle(["x"])}, filename: "story.mp4", size: -1}
    ]

    for upload <- invalid_uploads do
      assert_raise ArgumentError,
                   ~r/must be an InputFile path, bytes, or known-size stream/,
                   fn ->
                     InputStoryContent.photo(upload)
                   end
    end
  end

  test "video accepts duration and cover boundaries" do
    upload = InputFile.bytes("mp4", "story.mp4")

    for duration <- [0, 0.0, 30, 30.5, 60, 60.0] do
      assert {:ok, %{duration: ^duration}} =
               upload
               |> InputStoryContent.video(duration: duration)
               |> InputStoryContent.to_map()
    end

    assert {:ok, %{duration: 60, cover_frame_timestamp: 60}} =
             upload
             |> InputStoryContent.video(duration: 60, cover_frame_timestamp: 60)
             |> InputStoryContent.to_map()

    assert {:ok, %{cover_frame_timestamp: 60.5}} =
             upload
             |> InputStoryContent.video(cover_frame_timestamp: 60.5)
             |> InputStoryContent.to_map()
  end

  test "video rejects invalid duration, cover timestamp, ordering, and animation flag" do
    upload = InputFile.bytes("mp4", "story.mp4")

    for duration <- [-0.1, 60.1, "60", false] do
      assert_raise ArgumentError, ~r/duration must be a number from 0 through 60/, fn ->
        InputStoryContent.video(upload, duration: duration)
      end
    end

    for timestamp <- [-1, -0.1, "0", true] do
      assert_raise ArgumentError, ~r/cover_frame_timestamp must be a nonnegative number/, fn ->
        InputStoryContent.video(upload, cover_frame_timestamp: timestamp)
      end
    end

    assert_raise ArgumentError, ~r/can't be greater than duration/, fn ->
      InputStoryContent.video(upload, duration: 1.5, cover_frame_timestamp: 1.6)
    end

    for value <- [0, 1, "false", :not_boolean] do
      assert_raise ArgumentError, ~r/is_animation must be a boolean/, fn ->
        InputStoryContent.video(upload, is_animation: value)
      end
    end

    assert {:ok, %{is_animation: true}} =
             upload
             |> InputStoryContent.video(is_animation: true)
             |> InputStoryContent.to_map()
  end

  test "video validates options and accepts maps" do
    upload = InputFile.bytes("mp4", "story.mp4")

    assert {:ok, %{duration: 1.5, cover_frame_timestamp: 1}} =
             upload
             |> InputStoryContent.video(%{duration: 1.5, cover_frame_timestamp: 1})
             |> InputStoryContent.to_map()

    assert_raise ArgumentError, ~r/unsupported Nadia.InputStoryContent option/, fn ->
      InputStoryContent.video(upload, type: "photo")
    end

    assert_raise ArgumentError, ~r/options must be a keyword list or map/, fn ->
      InputStoryContent.video(upload, [:duration])
    end
  end

  test "to_map returns deterministic errors for tampered opaque values" do
    upload = InputFile.bytes("mp4", "story.mp4")

    assert {:error, {:invalid_discriminator, :future}} =
             struct(InputStoryContent, variant: :future, fields: %{video: upload})
             |> InputStoryContent.to_map()

    assert {:error, :invalid_fields} =
             struct(InputStoryContent, variant: :video, fields: nil)
             |> InputStoryContent.to_map()

    assert {:error, {:unsupported_field, :photo}} =
             struct(InputStoryContent,
               variant: :video,
               fields: %{video: upload, type: "video", photo: upload}
             )
             |> InputStoryContent.to_map()

    assert {:error, {:upload_required, :video}} =
             struct(InputStoryContent, variant: :video, fields: %{video: "attach://story"})
             |> InputStoryContent.to_map()

    assert {:error, {:number_out_of_range, :duration, 0, 60}} =
             struct(InputStoryContent, variant: :video, fields: %{video: upload, duration: 61})
             |> InputStoryContent.to_map()

    assert {:error, {:nonnegative_number_required, :cover_frame_timestamp}} =
             struct(InputStoryContent,
               variant: :video,
               fields: %{video: upload, cover_frame_timestamp: -1}
             )
             |> InputStoryContent.to_map()

    assert {:error, {:boolean_required, :is_animation}} =
             struct(InputStoryContent,
               variant: :video,
               fields: %{video: upload, is_animation: 0}
             )
             |> InputStoryContent.to_map()

    assert {:error, {:cover_frame_after_duration, 2, 1}} =
             struct(InputStoryContent,
               variant: :video,
               fields: %{video: upload, duration: 1, cover_frame_timestamp: 2}
             )
             |> InputStoryContent.to_map()
  end
end
