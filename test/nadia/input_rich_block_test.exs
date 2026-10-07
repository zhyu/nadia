defmodule Nadia.InputRichBlockTest do
  use ExUnit.Case, async: true

  alias Nadia.InputMedia
  alias Nadia.InputRichBlock

  describe "block builders fix discriminators and omit nil options" do
    test "text blocks carry their content and supported options" do
      assert {:ok, %{type: "paragraph", text: "hello", is_expandable: true}} =
               InputRichBlock.to_map(InputRichBlock.paragraph("hello", is_expandable: true))

      assert {:ok, %{type: "section_heading", text: %{"plain" => "hi"}}} =
               InputRichBlock.to_map(InputRichBlock.section_heading(%{"plain" => "hi"}))

      assert {:ok, %{type: "preformatted", text: "code", language: "elixir"}} =
               InputRichBlock.to_map(InputRichBlock.preformatted("code", language: "elixir"))

      assert {:ok, %{type: "footer", text: "bye"}} =
               InputRichBlock.to_map(InputRichBlock.footer("bye"))
    end

    test "standalone blocks carry no content" do
      assert {:ok, %{type: "divider"}} = InputRichBlock.to_map(InputRichBlock.divider())

      assert {:ok, %{type: "mathematical_expression", expression: "E=mc^2"}} =
               InputRichBlock.to_map(InputRichBlock.mathematical_expression("E=mc^2"))

      assert {:ok, %{type: "anchor", name: "intro"}} =
               InputRichBlock.to_map(InputRichBlock.anchor("intro"))
    end

    test "composite blocks keep lists and nesting" do
      items = [
        %{"marker" => %{"type" => "bullet"}, "content" => [%{"type" => "paragraph"}]},
        %{"marker" => %{"type" => "decimal"}, "content" => []}
      ]

      assert {:ok, %{type: "list", items: ^items}} =
               InputRichBlock.to_map(InputRichBlock.list(items))

      rows = [[InputRichBlock.paragraph("cell")], [%{"type" => "paragraph"}]]

      assert {:ok, %{type: "table", rows: [_, _], is_compact: true}} =
               InputRichBlock.to_map(InputRichBlock.table(rows, is_compact: true))

      assert {:ok, %{type: "details", title: %{}, content: [_], is_open: false}} =
               InputRichBlock.to_map(
                 InputRichBlock.details(%{}, [InputRichBlock.divider()], is_open: false)
               )
    end

    test "media blocks embed InputMedia values and keep options" do
      photo = InputMedia.photo("photo_file_id")

      assert {:ok,
              %{
                type: "photo",
                media: %{type: "photo", media: "photo_file_id"},
                is_above_text: true
              }} =
               InputRichBlock.to_map(InputRichBlock.photo_media(photo, is_above_text: true))

      assert {:ok,
              %{
                type: "voice_note",
                media: %{type: "voice_note", media: "voice_file_id", duration: 3}
              }} =
               InputRichBlock.to_map(
                 InputRichBlock.voice_note_media(
                   InputMedia.voice_note("voice_file_id", duration: 3)
                 )
               )
    end

    test "buttons rows pass through and unsupported options raise" do
      rows = [[%{text: "OK", callback_data: "ok"}]]

      assert {:ok, %{type: "buttons", rows: ^rows}} =
               InputRichBlock.to_map(InputRichBlock.buttons(rows))

      assert_raise ArgumentError, ~r/unsupported Nadia\.InputRichBlock option/, fn ->
        InputRichBlock.paragraph("hi", future: true)
      end
    end
  end
end
