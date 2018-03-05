defmodule Nadia.ParserTest do
  use ExUnit.Case, async: true

  alias Nadia.Parser
  alias Nadia.Model.{User, PhotoSize, UserProfilePhotos}

  test "parse result of get_me" do
    me =
      Parser.parse_result(
        %{id: 666, first_name: "Nadia", last_name: nil, username: "nadia_bot"},
        "getMe"
      )

    assert me == %User{id: 666, first_name: "Nadia", last_name: nil, username: "nadia_bot"}
  end

  test "pase result of get_user_profile_photos" do
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

  test "pase result of get_updates" do
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
          chat: %{first_name: "John", id: 440_000_000, last_name: "Doe", type: "private"},
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
                   %{length: 5, offset: 0, type: "bot_command"},
                   %{length: 9, offset: 6, type: "mention"}
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
                   type: "private"
                 },
                 date: 1_508_359_228,
                 from: %Nadia.Model.User{first_name: "John", id: 440_000_000, last_name: "Doe"},
                 message_id: 3,
                 text: "Test"
               },
               update_id: 790_000_001
             }
           ]
  end
end
