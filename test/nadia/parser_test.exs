defmodule Nadia.ParserTest do
  use ExUnit.Case, async: true

  alias Nadia.Parser
  alias Nadia.Model.{User, PhotoSize, UserProfilePhotos}

  test "parse result of get_me" do
    me = Parser.parse_result(%{id: 666, first_name: "Nadia", last_name: nil,
                               username: "nadia_bot"}, "getMe")
    assert me == %User{id: 666, first_name: "Nadia", last_name: nil,
                       username: "nadia_bot"}
  end

  test "pase result of get_user_profile_photos" do
    user_profile_photos = Parser.parse_result(%{photos: [], total_count: 0},
                                              "getUserProfilePhotos")
    assert user_profile_photos == %UserProfilePhotos{photos: [], total_count: 0}

    user_profile_photos = Parser.parse_result(
      %{photos: [[%{file_id: "foo", file_size: 100, height: 160, width: 160},
                  %{file_id: "bar", file_size: 200, height: 320, width: 320}]],
        total_count: 1},
      "getUserProfilePhotos")
    assert user_profile_photos == %UserProfilePhotos{
      photos: [[%PhotoSize{file_id: "foo", file_size: 100, height: 160, width: 160},
                %PhotoSize{file_id: "bar", file_size: 200, height: 320, width: 320}]],
      total_count: 1}
  end
end
