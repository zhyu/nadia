defmodule Nadia.Methods.Business do
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
        api_request(client, "getBusinessConnection",
          business_connection_id: business_connection_id
        )
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
        api_request("getBusinessAccountStarBalance",
          business_connection_id: business_connection_id
        )
      end

      def get_business_account_star_balance(%Client{} = client, business_connection_id) do
        api_request(
          client,
          "getBusinessAccountStarBalance",
          business_connection_id: business_connection_id
        )
      end

      @doc """
      Use this method to get gifts received and owned by a managed business account.
      Returns a `Nadia.Model.OwnedGifts` object on success.

      Args:
      * `business_connection_id` - Unique identifier of the business connection
      * `options` - orddict or map of options
      """
      @spec get_business_account_gifts(binary) :: {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @spec get_business_account_gifts(binary, [{atom, any}] | map) ::
              {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @spec get_business_account_gifts(Client.t(), binary) ::
              {:ok, OwnedGifts.t()} | {:error, Error.t()}
      @spec get_business_account_gifts(Client.t(), binary, [{atom, any}] | map) ::
              {:ok, OwnedGifts.t()} | {:error, Error.t()}
      def get_business_account_gifts(business_connection_id) do
        get_business_account_gifts(business_connection_id, [])
      end

      def get_business_account_gifts(%Client{} = client, business_connection_id) do
        get_business_account_gifts(client, business_connection_id, [])
      end

      def get_business_account_gifts(business_connection_id, options) do
        api_request(
          "getBusinessAccountGifts",
          request_options([business_connection_id: business_connection_id], options)
        )
      end

      def get_business_account_gifts(%Client{} = client, business_connection_id, options) do
        api_request(
          client,
          "getBusinessAccountGifts",
          request_options([business_connection_id: business_connection_id], options)
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

      def set_business_account_name(
            %Client{} = client,
            business_connection_id,
            first_name,
            options
          ) do
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
      @spec set_business_account_username(binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
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

      def remove_business_account_profile_photo(
            %Client{} = client,
            business_connection_id,
            options
          ) do
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
      @spec transfer_business_account_stars(Client.t(), binary, integer) ::
              :ok | {:error, Error.t()}
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

      def transfer_gift(
            %Client{} = client,
            business_connection_id,
            owned_gift_id,
            new_owner_chat_id
          ) do
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
      Use this method to post a story on behalf of a managed business account.
      Returns a Story object.

      Args:
      * `business_connection_id` - Unique identifier of the business connection
      * `content` - JSON-serializable story content object or a pre-encoded JSON string
      * `active_period` - Period after which the story is moved to the archive, in seconds
      * `options` - orddict or map of options

      Options:
      * `:caption` - Caption of the story
      * `:parse_mode` - Mode for parsing entities in the story caption
      * `:caption_entities` - JSON-serializable caption entities array or a pre-encoded JSON string
      * `:areas` - JSON-serializable story areas array or a pre-encoded JSON string
      * `:post_to_chat_page` - Pass true to keep the story accessible after it expires
      * `:protect_content` - Pass true if the content of the story must be protected
      """
      @spec post_story(binary, list | map | struct | binary, integer) ::
              {:ok, Story.t()} | {:error, Error.t()}
      @spec post_story(binary, list | map | struct | binary, integer, [{atom, any}] | map) ::
              {:ok, Story.t()} | {:error, Error.t()}
      @spec post_story(Client.t(), binary, list | map | struct | binary, integer) ::
              {:ok, Story.t()} | {:error, Error.t()}
      @spec post_story(
              Client.t(),
              binary,
              list | map | struct | binary,
              integer,
              [{atom, any}] | map
            ) :: {:ok, Story.t()} | {:error, Error.t()}
      def post_story(business_connection_id, content, active_period) do
        post_story(business_connection_id, content, active_period, [])
      end

      def post_story(%Client{} = client, business_connection_id, content, active_period) do
        post_story(client, business_connection_id, content, active_period, [])
      end

      def post_story(business_connection_id, content, active_period, options) do
        api_request(
          "postStory",
          request_options(
            [
              business_connection_id: business_connection_id,
              content: encode_json_payload(content),
              active_period: active_period
            ],
            encode_story_options(options)
          )
        )
      end

      def post_story(%Client{} = client, business_connection_id, content, active_period, options) do
        api_request(
          client,
          "postStory",
          request_options(
            [
              business_connection_id: business_connection_id,
              content: encode_json_payload(content),
              active_period: active_period
            ],
            encode_story_options(options)
          )
        )
      end

      @doc """
      Use this method to edit a story previously posted by the bot on behalf of a managed business account.
      Returns a Story object.

      Args:
      * `business_connection_id` - Unique identifier of the business connection
      * `story_id` - Unique identifier of the story to edit
      * `content` - JSON-serializable story content object or a pre-encoded JSON string
      * `options` - orddict or map of options

      Options:
      * `:caption` - Caption of the story
      * `:parse_mode` - Mode for parsing entities in the story caption
      * `:caption_entities` - JSON-serializable caption entities array or a pre-encoded JSON string
      * `:areas` - JSON-serializable story areas array or a pre-encoded JSON string
      """
      @spec edit_story(binary, integer, list | map | struct | binary) ::
              {:ok, Story.t()} | {:error, Error.t()}
      @spec edit_story(binary, integer, list | map | struct | binary, [{atom, any}] | map) ::
              {:ok, Story.t()} | {:error, Error.t()}
      @spec edit_story(Client.t(), binary, integer, list | map | struct | binary) ::
              {:ok, Story.t()} | {:error, Error.t()}
      @spec edit_story(
              Client.t(),
              binary,
              integer,
              list | map | struct | binary,
              [{atom, any}] | map
            ) :: {:ok, Story.t()} | {:error, Error.t()}
      def edit_story(business_connection_id, story_id, content) do
        edit_story(business_connection_id, story_id, content, [])
      end

      def edit_story(%Client{} = client, business_connection_id, story_id, content) do
        edit_story(client, business_connection_id, story_id, content, [])
      end

      def edit_story(business_connection_id, story_id, content, options) do
        api_request(
          "editStory",
          request_options(
            [
              business_connection_id: business_connection_id,
              story_id: story_id,
              content: encode_json_payload(content)
            ],
            encode_story_options(options)
          )
        )
      end

      def edit_story(%Client{} = client, business_connection_id, story_id, content, options) do
        api_request(
          client,
          "editStory",
          request_options(
            [
              business_connection_id: business_connection_id,
              story_id: story_id,
              content: encode_json_payload(content)
            ],
            encode_story_options(options)
          )
        )
      end

      @doc """
      Use this method to delete a story previously posted by the bot on behalf of a managed business account.
      Returns `:ok` on success.

      Args:
      * `business_connection_id` - Unique identifier of the business connection
      * `story_id` - Unique identifier of the story to delete
      """
      @spec delete_story(binary, integer) :: :ok | {:error, Error.t()}
      @spec delete_story(Client.t(), binary, integer) :: :ok | {:error, Error.t()}
      def delete_story(business_connection_id, story_id) do
        api_request("deleteStory",
          business_connection_id: business_connection_id,
          story_id: story_id
        )
      end

      def delete_story(%Client{} = client, business_connection_id, story_id) do
        api_request(
          client,
          "deleteStory",
          business_connection_id: business_connection_id,
          story_id: story_id
        )
      end

      @doc """
      Use this method to repost a story on behalf of a managed business account.
      Returns a Story object.

      Args:
      * `business_connection_id` - Unique identifier of the business connection
      * `from_chat_id` - Unique identifier of the chat which posted the story
      * `from_story_id` - Unique identifier of the story that should be reposted
      * `active_period` - Period after which the story is moved to the archive, in seconds
      * `options` - orddict or map of options

      Options:
      * `:post_to_chat_page` - Pass true to keep the story accessible after it expires
      * `:protect_content` - Pass true if the content of the story must be protected
      """
      @spec repost_story(binary, integer, integer, integer) ::
              {:ok, Story.t()} | {:error, Error.t()}
      @spec repost_story(binary, integer, integer, integer, [{atom, any}] | map) ::
              {:ok, Story.t()} | {:error, Error.t()}
      @spec repost_story(Client.t(), binary, integer, integer, integer) ::
              {:ok, Story.t()} | {:error, Error.t()}
      @spec repost_story(Client.t(), binary, integer, integer, integer, [{atom, any}] | map) ::
              {:ok, Story.t()} | {:error, Error.t()}
      def repost_story(business_connection_id, from_chat_id, from_story_id, active_period) do
        repost_story(business_connection_id, from_chat_id, from_story_id, active_period, [])
      end

      def repost_story(
            %Client{} = client,
            business_connection_id,
            from_chat_id,
            from_story_id,
            active_period
          ) do
        repost_story(
          client,
          business_connection_id,
          from_chat_id,
          from_story_id,
          active_period,
          []
        )
      end

      def repost_story(
            business_connection_id,
            from_chat_id,
            from_story_id,
            active_period,
            options
          ) do
        api_request(
          "repostStory",
          request_options(
            [
              business_connection_id: business_connection_id,
              from_chat_id: from_chat_id,
              from_story_id: from_story_id,
              active_period: active_period
            ],
            options
          )
        )
      end

      def repost_story(
            %Client{} = client,
            business_connection_id,
            from_chat_id,
            from_story_id,
            active_period,
            options
          ) do
        api_request(
          client,
          "repostStory",
          request_options(
            [
              business_connection_id: business_connection_id,
              from_chat_id: from_chat_id,
              from_story_id: from_story_id,
              active_period: active_period
            ],
            options
          )
        )
      end
    end
  end
end
