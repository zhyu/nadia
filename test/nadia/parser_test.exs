defmodule Nadia.ParserTest do
  use ExUnit.Case, async: true

  alias Nadia.Parser

  alias Nadia.Model.{
    Update,
    InlineQuery,
    CallbackQuery,
    ChosenInlineResult,
    User,
    PhotoSize,
    UserProfilePhotos,
    Message,
    MessageEntity,
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
