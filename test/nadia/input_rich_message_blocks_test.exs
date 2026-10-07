defmodule Nadia.InputRichMessageBlocksTest do
  use ExUnit.Case, async: true

  alias Nadia.InputMedia
  alias Nadia.InputRichBlock
  alias Nadia.InputRichMessage
  alias Nadia.InputRichMessageMedia

  test "blocks builds block-based content with optional fields" do
    rich = InputRichMessage.blocks([InputRichBlock.paragraph("hello")], is_rtl: true)

    assert {:ok, map} = InputRichMessage.to_map(rich)

    assert map.blocks == [InputRichBlock.to_map(InputRichBlock.paragraph("hello")) |> elem(1)]
    assert map.is_rtl == true
    refute Map.has_key?(map, :html)
    refute Map.has_key?(map, :markdown)
  end

  test "blocks rejects empty and oversized block lists" do
    assert_raise ArgumentError, ~r/\{:block_count, 0\}/, fn ->
      InputRichMessage.blocks([])
    end

    blocks = List.duplicate(InputRichBlock.paragraph("x"), 501)

    assert_raise ArgumentError, ~r/\{:block_count, 501\}/, fn ->
      InputRichMessage.blocks(blocks)
    end
  end

  test "with_media attaches typed media entries to html or markdown content" do
    rich =
      InputRichMessage.html("<b>hi</b>")
      |> InputRichMessage.with_media([
        InputRichMessageMedia.new("hero", InputMedia.photo("photo_file_id"))
      ])

    assert {:ok, %{html: "<b>hi</b>", media: [media]}} =
             InputRichMessage.to_map(rich) |> elem(1) |> then(&{:ok, &1})

    assert media == %{
             id: "hero",
             media: %{type: "photo", media: "photo_file_id"}
           }
  end

  test "with_media accepts raw InputMedia values and raw maps" do
    rich =
      InputRichMessage.markdown("**hi**")
      |> InputRichMessage.with_media([
        InputMedia.photo("images/hero.png"),
        %{id: "song", media: %{}}
      ])

    assert {:ok, %{markdown: "**hi**", media: [derived, raw]}} =
             InputRichMessage.to_map(rich) |> elem(1) |> then(&{:ok, &1})

    assert derived == %{id: "hero_png", media: %{type: "photo", media: "images/hero.png"}}
    assert raw == %{id: "song", media: %{}}
  end

  test "with_media rejects empty lists, oversized lists, and malformed entries" do
    assert_raise ArgumentError, ~r/\{:media_count, 0\}/, fn ->
      InputRichMessage.html("hi") |> InputRichMessage.with_media([])
    end

    media = List.duplicate(InputRichMessageMedia.new("m", InputMedia.photo("p")), 51)

    assert_raise ArgumentError, ~r/\{:media_count, 51\}/, fn ->
      InputRichMessage.html("hi") |> InputRichMessage.with_media(media)
    end

    assert_raise ArgumentError, ~r/:invalid_media_entry/, fn ->
      InputRichMessage.html("hi") |> InputRichMessage.with_media(["nope"])
    end
  end

  test "content fields are mutually exclusive across html, markdown, and blocks" do
    tampered =
      struct(InputRichMessage, mode: :html, fields: %{html: "a", markdown: "b", blocks: []})

    assert {:error, {:invalid_content_fields, :multiple}} = InputRichMessage.to_map(tampered)
  end
end
