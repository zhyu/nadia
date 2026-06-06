defmodule Nadia.APITest do
  use Nadia.HTTPCase

  doctest Nadia.API

  alias Nadia.API
  alias Nadia.Client
  alias Nadia.HTTPResponse
  alias Nadia.Model.Error

  alias Nadia.Model.{
    BotAccessSettings,
    BusinessBotRights,
    BusinessConnection,
    BusinessIntro,
    BusinessLocation,
    BusinessMessagesDeleted,
    BusinessOpeningHours,
    BusinessOpeningHoursInterval,
    Chat,
    ChatBoost,
    ChatBoostAdded,
    ChatBoostRemoved,
    ChatBoostSourceGiftCode,
    ChatBoostSourceGiveaway,
    ChatBoostSourcePremium,
    ChatBoostUpdated,
    Message,
    MessageEntity,
    ManagedBotCreated,
    ManagedBotUpdated,
    Location,
    MessageReactionUpdated,
    PaidMedia,
    PaidMediaInfo,
    PaidMediaLivePhoto,
    PaidMediaPhoto,
    PaidMediaPreview,
    PaidMediaPurchased,
    PaidMediaVideo,
    PhotoSize,
    ReactionCount,
    ReactionType,
    ReplyKeyboardRemove,
    SentGuestMessage,
    Sticker,
    User,
    UserChatBoosts,
    Video
  }

  defmodule BotAHTTPClient do
    @behaviour Nadia.HTTPClient

    @impl Nadia.HTTPClient
    def post(request) do
      send(self(), {:bot_a_request, request})
      {:ok, %Nadia.HTTPResponse{status_code: 200, body: Jason.encode!(%{ok: true, result: true})}}
    end
  end

  defmodule BotBHTTPClient do
    @behaviour Nadia.HTTPClient

    @impl Nadia.HTTPClient
    def post(request) do
      send(self(), {:bot_b_request, request})
      {:ok, %Nadia.HTTPResponse{status_code: 200, body: Jason.encode!(%{ok: true, result: true})}}
    end
  end

  test "request_with_map" do
    stub_telegram_result([])

    assert [] == API.request?("getUpdates", %{"limit" => 4})

    assert_telegram_request("getUpdates",
      body: {:form, [{"limit", "4"}]},
      options: [recv_timeout: 5000]
    )
  end

  test "public method uses the HTTP boundary and parses successful responses" do
    stub_telegram_result(%{id: 123, first_name: "Nadia"})

    assert {:ok, %User{id: 123, first_name: "Nadia"}} = Nadia.get_me()

    assert_telegram_request("getMe",
      body: {:form, []},
      options: [recv_timeout: 5000]
    )
  end

  test "request ignores unknown Telegram response fields without creating atoms" do
    unknown_key = "telegram_unknown_#{System.unique_integer([:positive])}"
    refute existing_atom?(unknown_key)

    stub_http_response(
      {:ok,
       %HTTPResponse{
         status_code: 200,
         body:
           Jason.encode!(%{
             "ok" => true,
             "result" => %{
               "id" => 123,
               "first_name" => "Nadia",
               unknown_key => "ignored"
             }
           })
       }}
    )

    assert {:ok, %User{id: 123, first_name: "Nadia"}} = Nadia.get_me()
    refute existing_atom?(unknown_key)
  end

  test "request decodes fixture-backed modern getUpdates response" do
    unknown_update_key = "future_update_field"
    unknown_message_key = "future_message_field"
    unknown_user_key = "future_user_field"

    refute existing_atom?(unknown_update_key)
    refute existing_atom?(unknown_message_key)
    refute existing_atom?(unknown_user_key)

    stub_http_response(
      {:ok,
       %HTTPResponse{
         status_code: 200,
         body: response_fixture("get_updates_modern.json")
       }}
    )

    assert {:ok, [%{edited_channel_post: %Message{} = message}, %{guest_message: guest_message}]} =
             Nadia.get_updates()

    assert message.business_connection_id == "business-connection-1"
    assert message.from.is_bot == false
    assert message.from.supports_guest_queries == true
    assert message.via_bot.can_manage_bots == true

    assert [
             %MessageEntity{type: "bot_command"},
             %MessageEntity{type: "date_time", unix_time: 1_780_000_000}
           ] = message.entities

    assert [%MessageEntity{type: "custom_emoji", custom_emoji_id: "emoji-1"}] =
             message.caption_entities

    assert guest_message.guest_bot_caller_chat.title == "Caller Chat"
    assert guest_message.sender_business_bot.is_bot == true

    refute existing_atom?(unknown_update_key)
    refute existing_atom?(unknown_message_key)
    refute existing_atom?(unknown_user_key)
  end

  test "request decodes fixture-backed reaction getUpdates response" do
    unknown_update_key = "future_reaction_update_field"
    unknown_reaction_key = "future_message_reaction_field"
    unknown_count_key = "future_reaction_count_field"

    refute existing_atom?(unknown_update_key)
    refute existing_atom?(unknown_reaction_key)
    refute existing_atom?(unknown_count_key)

    stub_http_response(
      {:ok,
       %HTTPResponse{
         status_code: 200,
         body: response_fixture("get_updates_reactions.json")
       }}
    )

    assert {:ok,
            [
              %{message_reaction: %MessageReactionUpdated{} = message_reaction},
              %{message_reaction_count: reaction_count}
            ]} = Nadia.get_updates()

    assert message_reaction.chat.title == "Reaction Room"
    assert message_reaction.actor_chat.title == "Anonymous Channel"

    assert [%ReactionType{type: "emoji", emoji: "\u{1F44D}"}] =
             message_reaction.old_reaction

    assert [
             %ReactionCount{
               type: %ReactionType{type: "emoji", emoji: "\u{2764}\u{FE0F}"},
               total_count: 4
             },
             %ReactionCount{type: %ReactionType{type: "custom_emoji"}, total_count: 2},
             %ReactionCount{type: %ReactionType{type: "paid"}, total_count: 1}
           ] = reaction_count.reactions

    refute existing_atom?(unknown_update_key)
    refute existing_atom?(unknown_reaction_key)
    refute existing_atom?(unknown_count_key)
  end

  test "request decodes fixture-backed chat boost getUpdates response" do
    unknown_update_key = "future_chat_boost_outer_field"
    unknown_boost_update_key = "future_chat_boost_update_field"
    unknown_boost_key = "future_chat_boost_field"
    unknown_source_key = "future_chat_boost_source_field"
    unknown_removed_key = "future_removed_chat_boost_field"
    unknown_boost_added_key = "future_boost_added_field"

    refute existing_atom?(unknown_update_key)
    refute existing_atom?(unknown_boost_update_key)
    refute existing_atom?(unknown_boost_key)
    refute existing_atom?(unknown_source_key)
    refute existing_atom?(unknown_removed_key)
    refute existing_atom?(unknown_boost_added_key)

    stub_http_response(
      {:ok,
       %HTTPResponse{
         status_code: 200,
         body: response_fixture("get_updates_chat_boosts.json")
       }}
    )

    assert {:ok,
            [
              %{chat_boost: %ChatBoostUpdated{} = premium_update},
              %{chat_boost: %ChatBoostUpdated{} = giveaway_update},
              %{removed_chat_boost: %ChatBoostRemoved{} = removed_boost},
              %{message: %Message{boost_added: %ChatBoostAdded{} = boost_added}}
            ]} = Nadia.get_updates()

    assert premium_update.boost.boost_id == "boost-premium-1"

    assert %ChatBoostSourcePremium{
             source: "premium",
             user: %User{id: 10001, first_name: "Premium Booster"}
           } = premium_update.boost.source

    assert %ChatBoostSourceGiveaway{
             source: "giveaway",
             giveaway_message_id: 44,
             prize_star_count: 250,
             is_unclaimed: true
           } = giveaway_update.boost.source

    assert removed_boost.boost_id == "boost-gift-code-1"

    assert %ChatBoostSourceGiftCode{
             source: "gift_code",
             user: %User{id: 10003, first_name: "Gift Code Booster"}
           } = removed_boost.source

    assert boost_added.boost_count == 4

    refute existing_atom?(unknown_update_key)
    refute existing_atom?(unknown_boost_update_key)
    refute existing_atom?(unknown_boost_key)
    refute existing_atom?(unknown_source_key)
    refute existing_atom?(unknown_removed_key)
    refute existing_atom?(unknown_boost_added_key)
  end

  test "request decodes fixture-backed paid media getUpdates response" do
    unknown_update_key = "future_paid_media_update_field"
    unknown_message_key = "future_paid_media_message_field"
    unknown_info_key = "future_paid_media_info_field"
    unknown_item_key = "future_paid_media_item_field"
    unknown_purchase_key = "future_paid_media_purchase_field"
    unknown_live_photo_key = "future_live_photo_field"

    refute existing_atom?(unknown_update_key)
    refute existing_atom?(unknown_message_key)
    refute existing_atom?(unknown_info_key)
    refute existing_atom?(unknown_item_key)
    refute existing_atom?(unknown_purchase_key)
    refute existing_atom?(unknown_live_photo_key)

    stub_http_response(
      {:ok,
       %HTTPResponse{
         status_code: 200,
         body: response_fixture("get_updates_paid_media.json")
       }}
    )

    assert {:ok,
            [
              %{message: %Message{paid_media: %PaidMediaInfo{} = paid_media_info}},
              %{purchased_paid_media: %PaidMediaPurchased{} = purchased_paid_media}
            ]} = Nadia.get_updates()

    assert paid_media_info.star_count == 42

    assert [
             %PaidMediaPhoto{photo: [%PhotoSize{file_id: "paid-photo-1"}]},
             %PaidMediaPreview{type: "preview", width: 640, height: 360, duration: 15},
             %PaidMediaVideo{video: %Video{file_id: "paid-video-1"}},
             %PaidMediaLivePhoto{
               type: "live_photo",
               live_photo: %{
                 "file_id" => "paid-live-photo-1",
                 "future_live_photo_field" => "preserved-raw"
               }
             },
             %PaidMedia{type: "future_paid_media"}
           ] = paid_media_info.paid_media

    assert purchased_paid_media.from == %User{
             id: 11001,
             is_bot: false,
             first_name: "Media Buyer",
             language_code: "en"
           }

    assert purchased_paid_media.paid_media_payload == "paid-media-payload-1"

    refute existing_atom?(unknown_update_key)
    refute existing_atom?(unknown_message_key)
    refute existing_atom?(unknown_info_key)
    refute existing_atom?(unknown_item_key)
    refute existing_atom?(unknown_purchase_key)
    refute existing_atom?(unknown_live_photo_key)
  end

  test "request decodes fixture-backed managed bot getUpdates response" do
    unknown_update_key = "future_managed_bot_update_field"
    unknown_message_key = "future_managed_bot_message_field"
    unknown_created_key = "future_managed_bot_created_field"
    unknown_created_bot_key = "future_managed_bot_created_bot_field"
    unknown_updated_key = "future_managed_bot_updated_field"
    unknown_user_key = "future_managed_bot_user_field"
    unknown_bot_key = "future_managed_bot_bot_field"

    refute existing_atom?(unknown_update_key)
    refute existing_atom?(unknown_message_key)
    refute existing_atom?(unknown_created_key)
    refute existing_atom?(unknown_created_bot_key)
    refute existing_atom?(unknown_updated_key)
    refute existing_atom?(unknown_user_key)
    refute existing_atom?(unknown_bot_key)

    stub_http_response(
      {:ok,
       %HTTPResponse{
         status_code: 200,
         body: response_fixture("get_updates_managed_bots.json")
       }}
    )

    assert {:ok,
            [
              %{message: %Message{managed_bot_created: %ManagedBotCreated{} = created}},
              %{managed_bot: %ManagedBotUpdated{} = updated}
            ]} = Nadia.get_updates()

    assert created.bot.username == "created_managed_bot"
    assert created.bot.supports_inline_queries == true
    assert updated.user.can_manage_bots == true
    assert updated.bot.username == "updated_managed_bot"
    assert updated.bot.supports_inline_queries == true

    refute existing_atom?(unknown_update_key)
    refute existing_atom?(unknown_message_key)
    refute existing_atom?(unknown_created_key)
    refute existing_atom?(unknown_created_bot_key)
    refute existing_atom?(unknown_updated_key)
    refute existing_atom?(unknown_user_key)
    refute existing_atom?(unknown_bot_key)
  end

  test "request decodes fixture-backed business/guest getUpdates response" do
    unknown_update_key = "future_business_update_field"
    unknown_connection_key = "future_business_connection_field"
    unknown_rights_key = "future_business_rights_field"
    unknown_chat_key = "future_business_chat_field"
    unknown_guest_message_key = "future_guest_message_field"

    refute existing_atom?(unknown_update_key)
    refute existing_atom?(unknown_connection_key)
    refute existing_atom?(unknown_rights_key)
    refute existing_atom?(unknown_chat_key)
    refute existing_atom?(unknown_guest_message_key)

    stub_http_response(
      {:ok,
       %HTTPResponse{
         status_code: 200,
         body: response_fixture("get_updates_business_guest.json")
       }}
    )

    assert {:ok,
            [
              %{business_connection: %BusinessConnection{} = business_connection},
              %{deleted_business_messages: %BusinessMessagesDeleted{} = deleted_messages},
              %{business_message: %Message{} = business_message},
              %{edited_business_message: %Message{} = edited_business_message},
              %{guest_message: %Message{} = guest_message}
            ]} = Nadia.get_updates()

    assert business_connection.user.first_name == "Business Owner"
    assert business_connection.rights.can_reply == true
    assert business_connection.rights.can_manage_stories == true

    assert %Chat{
             business_intro: %BusinessIntro{
               sticker: %Sticker{file_id: "intro-sticker-1", file_size: 2048}
             },
             business_location: %BusinessLocation{
               location: %Location{latitude: 37.7749, longitude: -122.4194}
             },
             business_opening_hours: %BusinessOpeningHours{
               opening_hours: [
                 %BusinessOpeningHoursInterval{opening_minute: 540},
                 %BusinessOpeningHoursInterval{closing_minute: 2460}
               ]
             }
           } = deleted_messages.chat

    assert deleted_messages.message_ids == [70, 71]
    assert business_message.text == "business hello"
    assert edited_business_message.text == "edited business hello"
    assert guest_message.guest_query_id == "guest-query-business-1"

    refute existing_atom?(unknown_update_key)
    refute existing_atom?(unknown_connection_key)
    refute existing_atom?(unknown_rights_key)
    refute existing_atom?(unknown_chat_key)
    refute existing_atom?(unknown_guest_message_key)
  end

  test "request? parses getBusinessConnection into modeled results" do
    unknown_connection_key = "future_business_connection_api_field"
    unknown_rights_key = "future_business_rights_api_field"

    refute existing_atom?(unknown_connection_key)
    refute existing_atom?(unknown_rights_key)

    stub_http_response(
      {:ok,
       %HTTPResponse{
         status_code: 200,
         body:
           Jason.encode!(%{
             "ok" => true,
             "result" => %{
               "id" => "business-direct-api-1",
               "user" => %{
                 "id" => 13006,
                 "is_bot" => false,
                 "first_name" => "API Owner",
                 "can_connect_to_business" => true
               },
               "user_chat_id" => 777_000_333,
               "date" => 1_780_004_500,
               "rights" => %{
                 "can_reply" => true,
                 "can_read_messages" => true,
                 unknown_rights_key => "ignored"
               },
               "is_enabled" => true,
               unknown_connection_key => "ignored"
             }
           })
       }}
    )

    assert %BusinessConnection{
             id: "business-direct-api-1",
             user: %User{id: 13006, first_name: "API Owner", can_connect_to_business: true},
             user_chat_id: 777_000_333,
             rights: %BusinessBotRights{can_reply: true, can_read_messages: true},
             is_enabled: true
           } =
             API.request?("getBusinessConnection",
               business_connection_id: "business-direct-api-1"
             )

    assert_telegram_request("getBusinessConnection",
      body: {:form, [{"business_connection_id", "business-direct-api-1"}]},
      options: [recv_timeout: 5000]
    )

    refute existing_atom?(unknown_connection_key)
    refute existing_atom?(unknown_rights_key)
  end

  test "request? parses answerGuestQuery into modeled results" do
    unknown_sent_guest_key = "future_sent_guest_message_api_field"

    refute existing_atom?(unknown_sent_guest_key)

    stub_http_response(
      {:ok,
       %HTTPResponse{
         status_code: 200,
         body:
           Jason.encode!(%{
             "ok" => true,
             "result" => %{
               "inline_message_id" => "inline-guest-message-api-1",
               unknown_sent_guest_key => "ignored"
             }
           })
       }}
    )

    assert %SentGuestMessage{inline_message_id: "inline-guest-message-api-1"} =
             API.request?("answerGuestQuery",
               guest_query_id: "guest-query-api-1",
               result: "{\"type\":\"article\"}"
             )

    assert_telegram_request("answerGuestQuery",
      body:
        {:form, [{"guest_query_id", "guest-query-api-1"}, {"result", "{\"type\":\"article\"}"}]},
      options: [recv_timeout: 5000]
    )

    refute existing_atom?(unknown_sent_guest_key)
  end

  test "request? parses getUserChatBoosts into modeled results" do
    stub_http_response(
      {:ok,
       %HTTPResponse{
         status_code: 200,
         body:
           Jason.encode!(%{
             "ok" => true,
             "result" => %{
               "boosts" => [
                 %{
                   "boost_id" => "boost-direct-api-1",
                   "add_date" => 1_780_001_600,
                   "expiration_date" => 1_782_593_600,
                   "source" => %{
                     "source" => "premium",
                     "user" => %{
                       "id" => 10005,
                       "is_bot" => false,
                       "first_name" => "API Booster"
                     }
                   }
                 }
               ]
             }
           })
       }}
    )

    assert %UserChatBoosts{
             boosts: [
               %ChatBoost{
                 boost_id: "boost-direct-api-1",
                 source: %ChatBoostSourcePremium{
                   source: "premium",
                   user: %User{id: 10005, first_name: "API Booster"}
                 }
               }
             ]
           } = API.request?("getUserChatBoosts", chat_id: -1_008_888_888_888, user_id: 10005)

    assert_telegram_request("getUserChatBoosts",
      body: {:form, [{"chat_id", "-1008888888888"}, {"user_id", "10005"}]},
      options: [recv_timeout: 5000]
    )
  end

  test "request? parses getManagedBotAccessSettings into modeled results" do
    unknown_settings_key = "future_bot_access_settings_field"
    unknown_added_user_key = "future_bot_access_added_user_field"

    refute existing_atom?(unknown_settings_key)
    refute existing_atom?(unknown_added_user_key)

    stub_http_response(
      {:ok,
       %HTTPResponse{
         status_code: 200,
         body:
           Jason.encode!(%{
             "ok" => true,
             "result" => %{
               "is_access_restricted" => true,
               "added_users" => [
                 %{
                   "id" => 12004,
                   "is_bot" => false,
                   "first_name" => "Allowed Manager",
                   "can_manage_bots" => true,
                   unknown_added_user_key => "ignored"
                 }
               ],
               unknown_settings_key => "ignored"
             }
           })
       }}
    )

    assert %BotAccessSettings{
             is_access_restricted: true,
             added_users: [
               %User{id: 12004, first_name: "Allowed Manager", can_manage_bots: true}
             ]
           } = API.request?("getManagedBotAccessSettings", user_id: 12004)

    assert_telegram_request("getManagedBotAccessSettings",
      body: {:form, [{"user_id", "12004"}]},
      options: [recv_timeout: 5000]
    )

    refute existing_atom?(unknown_settings_key)
    refute existing_atom?(unknown_added_user_key)
  end

  test "request builds form body from keyword list params" do
    stub_telegram_result(true)

    assert :ok == API.request("sendMessage", chat_id: 123, text: "hello")

    assert_telegram_request("sendMessage",
      body: {:form, [{"chat_id", "123"}, {"text", "hello"}]},
      options: [recv_timeout: 5000]
    )
  end

  test "request JSON-encodes reply markup" do
    stub_telegram_result(true)

    assert :ok ==
             API.request("sendMessage",
               chat_id: 123,
               text: "hello",
               reply_markup: %ReplyKeyboardRemove{selective: true}
             )

    request =
      assert_telegram_request("sendMessage",
        options: [recv_timeout: 5000]
      )

    params = form_params(request)

    assert params["chat_id"] == "123"
    assert params["text"] == "hello"

    assert Jason.decode!(params["reply_markup"]) == %{
             "remove_keyboard" => true,
             "selective" => true
           }
  end

  test "request omits nil params and preserves false params" do
    stub_telegram_result(true)

    assert :ok ==
             API.request("banChatMember",
               chat_id: 123,
               user_id: 456,
               parse_mode: nil,
               reply_markup: nil,
               revoke_messages: false
             )

    request = assert_telegram_request("banChatMember", options: [recv_timeout: 5000])
    params = form_params(request)

    assert params["chat_id"] == "123"
    assert params["user_id"] == "456"
    assert params["revoke_messages"] == "false"
    refute Map.has_key?(params, "parse_mode")
    refute Map.has_key?(params, "reply_markup")
  end

  test "request builds multipart body when file field points to a local file" do
    file_path =
      Path.join(System.tmp_dir!(), "nadia-api-test-#{System.unique_integer([:positive])}.txt")

    File.write!(file_path, "photo")
    on_exit(fn -> File.rm(file_path) end)

    stub_telegram_result(true)

    assert :ok ==
             API.request(
               "sendPhoto",
               [
                 chat_id: 123,
                 photo: file_path,
                 caption: "hello",
                 has_spoiler: false,
                 parse_mode: nil
               ],
               :photo
             )

    request = assert_telegram_request("sendPhoto", options: [recv_timeout: 5000])

    assert {:multipart, parts} = request.body
    assert {"chat_id", "123"} in parts
    assert {"caption", "hello"} in parts
    assert {"has_spoiler", "false"} in parts
    refute Enum.any?(parts, &match?({"parse_mode", _}, &1))

    assert {:file, file_path, {"form-data", [{"name", "photo"}, {"filename", file_path}]}, []} in parts
  end

  test "request includes per-request timeout in HTTP options" do
    stub_telegram_result([])

    assert [] == API.request?("getUpdates", timeout: 2)

    assert_telegram_request("getUpdates",
      body: {:form, [{"timeout", "2"}]},
      options: [recv_timeout: 7000]
    )
  end

  test "request propagates proxy options" do
    proxy = {:http, "localhost", 8080}
    proxy_auth = {"proxy-user", "proxy-password"}

    Application.put_env(:nadia, :proxy, proxy)
    Application.put_env(:nadia, :proxy_auth, proxy_auth)

    stub_telegram_result(true)

    assert :ok == API.request("sendChatAction", chat_id: 123, action: "typing")

    request = assert_telegram_request("sendChatAction")

    assert Keyword.get(request.options, :recv_timeout) == 5000
    assert Keyword.get(request.options, :proxy) == proxy
    assert Keyword.get(request.options, :proxy_auth) == proxy_auth
  end

  test "request/4 uses explicit clients independently of application config" do
    Application.put_env(:nadia, :token, "global-token")
    Application.put_env(:nadia, :recv_timeout, 30)

    bot_a =
      Client.new(
        token: "111:bot-a",
        recv_timeout: 1,
        proxy: "http://bot-a-proxy.test",
        http_client: BotAHTTPClient
      )

    bot_b =
      Client.new(
        token: "222:bot-b",
        recv_timeout: 3,
        proxy_auth: {"bot-b-user", "bot-b-pass"},
        http_client: BotBHTTPClient
      )

    assert :ok ==
             API.request(
               bot_a,
               "sendChatAction",
               [chat_id: 123, action: "typing", timeout: 2],
               nil
             )

    assert :ok == API.request(bot_b, "setWebhook", [url: "https://example.test/webhook"], nil)

    assert_received {:bot_a_request, bot_a_request}
    assert_received {:bot_b_request, bot_b_request}

    assert bot_a_request.url == "https://api.telegram.org/bot111:bot-a/sendChatAction"

    assert bot_a_request.body ==
             {:form, [{"chat_id", "123"}, {"action", "typing"}, {"timeout", "2"}]}

    assert Keyword.get(bot_a_request.options, :recv_timeout) == 3000
    assert Keyword.get(bot_a_request.options, :proxy) == "http://bot-a-proxy.test"
    refute Keyword.has_key?(bot_a_request.options, :proxy_auth)

    assert bot_b_request.url == "https://api.telegram.org/bot222:bot-b/setWebhook"
    assert bot_b_request.body == {:form, [{"url", "https://example.test/webhook"}]}
    assert Keyword.get(bot_b_request.options, :recv_timeout) == 3000
    assert Keyword.get(bot_b_request.options, :proxy_auth) == {"bot-b-user", "bot-b-pass"}
    refute Keyword.has_key?(bot_b_request.options, :proxy)
  end

  test "request/4 builds test environment API URLs" do
    client =
      Client.new(
        token: "123:test-token",
        api_environment: :test,
        http_client: Nadia.HTTPCase.StubHTTPClient
      )

    stub_telegram_result(true)

    assert :ok == API.request(client, "setWebhook", [], nil)

    assert_http_request(
      method: :post,
      url: "https://api.telegram.org/bot123:test-token/test/setWebhook",
      body: {:form, []},
      headers: [],
      options: [recv_timeout: 5000]
    )
  end

  test "request returns :ok for true responses" do
    stub_telegram_result(true)

    assert :ok == API.request("setWebhook")
  end

  test "request normalizes Telegram error responses" do
    stub_telegram_error("Bad Request: chat not found")

    assert {:error, %Error{reason: "Bad Request: chat not found"}} =
             API.request("sendMessage", chat_id: 1, text: "hello")
  end

  test "request normalizes transport errors" do
    stub_transport_error(:timeout)

    assert {:error, %Error{reason: :timeout}} = API.request("getMe")
  end

  test "request normalizes malformed JSON responses" do
    stub_http_response({:ok, %HTTPResponse{status_code: 200, body: "not json"}})

    assert {:error, %Error{reason: %Jason.DecodeError{}}} = API.request("getMe")
  end

  test "build_file_url uses the configured token and default file base URL" do
    assert API.build_file_url("document/file_10") ==
             "https://api.telegram.org/file/bot#{Nadia.Config.token()}/document/file_10"
  end

  test "build_file_url uses custom file base URL" do
    Application.put_env(:nadia, :file_base_url, "https://files.example/bot")

    assert API.build_file_url("document/file_10") ==
             "https://files.example/bot123:test-token/document/file_10"
  end

  test "build_file_url/2 uses explicit client file settings" do
    client =
      Client.new(
        token: "999:file-token",
        file_base_url: "https://files.example/bot"
      )

    assert API.build_file_url(client, "document/file_10") ==
             "https://files.example/bot999:file-token/document/file_10"
  end

  defp existing_atom?(name) do
    _ = String.to_existing_atom(name)
    true
  rescue
    ArgumentError -> false
  end

  defp response_fixture(name) do
    "../fixtures/telegram/responses/#{name}"
    |> Path.expand(__DIR__)
    |> File.read!()
  end
end
