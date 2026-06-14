defmodule Nadia.Behaviour.PinnedMessages do
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

      @callback pin_chat_message(Client.t(), integer | binary, integer | binary, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback unpin_chat_message(integer | binary) :: :ok | {:error, Error.t()}
      @callback unpin_chat_message(integer | binary, [{atom, any}]) :: :ok | {:error, Error.t()}
      @callback unpin_chat_message(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      @callback unpin_chat_message(Client.t(), integer | binary, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
    end
  end
end
