defmodule Nadia.InputTextMessageContentTest do
  use ExUnit.Case, async: true

  alias Nadia.InputTextMessageContent

  defmodule LinkPreviewOptions do
    defstruct [:is_disabled, :url, :prefer_small_media, :future_nil]
  end

  test "message text accepts the 1 and 4096 character boundaries" do
    for text <- ["a", String.duplicate("界", 4096)] do
      assert {:ok, %{message_text: ^text}} =
               text
               |> InputTextMessageContent.new([])
               |> InputTextMessageContent.to_map()
    end
  end

  test "message text rejects 0 and 4097 characters and invalid UTF-8" do
    for text <- ["", String.duplicate("a", 4097), <<255>>] do
      assert_raise ArgumentError,
                   ~r/message_text must be valid UTF-8 with 1 to 4096 characters/,
                   fn ->
                     InputTextMessageContent.new(text, [])
                   end
    end
  end

  test "formatting options omit nil and preserve link-preview false values" do
    entities = [%{type: "bold", offset: 0, length: 4}]

    assert {:ok, %{message_text: "One", parse_mode: "HTML"}} =
             InputTextMessageContent.new("One", parse_mode: "HTML")
             |> InputTextMessageContent.to_map()

    assert {:ok, %{message_text: "Two", entities: ^entities}} =
             InputTextMessageContent.new("Two", %{entities: entities})
             |> InputTextMessageContent.to_map()

    assert {:ok,
            %{
              message_text: "Three",
              link_preview_options: %{
                is_disabled: false,
                url: "",
                prefer_small_media: false,
                show_above_text: false
              }
            }} =
             InputTextMessageContent.new("Three",
               parse_mode: nil,
               entities: nil,
               link_preview_options: [
                 is_disabled: false,
                 url: "",
                 prefer_small_media: false,
                 prefer_large_media: nil,
                 show_above_text: false
               ]
             )
             |> InputTextMessageContent.to_map()
  end

  test "link-preview options accept map and struct inputs" do
    assert {:ok,
            %{
              message_text: "Map",
              link_preview_options: %{is_disabled: true, prefer_large_media: false}
            }} =
             InputTextMessageContent.new("Map", %{
               link_preview_options: %{is_disabled: true, prefer_large_media: false}
             })
             |> InputTextMessageContent.to_map()

    assert {:ok,
            %{
              message_text: "Struct",
              link_preview_options: %{
                is_disabled: false,
                url: "https://example.test",
                prefer_small_media: true
              }
            }} =
             InputTextMessageContent.new("Struct",
               link_preview_options: %LinkPreviewOptions{
                 is_disabled: false,
                 url: "https://example.test",
                 prefer_small_media: true,
                 future_nil: nil
               }
             )
             |> InputTextMessageContent.to_map()
  end

  test "formatting and link-preview validation rejects malformed values" do
    assert_raise ArgumentError, ~r/mutually exclusive/, fn ->
      InputTextMessageContent.new("One", parse_mode: "HTML", entities: [])
    end

    for mode <- ["", <<255>>, :html, 1] do
      assert_raise ArgumentError, ~r/parse_mode must be a non-empty valid UTF-8 binary/, fn ->
        InputTextMessageContent.new("One", parse_mode: mode)
      end
    end

    assert_raise ArgumentError, ~r/entities must be a list/, fn ->
      InputTextMessageContent.new("One", entities: %{type: "bold"})
    end

    assert_raise ArgumentError, ~r/link_preview_options is_disabled must be a boolean/, fn ->
      InputTextMessageContent.new("One", link_preview_options: %{is_disabled: "false"})
    end

    assert_raise ArgumentError, ~r/link_preview_options url must be valid UTF-8/, fn ->
      InputTextMessageContent.new("One", link_preview_options: %{url: <<255>>})
    end
  end

  test "constructors reject unsupported options and malformed option containers" do
    assert_raise ArgumentError,
                 ~r/unsupported Nadia.InputTextMessageContent option: :future/,
                 fn ->
                   InputTextMessageContent.new("One", future: true)
                 end

    for options <- [[:not_a_keyword], "HTML", nil] do
      assert_raise ArgumentError, ~r/options must be a keyword list or map/, fn ->
        InputTextMessageContent.new("One", options)
      end
    end
  end

  test "to_map returns deterministic errors for tampered opaque structs" do
    assert {:error, {:invalid_fields, :not_a_map}} =
             struct(InputTextMessageContent, fields: :not_a_map)
             |> InputTextMessageContent.to_map()

    assert {:error, {:unsupported_field, :future}} =
             struct(InputTextMessageContent, fields: %{message_text: "One", future: true})
             |> InputTextMessageContent.to_map()

    assert {:error, :invalid_message_text} =
             struct(InputTextMessageContent, fields: %{message_text: ""})
             |> InputTextMessageContent.to_map()

    assert {:error, :text_formatting_conflict} =
             struct(InputTextMessageContent,
               fields: %{message_text: "One", parse_mode: "HTML", entities: []}
             )
             |> InputTextMessageContent.to_map()

    assert {:error, {:link_preview_options, {:boolean_required, :show_above_text, 0}}} =
             struct(InputTextMessageContent,
               fields: %{message_text: "One", link_preview_options: %{show_above_text: 0}}
             )
             |> InputTextMessageContent.to_map()

    assert {:error, {:unsupported_field, :future}} =
             InputTextMessageContent.new("One")
             |> Map.put(:future, true)
             |> InputTextMessageContent.to_map()

    assert {:error, :invalid_input_text_message_content} =
             InputTextMessageContent.to_map(%{message_text: "raw"})
  end

  test "unknown binary fields never create atoms" do
    option_key = "nadia_text_option_#{System.unique_integer([:positive, :monotonic])}"
    field_key = "nadia_text_field_#{System.unique_integer([:positive, :monotonic])}"
    preview_key = "nadia_text_preview_#{System.unique_integer([:positive, :monotonic])}"
    wrapper_key = "nadia_text_wrapper_#{System.unique_integer([:positive, :monotonic])}"

    for key <- [option_key, field_key, preview_key, wrapper_key] do
      refute existing_atom?(key)
    end

    assert_raise ArgumentError, ~r/unsupported Nadia.InputTextMessageContent option/, fn ->
      InputTextMessageContent.new("One", %{option_key => true})
    end

    assert {:error, {:unsupported_field, ^field_key}} =
             struct(InputTextMessageContent, fields: %{field_key => true, message_text: "One"})
             |> InputTextMessageContent.to_map()

    assert {:error, {:link_preview_options, {:unsupported_field, ^preview_key}}} =
             struct(InputTextMessageContent,
               fields: %{message_text: "One", link_preview_options: %{preview_key => true}}
             )
             |> InputTextMessageContent.to_map()

    assert {:error, {:unsupported_field, ^wrapper_key}} =
             InputTextMessageContent.new("One")
             |> Map.put(wrapper_key, true)
             |> InputTextMessageContent.to_map()

    for key <- [option_key, field_key, preview_key, wrapper_key] do
      refute existing_atom?(key)
    end
  end

  defp existing_atom?(name) do
    _ = String.to_existing_atom(name)
    true
  rescue
    ArgumentError -> false
  end
end
