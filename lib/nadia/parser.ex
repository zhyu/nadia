defmodule Nadia.Parser do
  @moduledoc """
  Provides parser logics for API results.
  """

  alias Nadia.Model.{
    User,
    Chat,
    ChatMember,
    Message,
    ChatPhoto,
    PhotoSize,
    Audio,
    Document,
    Sticker,
    InlineQuery,
    ChosenInlineResult
  }

  alias Nadia.Model.{Video, Voice, Contact, Location, Venue, Update, File, CallbackQuery}
  alias Nadia.Model.UserProfilePhotos

  @doc """
  parse `result` field of decoded API response json.
  Args:
  * `result` - `result` field of decoded API response json
  * `method` - name of API method
  """
  def parse_result(result, method) do
    case method do
      "getMe" -> parse(User, result)
      "sendChatAction" -> result
      "getUserProfilePhotos" -> parse(UserProfilePhotos, result)
      "getUpdates" -> parse(:updates, result)
      "setWebhook" -> result
      "getFile" -> parse(File, result)
      "getChat" -> parse(Chat, result)
      "getChatMember" -> parse(ChatMember, result)
      "getChatAdministrators" -> parse(:chat_members, result)
      "getChatMembersCount" -> result
      _ -> parse(Message, result)
    end
  end

  @keys_of_message [:message, :reply_to_message, :channel_post]
  @keys_of_inline_query [:inline_query]
  @keys_of_callback_query [:callback_query]
  @keys_of_choosen_inline_result [:chosen_inline_result]
  @keys_of_photo [:photo, :new_chat_photo]
  @keys_of_user [:from, :forward_from, :new_chat_participant, :left_chat_participant]

  defp parse(:photo, l) when is_list(l), do: Enum.map(l, &parse(PhotoSize, &1))
  defp parse(:photo, p), do: parse(ChatPhoto, p)
  defp parse(:photos, l) when is_list(l), do: Enum.map(l, &parse(:photo, &1))
  defp parse(:updates, l) when is_list(l), do: Enum.map(l, &parse(Update, &1))
  defp parse(:chat_members, l) when is_list(l), do: Enum.map(l, &parse(ChatMember, &1))
  defp parse(type, val), do: struct(type, Enum.map(val, &parse(&1)))
  defp parse({:chat, val}), do: {:chat, parse(Chat, val)}
  defp parse({:audio, val}), do: {:audio, parse(Audio, val)}
  defp parse({:video, val}), do: {:video, parse(Video, val)}
  defp parse({:voice, val}), do: {:voice, parse(Voice, val)}
  defp parse({:sticker, val}), do: {:sticker, parse(Sticker, val)}
  defp parse({:document, val}), do: {:document, parse(Document, val)}
  defp parse({:contact, val}), do: {:contact, parse(Contact, val)}
  defp parse({:location, val}), do: {:location, parse(Location, val)}
  defp parse({:venue, val}), do: {:venue, parse(Venue, val)}
  defp parse({:thumb, val}), do: {:thumb, parse(PhotoSize, val)}
  defp parse({:photos, val}), do: {:photos, parse(:photos, val)}
  defp parse({:callback_query, val}), do: {:callback_query, parse(CallbackQuery, val)}
  defp parse({key, val}) when key in @keys_of_photo, do: {key, parse(:photo, val)}
  defp parse({key, val}) when key in @keys_of_user, do: {key, parse(User, val)}
  defp parse({key, val}) when key in @keys_of_message, do: {key, parse(Message, val)}
  defp parse({key, val}) when key in @keys_of_inline_query, do: {key, parse(InlineQuery, val)}
  defp parse({key, val}) when key in @keys_of_callback_query, do: {key, parse(CallbackQuery, val)}

  defp parse({key, val}) when key in @keys_of_choosen_inline_result,
    do: {key, parse(ChosenInlineResult, val)}

  defp parse(others), do: others
end
