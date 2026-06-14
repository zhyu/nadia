defmodule Nadia.Behaviour.Payments do
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

      @callback send_invoice(
                  integer | binary,
                  binary,
                  binary,
                  binary,
                  binary,
                  list | map | struct | binary
                ) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_invoice(
                  integer | binary,
                  binary,
                  binary,
                  binary,
                  binary,
                  list | map | struct | binary,
                  [{atom, any}] | map
                ) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_invoice(
                  Client.t(),
                  integer | binary,
                  binary,
                  binary,
                  binary,
                  binary,
                  list | map | struct | binary
                ) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback send_invoice(
                  Client.t(),
                  integer | binary,
                  binary,
                  binary,
                  binary,
                  binary,
                  list | map | struct | binary,
                  [{atom, any}] | map
                ) ::
                  {:ok, Message.t()} | {:error, Error.t()}
      @callback create_invoice_link(binary, binary, binary, binary, list | map | struct | binary) ::
                  {:ok, binary} | {:error, Error.t()}
      @callback create_invoice_link(
                  binary,
                  binary,
                  binary,
                  binary,
                  list | map | struct | binary,
                  [{atom, any}] | map
                ) ::
                  {:ok, binary} | {:error, Error.t()}
      @callback create_invoice_link(
                  Client.t(),
                  binary,
                  binary,
                  binary,
                  binary,
                  list | map | struct | binary
                ) ::
                  {:ok, binary} | {:error, Error.t()}
      @callback create_invoice_link(
                  Client.t(),
                  binary,
                  binary,
                  binary,
                  binary,
                  list | map | struct | binary,
                  [{atom, any}] | map
                ) ::
                  {:ok, binary} | {:error, Error.t()}
      @callback answer_shipping_query(binary, boolean) :: :ok | {:error, Error.t()}
      @callback answer_shipping_query(binary, boolean, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback answer_shipping_query(Client.t(), binary, boolean) :: :ok | {:error, Error.t()}
      @callback answer_shipping_query(Client.t(), binary, boolean, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback answer_pre_checkout_query(binary, boolean) :: :ok | {:error, Error.t()}
      @callback answer_pre_checkout_query(binary, boolean, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback answer_pre_checkout_query(Client.t(), binary, boolean) ::
                  :ok | {:error, Error.t()}
      @callback answer_pre_checkout_query(Client.t(), binary, boolean, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback get_my_star_balance() :: {:ok, StarAmount.t()} | {:error, Error.t()}
      @callback get_my_star_balance(Client.t()) :: {:ok, StarAmount.t()} | {:error, Error.t()}
      @callback get_star_transactions() :: {:ok, StarTransactions.t()} | {:error, Error.t()}
      @callback get_star_transactions([{atom, any}] | map) ::
                  {:ok, StarTransactions.t()} | {:error, Error.t()}
      @callback get_star_transactions(Client.t()) ::
                  {:ok, StarTransactions.t()} | {:error, Error.t()}
      @callback get_star_transactions(Client.t(), [{atom, any}] | map) ::
                  {:ok, StarTransactions.t()} | {:error, Error.t()}
      @callback refund_star_payment(integer, binary) :: :ok | {:error, Error.t()}
      @callback refund_star_payment(Client.t(), integer, binary) :: :ok | {:error, Error.t()}
      @callback edit_user_star_subscription(integer, binary, boolean) :: :ok | {:error, Error.t()}
      @callback edit_user_star_subscription(Client.t(), integer, binary, boolean) ::
                  :ok | {:error, Error.t()}
    end
  end
end
