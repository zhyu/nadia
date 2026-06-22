defmodule Nadia.Methods.Chats do
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

      @doc group: "Chats And Administration"
      @doc """
      Use this method to ban a user in a group, a supergroup or a channel. In the
      case of supergroups and channels, the user will not be able to return to the
      chat on their own using invite links, etc., unless unbanned first. The bot must
      be an administrator in the chat for this to work and must have the appropriate
      administrator rights. Returns True on success.

      Args:
      * `chat_id` - Unique identifier for the target group or username of the target
      supergroup or channel (in the format @username)
      * `user_id` - Unique identifier of the target user
      * `options` - keyword list of options
      """
      @spec ban_chat_member(integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec ban_chat_member(integer | binary, integer, [{atom, any}]) :: :ok | {:error, Error.t()}
      @spec ban_chat_member(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec ban_chat_member(Client.t(), integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      def ban_chat_member(chat_id, user_id), do: ban_chat_member(chat_id, user_id, [])

      @doc group: "Chats And Administration"
      def ban_chat_member(%Client{} = client, chat_id, user_id) do
        ban_chat_member(client, chat_id, user_id, [])
      end

      def ban_chat_member(chat_id, user_id, options) do
        api_request("banChatMember", [chat_id: chat_id, user_id: user_id] ++ options)
      end

      @doc group: "Chats And Administration"
      def ban_chat_member(%Client{} = client, chat_id, user_id, options) do
        api_request(client, "banChatMember", [chat_id: chat_id, user_id: user_id] ++ options)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method for your bot to leave a group, supergroup or channel.
      Returns True on success.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target supergroup or
      channel (in the format @supergroupusername)
      """
      @spec leave_chat(integer | binary) :: :ok | {:error, Error.t()}
      @spec leave_chat(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      def leave_chat(chat_id) do
        api_request("leaveChat", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      def leave_chat(%Client{} = client, chat_id) do
        api_request(client, "leaveChat", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to unban a previously kicked user in a supergroup. The user will not
      return to the group automatically, but will be able to join via link, etc. The bot
      must be an administrator in the group for this to work. Returns True on success.

      Args:
      * `chat_id` - Unique identifier for the target group or username of the target supergroup
      (in the format @supergroupusername)
      * `user_id` - Unique identifier of the target user
      * `options` - keyword list of options

      Options:
      * `:only_if_banned` - Do nothing if the user is not banned
      """
      @spec unban_chat_member(integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec unban_chat_member(integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      @spec unban_chat_member(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec unban_chat_member(Client.t(), integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      def unban_chat_member(chat_id, user_id) do
        unban_chat_member(chat_id, user_id, [])
      end

      @doc group: "Chats And Administration"
      def unban_chat_member(%Client{} = client, chat_id, user_id) do
        unban_chat_member(client, chat_id, user_id, [])
      end

      def unban_chat_member(chat_id, user_id, options) do
        api_request("unbanChatMember", [chat_id: chat_id, user_id: user_id] ++ options)
      end

      @doc group: "Chats And Administration"
      def unban_chat_member(%Client{} = client, chat_id, user_id, options) do
        api_request(client, "unbanChatMember", [chat_id: chat_id, user_id: user_id] ++ options)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to restrict a user in a supergroup. Returns True on success.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target supergroup
      (in the format @supergroupusername)
      * `user_id` - Unique identifier of the target user
      * `permissions` - New user permissions
      * `options` - keyword list of options
      """
      @spec restrict_chat_member(integer | binary, integer, map | keyword | struct | binary) ::
              :ok | {:error, Error.t()}
      @spec restrict_chat_member(
              integer | binary,
              integer,
              map | keyword | struct | binary,
              [{atom, any}]
            ) :: :ok | {:error, Error.t()}
      @spec restrict_chat_member(
              Client.t(),
              integer | binary,
              integer,
              map | keyword | struct | binary
            ) ::
              :ok | {:error, Error.t()}
      @spec restrict_chat_member(
              Client.t(),
              integer | binary,
              integer,
              map | keyword | struct | binary,
              [{atom, any}]
            ) :: :ok | {:error, Error.t()}
      def restrict_chat_member(chat_id, user_id, permissions) do
        restrict_chat_member(chat_id, user_id, permissions, [])
      end

      @doc group: "Chats And Administration"
      def restrict_chat_member(%Client{} = client, chat_id, user_id, permissions) do
        restrict_chat_member(client, chat_id, user_id, permissions, [])
      end

      def restrict_chat_member(chat_id, user_id, permissions, options) do
        api_request(
          "restrictChatMember",
          [chat_id: chat_id, user_id: user_id, permissions: encode_permissions(permissions)] ++
            options
        )
      end

      @doc group: "Chats And Administration"
      def restrict_chat_member(%Client{} = client, chat_id, user_id, permissions, options) do
        api_request(
          client,
          "restrictChatMember",
          [chat_id: chat_id, user_id: user_id, permissions: encode_permissions(permissions)] ++
            options
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to promote or demote a user in a supergroup or a channel.
      Returns True on success.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      * `user_id` - Unique identifier of the target user
      * `options` - keyword list of options
      """
      @spec promote_chat_member(integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec promote_chat_member(integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      @spec promote_chat_member(Client.t(), integer | binary, integer) ::
              :ok | {:error, Error.t()}
      @spec promote_chat_member(Client.t(), integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      def promote_chat_member(chat_id, user_id), do: promote_chat_member(chat_id, user_id, [])

      @doc group: "Chats And Administration"
      def promote_chat_member(%Client{} = client, chat_id, user_id) do
        promote_chat_member(client, chat_id, user_id, [])
      end

      def promote_chat_member(chat_id, user_id, options) do
        api_request("promoteChatMember", [chat_id: chat_id, user_id: user_id] ++ options)
      end

      @doc group: "Chats And Administration"
      def promote_chat_member(%Client{} = client, chat_id, user_id, options) do
        api_request(client, "promoteChatMember", [chat_id: chat_id, user_id: user_id] ++ options)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to set a custom title for an administrator in a supergroup.
      Returns True on success.
      """
      @spec set_chat_administrator_custom_title(integer | binary, integer, binary) ::
              :ok | {:error, Error.t()}
      @spec set_chat_administrator_custom_title(Client.t(), integer | binary, integer, binary) ::
              :ok | {:error, Error.t()}
      def set_chat_administrator_custom_title(chat_id, user_id, custom_title) do
        api_request(
          "setChatAdministratorCustomTitle",
          chat_id: chat_id,
          user_id: user_id,
          custom_title: custom_title
        )
      end

      @doc group: "Chats And Administration"
      def set_chat_administrator_custom_title(%Client{} = client, chat_id, user_id, custom_title) do
        api_request(
          client,
          "setChatAdministratorCustomTitle",
          chat_id: chat_id,
          user_id: user_id,
          custom_title: custom_title
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to change the tag of a user in a direct messages chat. Returns True on success.

      Args:
      * `chat_id` - Unique identifier for the target chat
      * `user_id` - Unique identifier of the target user
      * `options` - keyword list of options
      """
      @spec set_chat_member_tag(integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec set_chat_member_tag(integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      @spec set_chat_member_tag(Client.t(), integer | binary, integer) ::
              :ok | {:error, Error.t()}
      @spec set_chat_member_tag(Client.t(), integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      def set_chat_member_tag(chat_id, user_id), do: set_chat_member_tag(chat_id, user_id, [])

      @doc group: "Chats And Administration"
      def set_chat_member_tag(%Client{} = client, chat_id, user_id) do
        set_chat_member_tag(client, chat_id, user_id, [])
      end

      def set_chat_member_tag(chat_id, user_id, options) do
        api_request("setChatMemberTag", [chat_id: chat_id, user_id: user_id] ++ options)
      end

      @doc group: "Chats And Administration"
      def set_chat_member_tag(%Client{} = client, chat_id, user_id, options) do
        api_request(client, "setChatMemberTag", [chat_id: chat_id, user_id: user_id] ++ options)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to ban a channel chat in a supergroup or a channel. Returns True on success.
      """
      @spec ban_chat_sender_chat(integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec ban_chat_sender_chat(Client.t(), integer | binary, integer) ::
              :ok | {:error, Error.t()}
      def ban_chat_sender_chat(chat_id, sender_chat_id) do
        api_request("banChatSenderChat", chat_id: chat_id, sender_chat_id: sender_chat_id)
      end

      @doc group: "Chats And Administration"
      def ban_chat_sender_chat(%Client{} = client, chat_id, sender_chat_id) do
        api_request(client, "banChatSenderChat", chat_id: chat_id, sender_chat_id: sender_chat_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to unban a previously banned channel chat. Returns True on success.
      """
      @spec unban_chat_sender_chat(integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec unban_chat_sender_chat(Client.t(), integer | binary, integer) ::
              :ok | {:error, Error.t()}
      def unban_chat_sender_chat(chat_id, sender_chat_id) do
        api_request("unbanChatSenderChat", chat_id: chat_id, sender_chat_id: sender_chat_id)
      end

      @doc group: "Chats And Administration"
      def unban_chat_sender_chat(%Client{} = client, chat_id, sender_chat_id) do
        api_request(client, "unbanChatSenderChat",
          chat_id: chat_id,
          sender_chat_id: sender_chat_id
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to set default chat permissions for all members. Returns True on success.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target supergroup
      * `permissions` - New default chat permissions
      * `options` - keyword list of options
      """
      @spec set_chat_permissions(integer | binary, map | keyword | struct | binary) ::
              :ok | {:error, Error.t()}
      @spec set_chat_permissions(integer | binary, map | keyword | struct | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      @spec set_chat_permissions(Client.t(), integer | binary, map | keyword | struct | binary) ::
              :ok | {:error, Error.t()}
      @spec set_chat_permissions(
              Client.t(),
              integer | binary,
              map | keyword | struct | binary,
              [{atom, any}]
            ) :: :ok | {:error, Error.t()}
      def set_chat_permissions(chat_id, permissions),
        do: set_chat_permissions(chat_id, permissions, [])

      @doc group: "Chats And Administration"
      def set_chat_permissions(%Client{} = client, chat_id, permissions) do
        set_chat_permissions(client, chat_id, permissions, [])
      end

      def set_chat_permissions(chat_id, permissions, options) do
        api_request(
          "setChatPermissions",
          [chat_id: chat_id, permissions: encode_permissions(permissions)] ++ options
        )
      end

      @doc group: "Chats And Administration"
      def set_chat_permissions(%Client{} = client, chat_id, permissions, options) do
        api_request(
          client,
          "setChatPermissions",
          [chat_id: chat_id, permissions: encode_permissions(permissions)] ++ options
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to approve a chat join request. Returns True on success.
      """
      @spec approve_chat_join_request(integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec approve_chat_join_request(Client.t(), integer | binary, integer) ::
              :ok | {:error, Error.t()}
      def approve_chat_join_request(chat_id, user_id) do
        api_request("approveChatJoinRequest", chat_id: chat_id, user_id: user_id)
      end

      @doc group: "Chats And Administration"
      def approve_chat_join_request(%Client{} = client, chat_id, user_id) do
        api_request(client, "approveChatJoinRequest", chat_id: chat_id, user_id: user_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to decline a chat join request. Returns True on success.
      """
      @spec decline_chat_join_request(integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec decline_chat_join_request(Client.t(), integer | binary, integer) ::
              :ok | {:error, Error.t()}
      def decline_chat_join_request(chat_id, user_id) do
        api_request("declineChatJoinRequest", chat_id: chat_id, user_id: user_id)
      end

      @doc group: "Chats And Administration"
      def decline_chat_join_request(%Client{} = client, chat_id, user_id) do
        api_request(client, "declineChatJoinRequest", chat_id: chat_id, user_id: user_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to process a received chat join request query.
      Returns `:ok` on success.
      """
      @spec answer_chat_join_request_query(binary, binary) :: :ok | {:error, Error.t()}
      @spec answer_chat_join_request_query(Client.t(), binary, binary) ::
              :ok | {:error, Error.t()}
      def answer_chat_join_request_query(chat_join_request_query_id, result) do
        api_request(
          "answerChatJoinRequestQuery",
          chat_join_request_query_id: chat_join_request_query_id,
          result: result
        )
      end

      @doc group: "Chats And Administration"
      def answer_chat_join_request_query(%Client{} = client, chat_join_request_query_id, result) do
        api_request(
          client,
          "answerChatJoinRequestQuery",
          chat_join_request_query_id: chat_join_request_query_id,
          result: result
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to process a received chat join request query by showing a
      Mini App to the user before deciding the outcome.
      Returns `:ok` on success.
      """
      @spec send_chat_join_request_web_app(binary, binary) :: :ok | {:error, Error.t()}
      @spec send_chat_join_request_web_app(Client.t(), binary, binary) ::
              :ok | {:error, Error.t()}
      def send_chat_join_request_web_app(chat_join_request_query_id, web_app_url) do
        api_request(
          "sendChatJoinRequestWebApp",
          chat_join_request_query_id: chat_join_request_query_id,
          web_app_url: web_app_url
        )
      end

      @doc group: "Chats And Administration"
      def send_chat_join_request_web_app(
            %Client{} = client,
            chat_join_request_query_id,
            web_app_url
          ) do
        api_request(
          client,
          "sendChatJoinRequestWebApp",
          chat_join_request_query_id: chat_join_request_query_id,
          web_app_url: web_app_url
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to delete a chat photo. Returns True on success.
      """
      @spec delete_chat_photo(integer | binary) :: :ok | {:error, Error.t()}
      @spec delete_chat_photo(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      def delete_chat_photo(chat_id) do
        api_request("deleteChatPhoto", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      def delete_chat_photo(%Client{} = client, chat_id) do
        api_request(client, "deleteChatPhoto", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to set a new profile photo for the chat. Returns True on success.
      """
      @spec set_chat_photo(integer | binary, binary | Nadia.InputFile.t()) ::
              :ok | {:error, Error.t()}
      @spec set_chat_photo(Client.t(), integer | binary, binary | Nadia.InputFile.t()) ::
              :ok | {:error, Error.t()}
      def set_chat_photo(chat_id, photo) do
        api_request("setChatPhoto", [chat_id: chat_id, photo: photo], :photo)
      end

      @doc group: "Chats And Administration"
      def set_chat_photo(%Client{} = client, chat_id, photo) do
        api_request(client, "setChatPhoto", [chat_id: chat_id, photo: photo], :photo)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to change the title of a chat. Returns True on success.
      """
      @spec set_chat_title(integer | binary, binary) :: :ok | {:error, Error.t()}
      @spec set_chat_title(Client.t(), integer | binary, binary) :: :ok | {:error, Error.t()}
      def set_chat_title(chat_id, title) do
        api_request("setChatTitle", chat_id: chat_id, title: title)
      end

      @doc group: "Chats And Administration"
      def set_chat_title(%Client{} = client, chat_id, title) do
        api_request(client, "setChatTitle", chat_id: chat_id, title: title)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to change the description of a chat. Returns True on success.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      * `options` - keyword list of options
      """
      @spec set_chat_description(integer | binary) :: :ok | {:error, Error.t()}
      @spec set_chat_description(integer | binary, [{atom, any}]) :: :ok | {:error, Error.t()}
      @spec set_chat_description(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      @spec set_chat_description(Client.t(), integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      def set_chat_description(chat_id) do
        set_chat_description(chat_id, [])
      end

      @doc group: "Chats And Administration"
      def set_chat_description(%Client{} = client, chat_id) do
        set_chat_description(client, chat_id, [])
      end

      def set_chat_description(chat_id, options) do
        api_request("setChatDescription", [chat_id: chat_id] ++ options)
      end

      @doc group: "Chats And Administration"
      def set_chat_description(%Client{} = client, chat_id, options) do
        api_request(client, "setChatDescription", [chat_id: chat_id] ++ options)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to clear the list of pinned messages in a chat. Returns True on success.
      """
      @spec unpin_all_chat_messages(integer | binary) :: :ok | {:error, Error.t()}
      @spec unpin_all_chat_messages(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      def unpin_all_chat_messages(chat_id) do
        api_request("unpinAllChatMessages", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      def unpin_all_chat_messages(%Client{} = client, chat_id) do
        api_request(client, "unpinAllChatMessages", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to set a new group sticker set for a supergroup. Returns True on success.
      """
      @spec set_chat_sticker_set(integer | binary, binary) :: :ok | {:error, Error.t()}
      @spec set_chat_sticker_set(Client.t(), integer | binary, binary) ::
              :ok | {:error, Error.t()}
      def set_chat_sticker_set(chat_id, sticker_set_name) do
        api_request("setChatStickerSet", chat_id: chat_id, sticker_set_name: sticker_set_name)
      end

      @doc group: "Chats And Administration"
      def set_chat_sticker_set(%Client{} = client, chat_id, sticker_set_name) do
        api_request(
          client,
          "setChatStickerSet",
          chat_id: chat_id,
          sticker_set_name: sticker_set_name
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to delete a group sticker set from a supergroup. Returns True on success.
      """
      @spec delete_chat_sticker_set(integer | binary) :: :ok | {:error, Error.t()}
      @spec delete_chat_sticker_set(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      def delete_chat_sticker_set(chat_id) do
        api_request("deleteChatStickerSet", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      def delete_chat_sticker_set(%Client{} = client, chat_id) do
        api_request(client, "deleteChatStickerSet", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to get custom emoji stickers that can be used as forum topic icons.
      Returns an array of Sticker objects.
      """
      @spec get_forum_topic_icon_stickers() :: {:ok, [Sticker.t()]} | {:error, Error.t()}
      @spec get_forum_topic_icon_stickers(Client.t()) ::
              {:ok, [Sticker.t()]} | {:error, Error.t()}
      def get_forum_topic_icon_stickers, do: api_request("getForumTopicIconStickers")

      @doc group: "Chats And Administration"
      def get_forum_topic_icon_stickers(%Client{} = client) do
        api_request(client, "getForumTopicIconStickers")
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to create a topic in a forum supergroup chat or private chat.
      Returns information about the created topic as a ForumTopic object.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target supergroup
      * `name` - Topic name
      * `options` - keyword list of options

      Options:
      * `:icon_color` - Color of the topic icon in RGB format
      * `:icon_custom_emoji_id` - Unique identifier of the custom emoji shown as the topic icon
      """
      @spec create_forum_topic(integer | binary, binary) ::
              {:ok, ForumTopic.t()} | {:error, Error.t()}
      @spec create_forum_topic(integer | binary, binary, [{atom, any}]) ::
              {:ok, ForumTopic.t()} | {:error, Error.t()}
      @spec create_forum_topic(Client.t(), integer | binary, binary) ::
              {:ok, ForumTopic.t()} | {:error, Error.t()}
      @spec create_forum_topic(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, ForumTopic.t()} | {:error, Error.t()}
      def create_forum_topic(chat_id, name), do: create_forum_topic(chat_id, name, [])

      @doc group: "Chats And Administration"
      def create_forum_topic(%Client{} = client, chat_id, name) do
        create_forum_topic(client, chat_id, name, [])
      end

      def create_forum_topic(chat_id, name, options) do
        api_request("createForumTopic", [chat_id: chat_id, name: name] ++ options)
      end

      @doc group: "Chats And Administration"
      def create_forum_topic(%Client{} = client, chat_id, name, options) do
        api_request(client, "createForumTopic", [chat_id: chat_id, name: name] ++ options)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to edit name and icon of a forum topic. Returns True on success.
      """
      @spec edit_forum_topic(integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec edit_forum_topic(integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      @spec edit_forum_topic(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec edit_forum_topic(Client.t(), integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      def edit_forum_topic(chat_id, message_thread_id) do
        edit_forum_topic(chat_id, message_thread_id, [])
      end

      @doc group: "Chats And Administration"
      def edit_forum_topic(%Client{} = client, chat_id, message_thread_id) do
        edit_forum_topic(client, chat_id, message_thread_id, [])
      end

      def edit_forum_topic(chat_id, message_thread_id, options) do
        api_request(
          "editForumTopic",
          [chat_id: chat_id, message_thread_id: message_thread_id] ++ options
        )
      end

      @doc group: "Chats And Administration"
      def edit_forum_topic(%Client{} = client, chat_id, message_thread_id, options) do
        api_request(
          client,
          "editForumTopic",
          [chat_id: chat_id, message_thread_id: message_thread_id] ++ options
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to close an open forum topic. Returns True on success.
      """
      @spec close_forum_topic(integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec close_forum_topic(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
      def close_forum_topic(chat_id, message_thread_id) do
        api_request("closeForumTopic", chat_id: chat_id, message_thread_id: message_thread_id)
      end

      @doc group: "Chats And Administration"
      def close_forum_topic(%Client{} = client, chat_id, message_thread_id) do
        api_request(client, "closeForumTopic",
          chat_id: chat_id,
          message_thread_id: message_thread_id
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to reopen a closed forum topic. Returns True on success.
      """
      @spec reopen_forum_topic(integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec reopen_forum_topic(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
      def reopen_forum_topic(chat_id, message_thread_id) do
        api_request("reopenForumTopic", chat_id: chat_id, message_thread_id: message_thread_id)
      end

      @doc group: "Chats And Administration"
      def reopen_forum_topic(%Client{} = client, chat_id, message_thread_id) do
        api_request(client, "reopenForumTopic",
          chat_id: chat_id,
          message_thread_id: message_thread_id
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to delete a forum topic and all its messages. Returns True on success.
      """
      @spec delete_forum_topic(integer | binary, integer) :: :ok | {:error, Error.t()}
      @spec delete_forum_topic(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
      def delete_forum_topic(chat_id, message_thread_id) do
        api_request("deleteForumTopic", chat_id: chat_id, message_thread_id: message_thread_id)
      end

      @doc group: "Chats And Administration"
      def delete_forum_topic(%Client{} = client, chat_id, message_thread_id) do
        api_request(client, "deleteForumTopic",
          chat_id: chat_id,
          message_thread_id: message_thread_id
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to clear the list of pinned messages in a forum topic. Returns True on success.
      """
      @spec unpin_all_forum_topic_messages(integer | binary, integer) ::
              :ok | {:error, Error.t()}
      @spec unpin_all_forum_topic_messages(Client.t(), integer | binary, integer) ::
              :ok | {:error, Error.t()}
      def unpin_all_forum_topic_messages(chat_id, message_thread_id) do
        api_request("unpinAllForumTopicMessages",
          chat_id: chat_id,
          message_thread_id: message_thread_id
        )
      end

      @doc group: "Chats And Administration"
      def unpin_all_forum_topic_messages(%Client{} = client, chat_id, message_thread_id) do
        api_request(client, "unpinAllForumTopicMessages",
          chat_id: chat_id,
          message_thread_id: message_thread_id
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to edit the name of the General forum topic. Returns True on success.
      """
      @spec edit_general_forum_topic(integer | binary, binary) :: :ok | {:error, Error.t()}
      @spec edit_general_forum_topic(Client.t(), integer | binary, binary) ::
              :ok | {:error, Error.t()}
      def edit_general_forum_topic(chat_id, name) do
        api_request("editGeneralForumTopic", chat_id: chat_id, name: name)
      end

      @doc group: "Chats And Administration"
      def edit_general_forum_topic(%Client{} = client, chat_id, name) do
        api_request(client, "editGeneralForumTopic", chat_id: chat_id, name: name)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to close an open General forum topic. Returns True on success.
      """
      @spec close_general_forum_topic(integer | binary) :: :ok | {:error, Error.t()}
      @spec close_general_forum_topic(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      def close_general_forum_topic(chat_id) do
        api_request("closeGeneralForumTopic", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      def close_general_forum_topic(%Client{} = client, chat_id) do
        api_request(client, "closeGeneralForumTopic", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to reopen a closed General forum topic. Returns True on success.
      """
      @spec reopen_general_forum_topic(integer | binary) :: :ok | {:error, Error.t()}
      @spec reopen_general_forum_topic(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      def reopen_general_forum_topic(chat_id) do
        api_request("reopenGeneralForumTopic", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      def reopen_general_forum_topic(%Client{} = client, chat_id) do
        api_request(client, "reopenGeneralForumTopic", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to hide the General forum topic. Returns True on success.
      """
      @spec hide_general_forum_topic(integer | binary) :: :ok | {:error, Error.t()}
      @spec hide_general_forum_topic(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      def hide_general_forum_topic(chat_id) do
        api_request("hideGeneralForumTopic", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      def hide_general_forum_topic(%Client{} = client, chat_id) do
        api_request(client, "hideGeneralForumTopic", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to unhide the General forum topic. Returns True on success.
      """
      @spec unhide_general_forum_topic(integer | binary) :: :ok | {:error, Error.t()}
      @spec unhide_general_forum_topic(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      def unhide_general_forum_topic(chat_id) do
        api_request("unhideGeneralForumTopic", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      def unhide_general_forum_topic(%Client{} = client, chat_id) do
        api_request(client, "unhideGeneralForumTopic", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to clear pinned messages in the General forum topic. Returns True on success.
      """
      @spec unpin_all_general_forum_topic_messages(integer | binary) :: :ok | {:error, Error.t()}
      @spec unpin_all_general_forum_topic_messages(Client.t(), integer | binary) ::
              :ok | {:error, Error.t()}
      def unpin_all_general_forum_topic_messages(chat_id) do
        api_request("unpinAllGeneralForumTopicMessages", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      def unpin_all_general_forum_topic_messages(%Client{} = client, chat_id) do
        api_request(client, "unpinAllGeneralForumTopicMessages", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to get up to date information about the chat (current name of
      the user for one-on-one conversations, current username of a user, group or channel, etc.)
      Returns a Chat object on success.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target supergroup or
      channel (in the format @supergroupusername)
      """
      @spec get_chat(integer | binary) :: {:ok, Chat.t()} | {:error, Error.t()}
      @spec get_chat(Client.t(), integer | binary) :: {:ok, Chat.t()} | {:error, Error.t()}
      def get_chat(chat_id) do
        api_request("getChat", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      def get_chat(%Client{} = client, chat_id) do
        api_request(client, "getChat", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to generate a new primary invite link for a chat.
      Returns the new invite link as String on success.
      """
      @spec export_chat_invite_link(integer | binary) :: {:ok, binary} | {:error, Error.t()}
      @spec export_chat_invite_link(Client.t(), integer | binary) ::
              {:ok, binary} | {:error, Error.t()}
      def export_chat_invite_link(chat_id) do
        api_request("exportChatInviteLink", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      def export_chat_invite_link(%Client{} = client, chat_id) do
        api_request(client, "exportChatInviteLink", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to create an additional invite link for a chat.
      Returns the new invite link as a ChatInviteLink object.
      """
      @spec create_chat_invite_link(integer | binary) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @spec create_chat_invite_link(integer | binary, [{atom, any}] | map) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @spec create_chat_invite_link(Client.t(), integer | binary) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @spec create_chat_invite_link(Client.t(), integer | binary, [{atom, any}] | map) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      def create_chat_invite_link(chat_id), do: create_chat_invite_link(chat_id, [])

      @doc group: "Chats And Administration"
      def create_chat_invite_link(%Client{} = client, chat_id) do
        create_chat_invite_link(client, chat_id, [])
      end

      def create_chat_invite_link(chat_id, options) do
        api_request("createChatInviteLink", request_options([chat_id: chat_id], options))
      end

      @doc group: "Chats And Administration"
      def create_chat_invite_link(%Client{} = client, chat_id, options) do
        api_request(client, "createChatInviteLink", request_options([chat_id: chat_id], options))
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to edit a non-primary invite link created by the bot.
      Returns the edited invite link as a ChatInviteLink object.
      """
      @spec edit_chat_invite_link(integer | binary, binary) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @spec edit_chat_invite_link(integer | binary, binary, [{atom, any}] | map) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @spec edit_chat_invite_link(Client.t(), integer | binary, binary) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @spec edit_chat_invite_link(Client.t(), integer | binary, binary, [{atom, any}] | map) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      def edit_chat_invite_link(chat_id, invite_link) do
        edit_chat_invite_link(chat_id, invite_link, [])
      end

      @doc group: "Chats And Administration"
      def edit_chat_invite_link(%Client{} = client, chat_id, invite_link) do
        edit_chat_invite_link(client, chat_id, invite_link, [])
      end

      def edit_chat_invite_link(chat_id, invite_link, options) do
        api_request(
          "editChatInviteLink",
          request_options([chat_id: chat_id, invite_link: invite_link], options)
        )
      end

      @doc group: "Chats And Administration"
      def edit_chat_invite_link(%Client{} = client, chat_id, invite_link, options) do
        api_request(
          client,
          "editChatInviteLink",
          request_options([chat_id: chat_id, invite_link: invite_link], options)
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to create a subscription invite link for a channel chat.
      Returns the new invite link as a ChatInviteLink object.
      """
      @spec create_chat_subscription_invite_link(integer | binary, integer, integer) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @spec create_chat_subscription_invite_link(
              integer | binary,
              integer,
              integer,
              [{atom, any}] | map
            ) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @spec create_chat_subscription_invite_link(Client.t(), integer | binary, integer, integer) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @spec create_chat_subscription_invite_link(
              Client.t(),
              integer | binary,
              integer,
              integer,
              [{atom, any}] | map
            ) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      def create_chat_subscription_invite_link(chat_id, subscription_period, subscription_price) do
        create_chat_subscription_invite_link(chat_id, subscription_period, subscription_price, [])
      end

      @doc group: "Chats And Administration"
      def create_chat_subscription_invite_link(
            %Client{} = client,
            chat_id,
            subscription_period,
            subscription_price
          ) do
        create_chat_subscription_invite_link(
          client,
          chat_id,
          subscription_period,
          subscription_price,
          []
        )
      end

      def create_chat_subscription_invite_link(
            chat_id,
            subscription_period,
            subscription_price,
            options
          ) do
        api_request(
          "createChatSubscriptionInviteLink",
          request_options(
            [
              chat_id: chat_id,
              subscription_period: subscription_period,
              subscription_price: subscription_price
            ],
            options
          )
        )
      end

      @doc group: "Chats And Administration"
      def create_chat_subscription_invite_link(
            %Client{} = client,
            chat_id,
            subscription_period,
            subscription_price,
            options
          ) do
        api_request(
          client,
          "createChatSubscriptionInviteLink",
          request_options(
            [
              chat_id: chat_id,
              subscription_period: subscription_period,
              subscription_price: subscription_price
            ],
            options
          )
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to edit a subscription invite link created by the bot.
      Returns the edited invite link as a ChatInviteLink object.
      """
      @spec edit_chat_subscription_invite_link(integer | binary, binary) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @spec edit_chat_subscription_invite_link(integer | binary, binary, [{atom, any}] | map) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @spec edit_chat_subscription_invite_link(Client.t(), integer | binary, binary) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @spec edit_chat_subscription_invite_link(
              Client.t(),
              integer | binary,
              binary,
              [{atom, any}] | map
            ) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      def edit_chat_subscription_invite_link(chat_id, invite_link) do
        edit_chat_subscription_invite_link(chat_id, invite_link, [])
      end

      @doc group: "Chats And Administration"
      def edit_chat_subscription_invite_link(%Client{} = client, chat_id, invite_link) do
        edit_chat_subscription_invite_link(client, chat_id, invite_link, [])
      end

      def edit_chat_subscription_invite_link(chat_id, invite_link, options) do
        api_request(
          "editChatSubscriptionInviteLink",
          request_options([chat_id: chat_id, invite_link: invite_link], options)
        )
      end

      @doc group: "Chats And Administration"
      def edit_chat_subscription_invite_link(%Client{} = client, chat_id, invite_link, options) do
        api_request(
          client,
          "editChatSubscriptionInviteLink",
          request_options([chat_id: chat_id, invite_link: invite_link], options)
        )
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to revoke an invite link created by the bot.
      Returns the revoked invite link as a ChatInviteLink object.
      """
      @spec revoke_chat_invite_link(integer | binary, binary) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @spec revoke_chat_invite_link(Client.t(), integer | binary, binary) ::
              {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      def revoke_chat_invite_link(chat_id, invite_link) do
        api_request("revokeChatInviteLink", chat_id: chat_id, invite_link: invite_link)
      end

      @doc group: "Chats And Administration"
      def revoke_chat_invite_link(%Client{} = client, chat_id, invite_link) do
        api_request(client, "revokeChatInviteLink", chat_id: chat_id, invite_link: invite_link)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to get a list of administrators in a chat. On success, returns an Array of
      ChatMember objects that contains information about all chat administrators except other bots.
      If the chat is a group or a supergroup and no administrators were appointed, only the creator
      will be returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target supergroup or
      channel (in the format @channelusername)
      * `options` - keyword list of options

      Options:
      * `:return_bots` - Pass True to include bots in the returned administrator list
      """
      @spec get_chat_administrators(integer | binary) ::
              {:ok, [ChatMember.t()]} | {:error, Error.t()}
      @spec get_chat_administrators(integer | binary, [{atom, any}]) ::
              {:ok, [ChatMember.t()]} | {:error, Error.t()}
      @spec get_chat_administrators(Client.t(), integer | binary) ::
              {:ok, [ChatMember.t()]} | {:error, Error.t()}
      @spec get_chat_administrators(Client.t(), integer | binary, [{atom, any}]) ::
              {:ok, [ChatMember.t()]} | {:error, Error.t()}
      def get_chat_administrators(chat_id) do
        get_chat_administrators(chat_id, [])
      end

      @doc group: "Chats And Administration"
      def get_chat_administrators(%Client{} = client, chat_id) do
        get_chat_administrators(client, chat_id, [])
      end

      def get_chat_administrators(chat_id, options) do
        api_request("getChatAdministrators", [chat_id: chat_id] ++ options)
      end

      @doc group: "Chats And Administration"
      def get_chat_administrators(%Client{} = client, chat_id, options) do
        api_request(client, "getChatAdministrators", [chat_id: chat_id] ++ options)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to get the number of members in a chat. Returns Int on success.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target supergroup or
      channel (in the format @channelusername)
      """
      @spec get_chat_member_count(integer | binary) :: {:ok, integer} | {:error, Error.t()}
      @spec get_chat_member_count(Client.t(), integer | binary) ::
              {:ok, integer} | {:error, Error.t()}
      def get_chat_member_count(chat_id) do
        api_request("getChatMemberCount", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      def get_chat_member_count(%Client{} = client, chat_id) do
        api_request(client, "getChatMemberCount", chat_id: chat_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to get information about a member of a chat.
      Returns a ChatMember object on success.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target supergroup or
      channel (in the format @channelusername)
      * `user_id` - Unique identifier of the target user
      """
      @spec get_chat_member(integer | binary, integer) ::
              {:ok, ChatMember.t()} | {:error, Error.t()}
      @spec get_chat_member(Client.t(), integer | binary, integer) ::
              {:ok, ChatMember.t()} | {:error, Error.t()}
      def get_chat_member(chat_id, user_id) do
        api_request("getChatMember", chat_id: chat_id, user_id: user_id)
      end

      @doc group: "Chats And Administration"
      def get_chat_member(%Client{} = client, chat_id, user_id) do
        api_request(client, "getChatMember", chat_id: chat_id, user_id: user_id)
      end

      @doc group: "Chats And Administration"
      @doc """
      Use this method to get the list of boosts added to a chat by a user.
      Returns a UserChatBoosts object.

      Args:
      * `chat_id` - Unique identifier for the chat or username of the channel
      * `user_id` - Unique identifier of the target user
      """
      @spec get_user_chat_boosts(integer | binary, integer) ::
              {:ok, UserChatBoosts.t()} | {:error, Error.t()}
      @spec get_user_chat_boosts(Client.t(), integer | binary, integer) ::
              {:ok, UserChatBoosts.t()} | {:error, Error.t()}
      def get_user_chat_boosts(chat_id, user_id) do
        api_request("getUserChatBoosts", chat_id: chat_id, user_id: user_id)
      end

      @doc group: "Chats And Administration"
      def get_user_chat_boosts(%Client{} = client, chat_id, user_id) do
        api_request(client, "getUserChatBoosts", chat_id: chat_id, user_id: user_id)
      end
    end
  end
end
