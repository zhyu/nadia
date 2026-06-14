defmodule Nadia.Methods.ManagedBots do
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
      Use this method to get the token of a managed bot.
      Returns the token as a string.

      Args:
      * `user_id` - User identifier of the managed bot whose token will be returned
      """
      @spec get_managed_bot_token(integer) :: {:ok, binary} | {:error, Error.t()}
      @spec get_managed_bot_token(Client.t(), integer) :: {:ok, binary} | {:error, Error.t()}
      def get_managed_bot_token(user_id) do
        api_request("getManagedBotToken", user_id: user_id)
      end

      def get_managed_bot_token(%Client{} = client, user_id) do
        api_request(client, "getManagedBotToken", user_id: user_id)
      end

      @doc """
      Use this method to revoke the current token of a managed bot and generate a new one.
      Returns the new token as a string.

      Args:
      * `user_id` - User identifier of the managed bot whose token will be replaced
      """
      @spec replace_managed_bot_token(integer) :: {:ok, binary} | {:error, Error.t()}
      @spec replace_managed_bot_token(Client.t(), integer) :: {:ok, binary} | {:error, Error.t()}
      def replace_managed_bot_token(user_id) do
        api_request("replaceManagedBotToken", user_id: user_id)
      end

      def replace_managed_bot_token(%Client{} = client, user_id) do
        api_request(client, "replaceManagedBotToken", user_id: user_id)
      end

      @doc """
      Use this method to get the access settings of a managed bot.
      Returns a BotAccessSettings object.

      Args:
      * `user_id` - User identifier of the managed bot whose access settings will be returned
      """
      @spec get_managed_bot_access_settings(integer) ::
              {:ok, BotAccessSettings.t()} | {:error, Error.t()}
      @spec get_managed_bot_access_settings(Client.t(), integer) ::
              {:ok, BotAccessSettings.t()} | {:error, Error.t()}
      def get_managed_bot_access_settings(user_id) do
        api_request("getManagedBotAccessSettings", user_id: user_id)
      end

      def get_managed_bot_access_settings(%Client{} = client, user_id) do
        api_request(client, "getManagedBotAccessSettings", user_id: user_id)
      end

      @doc """
      Use this method to change the access settings of a managed bot.
      Returns True on success.

      Args:
      * `user_id` - User identifier of the managed bot whose access settings will be changed
      * `is_access_restricted` - Pass true if only selected users can access the bot
      * `options` - orddict of options

      Options:
      * `:added_user_ids` - Array of user identifiers allowed to access the bot
      """
      @spec set_managed_bot_access_settings(integer, boolean, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      @spec set_managed_bot_access_settings(Client.t(), integer, boolean, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      def set_managed_bot_access_settings(user_id, is_access_restricted) do
        set_managed_bot_access_settings(user_id, is_access_restricted, [])
      end

      def set_managed_bot_access_settings(%Client{} = client, user_id, is_access_restricted) do
        set_managed_bot_access_settings(client, user_id, is_access_restricted, [])
      end

      def set_managed_bot_access_settings(user_id, is_access_restricted, options) do
        api_request(
          "setManagedBotAccessSettings",
          [user_id: user_id, is_access_restricted: is_access_restricted] ++
            encode_added_user_ids(options)
        )
      end

      def set_managed_bot_access_settings(
            %Client{} = client,
            user_id,
            is_access_restricted,
            options
          ) do
        api_request(
          client,
          "setManagedBotAccessSettings",
          [user_id: user_id, is_access_restricted: is_access_restricted] ++
            encode_added_user_ids(options)
        )
      end

      @doc """
      Use this method to get the last messages from the personal chat of a given user.
      On success, an array of Message objects is returned.

      Args:
      * `user_id` - Unique identifier for the target user
      * `limit` - The maximum number of messages to return
      """
      @spec get_user_personal_chat_messages(integer, integer) ::
              {:ok, [Message.t()]} | {:error, Error.t()}
      @spec get_user_personal_chat_messages(Client.t(), integer, integer) ::
              {:ok, [Message.t()]} | {:error, Error.t()}
      def get_user_personal_chat_messages(user_id, limit) do
        api_request("getUserPersonalChatMessages", user_id: user_id, limit: limit)
      end

      def get_user_personal_chat_messages(%Client{} = client, user_id, limit) do
        api_request(client, "getUserPersonalChatMessages", user_id: user_id, limit: limit)
      end
    end
  end
end
