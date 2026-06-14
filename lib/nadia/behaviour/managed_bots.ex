defmodule Nadia.Behaviour.ManagedBots do
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

      @callback get_managed_bot_token(integer) :: {:ok, binary} | {:error, Error.t()}
      @callback get_managed_bot_token(Client.t(), integer) :: {:ok, binary} | {:error, Error.t()}
      @callback replace_managed_bot_token(integer) :: {:ok, binary} | {:error, Error.t()}
      @callback replace_managed_bot_token(Client.t(), integer) ::
                  {:ok, binary} | {:error, Error.t()}
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
    end
  end
end
