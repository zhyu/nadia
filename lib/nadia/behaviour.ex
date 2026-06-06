defmodule Nadia.Behaviour do
  alias Nadia.Client

  alias Nadia.Model.{
    BotAccessSettings,
    BusinessConnection,
    Chat,
    ChatMember,
    Error,
    File,
    Message,
    SentGuestMessage,
    Update,
    User,
    UserChatBoosts,
    UserProfilePhotos,
    WebhookInfo
  }

  @callback get_me :: {:ok, User.t()} | {:error, Error.t()}
  @callback get_me(Client.t()) :: {:ok, User.t()} | {:error, Error.t()}
  @callback send_message(integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_message(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback forward_message(integer | binary, integer | binary, integer) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback forward_message(integer | binary, integer | binary, integer, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback forward_message(Client.t(), integer | binary, integer | binary, integer) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback forward_message(Client.t(), integer | binary, integer | binary, integer, [
              {atom, any}
            ]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_photo(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_photo(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_audio(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_audio(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_document(integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_document(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_sticker(integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_sticker(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_video(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_video(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_voice(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_voice(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_animation(integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_animation(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_location(integer, float, float, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_location(Client.t(), integer | binary, float, float, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_venue(integer, float, float, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_venue(Client.t(), integer | binary, float, float, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_contact(integer, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_contact(Client.t(), integer | binary, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_chat_action(integer | binary, binary) :: :ok | {:error, Error.t()}
  @callback send_chat_action(integer | binary, binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback send_chat_action(Client.t(), integer | binary, binary) :: :ok | {:error, Error.t()}
  @callback send_chat_action(Client.t(), integer | binary, binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback get_user_profile_photos(integer, [{atom, any}]) ::
              {:ok, UserProfilePhotos.t()} | {:error, Error.t()}
  @callback get_user_profile_photos(Client.t(), integer, [{atom, any}]) ::
              {:ok, UserProfilePhotos.t()} | {:error, Error.t()}
  @callback get_updates([{atom, any}]) :: {:ok, [Update.t()]} | {:error, Error.t()}
  @callback get_updates(Client.t(), [{atom, any}]) :: {:ok, [Update.t()]} | {:error, Error.t()}
  @callback set_webhook([{atom, any}]) :: :ok | {:error, Error.t()}
  @callback set_webhook(Client.t(), [{atom, any}]) :: :ok | {:error, Error.t()}
  @callback delete_webhook() :: :ok | {:error, Error.t()}
  @callback delete_webhook([{atom, any}]) :: :ok | {:error, Error.t()}
  @callback delete_webhook(Client.t()) :: :ok | {:error, Error.t()}
  @callback delete_webhook(Client.t(), [{atom, any}]) :: :ok | {:error, Error.t()}
  @callback get_webhook_info(Client.t()) :: {:ok, WebhookInfo.t()} | {:error, Error.t()}
  @callback get_file(binary) :: {:ok, File.t()} | {:error, Error.t()}
  @callback get_file(Client.t(), binary) :: {:ok, File.t()} | {:error, Error.t()}
  @callback get_file_link(File.t()) :: {:ok, binary} | {:error, Error.t()}
  @callback get_file_link(Client.t(), File.t()) :: {:ok, binary} | {:error, Error.t()}
  @callback ban_chat_member(integer | binary, integer) :: :ok | {:error, Error.t()}
  @callback ban_chat_member(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
  @callback leave_chat(integer | binary) :: :ok | {:error, Error.t()}
  @callback leave_chat(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
  @callback unban_chat_member(integer | binary, integer) :: :ok | {:error, Error.t()}
  @callback unban_chat_member(integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback unban_chat_member(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
  @callback unban_chat_member(Client.t(), integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback get_chat(integer | binary) :: {:ok, Chat.t()} | {:error, Error.t()}
  @callback get_chat(Client.t(), integer | binary) :: {:ok, Chat.t()} | {:error, Error.t()}
  @callback get_chat_administrators(integer | binary) ::
              {:ok, [ChatMember.t()]} | {:error, Error.t()}
  @callback get_chat_administrators(integer | binary, [{atom, any}]) ::
              {:ok, [ChatMember.t()]} | {:error, Error.t()}
  @callback get_chat_administrators(Client.t(), integer | binary) ::
              {:ok, [ChatMember.t()]} | {:error, Error.t()}
  @callback get_chat_administrators(Client.t(), integer | binary, [{atom, any}]) ::
              {:ok, [ChatMember.t()]} | {:error, Error.t()}
  @callback get_chat_member_count(integer | binary) :: {:ok, integer} | {:error, Error.t()}
  @callback get_chat_member_count(Client.t(), integer | binary) ::
              {:ok, integer} | {:error, Error.t()}
  @callback get_chat_member(integer | binary, integer) ::
              {:ok, ChatMember.t()} | {:error, Error.t()}
  @callback get_chat_member(Client.t(), integer | binary, integer) ::
              {:ok, ChatMember.t()} | {:error, Error.t()}
  @callback get_user_chat_boosts(integer | binary, integer) ::
              {:ok, UserChatBoosts.t()} | {:error, Error.t()}
  @callback get_user_chat_boosts(Client.t(), integer | binary, integer) ::
              {:ok, UserChatBoosts.t()} | {:error, Error.t()}
  @callback get_business_connection(binary) :: {:ok, BusinessConnection.t()} | {:error, Error.t()}
  @callback get_business_connection(Client.t(), binary) ::
              {:ok, BusinessConnection.t()} | {:error, Error.t()}
  @callback get_managed_bot_token(integer) :: {:ok, binary} | {:error, Error.t()}
  @callback get_managed_bot_token(Client.t(), integer) :: {:ok, binary} | {:error, Error.t()}
  @callback replace_managed_bot_token(integer) :: {:ok, binary} | {:error, Error.t()}
  @callback replace_managed_bot_token(Client.t(), integer) :: {:ok, binary} | {:error, Error.t()}
  @callback get_managed_bot_access_settings(integer) ::
              {:ok, BotAccessSettings.t()} | {:error, Error.t()}
  @callback get_managed_bot_access_settings(Client.t(), integer) ::
              {:ok, BotAccessSettings.t()} | {:error, Error.t()}
  @callback set_managed_bot_access_settings(integer, boolean, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback set_managed_bot_access_settings(Client.t(), integer, boolean, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback get_user_personal_chat_messages(integer, integer) ::
              {:ok, [Message.t()]} | {:error, Error.t()}
  @callback get_user_personal_chat_messages(Client.t(), integer, integer) ::
              {:ok, [Message.t()]} | {:error, Error.t()}
  @callback delete_messages(integer | binary, [integer]) :: :ok | {:error, Error.t()}
  @callback delete_messages(Client.t(), integer | binary, [integer]) ::
              :ok | {:error, Error.t()}
  @callback delete_message_reaction(integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback delete_message_reaction(Client.t(), integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback delete_all_message_reactions(integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback delete_all_message_reactions(Client.t(), integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback set_message_reaction(integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback set_message_reaction(Client.t(), integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback answer_callback_query(binary, [{atom, any}]) :: :ok | {:error, Error.t()}
  @callback answer_callback_query(Client.t(), binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback answer_guest_query(binary, Nadia.Model.InlineQueryResult.t(), [{atom, any}]) ::
              {:ok, SentGuestMessage.t()} | {:error, Error.t()}
  @callback answer_guest_query(Client.t(), binary, Nadia.Model.InlineQueryResult.t(), [
              {atom, any}
            ]) ::
              {:ok, SentGuestMessage.t()} | {:error, Error.t()}
  @callback edit_message_text(integer | binary, integer, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_text(Client.t(), integer | binary, integer, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_caption(integer | binary, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_caption(Client.t(), integer | binary, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_reply_markup(integer | binary, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_reply_markup(Client.t(), integer | binary, integer, binary, [
              {atom, any}
            ]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback answer_inline_query(binary, [Nadia.Model.InlineQueryResult.t()], [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback answer_inline_query(Client.t(), binary, [Nadia.Model.InlineQueryResult.t()], [
              {atom, any}
            ]) ::
              :ok | {:error, Error.t()}
  @callback get_sticker_set(Client.t(), binary) ::
              {:ok, Nadia.Model.StickerSet.t()} | {:error, Error.t()}
  @callback upload_sticker_file(Client.t(), integer, binary) ::
              {:ok, File.t()} | {:error, Error.t()}
  @callback create_new_sticker_set(Client.t(), integer, binary, binary, binary, binary, [
              {atom, any}
            ]) ::
              :ok | {:error, Error.t()}
  @callback add_sticker_to_set(Client.t(), integer, binary, binary, binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback set_sticker_position_in_set(Client.t(), binary, integer) ::
              :ok | {:error, Error.t()}
  @callback delete_sticker_from_set(Client.t(), binary) :: :ok | {:error, Error.t()}
  @callback pin_chat_message(Client.t(), integer | binary, integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback unpin_chat_message(integer | binary) :: :ok | {:error, Error.t()}
  @callback unpin_chat_message(integer | binary, [{atom, any}]) :: :ok | {:error, Error.t()}
  @callback unpin_chat_message(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
  @callback unpin_chat_message(Client.t(), integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}

  @optional_callbacks get_me: 1,
                      send_message: 4,
                      forward_message: 4,
                      forward_message: 5,
                      send_photo: 4,
                      send_audio: 4,
                      send_document: 4,
                      send_sticker: 4,
                      send_video: 4,
                      send_voice: 4,
                      send_animation: 4,
                      send_location: 5,
                      send_venue: 7,
                      send_contact: 5,
                      send_chat_action: 3,
                      send_chat_action: 4,
                      get_user_profile_photos: 3,
                      get_updates: 2,
                      set_webhook: 2,
                      delete_webhook: 1,
                      delete_webhook: 2,
                      get_webhook_info: 1,
                      get_file: 2,
                      get_file_link: 2,
                      ban_chat_member: 3,
                      leave_chat: 2,
                      unban_chat_member: 3,
                      unban_chat_member: 4,
                      get_chat: 2,
                      get_chat_administrators: 2,
                      get_chat_administrators: 3,
                      get_chat_member_count: 2,
                      get_chat_member: 3,
                      get_user_chat_boosts: 3,
                      get_business_connection: 2,
                      get_managed_bot_token: 2,
                      replace_managed_bot_token: 2,
                      get_managed_bot_access_settings: 2,
                      set_managed_bot_access_settings: 4,
                      get_user_personal_chat_messages: 3,
                      delete_messages: 3,
                      delete_message_reaction: 4,
                      delete_all_message_reactions: 3,
                      set_message_reaction: 4,
                      answer_callback_query: 3,
                      answer_guest_query: 4,
                      edit_message_text: 6,
                      edit_message_caption: 5,
                      edit_message_reply_markup: 5,
                      answer_inline_query: 4,
                      get_sticker_set: 2,
                      upload_sticker_file: 3,
                      create_new_sticker_set: 7,
                      add_sticker_to_set: 6,
                      set_sticker_position_in_set: 3,
                      delete_sticker_from_set: 2,
                      pin_chat_message: 4,
                      unpin_chat_message: 2,
                      unpin_chat_message: 3
end
