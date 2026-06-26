defmodule Nadia.InputRichMessageTest do
  use ExUnit.Case, async: true

  alias Nadia.InputRichMessage
  alias Nadia.InputRichMessageContent

  test "html and markdown builders fix the selected mode" do
    assert {:ok, %{html: "<p>Hello</p>"}} =
             InputRichMessage.html("<p>Hello</p>", [])
             |> InputRichMessage.to_map()

    assert {:ok, %{markdown: "**Hello**"}} =
             InputRichMessage.markdown("**Hello**", [])
             |> InputRichMessage.to_map()
  end

  test "empty source is accepted and optional booleans omit nil but preserve false" do
    assert {:ok,
            %{
              html: "",
              is_rtl: false,
              skip_entity_detection: false
            }} =
             InputRichMessage.html("",
               is_rtl: false,
               skip_entity_detection: false
             )
             |> InputRichMessage.to_map()

    assert {:ok, %{markdown: "", is_rtl: true}} =
             InputRichMessage.markdown("", %{
               is_rtl: true,
               skip_entity_detection: nil
             })
             |> InputRichMessage.to_map()
  end

  test "content must be valid UTF-8" do
    for builder <- [&InputRichMessage.html/2, &InputRichMessage.markdown/2] do
      assert_raise ArgumentError, ~r/content must be valid UTF-8/, fn ->
        builder.(<<255>>, [])
      end
    end

    assert {:error, {:invalid_utf8, :html}} =
             struct(InputRichMessage, mode: :html, fields: %{html: <<255>>})
             |> InputRichMessage.to_map()
  end

  test "content accepts 32768 Unicode characters and rejects 32769" do
    maximum = String.duplicate("🙂", 32_768)
    too_long = maximum <> "🙂"

    assert {:ok, %{html: ^maximum}} =
             InputRichMessage.html(maximum, [])
             |> InputRichMessage.to_map()

    assert_raise ArgumentError, ~r/at most 32768 Unicode characters/, fn ->
      InputRichMessage.markdown(too_long, [])
    end

    assert {:error, {:content_too_long, :markdown, 32_768}} =
             struct(InputRichMessage, mode: :markdown, fields: %{markdown: too_long})
             |> InputRichMessage.to_map()
  end

  test "constructors reject unsupported options and invalid booleans" do
    for field <- [:is_rtl, :skip_entity_detection] do
      assert_raise ArgumentError, ~r/#{field} must be a boolean/, fn ->
        InputRichMessage.html("hello", [{field, 0}])
      end
    end

    assert_raise ArgumentError, ~r/unsupported Nadia.InputRichMessage option: :future/, fn ->
      InputRichMessage.markdown("hello", future: true)
    end

    assert_raise ArgumentError, ~r/unsupported Nadia.InputRichMessage option: "future"/, fn ->
      InputRichMessage.markdown("hello", %{"future" => true})
    end

    assert_raise ArgumentError, ~r/options must be a keyword list or map/, fn ->
      InputRichMessage.html("hello", [:is_rtl])
    end
  end

  test "to_map rejects both, neither, mismatched, and malformed opaque modes" do
    assert {:error, {:invalid_content_fields, :both}} =
             struct(InputRichMessage,
               mode: :html,
               fields: %{html: "html", markdown: "markdown"}
             )
             |> InputRichMessage.to_map()

    assert {:error, {:invalid_content_fields, :neither}} =
             struct(InputRichMessage, mode: :html, fields: %{is_rtl: false})
             |> InputRichMessage.to_map()

    assert {:error, {:mode_mismatch, :html, :markdown}} =
             struct(InputRichMessage, mode: :html, fields: %{markdown: "markdown"})
             |> InputRichMessage.to_map()

    assert {:error, {:invalid_discriminator, :future}} =
             struct(InputRichMessage, mode: :future, fields: %{html: "html"})
             |> InputRichMessage.to_map()

    assert {:error, {:invalid_fields, nil}} =
             struct(InputRichMessage, mode: :html, fields: nil)
             |> InputRichMessage.to_map()
  end

  test "to_map deterministically rejects unsupported and invalid fields" do
    assert {:error, {:unsupported_field, :a_first}} =
             struct(InputRichMessage,
               mode: :html,
               fields: %{html: "html", z_last: true, a_first: true}
             )
             |> InputRichMessage.to_map()

    assert {:error, {:unsupported_field, :future}} =
             InputRichMessage.html("html", [])
             |> Map.put(:future, true)
             |> InputRichMessage.to_map()

    assert {:error, {:boolean_required, :is_rtl}} =
             struct(InputRichMessage, mode: :html, fields: %{html: "html", is_rtl: 0})
             |> InputRichMessage.to_map()

    assert {:error, {:boolean_required, :skip_entity_detection}} =
             struct(InputRichMessage,
               mode: :markdown,
               fields: %{markdown: "markdown", skip_entity_detection: "false"}
             )
             |> InputRichMessage.to_map()
  end

  test "ordinary messages validate in every supported context" do
    for context <- [:send, :draft, :edit, :inline_content],
        message <- [
          InputRichMessage.html("<p>Hello</p>", []),
          InputRichMessage.markdown("**Hello**", [])
        ] do
      assert :ok = InputRichMessage.validate_context(message, context)
    end

    assert {:error, {:invalid_context, :caption}} =
             InputRichMessage.validate_context(InputRichMessage.html("hello", []), :caption)
  end

  test "literal tg-thinking detection is case-insensitive and draft-only" do
    messages = [
      InputRichMessage.html("<tg-thinking>Working</tg-thinking>", []),
      InputRichMessage.markdown("prefix <TG-ThInKiNg status=\"working\">", [])
    ]

    for message <- messages do
      assert :ok = InputRichMessage.validate_context(message, :draft)

      for context <- [:send, :edit, :inline_content] do
        assert {:error, {:unsupported_context, ^context, :tg_thinking}} =
                 InputRichMessage.validate_context(message, context)
      end
    end

    conservative = InputRichMessage.markdown("\\<tg-thinking is escaped", [])

    assert {:error, {:unsupported_context, :send, :tg_thinking}} =
             InputRichMessage.validate_context(conservative, :send)
  end

  test "validate_context propagates opaque tamper errors" do
    tampered =
      struct(InputRichMessage,
        mode: :html,
        fields: %{html: "html", markdown: "markdown"}
      )

    assert {:error, {:invalid_content_fields, :both}} =
             InputRichMessage.validate_context(tampered, :send)
  end

  test "rich-message content wraps typed inline-query content" do
    rich_message =
      InputRichMessage.markdown("**inline**",
        is_rtl: false,
        skip_entity_detection: true
      )

    content = InputRichMessageContent.new(rich_message)

    assert {:ok,
            %{
              rich_message: %{
                markdown: "**inline**",
                is_rtl: false,
                skip_entity_detection: true
              }
            }} = InputRichMessageContent.to_map(content)
  end

  test "rich-message content rejects non-typed, draft-only, and tampered values" do
    assert_raise ArgumentError, ~r/requires a typed Nadia.InputRichMessage/, fn ->
      InputRichMessageContent.new(%{html: "raw"})
    end

    assert_raise ArgumentError, ~r/tg_thinking/, fn ->
      "<tg-thinking>draft</tg-thinking>"
      |> InputRichMessage.html([])
      |> InputRichMessageContent.new()
    end

    tampered_rich_message =
      struct(InputRichMessage,
        mode: :html,
        fields: %{html: "html", markdown: "markdown"}
      )

    assert {:error, {:input_rich_message, {:invalid_content_fields, :both}}} =
             struct(InputRichMessageContent, rich_message: tampered_rich_message)
             |> InputRichMessageContent.to_map()

    assert {:error, {:unsupported_field, :future}} =
             InputRichMessageContent.new(InputRichMessage.html("inline", []))
             |> Map.put(:future, true)
             |> InputRichMessageContent.to_map()
  end

  test "unknown binary fields never create atoms" do
    option_key = "nadia_rich_option_#{System.unique_integer([:positive, :monotonic])}"
    field_key = "nadia_rich_field_#{System.unique_integer([:positive, :monotonic])}"
    wrapper_key = "nadia_rich_wrapper_#{System.unique_integer([:positive, :monotonic])}"

    for key <- [option_key, field_key, wrapper_key] do
      refute existing_atom?(key)
    end

    assert_raise ArgumentError, ~r/unsupported Nadia.InputRichMessage option/, fn ->
      InputRichMessage.html("html", %{option_key => true})
    end

    assert {:error, {:unsupported_field, ^field_key}} =
             struct(InputRichMessage, mode: :html, fields: %{field_key => true, html: "html"})
             |> InputRichMessage.to_map()

    assert {:error, {:unsupported_field, ^wrapper_key}} =
             InputRichMessageContent.new(InputRichMessage.html("inline", []))
             |> Map.put(wrapper_key, true)
             |> InputRichMessageContent.to_map()

    for key <- [option_key, field_key, wrapper_key] do
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
