defmodule Nadia.Parser do
  @moduledoc """
  Provides parser logics for API results.
  """

  alias Nadia.Model.User
  alias Nadia.Model.GroupChat
  alias Nadia.Model.Message
  alias Nadia.Model.PhotoSize
  alias Nadia.Model.Audio
  alias Nadia.Model.Document
  alias Nadia.Model.Sticker
  alias Nadia.Model.Video
  alias Nadia.Model.Voice
  alias Nadia.Model.Contact
  alias Nadia.Model.Location
  alias Nadia.Model.Update
  alias Nadia.Model.UserProfilePhotos

  @doc """
  parse from the API response json.
  """
  def parse_result(result, method) do
    case method do
      "getMe" -> parse(User, result)
      "sendChatAction" -> result
      "getUserProfilePhotos" -> parse(UserProfilePhotos, result)
      "getUpdates" -> parse(:updates, result)
      "setWebhook" -> result
      _ -> parse(Message, result)
    end
  end

  @keys_of_message [:message, :reply_to_message]
  @keys_of_photo [:photo, :new_chat_photo]
  @keys_of_user [:from, :forward_from, :new_chat_participant, :left_chat_participant]

  defp parse(:photo, l) when is_list(l), do: Enum.map(l, &(parse(PhotoSize, &1)))
  defp parse(:photos, l) when is_list(l), do: Enum.map(l, &(parse(:photo, &1)))
  defp parse(:updates, l) when is_list(l), do: Enum.map(l, &(parse(Update, &1)))
  defp parse(type, val), do: struct(type, Enum.map(val, &(parse(&1))))
  defp parse({:chat, val = %{title: _}}), do: {:chat, parse(GroupChat, val)}
  defp parse({:chat, val}), do: {:chat, parse(User, val)}
  defp parse({:audio, val}), do: {:audio, parse(Audio, val)}
  defp parse({:video, val}), do: {:video, parse(Video, val)}
  defp parse({:voice, val}), do: {:voice, parse(Voice, val)}
  defp parse({:sticker, val}), do: {:sticker, parse(Sticker, val)}
  defp parse({:document, val}), do: {:document, parse(Document, val)}
  defp parse({:contact, val}), do: {:contact, parse(Contact, val)}
  defp parse({:location, val}), do: {:location, parse(Location, val)}
  defp parse({:thumb, val}), do: {:thumb, parse(PhotoSize, val)}
  defp parse({:photos, val}), do: {:photos, parse(:photos, val)}
  defp parse({key, val}) when key in @keys_of_photo, do: {key, parse(:photo, val)}
  defp parse({key, val}) when key in @keys_of_user, do: {key, parse(User, val)}
  defp parse({key, val}) when key in @keys_of_message, do: {key, parse(Message, val)}
  defp parse(others), do: others
end
