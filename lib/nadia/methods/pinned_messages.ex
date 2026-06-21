defmodule Nadia.Methods.PinnedMessages do
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

      @doc group: "Pinned Messages"
      @doc """
      Use this method to pin a message in a group, a supergroup, or a channel. The bot must be an
      administrator in the chat for this to work and must have the ‘can_pin_messages’ admin right
      in the supergroup or ‘can_edit_messages’ admin right in the channel. Returns True on success.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `message_id` - Identifier of a message to pin

      Options:
      * `disable_notification` - Pass True, if it is not necessary to send a notification to all
      chat members about the new pinned message. Notifications are always disabled in channels.
      """
      @spec pin_chat_message(integer | binary, integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      @spec pin_chat_message(Client.t(), integer | binary, integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      def pin_chat_message(chat_id, message_id), do: pin_chat_message(chat_id, message_id, [])

      @doc group: "Pinned Messages"
      def pin_chat_message(%Client{} = client, chat_id, message_id) do
        pin_chat_message(client, chat_id, message_id, [])
      end

      def pin_chat_message(chat_id, message_id, options) do
        api_request("pinChatMessage", [chat_id: chat_id, message_id: message_id] ++ options)
      end

      @doc group: "Pinned Messages"
      def pin_chat_message(%Client{} = client, chat_id, message_id, options) do
        api_request(
          client,
          "pinChatMessage",
          [chat_id: chat_id, message_id: message_id] ++ options
        )
      end

      @doc group: "Pinned Messages"
      @doc """
      Use this method to unpin a message in a group, a supergroup, or a channel. The bot must be an
      administrator in the chat for this to work and must have the ‘can_pin_messages’ admin right in
      the supergroup or ‘can_edit_messages’ admin right in the channel. Returns True on success.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `options` - keyword list of options

      Options:
      * `:business_connection_id` - Unique identifier of the business connection
      * `:message_id` - Identifier of the message to unpin
      """
      @spec unpin_chat_message(integer | binary) :: :ok | {:error, Error.t()}
      @spec unpin_chat_message(integer | binary, [{atom, any}]) :: :ok | {:error, Error.t()}
      @spec unpin_chat_message(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      @spec unpin_chat_message(Client.t(), integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      def unpin_chat_message(chat_id) do
        unpin_chat_message(chat_id, [])
      end

      @doc group: "Pinned Messages"
      def unpin_chat_message(%Client{} = client, chat_id) do
        unpin_chat_message(client, chat_id, [])
      end

      def unpin_chat_message(chat_id, options) do
        api_request("unpinChatMessage", [chat_id: chat_id] ++ options)
      end

      @doc group: "Pinned Messages"
      def unpin_chat_message(%Client{} = client, chat_id, options) do
        api_request(client, "unpinChatMessage", [chat_id: chat_id] ++ options)
      end
    end
  end
end
