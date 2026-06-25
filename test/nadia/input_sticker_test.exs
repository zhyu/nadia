defmodule Nadia.InputStickerTest do
  use Nadia.HTTPCase

  alias Nadia.InputFile
  alias Nadia.InputSticker
  alias Nadia.Model.Error

  test "builders cover static, animated, and video formats" do
    assert {:ok,
            %{
              format: "static",
              sticker: "static-id",
              emoji_list: ["one"],
              keywords: [],
              mask_position: %{point: "eyes"}
            }} =
             InputSticker.static("static-id", ["one"],
               keywords: [],
               mask_position: %{point: "eyes"}
             )
             |> InputSticker.to_map()

    assert {:ok, %{format: "animated", emoji_list: ["one", "two"]}} =
             InputSticker.animated(InputFile.file_id("animated-id"), ["one", "two"])
             |> InputSticker.to_map()

    assert {:ok, %{format: "video", sticker: %InputFile{}}} =
             InputSticker.video(InputFile.bytes("webm", "sticker.webm"), ["one"])
             |> InputSticker.to_map()
  end

  test "builders reject invalid required fields, limits, URLs, and options" do
    assert_raise ArgumentError, ~r/sticker must be a non-empty/, fn ->
      InputSticker.static("", ["one"])
    end

    assert_raise ArgumentError, ~r/1 to 20/, fn ->
      InputSticker.static("sticker-id", [])
    end

    assert_raise ArgumentError, ~r/1 to 20/, fn ->
      InputSticker.static("sticker-id", List.duplicate("one", 21))
    end

    assert_raise ArgumentError, ~r/at most 20 strings and 64 characters/, fn ->
      InputSticker.static("sticker-id", ["one"], keywords: [String.duplicate("x", 65)])
    end

    assert_raise ArgumentError, ~r/do not support URLs/, fn ->
      InputSticker.animated(InputFile.url("https://cdn.example.test/sticker.tgs"), ["one"])
    end

    assert_raise ArgumentError, ~r/unsupported Nadia.InputSticker option/, fn ->
      InputSticker.video("sticker-id", ["one"], future: true)
    end
  end

  test "current creation supports multiple nested uploads and binary collision names" do
    stub_telegram_result(true)
    path = temporary_file("static.webp", "static")
    collision = "typed_sticker_#{System.unique_integer([:positive])}"
    refute existing_atom?(collision)

    stickers = [
      InputSticker.static(InputFile.path(path, attach_name: collision), ["one"]),
      InputSticker.video(
        InputFile.stream(Stream.map(["web", "m"], & &1), "video.webm",
          size: 4,
          attach_name: collision
        ),
        ["two"],
        keywords: []
      )
    ]

    assert :ok =
             Nadia.create_new_sticker_set(123, "nadia_by_bot", "Nadia", stickers,
               sticker_type: "regular",
               needs_repainting: false
             )

    request = assert_telegram_request("createNewStickerSet")
    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})
    assert params["needs_repainting"] == "false"
    assert [static, video] = Jason.decode!(params["stickers"])
    assert static["format"] == "static"
    assert video["format"] == "video"

    names =
      for {:file, _source, {"form-data", disposition}, _headers} <- parts,
          do: List.keyfind(disposition, "name", 0) |> elem(1)

    assert MapSet.new(names) == MapSet.new([collision, collision <> "_1"])
    refute existing_atom?(collision)
  end

  test "typed sticker set creation enforces the official 1-50 item range" do
    stub_telegram_result(true)

    assert {:error, %Error{reason: {:input_sticker, {:sticker_set_size, 0}}}} =
             Nadia.create_new_sticker_set(123, "nadia_by_bot", "Nadia", [])

    stickers = List.duplicate(InputSticker.static("sticker-id", ["one"]), 51)

    assert {:error, %Error{reason: {:input_sticker, {:sticker_set_size, 51}}}} =
             Nadia.create_new_sticker_set(123, "nadia_by_bot", "Nadia", stickers)

    refute_receive {:nadia_http_request, _request}
  end

  test "current add and replace workflows accept typed stickers" do
    stub_telegram_result(true)
    sticker = InputSticker.static(InputFile.bytes("webp", "sticker.webp"), ["one"])

    assert :ok = Nadia.add_sticker_to_set(123, "nadia_by_bot", sticker)
    request = assert_telegram_request("addStickerToSet")
    assert {:multipart, parts} = request.body
    assert {"sticker", encoded} = List.keyfind(parts, "sticker", 0)
    assert Jason.decode!(encoded)["format"] == "static"

    stub_telegram_result(true)

    assert :ok = Nadia.replace_sticker_in_set(123, "nadia_by_bot", "old-id", sticker)
    request = assert_telegram_request("replaceStickerInSet")
    assert {:multipart, parts} = request.body
    assert {"sticker", encoded} = List.keyfind(parts, "sticker", 0)
    assert Jason.decode!(encoded)["format"] == "static"
  end

  test "legacy callers translate to current static sticker request shapes" do
    stub_telegram_result(true)
    mask = %{point: "eyes", x_shift: 0.0, y_shift: 0.0, scale: 1.0}

    assert :ok =
             Nadia.create_new_sticker_set(
               123,
               "masks_by_bot",
               "Masks",
               "legacy-file-id",
               "one",
               contains_masks: true,
               mask_position: mask
             )

    request = assert_telegram_request("createNewStickerSet")
    params = form_params(request)
    assert params["sticker_type"] == "mask"
    refute Map.has_key?(params, "contains_masks")
    refute Map.has_key?(params, "mask_position")
    assert [sticker] = Jason.decode!(params["stickers"])
    assert sticker["format"] == "static"
    assert sticker["mask_position"]["point"] == "eyes"

    stub_telegram_result(%{file_id: "uploaded"})

    assert {:ok, %Nadia.Model.File{file_id: "uploaded"}} =
             Nadia.upload_sticker_file(123, "legacy.webp")

    request = assert_telegram_request("uploadStickerFile")
    assert form_params(request)["sticker_format"] == "static"
  end

  test "invalid opaque discriminator fails before the adapter" do
    stub_telegram_result(true)

    invalid =
      struct(InputSticker,
        variant: :future,
        sticker: "sticker-id",
        emoji_list: ["one"]
      )

    assert {:error, %Error{reason: {:input_sticker, {:invalid_discriminator, :future}}}} =
             Nadia.add_sticker_to_set(123, "nadia_by_bot", invalid)

    refute_receive {:nadia_http_request, _request}
  end

  defp temporary_file(filename, contents) do
    directory =
      Path.join(System.tmp_dir!(), "nadia-input-sticker-#{System.unique_integer([:positive])}")

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
