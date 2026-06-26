defmodule Nadia.Methods.Interactions do
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

      @doc group: "Interactions And Editing"
      @doc """
      Use this method to send answers to callback queries sent from inline keyboards.
      The answer will be displayed to the user as a notification at the top of the chat
      screen or as an alert. On success, True is returned.

      Args:
      * `callback_query_id` - Unique identifier for the query to be answered
      * `options` - keyword list of options

      Options:
      * `:text` - Text of the notification. If not specified, nothing will be shown
      to the user
      * `:show_alert` - If true, an alert will be shown by the client instead of a
      notification at the top of the chat screen. Defaults to false.
      """
      @spec answer_callback_query(binary, [{atom, any}]) :: :ok | {:error, Error.t()}
      @spec answer_callback_query(Client.t(), binary, [{atom, any}]) :: :ok | {:error, Error.t()}
      def answer_callback_query(callback_query_id),
        do: answer_callback_query(callback_query_id, [])

      @doc group: "Interactions And Editing"
      def answer_callback_query(%Client{} = client, callback_query_id) do
        answer_callback_query(client, callback_query_id, [])
      end

      def answer_callback_query(callback_query_id, options) do
        api_request("answerCallbackQuery", [callback_query_id: callback_query_id] ++ options)
      end

      @doc group: "Interactions And Editing"
      def answer_callback_query(%Client{} = client, callback_query_id, options) do
        api_request(
          client,
          "answerCallbackQuery",
          [callback_query_id: callback_query_id] ++ options
        )
      end

      @doc group: "Interactions And Editing"
      @doc """
      Use this method to reply to a received guest message.
      On success, a SentGuestMessage object is returned.

      Args:
      * `guest_query_id` - Unique identifier for the query to be answered
      * `result` - An inline query result describing the message to be sent
      * `options` - keyword list of options
      """
      @spec answer_guest_query(binary, Nadia.Model.InlineQueryResult.t(), [{atom, any}]) ::
              {:ok, SentGuestMessage.t()} | {:error, Error.t()}
      @spec answer_guest_query(Client.t(), binary, Nadia.Model.InlineQueryResult.t(), [
              {atom, any}
            ]) ::
              {:ok, SentGuestMessage.t()} | {:error, Error.t()}
      def answer_guest_query(guest_query_id, result),
        do: answer_guest_query(guest_query_id, result, [])

      @doc group: "Interactions And Editing"
      def answer_guest_query(%Client{} = client, guest_query_id, result) do
        answer_guest_query(client, guest_query_id, result, [])
      end

      def answer_guest_query(guest_query_id, result, options) do
        do_answer_guest_query(nil, guest_query_id, result, options)
      end

      @doc group: "Interactions And Editing"
      def answer_guest_query(%Client{} = client, guest_query_id, result, options) do
        do_answer_guest_query(client, guest_query_id, result, options)
      end

      @doc group: "Interactions And Editing"
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

      @doc group: "Interactions And Editing"
      def answer_web_app_query(%Client{} = client, web_app_query_id, result) do
        api_request(
          client,
          "answerWebAppQuery",
          web_app_query_id: web_app_query_id,
          result: encode_json_payload(result)
        )
      end

      @doc group: "Interactions And Editing"
      @doc """
      Use this method to store a message that can be sent by a user of a Mini App.
      On success, a PreparedInlineMessage object is returned.

      Args:
      * `user_id` - Unique identifier of the target user that can use the prepared message
      * `result` - An inline query result describing the message to be sent
      * `options` - keyword list of options
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

      @doc group: "Interactions And Editing"
      def save_prepared_inline_message(%Client{} = client, user_id, result) do
        save_prepared_inline_message(client, user_id, result, [])
      end

      def save_prepared_inline_message(user_id, result, options) do
        do_save_prepared_inline_message(nil, user_id, result, options)
      end

      @doc group: "Interactions And Editing"
      def save_prepared_inline_message(%Client{} = client, user_id, result, options) do
        do_save_prepared_inline_message(client, user_id, result, options)
      end

      @doc group: "Interactions And Editing"
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

      @doc group: "Interactions And Editing"
      def save_prepared_keyboard_button(%Client{} = client, user_id, button) do
        api_request(
          client,
          "savePreparedKeyboardButton",
          user_id: user_id,
          button: encode_json_payload(button)
        )
      end

      @doc group: "Interactions And Editing"
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
      * `options` - keyword list of options

      Options:
      * `:parse_mode`	- Send Markdown or HTML, if you want Telegram apps to show bold, italic,
      fixed-width text or inline URLs in your bot's message.
      * `:disable_web_page_preview` -	Disables link previews for links in this message
      * `:reply_markup`	- A JSON-serialized object for an inline
      keyboard - `Nadia.Model.InlineKeyboardMarkup`
      """
      @spec edit_message_text(
              integer | binary | nil,
              integer | nil,
              binary | nil,
              binary | nil,
              [{atom, any}] | map
            ) ::
              :ok | {:ok, Message.t()} | {:error, Error.t()}
      @spec edit_message_text(
              Client.t(),
              integer | binary | nil,
              integer | nil,
              binary | nil,
              binary | nil,
              [{atom, any}] | map
            ) ::
              :ok | {:ok, Message.t()} | {:error, Error.t()}
      def edit_message_text(chat_id, message_id, inline_message_id, text) do
        edit_message_text(chat_id, message_id, inline_message_id, text, [])
      end

      @doc group: "Interactions And Editing"
      def edit_message_text(%Client{} = client, chat_id, message_id, inline_message_id, text) do
        edit_message_text(client, chat_id, message_id, inline_message_id, text, [])
      end

      def edit_message_text(chat_id, message_id, inline_message_id, text, options) do
        case validate_rich_message(option_value(options, :rich_message), :edit) do
          :ok ->
            api_request(
              "editMessageText",
              request_options(
                [
                  chat_id: chat_id,
                  message_id: message_id,
                  inline_message_id: inline_message_id,
                  text: text
                ],
                encode_json_option(options, :rich_message)
              )
            )

          {:error, reason} ->
            {:error, %Error{reason: reason}}
        end
      end

      @doc group: "Interactions And Editing"
      def edit_message_text(
            %Client{} = client,
            chat_id,
            message_id,
            inline_message_id,
            text,
            options
          ) do
        case validate_rich_message(option_value(options, :rich_message), :edit) do
          :ok ->
            api_request(
              client,
              "editMessageText",
              request_options(
                [
                  chat_id: chat_id,
                  message_id: message_id,
                  inline_message_id: inline_message_id,
                  text: text
                ],
                encode_json_option(options, :rich_message)
              )
            )

          {:error, reason} ->
            {:error, %Error{reason: reason}}
        end
      end

      @doc group: "Interactions And Editing"
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

      @doc group: "Interactions And Editing"
      def delete_message(%Client{} = client, chat_id, message_id) do
        api_request(
          client,
          "deleteMessage",
          chat_id: chat_id,
          message_id: message_id
        )
      end

      @doc group: "Interactions And Editing"
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

      @doc group: "Interactions And Editing"
      def delete_messages(%Client{} = client, chat_id, message_ids) do
        api_request(
          client,
          "deleteMessages",
          chat_id: chat_id,
          message_ids: encode_message_ids(message_ids)
        )
      end

      @doc group: "Interactions And Editing"
      @doc """
      Use this method to remove a reaction from a message.
      Returns True on success.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target supergroup
      (in the format @username)
      * `message_id` - Identifier of the target message
      * `options` - keyword list of options

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

      @doc group: "Interactions And Editing"
      def delete_message_reaction(%Client{} = client, chat_id, message_id) do
        delete_message_reaction(client, chat_id, message_id, [])
      end

      def delete_message_reaction(chat_id, message_id, options) do
        api_request(
          "deleteMessageReaction",
          [chat_id: chat_id, message_id: message_id] ++ options
        )
      end

      @doc group: "Interactions And Editing"
      def delete_message_reaction(%Client{} = client, chat_id, message_id, options) do
        api_request(
          client,
          "deleteMessageReaction",
          [chat_id: chat_id, message_id: message_id] ++ options
        )
      end

      @doc group: "Interactions And Editing"
      @doc """
      Use this method to remove recent reactions added by a given user or chat.
      Returns True on success.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target supergroup
      (in the format @username)
      * `options` - keyword list of options

      Options:
      * `:user_id` - Identifier of the user whose reactions will be removed
      * `:actor_chat_id` - Identifier of the chat whose reactions will be removed
      """
      @spec delete_all_message_reactions(integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      @spec delete_all_message_reactions(Client.t(), integer | binary, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      def delete_all_message_reactions(chat_id), do: delete_all_message_reactions(chat_id, [])

      @doc group: "Interactions And Editing"
      def delete_all_message_reactions(%Client{} = client, chat_id) do
        delete_all_message_reactions(client, chat_id, [])
      end

      def delete_all_message_reactions(chat_id, options) do
        api_request(
          "deleteAllMessageReactions",
          [chat_id: chat_id] ++ options
        )
      end

      @doc group: "Interactions And Editing"
      def delete_all_message_reactions(%Client{} = client, chat_id, options) do
        api_request(
          client,
          "deleteAllMessageReactions",
          [chat_id: chat_id] ++ options
        )
      end

      @doc group: "Interactions And Editing"
      @doc """
      Use this method to change the chosen reactions on a message.
      Returns True on success.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `message_id` - Identifier of the target message
      * `options` - keyword list of options

      Options:
      * `:reaction` - List of reaction types to set on the message
      * `:is_big` - Pass True to set the reaction with a big animation
      """
      @spec set_message_reaction(integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      @spec set_message_reaction(Client.t(), integer | binary, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      def set_message_reaction(chat_id, message_id),
        do: set_message_reaction(chat_id, message_id, [])

      @doc group: "Interactions And Editing"
      def set_message_reaction(%Client{} = client, chat_id, message_id) do
        set_message_reaction(client, chat_id, message_id, [])
      end

      def set_message_reaction(chat_id, message_id, options) do
        api_request(
          "setMessageReaction",
          [chat_id: chat_id, message_id: message_id] ++ encode_reaction_option(options)
        )
      end

      @doc group: "Interactions And Editing"
      def set_message_reaction(%Client{} = client, chat_id, message_id, options) do
        api_request(
          client,
          "setMessageReaction",
          [chat_id: chat_id, message_id: message_id] ++ encode_reaction_option(options)
        )
      end

      @doc group: "Interactions And Editing"
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
      * `options` - keyword list of options

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

      @doc group: "Interactions And Editing"
      def edit_message_caption(%Client{} = client, chat_id, message_id, inline_message_id) do
        edit_message_caption(client, chat_id, message_id, inline_message_id, [])
      end

      def edit_message_caption(chat_id, message_id, inline_message_id, options) do
        api_request(
          "editMessageCaption",
          [chat_id: chat_id, message_id: message_id, inline_message_id: inline_message_id] ++
            options
        )
      end

      @doc group: "Interactions And Editing"
      def edit_message_caption(
            %Client{} = client,
            chat_id,
            message_id,
            inline_message_id,
            options
          ) do
        api_request(
          client,
          "editMessageCaption",
          [chat_id: chat_id, message_id: message_id, inline_message_id: inline_message_id] ++
            options
        )
      end

      @doc group: "Interactions And Editing"
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
      * `options` - keyword list of options

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

      @doc group: "Interactions And Editing"
      def edit_message_reply_markup(%Client{} = client, chat_id, message_id, inline_message_id) do
        edit_message_reply_markup(client, chat_id, message_id, inline_message_id, [])
      end

      def edit_message_reply_markup(chat_id, message_id, inline_message_id, options) do
        api_request(
          "editMessageReplyMarkup",
          [chat_id: chat_id, message_id: message_id, inline_message_id: inline_message_id] ++
            options
        )
      end

      @doc group: "Interactions And Editing"
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
          [chat_id: chat_id, message_id: message_id, inline_message_id: inline_message_id] ++
            options
        )
      end

      @doc group: "Interactions And Editing"
      @doc """
      Use this method to edit animation, audio, document, live photo, photo, or video
      messages, or to add media to text messages. On success, the edited Message is
      returned, or `:ok` is returned when editing an inline message.

      Args:
      * `media` - `Nadia.InputMedia` value, compatible JSON-serializable object,
        or pre-encoded JSON
      * `options` - keyword list of options

      Inline messages cannot upload new files; use file IDs or supported URLs.
      Album messages retain Telegram's audio-only, document-only, or visual
      media-family replacement restrictions.
      """
      @spec edit_message_media(list | map | struct | binary, [{atom, any}]) ::
              :ok | {:ok, Message.t()} | {:error, Error.t()}
      @spec edit_message_media(Client.t(), list | map | struct | binary, [{atom, any}]) ::
              :ok | {:ok, Message.t()} | {:error, Error.t()}

      def edit_message_media(media, options) when not is_struct(media, Client) do
        api_request("editMessageMedia", [media: encode_json_payload(media)] ++ options)
      end

      @doc group: "Interactions And Editing"
      def edit_message_media(%Client{} = client, media, options) do
        api_request(client, "editMessageMedia", [media: encode_json_payload(media)] ++ options)
      end

      @doc group: "Interactions And Editing"
      @doc """
      Use this method to edit live location messages. On success, the edited Message
      is returned, or `:ok` is returned when editing an inline message.

      Args:
      * `latitude` - Latitude of new location
      * `longitude` - Longitude of new location
      * `options` - keyword list of options
      """
      @spec edit_message_live_location(float, float, [{atom, any}]) ::
              :ok | {:ok, Message.t()} | {:error, Error.t()}
      @spec edit_message_live_location(Client.t(), float, float, [{atom, any}]) ::
              :ok | {:ok, Message.t()} | {:error, Error.t()}
      def edit_message_live_location(latitude, longitude, options) do
        api_request(
          "editMessageLiveLocation",
          [latitude: latitude, longitude: longitude] ++ options
        )
      end

      @doc group: "Interactions And Editing"
      def edit_message_live_location(%Client{} = client, latitude, longitude, options) do
        api_request(
          client,
          "editMessageLiveLocation",
          [latitude: latitude, longitude: longitude] ++ options
        )
      end

      @doc group: "Interactions And Editing"
      @doc """
      Use this method to stop updating a live location message before `live_period`
      expires. On success, the edited Message is returned, or `:ok` is returned
      when editing an inline message.

      Args:
      * `options` - keyword list of options
      """
      @spec stop_message_live_location([{atom, any}]) ::
              :ok | {:ok, Message.t()} | {:error, Error.t()}
      @spec stop_message_live_location(Client.t(), [{atom, any}]) ::
              :ok | {:ok, Message.t()} | {:error, Error.t()}
      def stop_message_live_location(options) do
        api_request("stopMessageLiveLocation", options)
      end

      @doc group: "Interactions And Editing"
      def stop_message_live_location(%Client{} = client, options) do
        api_request(client, "stopMessageLiveLocation", options)
      end

      @doc group: "Interactions And Editing"
      @doc """
      Use this method to edit a checklist on behalf of a connected business account.
      On success, the edited Message is returned.

      Args:
      * `business_connection_id` - Unique identifier of the business connection
      * `chat_id` - Unique identifier for the target chat or username of the target bot
      * `message_id` - Unique identifier for the target message
      * `checklist` - JSON-serializable checklist object or a pre-encoded JSON string
      * `options` - keyword list of options
      """
      @spec edit_message_checklist(
              binary,
              integer | binary,
              integer,
              list | map | struct | binary
            ) ::
              {:ok, Message.t()} | {:error, Error.t()}
      @spec edit_message_checklist(
              binary,
              integer | binary,
              integer,
              list | map | struct | binary,
              [
                {atom, any}
              ]
            ) ::
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

      @doc group: "Interactions And Editing"
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

      @doc group: "Interactions And Editing"
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

      @doc group: "Interactions And Editing"
      @doc """
      Use this method to stop a poll which was sent by the bot. On success, the
      stopped Poll is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      * `message_id` - Identifier of the original message with the poll
      * `options` - keyword list of options
      """
      @spec stop_poll(integer | binary, integer) :: {:ok, Poll.t()} | {:error, Error.t()}
      @spec stop_poll(integer | binary, integer, [{atom, any}]) ::
              {:ok, Poll.t()} | {:error, Error.t()}
      @spec stop_poll(Client.t(), integer | binary, integer) ::
              {:ok, Poll.t()} | {:error, Error.t()}
      @spec stop_poll(Client.t(), integer | binary, integer, [{atom, any}]) ::
              {:ok, Poll.t()} | {:error, Error.t()}
      def stop_poll(chat_id, message_id), do: stop_poll(chat_id, message_id, [])

      @doc group: "Interactions And Editing"
      def stop_poll(%Client{} = client, chat_id, message_id) do
        stop_poll(client, chat_id, message_id, [])
      end

      def stop_poll(chat_id, message_id, options) do
        api_request("stopPoll", [chat_id: chat_id, message_id: message_id] ++ options)
      end

      @doc group: "Interactions And Editing"
      def stop_poll(%Client{} = client, chat_id, message_id, options) do
        api_request(client, "stopPoll", [chat_id: chat_id, message_id: message_id] ++ options)
      end

      @doc group: "Interactions And Editing"
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

      @doc group: "Interactions And Editing"
      def set_passport_data_errors(%Client{} = client, user_id, errors) do
        api_request(
          client,
          "setPassportDataErrors",
          user_id: user_id,
          errors: encode_json_array_payload(errors)
        )
      end

      @doc group: "Interactions And Editing"
      @doc """
      Use this method to approve a suggested post in a direct messages chat.
      Returns `:ok` on success.

      Args:
      * `chat_id` - Unique identifier for the target direct messages chat
      * `message_id` - Identifier of a suggested post message to approve
      * `options` - keyword list of options
      """
      @spec approve_suggested_post(integer, integer) :: :ok | {:error, Error.t()}
      @spec approve_suggested_post(integer, integer, [{atom, any}]) :: :ok | {:error, Error.t()}
      @spec approve_suggested_post(Client.t(), integer, integer) :: :ok | {:error, Error.t()}
      @spec approve_suggested_post(Client.t(), integer, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      def approve_suggested_post(chat_id, message_id) do
        approve_suggested_post(chat_id, message_id, [])
      end

      @doc group: "Interactions And Editing"
      def approve_suggested_post(%Client{} = client, chat_id, message_id) do
        approve_suggested_post(client, chat_id, message_id, [])
      end

      def approve_suggested_post(chat_id, message_id, options) do
        api_request("approveSuggestedPost", [chat_id: chat_id, message_id: message_id] ++ options)
      end

      @doc group: "Interactions And Editing"
      def approve_suggested_post(%Client{} = client, chat_id, message_id, options) do
        api_request(
          client,
          "approveSuggestedPost",
          [chat_id: chat_id, message_id: message_id] ++ options
        )
      end

      @doc group: "Interactions And Editing"
      @doc """
      Use this method to decline a suggested post in a direct messages chat.
      Returns `:ok` on success.

      Args:
      * `chat_id` - Unique identifier for the target direct messages chat
      * `message_id` - Identifier of a suggested post message to decline
      * `options` - keyword list of options
      """
      @spec decline_suggested_post(integer, integer) :: :ok | {:error, Error.t()}
      @spec decline_suggested_post(integer, integer, [{atom, any}]) :: :ok | {:error, Error.t()}
      @spec decline_suggested_post(Client.t(), integer, integer) :: :ok | {:error, Error.t()}
      @spec decline_suggested_post(Client.t(), integer, integer, [{atom, any}]) ::
              :ok | {:error, Error.t()}
      def decline_suggested_post(chat_id, message_id) do
        decline_suggested_post(chat_id, message_id, [])
      end

      @doc group: "Interactions And Editing"
      def decline_suggested_post(%Client{} = client, chat_id, message_id) do
        decline_suggested_post(client, chat_id, message_id, [])
      end

      def decline_suggested_post(chat_id, message_id, options) do
        api_request("declineSuggestedPost", [chat_id: chat_id, message_id: message_id] ++ options)
      end

      @doc group: "Interactions And Editing"
      def decline_suggested_post(%Client{} = client, chat_id, message_id, options) do
        api_request(
          client,
          "declineSuggestedPost",
          [chat_id: chat_id, message_id: message_id] ++ options
        )
      end

      @doc group: "Interactions And Editing"
      @doc """
      Use this method to send answers to an inline query. On success, True is returned.
      No more than 50 results per query are allowed.

      Args:
      * `inline_query_id` - Unique identifier for the answered query
      * `results` - An array of results for the inline query
      * `options` - keyword list of options

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

      @doc group: "Interactions And Editing"
      def answer_inline_query(%Client{} = client, inline_query_id, results) do
        answer_inline_query(client, inline_query_id, results, [])
      end

      def answer_inline_query(inline_query_id, results, options) do
        do_answer_inline_query(nil, inline_query_id, results, options)
      end

      @doc group: "Interactions And Editing"
      def answer_inline_query(%Client{} = client, inline_query_id, results, options) do
        do_answer_inline_query(client, inline_query_id, results, options)
      end
    end
  end
end
