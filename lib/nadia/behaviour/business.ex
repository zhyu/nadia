defmodule Nadia.Behaviour.Business do
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

      @callback get_business_connection(binary) ::
                  {:ok, BusinessConnection.t()} | {:error, Error.t()}
      @callback get_business_connection(Client.t(), binary) ::
                  {:ok, BusinessConnection.t()} | {:error, Error.t()}
      @callback get_business_account_star_balance(binary) ::
                  {:ok, StarAmount.t()} | {:error, Error.t()}
      @callback get_business_account_star_balance(Client.t(), binary) ::
                  {:ok, StarAmount.t()} | {:error, Error.t()}
      @callback get_business_account_gifts(binary) :: {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @callback get_business_account_gifts(binary, [{atom, any}] | map) ::
                  {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @callback get_business_account_gifts(Client.t(), binary) ::
                  {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @callback get_business_account_gifts(Client.t(), binary, [{atom, any}] | map) ::
                  {:ok, OwnedGifts.t()} | {:error, Error.t()}
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
      @callback set_business_account_profile_photo(
                  binary,
                  Nadia.InputProfilePhoto.t() | list | map | struct | binary
                ) ::
                  :ok | {:error, Error.t()}
      @callback set_business_account_profile_photo(
                  binary,
                  Nadia.InputProfilePhoto.t() | list | map | struct | binary,
                  [{atom, any}] | map
                ) :: :ok | {:error, Error.t()}
      @callback set_business_account_profile_photo(
                  Client.t(),
                  binary,
                  Nadia.InputProfilePhoto.t() | list | map | struct | binary
                ) :: :ok | {:error, Error.t()}
      @callback set_business_account_profile_photo(
                  Client.t(),
                  binary,
                  Nadia.InputProfilePhoto.t() | list | map | struct | binary,
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
      @callback convert_gift_to_stars(binary, binary) :: :ok | {:error, Error.t()}
      @callback convert_gift_to_stars(Client.t(), binary, binary) :: :ok | {:error, Error.t()}
      @callback upgrade_gift(binary, binary) :: :ok | {:error, Error.t()}
      @callback upgrade_gift(binary, binary, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback upgrade_gift(Client.t(), binary, binary) :: :ok | {:error, Error.t()}
      @callback upgrade_gift(Client.t(), binary, binary, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback transfer_gift(binary, binary, integer) :: :ok | {:error, Error.t()}
      @callback transfer_gift(binary, binary, integer, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback transfer_gift(Client.t(), binary, binary, integer) :: :ok | {:error, Error.t()}
      @callback transfer_gift(Client.t(), binary, binary, integer, [{atom, any}] | map) ::
                  :ok | {:error, Error.t()}
      @callback post_story(
                  binary,
                  Nadia.InputStoryContent.t() | list | map | struct | binary,
                  integer
                ) ::
                  {:ok, Story.t()} | {:error, Error.t()}
      @callback post_story(
                  binary,
                  Nadia.InputStoryContent.t() | list | map | struct | binary,
                  integer,
                  [{atom, any}] | map
                ) ::
                  {:ok, Story.t()} | {:error, Error.t()}
      @callback post_story(
                  Client.t(),
                  binary,
                  Nadia.InputStoryContent.t() | list | map | struct | binary,
                  integer
                ) ::
                  {:ok, Story.t()} | {:error, Error.t()}
      @callback post_story(
                  Client.t(),
                  binary,
                  Nadia.InputStoryContent.t() | list | map | struct | binary,
                  integer,
                  [{atom, any}] | map
                ) :: {:ok, Story.t()} | {:error, Error.t()}
      @callback edit_story(
                  binary,
                  integer,
                  Nadia.InputStoryContent.t() | list | map | struct | binary
                ) ::
                  {:ok, Story.t()} | {:error, Error.t()}
      @callback edit_story(
                  binary,
                  integer,
                  Nadia.InputStoryContent.t() | list | map | struct | binary,
                  [{atom, any}] | map
                ) ::
                  {:ok, Story.t()} | {:error, Error.t()}
      @callback edit_story(
                  Client.t(),
                  binary,
                  integer,
                  Nadia.InputStoryContent.t() | list | map | struct | binary
                ) ::
                  {:ok, Story.t()} | {:error, Error.t()}
      @callback edit_story(
                  Client.t(),
                  binary,
                  integer,
                  Nadia.InputStoryContent.t() | list | map | struct | binary,
                  [{atom, any}] | map
                ) :: {:ok, Story.t()} | {:error, Error.t()}
      @callback delete_story(binary, integer) :: :ok | {:error, Error.t()}
      @callback delete_story(Client.t(), binary, integer) :: :ok | {:error, Error.t()}
      @callback repost_story(binary, integer, integer, integer) ::
                  {:ok, Story.t()} | {:error, Error.t()}
      @callback repost_story(binary, integer, integer, integer, [{atom, any}] | map) ::
                  {:ok, Story.t()} | {:error, Error.t()}
      @callback repost_story(Client.t(), binary, integer, integer, integer) ::
                  {:ok, Story.t()} | {:error, Error.t()}
      @callback repost_story(Client.t(), binary, integer, integer, integer, [{atom, any}] | map) ::
                  {:ok, Story.t()} | {:error, Error.t()}
    end
  end
end
