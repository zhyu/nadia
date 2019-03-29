defmodule Nadia.Behaviour do
  alias Nadia.Model.{User, Message, Update, UserProfilePhotos, File, Error}

  @callback get_me(binary) :: {:ok, User.t()} | {:error, Error.t()}
  @callback send_message(binary, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback forward_message(binary, integer, integer, integer) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_photo(binary, integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_audio(binary, integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_document(binary, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_sticker(binary, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_video(binary, integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_voice(binary, integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_location(binary, integer, float, float, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_venue(binary, integer, float, float, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_contact(binary, integer, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_chat_action(binary, integer, binary) :: :ok | {:error, Error.t()}
  @callback get_user_profile_photos(binary, integer, [{atom, any}]) ::
              {:ok, UserProfilePhotos.t()} | {:error, Error.t()}
  @callback get_updates(binary,[{atom, any}]) :: {:ok, [Update.t()]} | {:error, Error.t()}
  @callback set_webhook(binary, [{atom, any}]) :: :ok | {:error, Error.t()}
  @callback get_file(binary,binary) :: {:ok, File.t()} | {:error, Error.t()}
  @callback get_file_link(binary,File.t()) :: {:ok, binary} | {:error, Error.t()}
  @callback kick_chat_member(binary,integer | binary, integer) :: :ok | {:error, Error.t()}
  @callback leave_chat(binary,integer | binary) :: :ok | {:error, Error.t()}
  @callback unban_chat_member(binary,integer | binary, integer) :: :ok | {:error, Error.t()}
  @callback get_chat(binary,integer | binary) :: {:ok, Chat.t()} | {:error, Error.t()}
  @callback get_chat_administrators(binary,integer | binary) ::
              {:ok, [ChatMember.t()]} | {:error, Error.t()}
  @callback get_chat_members_count(binary,integer | binary) :: {:ok, integer} | {:error, Error.t()}
  @callback get_chat_member(binary,integer | binary, integer) ::
              {:ok, ChatMember.t()} | {:error, Error.t()}
  @callback answer_callback_query(binary,binary, [{atom, any}]) :: :ok | {:error, Error.t()}
  @callback edit_message_text(binary,integer | binary, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_caption(binary,integer | binary, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_reply_markup(binary,integer | binary, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback answer_inline_query(binary, binary, [Nadia.Model.InlineQueryResult.t()], [{atom, any}]) ::
              :ok | {:error, Error.t()}
end
