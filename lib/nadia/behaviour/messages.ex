defmodule Nadia.Behaviour.Messages do
  @moduledoc false

  defmacro __using__(_opts) do
    quote location: :keep do
      alias Nadia.Client

      alias Nadia.Model.{
        BotAccessSettings,
        BotCommand,
        BotDescription,
        BotName,
        BotShortDescription,
        BusinessConnection,
        Chat,
        ChatAdministratorRights,
        ChatInviteLink,
        ChatMember,
        Error,
        File,
        ForumTopic,
        GameHighScore,
        Gifts,
        MenuButton,
        Message,
        MessageId,
        OwnedGifts,
        Poll,
        PreparedInlineMessage,
        PreparedKeyboardButton,
        SentGuestMessage,
        SentWebAppMessage,
        StarAmount,
        StarTransactions,
        Story,
        Sticker,
        Update,
        User,
        UserChatBoosts,
        UserProfileAudios,
        UserProfilePhotos,
        WebhookInfo
      }

      @callback send_message(integer, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_message(Client.t(), integer | binary, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_rich_message(integer | binary, list | map | struct | binary) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_rich_message(integer | binary, list | map | struct | binary, [
                  {atom, any}
                ]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_rich_message(Client.t(), integer | binary, list | map | struct | binary) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_rich_message(Client.t(), integer | binary, list | map | struct | binary, [
                  {atom, any}
                ]) ::
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
      @callback forward_messages(integer | binary, integer | binary, [integer]) ::
                  {:ok, [MessageId.t()]} | {:error, Error.t()}
      @callback forward_messages(integer | binary, integer | binary, [integer], [{atom, any}]) ::
                  {:ok, [MessageId.t()]} | {:error, Error.t()}
      @callback forward_messages(Client.t(), integer | binary, integer | binary, [integer]) ::
                  {:ok, [MessageId.t()]} | {:error, Error.t()}
      @callback forward_messages(Client.t(), integer | binary, integer | binary, [integer], [
                  {atom, any}
                ]) ::
                  {:ok, [MessageId.t()]} | {:error, Error.t()}
      @callback copy_message(integer | binary, integer | binary, integer) ::
                  {:ok, MessageId.t()} | {:error, Error.t()}
      @callback copy_message(integer | binary, integer | binary, integer, [{atom, any}]) ::
                  {:ok, MessageId.t()} | {:error, Error.t()}
      @callback copy_message(Client.t(), integer | binary, integer | binary, integer) ::
                  {:ok, MessageId.t()} | {:error, Error.t()}
      @callback copy_message(Client.t(), integer | binary, integer | binary, integer, [
                  {atom, any}
                ]) ::
                  {:ok, MessageId.t()} | {:error, Error.t()}
      @callback copy_messages(integer | binary, integer | binary, [integer]) ::
                  {:ok, [MessageId.t()]} | {:error, Error.t()}
      @callback copy_messages(integer | binary, integer | binary, [integer], [{atom, any}]) ::
                  {:ok, [MessageId.t()]} | {:error, Error.t()}
      @callback copy_messages(Client.t(), integer | binary, integer | binary, [integer]) ::
                  {:ok, [MessageId.t()]} | {:error, Error.t()}
      @callback copy_messages(Client.t(), integer | binary, integer | binary, [integer], [
                  {atom, any}
                ]) ::
                  {:ok, [MessageId.t()]} | {:error, Error.t()}
      @callback send_photo(integer, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_photo(Client.t(), integer | binary, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_audio(integer, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
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
      @callback send_video(integer, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_video(Client.t(), integer | binary, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_voice(integer, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_voice(Client.t(), integer | binary, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_video_note(integer | binary, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_video_note(Client.t(), integer | binary, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_live_photo(integer | binary, binary, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_live_photo(Client.t(), integer | binary, binary, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_media_group(integer | binary, list | map | struct | binary, [{atom, any}]) ::
                  {:ok, [Message.t()]} | {:error, Error.t()}
      @callback send_media_group(Client.t(), integer | binary, list | map | struct | binary, [
                  {atom, any}
                ]) ::
                  {:ok, [Message.t()]} | {:error, Error.t()}
      @callback send_paid_media(integer | binary, integer, list | map | struct | binary, [
                  {atom, any}
                ]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_paid_media(
                  Client.t(),
                  integer | binary,
                  integer,
                  list | map | struct | binary,
                  [
                    {atom, any}
                  ]
                ) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_poll(integer | binary, binary, [{atom, any}] | map) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_poll(Client.t(), integer | binary, binary, [{atom, any}] | map) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_dice(integer | binary) :: {:ok, Message.t()} | {:error, Error.t()}
      @callback send_dice(integer | binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_dice(Client.t(), integer | binary) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_dice(Client.t(), integer | binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_game(integer | binary, binary) :: {:ok, Message.t()} | {:error, Error.t()}
      @callback send_game(integer | binary, binary, [{atom, any}] | map) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_game(Client.t(), integer | binary, binary) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_game(Client.t(), integer | binary, binary, [{atom, any}] | map) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_checklist(binary, integer | binary, list | map | struct | binary) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_checklist(binary, integer | binary, list | map | struct | binary, [
                  {atom, any}
                ]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_checklist(Client.t(), binary, integer | binary, list | map | struct | binary) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_checklist(
                  Client.t(),
                  binary,
                  integer | binary,
                  list | map | struct | binary,
                  [
                    {atom, any}
                  ]
                ) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_message_draft(integer | binary, integer) :: :ok | {:error, Error.t()}
      @callback send_message_draft(integer | binary, integer, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback send_message_draft(Client.t(), integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback send_message_draft(Client.t(), integer | binary, integer, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback send_rich_message_draft(integer, integer, list | map | struct | binary) ::
                  :ok | {:error, Error.t()}
      @callback send_rich_message_draft(integer, integer, list | map | struct | binary, [
                  {atom, any}
                ]) ::
                  :ok | {:error, Error.t()}
      @callback send_rich_message_draft(
                  Client.t(),
                  integer,
                  integer,
                  list | map | struct | binary
                ) ::
                  :ok | {:error, Error.t()}
      @callback send_rich_message_draft(
                  Client.t(),
                  integer,
                  integer,
                  list | map | struct | binary,
                  [
                    {atom, any}
                  ]
                ) ::
                  :ok | {:error, Error.t()}
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
      @callback send_venue(Client.t(), integer | binary, float, float, binary, binary, [
                  {atom, any}
                ]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_contact(integer, binary, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_contact(Client.t(), integer | binary, binary, binary, [{atom, any}]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_chat_action(integer | binary, binary) :: :ok | {:error, Error.t()}
      @callback send_chat_action(integer | binary, binary, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback send_chat_action(Client.t(), integer | binary, binary) ::
                  :ok | {:error, Error.t()}
      @callback send_chat_action(Client.t(), integer | binary, binary, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback get_user_profile_photos(integer, [{atom, any}]) ::
                  {:ok, UserProfilePhotos.t()} | {:error, Error.t()}
      @callback get_user_profile_photos(Client.t(), integer, [{atom, any}]) ::
                  {:ok, UserProfilePhotos.t()} | {:error, Error.t()}
      @callback get_user_profile_audios(integer) ::
                  {:ok, UserProfileAudios.t()} | {:error, Error.t()}
      @callback get_user_profile_audios(integer, [{atom, any}] | map) ::
                  {:ok, UserProfileAudios.t()} | {:error, Error.t()}
      @callback get_user_profile_audios(Client.t(), integer) ::
                  {:ok, UserProfileAudios.t()} | {:error, Error.t()}
      @callback get_user_profile_audios(Client.t(), integer, [{atom, any}] | map) ::
                  {:ok, UserProfileAudios.t()} | {:error, Error.t()}
    end
  end
end
