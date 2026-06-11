defmodule Nadia do
  @moduledoc """
  Provides access to Telegram Bot API.

  ## Reference
  https://core.telegram.org/bots/api#available-methods

  ## Explicit clients

  Public Bot API wrappers accept a `%Nadia.Client{}` as the first argument when
  a call should use a specific bot identity:

      client = Nadia.Client.new(token: System.fetch_env!("TELEGRAM_BOT_TOKEN"))
      Nadia.send_message(client, 123, "hello")

  Legacy application config based calls remain supported:

      Nadia.send_message(123, "hello")
  """

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
    MenuButton,
    Message,
    MessageId,
    Poll,
    PreparedInlineMessage,
    PreparedKeyboardButton,
    SentGuestMessage,
    SentWebAppMessage,
    StarAmount,
    Sticker,
    Update,
    User,
    UserChatBoosts,
    UserProfileAudios,
    UserProfilePhotos,
    WebhookInfo
  }

  import Nadia.API

  @behaviour Nadia.Behaviour

  defp api_request(method), do: request(method)

  defp api_request(%Client{} = client, method), do: request(client, method, [], nil)
  defp api_request(method, options), do: request(method, options)

  defp api_request(%Client{} = client, method, options), do: request(client, method, options, nil)
  defp api_request(method, options, file_field), do: request(method, options, file_field)

  defp api_request(%Client{} = client, method, options, file_field) do
    request(client, method, options, file_field)
  end

  defp encode_permissions(permissions) when is_list(permissions) do
    permissions
    |> Map.new()
    |> reject_nil_values()
    |> Jason.encode!()
  end

  defp encode_permissions(%_{} = permissions) do
    permissions
    |> Map.from_struct()
    |> reject_nil_values()
    |> Jason.encode!()
  end

  defp encode_permissions(permissions) when is_map(permissions) do
    permissions
    |> reject_nil_values()
    |> Jason.encode!()
  end

  defp encode_permissions(permissions), do: permissions

  defp encode_json_payload(nil), do: nil
  defp encode_json_payload(payload) when is_binary(payload), do: payload

  defp encode_json_payload(payload) do
    payload
    |> json_payload_value()
    |> Jason.encode!()
  end

  defp encode_json_array_payload(nil), do: nil
  defp encode_json_array_payload(payload) when is_binary(payload), do: payload

  defp encode_json_array_payload(payload) when is_list(payload) do
    payload
    |> Enum.map(&json_payload_value/1)
    |> Jason.encode!()
  end

  defp encode_json_array_payload(payload), do: encode_json_payload(payload)

  defp json_payload_value(payload) when is_list(payload) do
    if Keyword.keyword?(payload) do
      payload
      |> Map.new()
      |> json_payload_value()
    else
      Enum.map(payload, &json_payload_value/1)
    end
  end

  defp json_payload_value(%_{} = payload) do
    payload
    |> Map.from_struct()
    |> json_payload_value()
  end

  defp json_payload_value(payload) when is_map(payload) do
    payload
    |> reject_nil_values()
    |> Map.new(fn {key, value} -> {key, json_payload_value(value)} end)
  end

  defp json_payload_value(payload), do: payload

  defp encode_poll_options(params) when is_list(params) do
    Keyword.update(params, :options, nil, &encode_json_payload/1)
  end

  defp encode_poll_options(params) when is_map(params) do
    Map.update(params, :options, nil, &encode_json_payload/1)
  end

  @doc """
  A simple method for testing your bot's auth token. Requires no parameters.
  Returns basic information about the bot in form of a User object.
  """
  @spec get_me :: {:ok, User.t()} | {:error, Error.t()}
  @spec get_me(Client.t()) :: {:ok, User.t()} | {:error, Error.t()}
  def get_me, do: api_request("getMe")
  def get_me(%Client{} = client), do: api_request(client, "getMe")

  @doc """
  Use this method to log out from the cloud Bot API server before launching the
  bot locally.
  Returns `:ok` on success.
  """
  @spec log_out() :: :ok | {:error, Error.t()}
  @spec log_out(Client.t()) :: :ok | {:error, Error.t()}
  def log_out, do: api_request("logOut")
  def log_out(%Client{} = client), do: api_request(client, "logOut")

  @doc """
  Use this method to close the bot instance before moving it from one local
  server to another.
  Returns `:ok` on success.
  """
  @spec close() :: :ok | {:error, Error.t()}
  @spec close(Client.t()) :: :ok | {:error, Error.t()}
  def close, do: api_request("close")
  def close(%Client{} = client), do: api_request(client, "close")

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
  def delete_my_commands(%Client{} = client), do: delete_my_commands(client, [])

  def delete_my_commands(options),
    do: api_request("deleteMyCommands", encode_json_option(options, :scope))

  def delete_my_commands(%Client{} = client, options) do
    api_request(client, "deleteMyCommands", encode_json_option(options, :scope))
  end

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
  def get_my_commands(%Client{} = client), do: get_my_commands(client, [])

  def get_my_commands(options) do
    api_request("getMyCommands", encode_json_option(options, :scope))
  end

  def get_my_commands(%Client{} = client, options) do
    api_request(client, "getMyCommands", encode_json_option(options, :scope))
  end

  @doc """
  Use this method to change the bot's name.
  Returns `:ok` on success.
  """
  @spec set_my_name() :: :ok | {:error, Error.t()}
  @spec set_my_name([{atom, any}] | map) :: :ok | {:error, Error.t()}
  @spec set_my_name(Client.t()) :: :ok | {:error, Error.t()}
  @spec set_my_name(Client.t(), [{atom, any}] | map) :: :ok | {:error, Error.t()}
  def set_my_name(), do: set_my_name([])
  def set_my_name(%Client{} = client), do: set_my_name(client, [])
  def set_my_name(options), do: api_request("setMyName", options)
  def set_my_name(%Client{} = client, options), do: api_request(client, "setMyName", options)

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
  def get_my_name(%Client{} = client), do: get_my_name(client, [])
  def get_my_name(options), do: api_request("getMyName", options)
  def get_my_name(%Client{} = client, options), do: api_request(client, "getMyName", options)

  @doc """
  Use this method to change the bot's description.
  Returns `:ok` on success.
  """
  @spec set_my_description() :: :ok | {:error, Error.t()}
  @spec set_my_description([{atom, any}] | map) :: :ok | {:error, Error.t()}
  @spec set_my_description(Client.t()) :: :ok | {:error, Error.t()}
  @spec set_my_description(Client.t(), [{atom, any}] | map) :: :ok | {:error, Error.t()}
  def set_my_description(), do: set_my_description([])
  def set_my_description(%Client{} = client), do: set_my_description(client, [])
  def set_my_description(options), do: api_request("setMyDescription", options)

  def set_my_description(%Client{} = client, options) do
    api_request(client, "setMyDescription", options)
  end

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
  def get_my_description(%Client{} = client), do: get_my_description(client, [])
  def get_my_description(options), do: api_request("getMyDescription", options)

  def get_my_description(%Client{} = client, options) do
    api_request(client, "getMyDescription", options)
  end

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
  def set_my_short_description(%Client{} = client), do: set_my_short_description(client, [])
  def set_my_short_description(options), do: api_request("setMyShortDescription", options)

  def set_my_short_description(%Client{} = client, options) do
    api_request(client, "setMyShortDescription", options)
  end

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
  def get_my_short_description(%Client{} = client), do: get_my_short_description(client, [])
  def get_my_short_description(options), do: api_request("getMyShortDescription", options)

  def get_my_short_description(%Client{} = client, options) do
    api_request(client, "getMyShortDescription", options)
  end

  @doc """
  Use this method to change the bot's profile photo.
  Returns `:ok` on success.
  """
  @spec set_my_profile_photo(list | map | struct | binary) :: :ok | {:error, Error.t()}
  @spec set_my_profile_photo(Client.t(), list | map | struct | binary) ::
          :ok | {:error, Error.t()}
  def set_my_profile_photo(photo) do
    api_request("setMyProfilePhoto", photo: encode_json_payload(photo))
  end

  def set_my_profile_photo(%Client{} = client, photo) do
    api_request(client, "setMyProfilePhoto", photo: encode_json_payload(photo))
  end

  @doc """
  Use this method to remove the bot's profile photo.
  Returns `:ok` on success.
  """
  @spec remove_my_profile_photo() :: :ok | {:error, Error.t()}
  @spec remove_my_profile_photo([{atom, any}] | map) :: :ok | {:error, Error.t()}
  @spec remove_my_profile_photo(Client.t()) :: :ok | {:error, Error.t()}
  @spec remove_my_profile_photo(Client.t(), [{atom, any}] | map) :: :ok | {:error, Error.t()}
  def remove_my_profile_photo(), do: remove_my_profile_photo([])
  def remove_my_profile_photo(%Client{} = client), do: remove_my_profile_photo(client, [])
  def remove_my_profile_photo(options), do: api_request("removeMyProfilePhoto", options)

  def remove_my_profile_photo(%Client{} = client, options) do
    api_request(client, "removeMyProfilePhoto", options)
  end

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
  def set_chat_menu_button(%Client{} = client), do: set_chat_menu_button(client, [])

  def set_chat_menu_button(options) do
    api_request("setChatMenuButton", encode_json_option(options, :menu_button))
  end

  def set_chat_menu_button(%Client{} = client, options) do
    api_request(client, "setChatMenuButton", encode_json_option(options, :menu_button))
  end

  @doc """
  Use this method to get the current value of the bot's menu button in a private
  chat, or the default menu button.
  Returns a `Nadia.Model.MenuButton` on success.
  """
  @spec get_chat_menu_button() :: {:ok, MenuButton.t()} | {:error, Error.t()}
  @spec get_chat_menu_button([{atom, any}] | map) :: {:ok, MenuButton.t()} | {:error, Error.t()}
  @spec get_chat_menu_button(Client.t()) :: {:ok, MenuButton.t()} | {:error, Error.t()}
  @spec get_chat_menu_button(Client.t(), [{atom, any}] | map) ::
          {:ok, MenuButton.t()} | {:error, Error.t()}
  def get_chat_menu_button(), do: get_chat_menu_button([])
  def get_chat_menu_button(%Client{} = client), do: get_chat_menu_button(client, [])
  def get_chat_menu_button(options), do: api_request("getChatMenuButton", options)

  def get_chat_menu_button(%Client{} = client, options) do
    api_request(client, "getChatMenuButton", options)
  end

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

  def set_my_default_administrator_rights(%Client{} = client) do
    set_my_default_administrator_rights(client, [])
  end

  def set_my_default_administrator_rights(options) do
    api_request("setMyDefaultAdministratorRights", encode_json_option(options, :rights))
  end

  def set_my_default_administrator_rights(%Client{} = client, options) do
    api_request(client, "setMyDefaultAdministratorRights", encode_json_option(options, :rights))
  end

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

  def get_my_default_administrator_rights(%Client{} = client) do
    get_my_default_administrator_rights(client, [])
  end

  def get_my_default_administrator_rights(options) do
    api_request("getMyDefaultAdministratorRights", options)
  end

  def get_my_default_administrator_rights(%Client{} = client, options) do
    api_request(client, "getMyDefaultAdministratorRights", options)
  end

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

  def set_user_emoji_status(%Client{} = client, user_id) do
    set_user_emoji_status(client, user_id, [])
  end

  def set_user_emoji_status(user_id, options) do
    api_request("setUserEmojiStatus", request_options([user_id: user_id], options))
  end

  def set_user_emoji_status(%Client{} = client, user_id, options) do
    api_request(client, "setUserEmojiStatus", request_options([user_id: user_id], options))
  end

  @doc """
  Use this method to send a gift to a user or channel chat.
  Returns `:ok` on success.

  Args:
  * `gift_id` - Identifier of the gift
  * `options` - orddict or map of options, including required `:user_id` or `:chat_id`

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

  def send_gift(%Client{} = client, gift_id) do
    send_gift(client, gift_id, [])
  end

  def send_gift(gift_id, options) do
    api_request(
      "sendGift",
      request_options([gift_id: gift_id], encode_json_option(options, :text_entities))
    )
  end

  def send_gift(%Client{} = client, gift_id, options) do
    api_request(
      client,
      "sendGift",
      request_options([gift_id: gift_id], encode_json_option(options, :text_entities))
    )
  end

  @doc """
  Use this method to gift a Telegram Premium subscription to a user.
  Returns `:ok` on success.

  Args:
  * `user_id` - Unique identifier of the target user
  * `month_count` - Number of months the subscription will be active
  * `star_count` - Number of Telegram Stars to pay
  * `options` - orddict or map of options

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

  @doc """
  Use this method to verify a user on behalf of the organization represented by the bot.
  Returns `:ok` on success.
  """
  @spec verify_user(integer) :: :ok | {:error, Error.t()}
  @spec verify_user(integer, [{atom, any}] | map) :: :ok | {:error, Error.t()}
  @spec verify_user(Client.t(), integer) :: :ok | {:error, Error.t()}
  @spec verify_user(Client.t(), integer, [{atom, any}] | map) :: :ok | {:error, Error.t()}
  def verify_user(user_id), do: verify_user(user_id, [])

  def verify_user(%Client{} = client, user_id) do
    verify_user(client, user_id, [])
  end

  def verify_user(user_id, options) do
    api_request("verifyUser", request_options([user_id: user_id], options))
  end

  def verify_user(%Client{} = client, user_id, options) do
    api_request(client, "verifyUser", request_options([user_id: user_id], options))
  end

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

  def verify_chat(%Client{} = client, chat_id) do
    verify_chat(client, chat_id, [])
  end

  def verify_chat(chat_id, options) do
    api_request("verifyChat", request_options([chat_id: chat_id], options))
  end

  def verify_chat(%Client{} = client, chat_id, options) do
    api_request(client, "verifyChat", request_options([chat_id: chat_id], options))
  end

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

  def remove_user_verification(%Client{} = client, user_id) do
    api_request(client, "removeUserVerification", user_id: user_id)
  end

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

  def remove_chat_verification(%Client{} = client, chat_id) do
    api_request(client, "removeChatVerification", chat_id: chat_id)
  end

  @doc """
  Use this method to send text messages.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `text` - Text of the message to be sent
  * `options` - orddict of options

  Options:
  * `:parse_mode` - Use `Markdown`, if you want Telegram apps to show bold, italic
  and inline URLs in your bot's message
  * `:disable_web_page_preview` - Disables link previews for links in this message
  * `:disable_notification` - Sends the message silently or without notification
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardRemove` or `Nadia.Model.ForceReply`
  """
  @spec send_message(integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_message(Client.t(), integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_message(chat_id, text), do: send_message(chat_id, text, [])
  def send_message(%Client{} = client, chat_id, text), do: send_message(client, chat_id, text, [])

  def send_message(chat_id, text, options) do
    api_request("sendMessage", [chat_id: chat_id, text: text] ++ options)
  end

  def send_message(%Client{} = client, chat_id, text, options) do
    api_request(client, "sendMessage", [chat_id: chat_id, text: text] ++ options)
  end

  @doc """
  Use this method to forward messages of any kind.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `from_chat_id` - Unique identifier for the chat where the original message was sent
  or username of the target channel (in the format @channelusername)
  * `message_id` - Unique message identifier
  * `options` - orddict of options

  Options:
  * `:message_thread_id` - Unique identifier for the target message thread
  * `:direct_messages_topic_id` - Identifier of the direct messages topic
  * `:video_start_timestamp` - New start timestamp for forwarded videos
  * `:disable_notification` - Sends the message silently or without notification
  * `:protect_content` - Protects the contents of the forwarded message
  * `:message_effect_id` - Unique identifier of the message effect to be added
  * `:suggested_post_parameters` - Suggested post parameters
  """
  @spec forward_message(integer | binary, integer | binary, integer) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec forward_message(integer | binary, integer | binary, integer, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec forward_message(Client.t(), integer | binary, integer | binary, integer) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec forward_message(Client.t(), integer | binary, integer | binary, integer, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def forward_message(chat_id, from_chat_id, message_id) do
    forward_message(chat_id, from_chat_id, message_id, [])
  end

  def forward_message(%Client{} = client, chat_id, from_chat_id, message_id) do
    forward_message(client, chat_id, from_chat_id, message_id, [])
  end

  def forward_message(chat_id, from_chat_id, message_id, options) do
    api_request(
      "forwardMessage",
      [chat_id: chat_id, from_chat_id: from_chat_id, message_id: message_id] ++ options
    )
  end

  def forward_message(%Client{} = client, chat_id, from_chat_id, message_id, options) do
    api_request(
      client,
      "forwardMessage",
      [chat_id: chat_id, from_chat_id: from_chat_id, message_id: message_id] ++ options
    )
  end

  @doc """
  Use this method to forward multiple messages of any kind.
  On success, an array of MessageId objects is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `from_chat_id` - Unique identifier for the chat where the original messages were sent
  or username of the target channel (in the format @channelusername)
  * `message_ids` - List of message identifiers
  * `options` - orddict of options

  Options:
  * `:message_thread_id` - Unique identifier for the target message thread
  * `:direct_messages_topic_id` - Identifier of the direct messages topic
  * `:disable_notification` - Sends the messages silently or without notification
  * `:protect_content` - Protects the contents of the forwarded messages
  """
  @spec forward_messages(integer | binary, integer | binary, [integer]) ::
          {:ok, [MessageId.t()]} | {:error, Error.t()}
  @spec forward_messages(integer | binary, integer | binary, [integer], [{atom, any}]) ::
          {:ok, [MessageId.t()]} | {:error, Error.t()}
  @spec forward_messages(Client.t(), integer | binary, integer | binary, [integer]) ::
          {:ok, [MessageId.t()]} | {:error, Error.t()}
  @spec forward_messages(Client.t(), integer | binary, integer | binary, [integer], [
          {atom, any}
        ]) ::
          {:ok, [MessageId.t()]} | {:error, Error.t()}
  def forward_messages(chat_id, from_chat_id, message_ids) do
    forward_messages(chat_id, from_chat_id, message_ids, [])
  end

  def forward_messages(%Client{} = client, chat_id, from_chat_id, message_ids) do
    forward_messages(client, chat_id, from_chat_id, message_ids, [])
  end

  def forward_messages(chat_id, from_chat_id, message_ids, options) do
    api_request(
      "forwardMessages",
      [
        chat_id: chat_id,
        from_chat_id: from_chat_id,
        message_ids: encode_message_ids(message_ids)
      ] ++ options
    )
  end

  def forward_messages(%Client{} = client, chat_id, from_chat_id, message_ids, options) do
    api_request(
      client,
      "forwardMessages",
      [
        chat_id: chat_id,
        from_chat_id: from_chat_id,
        message_ids: encode_message_ids(message_ids)
      ] ++ options
    )
  end

  @doc """
  Use this method to copy messages of any kind.
  On success, the MessageId of the sent message is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `from_chat_id` - Unique identifier for the chat where the original message was sent
  or username of the target channel (in the format @channelusername)
  * `message_id` - Unique message identifier
  * `options` - orddict of options

  Options:
  * `:message_thread_id` - Unique identifier for the target message thread
  * `:direct_messages_topic_id` - Identifier of the direct messages topic
  * `:video_start_timestamp` - New start timestamp for copied videos
  * `:caption` - New caption for media
  * `:parse_mode` - Mode for parsing entities in the new caption
  * `:caption_entities` - JSON-serialized list of caption entities
  * `:show_caption_above_media` - Pass True to show the caption above media
  * `:disable_notification` - Sends the message silently or without notification
  * `:protect_content` - Protects the contents of the sent message
  * `:allow_paid_broadcast` - Allows paid broadcast throughput
  * `:message_effect_id` - Unique identifier of the message effect to be added
  * `:suggested_post_parameters` - Suggested post parameters
  * `:reply_parameters` - Description of the message to reply to
  * `:reply_markup` - Additional interface options
  """
  @spec copy_message(integer | binary, integer | binary, integer) ::
          {:ok, MessageId.t()} | {:error, Error.t()}
  @spec copy_message(integer | binary, integer | binary, integer, [{atom, any}]) ::
          {:ok, MessageId.t()} | {:error, Error.t()}
  @spec copy_message(Client.t(), integer | binary, integer | binary, integer) ::
          {:ok, MessageId.t()} | {:error, Error.t()}
  @spec copy_message(Client.t(), integer | binary, integer | binary, integer, [{atom, any}]) ::
          {:ok, MessageId.t()} | {:error, Error.t()}
  def copy_message(chat_id, from_chat_id, message_id) do
    copy_message(chat_id, from_chat_id, message_id, [])
  end

  def copy_message(%Client{} = client, chat_id, from_chat_id, message_id) do
    copy_message(client, chat_id, from_chat_id, message_id, [])
  end

  def copy_message(chat_id, from_chat_id, message_id, options) do
    api_request(
      "copyMessage",
      [chat_id: chat_id, from_chat_id: from_chat_id, message_id: message_id] ++ options
    )
  end

  def copy_message(%Client{} = client, chat_id, from_chat_id, message_id, options) do
    api_request(
      client,
      "copyMessage",
      [chat_id: chat_id, from_chat_id: from_chat_id, message_id: message_id] ++ options
    )
  end

  @doc """
  Use this method to copy multiple messages of any kind.
  On success, an array of MessageId objects is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `from_chat_id` - Unique identifier for the chat where the original messages were sent
  or username of the target channel (in the format @channelusername)
  * `message_ids` - List of message identifiers
  * `options` - orddict of options

  Options:
  * `:message_thread_id` - Unique identifier for the target message thread
  * `:direct_messages_topic_id` - Identifier of the direct messages topic
  * `:disable_notification` - Sends the messages silently or without notification
  * `:protect_content` - Protects the contents of the sent messages
  * `:remove_caption` - Pass True to copy the messages without their captions
  """
  @spec copy_messages(integer | binary, integer | binary, [integer]) ::
          {:ok, [MessageId.t()]} | {:error, Error.t()}
  @spec copy_messages(integer | binary, integer | binary, [integer], [{atom, any}]) ::
          {:ok, [MessageId.t()]} | {:error, Error.t()}
  @spec copy_messages(Client.t(), integer | binary, integer | binary, [integer]) ::
          {:ok, [MessageId.t()]} | {:error, Error.t()}
  @spec copy_messages(Client.t(), integer | binary, integer | binary, [integer], [
          {atom, any}
        ]) ::
          {:ok, [MessageId.t()]} | {:error, Error.t()}
  def copy_messages(chat_id, from_chat_id, message_ids) do
    copy_messages(chat_id, from_chat_id, message_ids, [])
  end

  def copy_messages(%Client{} = client, chat_id, from_chat_id, message_ids) do
    copy_messages(client, chat_id, from_chat_id, message_ids, [])
  end

  def copy_messages(chat_id, from_chat_id, message_ids, options) do
    api_request(
      "copyMessages",
      [
        chat_id: chat_id,
        from_chat_id: from_chat_id,
        message_ids: encode_message_ids(message_ids)
      ] ++ options
    )
  end

  def copy_messages(%Client{} = client, chat_id, from_chat_id, message_ids, options) do
    api_request(
      client,
      "copyMessages",
      [
        chat_id: chat_id,
        from_chat_id: from_chat_id,
        message_ids: encode_message_ids(message_ids)
      ] ++ options
    )
  end

  @doc """
  Use this method to send photos.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `photo` - Photo to send. Either a `file_id` to resend a photo that is already on
  the Telegram servers, or a `file_path` to upload a new photo
  * `options` - orddict of options

  Options:
  * `:caption` - Photo caption (may also be used when resending photos by `file_id`)
  * `:disable_notification` - Sends the message silently or without notification
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardRemove` or `Nadia.Model.ForceReply`
  """
  @spec send_photo(integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_photo(Client.t(), integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_photo(chat_id, photo), do: send_photo(chat_id, photo, [])
  def send_photo(%Client{} = client, chat_id, photo), do: send_photo(client, chat_id, photo, [])

  def send_photo(chat_id, photo, options) do
    api_request("sendPhoto", [chat_id: chat_id, photo: photo] ++ options, :photo)
  end

  def send_photo(%Client{} = client, chat_id, photo, options) do
    api_request(client, "sendPhoto", [chat_id: chat_id, photo: photo] ++ options, :photo)
  end

  @doc """
  Use this method to send audio files, if you want Telegram clients to display
  them in the music player. Your audio must be in the .mp3 format.
  On success, the sent Message is returned.
  Bots can currently send audio files of up to 50 MB in size, this limit may
  be changed in the future.

  For backward compatibility, when the fields title and performer are both
  empty and the mime-type of the file to be sent is not audio/mpeg, the file
  will be sent as a playable voice message. For this to work, the audio must be
  in an .ogg file encoded with OPUS. This behavior will be phased out in the
  future. For sending voice messages, use the sendVoice method instead.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `audio` - Audio to send. Either a `file_id` to resend an audio that is already on
  the Telegram servers, or a `file_path` to upload a new audio
  * `options` - orddict of options

  Options:
  * `:duration` - Duration of the audio in seconds
  * `:performer` - Performer
  * `:title` - Track name
  * `:disable_notification` - Sends the message silently or without notification
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardRemove` or `Nadia.Model.ForceReply`
  """
  @spec send_audio(integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_audio(Client.t(), integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_audio(chat_id, audio), do: send_audio(chat_id, audio, [])
  def send_audio(%Client{} = client, chat_id, audio), do: send_audio(client, chat_id, audio, [])

  def send_audio(chat_id, audio, options) do
    api_request("sendAudio", [chat_id: chat_id, audio: audio] ++ options, :audio)
  end

  def send_audio(%Client{} = client, chat_id, audio, options) do
    api_request(client, "sendAudio", [chat_id: chat_id, audio: audio] ++ options, :audio)
  end

  @doc """
  Use this method to send general files.
  On success, the sent Message is returned.
  Bots can currently send files of any type of up to 50 MB in size, this limit
  may be changed in the future.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `document` - File to send. Either a `file_id` to resend a file that is already on
  the Telegram servers, or a `file_path` to upload a new file
  * `options` - orddict of options

  Options:
  * `:disable_notification` - Sends the message silently or without notification
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardRemove` or `Nadia.Model.ForceReply`
  """
  @spec send_document(integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_document(Client.t(), integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_document(chat_id, document), do: send_document(chat_id, document, [])

  def send_document(%Client{} = client, chat_id, document) do
    send_document(client, chat_id, document, [])
  end

  def send_document(chat_id, document, options) do
    api_request("sendDocument", [chat_id: chat_id, document: document] ++ options, :document)
  end

  def send_document(%Client{} = client, chat_id, document, options) do
    api_request(
      client,
      "sendDocument",
      [chat_id: chat_id, document: document] ++ options,
      :document
    )
  end

  @doc """
  Use this method to send .webp stickers.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `sticker` - File to send. Either a `file_id` to resend a sticker that is already on
  the Telegram servers, or a `file_path` to upload a new sticker
  * `options` - orddict of options

  Options:
  * `:disable_notification` - Sends the message silently or without notification
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardRemove` or `Nadia.Model.ForceReply`
  """
  @spec send_sticker(integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_sticker(Client.t(), integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_sticker(chat_id, sticker), do: send_sticker(chat_id, sticker, [])

  def send_sticker(%Client{} = client, chat_id, sticker) do
    send_sticker(client, chat_id, sticker, [])
  end

  def send_sticker(chat_id, sticker, options) do
    api_request("sendSticker", [chat_id: chat_id, sticker: sticker] ++ options, :sticker)
  end

  def send_sticker(%Client{} = client, chat_id, sticker, options) do
    api_request(client, "sendSticker", [chat_id: chat_id, sticker: sticker] ++ options, :sticker)
  end

  @doc """
  Use this method to send video files, Telegram clients support mp4 videos
  (other formats may be sent as Document).
  On success, the sent Message is returned.
  Bots can currently send video files of up to 50 MB in size, this limit may be
  changed in the future.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `video` - Video to send. Either a `file_id` to resend a video that is already on
  the Telegram servers, or a `file_path` to upload a new video
  * `options` - orddict of options

  Options:
  * `:duration` - Duration of the video in seconds
  * `:caption` - Video caption (may also be used when resending videos by `file_id`)
  * `:disable_notification` - Sends the message silently or without notification
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardRemove` or `Nadia.Model.ForceReply`
  """
  @spec send_video(integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_video(Client.t(), integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_video(chat_id, video), do: send_video(chat_id, video, [])
  def send_video(%Client{} = client, chat_id, video), do: send_video(client, chat_id, video, [])

  def send_video(chat_id, video, options) do
    api_request("sendVideo", [chat_id: chat_id, video: video] ++ options, :video)
  end

  def send_video(%Client{} = client, chat_id, video, options) do
    api_request(client, "sendVideo", [chat_id: chat_id, video: video] ++ options, :video)
  end

  @doc """
  Use this method to send audio files, if you want Telegram clients to display
  the file as a playable voice message. For this to work, your audio must be in
  an .ogg file encoded with OPUS (other formats may be sent as Audio or Document).
  On success, the sent Message is returned.
  Bots can currently send voice messages of up to 50 MB in size, this limit may be
  changed in the future.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `voice` - Audio to send. Either a `file_id` to resend an audio that is already on
  the Telegram servers, or a `file_path` to upload a new audio
  * `options` - orddict of options

  Options:
  * `:duration` - Duration of the audio in seconds
  * `:disable_notification` - Sends the message silently or without notification
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardRemove` or `Nadia.Model.ForceReply`
  """
  @spec send_voice(integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_voice(Client.t(), integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_voice(chat_id, voice), do: send_voice(chat_id, voice, [])
  def send_voice(%Client{} = client, chat_id, voice), do: send_voice(client, chat_id, voice, [])

  def send_voice(chat_id, voice, options) do
    api_request("sendVoice", [chat_id: chat_id, voice: voice] ++ options, :voice)
  end

  def send_voice(%Client{} = client, chat_id, voice, options) do
    api_request(client, "sendVoice", [chat_id: chat_id, voice: voice] ++ options, :voice)
  end

  @doc """
  Use this method to send video messages.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `video_note` - Video note to send. Either a `file_id` to resend a video note that is
  already on the Telegram servers, or a `file_path` to upload a new video note
  * `options` - orddict of options
  """
  @spec send_video_note(integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_video_note(Client.t(), integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_video_note(chat_id, video_note), do: send_video_note(chat_id, video_note, [])

  def send_video_note(%Client{} = client, chat_id, video_note) do
    send_video_note(client, chat_id, video_note, [])
  end

  def send_video_note(chat_id, video_note, options) do
    api_request(
      "sendVideoNote",
      [chat_id: chat_id, video_note: video_note] ++ options,
      :video_note
    )
  end

  def send_video_note(%Client{} = client, chat_id, video_note, options) do
    api_request(
      client,
      "sendVideoNote",
      [chat_id: chat_id, video_note: video_note] ++ options,
      :video_note
    )
  end

  @doc """
  Use this method to send live photos.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `live_photo` - Live photo media to send
  * `photo` - Cover photo to send as a regular Telegram parameter
  * `options` - orddict of options
  """
  @spec send_live_photo(integer | binary, binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_live_photo(Client.t(), integer | binary, binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_live_photo(chat_id, live_photo, photo) do
    send_live_photo(chat_id, live_photo, photo, [])
  end

  def send_live_photo(%Client{} = client, chat_id, live_photo, photo) do
    send_live_photo(client, chat_id, live_photo, photo, [])
  end

  def send_live_photo(chat_id, live_photo, photo, options) do
    api_request(
      "sendLivePhoto",
      [chat_id: chat_id, live_photo: live_photo, photo: photo] ++ options,
      :live_photo
    )
  end

  def send_live_photo(%Client{} = client, chat_id, live_photo, photo, options) do
    api_request(
      client,
      "sendLivePhoto",
      [chat_id: chat_id, live_photo: live_photo, photo: photo] ++ options,
      :live_photo
    )
  end

  @doc """
  Use this method to send an album of photos, videos, documents or audios.
  On success, an array of sent Messages is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `media` - JSON-serializable media array or a pre-encoded JSON string
  * `options` - orddict of options
  """
  @spec send_media_group(integer | binary, list | map | struct | binary, [{atom, any}]) ::
          {:ok, [Message.t()]} | {:error, Error.t()}
  @spec send_media_group(Client.t(), integer | binary, list | map | struct | binary, [
          {atom, any}
        ]) ::
          {:ok, [Message.t()]} | {:error, Error.t()}
  def send_media_group(chat_id, media), do: send_media_group(chat_id, media, [])

  def send_media_group(%Client{} = client, chat_id, media) do
    send_media_group(client, chat_id, media, [])
  end

  def send_media_group(chat_id, media, options) do
    api_request(
      "sendMediaGroup",
      [chat_id: chat_id, media: encode_json_payload(media)] ++ options
    )
  end

  def send_media_group(%Client{} = client, chat_id, media, options) do
    api_request(
      client,
      "sendMediaGroup",
      [chat_id: chat_id, media: encode_json_payload(media)] ++ options
    )
  end

  @doc """
  Use this method to send paid media.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `star_count` - Amount of Telegram Stars to be paid for the media
  * `media` - JSON-serializable paid media array or a pre-encoded JSON string
  * `options` - orddict of options
  """
  @spec send_paid_media(integer | binary, integer, list | map | struct | binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_paid_media(Client.t(), integer | binary, integer, list | map | struct | binary, [
          {atom, any}
        ]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_paid_media(chat_id, star_count, media) do
    send_paid_media(chat_id, star_count, media, [])
  end

  def send_paid_media(%Client{} = client, chat_id, star_count, media) do
    send_paid_media(client, chat_id, star_count, media, [])
  end

  def send_paid_media(chat_id, star_count, media, options) do
    api_request(
      "sendPaidMedia",
      [chat_id: chat_id, star_count: star_count, media: encode_json_payload(media)] ++ options
    )
  end

  def send_paid_media(%Client{} = client, chat_id, star_count, media, options) do
    api_request(
      client,
      "sendPaidMedia",
      [chat_id: chat_id, star_count: star_count, media: encode_json_payload(media)] ++ options
    )
  end

  @doc """
  Use this method to send a native poll.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `question` - Poll question
  * `params` - orddict or map of Telegram parameters, including required `:options`
  """
  @spec send_poll(integer | binary, binary, [{atom, any}] | map) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_poll(Client.t(), integer | binary, binary, [{atom, any}] | map) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_poll(chat_id, question, params) when is_list(params) do
    api_request(
      "sendPoll",
      [chat_id: chat_id, question: question] ++ encode_poll_options(params)
    )
  end

  def send_poll(chat_id, question, params) when is_map(params) do
    api_request(
      "sendPoll",
      params
      |> encode_poll_options()
      |> Map.put(:chat_id, chat_id)
      |> Map.put(:question, question)
    )
  end

  def send_poll(%Client{} = client, chat_id, question, params) when is_list(params) do
    api_request(
      client,
      "sendPoll",
      [chat_id: chat_id, question: question] ++ encode_poll_options(params)
    )
  end

  def send_poll(%Client{} = client, chat_id, question, params) when is_map(params) do
    api_request(
      client,
      "sendPoll",
      params
      |> encode_poll_options()
      |> Map.put(:chat_id, chat_id)
      |> Map.put(:question, question)
    )
  end

  @doc """
  Use this method to send an animated emoji that will display a random value.
  On success, the sent Message is returned.
  """
  @spec send_dice(integer | binary) :: {:ok, Message.t()} | {:error, Error.t()}
  @spec send_dice(integer | binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  @spec send_dice(Client.t(), integer | binary) :: {:ok, Message.t()} | {:error, Error.t()}
  @spec send_dice(Client.t(), integer | binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_dice(chat_id), do: send_dice(chat_id, [])
  def send_dice(%Client{} = client, chat_id), do: send_dice(client, chat_id, [])
  def send_dice(chat_id, options), do: api_request("sendDice", [chat_id: chat_id] ++ options)

  def send_dice(%Client{} = client, chat_id, options) do
    api_request(client, "sendDice", [chat_id: chat_id] ++ options)
  end

  @doc """
  Use this method to send a game.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat
  * `game_short_name` - Short name of the game
  * `options` - orddict or map of options
  """
  @spec send_game(integer | binary, binary) :: {:ok, Message.t()} | {:error, Error.t()}
  @spec send_game(integer | binary, binary, [{atom, any}] | map) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_game(Client.t(), integer | binary, binary) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_game(Client.t(), integer | binary, binary, [{atom, any}] | map) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_game(chat_id, game_short_name), do: send_game(chat_id, game_short_name, [])

  def send_game(%Client{} = client, chat_id, game_short_name) do
    send_game(client, chat_id, game_short_name, [])
  end

  def send_game(chat_id, game_short_name, options) do
    api_request(
      "sendGame",
      request_options([chat_id: chat_id, game_short_name: game_short_name], options)
    )
  end

  def send_game(%Client{} = client, chat_id, game_short_name, options) do
    api_request(
      client,
      "sendGame",
      request_options([chat_id: chat_id, game_short_name: game_short_name], options)
    )
  end

  @doc """
  Use this method to send a checklist on behalf of a connected business account.
  On success, the sent Message is returned.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  * `chat_id` - Unique identifier for the target chat or username of the target bot
  * `checklist` - JSON-serializable checklist object or a pre-encoded JSON string
  * `options` - orddict of options
  """
  @spec send_checklist(binary, integer | binary, list | map | struct | binary) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_checklist(binary, integer | binary, list | map | struct | binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_checklist(Client.t(), binary, integer | binary, list | map | struct | binary) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_checklist(Client.t(), binary, integer | binary, list | map | struct | binary, [
          {atom, any}
        ]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_checklist(business_connection_id, chat_id, checklist) do
    send_checklist(business_connection_id, chat_id, checklist, [])
  end

  def send_checklist(%Client{} = client, business_connection_id, chat_id, checklist) do
    send_checklist(client, business_connection_id, chat_id, checklist, [])
  end

  def send_checklist(business_connection_id, chat_id, checklist, options) do
    api_request(
      "sendChecklist",
      [
        business_connection_id: business_connection_id,
        chat_id: chat_id,
        checklist: encode_json_payload(checklist)
      ] ++ options
    )
  end

  def send_checklist(%Client{} = client, business_connection_id, chat_id, checklist, options) do
    api_request(
      client,
      "sendChecklist",
      [
        business_connection_id: business_connection_id,
        chat_id: chat_id,
        checklist: encode_json_payload(checklist)
      ] ++ options
    )
  end

  @doc """
  Use this method to stream a partial message draft to a user.
  Returns `:ok` on success.
  """
  @spec send_message_draft(integer | binary, integer) :: :ok | {:error, Error.t()}
  @spec send_message_draft(integer | binary, integer, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  @spec send_message_draft(Client.t(), integer | binary, integer) ::
          :ok | {:error, Error.t()}
  @spec send_message_draft(Client.t(), integer | binary, integer, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  def send_message_draft(chat_id, draft_id), do: send_message_draft(chat_id, draft_id, [])

  def send_message_draft(%Client{} = client, chat_id, draft_id) do
    send_message_draft(client, chat_id, draft_id, [])
  end

  def send_message_draft(chat_id, draft_id, options) do
    api_request("sendMessageDraft", [chat_id: chat_id, draft_id: draft_id] ++ options)
  end

  def send_message_draft(%Client{} = client, chat_id, draft_id, options) do
    api_request(client, "sendMessageDraft", [chat_id: chat_id, draft_id: draft_id] ++ options)
  end

  @doc """
  Use this method to send point on the map.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `latitude` - Latitude of location
  * `longitude` - Longitude of location
  * `options` - orddict of options

  Options:
  * `:disable_notification` - Sends the message silently or without notification
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardRemove` or `Nadia.Model.ForceReply`
  """
  @spec send_location(integer | binary, float, float, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_location(Client.t(), integer | binary, float, float, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_location(chat_id, latitude, longitude),
    do: send_location(chat_id, latitude, longitude, [])

  def send_location(%Client{} = client, chat_id, latitude, longitude) do
    send_location(client, chat_id, latitude, longitude, [])
  end

  def send_location(chat_id, latitude, longitude, options) do
    api_request(
      "sendLocation",
      [chat_id: chat_id, latitude: latitude, longitude: longitude] ++ options
    )
  end

  def send_location(%Client{} = client, chat_id, latitude, longitude, options) do
    api_request(
      client,
      "sendLocation",
      [chat_id: chat_id, latitude: latitude, longitude: longitude] ++ options
    )
  end

  @doc """
  Use this method to send information about a venue.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `latitude` - Latitude of location
  * `longitude` - Longitude of location
  * `title` - Name of the venue
  * `address` - Address of the venue
  * `options` - orddict of options

  Options:
  * `:foursquare_id` - Foursquare identifier of the venue
  * `:disable_notification` - Sends the message silently or without notification
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. A JSON-serialized object for
  an inline keyboard, custom reply keyboard, instructions to hide reply keyboard
  or to force a reply from the user. - `Nadia.Model.InlineKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardMarkup` or `Nadia.Model.ReplyKeyboardRemove` or
  `Nadia.Model.ForceReply`
  """
  @spec send_venue(integer | binary, float, float, binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_venue(Client.t(), integer | binary, float, float, binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_venue(chat_id, latitude, longitude, title, address) do
    send_venue(chat_id, latitude, longitude, title, address, [])
  end

  def send_venue(%Client{} = client, chat_id, latitude, longitude, title, address) do
    send_venue(client, chat_id, latitude, longitude, title, address, [])
  end

  def send_venue(chat_id, latitude, longitude, title, address, options) do
    api_request(
      "sendVenue",
      [chat_id: chat_id, latitude: latitude, longitude: longitude, title: title, address: address] ++
        options
    )
  end

  def send_venue(%Client{} = client, chat_id, latitude, longitude, title, address, options) do
    api_request(
      client,
      "sendVenue",
      [chat_id: chat_id, latitude: latitude, longitude: longitude, title: title, address: address] ++
        options
    )
  end

  @doc """
  Use this method to send phone contacts.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `phone_number` - Contact's phone number
  * `first_name` - Contact's first name
  * `options` - orddict of options

  Options:
  * `:last_name` - Contact's last name
  * `:disable_notification` - Sends the message silently or without notification
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. A JSON-serialized object for
  an inline keyboard, custom reply keyboard, instructions to hide reply keyboard
  or to force a reply from the user. - `Nadia.Model.InlineKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardMarkup` or `Nadia.Model.ReplyKeyboardRemove` or
  `Nadia.Model.ForceReply`
  """
  @spec send_contact(integer | binary, binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_contact(Client.t(), integer | binary, binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_contact(chat_id, phone_number, first_name),
    do: send_contact(chat_id, phone_number, first_name, [])

  def send_contact(%Client{} = client, chat_id, phone_number, first_name) do
    send_contact(client, chat_id, phone_number, first_name, [])
  end

  def send_contact(chat_id, phone_number, first_name, options) do
    api_request(
      "sendContact",
      [chat_id: chat_id, phone_number: phone_number, first_name: first_name] ++ options
    )
  end

  def send_contact(%Client{} = client, chat_id, phone_number, first_name, options) do
    api_request(
      client,
      "sendContact",
      [chat_id: chat_id, phone_number: phone_number, first_name: first_name] ++ options
    )
  end

  @doc """
  Use this method when you need to tell the user that something is happening on
  the bot's side. The status is set for 5 seconds or less (when a message
  arrives from your bot, Telegram clients clear its typing status).

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `action` - Type of action to broadcast. Choose one, depending on what the user is
  about to receive:
      * `typing` for text messages
      * `upload_photo` for photos
      * `record_video` or `upload_video` for videos
      * `record_audio` or `upload_audio` for audio files
      * `upload_document` for general files
      * `find_location` for location data
  * `options` - orddict of options

  Options:
  * `:business_connection_id` - Unique identifier of the business connection
  * `:message_thread_id` - Unique identifier for the target message thread
  """
  @spec send_chat_action(integer | binary, binary) :: :ok | {:error, Error.t()}
  @spec send_chat_action(integer | binary, binary, [{atom, any}]) :: :ok | {:error, Error.t()}
  @spec send_chat_action(Client.t(), integer | binary, binary) :: :ok | {:error, Error.t()}
  @spec send_chat_action(Client.t(), integer | binary, binary, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  def send_chat_action(chat_id, action) do
    send_chat_action(chat_id, action, [])
  end

  def send_chat_action(%Client{} = client, chat_id, action) do
    send_chat_action(client, chat_id, action, [])
  end

  def send_chat_action(chat_id, action, options) do
    api_request("sendChatAction", [chat_id: chat_id, action: action] ++ options)
  end

  def send_chat_action(%Client{} = client, chat_id, action, options) do
    api_request(client, "sendChatAction", [chat_id: chat_id, action: action] ++ options)
  end

  @doc """
  Use this method to send animation files (GIF or H.264/MPEG-4 AVC video without sound).
  On success, the sent Message is returned. Bots can currently send animation files of up
  to 50 MB in size, this limit may be changed in the future.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `animation` - Animation to send. Pass a file_id as String to send an animation that
  exists on the Telegram servers (recommended), pass an HTTP URL as a String for
  Telegram to get an animation from the Internet, or upload a new animation using multipart/form-data.

  Options:
  * `:duration` - Duration of sent animation in seconds
  * `:width` - Animation width
  * `:height` - Animation height
  * `:thumb` - Thumbnail of the file sent; can be ignored if thumbnail generation for the file
  is supported server-side. thumbnail should be in JPEG format and less than 200 kB in size.
  * `:caption` - Animation caption (may also be used when resending animation by file_id), 0-1024 characters
  * `:parse_mode` - Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width
  text or inline URLs in the media caption.
  * `:disable_notification` - Sends the message silently. Users will receive a notification with no sound.
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. A JSON-serialized object for an inline keyboard,
  custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
  """
  @spec send_animation(integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec send_animation(Client.t(), integer | binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_animation(chat_id, animation), do: send_animation(chat_id, animation, [])

  def send_animation(%Client{} = client, chat_id, animation) do
    send_animation(client, chat_id, animation, [])
  end

  def send_animation(chat_id, animation, options) do
    api_request("sendAnimation", [chat_id: chat_id, animation: animation] ++ options)
  end

  def send_animation(%Client{} = client, chat_id, animation, options) do
    api_request(client, "sendAnimation", [chat_id: chat_id, animation: animation] ++ options)
  end

  @doc """
  Use this method to get a list of profile pictures for a user.
  Returns a UserProfilePhotos object.

  Args:
  * `user_id` - Unique identifier of the target user
  * `options` - orddict of options

  Options:
  * `:offset` - Sequential number of the first photo to be returned. By default, all
  photos are returned
  * `:limit` - Limits the number of photos to be retrieved. Values between 1—100 are
  accepted. Defaults to 100
  """
  @spec get_user_profile_photos(integer, [{atom, any}]) ::
          {:ok, UserProfilePhotos.t()} | {:error, Error.t()}
  @spec get_user_profile_photos(Client.t(), integer, [{atom, any}]) ::
          {:ok, UserProfilePhotos.t()} | {:error, Error.t()}
  def get_user_profile_photos(user_id), do: get_user_profile_photos(user_id, [])

  def get_user_profile_photos(%Client{} = client, user_id) do
    get_user_profile_photos(client, user_id, [])
  end

  def get_user_profile_photos(user_id, options) do
    api_request("getUserProfilePhotos", [user_id: user_id] ++ options)
  end

  def get_user_profile_photos(%Client{} = client, user_id, options) do
    api_request(client, "getUserProfilePhotos", [user_id: user_id] ++ options)
  end

  @doc """
  Use this method to get a list of profile audios for a user.
  Returns a UserProfileAudios object.

  Args:
  * `user_id` - Unique identifier of the target user
  * `options` - orddict of options

  Options:
  * `:offset` - Sequential number of the first audio to be returned
  * `:limit` - Limits the number of audios to be retrieved
  """
  @spec get_user_profile_audios(integer) :: {:ok, UserProfileAudios.t()} | {:error, Error.t()}
  @spec get_user_profile_audios(integer, [{atom, any}] | map) ::
          {:ok, UserProfileAudios.t()} | {:error, Error.t()}
  @spec get_user_profile_audios(Client.t(), integer) ::
          {:ok, UserProfileAudios.t()} | {:error, Error.t()}
  @spec get_user_profile_audios(Client.t(), integer, [{atom, any}] | map) ::
          {:ok, UserProfileAudios.t()} | {:error, Error.t()}
  def get_user_profile_audios(user_id), do: get_user_profile_audios(user_id, [])

  def get_user_profile_audios(%Client{} = client, user_id) do
    get_user_profile_audios(client, user_id, [])
  end

  def get_user_profile_audios(user_id, options) do
    api_request("getUserProfileAudios", request_options([user_id: user_id], options))
  end

  def get_user_profile_audios(%Client{} = client, user_id, options) do
    api_request(client, "getUserProfileAudios", request_options([user_id: user_id], options))
  end

  @doc """
  Use this method to set a user's score in a game message.
  On success, the edited Message is returned, or `:ok` is returned when editing
  an inline message.

  Args:
  * `user_id` - User identifier
  * `score` - New score
  * `options` - orddict or map of options
  """
  @spec set_game_score(integer, integer) :: {:ok, Message.t()} | :ok | {:error, Error.t()}
  @spec set_game_score(integer, integer, [{atom, any}] | map) ::
          {:ok, Message.t()} | :ok | {:error, Error.t()}
  @spec set_game_score(Client.t(), integer, integer) ::
          {:ok, Message.t()} | :ok | {:error, Error.t()}
  @spec set_game_score(Client.t(), integer, integer, [{atom, any}] | map) ::
          {:ok, Message.t()} | :ok | {:error, Error.t()}
  def set_game_score(user_id, score), do: set_game_score(user_id, score, [])

  def set_game_score(%Client{} = client, user_id, score) do
    set_game_score(client, user_id, score, [])
  end

  def set_game_score(user_id, score, options) do
    api_request("setGameScore", request_options([user_id: user_id, score: score], options))
  end

  def set_game_score(%Client{} = client, user_id, score, options) do
    api_request(
      client,
      "setGameScore",
      request_options([user_id: user_id, score: score], options)
    )
  end

  @doc """
  Use this method to get data for game high score tables.
  Returns a list of GameHighScore objects.

  Args:
  * `user_id` - Target user identifier
  * `options` - orddict or map of options
  """
  @spec get_game_high_scores(integer) :: {:ok, [GameHighScore.t()]} | {:error, Error.t()}
  @spec get_game_high_scores(integer, [{atom, any}] | map) ::
          {:ok, [GameHighScore.t()]} | {:error, Error.t()}
  @spec get_game_high_scores(Client.t(), integer) ::
          {:ok, [GameHighScore.t()]} | {:error, Error.t()}
  @spec get_game_high_scores(Client.t(), integer, [{atom, any}] | map) ::
          {:ok, [GameHighScore.t()]} | {:error, Error.t()}
  def get_game_high_scores(user_id), do: get_game_high_scores(user_id, [])

  def get_game_high_scores(%Client{} = client, user_id) do
    get_game_high_scores(client, user_id, [])
  end

  def get_game_high_scores(user_id, options) do
    api_request("getGameHighScores", request_options([user_id: user_id], options))
  end

  def get_game_high_scores(%Client{} = client, user_id, options) do
    api_request(client, "getGameHighScores", request_options([user_id: user_id], options))
  end

  @doc """
  Use this method to receive incoming updates using long polling.
  An Array of Update objects is returned.

  Args:
  * `options` - orddict of options

  Options:
  * `:offset` - Identifier of the first update to be returned. Must be greater by one
  than the highest among the identifiers of previously received updates. By default,
  updates starting with the earliest unconfirmed update are returned. An update is
  considered confirmed as soon as `get_updates` is called with an `offset` higher than
  its `update_id`.
  * `:limit` - Limits the number of updates to be retrieved. Values between 1—100 are
  accepted. Defaults to 100
  * `:timeout` - Timeout in seconds for long polling. Defaults to 0, i.e. usual short
  polling
  """
  @spec get_updates([{atom, any}]) :: {:ok, [Update.t()]} | {:error, Error.t()}
  @spec get_updates(Client.t(), [{atom, any}]) :: {:ok, [Update.t()]} | {:error, Error.t()}
  def get_updates(), do: get_updates([])
  def get_updates(%Client{} = client), do: get_updates(client, [])
  def get_updates(options), do: api_request("getUpdates", options)
  def get_updates(%Client{} = client, options), do: api_request(client, "getUpdates", options)

  @doc """
  Use this method to specify a url and receive incoming updates via an outgoing
  webhook. Whenever there is an update for the bot, we will send an HTTPS POST
  request to the specified url, containing a JSON-serialized Update. In case of
  an unsuccessful request, we will give up after a reasonable amount of attempts.

  Args:
  * `options` - orddict of options

  Options:
  * `:url` - HTTPS url to send updates to.
  """
  @spec set_webhook([{atom, any}]) :: :ok | {:error, Error.t()}
  @spec set_webhook(Client.t(), [{atom, any}]) :: :ok | {:error, Error.t()}
  def set_webhook(), do: set_webhook([])
  def set_webhook(%Client{} = client), do: set_webhook(client, [])
  def set_webhook(options), do: api_request("setWebhook", options)
  def set_webhook(%Client{} = client, options), do: api_request(client, "setWebhook", options)

  @doc """
  Use this method to remove webhook integration if you decide to switch back to `Nadia.get_updates/1`.
  Returns `:ok` on success.

  Args:
  * `options` - orddict of options

  Options:
  * `:drop_pending_updates` - Pass True to drop all pending updates
  """
  @spec delete_webhook() :: :ok | {:error, Error.t()}
  @spec delete_webhook([{atom, any}]) :: :ok | {:error, Error.t()}
  @spec delete_webhook(Client.t()) :: :ok | {:error, Error.t()}
  @spec delete_webhook(Client.t(), [{atom, any}]) :: :ok | {:error, Error.t()}
  def delete_webhook(), do: delete_webhook([])
  def delete_webhook(%Client{} = client), do: delete_webhook(client, [])
  def delete_webhook(options), do: api_request("deleteWebhook", options)

  def delete_webhook(%Client{} = client, options),
    do: api_request(client, "deleteWebhook", options)

  @doc """
  Use this method to get current webhook status. Requires no parameters.
  On success, returns a `Nadia.Model.WebhookInfo.t()` object with webhook details.
  If the bot is using getUpdates, will return an object with the url field empty.
  """
  @spec get_webhook_info() :: {:ok, WebhookInfo.t()} | {:error, Error.t()}
  @spec get_webhook_info(Client.t()) :: {:ok, WebhookInfo.t()} | {:error, Error.t()}
  def get_webhook_info(), do: api_request("getWebhookInfo")
  def get_webhook_info(%Client{} = client), do: api_request(client, "getWebhookInfo")

  @doc """
  Use this method to get basic info about a file and prepare it for downloading.
  For the moment, bots can download files of up to 20MB in size.
  On success, a File object is returned.
  The file can then be downloaded via the link
  `https://api.telegram.org/file/bot<token>/<file_path>`, where <file_path> is taken
  from the response. It is guaranteed that the link will be valid for at least 1 hour.
  When the link expires, a new one can be requested by calling `get_file` again.

  Args:
  * `file_id` - File identifier to get info about
  """
  @spec get_file(binary) :: {:ok, File.t()} | {:error, Error.t()}
  @spec get_file(Client.t(), binary) :: {:ok, File.t()} | {:error, Error.t()}
  def get_file(file_id), do: api_request("getFile", file_id: file_id)
  def get_file(%Client{} = client, file_id), do: api_request(client, "getFile", file_id: file_id)

  @doc ~S"""
  Use this method to get link for file for subsequent use.
  This method is an extension of the `get_file` method.

      iex> Nadia.get_file_link(%Nadia.Model.File{file_id: "BQADBQADBgADmEjsA1aqdSxtzvvVAg",
      ...> file_path: "document/file_10", file_size: 17680})
      {:ok,
      "https://api.telegram.org/file/bot#{Nadia.Config.token()}/document/file_10"}

  """
  @spec get_file_link(File.t()) :: {:ok, binary} | {:error, Error.t()}
  @spec get_file_link(Client.t(), File.t()) :: {:ok, binary} | {:error, Error.t()}
  def get_file_link(file) do
    {:ok, build_file_url(file.file_path)}
  end

  def get_file_link(%Client{} = client, file) do
    {:ok, build_file_url(client, file.file_path)}
  end

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
  * `options` - orddict of options
  """
  @spec ban_chat_member(integer | binary, integer) :: :ok | {:error, Error.t()}
  @spec ban_chat_member(integer | binary, integer, [{atom, any}]) :: :ok | {:error, Error.t()}
  @spec ban_chat_member(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
  @spec ban_chat_member(Client.t(), integer | binary, integer, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  def ban_chat_member(chat_id, user_id), do: ban_chat_member(chat_id, user_id, [])

  def ban_chat_member(%Client{} = client, chat_id, user_id) do
    ban_chat_member(client, chat_id, user_id, [])
  end

  def ban_chat_member(chat_id, user_id, options) do
    api_request("banChatMember", [chat_id: chat_id, user_id: user_id] ++ options)
  end

  def ban_chat_member(%Client{} = client, chat_id, user_id, options) do
    api_request(client, "banChatMember", [chat_id: chat_id, user_id: user_id] ++ options)
  end

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

  def leave_chat(%Client{} = client, chat_id) do
    api_request(client, "leaveChat", chat_id: chat_id)
  end

  @doc """
  Use this method to unban a previously kicked user in a supergroup. The user will not
  return to the group automatically, but will be able to join via link, etc. The bot
  must be an administrator in the group for this to work. Returns True on success.

  Args:
  * `chat_id` - Unique identifier for the target group or username of the target supergroup
  (in the format @supergroupusername)
  * `user_id` - Unique identifier of the target user
  * `options` - orddict of options

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

  def unban_chat_member(%Client{} = client, chat_id, user_id) do
    unban_chat_member(client, chat_id, user_id, [])
  end

  def unban_chat_member(chat_id, user_id, options) do
    api_request("unbanChatMember", [chat_id: chat_id, user_id: user_id] ++ options)
  end

  def unban_chat_member(%Client{} = client, chat_id, user_id, options) do
    api_request(client, "unbanChatMember", [chat_id: chat_id, user_id: user_id] ++ options)
  end

  @doc """
  Use this method to restrict a user in a supergroup. Returns True on success.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target supergroup
  (in the format @supergroupusername)
  * `user_id` - Unique identifier of the target user
  * `permissions` - New user permissions
  * `options` - orddict of options
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

  def restrict_chat_member(%Client{} = client, chat_id, user_id, permissions, options) do
    api_request(
      client,
      "restrictChatMember",
      [chat_id: chat_id, user_id: user_id, permissions: encode_permissions(permissions)] ++
        options
    )
  end

  @doc """
  Use this method to promote or demote a user in a supergroup or a channel.
  Returns True on success.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  * `user_id` - Unique identifier of the target user
  * `options` - orddict of options
  """
  @spec promote_chat_member(integer | binary, integer) :: :ok | {:error, Error.t()}
  @spec promote_chat_member(integer | binary, integer, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  @spec promote_chat_member(Client.t(), integer | binary, integer) ::
          :ok | {:error, Error.t()}
  @spec promote_chat_member(Client.t(), integer | binary, integer, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  def promote_chat_member(chat_id, user_id), do: promote_chat_member(chat_id, user_id, [])

  def promote_chat_member(%Client{} = client, chat_id, user_id) do
    promote_chat_member(client, chat_id, user_id, [])
  end

  def promote_chat_member(chat_id, user_id, options) do
    api_request("promoteChatMember", [chat_id: chat_id, user_id: user_id] ++ options)
  end

  def promote_chat_member(%Client{} = client, chat_id, user_id, options) do
    api_request(client, "promoteChatMember", [chat_id: chat_id, user_id: user_id] ++ options)
  end

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

  def set_chat_administrator_custom_title(%Client{} = client, chat_id, user_id, custom_title) do
    api_request(
      client,
      "setChatAdministratorCustomTitle",
      chat_id: chat_id,
      user_id: user_id,
      custom_title: custom_title
    )
  end

  @doc """
  Use this method to change the tag of a user in a direct messages chat. Returns True on success.

  Args:
  * `chat_id` - Unique identifier for the target chat
  * `user_id` - Unique identifier of the target user
  * `options` - orddict of options
  """
  @spec set_chat_member_tag(integer | binary, integer) :: :ok | {:error, Error.t()}
  @spec set_chat_member_tag(integer | binary, integer, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  @spec set_chat_member_tag(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
  @spec set_chat_member_tag(Client.t(), integer | binary, integer, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  def set_chat_member_tag(chat_id, user_id), do: set_chat_member_tag(chat_id, user_id, [])

  def set_chat_member_tag(%Client{} = client, chat_id, user_id) do
    set_chat_member_tag(client, chat_id, user_id, [])
  end

  def set_chat_member_tag(chat_id, user_id, options) do
    api_request("setChatMemberTag", [chat_id: chat_id, user_id: user_id] ++ options)
  end

  def set_chat_member_tag(%Client{} = client, chat_id, user_id, options) do
    api_request(client, "setChatMemberTag", [chat_id: chat_id, user_id: user_id] ++ options)
  end

  @doc """
  Use this method to ban a channel chat in a supergroup or a channel. Returns True on success.
  """
  @spec ban_chat_sender_chat(integer | binary, integer) :: :ok | {:error, Error.t()}
  @spec ban_chat_sender_chat(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
  def ban_chat_sender_chat(chat_id, sender_chat_id) do
    api_request("banChatSenderChat", chat_id: chat_id, sender_chat_id: sender_chat_id)
  end

  def ban_chat_sender_chat(%Client{} = client, chat_id, sender_chat_id) do
    api_request(client, "banChatSenderChat", chat_id: chat_id, sender_chat_id: sender_chat_id)
  end

  @doc """
  Use this method to unban a previously banned channel chat. Returns True on success.
  """
  @spec unban_chat_sender_chat(integer | binary, integer) :: :ok | {:error, Error.t()}
  @spec unban_chat_sender_chat(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
  def unban_chat_sender_chat(chat_id, sender_chat_id) do
    api_request("unbanChatSenderChat", chat_id: chat_id, sender_chat_id: sender_chat_id)
  end

  def unban_chat_sender_chat(%Client{} = client, chat_id, sender_chat_id) do
    api_request(client, "unbanChatSenderChat", chat_id: chat_id, sender_chat_id: sender_chat_id)
  end

  @doc """
  Use this method to set default chat permissions for all members. Returns True on success.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target supergroup
  * `permissions` - New default chat permissions
  * `options` - orddict of options
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

  def set_chat_permissions(%Client{} = client, chat_id, permissions) do
    set_chat_permissions(client, chat_id, permissions, [])
  end

  def set_chat_permissions(chat_id, permissions, options) do
    api_request(
      "setChatPermissions",
      [chat_id: chat_id, permissions: encode_permissions(permissions)] ++ options
    )
  end

  def set_chat_permissions(%Client{} = client, chat_id, permissions, options) do
    api_request(
      client,
      "setChatPermissions",
      [chat_id: chat_id, permissions: encode_permissions(permissions)] ++ options
    )
  end

  @doc """
  Use this method to approve a chat join request. Returns True on success.
  """
  @spec approve_chat_join_request(integer | binary, integer) :: :ok | {:error, Error.t()}
  @spec approve_chat_join_request(Client.t(), integer | binary, integer) ::
          :ok | {:error, Error.t()}
  def approve_chat_join_request(chat_id, user_id) do
    api_request("approveChatJoinRequest", chat_id: chat_id, user_id: user_id)
  end

  def approve_chat_join_request(%Client{} = client, chat_id, user_id) do
    api_request(client, "approveChatJoinRequest", chat_id: chat_id, user_id: user_id)
  end

  @doc """
  Use this method to decline a chat join request. Returns True on success.
  """
  @spec decline_chat_join_request(integer | binary, integer) :: :ok | {:error, Error.t()}
  @spec decline_chat_join_request(Client.t(), integer | binary, integer) ::
          :ok | {:error, Error.t()}
  def decline_chat_join_request(chat_id, user_id) do
    api_request("declineChatJoinRequest", chat_id: chat_id, user_id: user_id)
  end

  def decline_chat_join_request(%Client{} = client, chat_id, user_id) do
    api_request(client, "declineChatJoinRequest", chat_id: chat_id, user_id: user_id)
  end

  @doc """
  Use this method to delete a chat photo. Returns True on success.
  """
  @spec delete_chat_photo(integer | binary) :: :ok | {:error, Error.t()}
  @spec delete_chat_photo(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
  def delete_chat_photo(chat_id) do
    api_request("deleteChatPhoto", chat_id: chat_id)
  end

  def delete_chat_photo(%Client{} = client, chat_id) do
    api_request(client, "deleteChatPhoto", chat_id: chat_id)
  end

  @doc """
  Use this method to set a new profile photo for the chat. Returns True on success.
  """
  @spec set_chat_photo(integer | binary, binary) :: :ok | {:error, Error.t()}
  @spec set_chat_photo(Client.t(), integer | binary, binary) :: :ok | {:error, Error.t()}
  def set_chat_photo(chat_id, photo) do
    api_request("setChatPhoto", [chat_id: chat_id, photo: photo], :photo)
  end

  def set_chat_photo(%Client{} = client, chat_id, photo) do
    api_request(client, "setChatPhoto", [chat_id: chat_id, photo: photo], :photo)
  end

  @doc """
  Use this method to change the title of a chat. Returns True on success.
  """
  @spec set_chat_title(integer | binary, binary) :: :ok | {:error, Error.t()}
  @spec set_chat_title(Client.t(), integer | binary, binary) :: :ok | {:error, Error.t()}
  def set_chat_title(chat_id, title) do
    api_request("setChatTitle", chat_id: chat_id, title: title)
  end

  def set_chat_title(%Client{} = client, chat_id, title) do
    api_request(client, "setChatTitle", chat_id: chat_id, title: title)
  end

  @doc """
  Use this method to change the description of a chat. Returns True on success.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  * `options` - orddict of options
  """
  @spec set_chat_description(integer | binary) :: :ok | {:error, Error.t()}
  @spec set_chat_description(integer | binary, [{atom, any}]) :: :ok | {:error, Error.t()}
  @spec set_chat_description(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
  @spec set_chat_description(Client.t(), integer | binary, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  def set_chat_description(chat_id) do
    set_chat_description(chat_id, [])
  end

  def set_chat_description(%Client{} = client, chat_id) do
    set_chat_description(client, chat_id, [])
  end

  def set_chat_description(chat_id, options) do
    api_request("setChatDescription", [chat_id: chat_id] ++ options)
  end

  def set_chat_description(%Client{} = client, chat_id, options) do
    api_request(client, "setChatDescription", [chat_id: chat_id] ++ options)
  end

  @doc """
  Use this method to clear the list of pinned messages in a chat. Returns True on success.
  """
  @spec unpin_all_chat_messages(integer | binary) :: :ok | {:error, Error.t()}
  @spec unpin_all_chat_messages(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
  def unpin_all_chat_messages(chat_id) do
    api_request("unpinAllChatMessages", chat_id: chat_id)
  end

  def unpin_all_chat_messages(%Client{} = client, chat_id) do
    api_request(client, "unpinAllChatMessages", chat_id: chat_id)
  end

  @doc """
  Use this method to set a new group sticker set for a supergroup. Returns True on success.
  """
  @spec set_chat_sticker_set(integer | binary, binary) :: :ok | {:error, Error.t()}
  @spec set_chat_sticker_set(Client.t(), integer | binary, binary) :: :ok | {:error, Error.t()}
  def set_chat_sticker_set(chat_id, sticker_set_name) do
    api_request("setChatStickerSet", chat_id: chat_id, sticker_set_name: sticker_set_name)
  end

  def set_chat_sticker_set(%Client{} = client, chat_id, sticker_set_name) do
    api_request(
      client,
      "setChatStickerSet",
      chat_id: chat_id,
      sticker_set_name: sticker_set_name
    )
  end

  @doc """
  Use this method to delete a group sticker set from a supergroup. Returns True on success.
  """
  @spec delete_chat_sticker_set(integer | binary) :: :ok | {:error, Error.t()}
  @spec delete_chat_sticker_set(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
  def delete_chat_sticker_set(chat_id) do
    api_request("deleteChatStickerSet", chat_id: chat_id)
  end

  def delete_chat_sticker_set(%Client{} = client, chat_id) do
    api_request(client, "deleteChatStickerSet", chat_id: chat_id)
  end

  @doc """
  Use this method to get custom emoji stickers that can be used as forum topic icons.
  Returns an array of Sticker objects.
  """
  @spec get_forum_topic_icon_stickers() :: {:ok, [Sticker.t()]} | {:error, Error.t()}
  @spec get_forum_topic_icon_stickers(Client.t()) :: {:ok, [Sticker.t()]} | {:error, Error.t()}
  def get_forum_topic_icon_stickers, do: api_request("getForumTopicIconStickers")

  def get_forum_topic_icon_stickers(%Client{} = client) do
    api_request(client, "getForumTopicIconStickers")
  end

  @doc """
  Use this method to create a topic in a forum supergroup chat or private chat.
  Returns information about the created topic as a ForumTopic object.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target supergroup
  * `name` - Topic name
  * `options` - orddict of options

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

  def create_forum_topic(%Client{} = client, chat_id, name) do
    create_forum_topic(client, chat_id, name, [])
  end

  def create_forum_topic(chat_id, name, options) do
    api_request("createForumTopic", [chat_id: chat_id, name: name] ++ options)
  end

  def create_forum_topic(%Client{} = client, chat_id, name, options) do
    api_request(client, "createForumTopic", [chat_id: chat_id, name: name] ++ options)
  end

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

  def edit_forum_topic(%Client{} = client, chat_id, message_thread_id) do
    edit_forum_topic(client, chat_id, message_thread_id, [])
  end

  def edit_forum_topic(chat_id, message_thread_id, options) do
    api_request(
      "editForumTopic",
      [chat_id: chat_id, message_thread_id: message_thread_id] ++ options
    )
  end

  def edit_forum_topic(%Client{} = client, chat_id, message_thread_id, options) do
    api_request(
      client,
      "editForumTopic",
      [chat_id: chat_id, message_thread_id: message_thread_id] ++ options
    )
  end

  @doc """
  Use this method to close an open forum topic. Returns True on success.
  """
  @spec close_forum_topic(integer | binary, integer) :: :ok | {:error, Error.t()}
  @spec close_forum_topic(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
  def close_forum_topic(chat_id, message_thread_id) do
    api_request("closeForumTopic", chat_id: chat_id, message_thread_id: message_thread_id)
  end

  def close_forum_topic(%Client{} = client, chat_id, message_thread_id) do
    api_request(client, "closeForumTopic", chat_id: chat_id, message_thread_id: message_thread_id)
  end

  @doc """
  Use this method to reopen a closed forum topic. Returns True on success.
  """
  @spec reopen_forum_topic(integer | binary, integer) :: :ok | {:error, Error.t()}
  @spec reopen_forum_topic(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
  def reopen_forum_topic(chat_id, message_thread_id) do
    api_request("reopenForumTopic", chat_id: chat_id, message_thread_id: message_thread_id)
  end

  def reopen_forum_topic(%Client{} = client, chat_id, message_thread_id) do
    api_request(client, "reopenForumTopic",
      chat_id: chat_id,
      message_thread_id: message_thread_id
    )
  end

  @doc """
  Use this method to delete a forum topic and all its messages. Returns True on success.
  """
  @spec delete_forum_topic(integer | binary, integer) :: :ok | {:error, Error.t()}
  @spec delete_forum_topic(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
  def delete_forum_topic(chat_id, message_thread_id) do
    api_request("deleteForumTopic", chat_id: chat_id, message_thread_id: message_thread_id)
  end

  def delete_forum_topic(%Client{} = client, chat_id, message_thread_id) do
    api_request(client, "deleteForumTopic",
      chat_id: chat_id,
      message_thread_id: message_thread_id
    )
  end

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

  def unpin_all_forum_topic_messages(%Client{} = client, chat_id, message_thread_id) do
    api_request(client, "unpinAllForumTopicMessages",
      chat_id: chat_id,
      message_thread_id: message_thread_id
    )
  end

  @doc """
  Use this method to edit the name of the General forum topic. Returns True on success.
  """
  @spec edit_general_forum_topic(integer | binary, binary) :: :ok | {:error, Error.t()}
  @spec edit_general_forum_topic(Client.t(), integer | binary, binary) ::
          :ok | {:error, Error.t()}
  def edit_general_forum_topic(chat_id, name) do
    api_request("editGeneralForumTopic", chat_id: chat_id, name: name)
  end

  def edit_general_forum_topic(%Client{} = client, chat_id, name) do
    api_request(client, "editGeneralForumTopic", chat_id: chat_id, name: name)
  end

  @doc """
  Use this method to close an open General forum topic. Returns True on success.
  """
  @spec close_general_forum_topic(integer | binary) :: :ok | {:error, Error.t()}
  @spec close_general_forum_topic(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
  def close_general_forum_topic(chat_id) do
    api_request("closeGeneralForumTopic", chat_id: chat_id)
  end

  def close_general_forum_topic(%Client{} = client, chat_id) do
    api_request(client, "closeGeneralForumTopic", chat_id: chat_id)
  end

  @doc """
  Use this method to reopen a closed General forum topic. Returns True on success.
  """
  @spec reopen_general_forum_topic(integer | binary) :: :ok | {:error, Error.t()}
  @spec reopen_general_forum_topic(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
  def reopen_general_forum_topic(chat_id) do
    api_request("reopenGeneralForumTopic", chat_id: chat_id)
  end

  def reopen_general_forum_topic(%Client{} = client, chat_id) do
    api_request(client, "reopenGeneralForumTopic", chat_id: chat_id)
  end

  @doc """
  Use this method to hide the General forum topic. Returns True on success.
  """
  @spec hide_general_forum_topic(integer | binary) :: :ok | {:error, Error.t()}
  @spec hide_general_forum_topic(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
  def hide_general_forum_topic(chat_id) do
    api_request("hideGeneralForumTopic", chat_id: chat_id)
  end

  def hide_general_forum_topic(%Client{} = client, chat_id) do
    api_request(client, "hideGeneralForumTopic", chat_id: chat_id)
  end

  @doc """
  Use this method to unhide the General forum topic. Returns True on success.
  """
  @spec unhide_general_forum_topic(integer | binary) :: :ok | {:error, Error.t()}
  @spec unhide_general_forum_topic(Client.t(), integer | binary) :: :ok | {:error, Error.t()}
  def unhide_general_forum_topic(chat_id) do
    api_request("unhideGeneralForumTopic", chat_id: chat_id)
  end

  def unhide_general_forum_topic(%Client{} = client, chat_id) do
    api_request(client, "unhideGeneralForumTopic", chat_id: chat_id)
  end

  @doc """
  Use this method to clear pinned messages in the General forum topic. Returns True on success.
  """
  @spec unpin_all_general_forum_topic_messages(integer | binary) :: :ok | {:error, Error.t()}
  @spec unpin_all_general_forum_topic_messages(Client.t(), integer | binary) ::
          :ok | {:error, Error.t()}
  def unpin_all_general_forum_topic_messages(chat_id) do
    api_request("unpinAllGeneralForumTopicMessages", chat_id: chat_id)
  end

  def unpin_all_general_forum_topic_messages(%Client{} = client, chat_id) do
    api_request(client, "unpinAllGeneralForumTopicMessages", chat_id: chat_id)
  end

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

  def get_chat(%Client{} = client, chat_id) do
    api_request(client, "getChat", chat_id: chat_id)
  end

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

  def export_chat_invite_link(%Client{} = client, chat_id) do
    api_request(client, "exportChatInviteLink", chat_id: chat_id)
  end

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

  def create_chat_invite_link(%Client{} = client, chat_id) do
    create_chat_invite_link(client, chat_id, [])
  end

  def create_chat_invite_link(chat_id, options) do
    api_request("createChatInviteLink", request_options([chat_id: chat_id], options))
  end

  def create_chat_invite_link(%Client{} = client, chat_id, options) do
    api_request(client, "createChatInviteLink", request_options([chat_id: chat_id], options))
  end

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

  def edit_chat_invite_link(%Client{} = client, chat_id, invite_link) do
    edit_chat_invite_link(client, chat_id, invite_link, [])
  end

  def edit_chat_invite_link(chat_id, invite_link, options) do
    api_request(
      "editChatInviteLink",
      request_options([chat_id: chat_id, invite_link: invite_link], options)
    )
  end

  def edit_chat_invite_link(%Client{} = client, chat_id, invite_link, options) do
    api_request(
      client,
      "editChatInviteLink",
      request_options([chat_id: chat_id, invite_link: invite_link], options)
    )
  end

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

  def edit_chat_subscription_invite_link(%Client{} = client, chat_id, invite_link) do
    edit_chat_subscription_invite_link(client, chat_id, invite_link, [])
  end

  def edit_chat_subscription_invite_link(chat_id, invite_link, options) do
    api_request(
      "editChatSubscriptionInviteLink",
      request_options([chat_id: chat_id, invite_link: invite_link], options)
    )
  end

  def edit_chat_subscription_invite_link(%Client{} = client, chat_id, invite_link, options) do
    api_request(
      client,
      "editChatSubscriptionInviteLink",
      request_options([chat_id: chat_id, invite_link: invite_link], options)
    )
  end

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

  def revoke_chat_invite_link(%Client{} = client, chat_id, invite_link) do
    api_request(client, "revokeChatInviteLink", chat_id: chat_id, invite_link: invite_link)
  end

  @doc """
  Use this method to get a list of administrators in a chat. On success, returns an Array of
  ChatMember objects that contains information about all chat administrators except other bots.
  If the chat is a group or a supergroup and no administrators were appointed, only the creator
  will be returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target supergroup or
  channel (in the format @channelusername)
  * `options` - orddict of options

  Options:
  * `:return_bots` - Pass True to include bots in the returned administrator list
  """
  @spec get_chat_administrators(integer | binary) :: {:ok, [ChatMember.t()]} | {:error, Error.t()}
  @spec get_chat_administrators(integer | binary, [{atom, any}]) ::
          {:ok, [ChatMember.t()]} | {:error, Error.t()}
  @spec get_chat_administrators(Client.t(), integer | binary) ::
          {:ok, [ChatMember.t()]} | {:error, Error.t()}
  @spec get_chat_administrators(Client.t(), integer | binary, [{atom, any}]) ::
          {:ok, [ChatMember.t()]} | {:error, Error.t()}
  def get_chat_administrators(chat_id) do
    get_chat_administrators(chat_id, [])
  end

  def get_chat_administrators(%Client{} = client, chat_id) do
    get_chat_administrators(client, chat_id, [])
  end

  def get_chat_administrators(chat_id, options) do
    api_request("getChatAdministrators", [chat_id: chat_id] ++ options)
  end

  def get_chat_administrators(%Client{} = client, chat_id, options) do
    api_request(client, "getChatAdministrators", [chat_id: chat_id] ++ options)
  end

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

  def get_chat_member_count(%Client{} = client, chat_id) do
    api_request(client, "getChatMemberCount", chat_id: chat_id)
  end

  @doc """
  Use this method to get information about a member of a chat.
  Returns a ChatMember object on success.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target supergroup or
  channel (in the format @channelusername)
  * `user_id` - Unique identifier of the target user
  """
  @spec get_chat_member(integer | binary, integer) :: {:ok, ChatMember.t()} | {:error, Error.t()}
  @spec get_chat_member(Client.t(), integer | binary, integer) ::
          {:ok, ChatMember.t()} | {:error, Error.t()}
  def get_chat_member(chat_id, user_id) do
    api_request("getChatMember", chat_id: chat_id, user_id: user_id)
  end

  def get_chat_member(%Client{} = client, chat_id, user_id) do
    api_request(client, "getChatMember", chat_id: chat_id, user_id: user_id)
  end

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

  def get_user_chat_boosts(%Client{} = client, chat_id, user_id) do
    api_request(client, "getUserChatBoosts", chat_id: chat_id, user_id: user_id)
  end

  @doc """
  Use this method to get information about the connection of the bot with a business account.
  Returns a BusinessConnection object.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  """
  @spec get_business_connection(binary) :: {:ok, BusinessConnection.t()} | {:error, Error.t()}
  @spec get_business_connection(Client.t(), binary) ::
          {:ok, BusinessConnection.t()} | {:error, Error.t()}
  def get_business_connection(business_connection_id) do
    api_request("getBusinessConnection", business_connection_id: business_connection_id)
  end

  def get_business_connection(%Client{} = client, business_connection_id) do
    api_request(client, "getBusinessConnection", business_connection_id: business_connection_id)
  end

  @doc """
  Use this method to get the Telegram Stars balance of a managed business account.
  Returns a StarAmount object.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  """
  @spec get_business_account_star_balance(binary) ::
          {:ok, StarAmount.t()} | {:error, Error.t()}
  @spec get_business_account_star_balance(Client.t(), binary) ::
          {:ok, StarAmount.t()} | {:error, Error.t()}
  def get_business_account_star_balance(business_connection_id) do
    api_request("getBusinessAccountStarBalance", business_connection_id: business_connection_id)
  end

  def get_business_account_star_balance(%Client{} = client, business_connection_id) do
    api_request(
      client,
      "getBusinessAccountStarBalance",
      business_connection_id: business_connection_id
    )
  end

  @doc """
  Use this method to mark an incoming message as read on behalf of a business account.
  Returns `:ok` on success.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  * `chat_id` - Unique identifier of the chat in which the message was received
  * `message_id` - Unique identifier of the message to mark as read
  """
  @spec read_business_message(binary, integer, integer) :: :ok | {:error, Error.t()}
  @spec read_business_message(Client.t(), binary, integer, integer) ::
          :ok | {:error, Error.t()}
  def read_business_message(business_connection_id, chat_id, message_id) do
    api_request(
      "readBusinessMessage",
      business_connection_id: business_connection_id,
      chat_id: chat_id,
      message_id: message_id
    )
  end

  def read_business_message(%Client{} = client, business_connection_id, chat_id, message_id) do
    api_request(
      client,
      "readBusinessMessage",
      business_connection_id: business_connection_id,
      chat_id: chat_id,
      message_id: message_id
    )
  end

  @doc """
  Use this method to delete messages on behalf of a business account.
  Returns `:ok` on success.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  * `message_ids` - List of message identifiers to delete
  """
  @spec delete_business_messages(binary, [integer]) :: :ok | {:error, Error.t()}
  @spec delete_business_messages(Client.t(), binary, [integer]) :: :ok | {:error, Error.t()}
  def delete_business_messages(business_connection_id, message_ids) do
    api_request(
      "deleteBusinessMessages",
      business_connection_id: business_connection_id,
      message_ids: encode_message_ids(message_ids)
    )
  end

  def delete_business_messages(%Client{} = client, business_connection_id, message_ids) do
    api_request(
      client,
      "deleteBusinessMessages",
      business_connection_id: business_connection_id,
      message_ids: encode_message_ids(message_ids)
    )
  end

  @doc """
  Use this method to change the first and last name of a managed business account.
  Returns `:ok` on success.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  * `first_name` - New first name of the business account
  * `options` - orddict of options

  Options:
  * `:last_name` - New last name of the business account
  """
  @spec set_business_account_name(binary, binary) :: :ok | {:error, Error.t()}
  @spec set_business_account_name(binary, binary, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  @spec set_business_account_name(Client.t(), binary, binary) :: :ok | {:error, Error.t()}
  @spec set_business_account_name(Client.t(), binary, binary, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  def set_business_account_name(business_connection_id, first_name) do
    set_business_account_name(business_connection_id, first_name, [])
  end

  def set_business_account_name(%Client{} = client, business_connection_id, first_name) do
    set_business_account_name(client, business_connection_id, first_name, [])
  end

  def set_business_account_name(business_connection_id, first_name, options) do
    api_request(
      "setBusinessAccountName",
      request_options(
        [business_connection_id: business_connection_id, first_name: first_name],
        options
      )
    )
  end

  def set_business_account_name(%Client{} = client, business_connection_id, first_name, options) do
    api_request(
      client,
      "setBusinessAccountName",
      request_options(
        [business_connection_id: business_connection_id, first_name: first_name],
        options
      )
    )
  end

  @doc """
  Use this method to change the username of a managed business account.
  Returns `:ok` on success.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  * `options` - orddict of options

  Options:
  * `:username` - New username of the business account
  """
  @spec set_business_account_username(binary) :: :ok | {:error, Error.t()}
  @spec set_business_account_username(binary, [{atom, any}] | map) :: :ok | {:error, Error.t()}
  @spec set_business_account_username(Client.t(), binary) :: :ok | {:error, Error.t()}
  @spec set_business_account_username(Client.t(), binary, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  def set_business_account_username(business_connection_id) do
    set_business_account_username(business_connection_id, [])
  end

  def set_business_account_username(%Client{} = client, business_connection_id) do
    set_business_account_username(client, business_connection_id, [])
  end

  def set_business_account_username(business_connection_id, options) do
    api_request(
      "setBusinessAccountUsername",
      request_options([business_connection_id: business_connection_id], options)
    )
  end

  def set_business_account_username(%Client{} = client, business_connection_id, options) do
    api_request(
      client,
      "setBusinessAccountUsername",
      request_options([business_connection_id: business_connection_id], options)
    )
  end

  @doc """
  Use this method to change the bio of a managed business account.
  Returns `:ok` on success.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  * `options` - orddict of options

  Options:
  * `:bio` - New bio of the business account
  """
  @spec set_business_account_bio(binary) :: :ok | {:error, Error.t()}
  @spec set_business_account_bio(binary, [{atom, any}] | map) :: :ok | {:error, Error.t()}
  @spec set_business_account_bio(Client.t(), binary) :: :ok | {:error, Error.t()}
  @spec set_business_account_bio(Client.t(), binary, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  def set_business_account_bio(business_connection_id) do
    set_business_account_bio(business_connection_id, [])
  end

  def set_business_account_bio(%Client{} = client, business_connection_id) do
    set_business_account_bio(client, business_connection_id, [])
  end

  def set_business_account_bio(business_connection_id, options) do
    api_request(
      "setBusinessAccountBio",
      request_options([business_connection_id: business_connection_id], options)
    )
  end

  def set_business_account_bio(%Client{} = client, business_connection_id, options) do
    api_request(
      client,
      "setBusinessAccountBio",
      request_options([business_connection_id: business_connection_id], options)
    )
  end

  @doc """
  Use this method to change the profile photo of a managed business account.
  Returns `:ok` on success.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  * `photo` - JSON-serializable profile photo object or a pre-encoded JSON string
  * `options` - orddict of options

  Options:
  * `:is_public` - Pass true to set the public profile photo
  """
  @spec set_business_account_profile_photo(binary, list | map | struct | binary) ::
          :ok | {:error, Error.t()}
  @spec set_business_account_profile_photo(
          binary,
          list | map | struct | binary,
          [{atom, any}] | map
        ) :: :ok | {:error, Error.t()}
  @spec set_business_account_profile_photo(Client.t(), binary, list | map | struct | binary) ::
          :ok | {:error, Error.t()}
  @spec set_business_account_profile_photo(
          Client.t(),
          binary,
          list | map | struct | binary,
          [{atom, any}] | map
        ) :: :ok | {:error, Error.t()}
  def set_business_account_profile_photo(business_connection_id, photo) do
    set_business_account_profile_photo(business_connection_id, photo, [])
  end

  def set_business_account_profile_photo(%Client{} = client, business_connection_id, photo) do
    set_business_account_profile_photo(client, business_connection_id, photo, [])
  end

  def set_business_account_profile_photo(business_connection_id, photo, options) do
    api_request(
      "setBusinessAccountProfilePhoto",
      request_options(
        [business_connection_id: business_connection_id, photo: encode_json_payload(photo)],
        options
      )
    )
  end

  def set_business_account_profile_photo(
        %Client{} = client,
        business_connection_id,
        photo,
        options
      ) do
    api_request(
      client,
      "setBusinessAccountProfilePhoto",
      request_options(
        [business_connection_id: business_connection_id, photo: encode_json_payload(photo)],
        options
      )
    )
  end

  @doc """
  Use this method to remove the current profile photo of a managed business account.
  Returns `:ok` on success.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  * `options` - orddict of options

  Options:
  * `:is_public` - Pass true to remove the public profile photo
  """
  @spec remove_business_account_profile_photo(binary) :: :ok | {:error, Error.t()}
  @spec remove_business_account_profile_photo(binary, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  @spec remove_business_account_profile_photo(Client.t(), binary) :: :ok | {:error, Error.t()}
  @spec remove_business_account_profile_photo(Client.t(), binary, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  def remove_business_account_profile_photo(business_connection_id) do
    remove_business_account_profile_photo(business_connection_id, [])
  end

  def remove_business_account_profile_photo(%Client{} = client, business_connection_id) do
    remove_business_account_profile_photo(client, business_connection_id, [])
  end

  def remove_business_account_profile_photo(business_connection_id, options) do
    api_request(
      "removeBusinessAccountProfilePhoto",
      request_options([business_connection_id: business_connection_id], options)
    )
  end

  def remove_business_account_profile_photo(%Client{} = client, business_connection_id, options) do
    api_request(
      client,
      "removeBusinessAccountProfilePhoto",
      request_options([business_connection_id: business_connection_id], options)
    )
  end

  @doc """
  Use this method to change the gift settings of a managed business account.
  Returns `:ok` on success.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  * `show_gift_button` - Whether the gift button must always be shown in the input field
  * `accepted_gift_types` - JSON-serializable accepted gift types object or pre-encoded JSON
  """
  @spec set_business_account_gift_settings(
          binary,
          boolean,
          list | map | struct | binary
        ) :: :ok | {:error, Error.t()}
  @spec set_business_account_gift_settings(
          Client.t(),
          binary,
          boolean,
          list | map | struct | binary
        ) :: :ok | {:error, Error.t()}
  def set_business_account_gift_settings(
        business_connection_id,
        show_gift_button,
        accepted_gift_types
      ) do
    api_request(
      "setBusinessAccountGiftSettings",
      business_connection_id: business_connection_id,
      show_gift_button: show_gift_button,
      accepted_gift_types: encode_json_payload(accepted_gift_types)
    )
  end

  def set_business_account_gift_settings(
        %Client{} = client,
        business_connection_id,
        show_gift_button,
        accepted_gift_types
      ) do
    api_request(
      client,
      "setBusinessAccountGiftSettings",
      business_connection_id: business_connection_id,
      show_gift_button: show_gift_button,
      accepted_gift_types: encode_json_payload(accepted_gift_types)
    )
  end

  @doc """
  Use this method to transfer Telegram Stars from a business account balance to the bot.
  Returns `:ok` on success.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  * `star_count` - Number of Telegram Stars to transfer
  """
  @spec transfer_business_account_stars(binary, integer) :: :ok | {:error, Error.t()}
  @spec transfer_business_account_stars(Client.t(), binary, integer) :: :ok | {:error, Error.t()}
  def transfer_business_account_stars(business_connection_id, star_count) do
    api_request(
      "transferBusinessAccountStars",
      business_connection_id: business_connection_id,
      star_count: star_count
    )
  end

  def transfer_business_account_stars(%Client{} = client, business_connection_id, star_count) do
    api_request(
      client,
      "transferBusinessAccountStars",
      business_connection_id: business_connection_id,
      star_count: star_count
    )
  end

  @doc """
  Use this method to convert a gift received by a managed business account to Telegram Stars.
  Returns `:ok` on success.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  * `owned_gift_id` - Unique identifier of the regular gift that should be converted to Telegram Stars
  """
  @spec convert_gift_to_stars(binary, binary) :: :ok | {:error, Error.t()}
  @spec convert_gift_to_stars(Client.t(), binary, binary) :: :ok | {:error, Error.t()}
  def convert_gift_to_stars(business_connection_id, owned_gift_id) do
    api_request(
      "convertGiftToStars",
      business_connection_id: business_connection_id,
      owned_gift_id: owned_gift_id
    )
  end

  def convert_gift_to_stars(%Client{} = client, business_connection_id, owned_gift_id) do
    api_request(
      client,
      "convertGiftToStars",
      business_connection_id: business_connection_id,
      owned_gift_id: owned_gift_id
    )
  end

  @doc """
  Use this method to upgrade a gift received by a managed business account.
  Returns `:ok` on success.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  * `owned_gift_id` - Unique identifier of the regular gift that should be upgraded
  * `options` - orddict of options

  Options:
  * `:keep_original_details` - Pass true to keep the original gift text, sender, and receiver in the upgraded gift
  * `:star_count` - Number of Telegram Stars that will be paid for the upgrade
  """
  @spec upgrade_gift(binary, binary) :: :ok | {:error, Error.t()}
  @spec upgrade_gift(binary, binary, [{atom, any}] | map) :: :ok | {:error, Error.t()}
  @spec upgrade_gift(Client.t(), binary, binary) :: :ok | {:error, Error.t()}
  @spec upgrade_gift(Client.t(), binary, binary, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  def upgrade_gift(business_connection_id, owned_gift_id) do
    upgrade_gift(business_connection_id, owned_gift_id, [])
  end

  def upgrade_gift(%Client{} = client, business_connection_id, owned_gift_id) do
    upgrade_gift(client, business_connection_id, owned_gift_id, [])
  end

  def upgrade_gift(business_connection_id, owned_gift_id, options) do
    api_request(
      "upgradeGift",
      request_options(
        [business_connection_id: business_connection_id, owned_gift_id: owned_gift_id],
        options
      )
    )
  end

  def upgrade_gift(%Client{} = client, business_connection_id, owned_gift_id, options) do
    api_request(
      client,
      "upgradeGift",
      request_options(
        [business_connection_id: business_connection_id, owned_gift_id: owned_gift_id],
        options
      )
    )
  end

  @doc """
  Use this method to transfer an owned gift to another user.
  Returns `:ok` on success.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  * `owned_gift_id` - Unique identifier of the regular gift that should be transferred
  * `new_owner_chat_id` - Unique identifier of the chat which will own the gift
  * `options` - orddict of options

  Options:
  * `:star_count` - Number of Telegram Stars that will be paid for the transfer
  """
  @spec transfer_gift(binary, binary, integer) :: :ok | {:error, Error.t()}
  @spec transfer_gift(binary, binary, integer, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  @spec transfer_gift(Client.t(), binary, binary, integer) :: :ok | {:error, Error.t()}
  @spec transfer_gift(Client.t(), binary, binary, integer, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  def transfer_gift(business_connection_id, owned_gift_id, new_owner_chat_id) do
    transfer_gift(business_connection_id, owned_gift_id, new_owner_chat_id, [])
  end

  def transfer_gift(%Client{} = client, business_connection_id, owned_gift_id, new_owner_chat_id) do
    transfer_gift(client, business_connection_id, owned_gift_id, new_owner_chat_id, [])
  end

  def transfer_gift(business_connection_id, owned_gift_id, new_owner_chat_id, options) do
    api_request(
      "transferGift",
      request_options(
        [
          business_connection_id: business_connection_id,
          owned_gift_id: owned_gift_id,
          new_owner_chat_id: new_owner_chat_id
        ],
        options
      )
    )
  end

  def transfer_gift(
        %Client{} = client,
        business_connection_id,
        owned_gift_id,
        new_owner_chat_id,
        options
      ) do
    api_request(
      client,
      "transferGift",
      request_options(
        [
          business_connection_id: business_connection_id,
          owned_gift_id: owned_gift_id,
          new_owner_chat_id: new_owner_chat_id
        ],
        options
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

  def set_managed_bot_access_settings(%Client{} = client, user_id, is_access_restricted, options) do
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

  @doc """
  Use this method to send answers to callback queries sent from inline keyboards.
  The answer will be displayed to the user as a notification at the top of the chat
  screen or as an alert. On success, True is returned.

  Args:
  * `callback_query_id` - Unique identifier for the query to be answered
  * `options` - orddict of options

  Options:
  * `:text` - Text of the notification. If not specified, nothing will be shown
  to the user
  * `:show_alert` - If true, an alert will be shown by the client instead of a
  notification at the top of the chat screen. Defaults to false.
  """
  @spec answer_callback_query(binary, [{atom, any}]) :: :ok | {:error, Error.t()}
  @spec answer_callback_query(Client.t(), binary, [{atom, any}]) :: :ok | {:error, Error.t()}
  def answer_callback_query(callback_query_id), do: answer_callback_query(callback_query_id, [])

  def answer_callback_query(%Client{} = client, callback_query_id) do
    answer_callback_query(client, callback_query_id, [])
  end

  def answer_callback_query(callback_query_id, options) do
    api_request("answerCallbackQuery", [callback_query_id: callback_query_id] ++ options)
  end

  def answer_callback_query(%Client{} = client, callback_query_id, options) do
    api_request(client, "answerCallbackQuery", [callback_query_id: callback_query_id] ++ options)
  end

  @doc """
  Use this method to reply to a received guest message.
  On success, a SentGuestMessage object is returned.

  Args:
  * `guest_query_id` - Unique identifier for the query to be answered
  * `result` - An inline query result describing the message to be sent
  * `options` - orddict of options
  """
  @spec answer_guest_query(binary, Nadia.Model.InlineQueryResult.t(), [{atom, any}]) ::
          {:ok, SentGuestMessage.t()} | {:error, Error.t()}
  @spec answer_guest_query(Client.t(), binary, Nadia.Model.InlineQueryResult.t(), [{atom, any}]) ::
          {:ok, SentGuestMessage.t()} | {:error, Error.t()}
  def answer_guest_query(guest_query_id, result),
    do: answer_guest_query(guest_query_id, result, [])

  def answer_guest_query(%Client{} = client, guest_query_id, result) do
    answer_guest_query(client, guest_query_id, result, [])
  end

  def answer_guest_query(guest_query_id, result, options) do
    do_answer_guest_query(nil, guest_query_id, result, options)
  end

  def answer_guest_query(%Client{} = client, guest_query_id, result, options) do
    do_answer_guest_query(client, guest_query_id, result, options)
  end

  @doc """
  Use this method to set the result of an interaction with a Web App.
  On success, a SentWebAppMessage object is returned.

  Args:
  * `web_app_query_id` - Unique identifier for the query to be answered
  * `result` - An inline query result describing the message to be sent
  """
  @spec answer_web_app_query(binary, list | map | struct | binary) ::
          {:ok, SentWebAppMessage.t()} | {:error, Error.t()}
  @spec answer_web_app_query(Client.t(), binary, list | map | struct | binary) ::
          {:ok, SentWebAppMessage.t()} | {:error, Error.t()}
  def answer_web_app_query(web_app_query_id, result) do
    api_request(
      "answerWebAppQuery",
      web_app_query_id: web_app_query_id,
      result: encode_json_payload(result)
    )
  end

  def answer_web_app_query(%Client{} = client, web_app_query_id, result) do
    api_request(
      client,
      "answerWebAppQuery",
      web_app_query_id: web_app_query_id,
      result: encode_json_payload(result)
    )
  end

  @doc """
  Use this method to store a message that can be sent by a user of a Mini App.
  On success, a PreparedInlineMessage object is returned.

  Args:
  * `user_id` - Unique identifier of the target user that can use the prepared message
  * `result` - An inline query result describing the message to be sent
  * `options` - orddict of options
  """
  @spec save_prepared_inline_message(integer, Nadia.Model.InlineQueryResult.t()) ::
          {:ok, PreparedInlineMessage.t()} | {:error, Error.t()}
  @spec save_prepared_inline_message(
          integer,
          Nadia.Model.InlineQueryResult.t(),
          [{atom, any}] | map
        ) ::
          {:ok, PreparedInlineMessage.t()} | {:error, Error.t()}
  @spec save_prepared_inline_message(Client.t(), integer, Nadia.Model.InlineQueryResult.t()) ::
          {:ok, PreparedInlineMessage.t()} | {:error, Error.t()}
  @spec save_prepared_inline_message(
          Client.t(),
          integer,
          Nadia.Model.InlineQueryResult.t(),
          [{atom, any}] | map
        ) ::
          {:ok, PreparedInlineMessage.t()} | {:error, Error.t()}
  def save_prepared_inline_message(user_id, result) do
    save_prepared_inline_message(user_id, result, [])
  end

  def save_prepared_inline_message(%Client{} = client, user_id, result) do
    save_prepared_inline_message(client, user_id, result, [])
  end

  def save_prepared_inline_message(user_id, result, options) do
    do_save_prepared_inline_message(nil, user_id, result, options)
  end

  def save_prepared_inline_message(%Client{} = client, user_id, result, options) do
    do_save_prepared_inline_message(client, user_id, result, options)
  end

  @doc """
  Use this method to store a keyboard button that can be used by a user within a Mini App.
  On success, a PreparedKeyboardButton object is returned.

  Args:
  * `user_id` - Unique identifier of the target user that can use the button
  * `button` - JSON-serializable keyboard button object or a pre-encoded JSON string
  """
  @spec save_prepared_keyboard_button(integer, list | map | struct | binary) ::
          {:ok, PreparedKeyboardButton.t()} | {:error, Error.t()}
  @spec save_prepared_keyboard_button(Client.t(), integer, list | map | struct | binary) ::
          {:ok, PreparedKeyboardButton.t()} | {:error, Error.t()}
  def save_prepared_keyboard_button(user_id, button) do
    api_request(
      "savePreparedKeyboardButton",
      user_id: user_id,
      button: encode_json_payload(button)
    )
  end

  def save_prepared_keyboard_button(%Client{} = client, user_id, button) do
    api_request(
      client,
      "savePreparedKeyboardButton",
      user_id: user_id,
      button: encode_json_payload(button)
    )
  end

  @doc """
  Use this method to edit text messages sent by the bot or via the bot (for inline bots).
  On success, the edited Message is returned

  Args:
  * `chat_id` -	Required if inline_message_id is not specified. Unique identifier
  for the target chat or username of the target channel (in the format @channelusername)
  * `message_id` - Required if inline_message_id is not specified. Unique identifier of
  the sent message
  * `inline_message_id`	- Required if `chat_id` and `message_id` are not specified.
  Identifier of the inline message
  * `text` - New text of the message
  * `options` - orddict of options

  Options:
  * `:parse_mode`	- Send Markdown or HTML, if you want Telegram apps to show bold, italic,
  fixed-width text or inline URLs in your bot's message.
  * `:disable_web_page_preview` -	Disables link previews for links in this message
  * `:reply_markup`	- A JSON-serialized object for an inline
  keyboard - `Nadia.Model.InlineKeyboardMarkup`
  """
  @spec edit_message_text(integer | binary, integer, binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec edit_message_text(Client.t(), integer | binary, integer, binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def edit_message_text(chat_id, message_id, inline_message_id, text) do
    edit_message_text(chat_id, message_id, inline_message_id, text, [])
  end

  def edit_message_text(%Client{} = client, chat_id, message_id, inline_message_id, text) do
    edit_message_text(client, chat_id, message_id, inline_message_id, text, [])
  end

  def edit_message_text(chat_id, message_id, inline_message_id, text, options) do
    api_request(
      "editMessageText",
      [chat_id: chat_id, message_id: message_id, inline_message_id: inline_message_id, text: text] ++
        options
    )
  end

  def edit_message_text(%Client{} = client, chat_id, message_id, inline_message_id, text, options) do
    api_request(
      client,
      "editMessageText",
      [chat_id: chat_id, message_id: message_id, inline_message_id: inline_message_id, text: text] ++
        options
    )
  end

  @doc """
  Use this method to delete message from a chat.
  Bot should have admin permission to do that, and remember you can't delete messages that are more than
  48 hours old.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `message_id` - Required if inline_message_id is not specified. Unique identifier of
  the sent message
  """
  @spec delete_message(integer | binary, integer) :: :ok | {:error, Error.t()}
  @spec delete_message(Client.t(), integer | binary, integer) :: :ok | {:error, Error.t()}
  def delete_message(chat_id, message_id) do
    api_request(
      "deleteMessage",
      chat_id: chat_id,
      message_id: message_id
    )
  end

  def delete_message(%Client{} = client, chat_id, message_id) do
    api_request(
      client,
      "deleteMessage",
      chat_id: chat_id,
      message_id: message_id
    )
  end

  @doc """
  Use this method to delete multiple messages simultaneously.
  Returns True on success.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `message_ids` - List of message identifiers to delete
  """
  @spec delete_messages(integer | binary, [integer]) :: :ok | {:error, Error.t()}
  @spec delete_messages(Client.t(), integer | binary, [integer]) :: :ok | {:error, Error.t()}
  def delete_messages(chat_id, message_ids) do
    api_request(
      "deleteMessages",
      chat_id: chat_id,
      message_ids: encode_message_ids(message_ids)
    )
  end

  def delete_messages(%Client{} = client, chat_id, message_ids) do
    api_request(
      client,
      "deleteMessages",
      chat_id: chat_id,
      message_ids: encode_message_ids(message_ids)
    )
  end

  @doc """
  Use this method to remove a reaction from a message.
  Returns True on success.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target supergroup
  (in the format @username)
  * `message_id` - Identifier of the target message
  * `options` - orddict of options

  Options:
  * `:user_id` - Identifier of the user whose reaction will be removed
  * `:actor_chat_id` - Identifier of the chat whose reaction will be removed
  """
  @spec delete_message_reaction(integer | binary, integer, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  @spec delete_message_reaction(Client.t(), integer | binary, integer, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  def delete_message_reaction(chat_id, message_id),
    do: delete_message_reaction(chat_id, message_id, [])

  def delete_message_reaction(%Client{} = client, chat_id, message_id) do
    delete_message_reaction(client, chat_id, message_id, [])
  end

  def delete_message_reaction(chat_id, message_id, options) do
    api_request(
      "deleteMessageReaction",
      [chat_id: chat_id, message_id: message_id] ++ options
    )
  end

  def delete_message_reaction(%Client{} = client, chat_id, message_id, options) do
    api_request(
      client,
      "deleteMessageReaction",
      [chat_id: chat_id, message_id: message_id] ++ options
    )
  end

  @doc """
  Use this method to remove recent reactions added by a given user or chat.
  Returns True on success.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target supergroup
  (in the format @username)
  * `options` - orddict of options

  Options:
  * `:user_id` - Identifier of the user whose reactions will be removed
  * `:actor_chat_id` - Identifier of the chat whose reactions will be removed
  """
  @spec delete_all_message_reactions(integer | binary, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  @spec delete_all_message_reactions(Client.t(), integer | binary, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  def delete_all_message_reactions(chat_id), do: delete_all_message_reactions(chat_id, [])

  def delete_all_message_reactions(%Client{} = client, chat_id) do
    delete_all_message_reactions(client, chat_id, [])
  end

  def delete_all_message_reactions(chat_id, options) do
    api_request(
      "deleteAllMessageReactions",
      [chat_id: chat_id] ++ options
    )
  end

  def delete_all_message_reactions(%Client{} = client, chat_id, options) do
    api_request(
      client,
      "deleteAllMessageReactions",
      [chat_id: chat_id] ++ options
    )
  end

  @doc """
  Use this method to change the chosen reactions on a message.
  Returns True on success.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `message_id` - Identifier of the target message
  * `options` - orddict of options

  Options:
  * `:reaction` - List of reaction types to set on the message
  * `:is_big` - Pass True to set the reaction with a big animation
  """
  @spec set_message_reaction(integer | binary, integer, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  @spec set_message_reaction(Client.t(), integer | binary, integer, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  def set_message_reaction(chat_id, message_id), do: set_message_reaction(chat_id, message_id, [])

  def set_message_reaction(%Client{} = client, chat_id, message_id) do
    set_message_reaction(client, chat_id, message_id, [])
  end

  def set_message_reaction(chat_id, message_id, options) do
    api_request(
      "setMessageReaction",
      [chat_id: chat_id, message_id: message_id] ++ encode_reaction_option(options)
    )
  end

  def set_message_reaction(%Client{} = client, chat_id, message_id, options) do
    api_request(
      client,
      "setMessageReaction",
      [chat_id: chat_id, message_id: message_id] ++ encode_reaction_option(options)
    )
  end

  @doc """
  Use this method to edit captions of messages sent by the bot or via
  the bot (for inline bots). On success, the edited Message is returned.

  Args:
  * `chat_id` -	Required if inline_message_id is not specified. Unique identifier
  for the target chat or username of the target channel (in the format @channelusername)
  * `message_id` - Required if inline_message_id is not specified. Unique identifier of
  the sent message
  * `inline_message_id`	- Required if `chat_id` and `message_id` are not specified.
  Identifier of the inline message
  * `options` - orddict of options

  Options:
  * `:caption` - New caption of the message
  * `:reply_markup`	- A JSON-serialized object for an inline
  keyboard - `Nadia.Model.InlineKeyboardMarkup`
  """
  @spec edit_message_caption(integer | binary, integer, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec edit_message_caption(Client.t(), integer | binary, integer, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def edit_message_caption(chat_id, message_id, inline_message_id) do
    edit_message_caption(chat_id, message_id, inline_message_id, [])
  end

  def edit_message_caption(%Client{} = client, chat_id, message_id, inline_message_id) do
    edit_message_caption(client, chat_id, message_id, inline_message_id, [])
  end

  def edit_message_caption(chat_id, message_id, inline_message_id, options) do
    api_request(
      "editMessageCaption",
      [chat_id: chat_id, message_id: message_id, inline_message_id: inline_message_id] ++ options
    )
  end

  def edit_message_caption(%Client{} = client, chat_id, message_id, inline_message_id, options) do
    api_request(
      client,
      "editMessageCaption",
      [chat_id: chat_id, message_id: message_id, inline_message_id: inline_message_id] ++ options
    )
  end

  @doc """
  Use this method to edit only the reply markup of messages sent by the bot or via
  the bot (for inline bots). On success, the edited Message is returned.

  Args:
  * `chat_id` -	Required if inline_message_id is not specified. Unique identifier
  for the target chat or username of the target channel (in the format @channelusername)
  * `message_id` - Required if inline_message_id is not specified. Unique identifier of
  the sent message
  * `inline_message_id`	- Required if `chat_id` and `message_id` are not specified.
  Identifier of the inline message
  * `options` - orddict of options

  Options:
  * `:reply_markup`	- A JSON-serialized object for an inline
  keyboard - `Nadia.Model.InlineKeyboardMarkup`
  """
  @spec edit_message_reply_markup(integer | binary, integer, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec edit_message_reply_markup(Client.t(), integer | binary, integer, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def edit_message_reply_markup(chat_id, message_id, inline_message_id) do
    edit_message_reply_markup(chat_id, message_id, inline_message_id, [])
  end

  def edit_message_reply_markup(%Client{} = client, chat_id, message_id, inline_message_id) do
    edit_message_reply_markup(client, chat_id, message_id, inline_message_id, [])
  end

  def edit_message_reply_markup(chat_id, message_id, inline_message_id, options) do
    api_request(
      "editMessageReplyMarkup",
      [chat_id: chat_id, message_id: message_id, inline_message_id: inline_message_id] ++ options
    )
  end

  def edit_message_reply_markup(
        %Client{} = client,
        chat_id,
        message_id,
        inline_message_id,
        options
      ) do
    api_request(
      client,
      "editMessageReplyMarkup",
      [chat_id: chat_id, message_id: message_id, inline_message_id: inline_message_id] ++ options
    )
  end

  @doc """
  Use this method to edit animation, audio, document, live photo, photo, or video
  messages, or to add media to text messages. On success, the edited Message is
  returned, or `:ok` is returned when editing an inline message.

  Args:
  * `media` - JSON-serializable media object or a pre-encoded JSON string
  * `options` - orddict of options
  """
  @spec edit_message_media(list | map | struct | binary, [{atom, any}]) ::
          :ok | {:ok, Message.t()} | {:error, Error.t()}
  @spec edit_message_media(Client.t(), list | map | struct | binary, [{atom, any}]) ::
          :ok | {:ok, Message.t()} | {:error, Error.t()}

  def edit_message_media(media, options) when not is_struct(media, Client) do
    api_request("editMessageMedia", [media: encode_json_payload(media)] ++ options)
  end

  def edit_message_media(%Client{} = client, media, options) do
    api_request(client, "editMessageMedia", [media: encode_json_payload(media)] ++ options)
  end

  @doc """
  Use this method to edit live location messages. On success, the edited Message
  is returned, or `:ok` is returned when editing an inline message.

  Args:
  * `latitude` - Latitude of new location
  * `longitude` - Longitude of new location
  * `options` - orddict of options
  """
  @spec edit_message_live_location(float, float, [{atom, any}]) ::
          :ok | {:ok, Message.t()} | {:error, Error.t()}
  @spec edit_message_live_location(Client.t(), float, float, [{atom, any}]) ::
          :ok | {:ok, Message.t()} | {:error, Error.t()}
  def edit_message_live_location(latitude, longitude, options) do
    api_request("editMessageLiveLocation", [latitude: latitude, longitude: longitude] ++ options)
  end

  def edit_message_live_location(%Client{} = client, latitude, longitude, options) do
    api_request(
      client,
      "editMessageLiveLocation",
      [latitude: latitude, longitude: longitude] ++ options
    )
  end

  @doc """
  Use this method to stop updating a live location message before `live_period`
  expires. On success, the edited Message is returned, or `:ok` is returned
  when editing an inline message.

  Args:
  * `options` - orddict of options
  """
  @spec stop_message_live_location([{atom, any}]) ::
          :ok | {:ok, Message.t()} | {:error, Error.t()}
  @spec stop_message_live_location(Client.t(), [{atom, any}]) ::
          :ok | {:ok, Message.t()} | {:error, Error.t()}
  def stop_message_live_location(options) do
    api_request("stopMessageLiveLocation", options)
  end

  def stop_message_live_location(%Client{} = client, options) do
    api_request(client, "stopMessageLiveLocation", options)
  end

  @doc """
  Use this method to edit a checklist on behalf of a connected business account.
  On success, the edited Message is returned.

  Args:
  * `business_connection_id` - Unique identifier of the business connection
  * `chat_id` - Unique identifier for the target chat or username of the target bot
  * `message_id` - Unique identifier for the target message
  * `checklist` - JSON-serializable checklist object or a pre-encoded JSON string
  * `options` - orddict of options
  """
  @spec edit_message_checklist(binary, integer | binary, integer, list | map | struct | binary) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec edit_message_checklist(binary, integer | binary, integer, list | map | struct | binary, [
          {atom, any}
        ]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec edit_message_checklist(
          Client.t(),
          binary,
          integer | binary,
          integer,
          list | map | struct | binary
        ) ::
          {:ok, Message.t()} | {:error, Error.t()}
  @spec edit_message_checklist(
          Client.t(),
          binary,
          integer | binary,
          integer,
          list | map | struct | binary,
          [{atom, any}]
        ) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def edit_message_checklist(business_connection_id, chat_id, message_id, checklist) do
    edit_message_checklist(business_connection_id, chat_id, message_id, checklist, [])
  end

  def edit_message_checklist(
        %Client{} = client,
        business_connection_id,
        chat_id,
        message_id,
        checklist
      ) do
    edit_message_checklist(client, business_connection_id, chat_id, message_id, checklist, [])
  end

  def edit_message_checklist(business_connection_id, chat_id, message_id, checklist, options) do
    api_request(
      "editMessageChecklist",
      [
        business_connection_id: business_connection_id,
        chat_id: chat_id,
        message_id: message_id,
        checklist: encode_json_payload(checklist)
      ] ++ options
    )
  end

  def edit_message_checklist(
        %Client{} = client,
        business_connection_id,
        chat_id,
        message_id,
        checklist,
        options
      ) do
    api_request(
      client,
      "editMessageChecklist",
      [
        business_connection_id: business_connection_id,
        chat_id: chat_id,
        message_id: message_id,
        checklist: encode_json_payload(checklist)
      ] ++ options
    )
  end

  @doc """
  Use this method to stop a poll which was sent by the bot. On success, the
  stopped Poll is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  * `message_id` - Identifier of the original message with the poll
  * `options` - orddict of options
  """
  @spec stop_poll(integer | binary, integer) :: {:ok, Poll.t()} | {:error, Error.t()}
  @spec stop_poll(integer | binary, integer, [{atom, any}]) ::
          {:ok, Poll.t()} | {:error, Error.t()}
  @spec stop_poll(Client.t(), integer | binary, integer) ::
          {:ok, Poll.t()} | {:error, Error.t()}
  @spec stop_poll(Client.t(), integer | binary, integer, [{atom, any}]) ::
          {:ok, Poll.t()} | {:error, Error.t()}
  def stop_poll(chat_id, message_id), do: stop_poll(chat_id, message_id, [])

  def stop_poll(%Client{} = client, chat_id, message_id) do
    stop_poll(client, chat_id, message_id, [])
  end

  def stop_poll(chat_id, message_id, options) do
    api_request("stopPoll", [chat_id: chat_id, message_id: message_id] ++ options)
  end

  def stop_poll(%Client{} = client, chat_id, message_id, options) do
    api_request(client, "stopPoll", [chat_id: chat_id, message_id: message_id] ++ options)
  end

  @doc """
  Use this method to inform a user that Telegram Passport elements they provided
  contain errors.
  Returns `:ok` on success.

  Args:
  * `user_id` - User identifier
  * `errors` - JSON-serializable list of PassportElementError objects
  """
  @spec set_passport_data_errors(integer, list | map | struct | binary) ::
          :ok | {:error, Error.t()}
  @spec set_passport_data_errors(Client.t(), integer, list | map | struct | binary) ::
          :ok | {:error, Error.t()}
  def set_passport_data_errors(user_id, errors) do
    api_request(
      "setPassportDataErrors",
      user_id: user_id,
      errors: encode_json_array_payload(errors)
    )
  end

  def set_passport_data_errors(%Client{} = client, user_id, errors) do
    api_request(
      client,
      "setPassportDataErrors",
      user_id: user_id,
      errors: encode_json_array_payload(errors)
    )
  end

  @doc """
  Use this method to approve a suggested post in a direct messages chat.
  Returns `:ok` on success.

  Args:
  * `chat_id` - Unique identifier for the target direct messages chat
  * `message_id` - Identifier of a suggested post message to approve
  * `options` - orddict of options
  """
  @spec approve_suggested_post(integer, integer) :: :ok | {:error, Error.t()}
  @spec approve_suggested_post(integer, integer, [{atom, any}]) :: :ok | {:error, Error.t()}
  @spec approve_suggested_post(Client.t(), integer, integer) :: :ok | {:error, Error.t()}
  @spec approve_suggested_post(Client.t(), integer, integer, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  def approve_suggested_post(chat_id, message_id) do
    approve_suggested_post(chat_id, message_id, [])
  end

  def approve_suggested_post(%Client{} = client, chat_id, message_id) do
    approve_suggested_post(client, chat_id, message_id, [])
  end

  def approve_suggested_post(chat_id, message_id, options) do
    api_request("approveSuggestedPost", [chat_id: chat_id, message_id: message_id] ++ options)
  end

  def approve_suggested_post(%Client{} = client, chat_id, message_id, options) do
    api_request(
      client,
      "approveSuggestedPost",
      [chat_id: chat_id, message_id: message_id] ++ options
    )
  end

  @doc """
  Use this method to decline a suggested post in a direct messages chat.
  Returns `:ok` on success.

  Args:
  * `chat_id` - Unique identifier for the target direct messages chat
  * `message_id` - Identifier of a suggested post message to decline
  * `options` - orddict of options
  """
  @spec decline_suggested_post(integer, integer) :: :ok | {:error, Error.t()}
  @spec decline_suggested_post(integer, integer, [{atom, any}]) :: :ok | {:error, Error.t()}
  @spec decline_suggested_post(Client.t(), integer, integer) :: :ok | {:error, Error.t()}
  @spec decline_suggested_post(Client.t(), integer, integer, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  def decline_suggested_post(chat_id, message_id) do
    decline_suggested_post(chat_id, message_id, [])
  end

  def decline_suggested_post(%Client{} = client, chat_id, message_id) do
    decline_suggested_post(client, chat_id, message_id, [])
  end

  def decline_suggested_post(chat_id, message_id, options) do
    api_request("declineSuggestedPost", [chat_id: chat_id, message_id: message_id] ++ options)
  end

  def decline_suggested_post(%Client{} = client, chat_id, message_id, options) do
    api_request(
      client,
      "declineSuggestedPost",
      [chat_id: chat_id, message_id: message_id] ++ options
    )
  end

  @doc """
  Use this method to send answers to an inline query. On success, True is returned.
  No more than 50 results per query are allowed.

  Args:
  * `inline_query_id` - Unique identifier for the answered query
  * `results` - An array of results for the inline query
  * `options` - orddict of options

  Options:
  * `cache_time` - The maximum amount of time in seconds that the result of the inline
  query may be cached on the server. Defaults to 300.
  * `is_personal` - Pass True, if results may be cached on the server side only for
  the user that sent the query. By default, results may be returned to any user who
  sends the same query
  * `next_offset` - Pass the offset that a client should send in the next query with
  the same text to receive more results. Pass an empty string if there are no more
  results or if you don‘t support pagination. Offset length can’t exceed 64 bytes.
  * `switch_pm_text` - If passed, clients will display a button with specified text
  that switches the user to a private chat with the bot and sends the bot a start
  message with the parameter switch_pm_parameter.
  * `switch_pm_parameter` - Parameter for the start message sent to the bot when user
  presses the switch button.
  """
  @spec answer_inline_query(binary, [Nadia.Model.InlineQueryResult.t()], [{atom, any}]) ::
          :ok | {:error, Error.t()}
  @spec answer_inline_query(Client.t(), binary, [Nadia.Model.InlineQueryResult.t()], [
          {atom, any}
        ]) ::
          :ok | {:error, Error.t()}
  def answer_inline_query(inline_query_id, results),
    do: answer_inline_query(inline_query_id, results, [])

  def answer_inline_query(%Client{} = client, inline_query_id, results) do
    answer_inline_query(client, inline_query_id, results, [])
  end

  def answer_inline_query(inline_query_id, results, options) do
    do_answer_inline_query(nil, inline_query_id, results, options)
  end

  def answer_inline_query(%Client{} = client, inline_query_id, results, options) do
    do_answer_inline_query(client, inline_query_id, results, options)
  end

  defp do_answer_guest_query(client, guest_query_id, result, options) do
    args = [guest_query_id: guest_query_id, result: encode_inline_query_result(result)]

    if client do
      api_request(client, "answerGuestQuery", args ++ options)
    else
      api_request("answerGuestQuery", args ++ options)
    end
  end

  defp do_save_prepared_inline_message(client, user_id, result, options) do
    args = [user_id: user_id, result: encode_inline_query_result(result)]

    if client do
      api_request(client, "savePreparedInlineMessage", request_options(args, options))
    else
      api_request("savePreparedInlineMessage", request_options(args, options))
    end
  end

  defp do_answer_inline_query(client, inline_query_id, results, options) do
    encoded_results =
      results
      |> Enum.map(&inline_query_result_map/1)
      |> Jason.encode!()

    args = [inline_query_id: inline_query_id, results: encoded_results]

    if client do
      api_request(client, "answerInlineQuery", args ++ options)
    else
      api_request("answerInlineQuery", args ++ options)
    end
  end

  defp encode_inline_query_result(result) do
    result
    |> inline_query_result_map()
    |> Jason.encode!()
  end

  defp inline_query_result_map(result) do
    for {k, v} <- Map.from_struct(result), v != nil, into: %{}, do: {k, v}
  end

  defp request_options(required, options) when is_list(options), do: required ++ options

  defp request_options(required, options) when is_map(options),
    do: Map.merge(Map.new(required), options)

  defp encode_json_option(options, key) when is_list(options) do
    Keyword.update(options, key, nil, &encode_json_payload/1)
  end

  defp encode_json_option(options, key) when is_map(options) do
    Map.update(options, key, nil, &encode_json_payload/1)
  end

  defp encode_json_array_option(options, key) when is_list(options) do
    Keyword.update(options, key, nil, &encode_json_array_payload/1)
  end

  defp encode_json_array_option(options, key) when is_map(options) do
    Map.update(options, key, nil, &encode_json_array_payload/1)
  end

  defp encode_added_user_ids(options) do
    Keyword.update(options, :added_user_ids, nil, &Jason.encode!/1)
  end

  defp encode_message_ids(message_ids), do: Jason.encode!(message_ids)

  defp encode_reaction_option(options) do
    Keyword.update(options, :reaction, nil, &encode_reaction_types/1)
  end

  defp encode_reaction_types(nil), do: nil

  defp encode_reaction_types(reaction) when is_list(reaction) do
    reaction
    |> normalize_reaction_types()
    |> Jason.encode!()
  end

  defp encode_reaction_types(reaction) do
    [reaction]
    |> normalize_reaction_types()
    |> Jason.encode!()
  end

  defp normalize_reaction_types([]), do: []

  defp normalize_reaction_types(reaction) when is_list(reaction) do
    if Keyword.keyword?(reaction) do
      [reaction_type_map(reaction)]
    else
      Enum.map(reaction, &reaction_type_map/1)
    end
  end

  defp reaction_type_map(reaction) when is_list(reaction) do
    reaction
    |> Map.new()
    |> reject_nil_values()
  end

  defp reaction_type_map(%_{} = reaction) do
    reaction
    |> Map.from_struct()
    |> reject_nil_values()
  end

  defp reaction_type_map(reaction) when is_map(reaction) do
    reject_nil_values(reaction)
  end

  defp reject_nil_values(map) do
    for {key, value} <- map, value != nil, into: %{}, do: {key, value}
  end

  @doc """
  Use this method to get a sticker set. On success, a StickerSet object is returned.

  Args:
  * `name` - Name of the sticker set
  """
  @spec get_sticker_set(binary) :: {:ok, Nadia.Model.StickerSet.t()} | {:error, Error.t()}
  @spec get_sticker_set(Client.t(), binary) ::
          {:ok, Nadia.Model.StickerSet.t()} | {:error, Error.t()}
  def get_sticker_set(name) do
    api_request("getStickerSet", name: name)
  end

  def get_sticker_set(%Client{} = client, name) do
    api_request(client, "getStickerSet", name: name)
  end

  @doc """
  Use this method to get information about custom emoji stickers by their identifiers.
  Returns an array of Sticker objects.

  Args:
  * `custom_emoji_ids` - List of custom emoji identifiers
  """
  @spec get_custom_emoji_stickers([binary] | binary) ::
          {:ok, [Sticker.t()]} | {:error, Error.t()}
  @spec get_custom_emoji_stickers(Client.t(), [binary] | binary) ::
          {:ok, [Sticker.t()]} | {:error, Error.t()}
  def get_custom_emoji_stickers(custom_emoji_ids) do
    api_request(
      "getCustomEmojiStickers",
      custom_emoji_ids: encode_json_array_payload(custom_emoji_ids)
    )
  end

  def get_custom_emoji_stickers(%Client{} = client, custom_emoji_ids) do
    api_request(
      client,
      "getCustomEmojiStickers",
      custom_emoji_ids: encode_json_array_payload(custom_emoji_ids)
    )
  end

  @doc """
  Use this method to upload a .png file with a sticker for later use in
  createNewStickerSet and addStickerToSet methods (can be used multiple times).
  Returns the uploaded File on success.

  Args:
  * `user_id` - User identifier of sticker file owner
  * `png_sticker` - Png image with the sticker, must be up to 512 kilobytes in size,
  dimensions must not exceed 512px, and either width or height must be exactly 512px.
  Either a `file_id` to resend a file that is already on the Telegram servers,
  or a `file_path` to upload a new file from local, or a `HTTP URL` to get a file
  from the internet.
  """
  @spec upload_sticker_file(integer, binary) :: {:ok, File.t()} | {:error, Error.t()}
  @spec upload_sticker_file(Client.t(), integer, binary) :: {:ok, File.t()} | {:error, Error.t()}
  def upload_sticker_file(user_id, png_sticker) do
    api_request("uploadStickerFile", [user_id: user_id, png_sticker: png_sticker], :png_sticker)
  end

  def upload_sticker_file(%Client{} = client, user_id, png_sticker) do
    api_request(
      client,
      "uploadStickerFile",
      [user_id: user_id, png_sticker: png_sticker],
      :png_sticker
    )
  end

  @doc """
  Use this method to create new sticker set owned by a user. The bot will be able to
  edit the created sticker set. Returns True on success.

  Args:
  * `user_id` - User identifier of created sticker set owner
  * `name` - Short name of sticker set, to be used in t.me/addstickers/ URLs (e.g., animals).
  Can contain only english letters, digits and underscores. Must begin with a letter,
  can't contain consecutive underscores and must end in “_by_<bot username>”. <bot_username>
  is case insensitive. 1-64 characters.
  * `title` - Sticker set title, 1-64 characters
  * `png_sticker` - Png image with the sticker, must be up to 512 kilobytes in size,
  dimensions must not exceed 512px, and either width or height must be exactly 512px.
  Either a `file_id` to resend a file that is already on the Telegram servers,
  or a `file_path` to upload a new file from local, or a `HTTP URL` to get a file
  from the internet.
  * `emojis` - One or more emoji corresponding to the sticker

  Options:
  * `contains_masks` - Pass True, if a set of mask stickers should be created
  * `mask_position` - A `Nadia.Model.MaskPosition` object for position where the mask
  should be placed on faces
  """
  @spec create_new_sticker_set(integer, binary, binary, binary, binary, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  @spec create_new_sticker_set(Client.t(), integer, binary, binary, binary, binary, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  def create_new_sticker_set(user_id, name, title, png_sticker, emojis) do
    create_new_sticker_set(user_id, name, title, png_sticker, emojis, [])
  end

  def create_new_sticker_set(%Client{} = client, user_id, name, title, png_sticker, emojis) do
    create_new_sticker_set(client, user_id, name, title, png_sticker, emojis, [])
  end

  def create_new_sticker_set(user_id, name, title, png_sticker, emojis, options) do
    api_request(
      "createNewStickerSet",
      [user_id: user_id, name: name, title: title, png_sticker: png_sticker, emojis: emojis] ++
        options,
      :png_sticker
    )
  end

  def create_new_sticker_set(
        %Client{} = client,
        user_id,
        name,
        title,
        png_sticker,
        emojis,
        options
      ) do
    api_request(
      client,
      "createNewStickerSet",
      [user_id: user_id, name: name, title: title, png_sticker: png_sticker, emojis: emojis] ++
        options,
      :png_sticker
    )
  end

  @doc """
  Use this method to add a new sticker to a set created by the bot. Returns True on success.

  Args:
  * `user_id` - User identifier of created sticker set owner
  * `name` - Sticker set name
  * `png_sticker` - Png image with the sticker, must be up to 512 kilobytes in size,
  dimensions must not exceed 512px, and either width or height must be exactly 512px.
  Either a `file_id` to resend a file that is already on the Telegram servers,
  or a `file_path` to upload a new file from local, or a `HTTP URL` to get a file
  from the internet.
  * `emojis` - One or more emoji corresponding to the sticker

  Options:
  * `mask_position` - A `Nadia.Model.MaskPosition` object for position where the mask
  should be placed on faces
  """
  @spec add_sticker_to_set(integer, binary, binary, binary, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  @spec add_sticker_to_set(Client.t(), integer, binary, binary, binary, [{atom, any}]) ::
          :ok | {:error, Error.t()}
  def add_sticker_to_set(user_id, name, png_sticker, emojis) do
    add_sticker_to_set(user_id, name, png_sticker, emojis, [])
  end

  def add_sticker_to_set(%Client{} = client, user_id, name, png_sticker, emojis) do
    add_sticker_to_set(client, user_id, name, png_sticker, emojis, [])
  end

  def add_sticker_to_set(user_id, name, png_sticker, emojis, options) do
    api_request(
      "addStickerToSet",
      [user_id: user_id, name: name, png_sticker: png_sticker, emojis: emojis] ++ options,
      :png_sticker
    )
  end

  def add_sticker_to_set(%Client{} = client, user_id, name, png_sticker, emojis, options) do
    api_request(
      client,
      "addStickerToSet",
      [user_id: user_id, name: name, png_sticker: png_sticker, emojis: emojis] ++ options,
      :png_sticker
    )
  end

  @doc """
  Use this method to replace an existing sticker in a sticker set with a new one.
  Returns True on success.

  Args:
  * `user_id` - User identifier of the sticker set owner
  * `name` - Sticker set name
  * `old_sticker` - File identifier of the replaced sticker
  * `sticker` - InputSticker object for the new sticker
  """
  @spec replace_sticker_in_set(integer, binary, binary, list | map | struct | binary) ::
          :ok | {:error, Error.t()}
  @spec replace_sticker_in_set(
          Client.t(),
          integer,
          binary,
          binary,
          list | map | struct | binary
        ) ::
          :ok | {:error, Error.t()}
  def replace_sticker_in_set(user_id, name, old_sticker, sticker) do
    api_request(
      "replaceStickerInSet",
      user_id: user_id,
      name: name,
      old_sticker: old_sticker,
      sticker: encode_json_payload(sticker)
    )
  end

  def replace_sticker_in_set(%Client{} = client, user_id, name, old_sticker, sticker) do
    api_request(
      client,
      "replaceStickerInSet",
      user_id: user_id,
      name: name,
      old_sticker: old_sticker,
      sticker: encode_json_payload(sticker)
    )
  end

  @doc """
  Use this method to change the list of emoji assigned to a regular or custom emoji sticker.
  Returns True on success.

  Args:
  * `sticker` - File identifier of the sticker
  * `emoji_list` - List of emoji associated with the sticker
  """
  @spec set_sticker_emoji_list(binary, [binary] | binary) :: :ok | {:error, Error.t()}
  @spec set_sticker_emoji_list(Client.t(), binary, [binary] | binary) ::
          :ok | {:error, Error.t()}
  def set_sticker_emoji_list(sticker, emoji_list) do
    api_request(
      "setStickerEmojiList",
      sticker: sticker,
      emoji_list: encode_json_array_payload(emoji_list)
    )
  end

  def set_sticker_emoji_list(%Client{} = client, sticker, emoji_list) do
    api_request(
      client,
      "setStickerEmojiList",
      sticker: sticker,
      emoji_list: encode_json_array_payload(emoji_list)
    )
  end

  @doc """
  Use this method to change search keywords assigned to a regular or custom emoji sticker.
  Returns True on success.

  Args:
  * `sticker` - File identifier of the sticker

  Options:
  * `keywords` - List of 0-20 search keywords for the sticker
  """
  @spec set_sticker_keywords(binary) :: :ok | {:error, Error.t()}
  @spec set_sticker_keywords(binary, [{atom, any}] | map) :: :ok | {:error, Error.t()}
  @spec set_sticker_keywords(Client.t(), binary) :: :ok | {:error, Error.t()}
  @spec set_sticker_keywords(Client.t(), binary, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  def set_sticker_keywords(sticker), do: set_sticker_keywords(sticker, [])

  def set_sticker_keywords(%Client{} = client, sticker) do
    set_sticker_keywords(client, sticker, [])
  end

  def set_sticker_keywords(sticker, options) do
    api_request(
      "setStickerKeywords",
      request_options([sticker: sticker], encode_json_array_option(options, :keywords))
    )
  end

  def set_sticker_keywords(%Client{} = client, sticker, options) do
    api_request(
      client,
      "setStickerKeywords",
      request_options([sticker: sticker], encode_json_array_option(options, :keywords))
    )
  end

  @doc """
  Use this method to change the mask position of a mask sticker.
  Returns True on success.

  Args:
  * `sticker` - File identifier of the sticker

  Options:
  * `mask_position` - A `Nadia.Model.MaskPosition` object for the sticker
  """
  @spec set_sticker_mask_position(binary) :: :ok | {:error, Error.t()}
  @spec set_sticker_mask_position(binary, [{atom, any}] | map) :: :ok | {:error, Error.t()}
  @spec set_sticker_mask_position(Client.t(), binary) :: :ok | {:error, Error.t()}
  @spec set_sticker_mask_position(Client.t(), binary, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  def set_sticker_mask_position(sticker), do: set_sticker_mask_position(sticker, [])

  def set_sticker_mask_position(%Client{} = client, sticker) do
    set_sticker_mask_position(client, sticker, [])
  end

  def set_sticker_mask_position(sticker, options) do
    api_request(
      "setStickerMaskPosition",
      request_options([sticker: sticker], encode_json_option(options, :mask_position))
    )
  end

  def set_sticker_mask_position(%Client{} = client, sticker, options) do
    api_request(
      client,
      "setStickerMaskPosition",
      request_options([sticker: sticker], encode_json_option(options, :mask_position))
    )
  end

  @doc """
  Use this method to set the title of a created sticker set.
  Returns True on success.

  Args:
  * `name` - Sticker set name
  * `title` - Sticker set title
  """
  @spec set_sticker_set_title(binary, binary) :: :ok | {:error, Error.t()}
  @spec set_sticker_set_title(Client.t(), binary, binary) :: :ok | {:error, Error.t()}
  def set_sticker_set_title(name, title) do
    api_request("setStickerSetTitle", name: name, title: title)
  end

  def set_sticker_set_title(%Client{} = client, name, title) do
    api_request(client, "setStickerSetTitle", name: name, title: title)
  end

  @doc """
  Use this method to set the thumbnail of a regular or mask sticker set.
  Returns True on success.

  Args:
  * `name` - Sticker set name
  * `user_id` - User identifier of the sticker set owner

  Options:
  * `thumbnail` - Sticker set thumbnail as a file identifier, URL, or attach reference
  * `format` - Format of the thumbnail
  """
  @spec set_sticker_set_thumbnail(binary, integer) :: :ok | {:error, Error.t()}
  @spec set_sticker_set_thumbnail(binary, integer, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  @spec set_sticker_set_thumbnail(Client.t(), binary, integer) :: :ok | {:error, Error.t()}
  @spec set_sticker_set_thumbnail(Client.t(), binary, integer, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  def set_sticker_set_thumbnail(name, user_id), do: set_sticker_set_thumbnail(name, user_id, [])

  def set_sticker_set_thumbnail(%Client{} = client, name, user_id) do
    set_sticker_set_thumbnail(client, name, user_id, [])
  end

  def set_sticker_set_thumbnail(name, user_id, options) do
    api_request(
      "setStickerSetThumbnail",
      request_options([name: name, user_id: user_id], options)
    )
  end

  def set_sticker_set_thumbnail(%Client{} = client, name, user_id, options) do
    api_request(
      client,
      "setStickerSetThumbnail",
      request_options([name: name, user_id: user_id], options)
    )
  end

  @doc """
  Use this method to set the thumbnail of a custom emoji sticker set.
  Returns True on success.

  Args:
  * `name` - Sticker set name

  Options:
  * `custom_emoji_id` - Custom emoji identifier to use as thumbnail
  """
  @spec set_custom_emoji_sticker_set_thumbnail(binary) :: :ok | {:error, Error.t()}
  @spec set_custom_emoji_sticker_set_thumbnail(binary, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  @spec set_custom_emoji_sticker_set_thumbnail(Client.t(), binary) ::
          :ok | {:error, Error.t()}
  @spec set_custom_emoji_sticker_set_thumbnail(Client.t(), binary, [{atom, any}] | map) ::
          :ok | {:error, Error.t()}
  def set_custom_emoji_sticker_set_thumbnail(name) do
    set_custom_emoji_sticker_set_thumbnail(name, [])
  end

  def set_custom_emoji_sticker_set_thumbnail(%Client{} = client, name) do
    set_custom_emoji_sticker_set_thumbnail(client, name, [])
  end

  def set_custom_emoji_sticker_set_thumbnail(name, options) do
    api_request(
      "setCustomEmojiStickerSetThumbnail",
      request_options([name: name], options)
    )
  end

  def set_custom_emoji_sticker_set_thumbnail(%Client{} = client, name, options) do
    api_request(
      client,
      "setCustomEmojiStickerSetThumbnail",
      request_options([name: name], options)
    )
  end

  @doc """
  Use this method to move a sticker in a set created by the bot to a specific position.
  Returns True on success.

  Args:
  * `sticker` - File identifier of the sticker
  * `position` - New sticker position in the set, zero-based
  """
  @spec set_sticker_position_in_set(binary, integer) :: :ok | {:error, Error.t()}
  @spec set_sticker_position_in_set(Client.t(), binary, integer) :: :ok | {:error, Error.t()}
  def set_sticker_position_in_set(sticker, position) do
    api_request("setStickerPositionInSet", sticker: sticker, position: position)
  end

  def set_sticker_position_in_set(%Client{} = client, sticker, position) do
    api_request(client, "setStickerPositionInSet", sticker: sticker, position: position)
  end

  @doc """
  Use this method to delete a sticker from a set created by the bot. Returns True on success.

  Args:
  * `sticker` - File identifier of the sticker
  """
  @spec delete_sticker_from_set(binary) :: :ok | {:error, Error.t()}
  @spec delete_sticker_from_set(Client.t(), binary) :: :ok | {:error, Error.t()}
  def delete_sticker_from_set(sticker) do
    api_request("deleteStickerFromSet", sticker: sticker)
  end

  def delete_sticker_from_set(%Client{} = client, sticker) do
    api_request(client, "deleteStickerFromSet", sticker: sticker)
  end

  @doc """
  Use this method to delete a sticker set created by the bot.
  Returns True on success.

  Args:
  * `name` - Sticker set name
  """
  @spec delete_sticker_set(binary) :: :ok | {:error, Error.t()}
  @spec delete_sticker_set(Client.t(), binary) :: :ok | {:error, Error.t()}
  def delete_sticker_set(name) do
    api_request("deleteStickerSet", name: name)
  end

  def delete_sticker_set(%Client{} = client, name) do
    api_request(client, "deleteStickerSet", name: name)
  end

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

  def pin_chat_message(%Client{} = client, chat_id, message_id) do
    pin_chat_message(client, chat_id, message_id, [])
  end

  def pin_chat_message(chat_id, message_id, options) do
    api_request("pinChatMessage", [chat_id: chat_id, message_id: message_id] ++ options)
  end

  def pin_chat_message(%Client{} = client, chat_id, message_id, options) do
    api_request(client, "pinChatMessage", [chat_id: chat_id, message_id: message_id] ++ options)
  end

  @doc """
  Use this method to unpin a message in a group, a supergroup, or a channel. The bot must be an
  administrator in the chat for this to work and must have the ‘can_pin_messages’ admin right in
  the supergroup or ‘can_edit_messages’ admin right in the channel. Returns True on success.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `options` - orddict of options

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

  def unpin_chat_message(%Client{} = client, chat_id) do
    unpin_chat_message(client, chat_id, [])
  end

  def unpin_chat_message(chat_id, options) do
    api_request("unpinChatMessage", [chat_id: chat_id] ++ options)
  end

  def unpin_chat_message(%Client{} = client, chat_id, options) do
    api_request(client, "unpinChatMessage", [chat_id: chat_id] ++ options)
  end
end
