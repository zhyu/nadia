defmodule Nadia.Bot.Behaviour do
  alias Nadia.Model.{User, Message, Update, UserProfilePhotos, File, Error}

  @callback get_me(atom) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_message(atom, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback forward_message(atom, integer, integer, integer) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_photo(atom, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_audio(atom, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_document(atom, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_sticker(atom, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_video(atom, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_voice(atom, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_location(atom, integer, float, float, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_venue(atom, integer, float, float, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_contact(atom, integer, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_chat_action(atom, integer, binary) :: :ok | {:error, Error.t()}
  @callback send_animation(atom, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback get_user_profile_photos(atom, integer, [{atom, any}]) ::
              {:ok, UserProfilePhotos.t()} | {:error, Error.t()}
  @callback get_updates(atom, [{atom, any}]) :: {:ok, [Update.t()]} | {:error, Error.t()}
  @callback set_webhook(atom, [{atom, any}]) :: :ok | {:error, Error.t()}
  @callback delete_webhook(atom) :: :ok | {:error, Error.t()}
  @callback get_webhook_info(atom) :: {:ok, WebhookInfo.t()} | {:error, Error.t()}
  @callback get_file(atom, binary) :: {:ok, File.t()} | {:error, Error.t()}
  @callback get_file_link(atom, File.t()) :: {:ok, binary} | {:error, Error.t()}
  @callback kick_chat_member(atom, integer | binary, integer) :: :ok | {:error, Error.t()}
  @callback leave_chat(atom, integer | binary) :: :ok | {:error, Error.t()}
  @callback unban_chat_member(atom, integer | binary, integer) :: :ok | {:error, Error.t()}
  @callback get_chat(atom, integer | binary) :: {:ok, Chat.t()} | {:error, Error.t()}
  @callback get_chat_administrators(atom, integer | binary) ::
              {:ok, [ChatMember.t()]} | {:error, Error.t()}
  @callback get_chat_members_count(atom, integer | binary) :: {:ok, integer} | {:error, Error.t()}
  @callback get_chat_member(atom, integer | binary, integer) ::
              {:ok, ChatMember.t()} | {:error, Error.t()}
  @callback answer_callback_query(atom, binary, [{atom, any}]) :: :ok | {:error, Error.t()}
  @callback edit_message_text(atom, integer | binary, integer, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback delete_message(atom, integer | binary, integer) :: :ok | {:error, Error.t()}
  @callback edit_message_caption(atom, integer | binary, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_reply_markup(atom, integer | binary, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback answer_inline_query(atom, binary, [Nadia.Model.InlineQueryResult.t()], [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback get_sticker_set(atom, binary) ::
              {:ok, Nadia.Model.StickerSet.t()} | {:error, Error.t()}
  @callback upload_sticker_file(atom, integer, binary) :: {:ok, File.t()} | {:error, Error.t()}
  @callback create_new_sticker_set(atom, integer, binary, binary, binary, binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback add_sticker_to_set(atom, integer, binary, binary, binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback set_sticker_position_in_set(atom, binary, integer) :: :ok | {:error, Error.t()}
  @callback delete_sticker_from_set(atom, binary) :: :ok | {:error, Error.t()}
  @callback pin_chat_message(atom, integer | binary, integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback unpin_chat_message(atom, integer | binary) :: :ok | {:error, Error.t()}
end
