defmodule Nadia.Methods.BotAccount do
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

      @doc group: "Bot Account"
      @doc """
      A simple method for testing your bot's auth token. Requires no parameters.
      Returns basic information about the bot in form of a User object.
      """
      @spec get_me :: {:ok, User.t()} | {:error, Error.t()}
      @spec get_me(Client.t()) :: {:ok, User.t()} | {:error, Error.t()}
      def get_me, do: api_request("getMe")
      @doc group: "Bot Account"
      def get_me(%Client{} = client), do: api_request(client, "getMe")

      @doc group: "Bot Account"
      @doc """
      Use this method to log out from the cloud Bot API server before launching the
      bot locally.
      Returns `:ok` on success.
      """
      @spec log_out() :: :ok | {:error, Error.t()}
      @spec log_out(Client.t()) :: :ok | {:error, Error.t()}
      def log_out, do: api_request("logOut")
      @doc group: "Bot Account"
      def log_out(%Client{} = client), do: api_request(client, "logOut")

      @doc group: "Bot Account"
      @doc """
      Use this method to close the bot instance before moving it from one local
      server to another.
      Returns `:ok` on success.
      """
      @spec close() :: :ok | {:error, Error.t()}
      @spec close(Client.t()) :: :ok | {:error, Error.t()}
      def close, do: api_request("close")
      @doc group: "Bot Account"
      def close(%Client{} = client), do: api_request(client, "close")

      @doc group: "Bot Account"
      @doc """
      Use this method to change the list of the bot's commands.
      Returns `:ok` on success.
      """
      @spec set_my_commands(list | map | struct | binary) :: :ok | {:error, Error.t()}
      @spec set_my_commands(list | map | struct | binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      @spec set_my_commands(Client.t(), list | map | struct | binary) ::
              :ok | {:error, Error.t()}
      @spec set_my_commands(Client.t(), list | map | struct | binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      def set_my_commands(commands), do: set_my_commands(commands, [])

      @doc group: "Bot Account"
      def set_my_commands(%Client{} = client, commands) do
        set_my_commands(client, commands, [])
      end

      def set_my_commands(commands, options) do
        api_request(
          "setMyCommands",
          request_options(
            [commands: encode_json_payload(commands)],
            encode_json_option(options, :scope)
          )
        )
      end

      @doc group: "Bot Account"
      def set_my_commands(%Client{} = client, commands, options) do
        api_request(
          client,
          "setMyCommands",
          request_options(
            [commands: encode_json_payload(commands)],
            encode_json_option(options, :scope)
          )
        )
      end

      @doc group: "Bot Account"
      @doc """
      Use this method to delete the list of the bot's commands for the given scope
      and user language.
      Returns `:ok` on success.
      """
      @spec delete_my_commands() :: :ok | {:error, Error.t()}
      @spec delete_my_commands([{atom, any}] | map) :: :ok | {:error, Error.t()}
      @spec delete_my_commands(Client.t()) :: :ok | {:error, Error.t()}
      @spec delete_my_commands(Client.t(), [{atom, any}] | map) :: :ok | {:error, Error.t()}
      def delete_my_commands(), do: delete_my_commands([])
      @doc group: "Bot Account"
      def delete_my_commands(%Client{} = client), do: delete_my_commands(client, [])

      def delete_my_commands(options),
        do: api_request("deleteMyCommands", encode_json_option(options, :scope))

      @doc group: "Bot Account"
      def delete_my_commands(%Client{} = client, options) do
        api_request(client, "deleteMyCommands", encode_json_option(options, :scope))
      end

      @doc group: "Bot Account"
      @doc """
      Use this method to get the current list of the bot's commands for the given
      scope and user language.
      Returns a list of `Nadia.Model.BotCommand` objects on success.
      """
      @spec get_my_commands() :: {:ok, [BotCommand.t()]} | {:error, Error.t()}
      @spec get_my_commands([{atom, any}] | map) :: {:ok, [BotCommand.t()]} | {:error, Error.t()}
      @spec get_my_commands(Client.t()) :: {:ok, [BotCommand.t()]} | {:error, Error.t()}
      @spec get_my_commands(Client.t(), [{atom, any}] | map) ::
              {:ok, [BotCommand.t()]} | {:error, Error.t()}
      def get_my_commands(), do: get_my_commands([])
      @doc group: "Bot Account"
      def get_my_commands(%Client{} = client), do: get_my_commands(client, [])

      def get_my_commands(options) do
        api_request("getMyCommands", encode_json_option(options, :scope))
      end

      @doc group: "Bot Account"
      def get_my_commands(%Client{} = client, options) do
        api_request(client, "getMyCommands", encode_json_option(options, :scope))
      end

      @doc group: "Bot Account"
      @doc """
      Use this method to change the bot's name.
      Returns `:ok` on success.
      """
      @spec set_my_name() :: :ok | {:error, Error.t()}
      @spec set_my_name([{atom, any}] | map) :: :ok | {:error, Error.t()}
      @spec set_my_name(Client.t()) :: :ok | {:error, Error.t()}
      @spec set_my_name(Client.t(), [{atom, any}] | map) :: :ok | {:error, Error.t()}
      def set_my_name(), do: set_my_name([])
      @doc group: "Bot Account"
      def set_my_name(%Client{} = client), do: set_my_name(client, [])
      def set_my_name(options), do: api_request("setMyName", options)
      @doc group: "Bot Account"
      def set_my_name(%Client{} = client, options), do: api_request(client, "setMyName", options)

      @doc group: "Bot Account"
      @doc """
      Use this method to get the current bot name for the given user language.
      Returns a `Nadia.Model.BotName` on success.
      """
      @spec get_my_name() :: {:ok, BotName.t()} | {:error, Error.t()}
      @spec get_my_name([{atom, any}] | map) :: {:ok, BotName.t()} | {:error, Error.t()}
      @spec get_my_name(Client.t()) :: {:ok, BotName.t()} | {:error, Error.t()}
      @spec get_my_name(Client.t(), [{atom, any}] | map) ::
              {:ok, BotName.t()} | {:error, Error.t()}
      def get_my_name(), do: get_my_name([])
      @doc group: "Bot Account"
      def get_my_name(%Client{} = client), do: get_my_name(client, [])
      def get_my_name(options), do: api_request("getMyName", options)
      @doc group: "Bot Account"
      def get_my_name(%Client{} = client, options), do: api_request(client, "getMyName", options)

      @doc group: "Bot Account"
      @doc """
      Use this method to change the bot's description.
      Returns `:ok` on success.
      """
      @spec set_my_description() :: :ok | {:error, Error.t()}
      @spec set_my_description([{atom, any}] | map) :: :ok | {:error, Error.t()}
      @spec set_my_description(Client.t()) :: :ok | {:error, Error.t()}
      @spec set_my_description(Client.t(), [{atom, any}] | map) :: :ok | {:error, Error.t()}
      def set_my_description(), do: set_my_description([])
      @doc group: "Bot Account"
      def set_my_description(%Client{} = client), do: set_my_description(client, [])
      def set_my_description(options), do: api_request("setMyDescription", options)

      @doc group: "Bot Account"
      def set_my_description(%Client{} = client, options) do
        api_request(client, "setMyDescription", options)
      end

      @doc group: "Bot Account"
      @doc """
      Use this method to get the current bot description for the given user language.
      Returns a `Nadia.Model.BotDescription` on success.
      """
      @spec get_my_description() :: {:ok, BotDescription.t()} | {:error, Error.t()}
      @spec get_my_description([{atom, any}] | map) ::
              {:ok, BotDescription.t()} | {:error, Error.t()}
      @spec get_my_description(Client.t()) :: {:ok, BotDescription.t()} | {:error, Error.t()}
      @spec get_my_description(Client.t(), [{atom, any}] | map) ::
              {:ok, BotDescription.t()} | {:error, Error.t()}
      def get_my_description(), do: get_my_description([])
      @doc group: "Bot Account"
      def get_my_description(%Client{} = client), do: get_my_description(client, [])
      def get_my_description(options), do: api_request("getMyDescription", options)

      @doc group: "Bot Account"
      def get_my_description(%Client{} = client, options) do
        api_request(client, "getMyDescription", options)
      end

      @doc group: "Bot Account"
      @doc """
      Use this method to change the bot's short description.
      Returns `:ok` on success.
      """
      @spec set_my_short_description() :: :ok | {:error, Error.t()}
      @spec set_my_short_description([{atom, any}] | map) :: :ok | {:error, Error.t()}
      @spec set_my_short_description(Client.t()) :: :ok | {:error, Error.t()}
      @spec set_my_short_description(Client.t(), [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      def set_my_short_description(), do: set_my_short_description([])
      @doc group: "Bot Account"
      def set_my_short_description(%Client{} = client), do: set_my_short_description(client, [])
      def set_my_short_description(options), do: api_request("setMyShortDescription", options)

      @doc group: "Bot Account"
      def set_my_short_description(%Client{} = client, options) do
        api_request(client, "setMyShortDescription", options)
      end

      @doc group: "Bot Account"
      @doc """
      Use this method to get the current bot short description for the given user
      language.
      Returns a `Nadia.Model.BotShortDescription` on success.
      """
      @spec get_my_short_description() :: {:ok, BotShortDescription.t()} | {:error, Error.t()}
      @spec get_my_short_description([{atom, any}] | map) ::
              {:ok, BotShortDescription.t()} | {:error, Error.t()}
      @spec get_my_short_description(Client.t()) ::
              {:ok, BotShortDescription.t()} | {:error, Error.t()}
      @spec get_my_short_description(Client.t(), [{atom, any}] | map) ::
              {:ok, BotShortDescription.t()} | {:error, Error.t()}
      def get_my_short_description(), do: get_my_short_description([])
      @doc group: "Bot Account"
      def get_my_short_description(%Client{} = client), do: get_my_short_description(client, [])
      def get_my_short_description(options), do: api_request("getMyShortDescription", options)

      @doc group: "Bot Account"
      def get_my_short_description(%Client{} = client, options) do
        api_request(client, "getMyShortDescription", options)
      end

      @doc group: "Bot Account"
      @doc """
      Use this method to change the bot's profile photo.
      Returns `:ok` on success.

      Pass a typed `Nadia.InputProfilePhoto` to require a new multipart upload
      and validate its discriminator locally. Raw JSON-serializable objects and
      pre-encoded JSON strings remain supported for compatibility.
      """
      @spec set_my_profile_photo(Nadia.InputProfilePhoto.t() | list | map | struct | binary) ::
              :ok | {:error, Error.t()}
      @spec set_my_profile_photo(
              Client.t(),
              Nadia.InputProfilePhoto.t() | list | map | struct | binary
            ) ::
              :ok | {:error, Error.t()}
      def set_my_profile_photo(photo) do
        api_request("setMyProfilePhoto", photo: encode_json_payload(photo))
      end

      @doc group: "Bot Account"
      def set_my_profile_photo(%Client{} = client, photo) do
        api_request(client, "setMyProfilePhoto", photo: encode_json_payload(photo))
      end

      @doc group: "Bot Account"
      @doc """
      Use this method to remove the bot's profile photo.
      Returns `:ok` on success.
      """
      @spec remove_my_profile_photo() :: :ok | {:error, Error.t()}
      @spec remove_my_profile_photo([{atom, any}] | map) :: :ok | {:error, Error.t()}
      @spec remove_my_profile_photo(Client.t()) :: :ok | {:error, Error.t()}
      @spec remove_my_profile_photo(Client.t(), [{atom, any}] | map) :: :ok | {:error, Error.t()}
      def remove_my_profile_photo(), do: remove_my_profile_photo([])
      @doc group: "Bot Account"
      def remove_my_profile_photo(%Client{} = client), do: remove_my_profile_photo(client, [])
      def remove_my_profile_photo(options), do: api_request("removeMyProfilePhoto", options)

      @doc group: "Bot Account"
      def remove_my_profile_photo(%Client{} = client, options) do
        api_request(client, "removeMyProfilePhoto", options)
      end

      @doc group: "Bot Account"
      @doc """
      Use this method to change the bot's menu button in a private chat, or the
      default menu button.
      Returns `:ok` on success.
      """
      @spec set_chat_menu_button() :: :ok | {:error, Error.t()}
      @spec set_chat_menu_button([{atom, any}] | map) :: :ok | {:error, Error.t()}
      @spec set_chat_menu_button(Client.t()) :: :ok | {:error, Error.t()}
      @spec set_chat_menu_button(Client.t(), [{atom, any}] | map) :: :ok | {:error, Error.t()}
      def set_chat_menu_button(), do: set_chat_menu_button([])
      @doc group: "Bot Account"
      def set_chat_menu_button(%Client{} = client), do: set_chat_menu_button(client, [])

      def set_chat_menu_button(options) do
        api_request("setChatMenuButton", encode_json_option(options, :menu_button))
      end

      @doc group: "Bot Account"
      def set_chat_menu_button(%Client{} = client, options) do
        api_request(client, "setChatMenuButton", encode_json_option(options, :menu_button))
      end

      @doc group: "Bot Account"
      @doc """
      Use this method to get the current value of the bot's menu button in a private
      chat, or the default menu button.
      Returns a `Nadia.Model.MenuButton` on success.
      """
      @spec get_chat_menu_button() :: {:ok, MenuButton.t()} | {:error, Error.t()}
      @spec get_chat_menu_button([{atom, any}] | map) ::
              {:ok, MenuButton.t()} | {:error, Error.t()}
      @spec get_chat_menu_button(Client.t()) :: {:ok, MenuButton.t()} | {:error, Error.t()}
      @spec get_chat_menu_button(Client.t(), [{atom, any}] | map) ::
              {:ok, MenuButton.t()} | {:error, Error.t()}
      def get_chat_menu_button(), do: get_chat_menu_button([])
      @doc group: "Bot Account"
      def get_chat_menu_button(%Client{} = client), do: get_chat_menu_button(client, [])
      def get_chat_menu_button(options), do: api_request("getChatMenuButton", options)

      @doc group: "Bot Account"
      def get_chat_menu_button(%Client{} = client, options) do
        api_request(client, "getChatMenuButton", options)
      end

      @doc group: "Bot Account"
      @doc """
      Use this method to change the default administrator rights requested by the bot.
      Returns `:ok` on success.
      """
      @spec set_my_default_administrator_rights() :: :ok | {:error, Error.t()}
      @spec set_my_default_administrator_rights([{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      @spec set_my_default_administrator_rights(Client.t()) :: :ok | {:error, Error.t()}
      @spec set_my_default_administrator_rights(Client.t(), [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      def set_my_default_administrator_rights(), do: set_my_default_administrator_rights([])

      @doc group: "Bot Account"
      def set_my_default_administrator_rights(%Client{} = client) do
        set_my_default_administrator_rights(client, [])
      end

      def set_my_default_administrator_rights(options) do
        api_request("setMyDefaultAdministratorRights", encode_json_option(options, :rights))
      end

      @doc group: "Bot Account"
      def set_my_default_administrator_rights(%Client{} = client, options) do
        api_request(
          client,
          "setMyDefaultAdministratorRights",
          encode_json_option(options, :rights)
        )
      end

      @doc group: "Bot Account"
      @doc """
      Use this method to get the current default administrator rights of the bot.
      Returns `Nadia.Model.ChatAdministratorRights` on success.
      """
      @spec get_my_default_administrator_rights() ::
              {:ok, ChatAdministratorRights.t()} | {:error, Error.t()}
      @spec get_my_default_administrator_rights([{atom, any}] | map) ::
              {:ok, ChatAdministratorRights.t()} | {:error, Error.t()}
      @spec get_my_default_administrator_rights(Client.t()) ::
              {:ok, ChatAdministratorRights.t()} | {:error, Error.t()}
      @spec get_my_default_administrator_rights(Client.t(), [{atom, any}] | map) ::
              {:ok, ChatAdministratorRights.t()} | {:error, Error.t()}
      def get_my_default_administrator_rights(), do: get_my_default_administrator_rights([])

      @doc group: "Bot Account"
      def get_my_default_administrator_rights(%Client{} = client) do
        get_my_default_administrator_rights(client, [])
      end

      def get_my_default_administrator_rights(options) do
        api_request("getMyDefaultAdministratorRights", options)
      end

      @doc group: "Bot Account"
      def get_my_default_administrator_rights(%Client{} = client, options) do
        api_request(client, "getMyDefaultAdministratorRights", options)
      end

      @doc group: "Bot Account"
      @doc """
      Use this method to change the emoji status for a given user.
      Returns `:ok` on success.
      """
      @spec set_user_emoji_status(integer) :: :ok | {:error, Error.t()}
      @spec set_user_emoji_status(integer, [{atom, any}] | map) :: :ok | {:error, Error.t()}
      @spec set_user_emoji_status(Client.t(), integer) :: :ok | {:error, Error.t()}
      @spec set_user_emoji_status(Client.t(), integer, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      def set_user_emoji_status(user_id), do: set_user_emoji_status(user_id, [])

      @doc group: "Bot Account"
      def set_user_emoji_status(%Client{} = client, user_id) do
        set_user_emoji_status(client, user_id, [])
      end

      def set_user_emoji_status(user_id, options) do
        api_request("setUserEmojiStatus", request_options([user_id: user_id], options))
      end

      @doc group: "Bot Account"
      def set_user_emoji_status(%Client{} = client, user_id, options) do
        api_request(client, "setUserEmojiStatus", request_options([user_id: user_id], options))
      end
    end
  end
end
