defmodule Nadia.Behaviour do
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
    MenuButton,
    Message,
    MessageId,
    Poll,
    PreparedInlineMessage,
    PreparedKeyboardButton,
    SentGuestMessage,
    Sticker,
    Update,
    User,
    UserChatBoosts,
    UserProfileAudios,
    UserProfilePhotos,
    WebhookInfo
  }

  @callback get_me :: {:ok, User.t()} | {:error, Error.t()}
  @callback get_me(Client.t()) :: {:ok, User.t()} | {:error, Error.t()}
  @callback log_out() :: :ok | {:error, Error.t()}
  @callback log_out(Client.t()) :: :ok | {:error, Error.t()}
  @callback close() :: :ok | {:error, Error.t()}
  @callback close(Client.t()) :: :ok | {:error, Error.t()}
  @callback set_my_commands(list | map | struct | binary) :: :ok | {:error, Error.t()}
  @callback set_my_commands(list | map | struct | binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_my_commands(Client.t(), list | map | struct | binary) ::
              :ok | {:error, Error.t()}
  @callback set_my_commands(Client.t(), list | map | struct | binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback delete_my_commands() :: :ok | {:error, Error.t()}
  @callback delete_my_commands([{atom, any}] | map) :: :ok | {:error, Error.t()}
  @callback delete_my_commands(Client.t()) :: :ok | {:error, Error.t()}
  @callback delete_my_commands(Client.t(), [{atom, any}] | map) :: :ok | {:error, Error.t()}
  @callback get_my_commands() :: {:ok, [BotCommand.t()]} | {:error, Error.t()}
  @callback get_my_commands([{atom, any}] | map) ::
              {:ok, [BotCommand.t()]} | {:error, Error.t()}
  @callback get_my_commands(Client.t()) :: {:ok, [BotCommand.t()]} | {:error, Error.t()}
  @callback get_my_commands(Client.t(), [{atom, any}] | map) ::
              {:ok, [BotCommand.t()]} | {:error, Error.t()}
  @callback set_my_name() :: :ok | {:error, Error.t()}
  @callback set_my_name([{atom, any}] | map) :: :ok | {:error, Error.t()}
  @callback set_my_name(Client.t()) :: :ok | {:error, Error.t()}
  @callback set_my_name(Client.t(), [{atom, any}] | map) :: :ok | {:error, Error.t()}
  @callback get_my_name() :: {:ok, BotName.t()} | {:error, Error.t()}
  @callback get_my_name([{atom, any}] | map) :: {:ok, BotName.t()} | {:error, Error.t()}
  @callback get_my_name(Client.t()) :: {:ok, BotName.t()} | {:error, Error.t()}
  @callback get_my_name(Client.t(), [{atom, any}] | map) ::
              {:ok, BotName.t()} | {:error, Error.t()}
  @callback set_my_description() :: :ok | {:error, Error.t()}
  @callback set_my_description([{atom, any}] | map) :: :ok | {:error, Error.t()}
  @callback set_my_description(Client.t()) :: :ok | {:error, Error.t()}
  @callback set_my_description(Client.t(), [{atom, any}] | map) :: :ok | {:error, Error.t()}
  @callback get_my_description() :: {:ok, BotDescription.t()} | {:error, Error.t()}
  @callback get_my_description([{atom, any}] | map) ::
              {:ok, BotDescription.t()} | {:error, Error.t()}
  @callback get_my_description(Client.t()) :: {:ok, BotDescription.t()} | {:error, Error.t()}
  @callback get_my_description(Client.t(), [{atom, any}] | map) ::
              {:ok, BotDescription.t()} | {:error, Error.t()}
  @callback set_my_short_description() :: :ok | {:error, Error.t()}
  @callback set_my_short_description([{atom, any}] | map) :: :ok | {:error, Error.t()}
  @callback set_my_short_description(Client.t()) :: :ok | {:error, Error.t()}
  @callback set_my_short_description(Client.t(), [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback get_my_short_description() :: {:ok, BotShortDescription.t()} | {:error, Error.t()}
  @callback get_my_short_description([{atom, any}] | map) ::
              {:ok, BotShortDescription.t()} | {:error, Error.t()}
  @callback get_my_short_description(Client.t()) ::
              {:ok, BotShortDescription.t()} | {:error, Error.t()}
  @callback get_my_short_description(Client.t(), [{atom, any}] | map) ::
              {:ok, BotShortDescription.t()} | {:error, Error.t()}
  @callback set_my_profile_photo(list | map | struct | binary) :: :ok | {:error, Error.t()}
  @callback set_my_profile_photo(Client.t(), list | map | struct | binary) ::
              :ok | {:error, Error.t()}
  @callback remove_my_profile_photo() :: :ok | {:error, Error.t()}
  @callback remove_my_profile_photo([{atom, any}] | map) :: :ok | {:error, Error.t()}
  @callback remove_my_profile_photo(Client.t()) :: :ok | {:error, Error.t()}
  @callback remove_my_profile_photo(Client.t(), [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_chat_menu_button() :: :ok | {:error, Error.t()}
  @callback set_chat_menu_button([{atom, any}] | map) :: :ok | {:error, Error.t()}
  @callback set_chat_menu_button(Client.t()) :: :ok | {:error, Error.t()}
  @callback set_chat_menu_button(Client.t(), [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback get_chat_menu_button() :: {:ok, MenuButton.t()} | {:error, Error.t()}
  @callback get_chat_menu_button([{atom, any}] | map) ::
              {:ok, MenuButton.t()} | {:error, Error.t()}
  @callback get_chat_menu_button(Client.t()) :: {:ok, MenuButton.t()} | {:error, Error.t()}
  @callback get_chat_menu_button(Client.t(), [{atom, any}] | map) ::
              {:ok, MenuButton.t()} | {:error, Error.t()}
  @callback set_my_default_administrator_rights() :: :ok | {:error, Error.t()}
  @callback set_my_default_administrator_rights([{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_my_default_administrator_rights(Client.t()) :: :ok | {:error, Error.t()}
  @callback set_my_default_administrator_rights(Client.t(), [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback get_my_default_administrator_rights() ::
              {:ok, ChatAdministratorRights.t()} | {:error, Error.t()}
  @callback get_my_default_administrator_rights([{atom, any}] | map) ::
              {:ok, ChatAdministratorRights.t()} | {:error, Error.t()}
  @callback get_my_default_administrator_rights(Client.t()) ::
              {:ok, ChatAdministratorRights.t()} | {:error, Error.t()}
  @callback get_my_default_administrator_rights(Client.t(), [{atom, any}] | map) ::
              {:ok, ChatAdministratorRights.t()} | {:error, Error.t()}
  @callback set_user_emoji_status(integer) :: :ok | {:error, Error.t()}
  @callback set_user_emoji_status(integer, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_user_emoji_status(Client.t(), integer) :: :ok | {:error, Error.t()}
  @callback set_user_emoji_status(Client.t(), integer, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback send_message(integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_message(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback forward_message(integer | binary, integer | binary, integer) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback forward_message(integer | binary, integer | binary, integer, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback forward_message(Client.t(), integer | binary, integer | binary, integer) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback forward_message(Client.t(), integer | binary, integer | binary, integer, [
              {atom, any}
            ]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback forward_messages(integer | binary, integer | binary, [integer]) ::
              {:ok, [MessageId.t()]} | {:error, Error.t()}
  @callback forward_messages(integer | binary, integer | binary, [integer], [{atom, any}]) ::
              {:ok, [MessageId.t()]} | {:error, Error.t()}
  @callback forward_messages(Client.t(), integer | binary, integer | binary, [integer]) ::
              {:ok, [MessageId.t()]} | {:error, Error.t()}
  @callback forward_messages(Client.t(), integer | binary, integer | binary, [integer], [
              {atom, any}
            ]) ::
              {:ok, [MessageId.t()]} | {:error, Error.t()}
  @callback copy_message(integer | binary, integer | binary, integer) ::
              {:ok, MessageId.t()} | {:error, Error.t()}
  @callback copy_message(integer | binary, integer | binary, integer, [{atom, any}]) ::
              {:ok, MessageId.t()} | {:error, Error.t()}
  @callback copy_message(Client.t(), integer | binary, integer | binary, integer) ::
              {:ok, MessageId.t()} | {:error, Error.t()}
  @callback copy_message(Client.t(), integer | binary, integer | binary, integer, [
              {atom, any}
            ]) ::
              {:ok, MessageId.t()} | {:error, Error.t()}
  @callback copy_messages(integer | binary, integer | binary, [integer]) ::
              {:ok, [MessageId.t()]} | {:error, Error.t()}
  @callback copy_messages(integer | binary, integer | binary, [integer], [{atom, any}]) ::
              {:ok, [MessageId.t()]} | {:error, Error.t()}
  @callback copy_messages(Client.t(), integer | binary, integer | binary, [integer]) ::
              {:ok, [MessageId.t()]} | {:error, Error.t()}
  @callback copy_messages(Client.t(), integer | binary, integer | binary, [integer], [
              {atom, any}
            ]) ::
              {:ok, [MessageId.t()]} | {:error, Error.t()}
  @callback send_photo(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_photo(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_audio(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_audio(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_document(integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_document(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_sticker(integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_sticker(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_video(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_video(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_voice(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_voice(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_video_note(integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_video_note(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_live_photo(integer | binary, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_live_photo(Client.t(), integer | binary, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_media_group(integer | binary, list | map | struct | binary, [{atom, any}]) ::
              {:ok, [Message.t()]} | {:error, Error.t()}
  @callback send_media_group(Client.t(), integer | binary, list | map | struct | binary, [
              {atom, any}
            ]) ::
              {:ok, [Message.t()]} | {:error, Error.t()}
  @callback send_paid_media(integer | binary, integer, list | map | struct | binary, [
              {atom, any}
            ]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_paid_media(Client.t(), integer | binary, integer, list | map | struct | binary, [
              {atom, any}
            ]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_poll(integer | binary, binary, [{atom, any}] | map) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_poll(Client.t(), integer | binary, binary, [{atom, any}] | map) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_dice(integer | binary) :: {:ok, Message.t()} | {:error, Error.t()}
  @callback send_dice(integer | binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_dice(Client.t(), integer | binary) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_dice(Client.t(), integer | binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_checklist(binary, integer | binary, list | map | struct | binary) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_checklist(binary, integer | binary, list | map | struct | binary, [
              {atom, any}
            ]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_checklist(Client.t(), binary, integer | binary, list | map | struct | binary) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_checklist(Client.t(), binary, integer | binary, list | map | struct | binary, [
              {atom, any}
            ]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_message_draft(integer | binary, integer) :: :ok | {:error, Error.t()}
  @callback send_message_draft(integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback send_message_draft(Client.t(), integer | binary, integer) ::
              :ok | {:error, Error.t()}
  @callback send_message_draft(Client.t(), integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback send_animation(integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_animation(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_location(integer, float, float, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_location(Client.t(), integer | binary, float, float, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_venue(integer, float, float, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_venue(Client.t(), integer | binary, float, float, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_contact(integer, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_contact(Client.t(), integer | binary, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback send_chat_action(integer | binary, binary) :: :ok | {:error, Error.t()}
  @callback send_chat_action(integer | binary, binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback send_chat_action(Client.t(), integer | binary, binary) :: :ok | {:error, Error.t()}
  @callback send_chat_action(Client.t(), integer | binary, binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback get_user_profile_photos(integer, [{atom, any}]) ::
              {:ok, UserProfilePhotos.t()} | {:error, Error.t()}
  @callback get_user_profile_photos(Client.t(), integer, [{atom, any}]) ::
              {:ok, UserProfilePhotos.t()} | {:error, Error.t()}
  @callback get_user_profile_audios(integer) ::
              {:ok, UserProfileAudios.t()} | {:error, Error.t()}
  @callback get_user_profile_audios(integer, [{atom, any}] | map) ::
              {:ok, UserProfileAudios.t()} | {:error, Error.t()}
  @callback get_user_profile_audios(Client.t(), integer) ::
              {:ok, UserProfileAudios.t()} | {:error, Error.t()}
  @callback get_user_profile_audios(Client.t(), integer, [{atom, any}] | map) ::
              {:ok, UserProfileAudios.t()} | {:error, Error.t()}
  @callback get_updates([{atom, any}]) :: {:ok, [Update.t()]} | {:error, Error.t()}
  @callback get_updates(Client.t(), [{atom, any}]) :: {:ok, [Update.t()]} | {:error, Error.t()}
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
  @callback ban_chat_member(integer | binary, integer) :: :ok | {:error, Error.t()}
  @callback ban_chat_member(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
  @callback leave_chat(integer | binary) :: :ok | {:error, Error.t()}
  @callback leave_chat(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
  @callback unban_chat_member(integer | binary, integer) :: :ok | {:error, Error.t()}
  @callback unban_chat_member(integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback unban_chat_member(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
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
  @callback set_chat_permissions(Client.t(), integer | binary, map | keyword | struct | binary) ::
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
  @callback delete_chat_photo(integer | binary) :: :ok | {:error, Error.t()}
  @callback delete_chat_photo(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
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
  @callback hide_general_forum_topic(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
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
  @callback get_business_connection(binary) :: {:ok, BusinessConnection.t()} | {:error, Error.t()}
  @callback get_business_connection(Client.t(), binary) ::
              {:ok, BusinessConnection.t()} | {:error, Error.t()}
  @callback read_business_message(binary, integer, integer) :: :ok | {:error, Error.t()}
  @callback read_business_message(Client.t(), binary, integer, integer) ::
              :ok | {:error, Error.t()}
  @callback delete_business_messages(binary, [integer]) :: :ok | {:error, Error.t()}
  @callback delete_business_messages(Client.t(), binary, [integer]) ::
              :ok | {:error, Error.t()}
  @callback set_business_account_name(binary, binary) :: :ok | {:error, Error.t()}
  @callback set_business_account_name(binary, binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_business_account_name(Client.t(), binary, binary) ::
              :ok | {:error, Error.t()}
  @callback set_business_account_name(Client.t(), binary, binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_business_account_username(binary) :: :ok | {:error, Error.t()}
  @callback set_business_account_username(binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_business_account_username(Client.t(), binary) ::
              :ok | {:error, Error.t()}
  @callback set_business_account_username(Client.t(), binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_business_account_bio(binary) :: :ok | {:error, Error.t()}
  @callback set_business_account_bio(binary, [{atom, any}] | map) :: :ok | {:error, Error.t()}
  @callback set_business_account_bio(Client.t(), binary) :: :ok | {:error, Error.t()}
  @callback set_business_account_bio(Client.t(), binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_business_account_profile_photo(binary, list | map | struct | binary) ::
              :ok | {:error, Error.t()}
  @callback set_business_account_profile_photo(
              binary,
              list | map | struct | binary,
              [{atom, any}] | map
            ) :: :ok | {:error, Error.t()}
  @callback set_business_account_profile_photo(
              Client.t(),
              binary,
              list | map | struct | binary
            ) :: :ok | {:error, Error.t()}
  @callback set_business_account_profile_photo(
              Client.t(),
              binary,
              list | map | struct | binary,
              [{atom, any}] | map
            ) :: :ok | {:error, Error.t()}
  @callback remove_business_account_profile_photo(binary) :: :ok | {:error, Error.t()}
  @callback remove_business_account_profile_photo(binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback remove_business_account_profile_photo(Client.t(), binary) ::
              :ok | {:error, Error.t()}
  @callback remove_business_account_profile_photo(Client.t(), binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_business_account_gift_settings(binary, boolean, list | map | struct | binary) ::
              :ok | {:error, Error.t()}
  @callback set_business_account_gift_settings(
              Client.t(),
              binary,
              boolean,
              list | map | struct | binary
            ) :: :ok | {:error, Error.t()}
  @callback transfer_business_account_stars(binary, integer) :: :ok | {:error, Error.t()}
  @callback transfer_business_account_stars(Client.t(), binary, integer) ::
              :ok | {:error, Error.t()}
  @callback get_managed_bot_token(integer) :: {:ok, binary} | {:error, Error.t()}
  @callback get_managed_bot_token(Client.t(), integer) :: {:ok, binary} | {:error, Error.t()}
  @callback replace_managed_bot_token(integer) :: {:ok, binary} | {:error, Error.t()}
  @callback replace_managed_bot_token(Client.t(), integer) :: {:ok, binary} | {:error, Error.t()}
  @callback get_managed_bot_access_settings(integer) ::
              {:ok, BotAccessSettings.t()} | {:error, Error.t()}
  @callback get_managed_bot_access_settings(Client.t(), integer) ::
              {:ok, BotAccessSettings.t()} | {:error, Error.t()}
  @callback set_managed_bot_access_settings(integer, boolean, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback set_managed_bot_access_settings(Client.t(), integer, boolean, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback get_user_personal_chat_messages(integer, integer) ::
              {:ok, [Message.t()]} | {:error, Error.t()}
  @callback get_user_personal_chat_messages(Client.t(), integer, integer) ::
              {:ok, [Message.t()]} | {:error, Error.t()}
  @callback delete_messages(integer | binary, [integer]) :: :ok | {:error, Error.t()}
  @callback delete_messages(Client.t(), integer | binary, [integer]) ::
              :ok | {:error, Error.t()}
  @callback delete_message_reaction(integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback delete_message_reaction(Client.t(), integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback delete_all_message_reactions(integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback delete_all_message_reactions(Client.t(), integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback set_message_reaction(integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback set_message_reaction(Client.t(), integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback answer_callback_query(binary, [{atom, any}]) :: :ok | {:error, Error.t()}
  @callback answer_callback_query(Client.t(), binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback answer_guest_query(binary, Nadia.Model.InlineQueryResult.t(), [{atom, any}]) ::
              {:ok, SentGuestMessage.t()} | {:error, Error.t()}
  @callback answer_guest_query(Client.t(), binary, Nadia.Model.InlineQueryResult.t(), [
              {atom, any}
            ]) ::
              {:ok, SentGuestMessage.t()} | {:error, Error.t()}
  @callback save_prepared_inline_message(integer, Nadia.Model.InlineQueryResult.t()) ::
              {:ok, PreparedInlineMessage.t()} | {:error, Error.t()}
  @callback save_prepared_inline_message(
              integer,
              Nadia.Model.InlineQueryResult.t(),
              [{atom, any}] | map
            ) ::
              {:ok, PreparedInlineMessage.t()} | {:error, Error.t()}
  @callback save_prepared_inline_message(
              Client.t(),
              integer,
              Nadia.Model.InlineQueryResult.t()
            ) ::
              {:ok, PreparedInlineMessage.t()} | {:error, Error.t()}
  @callback save_prepared_inline_message(
              Client.t(),
              integer,
              Nadia.Model.InlineQueryResult.t(),
              [{atom, any}] | map
            ) ::
              {:ok, PreparedInlineMessage.t()} | {:error, Error.t()}
  @callback save_prepared_keyboard_button(integer, list | map | struct | binary) ::
              {:ok, PreparedKeyboardButton.t()} | {:error, Error.t()}
  @callback save_prepared_keyboard_button(Client.t(), integer, list | map | struct | binary) ::
              {:ok, PreparedKeyboardButton.t()} | {:error, Error.t()}
  @callback edit_message_text(integer | binary, integer, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_text(Client.t(), integer | binary, integer, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_caption(integer | binary, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_caption(Client.t(), integer | binary, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_reply_markup(integer | binary, integer, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_reply_markup(Client.t(), integer | binary, integer, binary, [
              {atom, any}
            ]) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_media(list | map | struct | binary, [{atom, any}]) ::
              :ok | {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_media(Client.t(), list | map | struct | binary, [{atom, any}]) ::
              :ok | {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_live_location(float, float, [{atom, any}]) ::
              :ok | {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_live_location(Client.t(), float, float, [{atom, any}]) ::
              :ok | {:ok, Message.t()} | {:error, Error.t()}
  @callback stop_message_live_location([{atom, any}]) ::
              :ok | {:ok, Message.t()} | {:error, Error.t()}
  @callback stop_message_live_location(Client.t(), [{atom, any}]) ::
              :ok | {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_checklist(
              binary,
              integer | binary,
              integer,
              list | map | struct | binary
            ) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_checklist(
              binary,
              integer | binary,
              integer,
              list | map | struct | binary,
              [{atom, any}]
            ) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_checklist(
              Client.t(),
              binary,
              integer | binary,
              integer,
              list | map | struct | binary
            ) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback edit_message_checklist(
              Client.t(),
              binary,
              integer | binary,
              integer,
              list | map | struct | binary,
              [{atom, any}]
            ) ::
              {:ok, Message.t()} | {:error, Error.t()}
  @callback stop_poll(integer | binary, integer) :: {:ok, Poll.t()} | {:error, Error.t()}
  @callback stop_poll(integer | binary, integer, [{atom, any}]) ::
              {:ok, Poll.t()} | {:error, Error.t()}
  @callback stop_poll(Client.t(), integer | binary, integer) ::
              {:ok, Poll.t()} | {:error, Error.t()}
  @callback stop_poll(Client.t(), integer | binary, integer, [{atom, any}]) ::
              {:ok, Poll.t()} | {:error, Error.t()}
  @callback approve_suggested_post(integer, integer) :: :ok | {:error, Error.t()}
  @callback approve_suggested_post(integer, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback approve_suggested_post(Client.t(), integer, integer) ::
              :ok | {:error, Error.t()}
  @callback approve_suggested_post(Client.t(), integer, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback decline_suggested_post(integer, integer) :: :ok | {:error, Error.t()}
  @callback decline_suggested_post(integer, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback decline_suggested_post(Client.t(), integer, integer) ::
              :ok | {:error, Error.t()}
  @callback decline_suggested_post(Client.t(), integer, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback answer_inline_query(binary, [Nadia.Model.InlineQueryResult.t()], [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback answer_inline_query(Client.t(), binary, [Nadia.Model.InlineQueryResult.t()], [
              {atom, any}
            ]) ::
              :ok | {:error, Error.t()}
  @callback get_sticker_set(Client.t(), binary) ::
              {:ok, Nadia.Model.StickerSet.t()} | {:error, Error.t()}
  @callback get_custom_emoji_stickers([binary] | binary) ::
              {:ok, [Sticker.t()]} | {:error, Error.t()}
  @callback get_custom_emoji_stickers(Client.t(), [binary] | binary) ::
              {:ok, [Sticker.t()]} | {:error, Error.t()}
  @callback upload_sticker_file(Client.t(), integer, binary) ::
              {:ok, File.t()} | {:error, Error.t()}
  @callback create_new_sticker_set(Client.t(), integer, binary, binary, binary, binary, [
              {atom, any}
            ]) ::
              :ok | {:error, Error.t()}
  @callback add_sticker_to_set(Client.t(), integer, binary, binary, binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback replace_sticker_in_set(integer, binary, binary, list | map | struct | binary) ::
              :ok | {:error, Error.t()}
  @callback replace_sticker_in_set(
              Client.t(),
              integer,
              binary,
              binary,
              list | map | struct | binary
            ) ::
              :ok | {:error, Error.t()}
  @callback set_sticker_emoji_list(binary, [binary] | binary) :: :ok | {:error, Error.t()}
  @callback set_sticker_emoji_list(Client.t(), binary, [binary] | binary) ::
              :ok | {:error, Error.t()}
  @callback set_sticker_keywords(binary) :: :ok | {:error, Error.t()}
  @callback set_sticker_keywords(binary, [{atom, any}] | map) :: :ok | {:error, Error.t()}
  @callback set_sticker_keywords(Client.t(), binary) :: :ok | {:error, Error.t()}
  @callback set_sticker_keywords(Client.t(), binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_sticker_mask_position(binary) :: :ok | {:error, Error.t()}
  @callback set_sticker_mask_position(binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_sticker_mask_position(Client.t(), binary) :: :ok | {:error, Error.t()}
  @callback set_sticker_mask_position(Client.t(), binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_sticker_set_title(binary, binary) :: :ok | {:error, Error.t()}
  @callback set_sticker_set_title(Client.t(), binary, binary) :: :ok | {:error, Error.t()}
  @callback set_sticker_set_thumbnail(binary, integer) :: :ok | {:error, Error.t()}
  @callback set_sticker_set_thumbnail(binary, integer, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_sticker_set_thumbnail(Client.t(), binary, integer) ::
              :ok | {:error, Error.t()}
  @callback set_sticker_set_thumbnail(Client.t(), binary, integer, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_custom_emoji_sticker_set_thumbnail(binary) :: :ok | {:error, Error.t()}
  @callback set_custom_emoji_sticker_set_thumbnail(binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_custom_emoji_sticker_set_thumbnail(Client.t(), binary) ::
              :ok | {:error, Error.t()}
  @callback set_custom_emoji_sticker_set_thumbnail(Client.t(), binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
  @callback set_sticker_position_in_set(Client.t(), binary, integer) ::
              :ok | {:error, Error.t()}
  @callback delete_sticker_from_set(Client.t(), binary) :: :ok | {:error, Error.t()}
  @callback delete_sticker_set(binary) :: :ok | {:error, Error.t()}
  @callback delete_sticker_set(Client.t(), binary) :: :ok | {:error, Error.t()}
  @callback pin_chat_message(Client.t(), integer | binary, integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
  @callback unpin_chat_message(integer | binary) :: :ok | {:error, Error.t()}
  @callback unpin_chat_message(integer | binary, [{atom, any}]) :: :ok | {:error, Error.t()}
  @callback unpin_chat_message(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
  @callback unpin_chat_message(Client.t(), integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}

  @optional_callbacks get_me: 1,
                      log_out: 0,
                      log_out: 1,
                      close: 0,
                      close: 1,
                      set_my_commands: 1,
                      set_my_commands: 2,
                      set_my_commands: 3,
                      delete_my_commands: 0,
                      delete_my_commands: 1,
                      delete_my_commands: 2,
                      get_my_commands: 0,
                      get_my_commands: 1,
                      get_my_commands: 2,
                      set_my_name: 0,
                      set_my_name: 1,
                      set_my_name: 2,
                      get_my_name: 0,
                      get_my_name: 1,
                      get_my_name: 2,
                      set_my_description: 0,
                      set_my_description: 1,
                      set_my_description: 2,
                      get_my_description: 0,
                      get_my_description: 1,
                      get_my_description: 2,
                      set_my_short_description: 0,
                      set_my_short_description: 1,
                      set_my_short_description: 2,
                      get_my_short_description: 0,
                      get_my_short_description: 1,
                      get_my_short_description: 2,
                      set_my_profile_photo: 1,
                      set_my_profile_photo: 2,
                      remove_my_profile_photo: 0,
                      remove_my_profile_photo: 1,
                      remove_my_profile_photo: 2,
                      set_chat_menu_button: 0,
                      set_chat_menu_button: 1,
                      set_chat_menu_button: 2,
                      get_chat_menu_button: 0,
                      get_chat_menu_button: 1,
                      get_chat_menu_button: 2,
                      set_my_default_administrator_rights: 0,
                      set_my_default_administrator_rights: 1,
                      set_my_default_administrator_rights: 2,
                      get_my_default_administrator_rights: 0,
                      get_my_default_administrator_rights: 1,
                      get_my_default_administrator_rights: 2,
                      set_user_emoji_status: 1,
                      set_user_emoji_status: 2,
                      set_user_emoji_status: 3,
                      send_message: 4,
                      forward_message: 4,
                      forward_message: 5,
                      forward_messages: 4,
                      forward_messages: 5,
                      copy_message: 4,
                      copy_message: 5,
                      copy_messages: 4,
                      copy_messages: 5,
                      send_photo: 4,
                      send_audio: 4,
                      send_document: 4,
                      send_sticker: 4,
                      send_video: 4,
                      send_voice: 4,
                      send_video_note: 4,
                      send_live_photo: 5,
                      send_media_group: 4,
                      send_paid_media: 5,
                      send_poll: 4,
                      send_dice: 2,
                      send_dice: 3,
                      send_checklist: 4,
                      send_checklist: 5,
                      send_message_draft: 3,
                      send_message_draft: 4,
                      send_animation: 4,
                      send_location: 5,
                      send_venue: 7,
                      send_contact: 5,
                      send_chat_action: 3,
                      send_chat_action: 4,
                      get_user_profile_photos: 3,
                      get_user_profile_audios: 1,
                      get_user_profile_audios: 2,
                      get_user_profile_audios: 3,
                      get_updates: 2,
                      set_webhook: 2,
                      delete_webhook: 1,
                      delete_webhook: 2,
                      get_webhook_info: 1,
                      get_file: 2,
                      get_file_link: 2,
                      ban_chat_member: 3,
                      leave_chat: 2,
                      unban_chat_member: 3,
                      unban_chat_member: 4,
                      restrict_chat_member: 4,
                      restrict_chat_member: 5,
                      promote_chat_member: 3,
                      promote_chat_member: 4,
                      set_chat_administrator_custom_title: 4,
                      set_chat_member_tag: 3,
                      set_chat_member_tag: 4,
                      ban_chat_sender_chat: 3,
                      unban_chat_sender_chat: 3,
                      set_chat_permissions: 3,
                      set_chat_permissions: 4,
                      approve_chat_join_request: 3,
                      decline_chat_join_request: 3,
                      delete_chat_photo: 2,
                      set_chat_title: 3,
                      set_chat_description: 2,
                      set_chat_description: 3,
                      unpin_all_chat_messages: 2,
                      set_chat_sticker_set: 3,
                      delete_chat_sticker_set: 2,
                      get_forum_topic_icon_stickers: 1,
                      create_forum_topic: 3,
                      create_forum_topic: 4,
                      edit_forum_topic: 3,
                      edit_forum_topic: 4,
                      close_forum_topic: 3,
                      reopen_forum_topic: 3,
                      delete_forum_topic: 3,
                      unpin_all_forum_topic_messages: 3,
                      edit_general_forum_topic: 3,
                      close_general_forum_topic: 2,
                      reopen_general_forum_topic: 2,
                      hide_general_forum_topic: 2,
                      unhide_general_forum_topic: 2,
                      unpin_all_general_forum_topic_messages: 2,
                      get_chat: 2,
                      export_chat_invite_link: 1,
                      export_chat_invite_link: 2,
                      create_chat_invite_link: 1,
                      create_chat_invite_link: 2,
                      create_chat_invite_link: 3,
                      edit_chat_invite_link: 2,
                      edit_chat_invite_link: 3,
                      edit_chat_invite_link: 4,
                      create_chat_subscription_invite_link: 3,
                      create_chat_subscription_invite_link: 4,
                      create_chat_subscription_invite_link: 5,
                      edit_chat_subscription_invite_link: 2,
                      edit_chat_subscription_invite_link: 3,
                      edit_chat_subscription_invite_link: 4,
                      revoke_chat_invite_link: 2,
                      revoke_chat_invite_link: 3,
                      get_chat_administrators: 2,
                      get_chat_administrators: 3,
                      get_chat_member_count: 2,
                      get_chat_member: 3,
                      get_user_chat_boosts: 3,
                      get_business_connection: 2,
                      read_business_message: 3,
                      read_business_message: 4,
                      delete_business_messages: 2,
                      delete_business_messages: 3,
                      set_business_account_name: 2,
                      set_business_account_name: 3,
                      set_business_account_name: 4,
                      set_business_account_username: 1,
                      set_business_account_username: 2,
                      set_business_account_username: 3,
                      set_business_account_bio: 1,
                      set_business_account_bio: 2,
                      set_business_account_bio: 3,
                      set_business_account_profile_photo: 2,
                      set_business_account_profile_photo: 3,
                      set_business_account_profile_photo: 4,
                      remove_business_account_profile_photo: 1,
                      remove_business_account_profile_photo: 2,
                      remove_business_account_profile_photo: 3,
                      set_business_account_gift_settings: 3,
                      set_business_account_gift_settings: 4,
                      transfer_business_account_stars: 2,
                      transfer_business_account_stars: 3,
                      get_managed_bot_token: 2,
                      replace_managed_bot_token: 2,
                      get_managed_bot_access_settings: 2,
                      set_managed_bot_access_settings: 4,
                      get_user_personal_chat_messages: 3,
                      delete_messages: 3,
                      delete_message_reaction: 4,
                      delete_all_message_reactions: 3,
                      set_message_reaction: 4,
                      answer_callback_query: 3,
                      answer_guest_query: 4,
                      save_prepared_inline_message: 2,
                      save_prepared_inline_message: 3,
                      save_prepared_inline_message: 4,
                      save_prepared_keyboard_button: 2,
                      save_prepared_keyboard_button: 3,
                      edit_message_text: 6,
                      edit_message_caption: 5,
                      edit_message_reply_markup: 5,
                      edit_message_media: 2,
                      edit_message_media: 3,
                      edit_message_live_location: 4,
                      stop_message_live_location: 2,
                      edit_message_checklist: 5,
                      edit_message_checklist: 6,
                      stop_poll: 3,
                      stop_poll: 4,
                      approve_suggested_post: 3,
                      approve_suggested_post: 4,
                      decline_suggested_post: 3,
                      decline_suggested_post: 4,
                      answer_inline_query: 4,
                      get_sticker_set: 2,
                      get_custom_emoji_stickers: 1,
                      get_custom_emoji_stickers: 2,
                      upload_sticker_file: 3,
                      create_new_sticker_set: 7,
                      add_sticker_to_set: 6,
                      replace_sticker_in_set: 4,
                      replace_sticker_in_set: 5,
                      set_sticker_emoji_list: 2,
                      set_sticker_emoji_list: 3,
                      set_sticker_keywords: 1,
                      set_sticker_keywords: 2,
                      set_sticker_keywords: 3,
                      set_sticker_mask_position: 1,
                      set_sticker_mask_position: 2,
                      set_sticker_mask_position: 3,
                      set_sticker_set_title: 2,
                      set_sticker_set_title: 3,
                      set_sticker_set_thumbnail: 2,
                      set_sticker_set_thumbnail: 3,
                      set_sticker_set_thumbnail: 4,
                      set_custom_emoji_sticker_set_thumbnail: 1,
                      set_custom_emoji_sticker_set_thumbnail: 2,
                      set_custom_emoji_sticker_set_thumbnail: 3,
                      set_sticker_position_in_set: 3,
                      delete_sticker_from_set: 2,
                      delete_sticker_set: 1,
                      delete_sticker_set: 2,
                      pin_chat_message: 4,
                      unpin_chat_message: 2,
                      unpin_chat_message: 3
end
