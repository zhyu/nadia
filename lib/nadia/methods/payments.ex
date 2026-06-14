defmodule Nadia.Methods.Payments do
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
        ChatAdministratorRights,
        ChatInviteLink,
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

      @doc """
      Use this method to send invoices.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      * `title` - Product name
      * `description` - Product description
      * `payload` - Bot-defined invoice payload
      * `currency` - Three-letter ISO 4217 currency code, or `XTR` for Stars
      * `prices` - JSON-serializable price breakdown array or a pre-encoded JSON string
      * `options` - orddict or map of options
      """
      @spec send_invoice(
              integer | binary,
              binary,
              binary,
              binary,
              binary,
              list | map | struct | binary
            ) ::
              {:ok, Message.t()} | {:error, Error.t()}
      @spec send_invoice(
              integer | binary,
              binary,
              binary,
              binary,
              binary,
              list | map | struct | binary,
              [{atom, any}] | map
            ) ::
              {:ok, Message.t()} | {:error, Error.t()}
      @spec send_invoice(
              Client.t(),
              integer | binary,
              binary,
              binary,
              binary,
              binary,
              list | map | struct | binary
            ) ::
              {:ok, Message.t()} | {:error, Error.t()}
      @spec send_invoice(
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
      def send_invoice(chat_id, title, description, payload, currency, prices) do
        send_invoice(chat_id, title, description, payload, currency, prices, [])
      end

      def send_invoice(%Client{} = client, chat_id, title, description, payload, currency, prices) do
        send_invoice(client, chat_id, title, description, payload, currency, prices, [])
      end

      def send_invoice(chat_id, title, description, payload, currency, prices, options) do
        api_request(
          "sendInvoice",
          request_options(
            [
              chat_id: chat_id,
              title: title,
              description: description,
              payload: payload,
              currency: currency,
              prices: encode_json_array_payload(prices)
            ],
            encode_invoice_options(options)
          )
        )
      end

      def send_invoice(
            %Client{} = client,
            chat_id,
            title,
            description,
            payload,
            currency,
            prices,
            options
          ) do
        api_request(
          client,
          "sendInvoice",
          request_options(
            [
              chat_id: chat_id,
              title: title,
              description: description,
              payload: payload,
              currency: currency,
              prices: encode_json_array_payload(prices)
            ],
            encode_invoice_options(options)
          )
        )
      end

      @doc """
      Use this method to create a link for an invoice.
      On success, the created invoice link is returned as a string.

      Args:
      * `title` - Product name
      * `description` - Product description
      * `payload` - Bot-defined invoice payload
      * `currency` - Three-letter ISO 4217 currency code, or `XTR` for Stars
      * `prices` - JSON-serializable price breakdown array or a pre-encoded JSON string
      * `options` - orddict or map of options
      """
      @spec create_invoice_link(binary, binary, binary, binary, list | map | struct | binary) ::
              {:ok, binary} | {:error, Error.t()}
      @spec create_invoice_link(
              binary,
              binary,
              binary,
              binary,
              list | map | struct | binary,
              [{atom, any}] | map
            ) ::
              {:ok, binary} | {:error, Error.t()}
      @spec create_invoice_link(
              Client.t(),
              binary,
              binary,
              binary,
              binary,
              list | map | struct | binary
            ) ::
              {:ok, binary} | {:error, Error.t()}
      @spec create_invoice_link(
              Client.t(),
              binary,
              binary,
              binary,
              binary,
              list | map | struct | binary,
              [{atom, any}] | map
            ) ::
              {:ok, binary} | {:error, Error.t()}
      def create_invoice_link(title, description, payload, currency, prices) do
        create_invoice_link(title, description, payload, currency, prices, [])
      end

      def create_invoice_link(%Client{} = client, title, description, payload, currency, prices) do
        create_invoice_link(client, title, description, payload, currency, prices, [])
      end

      def create_invoice_link(title, description, payload, currency, prices, options) do
        api_request(
          "createInvoiceLink",
          request_options(
            [
              title: title,
              description: description,
              payload: payload,
              currency: currency,
              prices: encode_json_array_payload(prices)
            ],
            encode_invoice_options(options)
          )
        )
      end

      def create_invoice_link(
            %Client{} = client,
            title,
            description,
            payload,
            currency,
            prices,
            options
          ) do
        api_request(
          client,
          "createInvoiceLink",
          request_options(
            [
              title: title,
              description: description,
              payload: payload,
              currency: currency,
              prices: encode_json_array_payload(prices)
            ],
            encode_invoice_options(options)
          )
        )
      end

      @doc """
      Use this method to reply to shipping queries.
      Returns `:ok` on success.

      Args:
      * `shipping_query_id` - Unique identifier for the query to be answered
      * `ok` - Pass true if delivery to the specified address is possible
      * `options` - orddict of options

      Options:
      * `:shipping_options` - JSON-serializable list of shipping options
      * `:error_message` - Error message to display when `ok` is false
      """
      @spec answer_shipping_query(binary, boolean) :: :ok | {:error, Error.t()}
      @spec answer_shipping_query(binary, boolean, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      @spec answer_shipping_query(Client.t(), binary, boolean) :: :ok | {:error, Error.t()}
      @spec answer_shipping_query(Client.t(), binary, boolean, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      def answer_shipping_query(shipping_query_id, ok) do
        answer_shipping_query(shipping_query_id, ok, [])
      end

      def answer_shipping_query(%Client{} = client, shipping_query_id, ok) do
        answer_shipping_query(client, shipping_query_id, ok, [])
      end

      def answer_shipping_query(shipping_query_id, ok, options) do
        api_request(
          "answerShippingQuery",
          request_options(
            [shipping_query_id: shipping_query_id, ok: ok],
            encode_json_option(options, :shipping_options)
          )
        )
      end

      def answer_shipping_query(%Client{} = client, shipping_query_id, ok, options) do
        api_request(
          client,
          "answerShippingQuery",
          request_options(
            [shipping_query_id: shipping_query_id, ok: ok],
            encode_json_option(options, :shipping_options)
          )
        )
      end

      @doc """
      Use this method to respond to pre-checkout queries.
      Returns `:ok` on success.

      Args:
      * `pre_checkout_query_id` - Unique identifier for the query to be answered
      * `ok` - Pass true if the bot is ready to proceed with the order
      * `options` - orddict of options

      Options:
      * `:error_message` - Error message to display when `ok` is false
      """
      @spec answer_pre_checkout_query(binary, boolean) :: :ok | {:error, Error.t()}
      @spec answer_pre_checkout_query(binary, boolean, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      @spec answer_pre_checkout_query(Client.t(), binary, boolean) :: :ok | {:error, Error.t()}
      @spec answer_pre_checkout_query(Client.t(), binary, boolean, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      def answer_pre_checkout_query(pre_checkout_query_id, ok) do
        answer_pre_checkout_query(pre_checkout_query_id, ok, [])
      end

      def answer_pre_checkout_query(%Client{} = client, pre_checkout_query_id, ok) do
        answer_pre_checkout_query(client, pre_checkout_query_id, ok, [])
      end

      def answer_pre_checkout_query(pre_checkout_query_id, ok, options) do
        api_request(
          "answerPreCheckoutQuery",
          request_options([pre_checkout_query_id: pre_checkout_query_id, ok: ok], options)
        )
      end

      def answer_pre_checkout_query(%Client{} = client, pre_checkout_query_id, ok, options) do
        api_request(
          client,
          "answerPreCheckoutQuery",
          request_options([pre_checkout_query_id: pre_checkout_query_id, ok: ok], options)
        )
      end

      @doc """
      Use this method to get the current Telegram Stars balance of the bot.
      Returns a StarAmount object.
      """
      @spec get_my_star_balance() :: {:ok, StarAmount.t()} | {:error, Error.t()}
      @spec get_my_star_balance(Client.t()) :: {:ok, StarAmount.t()} | {:error, Error.t()}
      def get_my_star_balance, do: api_request("getMyStarBalance")
      def get_my_star_balance(%Client{} = client), do: api_request(client, "getMyStarBalance")

      @doc """
      Use this method to get the bot's Telegram Star transactions.
      Returns a StarTransactions object.

      Args:
      * `options` - orddict or map of options
      """
      @spec get_star_transactions() :: {:ok, StarTransactions.t()} | {:error, Error.t()}
      @spec get_star_transactions([{atom, any}] | map) ::
              {:ok, StarTransactions.t()} | {:error, Error.t()}
      @spec get_star_transactions(Client.t()) ::
              {:ok, StarTransactions.t()} | {:error, Error.t()}
      @spec get_star_transactions(Client.t(), [{atom, any}] | map) ::
              {:ok, StarTransactions.t()} | {:error, Error.t()}
      def get_star_transactions(), do: get_star_transactions([])
      def get_star_transactions(%Client{} = client), do: get_star_transactions(client, [])

      def get_star_transactions(options) do
        api_request("getStarTransactions", request_options([], options))
      end

      def get_star_transactions(%Client{} = client, options) do
        api_request(client, "getStarTransactions", request_options([], options))
      end

      @doc """
      Use this method to refund a successful Telegram Stars payment.
      Returns `:ok` on success.

      Args:
      * `user_id` - Identifier of the user whose payment will be refunded
      * `telegram_payment_charge_id` - Telegram payment identifier
      """
      @spec refund_star_payment(integer, binary) :: :ok | {:error, Error.t()}
      @spec refund_star_payment(Client.t(), integer, binary) :: :ok | {:error, Error.t()}
      def refund_star_payment(user_id, telegram_payment_charge_id) do
        api_request(
          "refundStarPayment",
          user_id: user_id,
          telegram_payment_charge_id: telegram_payment_charge_id
        )
      end

      def refund_star_payment(%Client{} = client, user_id, telegram_payment_charge_id) do
        api_request(
          client,
          "refundStarPayment",
          user_id: user_id,
          telegram_payment_charge_id: telegram_payment_charge_id
        )
      end

      @doc """
      Use this method to cancel or re-enable extension of a Telegram Stars subscription.
      Returns `:ok` on success.

      Args:
      * `user_id` - Identifier of the user whose subscription will be edited
      * `telegram_payment_charge_id` - Telegram payment identifier for the subscription
      * `is_canceled` - Pass true to cancel extension, or false to re-enable it
      """
      @spec edit_user_star_subscription(integer, binary, boolean) :: :ok | {:error, Error.t()}
      @spec edit_user_star_subscription(Client.t(), integer, binary, boolean) ::
              :ok | {:error, Error.t()}
      def edit_user_star_subscription(user_id, telegram_payment_charge_id, is_canceled) do
        api_request(
          "editUserStarSubscription",
          user_id: user_id,
          telegram_payment_charge_id: telegram_payment_charge_id,
          is_canceled: is_canceled
        )
      end

      def edit_user_star_subscription(
            %Client{} = client,
            user_id,
            telegram_payment_charge_id,
            is_canceled
          ) do
        api_request(
          client,
          "editUserStarSubscription",
          user_id: user_id,
          telegram_payment_charge_id: telegram_payment_charge_id,
          is_canceled: is_canceled
        )
      end
    end
  end
end
