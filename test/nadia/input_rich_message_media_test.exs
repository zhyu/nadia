defmodule Nadia.InputRichMessageMediaTest do
  use ExUnit.Case, async: true

  alias Nadia.InputMedia
  alias Nadia.InputRichMessageMedia

  test "new binds an explicit id to a typed InputMedia value" do
    media = InputRichMessageMedia.new("hero", InputMedia.photo("photo_file_id"))

    assert {:ok, %{id: "hero", media: %{type: "photo", media: "photo_file_id"}}} =
             InputRichMessageMedia.to_map(media)
  end

  test "new derives an id from the media source when omitted" do
    media = InputRichMessageMedia.new(nil, InputMedia.photo("images/hero shot.png"))

    assert {:ok, %{id: "hero_shot_png", media: %{type: "photo"}}} =
             InputRichMessageMedia.to_map(media)
  end

  test "new accepts maps and pre-encoded JSON with an optional id" do
    assert {:ok, %{id: "doc", media: %{type: "document", media: "doc_id"}}} =
             InputRichMessageMedia.new("doc", %{type: "document", media: "doc_id"})
             |> InputRichMessageMedia.to_map()

    assert {:ok, %{media: ~s({"type":"photo","media":"p"})}} =
             InputRichMessageMedia.new(nil, ~s({"type":"photo","media":"p"}))
             |> InputRichMessageMedia.to_map()
  end

  test "new rejects malformed ids, missing media keys, and invalid typed media" do
    assert_raise ArgumentError, ~r/id must be 1-64 characters/, fn ->
      InputRichMessageMedia.new("bad id!", InputMedia.photo("photo_file_id"))
    end

    assert_raise ArgumentError, ~r/invalid Nadia\.InputMedia media/, fn ->
      media = InputMedia.photo("photo_file_id")
      media = struct(media, variant: :future)
      InputRichMessageMedia.new("hero", media)
    end

    media = struct(InputRichMessageMedia, fields: %{id: "orphan"})

    assert {:error, :media_entry_requires_map} = InputRichMessageMedia.to_map(media)
  end
end
