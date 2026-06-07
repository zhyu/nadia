defmodule Nadia.APITest do
  use Nadia.HTTPCase

  doctest Nadia.API

  alias Nadia.API
  alias Nadia.Client
  alias Nadia.HTTPResponse
  alias Nadia.Model.Error
  alias Nadia.Model.InlineQueryResult

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
    Checklist,
    ChecklistTask,
    ForumTopic,
    Message,
    MessageId,
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
    Poll,
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

  defmodule ChatPermissions do
    defstruct [:can_send_messages, :can_send_polls]
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

  test "answer_guest_query/3 builds request and parses sent guest messages" do
    result = %InlineQueryResult.Article{
      id: "guest-article-1",
      title: "Guest reply"
    }

    stub_telegram_result(%{inline_message_id: "inline-guest-message-wrapper-1"})

    assert {:ok, %SentGuestMessage{inline_message_id: "inline-guest-message-wrapper-1"}} =
             Nadia.answer_guest_query("guest-query-wrapper-1", result, future_option: "ready")

    request =
      assert_telegram_request("answerGuestQuery",
        options: [recv_timeout: 5000]
      )

    params = form_params(request)

    assert params["guest_query_id"] == "guest-query-wrapper-1"
    assert params["future_option"] == "ready"

    assert %{
             "type" => "article",
             "id" => "guest-article-1",
             "title" => "Guest reply"
           } = Jason.decode!(params["result"])
  end

  test "get_user_chat_boosts/2 builds request and parses user chat boosts" do
    stub_telegram_result(%{
      boosts: [
        %{
          boost_id: "boost-wrapper-1",
          add_date: 1_780_010_000,
          expiration_date: 1_782_602_000,
          source: %{
            source: "premium",
            user: %{
              id: 10006,
              is_bot: false,
              first_name: "Wrapper Booster"
            }
          }
        }
      ]
    })

    assert {:ok,
            %UserChatBoosts{
              boosts: [
                %ChatBoost{
                  boost_id: "boost-wrapper-1",
                  source: %ChatBoostSourcePremium{
                    user: %User{id: 10006, first_name: "Wrapper Booster"}
                  }
                }
              ]
            }} = Nadia.get_user_chat_boosts(-1_008_888_888_889, 10006)

    assert_telegram_request("getUserChatBoosts",
      body: {:form, [{"chat_id", "-1008888888889"}, {"user_id", "10006"}]},
      options: [recv_timeout: 5000]
    )
  end

  test "get_business_connection/2 explicit client builds request and parses connection" do
    client =
      Client.new(
        token: "999:family-a",
        http_client: Nadia.HTTPCase.StubHTTPClient
      )

    stub_telegram_result(%{
      id: "business-wrapper-1",
      user: %{
        id: 13007,
        is_bot: false,
        first_name: "Explicit Owner"
      },
      user_chat_id: 777_000_444,
      date: 1_780_004_700,
      rights: %{can_reply: true},
      is_enabled: true
    })

    assert {:ok,
            %BusinessConnection{
              id: "business-wrapper-1",
              user: %User{id: 13007, first_name: "Explicit Owner"},
              rights: %BusinessBotRights{can_reply: true},
              is_enabled: true
            }} = Nadia.get_business_connection(client, "business-wrapper-1")

    assert_http_request(
      method: :post,
      url: "https://api.telegram.org/bot999:family-a/getBusinessConnection",
      body: {:form, [{"business_connection_id", "business-wrapper-1"}]},
      headers: [],
      options: [recv_timeout: 5000]
    )
  end

  test "managed bot token wrappers build requests and return string tokens" do
    stub_telegram_result("123:old-managed-token")

    assert {:ok, "123:old-managed-token"} = Nadia.get_managed_bot_token(12001)

    assert_telegram_request("getManagedBotToken",
      body: {:form, [{"user_id", "12001"}]},
      options: [recv_timeout: 5000]
    )

    stub_telegram_result("123:new-managed-token")

    assert {:ok, "123:new-managed-token"} = Nadia.replace_managed_bot_token(12001)

    assert_telegram_request("replaceManagedBotToken",
      body: {:form, [{"user_id", "12001"}]},
      options: [recv_timeout: 5000]
    )
  end

  test "managed bot access settings wrappers build requests and parse settings" do
    stub_telegram_result(%{
      is_access_restricted: true,
      added_users: [
        %{
          id: 12004,
          is_bot: false,
          first_name: "Allowed Manager",
          can_manage_bots: true
        }
      ]
    })

    assert {:ok,
            %BotAccessSettings{
              is_access_restricted: true,
              added_users: [
                %User{id: 12004, first_name: "Allowed Manager", can_manage_bots: true}
              ]
            }} = Nadia.get_managed_bot_access_settings(12004)

    assert_telegram_request("getManagedBotAccessSettings",
      body: {:form, [{"user_id", "12004"}]},
      options: [recv_timeout: 5000]
    )

    stub_telegram_result(true)

    assert :ok ==
             Nadia.set_managed_bot_access_settings(12004, true, added_user_ids: [12004, 12005])

    assert_telegram_request("setManagedBotAccessSettings",
      body:
        {:form,
         [
           {"user_id", "12004"},
           {"is_access_restricted", "true"},
           {"added_user_ids", "[12004,12005]"}
         ]},
      options: [recv_timeout: 5000]
    )

    stub_telegram_result(true)

    assert :ok == Nadia.set_managed_bot_access_settings(12004, false)

    assert_telegram_request("setManagedBotAccessSettings",
      body: {:form, [{"user_id", "12004"}, {"is_access_restricted", "false"}]},
      options: [recv_timeout: 5000]
    )
  end

  test "get_user_personal_chat_messages/2 parses message arrays with nested chat and user" do
    stub_telegram_result([
      %{
        message_id: 91,
        date: 1_780_005_000,
        chat: %{
          id: 13008,
          type: "private",
          first_name: "Personal Chat"
        },
        from: %{
          id: 13009,
          is_bot: false,
          first_name: "Profile Owner"
        },
        text: "profile hello"
      }
    ])

    assert {:ok,
            [
              %Message{
                message_id: 91,
                text: "profile hello",
                chat: %Chat{id: 13008, type: "private", first_name: "Personal Chat"},
                from: %User{id: 13009, is_bot: false, first_name: "Profile Owner"}
              }
            ]} = Nadia.get_user_personal_chat_messages(13009, 1)

    assert_telegram_request("getUserPersonalChatMessages",
      body: {:form, [{"user_id", "13009"}, {"limit", "1"}]},
      options: [recv_timeout: 5000]
    )
  end

  test "delete_messages/2 builds request with JSON message id array" do
    stub_telegram_result(true)

    assert :ok == Nadia.delete_messages(-1_008_888_888_890, [10, 11, 12])

    assert_telegram_request("deleteMessages",
      body: {:form, [{"chat_id", "-1008888888890"}, {"message_ids", "[10,11,12]"}]},
      options: [recv_timeout: 5000]
    )

    client =
      Client.new(
        token: "999:family-b",
        http_client: Nadia.HTTPCase.StubHTTPClient
      )

    assert :ok == Nadia.delete_messages(client, "@cleanup_channel", [20, 21])

    assert_http_request(
      method: :post,
      url: "https://api.telegram.org/bot999:family-b/deleteMessages",
      body: {:form, [{"chat_id", "@cleanup_channel"}, {"message_ids", "[20,21]"}]},
      headers: [],
      options: [recv_timeout: 5000]
    )
  end

  test "delete_message_reaction/3 passes user and actor chat selectors" do
    stub_telegram_result(true)

    assert :ok ==
             Nadia.delete_message_reaction(-1_008_888_888_891, 44,
               user_id: 10010,
               actor_chat_id: -1_008_888_888_892
             )

    assert_telegram_request("deleteMessageReaction",
      body:
        {:form,
         [
           {"chat_id", "-1008888888891"},
           {"message_id", "44"},
           {"user_id", "10010"},
           {"actor_chat_id", "-1008888888892"}
         ]},
      options: [recv_timeout: 5000]
    )
  end

  test "delete_all_message_reactions/2 passes user and actor chat selectors" do
    stub_telegram_result(true)

    assert :ok ==
             Nadia.delete_all_message_reactions("@reaction_room",
               user_id: 10011,
               actor_chat_id: -1_008_888_888_893
             )

    assert_telegram_request("deleteAllMessageReactions",
      body:
        {:form,
         [
           {"chat_id", "@reaction_room"},
           {"user_id", "10011"},
           {"actor_chat_id", "-1008888888893"}
         ]},
      options: [recv_timeout: 5000]
    )
  end

  test "set_message_reaction/3 encodes reaction payload and preserves false is_big" do
    stub_telegram_result(true)

    reactions = [
      %ReactionType{type: "emoji", emoji: "\u{1F44D}"},
      [type: "custom_emoji", custom_emoji_id: "emoji-custom-1"],
      %{type: "emoji", emoji: "\u{1F525}"}
    ]

    encoded_reactions =
      Jason.encode!([
        %{type: "emoji", emoji: "\u{1F44D}"},
        %{type: "custom_emoji", custom_emoji_id: "emoji-custom-1"},
        %{type: "emoji", emoji: "\u{1F525}"}
      ])

    assert :ok ==
             Nadia.set_message_reaction(-1_008_888_888_894, 55,
               reaction: reactions,
               is_big: false
             )

    assert_telegram_request("setMessageReaction",
      body:
        {:form,
         [
           {"chat_id", "-1008888888894"},
           {"message_id", "55"},
           {"reaction", encoded_reactions},
           {"is_big", "false"}
         ]},
      options: [recv_timeout: 5000]
    )
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

  test "existing wrappers with widened option arities build request contracts" do
    stub_telegram_result(message_result(%{message_id: 789}))

    assert {:ok, %Message{message_id: 789}} =
             Nadia.forward_message(123, 456, 789,
               message_thread_id: 10,
               direct_messages_topic_id: 20,
               video_start_timestamp: 30,
               disable_notification: true,
               protect_content: false,
               message_effect_id: "effect-1",
               suggested_post_parameters: "suggested-post-json"
             )

    assert_telegram_request("forwardMessage",
      body:
        {:form,
         [
           {"chat_id", "123"},
           {"from_chat_id", "456"},
           {"message_id", "789"},
           {"message_thread_id", "10"},
           {"direct_messages_topic_id", "20"},
           {"video_start_timestamp", "30"},
           {"disable_notification", "true"},
           {"protect_content", "false"},
           {"message_effect_id", "effect-1"},
           {"suggested_post_parameters", "suggested-post-json"}
         ]},
      options: [recv_timeout: 5000]
    )

    client = Client.new(token: "999:family-c", http_client: Nadia.HTTPCase.StubHTTPClient)

    stub_telegram_result(true)

    assert :ok ==
             Nadia.send_chat_action(client, "@channel", "upload_photo",
               business_connection_id: "business-1",
               message_thread_id: 11
             )

    assert_http_request(
      method: :post,
      url: "https://api.telegram.org/bot999:family-c/sendChatAction",
      body:
        {:form,
         [
           {"chat_id", "@channel"},
           {"action", "upload_photo"},
           {"business_connection_id", "business-1"},
           {"message_thread_id", "11"}
         ]},
      headers: [],
      options: [recv_timeout: 5000]
    )

    stub_telegram_result(true)

    assert :ok == Nadia.delete_webhook(drop_pending_updates: false)

    assert_telegram_request("deleteWebhook",
      body: {:form, [{"drop_pending_updates", "false"}]},
      options: [recv_timeout: 5000]
    )

    stub_telegram_result([%{status: "administrator", user: user_result()}])

    assert {:ok, [_admin]} = Nadia.get_chat_administrators("@group", return_bots: false)

    assert_telegram_request("getChatAdministrators",
      body: {:form, [{"chat_id", "@group"}, {"return_bots", "false"}]},
      options: [recv_timeout: 5000]
    )

    stub_telegram_result(true)

    assert :ok == Nadia.unban_chat_member(123, 456, only_if_banned: false)

    assert_telegram_request("unbanChatMember",
      body: {:form, [{"chat_id", "123"}, {"user_id", "456"}, {"only_if_banned", "false"}]},
      options: [recv_timeout: 5000]
    )

    stub_telegram_result(true)

    assert :ok ==
             Nadia.unpin_chat_message("@channel",
               message_id: 654,
               business_connection_id: "business-1"
             )

    assert_telegram_request("unpinChatMessage",
      body:
        {:form,
         [
           {"chat_id", "@channel"},
           {"message_id", "654"},
           {"business_connection_id", "business-1"}
         ]},
      options: [recv_timeout: 5000]
    )
  end

  test "copy_message/4 builds request, preserves false options, and parses message ids" do
    stub_telegram_result(%{message_id: 8801, future_message_id_field: "ignored"})

    assert {:ok, %MessageId{message_id: 8801}} =
             Nadia.copy_message("@copy_target", -1_008_888_888_900, 41,
               protect_content: false,
               caption: "fresh caption"
             )

    assert_telegram_request("copyMessage",
      body:
        {:form,
         [
           {"chat_id", "@copy_target"},
           {"from_chat_id", "-1008888888900"},
           {"message_id", "41"},
           {"protect_content", "false"},
           {"caption", "fresh caption"}
         ]},
      options: [recv_timeout: 5000]
    )
  end

  test "copy_messages/4 JSON-encodes message ids and supports explicit clients" do
    stub_telegram_result([%{message_id: 8901}, %{message_id: 8902}])

    assert {:ok, [%MessageId{message_id: 8901}, %MessageId{message_id: 8902}]} =
             Nadia.copy_messages(123, 456, [10, 11], remove_caption: false)

    assert_telegram_request("copyMessages",
      body:
        {:form,
         [
           {"chat_id", "123"},
           {"from_chat_id", "456"},
           {"message_ids", "[10,11]"},
           {"remove_caption", "false"}
         ]},
      options: [recv_timeout: 5000]
    )

    client = Client.new(token: "999:family-f1", http_client: Nadia.HTTPCase.StubHTTPClient)

    assert {:ok, [%MessageId{message_id: 8901}, %MessageId{message_id: 8902}]} =
             Nadia.copy_messages(client, "@copy_target", "@copy_source", [12, 14])

    assert_http_request(
      method: :post,
      url: "https://api.telegram.org/bot999:family-f1/copyMessages",
      body:
        {:form,
         [
           {"chat_id", "@copy_target"},
           {"from_chat_id", "@copy_source"},
           {"message_ids", "[12,14]"}
         ]},
      headers: [],
      options: [recv_timeout: 5000]
    )
  end

  test "forward_messages/4 JSON-encodes message ids and parses message id arrays" do
    stub_telegram_result([%{message_id: 9001}, %{message_id: 9002}])

    assert {:ok, [%MessageId{message_id: 9001}, %MessageId{message_id: 9002}]} =
             Nadia.forward_messages(
               -1_008_888_888_901,
               -1_008_888_888_902,
               [20, 22],
               protect_content: false
             )

    assert_telegram_request("forwardMessages",
      body:
        {:form,
         [
           {"chat_id", "-1008888888901"},
           {"from_chat_id", "-1008888888902"},
           {"message_ids", "[20,22]"},
           {"protect_content", "false"}
         ]},
      options: [recv_timeout: 5000]
    )
  end

  test "send_media_group/3 JSON-encodes media arrays and parses message arrays" do
    stub_telegram_result([
      message_result(%{message_id: 9101}),
      message_result(%{message_id: 9102})
    ])

    media = [
      %{type: "photo", media: "photo-file-id", caption: nil},
      [type: "video", media: "video-file-id", supports_streaming: false]
    ]

    encoded_media =
      Jason.encode!([
        %{type: "photo", media: "photo-file-id"},
        %{type: "video", media: "video-file-id", supports_streaming: false}
      ])

    assert {:ok, [%Message{message_id: 9101}, %Message{message_id: 9102}]} =
             Nadia.send_media_group("@album", media, protect_content: false)

    request =
      assert_telegram_request("sendMediaGroup",
        body:
          {:form,
           [
             {"chat_id", "@album"},
             {"media", encoded_media},
             {"protect_content", "false"}
           ]},
        options: [recv_timeout: 5000]
      )

    assert Jason.decode!(form_params(request)["media"]) == [
             %{"type" => "photo", "media" => "photo-file-id"},
             %{"type" => "video", "media" => "video-file-id", "supports_streaming" => false}
           ]

    client = Client.new(token: "999:family-f2", http_client: Nadia.HTTPCase.StubHTTPClient)
    preencoded_media = ~s([{"type":"photo","media":"already-json"}])

    stub_telegram_result([message_result(%{message_id: 9103})])

    assert {:ok, [%Message{message_id: 9103}]} =
             Nadia.send_media_group(client, "@album", preencoded_media)

    assert_http_request(
      method: :post,
      url: "https://api.telegram.org/bot999:family-f2/sendMediaGroup",
      body: {:form, [{"chat_id", "@album"}, {"media", preencoded_media}]},
      headers: [],
      options: [recv_timeout: 5000]
    )
  end

  test "send_paid_media/4 JSON-encodes media arrays and parses messages" do
    stub_telegram_result(message_result(%{message_id: 9201}))

    media = [
      [type: "photo", media: "paid-photo-file-id"],
      %{type: "preview", width: 320, height: nil}
    ]

    encoded_media =
      Jason.encode!([
        %{type: "photo", media: "paid-photo-file-id"},
        %{type: "preview", width: 320}
      ])

    assert {:ok, %Message{message_id: 9201}} =
             Nadia.send_paid_media(123, 25, media,
               payload: "paid-payload-1",
               allow_paid_broadcast: false
             )

    request =
      assert_telegram_request("sendPaidMedia",
        body:
          {:form,
           [
             {"chat_id", "123"},
             {"star_count", "25"},
             {"media", encoded_media},
             {"payload", "paid-payload-1"},
             {"allow_paid_broadcast", "false"}
           ]},
        options: [recv_timeout: 5000]
      )

    assert Jason.decode!(form_params(request)["media"]) == [
             %{"type" => "photo", "media" => "paid-photo-file-id"},
             %{"type" => "preview", "width" => 320}
           ]
  end

  test "send_poll/3 JSON-encodes poll options and preserves false booleans" do
    stub_telegram_result(message_result(%{message_id: 9301}))

    poll_options = [
      [text: "Yes"],
      %{text: "No", text_parse_mode: nil}
    ]

    encoded_options = Jason.encode!([%{text: "Yes"}, %{text: "No"}])

    assert {:ok, %Message{message_id: 9301}} =
             Nadia.send_poll("@polls", "Ship F2?",
               options: poll_options,
               is_anonymous: false,
               allows_multiple_answers: false
             )

    request =
      assert_telegram_request("sendPoll",
        body:
          {:form,
           [
             {"chat_id", "@polls"},
             {"question", "Ship F2?"},
             {"options", encoded_options},
             {"is_anonymous", "false"},
             {"allows_multiple_answers", "false"}
           ]},
        options: [recv_timeout: 5000]
      )

    assert Jason.decode!(form_params(request)["options"]) == [
             %{"text" => "Yes"},
             %{"text" => "No"}
           ]
  end

  test "send video note and live photo wrappers build media file field requests" do
    stub_telegram_result(message_result(%{message_id: 9401}))

    assert {:ok, %Message{message_id: 9401}} =
             Nadia.send_video_note(123, "video-note-file-id",
               duration: 7,
               thumbnail: "thumbnail-file-id"
             )

    assert_telegram_request("sendVideoNote",
      body:
        {:form,
         [
           {"chat_id", "123"},
           {"video_note", "video-note-file-id"},
           {"duration", "7"},
           {"thumbnail", "thumbnail-file-id"}
         ]},
      options: [recv_timeout: 5000]
    )

    stub_telegram_result(message_result(%{message_id: 9402}))

    assert {:ok, %Message{message_id: 9402}} =
             Nadia.send_live_photo("@live", "live-photo-file-id", "cover-photo-file-id",
               caption: "a moment",
               show_caption_above_media: false
             )

    assert_telegram_request("sendLivePhoto",
      body:
        {:form,
         [
           {"chat_id", "@live"},
           {"live_photo", "live-photo-file-id"},
           {"photo", "cover-photo-file-id"},
           {"caption", "a moment"},
           {"show_caption_above_media", "false"}
         ]},
      options: [recv_timeout: 5000]
    )
  end

  test "send_dice and send_message_draft parse message and true responses" do
    stub_telegram_result(message_result(%{message_id: 9501}))

    assert {:ok, %Message{message_id: 9501}} = Nadia.send_dice("@games", emoji: "dice")

    assert_telegram_request("sendDice",
      body: {:form, [{"chat_id", "@games"}, {"emoji", "dice"}]},
      options: [recv_timeout: 5000]
    )

    stub_telegram_result(true)

    assert :ok == Nadia.send_message_draft(123, 44, text: "", parse_mode: nil)

    assert_telegram_request("sendMessageDraft",
      body: {:form, [{"chat_id", "123"}, {"draft_id", "44"}, {"text", ""}]},
      options: [recv_timeout: 5000]
    )
  end

  test "send_checklist/4 JSON-encodes checklist, preserves false options, and parses checklist messages" do
    checklist_response = %{
      title: "Launch",
      title_entities: [%{type: "bold", offset: 0, length: 6}],
      tasks: [
        %{
          id: 1,
          text: "Ship F3",
          text_entities: [%{type: "bold", offset: 0, length: 4}],
          completed_by_user: user_result(),
          completed_by_chat: %{id: -1_008_888_888_960, type: "supergroup", title: "Ops"},
          completion_date: 1_780_006_000
        }
      ],
      others_can_add_tasks: true,
      others_can_mark_tasks_as_done: true
    }

    stub_telegram_result(message_result(%{message_id: 9601, checklist: checklist_response}))

    checklist = [
      title: "Launch",
      title_entities: [[type: "bold", offset: 0, length: 6]],
      tasks: [
        [id: 1, text: "Ship F3", text_entities: [[type: "bold", offset: 0, length: 4]]],
        %{id: 2, text: "Verify", parse_mode: nil}
      ],
      others_can_add_tasks: false,
      others_can_mark_tasks_as_done: true
    ]

    encoded_checklist =
      Jason.encode!(%{
        title: "Launch",
        title_entities: [%{type: "bold", offset: 0, length: 6}],
        tasks: [
          %{id: 1, text: "Ship F3", text_entities: [%{type: "bold", offset: 0, length: 4}]},
          %{id: 2, text: "Verify"}
        ],
        others_can_add_tasks: false,
        others_can_mark_tasks_as_done: true
      })

    assert {:ok,
            %Message{
              message_id: 9601,
              checklist: %Checklist{
                title: "Launch",
                tasks: [
                  %ChecklistTask{
                    id: 1,
                    text: "Ship F3",
                    text_entities: [%MessageEntity{type: "bold"}],
                    completed_by_user: %User{id: 456},
                    completed_by_chat: %Chat{id: -1_008_888_888_960},
                    completion_date: 1_780_006_000
                  }
                ]
              }
            }} =
             Nadia.send_checklist("business-checklist-1", "@checklists", checklist,
               protect_content: false
             )

    request =
      assert_telegram_request("sendChecklist",
        body:
          {:form,
           [
             {"business_connection_id", "business-checklist-1"},
             {"chat_id", "@checklists"},
             {"checklist", encoded_checklist},
             {"protect_content", "false"}
           ]},
        options: [recv_timeout: 5000]
      )

    assert Jason.decode!(form_params(request)["checklist"]) == %{
             "title" => "Launch",
             "title_entities" => [%{"type" => "bold", "offset" => 0, "length" => 6}],
             "tasks" => [
               %{
                 "id" => 1,
                 "text" => "Ship F3",
                 "text_entities" => [%{"type" => "bold", "offset" => 0, "length" => 4}]
               },
               %{"id" => 2, "text" => "Verify"}
             ],
             "others_can_add_tasks" => false,
             "others_can_mark_tasks_as_done" => true
           }

    client = Client.new(token: "999:family-f3", http_client: Nadia.HTTPCase.StubHTTPClient)
    preencoded_checklist = ~s({"title":"Preencoded","tasks":[{"id":1,"text":"Keep"}]})

    stub_telegram_result(message_result(%{message_id: 9602}))

    assert {:ok, %Message{message_id: 9602}} =
             Nadia.send_checklist(
               client,
               "business-checklist-2",
               123,
               preencoded_checklist
             )

    assert_http_request(
      method: :post,
      url: "https://api.telegram.org/bot999:family-f3/sendChecklist",
      body:
        {:form,
         [
           {"business_connection_id", "business-checklist-2"},
           {"chat_id", "123"},
           {"checklist", preencoded_checklist}
         ]},
      headers: [],
      options: [recv_timeout: 5000]
    )
  end

  test "edit_message_media/2 JSON-encodes media and handles edit return shapes" do
    stub_telegram_result(message_result(%{message_id: 9701}))

    media = [
      type: "photo",
      media: "photo-file-id",
      caption: nil,
      show_caption_above_media: false
    ]

    encoded_media =
      Jason.encode!(%{
        type: "photo",
        media: "photo-file-id",
        show_caption_above_media: false
      })

    assert {:ok, %Message{message_id: 9701}} =
             Nadia.edit_message_media(media,
               chat_id: "@updates",
               message_id: 71,
               inline_message_id: nil,
               business_connection_id: "business-g-1"
             )

    request =
      assert_telegram_request("editMessageMedia",
        body:
          {:form,
           [
             {"media", encoded_media},
             {"chat_id", "@updates"},
             {"message_id", "71"},
             {"business_connection_id", "business-g-1"}
           ]},
        options: [recv_timeout: 5000]
      )

    assert Jason.decode!(form_params(request)["media"]) == %{
             "type" => "photo",
             "media" => "photo-file-id",
             "show_caption_above_media" => false
           }

    client = Client.new(token: "999:family-g", http_client: Nadia.HTTPCase.StubHTTPClient)
    preencoded_media = ~s({"type":"video","media":"already-json"})

    stub_telegram_result(true)

    assert :ok =
             Nadia.edit_message_media(client, preencoded_media, inline_message_id: "inline-g-1")

    assert_http_request(
      method: :post,
      url: "https://api.telegram.org/bot999:family-g/editMessageMedia",
      body: {:form, [{"media", preencoded_media}, {"inline_message_id", "inline-g-1"}]},
      headers: [],
      options: [recv_timeout: 5000]
    )
  end

  test "live location update wrappers build request contracts" do
    stub_telegram_result(message_result(%{message_id: 9711}))

    assert {:ok, %Message{message_id: 9711}} =
             Nadia.edit_message_live_location(35.68, 139.76,
               chat_id: "@geo",
               message_id: 33,
               business_connection_id: "business-g-2",
               live_period: 3600
             )

    assert_telegram_request("editMessageLiveLocation",
      body:
        {:form,
         [
           {"latitude", "35.68"},
           {"longitude", "139.76"},
           {"chat_id", "@geo"},
           {"message_id", "33"},
           {"business_connection_id", "business-g-2"},
           {"live_period", "3600"}
         ]},
      options: [recv_timeout: 5000]
    )

    reply_markup = %{inline_keyboard: [[%{text: "Track", callback_data: "track"}]]}
    encoded_reply_markup = Jason.encode!(reply_markup)

    stub_telegram_result(message_result(%{message_id: 9712}))

    assert {:ok, %Message{message_id: 9712}} =
             Nadia.stop_message_live_location(
               inline_message_id: "inline-live-g",
               business_connection_id: "business-g-2",
               reply_markup: reply_markup
             )

    assert_telegram_request("stopMessageLiveLocation",
      body:
        {:form,
         [
           {"inline_message_id", "inline-live-g"},
           {"business_connection_id", "business-g-2"},
           {"reply_markup", encoded_reply_markup}
         ]},
      options: [recv_timeout: 5000]
    )
  end

  test "edit_message_checklist/5 JSON-encodes checklist and parses checklist messages" do
    checklist_response = %{
      title: "Launch update",
      tasks: [
        %{
          id: 1,
          text: "Review",
          completed_by_user: user_result()
        }
      ],
      others_can_add_tasks: false,
      others_can_mark_tasks_as_done: true
    }

    stub_telegram_result(message_result(%{message_id: 9721, checklist: checklist_response}))

    checklist = [
      title: "Launch update",
      tasks: [
        [id: 1, text: "Review", parse_mode: nil],
        %{id: 2, text: "Ship", text_entities: [[type: "bold", offset: 0, length: 4]]}
      ],
      others_can_add_tasks: false,
      others_can_mark_tasks_as_done: true
    ]

    encoded_checklist =
      Jason.encode!(%{
        title: "Launch update",
        tasks: [
          %{id: 1, text: "Review"},
          %{id: 2, text: "Ship", text_entities: [%{type: "bold", offset: 0, length: 4}]}
        ],
        others_can_add_tasks: false,
        others_can_mark_tasks_as_done: true
      })

    reply_markup = %{inline_keyboard: [[%{text: "Done", callback_data: "done"}]]}
    encoded_reply_markup = Jason.encode!(reply_markup)

    assert {:ok,
            %Message{
              message_id: 9721,
              checklist: %Checklist{
                title: "Launch update",
                tasks: [
                  %ChecklistTask{
                    id: 1,
                    text: "Review",
                    completed_by_user: %User{id: 456}
                  }
                ],
                others_can_add_tasks: false,
                others_can_mark_tasks_as_done: true
              }
            }} =
             Nadia.edit_message_checklist(
               "business-g-3",
               "@checklists",
               88,
               checklist,
               reply_markup: reply_markup
             )

    request =
      assert_telegram_request("editMessageChecklist",
        body:
          {:form,
           [
             {"business_connection_id", "business-g-3"},
             {"chat_id", "@checklists"},
             {"message_id", "88"},
             {"checklist", encoded_checklist},
             {"reply_markup", encoded_reply_markup}
           ]},
        options: [recv_timeout: 5000]
      )

    assert Jason.decode!(form_params(request)["checklist"]) == %{
             "title" => "Launch update",
             "tasks" => [
               %{"id" => 1, "text" => "Review"},
               %{
                 "id" => 2,
                 "text" => "Ship",
                 "text_entities" => [%{"type" => "bold", "offset" => 0, "length" => 4}]
               }
             ],
             "others_can_add_tasks" => false,
             "others_can_mark_tasks_as_done" => true
           }
  end

  test "stop_poll/3 builds request and parses stopped polls" do
    reply_markup = %{inline_keyboard: [[%{text: "Close", callback_data: "close"}]]}
    encoded_reply_markup = Jason.encode!(reply_markup)

    stub_telegram_result(%{
      id: "poll-g-1",
      question: "Stop?",
      options: [%{persistent_id: "yes", text: "Yes", voter_count: 1}],
      total_voter_count: 1,
      is_closed: true,
      is_anonymous: false,
      type: "regular",
      allows_multiple_answers: false,
      allows_revoting: false
    })

    assert {:ok, %Poll{id: "poll-g-1", is_closed: true, options: [option]}} =
             Nadia.stop_poll("@polls", 44,
               business_connection_id: "business-g-4",
               reply_markup: reply_markup
             )

    assert option.text == "Yes"

    assert_telegram_request("stopPoll",
      body:
        {:form,
         [
           {"chat_id", "@polls"},
           {"message_id", "44"},
           {"business_connection_id", "business-g-4"},
           {"reply_markup", encoded_reply_markup}
         ]},
      options: [recv_timeout: 5000]
    )
  end

  test "suggested post approval wrappers return ok and pass optional params" do
    stub_telegram_result(true)

    assert :ok == Nadia.approve_suggested_post(777, 91, send_date: 1_780_100_000)

    assert_telegram_request("approveSuggestedPost",
      body:
        {:form,
         [
           {"chat_id", "777"},
           {"message_id", "91"},
           {"send_date", "1780100000"}
         ]},
      options: [recv_timeout: 5000]
    )

    client = Client.new(token: "999:family-g-posts", http_client: Nadia.HTTPCase.StubHTTPClient)

    stub_telegram_result(true)

    assert :ok == Nadia.decline_suggested_post(client, 777, 92, comment: "Needs changes")

    assert_http_request(
      method: :post,
      url: "https://api.telegram.org/bot999:family-g-posts/declineSuggestedPost",
      body:
        {:form,
         [
           {"chat_id", "777"},
           {"message_id", "92"},
           {"comment", "Needs changes"}
         ]},
      headers: [],
      options: [recv_timeout: 5000]
    )
  end

  test "chat administration membership wrappers build request contracts" do
    stub_telegram_result(true)

    restrict_permissions = [can_send_messages: true, can_invite_users: false]
    encoded_restrict_permissions = Jason.encode!(Map.new(restrict_permissions))

    assert :ok ==
             Nadia.restrict_chat_member("@moderated", 42, restrict_permissions,
               use_independent_chat_permissions: true,
               until_date: 1_710_000_000
             )

    request =
      assert_telegram_request("restrictChatMember",
        body:
          {:form,
           [
             {"chat_id", "@moderated"},
             {"user_id", "42"},
             {"permissions", encoded_restrict_permissions},
             {"use_independent_chat_permissions", "true"},
             {"until_date", "1710000000"}
           ]},
        options: [recv_timeout: 5000]
      )

    assert Jason.decode!(form_params(request)["permissions"]) == %{
             "can_send_messages" => true,
             "can_invite_users" => false
           }

    assert :ok ==
             Nadia.promote_chat_member("@moderated", 42,
               can_manage_chat: false,
               can_delete_messages: true,
               can_invite_users: false
             )

    assert_telegram_request("promoteChatMember",
      body:
        {:form,
         [
           {"chat_id", "@moderated"},
           {"user_id", "42"},
           {"can_manage_chat", "false"},
           {"can_delete_messages", "true"},
           {"can_invite_users", "false"}
         ]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.set_chat_administrator_custom_title("@moderated", 42, "Ops Lead")

    assert_telegram_request("setChatAdministratorCustomTitle",
      body: {:form, [{"chat_id", "@moderated"}, {"user_id", "42"}, {"custom_title", "Ops Lead"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.set_chat_member_tag("@direct", 42, tag: "priority")

    assert_telegram_request("setChatMemberTag",
      body: {:form, [{"chat_id", "@direct"}, {"user_id", "42"}, {"tag", "priority"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.ban_chat_sender_chat("@moderated", -100_123)

    assert_telegram_request("banChatSenderChat",
      body: {:form, [{"chat_id", "@moderated"}, {"sender_chat_id", "-100123"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.unban_chat_sender_chat("@moderated", -100_123)

    assert_telegram_request("unbanChatSenderChat",
      body: {:form, [{"chat_id", "@moderated"}, {"sender_chat_id", "-100123"}]},
      options: [recv_timeout: 5000]
    )

    permissions = %ChatPermissions{can_send_messages: true, can_send_polls: false}
    encoded_permissions = Jason.encode!(Map.from_struct(permissions))

    assert :ok ==
             Nadia.set_chat_permissions("@moderated", permissions,
               use_independent_chat_permissions: false
             )

    request =
      assert_telegram_request("setChatPermissions",
        body:
          {:form,
           [
             {"chat_id", "@moderated"},
             {"permissions", encoded_permissions},
             {"use_independent_chat_permissions", "false"}
           ]},
        options: [recv_timeout: 5000]
      )

    decoded_permissions = Jason.decode!(form_params(request)["permissions"])

    assert decoded_permissions == %{
             "can_send_messages" => true,
             "can_send_polls" => false
           }

    refute Map.has_key?(decoded_permissions, "can_invite_users")
  end

  test "chat join and settings true-return wrappers build request contracts" do
    stub_telegram_result(true)

    client = Client.new(token: "999:family-d", http_client: Nadia.HTTPCase.StubHTTPClient)

    assert :ok == Nadia.approve_chat_join_request(client, "@moderated", 42)

    assert_http_request(
      method: :post,
      url: "https://api.telegram.org/bot999:family-d/approveChatJoinRequest",
      body: {:form, [{"chat_id", "@moderated"}, {"user_id", "42"}]},
      headers: [],
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.decline_chat_join_request("@moderated", 43)

    assert_telegram_request("declineChatJoinRequest",
      body: {:form, [{"chat_id", "@moderated"}, {"user_id", "43"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.delete_chat_photo("@moderated")

    assert_telegram_request("deleteChatPhoto",
      body: {:form, [{"chat_id", "@moderated"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.set_chat_title("@moderated", "Moderation Room")

    assert_telegram_request("setChatTitle",
      body: {:form, [{"chat_id", "@moderated"}, {"title", "Moderation Room"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.set_chat_description("@moderated")

    assert_telegram_request("setChatDescription",
      body: {:form, [{"chat_id", "@moderated"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.set_chat_description("@moderated", description: "Quiet ops channel")

    assert_telegram_request("setChatDescription",
      body: {:form, [{"chat_id", "@moderated"}, {"description", "Quiet ops channel"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.unpin_all_chat_messages("@moderated")

    assert_telegram_request("unpinAllChatMessages",
      body: {:form, [{"chat_id", "@moderated"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.set_chat_sticker_set("@moderated", "nadia_mods_by_bot")

    assert_telegram_request("setChatStickerSet",
      body: {:form, [{"chat_id", "@moderated"}, {"sticker_set_name", "nadia_mods_by_bot"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.delete_chat_sticker_set("@moderated")

    assert_telegram_request("deleteChatStickerSet",
      body: {:form, [{"chat_id", "@moderated"}]},
      options: [recv_timeout: 5000]
    )
  end

  test "get_forum_topic_icon_stickers parses sticker arrays and supports explicit clients" do
    client = Client.new(token: "999:family-e", http_client: Nadia.HTTPCase.StubHTTPClient)

    stub_telegram_result([
      %{
        file_id: "topic-icon-sticker-1",
        width: 512,
        height: 512,
        emoji: "\u{1F4AC}",
        file_size: 2048
      }
    ])

    assert {:ok, [%Sticker{file_id: "topic-icon-sticker-1", emoji: "\u{1F4AC}"}]} =
             Nadia.get_forum_topic_icon_stickers()

    assert_telegram_request("getForumTopicIconStickers",
      body: {:form, []},
      options: [recv_timeout: 5000]
    )

    assert {:ok, [%Sticker{file_id: "topic-icon-sticker-1", emoji: "\u{1F4AC}"}]} =
             Nadia.get_forum_topic_icon_stickers(client)

    assert_http_request(
      method: :post,
      url: "https://api.telegram.org/bot999:family-e/getForumTopicIconStickers",
      body: {:form, []},
      headers: [],
      options: [recv_timeout: 5000]
    )
  end

  test "create_forum_topic/3 builds request and parses forum topics" do
    stub_telegram_result(%{
      message_thread_id: 321,
      name: "Release Notes",
      icon_color: 7_322_096,
      icon_custom_emoji_id: "emoji-topic-1",
      is_name_implicit: true
    })

    assert {:ok,
            %ForumTopic{
              message_thread_id: 321,
              name: "Release Notes",
              icon_color: 7_322_096,
              icon_custom_emoji_id: "emoji-topic-1",
              is_name_implicit: true
            }} =
             Nadia.create_forum_topic("@forum", "Release Notes",
               icon_color: 7_322_096,
               icon_custom_emoji_id: "emoji-topic-1"
             )

    assert_telegram_request("createForumTopic",
      body:
        {:form,
         [
           {"chat_id", "@forum"},
           {"name", "Release Notes"},
           {"icon_color", "7322096"},
           {"icon_custom_emoji_id", "emoji-topic-1"}
         ]},
      options: [recv_timeout: 5000]
    )
  end

  test "forum topic true-return wrappers build request contracts" do
    stub_telegram_result(true)

    assert :ok == Nadia.edit_forum_topic("@forum", 321)

    assert_telegram_request("editForumTopic",
      body: {:form, [{"chat_id", "@forum"}, {"message_thread_id", "321"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok ==
             Nadia.edit_forum_topic("@forum", 321,
               name: "Release Discussion",
               icon_custom_emoji_id: ""
             )

    assert_telegram_request("editForumTopic",
      body:
        {:form,
         [
           {"chat_id", "@forum"},
           {"message_thread_id", "321"},
           {"name", "Release Discussion"},
           {"icon_custom_emoji_id", ""}
         ]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.close_forum_topic("@forum", 321)

    assert_telegram_request("closeForumTopic",
      body: {:form, [{"chat_id", "@forum"}, {"message_thread_id", "321"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.reopen_forum_topic("@forum", 321)

    assert_telegram_request("reopenForumTopic",
      body: {:form, [{"chat_id", "@forum"}, {"message_thread_id", "321"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.delete_forum_topic("@forum", 321)

    assert_telegram_request("deleteForumTopic",
      body: {:form, [{"chat_id", "@forum"}, {"message_thread_id", "321"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.unpin_all_forum_topic_messages("@forum", 321)

    assert_telegram_request("unpinAllForumTopicMessages",
      body: {:form, [{"chat_id", "@forum"}, {"message_thread_id", "321"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.edit_general_forum_topic("@forum", "General Chat")

    assert_telegram_request("editGeneralForumTopic",
      body: {:form, [{"chat_id", "@forum"}, {"name", "General Chat"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.close_general_forum_topic("@forum")

    assert_telegram_request("closeGeneralForumTopic",
      body: {:form, [{"chat_id", "@forum"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.reopen_general_forum_topic("@forum")

    assert_telegram_request("reopenGeneralForumTopic",
      body: {:form, [{"chat_id", "@forum"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.hide_general_forum_topic("@forum")

    assert_telegram_request("hideGeneralForumTopic",
      body: {:form, [{"chat_id", "@forum"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.unhide_general_forum_topic("@forum")

    assert_telegram_request("unhideGeneralForumTopic",
      body: {:form, [{"chat_id", "@forum"}]},
      options: [recv_timeout: 5000]
    )

    assert :ok == Nadia.unpin_all_general_forum_topic_messages("@forum")

    assert_telegram_request("unpinAllGeneralForumTopicMessages",
      body: {:form, [{"chat_id", "@forum"}]},
      options: [recv_timeout: 5000]
    )
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

  defp message_result(overrides) do
    Map.merge(
      %{
        message_id: 1,
        date: 1_700_000_000,
        chat: %{id: 123, type: "private", username: "nadia_test"},
        from: user_result()
      },
      overrides
    )
  end

  defp user_result do
    %{id: 456, first_name: "Nadia", username: "nadia_test"}
  end
end
