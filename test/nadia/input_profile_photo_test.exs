defmodule Nadia.InputProfilePhotoTest do
  use ExUnit.Case, async: true

  alias Nadia.InputFile
  alias Nadia.InputProfilePhoto

  test "static and animated builders fix discriminators and omit nil fields" do
    photo = InputFile.bytes("jpg", "photo.jpg")
    animation = InputFile.bytes("mp4", "animation.mp4")

    assert {:ok, %{type: "static", photo: ^photo}} =
             photo |> InputProfilePhoto.static() |> InputProfilePhoto.to_map()

    assert {:ok, animated} =
             animation
             |> InputProfilePhoto.animated(main_frame_timestamp: nil)
             |> InputProfilePhoto.to_map()

    assert animated == %{type: "animated", animation: animation}

    assert {:ok, animated} =
             animation
             |> InputProfilePhoto.animated(%{main_frame_timestamp: 0.0})
             |> InputProfilePhoto.to_map()

    assert animated.main_frame_timestamp == 0.0
  end

  test "all supported upload source kinds are accepted" do
    uploads = [
      InputFile.path("/tmp/profile.jpg"),
      InputFile.bytes(["pro", "file"], "profile.jpg"),
      InputFile.stream(Stream.map(["pro", "file"], & &1), "profile.jpg", size: 7)
    ]

    for upload <- uploads do
      assert {:ok, %{photo: ^upload, type: "static"}} =
               upload |> InputProfilePhoto.static() |> InputProfilePhoto.to_map()

      assert {:ok, %{animation: ^upload, type: "animated"}} =
               upload |> InputProfilePhoto.animated() |> InputProfilePhoto.to_map()
    end
  end

  test "constructors reject references, bare binaries, and malformed streams" do
    invalid_uploads = [
      InputFile.file_id("file-id"),
      InputFile.url("https://example.test/profile.jpg"),
      "attach://profile",
      "/tmp/profile.jpg",
      %InputFile{source: {:stream, Stream.cycle(["x"])}, filename: "profile.jpg"},
      %InputFile{source: {:stream, Stream.cycle(["x"])}, filename: "profile.jpg", size: -1}
    ]

    for upload <- invalid_uploads do
      assert_raise ArgumentError,
                   ~r/must be an InputFile path, bytes, or known-size stream/,
                   fn ->
                     InputProfilePhoto.static(upload)
                   end
    end
  end

  test "animated validates main_frame_timestamp and options" do
    upload = InputFile.bytes("mp4", "profile.mp4")

    for timestamp <- [0, 0.0, 1, 1.25] do
      assert {:ok, %{main_frame_timestamp: ^timestamp}} =
               upload
               |> InputProfilePhoto.animated(main_frame_timestamp: timestamp)
               |> InputProfilePhoto.to_map()
    end

    for timestamp <- [-1, -0.1, "0", false] do
      assert_raise ArgumentError, ~r/main_frame_timestamp must be a nonnegative number/, fn ->
        InputProfilePhoto.animated(upload, main_frame_timestamp: timestamp)
      end
    end

    assert_raise ArgumentError, ~r/unsupported Nadia.InputProfilePhoto option/, fn ->
      InputProfilePhoto.animated(upload, type: "static")
    end

    assert_raise ArgumentError, ~r/options must be a keyword list or map/, fn ->
      InputProfilePhoto.animated(upload, [:main_frame_timestamp])
    end
  end

  test "to_map returns deterministic errors for tampered opaque values" do
    upload = InputFile.bytes("jpg", "profile.jpg")

    assert {:error, {:invalid_discriminator, :future}} =
             struct(InputProfilePhoto, variant: :future, fields: %{photo: upload})
             |> InputProfilePhoto.to_map()

    assert {:error, :invalid_fields} =
             struct(InputProfilePhoto, variant: :static, fields: nil)
             |> InputProfilePhoto.to_map()

    assert {:error, {:unsupported_field, :animation}} =
             struct(InputProfilePhoto,
               variant: :static,
               fields: %{photo: upload, type: "static", animation: upload}
             )
             |> InputProfilePhoto.to_map()

    assert {:error, {:upload_required, :photo}} =
             struct(InputProfilePhoto, variant: :static, fields: %{photo: "attach://photo"})
             |> InputProfilePhoto.to_map()

    assert {:error, {:nonnegative_number_required, :main_frame_timestamp}} =
             struct(InputProfilePhoto,
               variant: :animated,
               fields: %{animation: upload, main_frame_timestamp: -0.1}
             )
             |> InputProfilePhoto.to_map()
  end
end
