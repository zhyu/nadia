defmodule Nadia.Methods.Stickers do
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
      @spec upload_sticker_file(Client.t(), integer, binary) ::
              {:ok, File.t()} | {:error, Error.t()}
      def upload_sticker_file(user_id, png_sticker) do
        api_request(
          "uploadStickerFile",
          [user_id: user_id, png_sticker: png_sticker],
          :png_sticker
        )
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
      @spec create_new_sticker_set(Client.t(), integer, binary, binary, binary, binary, [
              {atom, any}
            ]) ::
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
      def set_sticker_set_thumbnail(name, user_id),
        do: set_sticker_set_thumbnail(name, user_id, [])

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
    end
  end
end
