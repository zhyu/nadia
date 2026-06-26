defmodule Nadia.TypedOutgoingContentTest do
  use Nadia.HTTPCase

  alias Nadia.Client
  alias Nadia.InputFile
  alias Nadia.InputMedia
  alias Nadia.InputPaidMedia
  alias Nadia.InputPollOption
  alias Nadia.InputPollMedia
  alias Nadia.InputProfilePhoto
  alias Nadia.InputContactMessageContent
  alias Nadia.InputInvoiceMessageContent
  alias Nadia.InputLocationMessageContent
  alias Nadia.InputRichMessage
  alias Nadia.InputRichMessageContent
  alias Nadia.InputStoryContent
  alias Nadia.InputTextMessageContent
  alias Nadia.InputVenueMessageContent
  alias Nadia.LabeledPrice
  alias Nadia.ReactionType
  alias Nadia.StoryArea
  alias Nadia.Model.Error
  alias Nadia.Model.InlineQueryResult

  defmodule LegacyProfilePhoto do
    defstruct [:type, :photo, :future_nil]
  end

  defmodule LegacyPollOption do
    defstruct [:text, :media, :future_nil]
  end

  defmodule LegacyRichMessage do
    defstruct [:html, :is_rtl, :future_nil]
  end

  defmodule LegacyInputMessageContent do
    defstruct [:message_text, :link_preview_options, :future_nil]
  end

  defmodule LegacyInlineResult do
    defstruct [:type, :id, :title, :input_message_content, :future_nil]
  end

  defmodule LegacyStoryArea do
    defstruct [:position, :type, :future_nil]
  end

  test "typed paid media discovers multiple uploads and collision-safe binary names" do
    stub_telegram_result(message_result())
    video = temporary_file("paid.mp4", "video")
    collision = "paid_attachment_#{System.unique_integer([:positive])}"
    refute existing_atom?(collision)

    media = [
      InputPaidMedia.video(
        InputFile.path(video, attach_name: "chat_id"),
        thumbnail: InputFile.bytes("thumb", "thumb.jpg", attach_name: collision),
        cover:
          InputFile.stream(Stream.map(["co", "ver"], & &1), "cover.jpg",
            size: 5,
            attach_name: collision
          ),
        supports_streaming: false
      )
    ]

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_paid_media(123, 25, media,
               caption_entities: [%{type: "bold", offset: 0, length: 4}],
               suggested_post_parameters: %{price: 10},
               reply_parameters: %{message_id: 7},
               show_caption_above_media: false
             )

    request = assert_telegram_request("sendPaidMedia")
    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})
    assert [item] = Jason.decode!(params["media"])
    assert item["supports_streaming"] == false

    assert Jason.decode!(params["caption_entities"]) == [
             %{"type" => "bold", "offset" => 0, "length" => 4}
           ]

    assert Jason.decode!(params["suggested_post_parameters"]) == %{"price" => 10}
    assert Jason.decode!(params["reply_parameters"]) == %{"message_id" => 7}
    assert params["show_caption_above_media"] == "false"

    names =
      Map.new(
        for {:file, _source, {"form-data", disposition}, _headers} <- parts do
          {List.keyfind(disposition, "filename", 0) |> elem(1),
           List.keyfind(disposition, "name", 0) |> elem(1)}
        end
      )

    assert item["media"] == "attach://chat_id_1"
    assert item["thumbnail"] == "attach://#{names["thumb.jpg"]}"
    assert item["cover"] == "attach://#{names["cover.jpg"]}"

    assert MapSet.new([names["thumb.jpg"], names["cover.jpg"]]) ==
             MapSet.new([collision, collision <> "_1"])

    refute existing_atom?(collision)
  end

  test "typed paid media validates size and malformed values before HTTP" do
    stub_telegram_result(message_result())

    assert {:error, %Error{reason: {:input_paid_media, {:media_size, 0}}}} =
             Nadia.send_paid_media(123, 25, [])

    assert {:error, %Error{reason: {:input_paid_media, {:media_size, 11}}}} =
             Nadia.send_paid_media(
               123,
               25,
               List.duplicate(InputPaidMedia.photo("photo-id"), 11)
             )

    invalid = struct(InputPaidMedia, variant: :future, fields: %{media: "file-id"})

    assert {:error, %Error{reason: {:input_paid_media, {:invalid_discriminator, :future}}}} =
             Nadia.send_paid_media(123, 25, [invalid])

    refute_receive {:nadia_http_request, _request}

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_paid_media(123, 25, [%{type: "photo", media: "raw"}])

    assert_telegram_request("sendPaidMedia")
  end

  test "typed poll media enforces description, explanation, and option contexts" do
    stub_telegram_result(message_result())

    options = [
      %{
        text: "Docs",
        media: InputPollMedia.link("https://example.test/docs")
      },
      [
        text: "Sticker",
        media: InputPollMedia.sticker(InputFile.bytes("webp", "poll.webp"))
      ]
    ]

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_poll(123, "Choose",
               type: "quiz",
               options: options,
               correct_option_ids: [0],
               question_entities: [%{type: "bold", offset: 0, length: 6}],
               explanation_entities: [%{type: "italic", offset: 0, length: 3}],
               description_entities: [%{type: "code", offset: 0, length: 3}],
               country_codes: ["US", "FT"],
               media: InputPollMedia.location(35.0, 139.0, horizontal_accuracy: 0),
               explanation_media: InputMedia.audio("audio-id"),
               reply_parameters: %{message_id: 8},
               allows_revoting: false
             )

    request = assert_telegram_request("sendPoll")
    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})
    assert params["allows_revoting"] == "false"
    assert Jason.decode!(params["correct_option_ids"]) == [0]
    assert Jason.decode!(params["country_codes"]) == ["US", "FT"]
    assert Jason.decode!(params["question_entities"]) |> hd() |> Map.get("type") == "bold"
    assert Jason.decode!(params["explanation_entities"]) |> hd() |> Map.get("type") == "italic"
    assert Jason.decode!(params["description_entities"]) |> hd() |> Map.get("type") == "code"
    assert Jason.decode!(params["reply_parameters"]) == %{"message_id" => 8}
    assert Jason.decode!(params["media"])["type"] == "location"
    assert Jason.decode!(params["explanation_media"])["type"] == "audio"
    assert [link, sticker] = Jason.decode!(params["options"])
    assert link["media"]["type"] == "link"
    assert sticker["media"]["type"] == "sticker"
    assert String.starts_with?(sticker["media"]["media"], "attach://")

    assert {:file, {:bytes, "webp", 4}, {"form-data", disposition}, []} =
             List.keyfind(parts, :file, 0)

    assert List.keyfind(disposition, "filename", 0) == {"filename", "poll.webp"}
  end

  test "invalid typed poll contexts fail locally while raw values remain compatible" do
    stub_telegram_result(message_result())

    assert {:error,
            %Error{
              reason: {:input_poll_media, {:unsupported_context, :description, :link}}
            }} =
             Nadia.send_poll(123, "Question",
               options: [%{text: "One"}],
               media: InputPollMedia.link("https://example.test")
             )

    assert {:error, %Error{reason: {:input_poll_media, :explanation_media_requires_quiz}}} =
             Nadia.send_poll(123, "Question",
               options: [%{text: "One"}],
               explanation_media: InputMedia.photo("photo-id")
             )

    assert {:error,
            %Error{
              reason: {:input_poll_media, {:unsupported_context, :option, :audio}}
            }} =
             Nadia.send_poll(123, "Question",
               options: [%{text: "One", media: InputMedia.audio("audio-id")}]
             )

    typed_options =
      List.duplicate(
        %{text: "One", media: InputPollMedia.link("https://example.test")},
        13
      )

    assert {:error, %Error{reason: {:input_poll_media, {:poll_option_size, 13}}}} =
             Nadia.send_poll(123, "Question", options: typed_options)

    refute_receive {:nadia_http_request, _request}

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_poll(123, "Question",
               options: [%{text: "One", media: %{type: "audio", media: "raw"}}],
               media: %{type: "link", url: "https://raw.example"}
             )

    assert_telegram_request("sendPoll")
  end

  test "typed poll options validate counts and correct option relationships" do
    stub_telegram_result(message_result())

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_poll(123, "Choose",
               options: [InputPollOption.new("One")],
               allows_revoting: false
             )

    request = assert_telegram_request("sendPoll")
    assert [%{"text" => "One"}] = Jason.decode!(form_params(request)["options"])

    stub_telegram_result(message_result())

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_poll(123, "Choose",
               type: "quiz",
               options:
                 Enum.map(1..12, fn index ->
                   InputPollOption.new("Option #{index}")
                 end),
               correct_option_ids: [0, 11]
             )

    assert_telegram_request("sendPoll")

    for {options, ids, expected} <- [
          {[], nil, {:option_count, 0}},
          {List.duplicate(InputPollOption.new("One"), 13), nil, {:option_count, 13}},
          {[InputPollOption.new("One")], nil, {:correct_option_ids, :required}},
          {[InputPollOption.new("One"), InputPollOption.new("Two")], [1, 0],
           {:correct_option_ids, :not_strictly_increasing}},
          {[InputPollOption.new("One"), InputPollOption.new("Two")], [0, 0],
           {:correct_option_ids, :not_strictly_increasing}},
          {[InputPollOption.new("One"), InputPollOption.new("Two")], [-1],
           {:correct_option_ids, {:out_of_bounds, -1, 2}}},
          {[InputPollOption.new("One"), InputPollOption.new("Two")], [2],
           {:correct_option_ids, {:out_of_bounds, 2, 2}}}
        ] do
      params =
        [type: "quiz", options: options]
        |> then(fn params ->
          if is_nil(ids), do: params, else: Keyword.put(params, :correct_option_ids, ids)
        end)

      assert {:error, %Error{reason: {:input_poll_option, ^expected}}} =
               Nadia.send_poll(123, "Choose", params)

      refute_receive {:nadia_http_request, _request}
    end
  end

  test "typed poll options discover nested uploads without attachment collisions" do
    stub_telegram_result(message_result())
    collision = "typed_poll_#{System.unique_integer([:positive])}"
    refute existing_atom?(collision)

    options = [
      InputPollOption.new("First",
        media: InputPollMedia.sticker(InputFile.bytes("one", "one.webp", attach_name: collision))
      ),
      InputPollOption.new("Second",
        media:
          InputMedia.video(
            InputFile.bytes("video", "video.mp4", attach_name: "chat_id"),
            thumbnail: InputFile.bytes("two", "two.jpg", attach_name: collision),
            supports_streaming: false
          )
      )
    ]

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_poll(123, "Choose", options: options)

    request = assert_telegram_request("sendPoll")
    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})
    assert [first, second] = Jason.decode!(params["options"])
    assert first["media"]["media"] == "attach://#{collision}"
    assert second["media"]["media"] == "attach://chat_id_1"
    assert second["media"]["thumbnail"] == "attach://#{collision}_1"
    assert second["media"]["supports_streaming"] == false
    refute existing_atom?(collision)
  end

  test "raw and mixed poll-option compatibility remains pass-through" do
    stub_telegram_result(message_result())

    mixed = [
      InputPollOption.new("Typed"),
      [text: "Keyword", future_nil: nil],
      %LegacyPollOption{text: "Struct", media: %{type: "future"}, future_nil: nil},
      %{"text" => "String keys", "future" => false}
    ]

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_poll(123, "Question", %{"options" => mixed})

    request = assert_telegram_request("sendPoll")
    assert [typed, keyword, legacy, string_keys] = Jason.decode!(form_params(request)["options"])
    assert typed == %{"text" => "Typed"}
    assert keyword == %{"text" => "Keyword"}
    assert legacy == %{"text" => "Struct", "media" => %{"type" => "future"}}
    assert string_keys["future"] == false

    stub_telegram_result(message_result())
    encoded = Jason.encode!([%{text: "Already JSON"}])
    assert {:ok, %Nadia.Model.Message{}} = Nadia.send_poll(123, "Question", options: encoded)
    assert form_params(assert_telegram_request("sendPoll"))["options"] == encoded
  end

  test "typed rich messages integrate with send, draft, edit, and inline content" do
    stub_telegram_result(message_result())

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_rich_message(
               123,
               InputRichMessage.html("<h2>Hello</h2>", is_rtl: false)
             )

    params = form_params(assert_telegram_request("sendRichMessage"))

    assert Jason.decode!(params["rich_message"]) == %{
             "html" => "<h2>Hello</h2>",
             "is_rtl" => false
           }

    stub_telegram_result(true)

    assert :ok =
             Nadia.send_rich_message_draft(
               123,
               7,
               InputRichMessage.markdown("<tg-thinking>Working</tg-thinking>")
             )

    assert_telegram_request("sendRichMessageDraft")

    stub_telegram_result(message_result())

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.edit_message_text(
               123,
               9,
               nil,
               nil,
               rich_message: InputRichMessage.markdown("**Edited**", skip_entity_detection: false)
             )

    params = form_params(assert_telegram_request("editMessageText"))

    assert Jason.decode!(params["rich_message"]) == %{
             "markdown" => "**Edited**",
             "skip_entity_detection" => false
           }

    stub_telegram_result(true)

    result = %InlineQueryResult.Article{
      id: "rich-inline",
      title: "Rich",
      input_message_content: InputRichMessageContent.new(InputRichMessage.html("<p>Inline</p>"))
    }

    assert :ok = Nadia.answer_inline_query("query", [result])
    params = form_params(assert_telegram_request("answerInlineQuery"))
    assert [encoded_result] = Jason.decode!(params["results"])

    assert encoded_result["input_message_content"] == %{
             "rich_message" => %{"html" => "<p>Inline</p>"}
           }
  end

  test "invalid typed rich messages fail before HTTP while raw inputs remain compatible" do
    stub_telegram_result(message_result())

    thinking = InputRichMessage.html("<tg-thinking>Working</tg-thinking>")

    for operation <- [
          fn -> Nadia.send_rich_message(123, thinking) end,
          fn -> Nadia.edit_message_text(123, 1, nil, nil, rich_message: thinking) end
        ] do
      assert {:error,
              %Error{
                reason: {:input_rich_message, {:unsupported_context, _context, :tg_thinking}}
              }} = operation.()

      refute_receive {:nadia_http_request, _request}
    end

    malformed =
      struct(InputRichMessage,
        mode: :html,
        fields: %{html: "one", markdown: "two"}
      )

    assert {:error,
            %Error{
              reason: {:input_rich_message, {:invalid_content_fields, :both}}
            }} = Nadia.send_rich_message(123, malformed)

    refute_receive {:nadia_http_request, _request}

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_rich_message(123, %{html: "<future-tag/>", future: false})

    assert_telegram_request("sendRichMessage")

    stub_telegram_result(message_result())

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_rich_message(
               123,
               %LegacyRichMessage{html: "<p>Struct</p>", is_rtl: false, future_nil: nil}
             )

    params = form_params(assert_telegram_request("sendRichMessage"))

    assert Jason.decode!(params["rich_message"]) == %{
             "html" => "<p>Struct</p>",
             "is_rtl" => false
           }

    stub_telegram_result(message_result())
    encoded = Jason.encode!(%{markdown: "**already encoded**"})

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_rich_message(123, encoded)

    assert form_params(assert_telegram_request("sendRichMessage"))["rich_message"] == encoded
  end

  test "typed rich inline content traverses every inline-result request path" do
    content =
      InputRichMessageContent.new(InputRichMessage.markdown("**Inline**", is_rtl: false))

    result = %InlineQueryResult.Article{
      id: "typed-rich-result",
      title: "Typed rich result",
      input_message_content: content
    }

    stub_telegram_result(%{inline_message_id: "guest-inline"})
    assert {:ok, %Nadia.Model.SentGuestMessage{}} = Nadia.answer_guest_query("guest", result)
    assert_typed_rich_inline_result(assert_telegram_request("answerGuestQuery"), "result")

    stub_telegram_result(%{inline_message_id: "web-app-inline"})
    assert {:ok, %Nadia.Model.SentWebAppMessage{}} = Nadia.answer_web_app_query("web-app", result)
    assert_typed_rich_inline_result(assert_telegram_request("answerWebAppQuery"), "result")

    stub_telegram_result(%{id: "prepared", expiration_date: 1_800_000_000})

    assert {:ok, %Nadia.Model.PreparedInlineMessage{}} =
             Nadia.save_prepared_inline_message(123, result)

    assert_typed_rich_inline_result(
      assert_telegram_request("savePreparedInlineMessage"),
      "result"
    )

    malformed_rich =
      struct(InputRichMessage,
        mode: :html,
        fields: %{html: "one", markdown: "two"}
      )

    malformed_content = struct(InputRichMessageContent, rich_message: malformed_rich)
    malformed_result = %{result | input_message_content: malformed_content}

    assert {:error,
            %Error{
              reason:
                {:input_rich_message_content,
                 {:input_rich_message, {:invalid_content_fields, :both}}}
            }} = Nadia.answer_inline_query("query", [malformed_result])

    refute_receive {:nadia_http_request, _request}
  end

  test "typed input message content variants traverse every inline-result request path" do
    cases = [
      {
        InputTextMessageContent.new("Typed text",
          link_preview_options: [is_disabled: false, show_above_text: false]
        ),
        %{
          "message_text" => "Typed text",
          "link_preview_options" => %{"is_disabled" => false, "show_above_text" => false}
        }
      },
      {
        InputInvoiceMessageContent.stars(
          "Stars",
          "Inline Stars",
          "stars-payload",
          LabeledPrice.new("Stars", 50),
          need_email: false
        ),
        %{
          "title" => "Stars",
          "description" => "Inline Stars",
          "payload" => "stars-payload",
          "currency" => "XTR",
          "prices" => [%{"label" => "Stars", "amount" => 50}],
          "provider_token" => "",
          "need_email" => false
        }
      },
      {
        InputLocationMessageContent.new(35.6762, 139.6503,
          horizontal_accuracy: 0,
          live_period: 60
        ),
        %{
          "latitude" => 35.6762,
          "longitude" => 139.6503,
          "horizontal_accuracy" => 0,
          "live_period" => 60
        }
      },
      {
        InputVenueMessageContent.new(35.6762, 139.6503, "Nadia Cafe", "1 Bot Street",
          google_place_type: "cafe"
        ),
        %{
          "latitude" => 35.6762,
          "longitude" => 139.6503,
          "title" => "Nadia Cafe",
          "address" => "1 Bot Street",
          "google_place_type" => "cafe"
        }
      },
      {
        InputContactMessageContent.new("+15550123", "Nadia",
          last_name: "",
          vcard: "BEGIN:VCARD\nEND:VCARD"
        ),
        %{
          "phone_number" => "+15550123",
          "first_name" => "Nadia",
          "last_name" => "",
          "vcard" => "BEGIN:VCARD\nEND:VCARD"
        }
      }
    ]

    for {content, expected_content} <- cases do
      result = %InlineQueryResult.Article{
        id: "typed-content-#{System.unique_integer([:positive])}",
        title: "Typed content",
        input_message_content: content
      }

      for {method, field, response, call} <- inline_result_paths(result) do
        stub_telegram_result(response)

        case call.() do
          :ok -> :ok
          {:ok, _value} -> :ok
        end

        assert expected_content ==
                 assert_inline_result_input_content(assert_telegram_request(method), field)
      end
    end
  end

  test "typed labeled prices integrate with invoice wrappers" do
    stub_telegram_result(message_result())

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_invoice(
               123,
               "Typed prices",
               "Existing invoice wrapper",
               "payload",
               "USD",
               [LabeledPrice.new("Base", 100), LabeledPrice.new("Discount", -10)],
               need_email: false
             )

    params = form_params(assert_telegram_request("sendInvoice"))

    assert Jason.decode!(params["prices"]) == [
             %{"label" => "Base", "amount" => 100},
             %{"label" => "Discount", "amount" => -10}
           ]

    assert params["need_email"] == "false"

    malformed = struct(LabeledPrice, fields: %{label: "Base", amount: "100"})

    assert {:error, %Error{reason: {:labeled_price, {:invalid_amount, "100"}}}} =
             Nadia.create_invoice_link(
               "Bad",
               "Malformed typed price",
               "payload",
               "USD",
               [malformed]
             )

    refute_receive {:nadia_http_request, _request}
  end

  test "malformed typed input message content fails before HTTP" do
    cases = [
      {struct(InputTextMessageContent, fields: %{message_text: ""}),
       {:input_text_message_content, :invalid_message_text}},
      {struct(InputInvoiceMessageContent, fields: invoice_content_fields(%{prices: []})),
       {:input_invoice_message_content, {:prices_size, 0}}},
      {struct(InputLocationMessageContent, fields: %{latitude: 91, longitude: 0}),
       {:input_location_message_content, {:out_of_range, :latitude, 91, -90, 90}}},
      {struct(InputVenueMessageContent,
         fields: %{latitude: 0, longitude: 181, title: "T", address: "A"}
       ), {:input_venue_message_content, {:out_of_range, :longitude, 181, -180, 180}}},
      {struct(InputContactMessageContent, fields: %{phone_number: "", first_name: "Nadia"}),
       {:input_contact_message_content, {:required, :phone_number}}}
    ]

    for {content, expected_reason} <- cases do
      result = %InlineQueryResult.Article{
        id: "malformed-content",
        title: "Malformed content",
        input_message_content: content
      }

      assert {:error, %Error{reason: ^expected_reason}} =
               Nadia.answer_inline_query("query", [result])

      refute_receive {:nadia_http_request, _request}
    end
  end

  test "raw mixed and preencoded input message content compatibility remains pass-through" do
    mixed = [
      %InlineQueryResult.Article{
        id: "typed",
        title: "Typed",
        input_message_content: InputTextMessageContent.new("Typed")
      },
      %{
        type: "article",
        id: "raw-map",
        title: "Raw map",
        input_message_content: %{
          "message_text" => "Raw map",
          "future" => false
        }
      },
      [
        type: "article",
        id: "keyword",
        title: "Keyword",
        input_message_content: [
          message_text: "Keyword content",
          link_preview_options: [is_disabled: false],
          future_nil: nil
        ]
      ],
      %LegacyInlineResult{
        type: "article",
        id: "struct",
        title: "Struct",
        input_message_content: %LegacyInputMessageContent{
          message_text: "Struct content",
          link_preview_options: %{is_disabled: false},
          future_nil: nil
        },
        future_nil: nil
      }
    ]

    stub_telegram_result(true)
    assert :ok = Nadia.answer_inline_query("query", mixed)

    params = form_params(assert_telegram_request("answerInlineQuery"))
    assert [typed, raw_map, keyword, struct_result] = Jason.decode!(params["results"])

    assert typed["input_message_content"] == %{"message_text" => "Typed"}
    assert raw_map["input_message_content"]["future"] == false

    assert keyword["input_message_content"] == %{
             "message_text" => "Keyword content",
             "link_preview_options" => %{"is_disabled" => false}
           }

    assert struct_result["input_message_content"] == %{
             "message_text" => "Struct content",
             "link_preview_options" => %{"is_disabled" => false}
           }

    preencoded_results =
      Jason.encode!([
        %{type: "article", id: "json", title: "JSON", input_message_content: %{future: false}}
      ])

    stub_telegram_result(true)
    assert :ok = Nadia.answer_inline_query("query", preencoded_results)

    assert form_params(assert_telegram_request("answerInlineQuery"))["results"] ==
             preencoded_results

    preencoded_result =
      Jason.encode!(%{
        type: "article",
        id: "json-result",
        title: "JSON result",
        input_message_content: %{future: false}
      })

    stub_telegram_result(%{inline_message_id: "preencoded-guest"})

    assert {:ok, %Nadia.Model.SentGuestMessage{}} =
             Nadia.answer_guest_query("guest", preencoded_result)

    assert form_params(assert_telegram_request("answerGuestQuery"))["result"] == preencoded_result
  end

  test "typed story areas integrate with post and edit and enforce variant limits" do
    position = StoryArea.position(50, 50, 20, 10, 0, 2)

    areas = [
      StoryArea.location(
        position,
        35.6762,
        139.6503,
        address: StoryArea.location_address("JP", city: "Tokyo")
      ),
      StoryArea.suggested_reaction(
        position,
        ReactionType.custom_emoji("custom-id"),
        is_dark: false,
        is_flipped: false
      ),
      StoryArea.link(position, "tg://resolve?domain=telegram"),
      StoryArea.weather(position, 24.5, "☀️", 0xFF112233),
      StoryArea.unique_gift(position, "Nadia Gift")
    ]

    stub_telegram_result(%{chat: %{id: -1001, type: "channel"}, id: 10})

    assert {:ok, %Nadia.Model.Story{id: 10}} =
             Nadia.post_story(
               "business-1",
               InputStoryContent.photo(InputFile.bytes("photo", "story.jpg")),
               86_400,
               areas: areas
             )

    request = assert_telegram_request("postStory")
    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})
    assert decoded_areas = Jason.decode!(params["areas"])

    assert Enum.map(decoded_areas, & &1["type"]["type"]) == [
             "location",
             "suggested_reaction",
             "link",
             "weather",
             "unique_gift"
           ]

    assert Enum.at(decoded_areas, 1)["type"]["is_dark"] == false

    for {area, count, variant, limit} <- [
          {StoryArea.location(position, 0, 0), 11, :location, 10},
          {StoryArea.suggested_reaction(position, ReactionType.emoji("👍")), 6,
           :suggested_reaction, 5},
          {StoryArea.link(position, "https://example.test"), 4, :link, 3},
          {StoryArea.weather(position, 20, "☀️", 0), 4, :weather, 3},
          {StoryArea.unique_gift(position, "gift"), 2, :unique_gift, 1}
        ] do
      assert {:error,
              %Error{
                reason: {:story_area, {:area_count, ^variant, ^count, ^limit}}
              }} =
               Nadia.edit_story(
                 "business-1",
                 10,
                 InputStoryContent.photo(InputFile.bytes("photo", "story.jpg")),
                 areas: List.duplicate(area, count)
               )

      refute_receive {:nadia_http_request, _request}
    end
  end

  test "malformed typed story areas fail locally while raw and mixed values pass" do
    content = InputStoryContent.photo(InputFile.bytes("photo", "story.jpg"))

    malformed =
      struct(StoryArea,
        variant: :weather,
        fields: %{
          position: StoryArea.position(0, 0, 1, 1, 0, 0),
          temperature: 20,
          emoji: "☀️",
          background_color: -1
        }
      )

    assert {:error, %Error{reason: {:story_area, {:invalid_argb, -1}}}} =
             Nadia.post_story("business-1", content, 86_400, areas: [malformed])

    refute_receive {:nadia_http_request, _request}

    stub_telegram_result(%{chat: %{id: -1001, type: "channel"}, id: 11})

    raw = [
      position: [x_percentage: "future"],
      type: [type: "future", is_visible: false]
    ]

    raw_struct = %LegacyStoryArea{
      position: %{x_percentage: "struct"},
      type: %{type: "future_struct", is_visible: false},
      future_nil: nil
    }

    assert {:ok, %Nadia.Model.Story{id: 11}} =
             Nadia.edit_story(
               "business-1",
               10,
               content,
               areas: [
                 StoryArea.link(StoryArea.position(0, 0, 1, 1, 0, 0), "https://x.test"),
                 raw,
                 raw_struct
               ]
             )

    request = assert_telegram_request("editStory")
    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})

    assert [_typed, raw_encoded, struct_encoded] = Jason.decode!(params["areas"])
    assert raw_encoded["type"]["is_visible"] == false
    assert struct_encoded["type"] == %{"type" => "future_struct", "is_visible" => false}

    stub_telegram_result(%{chat: %{id: -1001, type: "channel"}, id: 12})
    encoded = Jason.encode!([%{position: %{}, type: %{type: "future"}}])

    assert {:ok, %Nadia.Model.Story{id: 12}} =
             Nadia.edit_story("business-1", 11, content, areas: encoded)

    request = assert_telegram_request("editStory")
    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})
    assert params["areas"] == encoded
  end

  test "typed profile photos require uploads and integrate with both wrappers" do
    stub_telegram_result(true)
    path = temporary_file("profile.jpg", "jpg")

    assert :ok =
             Nadia.set_my_profile_photo(
               InputProfilePhoto.static(InputFile.path(path, attach_name: "photo"))
             )

    request = assert_telegram_request("setMyProfilePhoto")
    assert {:multipart, parts} = request.body
    assert {"photo", encoded} = List.keyfind(parts, "photo", 0)
    assert Jason.decode!(encoded) == %{"type" => "static", "photo" => "attach://photo_1"}

    stub_telegram_result(true)

    assert :ok =
             Nadia.set_business_account_profile_photo(
               "business-1",
               InputProfilePhoto.animated(
                 InputFile.bytes("mp4", "profile.mp4", attach_name: "business_connection_id"),
                 main_frame_timestamp: 0.0
               ),
               is_public: false
             )

    request = assert_telegram_request("setBusinessAccountProfilePhoto")
    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})
    assert params["is_public"] == "false"

    assert Jason.decode!(params["photo"]) == %{
             "type" => "animated",
             "animation" => "attach://business_connection_id_1",
             "main_frame_timestamp" => 0.0
           }

    invalid =
      struct(InputProfilePhoto,
        variant: :static,
        fields: %{photo: InputFile.file_id("not-an-upload")}
      )

    stub_telegram_result(true)

    assert {:error, %Error{reason: {:input_profile_photo, {:upload_required, :photo}}}} =
             Nadia.set_my_profile_photo(invalid)

    refute_receive {:nadia_http_request, _request}
  end

  test "typed stories upload paths, bytes, and streams and reject tampered values" do
    stub_telegram_result(%{
      chat: %{id: -1001, type: "channel", title: "Story"},
      id: 1
    })

    stream = Stream.map(["pho", "to"], & &1)

    assert {:ok, %Nadia.Model.Story{id: 1}} =
             Nadia.post_story(
               "business-1",
               InputStoryContent.photo(
                 InputFile.stream(stream, "story.jpg", size: 5, attach_name: "content")
               ),
               86_400,
               protect_content: false
             )

    request = assert_telegram_request("postStory")
    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})
    assert params["protect_content"] == "false"

    assert Jason.decode!(params["content"]) == %{
             "type" => "photo",
             "photo" => "attach://content_1"
           }

    assert {:file, {:stream, ^stream, 5}, _disposition, []} = List.keyfind(parts, :file, 0)

    client = Client.new(token: "999:story", http_client: Nadia.HTTPCase.StubHTTPClient)

    stub_telegram_result(%{
      chat: %{id: -1001, type: "channel", title: "Story"},
      id: 2
    })

    assert {:ok, %Nadia.Model.Story{id: 2}} =
             Nadia.edit_story(
               client,
               "business-1",
               1,
               InputStoryContent.video(
                 InputFile.bytes("video", "story.mp4"),
                 duration: 60,
                 cover_frame_timestamp: 0,
                 is_animation: false
               )
             )

    request =
      assert_http_request(
        method: :post,
        url: "https://api.telegram.org/bot999:story/editStory",
        headers: [],
        options: [recv_timeout: 5000]
      )

    assert {:multipart, parts} = request.body
    params = Map.new(for {key, value} <- parts, is_binary(key), do: {key, value})

    assert Jason.decode!(params["content"]) == %{
             "type" => "video",
             "video" => "attach://nadia_file_0",
             "duration" => 60,
             "cover_frame_timestamp" => 0,
             "is_animation" => false
           }

    invalid =
      struct(InputStoryContent,
        variant: :video,
        fields: %{video: InputFile.file_id("not-an-upload")}
      )

    stub_telegram_result(%{chat: %{id: -1001, type: "channel"}, id: 3})

    assert {:error, %Error{reason: {:input_story_content, {:upload_required, :video}}}} =
             Nadia.edit_story("business-1", 2, invalid)

    refute_receive {:nadia_http_request, _request}
  end

  test "raw profile and story payload compatibility remains pass-through" do
    stub_telegram_result(true)

    raw_profile = %LegacyProfilePhoto{
      type: "static",
      photo: "legacy-file-id",
      future_nil: nil
    }

    assert :ok = Nadia.set_my_profile_photo(raw_profile)
    request = assert_telegram_request("setMyProfilePhoto")

    assert Jason.decode!(form_params(request)["photo"]) == %{
             "type" => "static",
             "photo" => "legacy-file-id"
           }

    stub_telegram_result(%{chat: %{id: -1001, type: "channel"}, id: 4})
    preencoded = Jason.encode!(%{type: "video", video: "attach://legacy"})

    assert {:ok, %Nadia.Model.Story{id: 4}} =
             Nadia.edit_story("business-1", 3, preencoded)

    request = assert_telegram_request("editStory")
    assert form_params(request)["content"] == preencoded

    stub_telegram_result(message_result())
    paid_json = Jason.encode!([%{type: "photo", media: "already-json"}])

    assert {:ok, %Nadia.Model.Message{}} =
             Nadia.send_paid_media(123, 25, paid_json)

    request = assert_telegram_request("sendPaidMedia")
    assert form_params(request)["media"] == paid_json
  end

  defp message_result do
    %{
      message_id: 1,
      date: 1_700_000_000,
      chat: %{id: 123, type: "private"}
    }
  end

  defp inline_result_paths(result) do
    [
      {"answerInlineQuery", "results", true,
       fn ->
         Nadia.answer_inline_query("query", [result])
       end},
      {"answerGuestQuery", "result", %{inline_message_id: "guest-inline"},
       fn ->
         Nadia.answer_guest_query("guest", result)
       end},
      {"answerWebAppQuery", "result", %{inline_message_id: "web-app-inline"},
       fn ->
         Nadia.answer_web_app_query("web-app", result)
       end},
      {"savePreparedInlineMessage", "result", %{id: "prepared", expiration_date: 1_800_000_000},
       fn ->
         Nadia.save_prepared_inline_message(123, result)
       end}
    ]
  end

  defp assert_inline_result_input_content(request, field) do
    request
    |> form_params()
    |> Map.fetch!(field)
    |> Jason.decode!()
    |> case do
      [result] -> result
      result -> result
    end
    |> Map.fetch!("input_message_content")
  end

  defp assert_typed_rich_inline_result(request, field) do
    result =
      request
      |> form_params()
      |> Map.fetch!(field)
      |> Jason.decode!()

    assert result["input_message_content"] == %{
             "rich_message" => %{"markdown" => "**Inline**", "is_rtl" => false}
           }
  end

  defp invoice_content_fields(overrides) do
    Map.merge(
      %{
        title: "Title",
        description: "Description",
        payload: "payload",
        currency: "USD",
        prices: [LabeledPrice.new("Base", 100)]
      },
      overrides
    )
  end

  defp temporary_file(filename, contents) do
    directory =
      Path.join(System.tmp_dir!(), "nadia-typed-outgoing-#{System.unique_integer([:positive])}")

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
