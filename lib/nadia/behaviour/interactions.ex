defmodule Nadia.Behaviour.Interactions do
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
      @callback answer_web_app_query(binary, list | map | struct | binary) ::
                  {:ok, SentWebAppMessage.t()} | {:error, Error.t()}
      @callback answer_web_app_query(Client.t(), binary, list | map | struct | binary) ::
                  {:ok, SentWebAppMessage.t()} | {:error, Error.t()}
      @callback save_prepared_inline_message(integer, Nadia.Model.InlineQueryResult.t()) ::
                  {:ok, PreparedInlineMessage.t()} | {:error, Error.t()}
      @callback save_prepared_inline_message(
                  integer,
                  Nadia.Model.InlineQueryResult.t(),
                  [{atom, any}] | map
                ) ::
                  {:ok, PreparedInlineMessage.t()} | {:error, Error.t()}
      @callback save_prepared_inline_message(
                  Client.t(),
                  integer,
                  Nadia.Model.InlineQueryResult.t()
                ) ::
                  {:ok, PreparedInlineMessage.t()} | {:error, Error.t()}
      @callback save_prepared_inline_message(
                  Client.t(),
                  integer,
                  Nadia.Model.InlineQueryResult.t(),
                  [{atom, any}] | map
                ) ::
                  {:ok, PreparedInlineMessage.t()} | {:error, Error.t()}
      @callback save_prepared_keyboard_button(integer, list | map | struct | binary) ::
                  {:ok, PreparedKeyboardButton.t()} | {:error, Error.t()}
      @callback save_prepared_keyboard_button(Client.t(), integer, list | map | struct | binary) ::
                  {:ok, PreparedKeyboardButton.t()} | {:error, Error.t()}
      @callback edit_message_text(integer | binary, integer | nil, binary | nil, binary | nil, [
                  {atom, any}
                ]) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback edit_message_text(
                  Client.t(),
                  integer | binary,
                  integer | nil,
                  binary | nil,
                  binary | nil,
                  [{atom, any}]
                ) ::
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
      @callback edit_message_media(list | map | struct | binary, [{atom, any}]) ::
                  :ok | {:ok, Message.t()} | {:error, Error.t()}
      @callback edit_message_media(Client.t(), list | map | struct | binary, [{atom, any}]) ::
                  :ok | {:ok, Message.t()} | {:error, Error.t()}
      @callback edit_message_live_location(float, float, [{atom, any}]) ::
                  :ok | {:ok, Message.t()} | {:error, Error.t()}
      @callback edit_message_live_location(Client.t(), float, float, [{atom, any}]) ::
                  :ok | {:ok, Message.t()} | {:error, Error.t()}
      @callback stop_message_live_location([{atom, any}]) ::
                  :ok | {:ok, Message.t()} | {:error, Error.t()}
      @callback stop_message_live_location(Client.t(), [{atom, any}]) ::
                  :ok | {:ok, Message.t()} | {:error, Error.t()}
      @callback edit_message_checklist(
                  binary,
                  integer | binary,
                  integer,
                  list | map | struct | binary
                ) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback edit_message_checklist(
                  binary,
                  integer | binary,
                  integer,
                  list | map | struct | binary,
                  [{atom, any}]
                ) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback edit_message_checklist(
                  Client.t(),
                  binary,
                  integer | binary,
                  integer,
                  list | map | struct | binary
                ) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback edit_message_checklist(
                  Client.t(),
                  binary,
                  integer | binary,
                  integer,
                  list | map | struct | binary,
                  [{atom, any}]
                ) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback stop_poll(integer | binary, integer) :: {:ok, Poll.t()} | {:error, Error.t()}
      @callback stop_poll(integer | binary, integer, [{atom, any}]) ::
                  {:ok, Poll.t()} | {:error, Error.t()}
      @callback stop_poll(Client.t(), integer | binary, integer) ::
                  {:ok, Poll.t()} | {:error, Error.t()}
      @callback stop_poll(Client.t(), integer | binary, integer, [{atom, any}]) ::
                  {:ok, Poll.t()} | {:error, Error.t()}
      @callback set_passport_data_errors(integer, list | map | struct | binary) ::
                  :ok | {:error, Error.t()}
      @callback set_passport_data_errors(Client.t(), integer, list | map | struct | binary) ::
                  :ok | {:error, Error.t()}
      @callback approve_suggested_post(integer, integer) :: :ok | {:error, Error.t()}
      @callback approve_suggested_post(integer, integer, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback approve_suggested_post(Client.t(), integer, integer) ::
                  :ok | {:error, Error.t()}
      @callback approve_suggested_post(Client.t(), integer, integer, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback decline_suggested_post(integer, integer) :: :ok | {:error, Error.t()}
      @callback decline_suggested_post(integer, integer, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback decline_suggested_post(Client.t(), integer, integer) ::
                  :ok | {:error, Error.t()}
      @callback decline_suggested_post(Client.t(), integer, integer, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback answer_inline_query(binary, [Nadia.Model.InlineQueryResult.t()], [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback answer_inline_query(Client.t(), binary, [Nadia.Model.InlineQueryResult.t()], [
                  {atom, any}
                ]) ::
                  :ok | {:error, Error.t()}
    end
  end
end
