defmodule Nadia.ParserTest do
  use ExUnit.Case, async: true

  alias Nadia.Parser

  alias Nadia.Model.{
    AffiliateInfo,
    Update,
    Audio,
    BotAccessSettings,
    BotCommand,
    BotDescription,
    BotName,
    BotShortDescription,
    BusinessBotRights,
    BusinessConnection,
    BusinessIntro,
    BusinessLocation,
    BusinessMessagesDeleted,
    BusinessOpeningHours,
    BusinessOpeningHoursInterval,
    Chat,
    ChatAdministratorRights,
    ChatInviteLink,
    ChatJoinRequest,
    ChatBoost,
    ChatBoostAdded,
    ChatBoostRemoved,
    ChatBoostSource,
    ChatBoostSourceGiftCode,
    ChatBoostSourceGiveaway,
    ChatBoostSourcePremium,
    ChatBoostUpdated,
    Checklist,
    ChecklistTask,
    ForumTopic,
    GameHighScore,
    Gift,
    GiftBackground,
    Gifts,
    InlineQuery,
    CallbackQuery,
    ChosenInlineResult,
    User,
    Location,
    Link,
    PhotoSize,
    UserProfilePhotos,
    Message,
    MessageId,
    MessageEntity,
    ManagedBotCreated,
    ManagedBotUpdated,
    MenuButton,
    MenuButtonWebApp,
    MessageReactionCountUpdated,
    MessageReactionUpdated,
    OwnedGift,
    OwnedGiftRegular,
    OwnedGifts,
    OwnedGiftUnique,
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
    PreparedInlineMessage,
    PreparedKeyboardButton,
    ReactionCount,
    ReactionType,
    RevenueWithdrawalState,
    RevenueWithdrawalStateFailed,
    RevenueWithdrawalStatePending,
    RevenueWithdrawalStateSucceeded,
    RichMessage,
    SentGuestMessage,
    SentWebAppMessage,
    StarAmount,
    StarTransaction,
    StarTransactions,
    Story,
    Sticker,
    TransactionPartner,
    TransactionPartnerAffiliateProgram,
    TransactionPartnerChat,
    TransactionPartnerFragment,
    TransactionPartnerOther,
    TransactionPartnerTelegramAds,
    TransactionPartnerTelegramApi,
    TransactionPartnerUser,
    UniqueGift,
    UniqueGiftBackdrop,
    UniqueGiftBackdropColors,
    UniqueGiftColors,
    UniqueGiftModel,
    UniqueGiftSymbol,
    UserChatBoosts,
    UserProfileAudios,
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

  test "parse result of get_my_commands" do
    commands =
      Parser.parse_result(
        [
          %{
            "command" => "start",
            "description" => "Start the bot",
            "future_field" => "ignored"
          },
          %{"command" => "help", "description" => "Show help"}
        ],
        "getMyCommands"
      )

    assert commands == [
             %BotCommand{command: "start", description: "Start the bot"},
             %BotCommand{command: "help", description: "Show help"}
           ]
  end

  test "parse result of bot name and description getters" do
    assert Parser.parse_result(%{"name" => "Nadia"}, "getMyName") == %BotName{name: "Nadia"}

    assert Parser.parse_result(%{"description" => "A helpful bot"}, "getMyDescription") ==
             %BotDescription{description: "A helpful bot"}

    assert Parser.parse_result(%{"short_description" => "Helpful"}, "getMyShortDescription") ==
             %BotShortDescription{short_description: "Helpful"}
  end

  test "parse result of StarAmount balance getters" do
    star_amount =
      Parser.parse_result(
        %{
          "amount" => 42,
          "nanostar_amount" => 123_000_000,
          "future_star_amount_field" => "ignored"
        },
        "getMyStarBalance"
      )

    assert star_amount == %StarAmount{amount: 42, nanostar_amount: 123_000_000}
    refute Map.has_key?(star_amount, :future_star_amount_field)

    assert Parser.parse_result(
             %{amount: -1, nanostar_amount: -500_000_000, future_star_amount_field: "ignored"},
             "getBusinessAccountStarBalance"
           ) == %StarAmount{amount: -1, nanostar_amount: -500_000_000}
  end

  test "parse result of get_star_transactions" do
    gift = %{
      "id" => "gift-star-tx",
      "sticker" => %{
        "file_id" => "gift-star-sticker",
        "width" => 512,
        "height" => 512,
        "star_tx_future_sticker_field" => "ignored"
      },
      "star_count" => 25,
      "star_tx_future_gift_field" => "ignored"
    }

    star_transactions =
      Parser.parse_result(
        %{
          "transactions" => [
            %{
              "id" => "tx-user",
              "amount" => 125,
              "nanostar_amount" => 5,
              "date" => 1_780_010_000,
              "source" => %{
                "type" => "user",
                "transaction_type" => "paid_media_payment",
                "user" => %{
                  "id" => 91_001,
                  "is_bot" => false,
                  "first_name" => "Buyer",
                  "star_tx_future_user_field" => "ignored"
                },
                "affiliate" => %{
                  "affiliate_user" => %{
                    "id" => 91_002,
                    "is_bot" => true,
                    "first_name" => "Affiliate Bot"
                  },
                  "affiliate_chat" => %{
                    "id" => -1001,
                    "type" => "channel",
                    "title" => "Affiliate Channel",
                    "star_tx_future_chat_field" => "ignored"
                  },
                  "commission_per_mille" => 50,
                  "amount" => 6,
                  "nanostar_amount" => 7,
                  "future_affiliate_field" => "ignored"
                },
                "invoice_payload" => "invoice-payload",
                "subscription_period" => 2_592_000,
                "paid_media" => [
                  %{
                    "type" => "photo",
                    "photo" => [
                      %{
                        "file_id" => "paid-photo-1",
                        "width" => 640,
                        "height" => 480,
                        "star_tx_future_photo_field" => "ignored"
                      }
                    ],
                    "star_tx_future_paid_media_field" => "ignored"
                  },
                  %{"type" => "future_media", "star_tx_future_paid_media_field" => "ignored"}
                ],
                "paid_media_payload" => "paid-media-payload",
                "gift" => gift,
                "premium_subscription_duration" => 3,
                "future_user_partner_field" => "ignored"
              },
              "future_transaction_field" => "ignored"
            },
            %{
              "id" => "tx-chat",
              "amount" => -25,
              "date" => 1_780_010_100,
              "receiver" => %{
                "type" => "chat",
                "chat" => %{
                  "id" => -1002,
                  "type" => "channel",
                  "title" => "Gift Chat"
                },
                "gift" => gift,
                "future_chat_partner_field" => "ignored"
              }
            },
            %{
              "id" => "tx-fragment",
              "amount" => -75,
              "date" => 1_780_010_200,
              "source" => %{
                "type" => "fragment",
                "withdrawal_state" => %{
                  "type" => "pending",
                  "future_withdrawal_field" => "ignored"
                }
              },
              "receiver" => %{
                "type" => "fragment",
                "withdrawal_state" => %{
                  "type" => "succeeded",
                  "date" => 1_780_010_300,
                  "url" => "https://fragment.example/tx",
                  "future_withdrawal_field" => "ignored"
                }
              }
            },
            %{
              "id" => "tx-fragment-failed",
              "amount" => -80,
              "date" => 1_780_010_250,
              "receiver" => %{
                "type" => "fragment",
                "withdrawal_state" => %{"type" => "failed"}
              }
            },
            %{
              "id" => "tx-fragment-unknown",
              "amount" => -81,
              "date" => 1_780_010_260,
              "receiver" => %{
                "type" => "fragment",
                "withdrawal_state" => %{"type" => "future_state", "extra" => "ignored"}
              }
            },
            %{
              "id" => "tx-telegram-api",
              "amount" => -3,
              "date" => 1_780_010_400,
              "receiver" => %{
                "type" => "telegram_api",
                "request_count" => 17,
                "future_api_partner_field" => "ignored"
              }
            },
            %{
              "id" => "tx-affiliate-program",
              "amount" => 5,
              "date" => 1_780_010_500,
              "source" => %{
                "type" => "affiliate_program",
                "sponsor_user" => %{
                  "id" => 91_003,
                  "is_bot" => true,
                  "first_name" => "Sponsor Bot"
                },
                "commission_per_mille" => 100
              }
            },
            %{
              "id" => "tx-telegram-ads",
              "amount" => -9,
              "date" => 1_780_010_600,
              "receiver" => %{"type" => "telegram_ads"}
            },
            %{
              "id" => "tx-other",
              "amount" => 1,
              "date" => 1_780_010_700,
              "source" => %{"type" => "other"}
            },
            %{
              "id" => "tx-unknown",
              "amount" => 2,
              "date" => 1_780_010_800,
              "source" => %{
                "type" => "future_partner",
                "future_partner_field" => "ignored"
              }
            }
          ],
          "future_star_transactions_field" => "ignored"
        },
        "getStarTransactions"
      )

    assert %StarTransactions{
             transactions: [
               %StarTransaction{
                 id: "tx-user",
                 source:
                   %TransactionPartnerUser{
                     user: %User{id: 91_001, first_name: "Buyer"},
                     affiliate: %AffiliateInfo{
                       affiliate_user: %User{id: 91_002, first_name: "Affiliate Bot"},
                       affiliate_chat: %Chat{title: "Affiliate Channel"},
                       commission_per_mille: 50,
                       amount: 6,
                       nanostar_amount: 7
                     },
                     paid_media: [
                       %PaidMediaPhoto{photo: [%PhotoSize{file_id: "paid-photo-1"}]},
                       %PaidMedia{type: "future_media"}
                     ],
                     gift: %Gift{
                       id: "gift-star-tx",
                       sticker: %Sticker{file_id: "gift-star-sticker"}
                     }
                   } = user_partner
               } = user_transaction,
               %StarTransaction{
                 receiver:
                   %TransactionPartnerChat{
                     chat: %Chat{title: "Gift Chat"},
                     gift: %Gift{id: "gift-star-tx"}
                   } = chat_partner
               },
               %StarTransaction{
                 source: %TransactionPartnerFragment{
                   withdrawal_state: %RevenueWithdrawalStatePending{} = pending_state
                 },
                 receiver: %TransactionPartnerFragment{
                   withdrawal_state:
                     %RevenueWithdrawalStateSucceeded{
                       date: 1_780_010_300,
                       url: "https://fragment.example/tx"
                     } = succeeded_state
                 }
               },
               %StarTransaction{
                 receiver: %TransactionPartnerFragment{
                   withdrawal_state: %RevenueWithdrawalStateFailed{type: "failed"}
                 }
               },
               %StarTransaction{
                 receiver: %TransactionPartnerFragment{
                   withdrawal_state:
                     %RevenueWithdrawalState{type: "future_state"} =
                       unknown_state
                 }
               },
               %StarTransaction{
                 receiver: %TransactionPartnerTelegramApi{request_count: 17} = api_partner
               },
               %StarTransaction{
                 source: %TransactionPartnerAffiliateProgram{
                   sponsor_user: %User{id: 91_003},
                   commission_per_mille: 100
                 }
               },
               %StarTransaction{receiver: %TransactionPartnerTelegramAds{type: "telegram_ads"}},
               %StarTransaction{source: %TransactionPartnerOther{type: "other"}},
               %StarTransaction{
                 source: %TransactionPartner{type: "future_partner"} = unknown_partner
               }
             ]
           } = star_transactions

    [paid_media_photo | _] = user_partner.paid_media
    [photo_size | _] = paid_media_photo.photo

    refute Map.has_key?(star_transactions, :future_star_transactions_field)
    refute Map.has_key?(user_transaction, :future_transaction_field)
    refute Map.has_key?(user_partner, :future_user_partner_field)
    refute Map.has_key?(user_partner.user, :star_tx_future_user_field)
    refute Map.has_key?(user_partner.affiliate, :future_affiliate_field)
    refute Map.has_key?(user_partner.affiliate.affiliate_chat, :star_tx_future_chat_field)
    refute Map.has_key?(paid_media_photo, :star_tx_future_paid_media_field)
    refute Map.has_key?(photo_size, :star_tx_future_photo_field)
    refute Map.has_key?(user_partner.gift, :star_tx_future_gift_field)
    refute Map.has_key?(user_partner.gift.sticker, :star_tx_future_sticker_field)
    refute Map.has_key?(chat_partner, :future_chat_partner_field)
    refute Map.has_key?(pending_state, :future_withdrawal_field)
    refute Map.has_key?(succeeded_state, :future_withdrawal_field)
    refute Map.has_key?(unknown_state, :extra)
    refute Map.has_key?(api_partner, :future_api_partner_field)
    refute Map.has_key?(unknown_partner, :future_partner_field)
  end

  test "parse result of get_available_gifts" do
    gifts =
      Parser.parse_result(
        %{
          "gifts" => [
            %{
              "id" => "gift-parser-1",
              "sticker" => %{
                "file_id" => "gift-parser-sticker-1",
                "width" => 512,
                "height" => 512,
                "emoji" => "\u{1F381}",
                "future_sticker_field" => "ignored"
              },
              "star_count" => 25,
              "upgrade_star_count" => 50,
              "is_premium" => true,
              "has_colors" => true,
              "total_count" => 100,
              "remaining_count" => 90,
              "personal_total_count" => 5,
              "personal_remaining_count" => 4,
              "background" => %{
                "center_color" => 16_711_680,
                "edge_color" => 16_711_935,
                "text_color" => 16_777_215,
                "future_background_field" => "ignored"
              },
              "unique_gift_variant_count" => 12,
              "publisher_chat" => %{
                "id" => -1_001_111_111_111,
                "type" => "channel",
                "title" => "Gift Publisher",
                "future_chat_field" => "ignored"
              },
              "future_gift_field" => "ignored"
            }
          ],
          "future_gifts_field" => "ignored"
        },
        "getAvailableGifts"
      )

    assert %Gifts{
             gifts: [
               %Gift{
                 id: "gift-parser-1",
                 sticker: %Sticker{file_id: "gift-parser-sticker-1", emoji: "\u{1F381}"},
                 background: %GiftBackground{
                   center_color: 16_711_680,
                   edge_color: 16_711_935,
                   text_color: 16_777_215
                 },
                 publisher_chat: %Chat{title: "Gift Publisher"}
               } = gift
             ]
           } = gifts

    refute Map.has_key?(gifts, :future_gifts_field)
    refute Map.has_key?(gift, :future_gift_field)
    refute Map.has_key?(gift.sticker, :future_sticker_field)
    refute Map.has_key?(gift.background, :future_background_field)
    refute Map.has_key?(gift.publisher_chat, :future_chat_field)
  end

  test "parse result of owned gift getters" do
    raw_owned_gifts = %{
      "total_count" => 3,
      "gifts" => [
        %{
          "type" => "regular",
          "gift" => %{
            "id" => "regular-gift-1",
            "sticker" => %{
              "file_id" => "regular-sticker-1",
              "width" => 512,
              "height" => 512,
              "future_sticker_field" => "ignored"
            },
            "star_count" => 15,
            "background" => %{
              "center_color" => 1,
              "edge_color" => 2,
              "text_color" => 3
            },
            "publisher_chat" => %{
              "id" => -1001,
              "type" => "channel",
              "title" => "Regular Publisher"
            },
            "future_gift_field" => "ignored"
          },
          "owned_gift_id" => "owned-regular-1",
          "sender_user" => %{
            "id" => 91_002,
            "is_bot" => false,
            "first_name" => "Sender",
            "gift_future_user_field" => "ignored"
          },
          "send_date" => 1_780_005_000,
          "text" => "For you",
          "entities" => [
            %{
              "type" => "text_mention",
              "offset" => 0,
              "length" => 3,
              "user" => %{"id" => 91_004, "is_bot" => false, "first_name" => "Mentioned"},
              "future_entity_field" => "ignored"
            }
          ],
          "is_private" => false,
          "is_saved" => true,
          "can_be_upgraded" => true,
          "was_refunded" => false,
          "convert_star_count" => 10,
          "prepaid_upgrade_star_count" => 5,
          "is_upgrade_separate" => false,
          "unique_gift_number" => 7,
          "future_regular_field" => "ignored"
        },
        %{
          "type" => "unique",
          "gift" => %{
            "gift_id" => "base-gift-1",
            "base_name" => "Nadia Gift",
            "name" => "NadiaGift-1",
            "number" => 1,
            "model" => %{
              "name" => "Model",
              "sticker" => %{"file_id" => "model-sticker-1", "width" => 512, "height" => 512},
              "rarity_per_mille" => 10,
              "rarity" => "rare",
              "future_model_field" => "ignored"
            },
            "symbol" => %{
              "name" => "Symbol",
              "sticker" => %{"file_id" => "symbol-sticker-1", "width" => 512, "height" => 512},
              "rarity_per_mille" => 20,
              "future_symbol_field" => "ignored"
            },
            "backdrop" => %{
              "name" => "Backdrop",
              "colors" => %{
                "center_color" => 1,
                "edge_color" => 2,
                "symbol_color" => 3,
                "text_color" => 4,
                "future_backdrop_colors_field" => "ignored"
              },
              "rarity_per_mille" => 30,
              "future_backdrop_field" => "ignored"
            },
            "is_premium" => true,
            "is_burned" => false,
            "is_from_blockchain" => false,
            "colors" => %{
              "model_custom_emoji_id" => "model-emoji",
              "symbol_custom_emoji_id" => "symbol-emoji",
              "light_theme_main_color" => 5,
              "light_theme_other_colors" => [6, 7],
              "dark_theme_main_color" => 8,
              "dark_theme_other_colors" => [9],
              "future_colors_field" => "ignored"
            },
            "publisher_chat" => %{
              "id" => -1002,
              "type" => "channel",
              "title" => "Unique Publisher"
            },
            "future_unique_gift_field" => "ignored"
          },
          "owned_gift_id" => "owned-unique-1",
          "sender_user" => %{"id" => 91_003, "is_bot" => false, "first_name" => "Unique Sender"},
          "send_date" => 1_780_005_100,
          "is_saved" => true,
          "can_be_transferred" => true,
          "transfer_star_count" => 75,
          "next_transfer_date" => 1_780_100_000,
          "future_unique_field" => "ignored"
        },
        %{
          "type" => "future",
          "gift" => %{"id" => "unknown"},
          "future_owned_gift_field" => "ignored"
        }
      ],
      "next_offset" => "owned-next",
      "future_owned_gifts_field" => "ignored"
    }

    for method <- ["getUserGifts", "getChatGifts", "getBusinessAccountGifts"] do
      assert %OwnedGifts{
               total_count: 3,
               next_offset: "owned-next",
               gifts: [
                 %OwnedGiftRegular{
                   gift: %Gift{
                     id: "regular-gift-1",
                     sticker: %Sticker{file_id: "regular-sticker-1"},
                     background: %GiftBackground{center_color: 1},
                     publisher_chat: %Chat{title: "Regular Publisher"}
                   },
                   sender_user: %User{id: 91_002, first_name: "Sender"},
                   entities: [
                     %MessageEntity{
                       type: "text_mention",
                       user: %User{id: 91_004, first_name: "Mentioned"}
                     }
                   ]
                 } = regular,
                 %OwnedGiftUnique{
                   gift: %UniqueGift{
                     model: %UniqueGiftModel{
                       name: "Model",
                       sticker: %Sticker{file_id: "model-sticker-1"}
                     },
                     symbol: %UniqueGiftSymbol{
                       name: "Symbol",
                       sticker: %Sticker{file_id: "symbol-sticker-1"}
                     },
                     backdrop: %UniqueGiftBackdrop{
                       colors: %UniqueGiftBackdropColors{symbol_color: 3}
                     },
                     colors: %UniqueGiftColors{light_theme_other_colors: [6, 7]},
                     publisher_chat: %Chat{title: "Unique Publisher"}
                   },
                   sender_user: %User{id: 91_003, first_name: "Unique Sender"}
                 } = unique,
                 %OwnedGift{type: "future"} = future
               ]
             } = owned_gifts = Parser.parse_result(raw_owned_gifts, method)

      refute Map.has_key?(owned_gifts, :future_owned_gifts_field)
      refute Map.has_key?(regular, :future_regular_field)
      refute Map.has_key?(regular.gift, :future_gift_field)
      refute Map.has_key?(regular.gift.sticker, :future_sticker_field)
      refute Map.has_key?(regular.sender_user, :gift_future_user_field)
      refute Map.has_key?(hd(regular.entities), :future_entity_field)
      refute Map.has_key?(unique, :future_unique_field)
      refute Map.has_key?(unique.gift, :future_unique_gift_field)
      refute Map.has_key?(unique.gift.model, :future_model_field)
      refute Map.has_key?(unique.gift.symbol, :future_symbol_field)
      refute Map.has_key?(unique.gift.backdrop, :future_backdrop_field)
      refute Map.has_key?(unique.gift.backdrop.colors, :future_backdrop_colors_field)
      refute Map.has_key?(unique.gift.colors, :future_colors_field)
      refute Map.has_key?(future, :gift)
      refute Map.has_key?(future, :future_owned_gift_field)
    end
  end

  test "parse result of story methods" do
    raw_story = %{
      "chat" => %{
        "id" => -100_910_010_010,
        "type" => "channel",
        "title" => "Stories",
        "future_chat_field" => "ignored"
      },
      "id" => 51,
      "future_story_field" => "ignored"
    }

    for method <- ["postStory", "editStory", "repostStory"] do
      assert %Story{
               chat: %Chat{
                 id: -100_910_010_010,
                 type: "channel",
                 title: "Stories"
               },
               id: 51
             } = story = Parser.parse_result(raw_story, method)

      refute Map.has_key?(story, :future_story_field)
      refute Map.has_key?(story.chat, :future_chat_field)
    end
  end

  test "parse result of get_chat_menu_button" do
    web_app_button =
      Parser.parse_result(
        %{
          "type" => "web_app",
          "text" => "Open",
          "web_app" => %{"url" => "https://example.test/app"},
          "future_field" => "ignored"
        },
        "getChatMenuButton"
      )

    assert web_app_button == %MenuButtonWebApp{
             type: "web_app",
             text: "Open",
             web_app: %{"url" => "https://example.test/app"}
           }

    assert Parser.parse_result(%{"type" => "future_button"}, "getChatMenuButton") ==
             %MenuButton{type: "future_button"}
  end

  test "parse result of get_my_default_administrator_rights" do
    rights =
      Parser.parse_result(
        %{
          "is_anonymous" => false,
          "can_manage_chat" => true,
          "can_delete_messages" => true,
          "can_manage_video_chats" => true,
          "can_restrict_members" => true,
          "can_promote_members" => false,
          "can_change_info" => true,
          "can_invite_users" => true,
          "can_post_stories" => true,
          "can_edit_stories" => true,
          "can_delete_stories" => true,
          "can_post_messages" => true,
          "can_edit_messages" => true,
          "can_pin_messages" => nil,
          "can_manage_topics" => nil,
          "can_manage_direct_messages" => true,
          "can_manage_tags" => nil,
          "future_field" => "ignored"
        },
        "getMyDefaultAdministratorRights"
      )

    assert rights == %ChatAdministratorRights{
             is_anonymous: false,
             can_manage_chat: true,
             can_delete_messages: true,
             can_manage_video_chats: true,
             can_restrict_members: true,
             can_promote_members: false,
             can_change_info: true,
             can_invite_users: true,
             can_post_stories: true,
             can_edit_stories: true,
             can_delete_stories: true,
             can_post_messages: true,
             can_edit_messages: true,
             can_pin_messages: nil,
             can_manage_topics: nil,
             can_manage_direct_messages: true,
             can_manage_tags: nil
           }
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

  test "parse result of get_user_profile_audios" do
    user_profile_audios =
      Parser.parse_result(
        %{
          "total_count" => 1,
          "audios" => [
            %{
              "file_id" => "profile-audio-1",
              "duration" => 42,
              "performer" => "Nadia",
              "title" => "Coverage",
              "mime_type" => "audio/mpeg",
              "file_size" => 4096,
              "future_audio_field" => "ignored"
            }
          ],
          "future_user_profile_audios_field" => "ignored"
        },
        "getUserProfileAudios"
      )

    assert user_profile_audios == %UserProfileAudios{
             total_count: 1,
             audios: [
               %Audio{
                 file_id: "profile-audio-1",
                 duration: 42,
                 performer: "Nadia",
                 title: "Coverage",
                 mime_type: "audio/mpeg",
                 file_size: 4096
               }
             ]
           }

    refute Map.has_key?(user_profile_audios, :future_user_profile_audios_field)
    refute Map.has_key?(hd(user_profile_audios.audios), :future_audio_field)
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

  test "parse fixture-backed business/guest get_updates response decoded with string keys" do
    raw_updates = response_result_fixture("get_updates_business_guest.json")

    updates = Parser.parse_result(raw_updates, "getUpdates")

    assert [
             %Update{
               update_id: 900_600_001,
               business_connection: %BusinessConnection{} = business_connection
             },
             %Update{
               update_id: 900_600_002,
               deleted_business_messages: %BusinessMessagesDeleted{} = deleted_business_messages
             },
             %Update{
               update_id: 900_600_003,
               business_message: %Message{} = business_message
             },
             %Update{
               update_id: 900_600_004,
               edited_business_message: %Message{} = edited_business_message
             },
             %Update{
               update_id: 900_600_005,
               guest_message: %Message{} = guest_message
             }
           ] = updates

    assert business_connection.id == "business-connection-2"

    assert business_connection.user == %User{
             id: 13001,
             is_bot: false,
             first_name: "Business Owner",
             username: "owner",
             can_connect_to_business: true
           }

    assert business_connection.user_chat_id == 777_000_111
    assert business_connection.date == 1_780_004_000
    assert business_connection.is_enabled == true

    assert %BusinessBotRights{
             can_reply: true,
             can_read_messages: true,
             can_delete_sent_messages: true,
             can_delete_all_messages: true,
             can_edit_name: true,
             can_edit_bio: true,
             can_edit_profile_photo: true,
             can_edit_username: true,
             can_change_gift_settings: true,
             can_view_gifts_and_stars: true,
             can_convert_gifts_to_stars: true,
             can_transfer_and_upgrade_gifts: true,
             can_transfer_stars: true,
             can_manage_stories: true
           } = business_connection.rights

    assert deleted_business_messages.business_connection_id == "business-connection-2"
    assert deleted_business_messages.message_ids == [70, 71]

    assert %Chat{
             title: "Business Chat",
             business_intro: %BusinessIntro{
               title: "Welcome",
               message: "We are open.",
               sticker: %Sticker{
                 file_id: "intro-sticker-1",
                 width: 512,
                 height: 512,
                 emoji: "wave",
                 file_size: 2048
               }
             },
             business_location: %BusinessLocation{
               address: "1 Market Street",
               location: %Location{latitude: 37.7749, longitude: -122.4194}
             },
             business_opening_hours: %BusinessOpeningHours{
               time_zone_name: "America/Los_Angeles",
               opening_hours: [
                 %BusinessOpeningHoursInterval{opening_minute: 540, closing_minute: 1020},
                 %BusinessOpeningHoursInterval{opening_minute: 1980, closing_minute: 2460}
               ]
             }
           } = deleted_business_messages.chat

    assert business_message.business_connection_id == "business-connection-2"
    assert business_message.from == %User{id: 13002, is_bot: false, first_name: "Buyer"}
    assert business_message.text == "business hello"

    assert edited_business_message.business_connection_id == "business-connection-2"
    assert edited_business_message.edit_date == 1_780_004_210
    assert edited_business_message.text == "edited business hello"

    assert guest_message.guest_query_id == "guest-query-business-1"
    assert guest_message.chat == %Chat{id: 13004, type: "private", first_name: "Guest"}
    assert guest_message.text == "guest hello"
  end

  test "parse result of get_business_connection" do
    connection =
      Parser.parse_result(
        %{
          "id" => "business-direct-1",
          "user" => %{
            "id" => 13005,
            "is_bot" => false,
            "first_name" => "Direct Owner",
            "can_connect_to_business" => true
          },
          "user_chat_id" => 777_000_222,
          "date" => 1_780_004_400,
          "rights" => %{
            "can_reply" => true,
            "can_read_messages" => true,
            "future_business_rights_field" => "ignored"
          },
          "is_enabled" => false,
          "future_business_connection_field" => "ignored"
        },
        "getBusinessConnection"
      )

    assert %BusinessConnection{
             id: "business-direct-1",
             user: %User{id: 13005, first_name: "Direct Owner", can_connect_to_business: true},
             user_chat_id: 777_000_222,
             date: 1_780_004_400,
             rights: %BusinessBotRights{can_reply: true, can_read_messages: true},
             is_enabled: false
           } = connection
  end

  test "parse result of answer_guest_query" do
    sent_guest_message =
      Parser.parse_result(
        %{
          "inline_message_id" => "inline-guest-message-1",
          "future_sent_guest_message_field" => "ignored"
        },
        "answerGuestQuery"
      )

    assert %SentGuestMessage{inline_message_id: "inline-guest-message-1"} = sent_guest_message
  end

  test "parse result of answer_web_app_query" do
    sent_web_app_message =
      Parser.parse_result(
        %{
          "inline_message_id" => "inline-web-app-message-1",
          "future_sent_web_app_message_field" => "ignored"
        },
        "answerWebAppQuery"
      )

    assert sent_web_app_message == %SentWebAppMessage{
             inline_message_id: "inline-web-app-message-1"
           }
  end

  test "parse result of save_prepared_inline_message" do
    prepared_inline_message =
      Parser.parse_result(
        %{
          "id" => "prepared-inline-message-1",
          "expiration_date" => 1_800_000_001,
          "future_prepared_inline_message_field" => "ignored"
        },
        "savePreparedInlineMessage"
      )

    assert %PreparedInlineMessage{
             id: "prepared-inline-message-1",
             expiration_date: 1_800_000_001
           } = prepared_inline_message
  end

  test "parse result of save_prepared_keyboard_button" do
    prepared_keyboard_button =
      Parser.parse_result(
        %{
          "id" => "prepared-keyboard-button-1",
          "future_prepared_keyboard_button_field" => "ignored"
        },
        "savePreparedKeyboardButton"
      )

    assert %PreparedKeyboardButton{id: "prepared-keyboard-button-1"} =
             prepared_keyboard_button
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

  test "parse result of create_forum_topic" do
    forum_topic =
      Parser.parse_result(
        %{
          "message_thread_id" => 321,
          "name" => "Release Notes",
          "icon_color" => 7_322_096,
          "icon_custom_emoji_id" => "emoji-topic-1",
          "is_name_implicit" => true,
          "future_forum_topic_field" => "ignored"
        },
        "createForumTopic"
      )

    assert %ForumTopic{
             message_thread_id: 321,
             name: "Release Notes",
             icon_color: 7_322_096,
             icon_custom_emoji_id: "emoji-topic-1",
             is_name_implicit: true
           } = forum_topic
  end

  test "parse result of chat invite link methods" do
    raw_invite_link = %{
      "invite_link" => "https://t.me/+family-n",
      "creator" => %{
        "id" => 4201,
        "is_bot" => true,
        "first_name" => "Nadia",
        "future_chat_invite_creator_field" => "ignored"
      },
      "creates_join_request" => true,
      "is_primary" => false,
      "is_revoked" => false,
      "name" => "Family N",
      "expire_date" => 1_800_000_000,
      "member_limit" => 25,
      "pending_join_request_count" => 2,
      "subscription_period" => 2_592_000,
      "subscription_price" => 150,
      "future_invite_field" => "ignored"
    }

    for method <- [
          "createChatInviteLink",
          "editChatInviteLink",
          "createChatSubscriptionInviteLink",
          "editChatSubscriptionInviteLink",
          "revokeChatInviteLink"
        ] do
      invite_link = Parser.parse_result(raw_invite_link, method)

      assert %ChatInviteLink{
               invite_link: "https://t.me/+family-n",
               creator: %User{id: 4201, is_bot: true, first_name: "Nadia"},
               creates_join_request: true,
               is_primary: false,
               is_revoked: false,
               name: "Family N",
               expire_date: 1_800_000_000,
               member_limit: 25,
               pending_join_request_count: 2,
               subscription_period: 2_592_000,
               subscription_price: 150
             } = invite_link

      refute Map.has_key?(invite_link, :future_invite_field)
      refute Map.has_key?(invite_link.creator, :future_chat_invite_creator_field)
    end

    assert Parser.parse_result("https://t.me/+primary-family-n", "exportChatInviteLink") ==
             "https://t.me/+primary-family-n"
  end

  test "parse result of copy_message" do
    message_id =
      Parser.parse_result(
        %{
          "message_id" => 8801,
          "future_message_id_field" => "ignored"
        },
        "copyMessage"
      )

    assert %MessageId{message_id: 8801} = message_id
  end

  test "parse result of copy_messages and forward_messages" do
    copy_message_ids =
      Parser.parse_result(
        [
          %{"message_id" => 8901, "future_message_id_field" => "ignored"},
          %{"message_id" => 8902}
        ],
        "copyMessages"
      )

    forward_message_ids =
      Parser.parse_result(
        [
          %{"message_id" => 9001},
          %{"message_id" => 9002, "future_message_id_field" => "ignored"}
        ],
        "forwardMessages"
      )

    assert [%MessageId{message_id: 8901}, %MessageId{message_id: 8902}] = copy_message_ids
    assert [%MessageId{message_id: 9001}, %MessageId{message_id: 9002}] = forward_message_ids
  end

  test "parse result of send_media_group" do
    messages =
      Parser.parse_result(
        [
          %{"message_id" => 9101, "chat" => %{"id" => 123, "type" => "private"}},
          %{
            "message_id" => 9102,
            "chat" => %{"id" => 123, "type" => "private"},
            "future_message_field" => "ignored"
          }
        ],
        "sendMediaGroup"
      )

    assert [
             %Message{message_id: 9101, chat: %Chat{id: 123, type: "private"}},
             %Message{message_id: 9102, chat: %Chat{id: 123, type: "private"}}
           ] = messages
  end

  test "parse rich messages and poll link media" do
    message =
      Parser.parse_result(
        %{
          "message_id" => 9503,
          "chat" => %{"id" => 123, "type" => "private"},
          "rich_message" => %{
            "blocks" => [
              %{"type" => "paragraph", "text" => %{"type" => "bold", "text" => "Nadia"}}
            ],
            "is_rtl" => true,
            "future_rich_message_field" => "ignored"
          }
        },
        "sendRichMessage"
      )

    assert %Message{
             message_id: 9503,
             rich_message: %RichMessage{
               blocks: [
                 %{"type" => "paragraph", "text" => %{"type" => "bold", "text" => "Nadia"}}
               ],
               is_rtl: true
             }
           } = message

    poll =
      Parser.parse_result(
        %{
          "id" => "poll-link-1",
          "question" => "Open link?",
          "options" => [],
          "total_voter_count" => 0,
          "is_closed" => false,
          "is_anonymous" => false,
          "type" => "regular",
          "allows_multiple_answers" => false,
          "media" => %{"link" => %{"url" => "https://example.com/poll"}}
        },
        "stopPoll"
      )

    assert %Poll{media: %PollMedia{link: %Link{url: "https://example.com/poll"}}} = poll
  end

  test "parse Message.checklist with task entities and completion actors" do
    message =
      Parser.parse_result(
        %{
          "message_id" => 9601,
          "chat" => %{"id" => 123, "type" => "private"},
          "checklist" => %{
            "title" => "Launch",
            "title_entities" => [%{"type" => "bold", "offset" => 0, "length" => 6}],
            "tasks" => [
              %{
                "id" => 1,
                "text" => "Ship F3",
                "text_entities" => [
                  %{
                    "type" => "text_mention",
                    "offset" => 0,
                    "length" => 4,
                    "user" => %{
                      "id" => 9602,
                      "is_bot" => false,
                      "first_name" => "Mentioned"
                    }
                  }
                ],
                "completed_by_user" => %{
                  "id" => 9603,
                  "is_bot" => false,
                  "first_name" => "Finisher"
                },
                "completed_by_chat" => %{
                  "id" => -1_008_888_888_960,
                  "type" => "supergroup",
                  "title" => "Ops"
                },
                "completion_date" => 1_780_006_000,
                "future_checklist_task_field" => "ignored"
              }
            ],
            "others_can_add_tasks" => true,
            "others_can_mark_tasks_as_done" => true,
            "future_checklist_field" => "ignored"
          }
        },
        "sendChecklist"
      )

    assert %Message{
             message_id: 9601,
             checklist: %Checklist{
               title: "Launch",
               title_entities: [%MessageEntity{type: "bold", offset: 0, length: 6}],
               tasks: [
                 %ChecklistTask{
                   id: 1,
                   text: "Ship F3",
                   text_entities: [
                     %MessageEntity{
                       type: "text_mention",
                       user: %User{id: 9602, first_name: "Mentioned"}
                     }
                   ],
                   completed_by_user: %User{id: 9603, first_name: "Finisher"},
                   completed_by_chat: %Chat{id: -1_008_888_888_960, title: "Ops"},
                   completion_date: 1_780_006_000
                 }
               ],
               others_can_add_tasks: true,
               others_can_mark_tasks_as_done: true
             }
           } = message
  end

  test "parse result of get_forum_topic_icon_stickers" do
    stickers =
      Parser.parse_result(
        [
          %{
            "file_id" => "topic-icon-sticker-1",
            "width" => 512,
            "height" => 512,
            "emoji" => "\u{1F4AC}",
            "future_sticker_field" => "ignored"
          }
        ],
        "getForumTopicIconStickers"
      )

    assert [
             %Sticker{
               file_id: "topic-icon-sticker-1",
               width: 512,
               height: 512,
               emoji: "\u{1F4AC}"
             }
           ] =
             stickers
  end

  test "parse result of get_game_high_scores" do
    game_high_scores =
      Parser.parse_result(
        [
          %{
            "position" => 1,
            "user" => %{
              "id" => 7001,
              "is_bot" => false,
              "first_name" => "Player One",
              "future_user_field" => "ignored"
            },
            "score" => 9000,
            "future_high_score_field" => "ignored"
          }
        ],
        "getGameHighScores"
      )

    assert game_high_scores == [
             %GameHighScore{
               position: 1,
               user: %User{id: 7001, is_bot: false, first_name: "Player One"},
               score: 9000
             }
           ]
  end

  test "parse result of get_custom_emoji_stickers" do
    stickers =
      Parser.parse_result(
        [
          %{
            "file_id" => "custom-emoji-sticker-1",
            "width" => 512,
            "height" => 512,
            "emoji" => "\u{1F680}",
            "set_name" => "nadia_custom_by_bot",
            "future_sticker_field" => "ignored"
          }
        ],
        "getCustomEmojiStickers"
      )

    assert [
             %Sticker{
               file_id: "custom-emoji-sticker-1",
               width: 512,
               height: 512,
               emoji: "\u{1F680}",
               set_name: "nadia_custom_by_bot"
             }
           ] =
             stickers
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

  test "parse result of get_updates chat join request query" do
    raw_updates = [
      %{
        "update_id" => 790_000_002,
        "chat_join_request" => %{
          "chat" => %{"id" => -100_123, "type" => "supergroup", "title" => "Nadia Test"},
          "from" => %{
            "id" => 440_000_001,
            "is_bot" => false,
            "first_name" => "Joiner",
            "supports_join_request_queries" => true
          },
          "user_chat_id" => 440_000_001,
          "date" => 1_508_360_700,
          "bio" => "Please let me in",
          "invite_link" => %{
            "invite_link" => "https://t.me/+join",
            "creator" => %{"id" => 440_000_002, "is_bot" => true, "first_name" => "Guard"}
          },
          "query_id" => "join-query-parser-1",
          "future_join_request_field" => "ignored"
        }
      }
    ]

    assert [
             %Update{
               chat_join_request: %ChatJoinRequest{
                 chat: %Chat{id: -100_123, type: "supergroup", title: "Nadia Test"},
                 from: %User{
                   id: 440_000_001,
                   is_bot: false,
                   first_name: "Joiner",
                   supports_join_request_queries: true
                 },
                 user_chat_id: 440_000_001,
                 date: 1_508_360_700,
                 bio: "Please let me in",
                 invite_link: %ChatInviteLink{
                   invite_link: "https://t.me/+join",
                   creator: %User{id: 440_000_002, is_bot: true, first_name: "Guard"}
                 },
                 query_id: "join-query-parser-1"
               },
               update_id: 790_000_002
             }
           ] = Parser.parse_result(raw_updates, "getUpdates")
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
