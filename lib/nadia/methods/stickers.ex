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

      @doc group: "Stickers"
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

      @doc group: "Stickers"
      def get_sticker_set(%Client{} = client, name) do
        api_request(client, "getStickerSet", name: name)
      end

      @doc group: "Stickers"
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

      @doc group: "Stickers"
      def get_custom_emoji_stickers(%Client{} = client, custom_emoji_ids) do
        api_request(
          client,
          "getCustomEmojiStickers",
          custom_emoji_ids: encode_json_array_payload(custom_emoji_ids)
        )
      end

      @doc group: "Stickers"
      @doc """
      Uploads a sticker file for later use in sticker-set methods.

      Args:
      * `user_id` - User identifier of sticker file owner
      * `sticker` - A new WEBP, PNG, TGS, or WEBM upload
      * `sticker_format` - `"static"`, `"animated"`, or `"video"`

      The historical two-argument form remains as a static-sticker compatibility
      shim. It now sends Telegram's current `sticker` and `sticker_format` fields.
      """
      @spec upload_sticker_file(integer, binary | Nadia.InputFile.t()) ::
              {:ok, File.t()} | {:error, Error.t()}
      @spec upload_sticker_file(integer, binary | Nadia.InputFile.t(), binary) ::
              {:ok, File.t()} | {:error, Error.t()}
      @spec upload_sticker_file(Client.t(), integer, binary | Nadia.InputFile.t()) ::
              {:ok, File.t()} | {:error, Error.t()}
      @spec upload_sticker_file(Client.t(), integer, binary | Nadia.InputFile.t(), binary) ::
              {:ok, File.t()} | {:error, Error.t()}
      def upload_sticker_file(user_id, sticker) do
        upload_sticker_file(user_id, sticker, "static")
      end

      @doc group: "Stickers"
      def upload_sticker_file(%Client{} = client, user_id, sticker) do
        upload_sticker_file(client, user_id, sticker, "static")
      end

      def upload_sticker_file(user_id, sticker, sticker_format) do
        api_request(
          "uploadStickerFile",
          [user_id: user_id, sticker: sticker, sticker_format: sticker_format],
          :sticker
        )
      end

      @doc group: "Stickers"
      def upload_sticker_file(%Client{} = client, user_id, sticker, sticker_format) do
        api_request(
          client,
          "uploadStickerFile",
          [user_id: user_id, sticker: sticker, sticker_format: sticker_format],
          :sticker
        )
      end

      @doc group: "Stickers"
      @doc """
      Creates a sticker set owned by a user.

      Args:
      * `user_id` - User identifier of created sticker set owner
      * `name` - Sticker-set short name
      * `title` - Sticker set title, 1-64 characters
      * `stickers` - A list of 1-50 `Nadia.InputSticker` values, compatible raw
        objects, or pre-encoded JSON

      Options:
      * `sticker_type` - `"regular"`, `"mask"`, or `"custom_emoji"`
      * `needs_repainting` - Repaint custom emoji to the surrounding text color

      Historical PNG-and-emoji arities remain supported. They are translated to
      one static `Nadia.InputSticker`; `contains_masks: true` becomes
      `sticker_type: "mask"`, and `mask_position` moves into that sticker.
      """
      @spec create_new_sticker_set(integer, binary, binary, list | map | binary) ::
              :ok | {:error, Error.t()}
      @spec create_new_sticker_set(
              integer,
              binary,
              binary,
              list | map | binary,
              keyword | map
            ) :: :ok | {:error, Error.t()}
      @spec create_new_sticker_set(integer, binary, binary, binary, binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      @spec create_new_sticker_set(Client.t(), integer, binary, binary, list | map | binary) ::
              :ok | {:error, Error.t()}
      @spec create_new_sticker_set(Client.t(), integer, binary, binary, binary, binary, [
              {atom, any}
            ]) ::
              :ok | {:error, Error.t()}
      def create_new_sticker_set(user_id, name, title, stickers) do
        case Nadia.InputSticker.validate_sticker_set(stickers) do
          :ok ->
            api_request(
              "createNewStickerSet",
              user_id: user_id,
              name: name,
              title: title,
              stickers: encode_json_array_payload(stickers)
            )

          {:error, reason} ->
            {:error, %Error{reason: {:input_sticker, reason}}}
        end
      end

      @doc group: "Stickers"
      def create_new_sticker_set(%Client{} = client, user_id, name, title, stickers) do
        case Nadia.InputSticker.validate_sticker_set(stickers) do
          :ok ->
            api_request(
              client,
              "createNewStickerSet",
              user_id: user_id,
              name: name,
              title: title,
              stickers: encode_json_array_payload(stickers)
            )

          {:error, reason} ->
            {:error, %Error{reason: {:input_sticker, reason}}}
        end
      end

      def create_new_sticker_set(user_id, name, title, stickers_or_png, options_or_emojis) do
        if current_sticker_options?(options_or_emojis) do
          case Nadia.InputSticker.validate_sticker_set(stickers_or_png) do
            :ok ->
              api_request(
                "createNewStickerSet",
                request_options(
                  [
                    user_id: user_id,
                    name: name,
                    title: title,
                    stickers: encode_json_array_payload(stickers_or_png)
                  ],
                  options_or_emojis
                )
              )

            {:error, reason} ->
              {:error, %Error{reason: {:input_sticker, reason}}}
          end
        else
          create_new_sticker_set(user_id, name, title, stickers_or_png, options_or_emojis, [])
        end
      end

      @doc group: "Stickers"
      def create_new_sticker_set(
            %Client{} = client,
            user_id,
            name,
            title,
            stickers_or_png,
            options_or_emojis
          ) do
        if current_sticker_options?(options_or_emojis) do
          case Nadia.InputSticker.validate_sticker_set(stickers_or_png) do
            :ok ->
              api_request(
                client,
                "createNewStickerSet",
                request_options(
                  [
                    user_id: user_id,
                    name: name,
                    title: title,
                    stickers: encode_json_array_payload(stickers_or_png)
                  ],
                  options_or_emojis
                )
              )

            {:error, reason} ->
              {:error, %Error{reason: {:input_sticker, reason}}}
          end
        else
          create_new_sticker_set(
            client,
            user_id,
            name,
            title,
            stickers_or_png,
            options_or_emojis,
            []
          )
        end
      end

      def create_new_sticker_set(user_id, name, title, png_sticker, emojis, options) do
        sticker = legacy_input_sticker(png_sticker, emojis, options)

        api_request(
          "createNewStickerSet",
          request_options(
            [
              user_id: user_id,
              name: name,
              title: title,
              stickers: encode_json_array_payload([sticker])
            ],
            current_sticker_set_options(options)
          )
        )
      end

      @doc group: "Stickers"
      def create_new_sticker_set(
            %Client{} = client,
            user_id,
            name,
            title,
            png_sticker,
            emojis,
            options
          ) do
        sticker = legacy_input_sticker(png_sticker, emojis, options)

        api_request(
          client,
          "createNewStickerSet",
          request_options(
            [
              user_id: user_id,
              name: name,
              title: title,
              stickers: encode_json_array_payload([sticker])
            ],
            current_sticker_set_options(options)
          )
        )
      end

      @doc group: "Stickers"
      @doc """
      Adds one current `Nadia.InputSticker` or compatible raw object to a set.

      Args:
      * `user_id` - User identifier of created sticker set owner
      * `name` - Sticker set name
      * `sticker` - A typed or compatible raw InputSticker object

      Historical PNG-and-emoji arities remain as static-sticker shims.
      """
      @spec add_sticker_to_set(integer, binary, Nadia.InputSticker.t() | list | map | binary) ::
              :ok | {:error, Error.t()}
      @spec add_sticker_to_set(integer, binary, binary, binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      @spec add_sticker_to_set(
              Client.t(),
              integer,
              binary,
              Nadia.InputSticker.t() | list | map | binary
            ) :: :ok | {:error, Error.t()}
      @spec add_sticker_to_set(Client.t(), integer, binary, binary, binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      def add_sticker_to_set(user_id, name, sticker) do
        api_request(
          "addStickerToSet",
          user_id: user_id,
          name: name,
          sticker: encode_json_payload(sticker)
        )
      end

      @doc group: "Stickers"
      def add_sticker_to_set(%Client{} = client, user_id, name, sticker) do
        api_request(
          client,
          "addStickerToSet",
          user_id: user_id,
          name: name,
          sticker: encode_json_payload(sticker)
        )
      end

      def add_sticker_to_set(user_id, name, png_sticker, emojis) do
        add_sticker_to_set(user_id, name, png_sticker, emojis, [])
      end

      @doc group: "Stickers"
      def add_sticker_to_set(%Client{} = client, user_id, name, png_sticker, emojis) do
        add_sticker_to_set(client, user_id, name, png_sticker, emojis, [])
      end

      def add_sticker_to_set(user_id, name, png_sticker, emojis, options) do
        sticker = legacy_input_sticker(png_sticker, emojis, options)

        api_request(
          "addStickerToSet",
          user_id: user_id,
          name: name,
          sticker: encode_json_payload(sticker)
        )
      end

      @doc group: "Stickers"
      def add_sticker_to_set(%Client{} = client, user_id, name, png_sticker, emojis, options) do
        sticker = legacy_input_sticker(png_sticker, emojis, options)

        api_request(
          client,
          "addStickerToSet",
          user_id: user_id,
          name: name,
          sticker: encode_json_payload(sticker)
        )
      end

      @doc group: "Stickers"
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

      @doc group: "Stickers"
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

      @doc group: "Stickers"
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

      @doc group: "Stickers"
      def set_sticker_emoji_list(%Client{} = client, sticker, emoji_list) do
        api_request(
          client,
          "setStickerEmojiList",
          sticker: sticker,
          emoji_list: encode_json_array_payload(emoji_list)
        )
      end

      @doc group: "Stickers"
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

      @doc group: "Stickers"
      def set_sticker_keywords(%Client{} = client, sticker) do
        set_sticker_keywords(client, sticker, [])
      end

      def set_sticker_keywords(sticker, options) do
        api_request(
          "setStickerKeywords",
          request_options([sticker: sticker], encode_json_array_option(options, :keywords))
        )
      end

      @doc group: "Stickers"
      def set_sticker_keywords(%Client{} = client, sticker, options) do
        api_request(
          client,
          "setStickerKeywords",
          request_options([sticker: sticker], encode_json_array_option(options, :keywords))
        )
      end

      @doc group: "Stickers"
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

      @doc group: "Stickers"
      def set_sticker_mask_position(%Client{} = client, sticker) do
        set_sticker_mask_position(client, sticker, [])
      end

      def set_sticker_mask_position(sticker, options) do
        api_request(
          "setStickerMaskPosition",
          request_options([sticker: sticker], encode_json_option(options, :mask_position))
        )
      end

      @doc group: "Stickers"
      def set_sticker_mask_position(%Client{} = client, sticker, options) do
        api_request(
          client,
          "setStickerMaskPosition",
          request_options([sticker: sticker], encode_json_option(options, :mask_position))
        )
      end

      @doc group: "Stickers"
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

      @doc group: "Stickers"
      def set_sticker_set_title(%Client{} = client, name, title) do
        api_request(client, "setStickerSetTitle", name: name, title: title)
      end

      @doc group: "Stickers"
      @doc """
      Use this method to set the thumbnail of a regular or mask sticker set.
      Returns True on success.

      Args:
      * `name` - Sticker set name
      * `user_id` - User identifier of the sticker set owner
      * `format` - `"static"`, `"animated"`, or `"video"`

      Options:
      * `thumbnail` - New thumbnail upload, or `nil` to remove it

      Historical no-format arities remain as static compatibility shims.
      """
      @spec set_sticker_set_thumbnail(binary, integer) :: :ok | {:error, Error.t()}
      @spec set_sticker_set_thumbnail(binary, integer, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      @spec set_sticker_set_thumbnail(Client.t(), binary, integer) :: :ok | {:error, Error.t()}
      @spec set_sticker_set_thumbnail(Client.t(), binary, integer, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      @spec set_sticker_set_thumbnail(binary, integer, binary, [{atom, any}] | map) ::
              :ok | {:error, Error.t()}
      @spec set_sticker_set_thumbnail(
              Client.t(),
              binary,
              integer,
              binary,
              [{atom, any}] | map
            ) :: :ok | {:error, Error.t()}
      def set_sticker_set_thumbnail(name, user_id),
        do: set_sticker_set_thumbnail(name, user_id, "static", [])

      @doc group: "Stickers"
      def set_sticker_set_thumbnail(%Client{} = client, name, user_id) do
        set_sticker_set_thumbnail(client, name, user_id, "static", [])
      end

      def set_sticker_set_thumbnail(name, user_id, format_or_options) do
        if is_binary(format_or_options) do
          set_sticker_set_thumbnail(name, user_id, format_or_options, [])
        else
          format = option_value(format_or_options, :format) || "static"

          set_sticker_set_thumbnail(
            name,
            user_id,
            format,
            delete_option(format_or_options, :format)
          )
        end
      end

      @doc group: "Stickers"
      def set_sticker_set_thumbnail(%Client{} = client, name, user_id, format_or_options) do
        if is_binary(format_or_options) do
          set_sticker_set_thumbnail(client, name, user_id, format_or_options, [])
        else
          format = option_value(format_or_options, :format) || "static"

          set_sticker_set_thumbnail(
            client,
            name,
            user_id,
            format,
            delete_option(format_or_options, :format)
          )
        end
      end

      def set_sticker_set_thumbnail(name, user_id, format, options) do
        api_request(
          "setStickerSetThumbnail",
          request_options([name: name, user_id: user_id, format: format], options)
        )
      end

      @doc group: "Stickers"
      def set_sticker_set_thumbnail(%Client{} = client, name, user_id, format, options) do
        api_request(
          client,
          "setStickerSetThumbnail",
          request_options([name: name, user_id: user_id, format: format], options)
        )
      end

      @doc group: "Stickers"
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

      @doc group: "Stickers"
      def set_custom_emoji_sticker_set_thumbnail(%Client{} = client, name) do
        set_custom_emoji_sticker_set_thumbnail(client, name, [])
      end

      def set_custom_emoji_sticker_set_thumbnail(name, options) do
        api_request(
          "setCustomEmojiStickerSetThumbnail",
          request_options([name: name], options)
        )
      end

      @doc group: "Stickers"
      def set_custom_emoji_sticker_set_thumbnail(%Client{} = client, name, options) do
        api_request(
          client,
          "setCustomEmojiStickerSetThumbnail",
          request_options([name: name], options)
        )
      end

      @doc group: "Stickers"
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

      @doc group: "Stickers"
      def set_sticker_position_in_set(%Client{} = client, sticker, position) do
        api_request(client, "setStickerPositionInSet", sticker: sticker, position: position)
      end

      @doc group: "Stickers"
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

      @doc group: "Stickers"
      def delete_sticker_from_set(%Client{} = client, sticker) do
        api_request(client, "deleteStickerFromSet", sticker: sticker)
      end

      @doc group: "Stickers"
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

      @doc group: "Stickers"
      def delete_sticker_set(%Client{} = client, name) do
        api_request(client, "deleteStickerSet", name: name)
      end
    end
  end
end
