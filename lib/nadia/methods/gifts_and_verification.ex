defmodule Nadia.Methods.GiftsAndVerification do
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

      @doc group: "Gifts And Verification"
      @doc """
      Use this method to get all gifts that can be sent by the bot.
      Returns a `Nadia.Model.Gifts` object on success.
      """
      @spec get_available_gifts() :: {:ok, Gifts.t()} | {:error, Error.t()}
      @spec get_available_gifts(Client.t()) :: {:ok, Gifts.t()} | {:error, Error.t()}
      def get_available_gifts, do: api_request("getAvailableGifts")
      @doc group: "Gifts And Verification"
      def get_available_gifts(%Client{} = client), do: api_request(client, "getAvailableGifts")

      @doc group: "Gifts And Verification"
      @doc """
      Use this method to get gifts owned by a user.
      Returns a `Nadia.Model.OwnedGifts` object on success.

      Args:
      * `user_id` - Unique identifier of the target user
      * `options` - keyword list or map of options
      """
      @spec get_user_gifts(integer) :: {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @spec get_user_gifts(integer, [{atom, any}] | map) ::
              {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @spec get_user_gifts(Client.t(), integer) ::
              {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @spec get_user_gifts(Client.t(), integer, [{atom, any}] | map) ::
              {:ok, OwnedGifts.t()} | {:error, Error.t()}
      def get_user_gifts(user_id), do: get_user_gifts(user_id, [])

      @doc group: "Gifts And Verification"
      def get_user_gifts(%Client{} = client, user_id) do
        get_user_gifts(client, user_id, [])
      end

      def get_user_gifts(user_id, options) do
        api_request("getUserGifts", request_options([user_id: user_id], options))
      end

      @doc group: "Gifts And Verification"
      def get_user_gifts(%Client{} = client, user_id, options) do
        api_request(client, "getUserGifts", request_options([user_id: user_id], options))
      end

      @doc group: "Gifts And Verification"
      @doc """
      Use this method to get gifts owned by a chat.
      Returns a `Nadia.Model.OwnedGifts` object on success.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      * `options` - keyword list or map of options
      """
      @spec get_chat_gifts(integer | binary) :: {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @spec get_chat_gifts(integer | binary, [{atom, any}] | map) ::
              {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @spec get_chat_gifts(Client.t(), integer | binary) ::
              {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @spec get_chat_gifts(Client.t(), integer | binary, [{atom, any}] | map) ::
              {:ok, OwnedGifts.t()} | {:error, Error.t()}
      def get_chat_gifts(chat_id), do: get_chat_gifts(chat_id, [])

      @doc group: "Gifts And Verification"
      def get_chat_gifts(%Client{} = client, chat_id) do
        get_chat_gifts(client, chat_id, [])
      end

      def get_chat_gifts(chat_id, options) do
        api_request("getChatGifts", request_options([chat_id: chat_id], options))
      end

      @doc group: "Gifts And Verification"
      def get_chat_gifts(%Client{} = client, chat_id, options) do
        api_request(client, "getChatGifts", request_options([chat_id: chat_id], options))
      end

      @doc group: "Gifts And Verification"
      @doc """
      Use this method to send a gift to a user or channel chat.
      Returns `:ok` on success.

      Args:
      * `gift_id` - Identifier of the gift
      * `options` - keyword list or map of options, including required `:user_id` or `:chat_id`

      Options:
      * `:user_id` - Unique identifier of the target user
      * `:chat_id` - Unique identifier or username of the target channel chat
      * `:pay_for_upgrade` - Pass true to pay for the gift upgrade from the bot's balance
      * `:text` - Text that will be shown along with the gift
      * `:text_parse_mode` - Mode for parsing entities in the text
      * `:text_entities` - JSON-serializable array of message entities or pre-encoded JSON
      """
      @spec send_gift(binary) :: :ok | {:error, Error.t()}
      @spec send_gift(binary, [{atom, any}] | map) :: :ok | {:error, Error.t()}
      @spec send_gift(Client.t(), binary) :: :ok | {:error, Error.t()}
      @spec send_gift(Client.t(), binary, [{atom, any}] | map) :: :ok | {:error, Error.t()}
      def send_gift(gift_id), do: send_gift(gift_id, [])

      @doc group: "Gifts And Verification"
      def send_gift(%Client{} = client, gift_id) do
        send_gift(client, gift_id, [])
      end

      def send_gift(gift_id, options) do
        api_request(
          "sendGift",
          request_options([gift_id: gift_id], encode_json_option(options, :text_entities))
        )
      end

      @doc group: "Gifts And Verification"
      def send_gift(%Client{} = client, gift_id, options) do
        api_request(
          client,
          "sendGift",
          request_options([gift_id: gift_id], encode_json_option(options, :text_entities))
        )
      end

      @doc group: "Gifts And Verification"
      @doc """
      Use this method to gift a Telegram Premium subscription to a user.
      Returns `:ok` on success.

      Args:
      * `user_id` - Unique identifier of the target user
      * `month_count` - Number of months the subscription will be active
      * `star_count` - Number of Telegram Stars to pay
      * `options` - keyword list or map of options

      Options:
      * `:text` - Text that will be shown along with the service message
      * `:text_parse_mode` - Mode for parsing entities in the text
      * `:text_entities` - JSON-serializable array of message entities or pre-encoded JSON
      """
      @spec gift_premium_subscription(integer, integer, integer) :: :ok | {:error, Error.t()}
      @spec gift_premium_subscription(integer, integer, integer, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      @spec gift_premium_subscription(Client.t(), integer, integer, integer) ::
              :ok | {:error, Error.t()}
      @spec gift_premium_subscription(Client.t(), integer, integer, integer, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      def gift_premium_subscription(user_id, month_count, star_count) do
        gift_premium_subscription(user_id, month_count, star_count, [])
      end

      @doc group: "Gifts And Verification"
      def gift_premium_subscription(%Client{} = client, user_id, month_count, star_count) do
        gift_premium_subscription(client, user_id, month_count, star_count, [])
      end

      def gift_premium_subscription(user_id, month_count, star_count, options) do
        api_request(
          "giftPremiumSubscription",
          request_options(
            [user_id: user_id, month_count: month_count, star_count: star_count],
            encode_json_option(options, :text_entities)
          )
        )
      end

      @doc group: "Gifts And Verification"
      def gift_premium_subscription(%Client{} = client, user_id, month_count, star_count, options) do
        api_request(
          client,
          "giftPremiumSubscription",
          request_options(
            [user_id: user_id, month_count: month_count, star_count: star_count],
            encode_json_option(options, :text_entities)
          )
        )
      end

      @doc group: "Gifts And Verification"
      @doc """
      Use this method to verify a user on behalf of the organization represented by the bot.
      Returns `:ok` on success.
      """
      @spec verify_user(integer) :: :ok | {:error, Error.t()}
      @spec verify_user(integer, [{atom, any}] | map) :: :ok | {:error, Error.t()}
      @spec verify_user(Client.t(), integer) :: :ok | {:error, Error.t()}
      @spec verify_user(Client.t(), integer, [{atom, any}] | map) :: :ok | {:error, Error.t()}
      def verify_user(user_id), do: verify_user(user_id, [])

      @doc group: "Gifts And Verification"
      def verify_user(%Client{} = client, user_id) do
        verify_user(client, user_id, [])
      end

      def verify_user(user_id, options) do
        api_request("verifyUser", request_options([user_id: user_id], options))
      end

      @doc group: "Gifts And Verification"
      def verify_user(%Client{} = client, user_id, options) do
        api_request(client, "verifyUser", request_options([user_id: user_id], options))
      end

      @doc group: "Gifts And Verification"
      @doc """
      Use this method to verify a chat on behalf of the organization represented by the bot.
      Returns `:ok` on success.
      """
      @spec verify_chat(integer | binary) :: :ok | {:error, Error.t()}
      @spec verify_chat(integer | binary, [{atom, any}] | map) :: :ok | {:error, Error.t()}
      @spec verify_chat(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      @spec verify_chat(Client.t(), integer | binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      def verify_chat(chat_id), do: verify_chat(chat_id, [])

      @doc group: "Gifts And Verification"
      def verify_chat(%Client{} = client, chat_id) do
        verify_chat(client, chat_id, [])
      end

      def verify_chat(chat_id, options) do
        api_request("verifyChat", request_options([chat_id: chat_id], options))
      end

      @doc group: "Gifts And Verification"
      def verify_chat(%Client{} = client, chat_id, options) do
        api_request(client, "verifyChat", request_options([chat_id: chat_id], options))
      end

      @doc group: "Gifts And Verification"
      @doc """
      Use this method to remove verification from a user who is currently verified on behalf
      of the organization represented by the bot.
      Returns `:ok` on success.
      """
      @spec remove_user_verification(integer) :: :ok | {:error, Error.t()}
      @spec remove_user_verification(Client.t(), integer) :: :ok | {:error, Error.t()}
      def remove_user_verification(user_id) do
        api_request("removeUserVerification", user_id: user_id)
      end

      @doc group: "Gifts And Verification"
      def remove_user_verification(%Client{} = client, user_id) do
        api_request(client, "removeUserVerification", user_id: user_id)
      end

      @doc group: "Gifts And Verification"
      @doc """
      Use this method to remove verification from a chat that is currently verified on behalf
      of the organization represented by the bot.
      Returns `:ok` on success.
      """
      @spec remove_chat_verification(integer | binary) :: :ok | {:error, Error.t()}
      @spec remove_chat_verification(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      def remove_chat_verification(chat_id) do
        api_request("removeChatVerification", chat_id: chat_id)
      end

      @doc group: "Gifts And Verification"
      def remove_chat_verification(%Client{} = client, chat_id) do
        api_request(client, "removeChatVerification", chat_id: chat_id)
      end
    end
  end
end
