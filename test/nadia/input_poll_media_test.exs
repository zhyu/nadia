defmodule Nadia.InputPollMediaTest do
  use ExUnit.Case, async: true

  alias Nadia.InputFile
  alias Nadia.InputMedia
  alias Nadia.InputPollMedia

  test "builders fix discriminators and omit nil options" do
    assert {:ok, %{type: "link", url: "https://example.test/path"}} =
             InputPollMedia.link("https://example.test/path")
             |> InputPollMedia.to_map()

    assert {:ok,
            %{
              type: "location",
              latitude: 12.5,
              longitude: -45,
              horizontal_accuracy: 0
            }} =
             InputPollMedia.location(12.5, -45, horizontal_accuracy: 0)
             |> InputPollMedia.to_map()

    assert {:ok, sticker} =
             InputPollMedia.sticker("attach://poll_sticker", emoji: "🙂")
             |> InputPollMedia.to_map()

    assert sticker == %{
             type: "sticker",
             media: "attach://poll_sticker",
             emoji: "🙂"
           }

    assert {:ok, venue} =
             InputPollMedia.venue(35.6762, 139.6503, "Nadia Cafe", "1 Bot Street",
               foursquare_id: "four-id",
               foursquare_type: nil,
               google_place_id: "google-id",
               google_place_type: "cafe"
             )
             |> InputPollMedia.to_map()

    assert venue.type == "venue"
    assert venue.foursquare_id == "four-id"
    assert venue.google_place_id == "google-id"
    assert venue.google_place_type == "cafe"
    refute Map.has_key?(venue, :foursquare_type)
  end

  test "link requires an HTTP or HTTPS URL with a host" do
    assert %InputPollMedia{} = InputPollMedia.link("http://example.test")
    assert %InputPollMedia{} = InputPollMedia.link("https://example.test/a")

    for invalid <- ["", "example.test", "ftp://example.test/a", "https:///missing-host"] do
      assert_raise ArgumentError, ~r/HTTP or HTTPS URL with a host/, fn ->
        InputPollMedia.link(invalid)
      end
    end
  end

  test "location and venue enforce coordinate and accuracy boundaries" do
    assert %InputPollMedia{} = InputPollMedia.location(-90, -180, horizontal_accuracy: 0)
    assert %InputPollMedia{} = InputPollMedia.location(90.0, 180.0, horizontal_accuracy: 1500)
    assert %InputPollMedia{} = InputPollMedia.venue(-90, 180, "South", "Edge")

    for {latitude, longitude} <- [{-90.01, 0}, {90.01, 0}, {0, -180.01}, {0, 180.01}] do
      assert_raise ArgumentError, ~r/must be a number from/, fn ->
        InputPollMedia.location(latitude, longitude)
      end
    end

    for accuracy <- [-0.1, 1500.1, "near"] do
      assert_raise ArgumentError, ~r/horizontal_accuracy/, fn ->
        InputPollMedia.location(0, 0, horizontal_accuracy: accuracy)
      end
    end

    assert_raise ArgumentError, ~r/title must be a non-empty string/, fn ->
      InputPollMedia.venue(0, 0, "", "Address")
    end

    assert_raise ArgumentError, ~r/address must be a non-empty string/, fn ->
      InputPollMedia.venue(0, 0, "Title", "")
    end
  end

  test "sticker accepts file IDs, attach references, URLs, and supported uploads" do
    assert %InputPollMedia{} = InputPollMedia.sticker("telegram-file-id")
    assert %InputPollMedia{} = InputPollMedia.sticker("attach://manual", emoji: "✨")

    assert %InputPollMedia{} =
             InputPollMedia.sticker("https://cdn.example.test/STICKER.WEBP?version=1")

    assert %InputPollMedia{} =
             InputPollMedia.sticker(InputFile.url("https://cdn.example.test/sticker.webp"))

    assert %InputPollMedia{} =
             InputPollMedia.sticker(InputFile.path("/tmp/sticker.TGS"), emoji: "✨")

    assert %InputPollMedia{} =
             InputPollMedia.sticker(InputFile.bytes("webm", "sticker.webm"), emoji: "✨")

    assert %InputPollMedia{} =
             InputPollMedia.sticker(
               InputFile.stream(Stream.map(["tg", "s"], & &1), "sticker.tgs", size: 3),
               emoji: "✨"
             )
  end

  test "sticker rejects unsupported formats and emoji on reused sources" do
    for invalid <- [
          "https://cdn.example.test/sticker.tgs",
          InputFile.url("https://cdn.example.test/sticker.webm")
        ] do
      assert_raise ArgumentError, ~r/HTTP URLs must have a .webp path/, fn ->
        InputPollMedia.sticker(invalid)
      end
    end

    for invalid <- [
          InputFile.path("/tmp/sticker.png"),
          InputFile.bytes("png", "sticker.png"),
          InputFile.stream(["png"], "sticker.png", size: 3)
        ] do
      assert_raise ArgumentError, ~r/uploads must use a .webp, .tgs, or .webm/, fn ->
        InputPollMedia.sticker(invalid)
      end
    end

    assert_raise ArgumentError, ~r/emoji is allowed only for a newly uploaded sticker/, fn ->
      InputPollMedia.sticker("telegram-file-id", emoji: "✨")
    end

    assert_raise ArgumentError, ~r/emoji is allowed only for a newly uploaded sticker/, fn ->
      InputPollMedia.sticker(InputFile.file_id("telegram-file-id"), emoji: "✨")
    end

    assert_raise ArgumentError, ~r/emoji must be a non-empty string/, fn ->
      InputPollMedia.sticker(InputFile.bytes("webp", "sticker.webp"), emoji: "")
    end

    assert_raise ArgumentError, ~r/sticker media must be a non-empty/, fn ->
      InputPollMedia.sticker("")
    end
  end

  test "validate_context accepts the official typed media families" do
    for context <- [:description, :explanation] do
      assert :ok = InputPollMedia.validate_context(InputPollMedia.location(0, 0), context)
      assert :ok = InputPollMedia.validate_context(InputPollMedia.venue(0, 0, "T", "A"), context)

      for media <- [
            InputMedia.animation("id"),
            InputMedia.audio("id"),
            InputMedia.document("id"),
            InputMedia.live_photo("video-id", "photo-id"),
            InputMedia.photo("id"),
            InputMedia.video("id")
          ] do
        assert :ok = InputPollMedia.validate_context(media, context)
      end
    end

    for media <- [
          InputPollMedia.link("https://example.test"),
          InputPollMedia.location(0, 0),
          InputPollMedia.sticker("file-id"),
          InputPollMedia.venue(0, 0, "T", "A"),
          InputMedia.animation("id"),
          InputMedia.live_photo("video-id", "photo-id"),
          InputMedia.photo("id"),
          InputMedia.video("id")
        ] do
      assert :ok = InputPollMedia.validate_context(media, :option)
    end
  end

  test "validate_context rejects typed variants outside their poll context" do
    assert {:error, {:unsupported_context, :description, :link}} =
             InputPollMedia.validate_context(
               InputPollMedia.link("https://example.test"),
               :description
             )

    assert {:error, {:unsupported_context, :explanation, :sticker}} =
             InputPollMedia.validate_context(
               InputPollMedia.sticker("file-id"),
               :explanation
             )

    for {variant, media} <- [
          audio: InputMedia.audio("id"),
          document: InputMedia.document("id")
        ] do
      assert {:error, {:unsupported_context, :option, ^variant}} =
               InputPollMedia.validate_context(media, :option)
    end

    assert {:error, {:invalid_context, :caption}} =
             InputPollMedia.validate_context(InputPollMedia.location(0, 0), :caption)

    assert :ok = InputPollMedia.validate_context(%{type: "future"}, :option)
  end

  test "to_map and validate_context reject tampered opaque structs" do
    assert {:error, {:invalid_discriminator, :future}} =
             struct(InputPollMedia, variant: :future, fields: %{url: "https://example.test"})
             |> InputPollMedia.to_map()

    assert {:error, {:unsupported_field, :future}} =
             struct(InputPollMedia,
               variant: :location,
               fields: %{latitude: 0, longitude: 0, future: true}
             )
             |> InputPollMedia.to_map()

    assert {:error, {:out_of_range, :latitude, 91, -90, 90}} =
             struct(InputPollMedia,
               variant: :location,
               fields: %{latitude: 91, longitude: 0}
             )
             |> InputPollMedia.to_map()

    tampered_sticker =
      struct(InputPollMedia,
        variant: :sticker,
        fields: %{media: InputFile.bytes("png", "sticker.png")}
      )

    assert {:error, :invalid_sticker_upload_extension} =
             InputPollMedia.to_map(tampered_sticker)

    assert {:error, :invalid_sticker_upload_extension} =
             InputPollMedia.validate_context(tampered_sticker, :option)

    tampered_input_media =
      struct(InputMedia, variant: :photo, fields: %{media: ""})

    assert {:error, {:required, :media}} =
             InputPollMedia.validate_context(tampered_input_media, :option)
  end

  test "builders reject unsupported options and invalid provider values" do
    assert_raise ArgumentError, ~r/unsupported Nadia.InputPollMedia option/, fn ->
      InputPollMedia.location(0, 0, future: true)
    end

    assert_raise ArgumentError, ~r/options must be a keyword list or map/, fn ->
      InputPollMedia.sticker("file-id", [:not_a_keyword])
    end

    assert_raise ArgumentError, ~r/foursquare_id must be a non-empty string/, fn ->
      InputPollMedia.venue(0, 0, "T", "A", foursquare_id: "")
    end
  end
end
