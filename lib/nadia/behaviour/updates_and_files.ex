defmodule Nadia.Behaviour.UpdatesAndFiles do
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

      @callback get_updates([{atom, any}]) :: {:ok, [Update.t()]} | {:error, Error.t()}
      @callback get_updates(Client.t(), [{atom, any}]) ::
                  {:ok, [Update.t()]} | {:error, Error.t()}
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
      @callback download_file(binary | File.t(), Path.t(), non_neg_integer) ::
                  {:ok, Path.t()} | {:error, Error.t()}
      @callback download_file(binary | File.t(), Path.t(), non_neg_integer, keyword) ::
                  {:ok, Path.t()} | {:error, Error.t()}
      @callback download_file(Client.t(), binary | File.t(), Path.t(), non_neg_integer) ::
                  {:ok, Path.t()} | {:error, Error.t()}
      @callback download_file(
                  Client.t(),
                  binary | File.t(),
                  Path.t(),
                  non_neg_integer,
                  keyword
                ) :: {:ok, Path.t()} | {:error, Error.t()}
    end
  end
end
