defmodule Nadia.InputPollOptionTest do
  use ExUnit.Case, async: true

  alias Nadia.InputMedia
  alias Nadia.InputPollMedia
  alias Nadia.InputPollOption

  test "text accepts the 1 and 100 character boundaries" do
    for text <- ["a", String.duplicate("界", 100)] do
      assert {:ok, %{text: ^text}} =
               text
               |> InputPollOption.new([])
               |> InputPollOption.to_map()
    end
  end

  test "text rejects 0 and 101 characters and invalid UTF-8" do
    for text <- ["", String.duplicate("a", 101), <<255>>] do
      assert_raise ArgumentError, ~r/text must be valid UTF-8 with 1 to 100 characters/, fn ->
        InputPollOption.new(text, [])
      end
    end
  end

  test "options accept keyword lists and maps and omit nil values" do
    entities = [%{type: "custom_emoji", offset: 0, length: 1}]

    assert {:ok, %{text: "One", text_parse_mode: "HTML"}} =
             InputPollOption.new("One", text_parse_mode: "HTML")
             |> InputPollOption.to_map()

    assert {:ok, %{text: "Two", text_entities: ^entities}} =
             InputPollOption.new("Two", %{text_entities: entities})
             |> InputPollOption.to_map()

    assert {:ok, %{text: "Three"}} =
             InputPollOption.new("Three", %{
               text_parse_mode: nil,
               text_entities: nil,
               media: nil
             })
             |> InputPollOption.to_map()
  end

  test "options reject unsupported fields and malformed containers" do
    assert_raise ArgumentError, ~r/unsupported Nadia.InputPollOption option: :future/, fn ->
      InputPollOption.new("One", future: true)
    end

    for options <- [[:not_a_keyword], "HTML", nil] do
      assert_raise ArgumentError, ~r/options must be a keyword list or map/, fn ->
        InputPollOption.new("One", options)
      end
    end
  end

  test "parse mode must be a non-empty valid UTF-8 binary" do
    for mode <- ["", <<255>>, :html, 1] do
      assert_raise ArgumentError,
                   ~r/text_parse_mode must be a non-empty valid UTF-8 binary/,
                   fn ->
                     InputPollOption.new("One", text_parse_mode: mode)
                   end
    end
  end

  test "entities must be a list and are mutually exclusive with parse mode" do
    assert_raise ArgumentError, ~r/text_entities must be a list/, fn ->
      InputPollOption.new("One", text_entities: %{type: "custom_emoji"})
    end

    assert_raise ArgumentError, ~r/mutually exclusive/, fn ->
      InputPollOption.new("One",
        text_parse_mode: "HTML",
        text_entities: []
      )
    end
  end

  test "accepts every official typed poll-option media family" do
    media_values = [
      InputMedia.animation("animation-id"),
      InputPollMedia.link("https://example.test"),
      InputMedia.live_photo("video-id", "photo-id"),
      InputPollMedia.location(35.0, 139.0),
      InputMedia.photo("photo-id"),
      InputPollMedia.sticker("sticker-id"),
      InputPollMedia.venue(35.0, 139.0, "Nadia Cafe", "1 Bot Street"),
      InputMedia.video("video-id")
    ]

    for media <- media_values do
      assert {:ok, %{text: "One", media: ^media}} =
               InputPollOption.new("One", media: media)
               |> InputPollOption.to_map()
    end
  end

  test "rejects audio and document typed media" do
    for {variant, media} <- [
          audio: InputMedia.audio("audio-id"),
          document: InputMedia.document("document-id")
        ] do
      assert_raise ArgumentError,
                   ~r/invalid Nadia.InputPollOption value: .*unsupported_context.*#{variant}/,
                   fn ->
                     InputPollOption.new("One", media: media)
                   end
    end
  end

  test "rejects malformed typed media" do
    invalid_input_media = struct(InputMedia, variant: :photo, fields: %{media: ""})

    assert_raise ArgumentError, ~r/invalid Nadia.InputPollOption value: .*required.*media/, fn ->
      InputPollOption.new("One", media: invalid_input_media)
    end

    invalid_poll_media =
      struct(InputPollMedia,
        variant: :location,
        fields: %{latitude: 0, longitude: 0, future: true}
      )

    assert_raise ArgumentError,
                 ~r/invalid Nadia.InputPollOption value: .*unsupported_field.*future/,
                 fn ->
                   InputPollOption.new("One", media: invalid_poll_media)
                 end
  end

  test "preserves nested false values and raw compatibility media" do
    media = %{
      type: "photo",
      media: "raw-photo-id",
      metadata: %{has_spoiler: false}
    }

    assert {:ok,
            %{
              text: "One",
              text_entities: [%{custom_emoji: false}],
              media: ^media
            }} =
             InputPollOption.new("One",
               text_entities: [%{custom_emoji: false}],
               media: media
             )
             |> InputPollOption.to_map()
  end

  test "tampered opaque structs return deterministic errors" do
    assert {:error, {:invalid_fields, :not_a_map}} =
             struct(InputPollOption, fields: :not_a_map)
             |> InputPollOption.to_map()

    assert {:error, {:unsupported_field, :future}} =
             struct(InputPollOption, fields: %{text: "One", future: true})
             |> InputPollOption.to_map()

    assert {:error, :invalid_text} =
             struct(InputPollOption, fields: %{text: ""})
             |> InputPollOption.to_map()

    assert {:error, :text_formatting_conflict} =
             struct(InputPollOption,
               fields: %{text: "One", text_parse_mode: "HTML", text_entities: []}
             )
             |> InputPollOption.to_map()
  end

  test "unsupported binary keys do not create atoms" do
    unknown_key =
      "input_poll_option_unknown_#{System.unique_integer([:positive, :monotonic])}"

    refute existing_atom?(unknown_key)

    assert_raise ArgumentError, ~r/unsupported Nadia.InputPollOption option/, fn ->
      InputPollOption.new("One", %{unknown_key => true})
    end

    refute existing_atom?(unknown_key)
  end

  defp existing_atom?(name) do
    _atom = String.to_existing_atom(name)
    true
  rescue
    ArgumentError -> false
  end
end
