defmodule Nadia.Behaviour.GiftsAndVerification do
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

      @callback get_available_gifts() :: {:ok, Gifts.t()} | {:error, Error.t()}
      @callback get_available_gifts(Client.t()) :: {:ok, Gifts.t()} | {:error, Error.t()}
      @callback get_user_gifts(integer) :: {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @callback get_user_gifts(integer, [{atom, any}] | map) ::
                  {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @callback get_user_gifts(Client.t(), integer) ::
                  {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @callback get_user_gifts(Client.t(), integer, [{atom, any}] | map) ::
                  {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @callback get_chat_gifts(integer | binary) :: {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @callback get_chat_gifts(integer | binary, [{atom, any}] | map) ::
                  {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @callback get_chat_gifts(Client.t(), integer | binary) ::
                  {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @callback get_chat_gifts(Client.t(), integer | binary, [{atom, any}] | map) ::
                  {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @callback send_gift(binary) :: :ok | {:error, Error.t()}
      @callback send_gift(binary, [{atom, any}] | map) :: :ok | {:error, Error.t()}
      @callback send_gift(Client.t(), binary) :: :ok | {:error, Error.t()}
      @callback send_gift(Client.t(), binary, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback gift_premium_subscription(integer, integer, integer) ::
                  :ok | {:error, Error.t()}
      @callback gift_premium_subscription(integer, integer, integer, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback gift_premium_subscription(Client.t(), integer, integer, integer) ::
                  :ok | {:error, Error.t()}
      @callback gift_premium_subscription(
                  Client.t(),
                  integer,
                  integer,
                  integer,
                  [{atom, any}] | map
                ) :: :ok | {:error, Error.t()}
      @callback verify_user(integer) :: :ok | {:error, Error.t()}
      @callback verify_user(integer, [{atom, any}] | map) :: :ok | {:error, Error.t()}
      @callback verify_user(Client.t(), integer) :: :ok | {:error, Error.t()}
      @callback verify_user(Client.t(), integer, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback verify_chat(integer | binary) :: :ok | {:error, Error.t()}
      @callback verify_chat(integer | binary, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback verify_chat(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      @callback verify_chat(Client.t(), integer | binary, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback remove_user_verification(integer) :: :ok | {:error, Error.t()}
      @callback remove_user_verification(Client.t(), integer) :: :ok | {:error, Error.t()}
      @callback remove_chat_verification(integer | binary) :: :ok | {:error, Error.t()}
      @callback remove_chat_verification(Client.t(), integer | binary) ::
                  :ok | {:error, Error.t()}
    end
  end
end
