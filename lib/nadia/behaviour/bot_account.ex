defmodule Nadia.Behaviour.BotAccount do
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
      @callback set_my_profile_photo(Nadia.InputProfilePhoto.t() | list | map | struct | binary) ::
                  :ok | {:error, Error.t()}
      @callback set_my_profile_photo(
                  Client.t(),
                  Nadia.InputProfilePhoto.t() | list | map | struct | binary
                ) ::
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
    end
  end
end
