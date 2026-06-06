defmodule Nadia.ParserTest do
  use ExUnit.Case, async: true

  alias Nadia.Parser

  alias Nadia.Model.{
    Update,
    BotAccessSettings,
    Chat,
    ChatBoost,
    ChatBoostAdded,
    ChatBoostRemoved,
    ChatBoostSource,
    ChatBoostSourceGiftCode,
    ChatBoostSourceGiveaway,
    ChatBoostSourcePremium,
    ChatBoostUpdated,
    InlineQuery,
    CallbackQuery,
    ChosenInlineResult,
    User,
    Location,
    PhotoSize,
    UserProfilePhotos,
    Message,
    MessageEntity,
    ManagedBotCreated,
    ManagedBotUpdated,
    MessageReactionCountUpdated,
    MessageReactionUpdated,
    PaidMedia,
    PaidMediaInfo,
    PaidMediaLivePhoto,
    PaidMediaPhoto,
    PaidMediaPreview,
    PaidMediaPurchased,
    PaidMediaVideo,
    Poll,
    PollAnswer,
    PollMedia,
    PollOption,
    PollOptionAdded,
    PollOptionDeleted,
    ReactionCount,
    ReactionType,
    UserChatBoosts,
    Video,
    Venue,
    WebhookInfo
  }

  test "parse result of get_me" do
    me =
      Parser.parse_result(
        %{id: 666, first_name: "Nadia", last_name: nil, username: "nadia_bot"},
        "getMe"
      )

    assert me == %User{id: 666, first_name: "Nadia", last_name: nil, username: "nadia_bot"}
  end

  test "parse result of get_user_profile_photos" do
    user_profile_photos =
      Parser.parse_result(%{photos: [], total_count: 0}, "getUserProfilePhotos")

    assert user_profile_photos == %UserProfilePhotos{photos: [], total_count: 0}

    user_profile_photos =
      Parser.parse_result(
        %{
          photos: [
            [
              %{file_id: "foo", file_size: 100, height: 160, width: 160},
              %{file_id: "bar", file_size: 200, height: 320, width: 320}
            ]
          ],
          total_count: 1
        },
        "getUserProfilePhotos"
      )

    assert user_profile_photos == %UserProfilePhotos{
             photos: [
               [
                 %PhotoSize{file_id: "foo", file_size: 100, height: 160, width: 160},
                 %PhotoSize{file_id: "bar", file_size: 200, height: 320, width: 320}
               ]
             ],
             total_count: 1
           }
  end

  test "parse result of get_updates" do
    raw_updates = [
      %{
        channel_post: %{
          chat: %{id: -1_000_000_000_000, title: "Test Channel", type: "channel"},
          date: 1_508_358_735,
          entities: [
            %{length: 5, offset: 0, type: "bot_command"},
            %{length: 9, offset: 6, type: "mention"}
          ],
          message_id: 5,
          text: "/test @my_test_bot"
        },
        update_id: 790_000_000
      },
      %{
        message: %{
          chat: %{
            first_name: "John",
            id: 440_000_000,
            last_name: "Doe",
            type: "private",
            photo: %{small_file_id: "sid", big_file_id: "bid"}
          },
          date: 1_508_359_228,
          from: %{
            first_name: "John",
            id: 440_000_000,
            is_bot: false,
            language_code: "en-US",
            last_name: "Doe"
          },
          message_id: 3,
          text: "Test"
        },
        update_id: 790_000_001
      }
    ]

    updates = Parser.parse_result(raw_updates, "getUpdates")

    assert updates == [
             %Nadia.Model.Update{
               channel_post: %Nadia.Model.Message{
                 chat: %Nadia.Model.Chat{
                   id: -1_000_000_000_000,
                   title: "Test Channel",
                   type: "channel"
                 },
                 date: 1_508_358_735,
                 entities: [
                   %MessageEntity{length: 5, offset: 0, type: "bot_command"},
                   %MessageEntity{length: 9, offset: 6, type: "mention"}
                 ],
                 message_id: 5,
                 text: "/test @my_test_bot"
               },
               update_id: 790_000_000
             },
             %Nadia.Model.Update{
               message: %Nadia.Model.Message{
                 chat: %Nadia.Model.Chat{
                   first_name: "John",
                   id: 440_000_000,
                   last_name: "Doe",
                   type: "private",
                   photo: %Nadia.Model.ChatPhoto{small_file_id: "sid", big_file_id: "bid"}
                 },
                 date: 1_508_359_228,
                 from: %Nadia.Model.User{
                   first_name: "John",
                   id: 440_000_000,
                   is_bot: false,
                   language_code: "en-US",
                   last_name: "Doe"
                 },
                 message_id: 3,
                 text: "Test"
               },
               update_id: 790_000_001
             }
           ]
  end

  test "parse fixture-backed modern get_updates response decoded with string keys" do
    raw_updates = response_result_fixture("get_updates_modern.json")

    updates = Parser.parse_result(raw_updates, "getUpdates")

    assert [
             %Update{
               update_id: 900_000_001,
               edited_channel_post: %Message{} = edited_channel_post
             },
             %Update{
               update_id: 900_000_002,
               guest_message: %Message{} = guest_message
             }
           ] = updates

    assert edited_channel_post.message_id == 10
    assert edited_channel_post.message_thread_id == 77
    assert edited_channel_post.business_connection_id == "business-connection-1"
    assert edited_channel_post.guest_query_id == "guest-query-1"
    assert edited_channel_post.chat.title == "Release Notes"
    assert edited_channel_post.sender_chat.title == "Release Notes"
    assert edited_channel_post.from.is_bot == false
    assert edited_channel_post.from.language_code == "en"
    assert edited_channel_post.from.supports_guest_queries == true
    assert edited_channel_post.via_bot.can_manage_bots == true
    assert edited_channel_post.guest_bot_caller_user.first_name == "Guest"

    assert [
             %MessageEntity{type: "bot_command", offset: 0, length: 5},
             %MessageEntity{
               type: "date_time",
               offset: 6,
               length: 12,
               unix_time: 1_780_000_000,
               date_time_format: "yyyy-MM-dd HH:mm"
             }
           ] = edited_channel_post.entities

    assert [
             %MessageEntity{
               type: "custom_emoji",
               offset: 0,
               length: 7,
               custom_emoji_id: "emoji-1"
             }
           ] = edited_channel_post.caption_entities

    assert [%User{id: 4004, first_name: "New", language_code: "ja"}] =
             edited_channel_post.new_chat_members

    assert edited_channel_post.reply_markup == %{
             "inline_keyboard" => [
               [
                 %{
                   "text" => "Open",
                   "url" => "https://example.test"
                 }
               ]
             ]
           }

    assert guest_message.guest_query_id == "guest-query-2"
    assert guest_message.guest_bot_caller_chat.title == "Caller Chat"
    assert guest_message.sender_business_bot.is_bot == true
  end

  test "parse fixture-backed poll get_updates response decoded with string keys" do
    raw_updates = response_result_fixture("get_updates_polls.json")

    updates = Parser.parse_result(raw_updates, "getUpdates")

    assert [
             %Update{message: %Message{poll: %Poll{} = message_poll}},
             %Update{poll: %Poll{} = closed_poll},
             %Update{poll_answer: %PollAnswer{} = poll_answer},
             %Update{message: %Message{poll_option_added: %PollOptionAdded{} = added}},
             %Update{message: %Message{poll_option_deleted: %PollOptionDeleted{} = deleted}}
           ] = updates

    assert message_poll.id == "poll-1"
    assert message_poll.allows_multiple_answers == true
    assert message_poll.allows_revoting == true
    assert message_poll.members_only == true
    assert message_poll.country_codes == ["JP", "US"]

    assert [%MessageEntity{type: "bold", offset: 7, length: 7}] =
             message_poll.question_entities

    assert [
             %PollOption{
               persistent_id: "morning",
               text: "Morning",
               voter_count: 3,
               media: %PollMedia{location: %Location{latitude: 35.6812, longitude: 139.7671}},
               added_by_user: %User{id: 7001, first_name: "Poll"},
               added_by_chat: %Chat{title: "Poll Room"},
               addition_date: 1_780_000_201,
               text_entities: [
                 %MessageEntity{
                   type: "custom_emoji",
                   offset: 0,
                   length: 7,
                   custom_emoji_id: "emoji-morning"
                 }
               ]
             },
             %PollOption{persistent_id: "evening", text: "Evening", voter_count: 5}
           ] = message_poll.options

    assert %PollMedia{
             photo: [
               %PhotoSize{
                 file_id: "photo-1",
                 file_unique_id: "photo-uniq-1",
                 width: 320,
                 height: 180,
                 file_size: 12_345
               }
             ]
           } = message_poll.media

    assert [%MessageEntity{type: "italic", offset: 0, length: 10}] =
             message_poll.description_entities

    assert closed_poll.id == "poll-2"
    assert closed_poll.correct_option_ids == [0]
    assert closed_poll.explanation == "Because it is the answer"

    assert [%MessageEntity{type: "bot_command", offset: 0, length: 7}] =
             closed_poll.explanation_entities

    assert %PollMedia{
             venue: %Venue{
               title: "Quiz Hall",
               address: "Example Street",
               location: %Location{latitude: 51.5074, longitude: -0.1278}
             }
           } = closed_poll.explanation_media

    assert poll_answer.poll_id == "poll-1"
    assert poll_answer.user.first_name == "Voter"
    assert poll_answer.voter_chat.title == "Voter Channel"
    assert poll_answer.option_ids == [0, 1]
    assert poll_answer.option_persistent_ids == ["morning", "evening"]

    assert added.poll_message.message_id == 20
    assert added.option_persistent_id == "night"
    assert added.option_text == "Night"
    assert [%MessageEntity{type: "underline"}] = added.option_text_entities

    assert deleted.poll_message.message_id == 20
    assert deleted.option_persistent_id == "evening"
    assert deleted.option_text == "Evening"
    assert [%MessageEntity{type: "strikethrough"}] = deleted.option_text_entities
  end

  test "parse fixture-backed reaction get_updates response decoded with string keys" do
    raw_updates = response_result_fixture("get_updates_reactions.json")

    updates = Parser.parse_result(raw_updates, "getUpdates")

    assert [
             %Update{
               update_id: 900_200_001,
               message_reaction: %MessageReactionUpdated{} = message_reaction
             },
             %Update{
               update_id: 900_200_002,
               message_reaction_count: %MessageReactionCountUpdated{} = reaction_count
             }
           ] = updates

    assert message_reaction.chat.title == "Reaction Room"
    assert message_reaction.message_id == 30
    assert message_reaction.user.first_name == "Reactor"
    assert message_reaction.actor_chat.title == "Anonymous Channel"
    assert message_reaction.date == 1_780_000_600

    assert [%ReactionType{type: "emoji", emoji: "\u{1F44D}"}] =
             message_reaction.old_reaction

    assert [
             %ReactionType{type: "custom_emoji", custom_emoji_id: "custom-reaction-1"},
             %ReactionType{type: "paid"}
           ] = message_reaction.new_reaction

    assert reaction_count.chat.title == "Reaction Room"
    assert reaction_count.message_id == 30

    assert [
             %ReactionCount{
               type: %ReactionType{type: "emoji", emoji: "\u{2764}\u{FE0F}"},
               total_count: 4
             },
             %ReactionCount{
               type: %ReactionType{type: "custom_emoji", custom_emoji_id: "custom-reaction-2"},
               total_count: 2
             },
             %ReactionCount{type: %ReactionType{type: "paid"}, total_count: 1}
           ] = reaction_count.reactions
  end

  test "parse fixture-backed chat boost get_updates response decoded with string keys" do
    raw_updates = response_result_fixture("get_updates_chat_boosts.json")

    updates = Parser.parse_result(raw_updates, "getUpdates")

    assert [
             %Update{
               update_id: 900_300_001,
               chat_boost: %ChatBoostUpdated{} = premium_update
             },
             %Update{
               update_id: 900_300_002,
               chat_boost: %ChatBoostUpdated{} = giveaway_update
             },
             %Update{
               update_id: 900_300_003,
               removed_chat_boost: %ChatBoostRemoved{} = removed_boost
             },
             %Update{
               update_id: 900_300_004,
               message: %Message{boost_added: %ChatBoostAdded{} = boost_added}
             }
           ] = updates

    assert premium_update.chat.title == "Boost Room"
    assert premium_update.boost.boost_id == "boost-premium-1"
    assert premium_update.boost.add_date == 1_780_001_000
    assert premium_update.boost.expiration_date == 1_782_593_000

    assert %ChatBoostSourcePremium{
             source: "premium",
             user: %User{id: 10001, first_name: "Premium Booster"}
           } = premium_update.boost.source

    assert giveaway_update.boost.boost_id == "boost-giveaway-1"

    assert %ChatBoostSourceGiveaway{
             source: "giveaway",
             giveaway_message_id: 44,
             user: %User{id: 10002, first_name: "Giveaway Winner"},
             prize_star_count: 250,
             is_unclaimed: true
           } = giveaway_update.boost.source

    assert removed_boost.chat.title == "Boost Room"
    assert removed_boost.boost_id == "boost-gift-code-1"
    assert removed_boost.remove_date == 1_780_001_200

    assert %ChatBoostSourceGiftCode{
             source: "gift_code",
             user: %User{id: 10003, first_name: "Gift Code Booster"}
           } = removed_boost.source

    assert boost_added.boost_count == 4
  end

  test "parse fixture-backed paid media get_updates response decoded with string keys" do
    raw_updates = response_result_fixture("get_updates_paid_media.json")

    updates = Parser.parse_result(raw_updates, "getUpdates")

    assert [
             %Update{
               update_id: 900_400_001,
               message: %Message{paid_media: %PaidMediaInfo{} = paid_media_info}
             },
             %Update{
               update_id: 900_400_002,
               purchased_paid_media: %PaidMediaPurchased{} = purchased_paid_media
             }
           ] = updates

    assert paid_media_info.star_count == 42

    assert [
             %PaidMediaPhoto{
               type: "photo",
               photo: [
                 %PhotoSize{
                   file_id: "paid-photo-1",
                   file_unique_id: "paid-photo-uniq-1",
                   width: 1280,
                   height: 720,
                   file_size: 54_321
                 }
               ]
             },
             %PaidMediaPreview{type: "preview", width: 640, height: 360, duration: 15},
             %PaidMediaVideo{
               type: "video",
               video: %Video{
                 file_id: "paid-video-1",
                 width: 1920,
                 height: 1080,
                 duration: 24,
                 mime_type: "video/mp4",
                 file_size: 1_234_567
               }
             },
             %PaidMediaLivePhoto{} = paid_media_live_photo,
             %PaidMedia{type: "future_paid_media"}
           ] = paid_media_info.paid_media

    assert paid_media_live_photo.type == "live_photo"

    assert paid_media_live_photo.live_photo == %{
             "file_id" => "paid-live-photo-1",
             "duration" => 3,
             "future_live_photo_field" => "preserved-raw"
           }

    assert purchased_paid_media.from == %User{
             id: 11001,
             is_bot: false,
             first_name: "Media Buyer",
             language_code: "en"
           }

    assert purchased_paid_media.paid_media_payload == "paid-media-payload-1"
  end

  test "parse fixture-backed managed bot get_updates response decoded with string keys" do
    raw_updates = response_result_fixture("get_updates_managed_bots.json")

    updates = Parser.parse_result(raw_updates, "getUpdates")

    assert [
             %Update{
               update_id: 900_500_001,
               message:
                 %Message{
                   managed_bot_created: %ManagedBotCreated{} = managed_bot_created
                 } = message
             },
             %Update{
               update_id: 900_500_002,
               managed_bot: %ManagedBotUpdated{} = managed_bot_updated
             }
           ] = updates

    assert message.chat.title == "Managed Bot Room"

    assert managed_bot_created.bot == %User{
             id: 12001,
             is_bot: true,
             first_name: "Created Managed Bot",
             username: "created_managed_bot",
             supports_inline_queries: true
           }

    assert managed_bot_updated.user == %User{
             id: 12002,
             is_bot: false,
             first_name: "Bot Manager",
             username: "bot_manager",
             can_manage_bots: true
           }

    assert managed_bot_updated.bot == %User{
             id: 12003,
             is_bot: true,
             first_name: "Updated Managed Bot",
             username: "updated_managed_bot",
             supports_inline_queries: true
           }
  end

  test "parse result of get_user_chat_boosts" do
    user_chat_boosts =
      Parser.parse_result(
        %{
          "boosts" => [
            %{
              "boost_id" => "boost-direct-1",
              "add_date" => 1_780_001_400,
              "expiration_date" => 1_782_593_400,
              "source" => %{
                "source" => "premium",
                "user" => %{
                  "id" => 10004,
                  "is_bot" => false,
                  "first_name" => "Direct Booster"
                }
              }
            },
            %{
              "boost_id" => "boost-direct-future",
              "add_date" => 1_780_001_500,
              "expiration_date" => 1_782_593_500,
              "source" => %{
                "source" => "future_source",
                "future_chat_boost_source_field" => "ignored"
              }
            }
          ]
        },
        "getUserChatBoosts"
      )

    assert %UserChatBoosts{
             boosts: [
               %ChatBoost{
                 boost_id: "boost-direct-1",
                 source: %ChatBoostSourcePremium{
                   source: "premium",
                   user: %User{id: 10004, first_name: "Direct Booster"}
                 }
               },
               %ChatBoost{
                 boost_id: "boost-direct-future",
                 source: %ChatBoostSource{source: "future_source"}
               }
             ]
           } = user_chat_boosts
  end

  test "parse result of get_managed_bot_access_settings" do
    settings =
      Parser.parse_result(
        %{
          "is_access_restricted" => true,
          "added_users" => [
            %{
              "id" => 12004,
              "is_bot" => false,
              "first_name" => "Allowed Manager",
              "can_manage_bots" => true
            },
            %{
              "id" => 12005,
              "is_bot" => false,
              "first_name" => "Allowed Auditor",
              "language_code" => "en"
            }
          ]
        },
        "getManagedBotAccessSettings"
      )

    assert %BotAccessSettings{
             is_access_restricted: true,
             added_users: [
               %User{id: 12004, first_name: "Allowed Manager", can_manage_bots: true},
               %User{id: 12005, first_name: "Allowed Auditor", language_code: "en"}
             ]
           } = settings
  end

  test "parse result of stop_poll" do
    poll =
      Parser.parse_result(
        %{
          "id" => "stopped-poll",
          "question" => "Stop?",
          "options" => [
            %{"persistent_id" => "yes", "text" => "Yes", "voter_count" => 1}
          ],
          "total_voter_count" => 1,
          "is_closed" => true,
          "is_anonymous" => false,
          "type" => "regular",
          "allows_multiple_answers" => false,
          "allows_revoting" => false
        },
        "stopPoll"
      )

    assert %Poll{
             id: "stopped-poll",
             is_closed: true,
             options: [%PollOption{persistent_id: "yes", text: "Yes"}]
           } = poll
  end

  test "parse result of get_updates inline query" do
    inline_query =
      Parser.parse_result(
        [
          %{
            inline_query: %{
              id: 111,
              from: %{
                id: 222,
                username: "Rastopyr",
                first_name: "Roman",
                last_name: "Senin"
              },
              location: %{
                latitude: 123,
                longitude: 321
              },
              offset: 0,
              query: "/new-feature"
            }
          }
        ],
        "getUpdates"
      )

    assert inline_query == [
             %Update{
               inline_query: %InlineQuery{
                 id: 111,
                 from: %Nadia.Model.User{
                   id: 222,
                   first_name: "Roman",
                   last_name: "Senin",
                   username: "Rastopyr"
                 },
                 location: %Nadia.Model.Location{
                   latitude: 123,
                   longitude: 321
                 },
                 offset: 0,
                 query: "/new-feature"
               }
             }
           ]
  end

  test "parse result of get_updates callback query" do
    callback_query =
      Parser.parse_result(
        [
          %{
            callback_query: %{
              id: 111,
              data: "111",
              inline_message_id: "111",
              message: %{
                text: "Hello world"
              }
            }
          }
        ],
        "getUpdates"
      )

    assert callback_query == [
             %Update{
               callback_query: %CallbackQuery{
                 id: 111,
                 data: "111",
                 inline_message_id: "111",
                 message: %Message{
                   text: "Hello world"
                 }
               }
             }
           ]
  end

  test "parse result of get_updates chosen inline result" do
    chosen_inline_result =
      Parser.parse_result(
        [
          %{
            chosen_inline_result: %{
              result_id: 111,
              from: %{
                id: 111,
                first_name: "Roman"
              },
              query: "42"
            }
          }
        ],
        "getUpdates"
      )

    assert chosen_inline_result == [
             %Update{
               chosen_inline_result: %ChosenInlineResult{
                 result_id: 111,
                 from: %User{
                   id: 111,
                   first_name: "Roman"
                 },
                 query: "42"
               }
             }
           ]
  end

  test "parse result of get_updates edited_message" do
    raw_updates = [
      %{
        edited_message: %{
          chat: %{first_name: "John", id: 440_000_000, type: "private"},
          date: 1_508_359_228,
          edit_date: 1_508_360_678,
          from: %{first_name: "John", id: 440_000_000, is_bot: false, language_code: "en-US"},
          message_id: 3,
          text: "Edited message"
        },
        update_id: 790_000_001
      }
    ]

    updates = Parser.parse_result(raw_updates, "getUpdates")

    assert updates == [
             %Nadia.Model.Update{
               edited_message: %Nadia.Model.Message{
                 chat: %Nadia.Model.Chat{first_name: "John", id: 440_000_000, type: "private"},
                 date: 1_508_359_228,
                 edit_date: 1_508_360_678,
                 from: %Nadia.Model.User{
                   first_name: "John",
                   id: 440_000_000,
                   is_bot: false,
                   language_code: "en-US"
                 },
                 message_id: 3,
                 text: "Edited message"
               },
               update_id: 790_000_001
             }
           ]
  end

  test "parse result of get_webhook_info" do
    webhook_info =
      Parser.parse_result(
        %{
          allowed_updates: [],
          has_custom_certificate: false,
          last_error_date: nil,
          last_error_message: nil,
          max_connections: 40,
          pending_update_count: 0,
          url: "https://elixir-trading-bot.herokuapp.com/"
        },
        "getWebhookInfo"
      )

    assert webhook_info == %WebhookInfo{
             allowed_updates: [],
             has_custom_certificate: false,
             last_error_date: nil,
             last_error_message: nil,
             max_connections: 40,
             pending_update_count: 0,
             url: "https://elixir-trading-bot.herokuapp.com/"
           }
  end

  defp response_result_fixture(name) do
    "../fixtures/telegram/responses/#{name}"
    |> Path.expand(__DIR__)
    |> File.read!()
    |> Jason.decode!()
    |> Map.fetch!("result")
  end
end
