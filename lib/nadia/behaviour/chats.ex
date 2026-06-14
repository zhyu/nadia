defmodule Nadia.Behaviour.Chats do
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

      @callback ban_chat_member(integer | binary, integer) :: :ok | {:error, Error.t()}
      @callback ban_chat_member(Client.t(), integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback leave_chat(integer | binary) :: :ok | {:error, Error.t()}
      @callback leave_chat(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      @callback unban_chat_member(integer | binary, integer) :: :ok | {:error, Error.t()}
      @callback unban_chat_member(integer | binary, integer, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback unban_chat_member(Client.t(), integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback unban_chat_member(Client.t(), integer | binary, integer, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback restrict_chat_member(integer | binary, integer, map | keyword | struct | binary) ::
                  :ok | {:error, Error.t()}
      @callback restrict_chat_member(
                  integer | binary,
                  integer,
                  map | keyword | struct | binary,
                  [{atom, any}]
                ) ::
                  :ok | {:error, Error.t()}
      @callback restrict_chat_member(
                  Client.t(),
                  integer | binary,
                  integer,
                  map | keyword | struct | binary
                ) ::
                  :ok | {:error, Error.t()}
      @callback restrict_chat_member(
                  Client.t(),
                  integer | binary,
                  integer,
                  map | keyword | struct | binary,
                  [{atom, any}]
                ) ::
                  :ok | {:error, Error.t()}
      @callback promote_chat_member(integer | binary, integer) :: :ok | {:error, Error.t()}
      @callback promote_chat_member(integer | binary, integer, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback promote_chat_member(Client.t(), integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback promote_chat_member(Client.t(), integer | binary, integer, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback set_chat_administrator_custom_title(integer | binary, integer, binary) ::
                  :ok | {:error, Error.t()}
      @callback set_chat_administrator_custom_title(Client.t(), integer | binary, integer, binary) ::
                  :ok | {:error, Error.t()}
      @callback set_chat_member_tag(integer | binary, integer) :: :ok | {:error, Error.t()}
      @callback set_chat_member_tag(integer | binary, integer, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback set_chat_member_tag(Client.t(), integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback set_chat_member_tag(Client.t(), integer | binary, integer, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback ban_chat_sender_chat(integer | binary, integer) :: :ok | {:error, Error.t()}
      @callback ban_chat_sender_chat(Client.t(), integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback unban_chat_sender_chat(integer | binary, integer) :: :ok | {:error, Error.t()}
      @callback unban_chat_sender_chat(Client.t(), integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback set_chat_permissions(integer | binary, map | keyword | struct | binary) ::
                  :ok | {:error, Error.t()}
      @callback set_chat_permissions(
                  integer | binary,
                  map | keyword | struct | binary,
                  [{atom, any}]
                ) ::
                  :ok | {:error, Error.t()}
      @callback set_chat_permissions(
                  Client.t(),
                  integer | binary,
                  map | keyword | struct | binary
                ) ::
                  :ok | {:error, Error.t()}
      @callback set_chat_permissions(
                  Client.t(),
                  integer | binary,
                  map | keyword | struct | binary,
                  [{atom, any}]
                ) ::
                  :ok | {:error, Error.t()}
      @callback approve_chat_join_request(integer | binary, integer) :: :ok | {:error, Error.t()}
      @callback approve_chat_join_request(Client.t(), integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback decline_chat_join_request(integer | binary, integer) :: :ok | {:error, Error.t()}
      @callback decline_chat_join_request(Client.t(), integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback answer_chat_join_request_query(binary, binary) :: :ok | {:error, Error.t()}
      @callback answer_chat_join_request_query(Client.t(), binary, binary) ::
                  :ok | {:error, Error.t()}
      @callback send_chat_join_request_web_app(binary, binary) :: :ok | {:error, Error.t()}
      @callback send_chat_join_request_web_app(Client.t(), binary, binary) ::
                  :ok | {:error, Error.t()}
      @callback delete_chat_photo(integer | binary) :: :ok | {:error, Error.t()}
      @callback delete_chat_photo(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      @callback set_chat_photo(integer | binary, binary) :: :ok | {:error, Error.t()}
      @callback set_chat_photo(Client.t(), integer | binary, binary) :: :ok | {:error, Error.t()}
      @callback set_chat_title(integer | binary, binary) :: :ok | {:error, Error.t()}
      @callback set_chat_title(Client.t(), integer | binary, binary) :: :ok | {:error, Error.t()}
      @callback set_chat_description(integer | binary) :: :ok | {:error, Error.t()}
      @callback set_chat_description(integer | binary, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback set_chat_description(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      @callback set_chat_description(Client.t(), integer | binary, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback unpin_all_chat_messages(integer | binary) :: :ok | {:error, Error.t()}
      @callback unpin_all_chat_messages(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      @callback set_chat_sticker_set(integer | binary, binary) :: :ok | {:error, Error.t()}
      @callback set_chat_sticker_set(Client.t(), integer | binary, binary) ::
                  :ok | {:error, Error.t()}
      @callback delete_chat_sticker_set(integer | binary) :: :ok | {:error, Error.t()}
      @callback delete_chat_sticker_set(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
      @callback get_forum_topic_icon_stickers() :: {:ok, [Sticker.t()]} | {:error, Error.t()}
      @callback get_forum_topic_icon_stickers(Client.t()) ::
                  {:ok, [Sticker.t()]} | {:error, Error.t()}
      @callback create_forum_topic(integer | binary, binary) ::
                  {:ok, ForumTopic.t()} | {:error, Error.t()}
      @callback create_forum_topic(integer | binary, binary, [{atom, any}]) ::
                  {:ok, ForumTopic.t()} | {:error, Error.t()}
      @callback create_forum_topic(Client.t(), integer | binary, binary) ::
                  {:ok, ForumTopic.t()} | {:error, Error.t()}
      @callback create_forum_topic(Client.t(), integer | binary, binary, [{atom, any}]) ::
                  {:ok, ForumTopic.t()} | {:error, Error.t()}
      @callback edit_forum_topic(integer | binary, integer) :: :ok | {:error, Error.t()}
      @callback edit_forum_topic(integer | binary, integer, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback edit_forum_topic(Client.t(), integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback edit_forum_topic(Client.t(), integer | binary, integer, [{atom, any}]) ::
                  :ok | {:error, Error.t()}
      @callback close_forum_topic(integer | binary, integer) :: :ok | {:error, Error.t()}
      @callback close_forum_topic(Client.t(), integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback reopen_forum_topic(integer | binary, integer) :: :ok | {:error, Error.t()}
      @callback reopen_forum_topic(Client.t(), integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback delete_forum_topic(integer | binary, integer) :: :ok | {:error, Error.t()}
      @callback delete_forum_topic(Client.t(), integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback unpin_all_forum_topic_messages(integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback unpin_all_forum_topic_messages(Client.t(), integer | binary, integer) ::
                  :ok | {:error, Error.t()}
      @callback edit_general_forum_topic(integer | binary, binary) :: :ok | {:error, Error.t()}
      @callback edit_general_forum_topic(Client.t(), integer | binary, binary) ::
                  :ok | {:error, Error.t()}
      @callback close_general_forum_topic(integer | binary) :: :ok | {:error, Error.t()}
      @callback close_general_forum_topic(Client.t(), integer | binary) ::
                  :ok | {:error, Error.t()}
      @callback reopen_general_forum_topic(integer | binary) :: :ok | {:error, Error.t()}
      @callback reopen_general_forum_topic(Client.t(), integer | binary) ::
                  :ok | {:error, Error.t()}
      @callback hide_general_forum_topic(integer | binary) :: :ok | {:error, Error.t()}
      @callback hide_general_forum_topic(Client.t(), integer | binary) ::
                  :ok | {:error, Error.t()}
      @callback unhide_general_forum_topic(integer | binary) :: :ok | {:error, Error.t()}
      @callback unhide_general_forum_topic(Client.t(), integer | binary) ::
                  :ok | {:error, Error.t()}
      @callback unpin_all_general_forum_topic_messages(integer | binary) ::
                  :ok | {:error, Error.t()}
      @callback unpin_all_general_forum_topic_messages(Client.t(), integer | binary) ::
                  :ok | {:error, Error.t()}
      @callback get_chat(integer | binary) :: {:ok, Chat.t()} | {:error, Error.t()}
      @callback get_chat(Client.t(), integer | binary) :: {:ok, Chat.t()} | {:error, Error.t()}
      @callback export_chat_invite_link(integer | binary) :: {:ok, binary} | {:error, Error.t()}
      @callback export_chat_invite_link(Client.t(), integer | binary) ::
                  {:ok, binary} | {:error, Error.t()}
      @callback create_chat_invite_link(integer | binary) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback create_chat_invite_link(integer | binary, [{atom, any}] | map) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback create_chat_invite_link(Client.t(), integer | binary) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback create_chat_invite_link(Client.t(), integer | binary, [{atom, any}] | map) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback edit_chat_invite_link(integer | binary, binary) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback edit_chat_invite_link(integer | binary, binary, [{atom, any}] | map) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback edit_chat_invite_link(Client.t(), integer | binary, binary) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback edit_chat_invite_link(Client.t(), integer | binary, binary, [{atom, any}] | map) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback create_chat_subscription_invite_link(integer | binary, integer, integer) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback create_chat_subscription_invite_link(
                  integer | binary,
                  integer,
                  integer,
                  [{atom, any}] | map
                ) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback create_chat_subscription_invite_link(
                  Client.t(),
                  integer | binary,
                  integer,
                  integer
                ) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback create_chat_subscription_invite_link(
                  Client.t(),
                  integer | binary,
                  integer,
                  integer,
                  [{atom, any}] | map
                ) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback edit_chat_subscription_invite_link(integer | binary, binary) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback edit_chat_subscription_invite_link(integer | binary, binary, [{atom, any}] | map) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback edit_chat_subscription_invite_link(Client.t(), integer | binary, binary) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback edit_chat_subscription_invite_link(
                  Client.t(),
                  integer | binary,
                  binary,
                  [{atom, any}] | map
                ) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback revoke_chat_invite_link(integer | binary, binary) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback revoke_chat_invite_link(Client.t(), integer | binary, binary) ::
                  {:ok, ChatInviteLink.t()} | {:error, Error.t()}
      @callback get_chat_administrators(integer | binary) ::
                  {:ok, [ChatMember.t()]} | {:error, Error.t()}
      @callback get_chat_administrators(integer | binary, [{atom, any}]) ::
                  {:ok, [ChatMember.t()]} | {:error, Error.t()}
      @callback get_chat_administrators(Client.t(), integer | binary) ::
                  {:ok, [ChatMember.t()]} | {:error, Error.t()}
      @callback get_chat_administrators(Client.t(), integer | binary, [{atom, any}]) ::
                  {:ok, [ChatMember.t()]} | {:error, Error.t()}
      @callback get_chat_member_count(integer | binary) :: {:ok, integer} | {:error, Error.t()}
      @callback get_chat_member_count(Client.t(), integer | binary) ::
                  {:ok, integer} | {:error, Error.t()}
      @callback get_chat_member(integer | binary, integer) ::
                  {:ok, ChatMember.t()} | {:error, Error.t()}
      @callback get_chat_member(Client.t(), integer | binary, integer) ::
                  {:ok, ChatMember.t()} | {:error, Error.t()}
      @callback get_user_chat_boosts(integer | binary, integer) ::
                  {:ok, UserChatBoosts.t()} | {:error, Error.t()}
      @callback get_user_chat_boosts(Client.t(), integer | binary, integer) ::
                  {:ok, UserChatBoosts.t()} | {:error, Error.t()}
    end
  end
end
