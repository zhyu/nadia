defmodule Nadia.Methods.Messages do
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

      @doc group: "Messages"
      @doc """
      Use this method to send text messages.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `text` - Text of the message to be sent
      * `options` - keyword list of options

      Options:
      * `:parse_mode` or `:entities` - Formatting for the message text
      * `:link_preview_options` - Link preview generation options
      * `:disable_notification` - Sends the message silently or without notification
      * `:protect_content` - Protects the message from forwarding and saving
      * `:reply_parameters` - Description of the message to reply to
      * `:reply_markup` - Additional interface options
      """
      @spec send_message(integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
      @spec send_message(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
      def send_message(chat_id, text), do: send_message(chat_id, text, [])

      @doc group: "Messages"
      def send_message(%Client{} = client, chat_id, text),
        do: send_message(client, chat_id, text, [])

      def send_message(chat_id, text, options) do
        api_request("sendMessage", [chat_id: chat_id, text: text] ++ options)
      end

      @doc group: "Messages"
      def send_message(%Client{} = client, chat_id, text, options) do
        api_request(client, "sendMessage", [chat_id: chat_id, text: text] ++ options)
      end

      @doc group: "Messages"
      @doc """
      Use this method to send rich messages.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target bot,
      supergroup, or channel
      * `rich_message` - JSON-serializable InputRichMessage object or a pre-encoded JSON string
      * `options` - keyword list of options
      """
      @spec send_rich_message(integer | binary, list | map | struct | binary) ::
              {:ok, Message.t()} | {:error, Error.t()}
      @spec send_rich_message(integer | binary, list | map | struct | binary, [{atom, any}] | map) ::
              {:ok, Message.t()} | {:error, Error.t()}
      @spec send_rich_message(Client.t(), integer | binary, list | map | struct | binary) ::
              {:ok, Message.t()} | {:error, Error.t()}
      @spec send_rich_message(
              Client.t(),
              integer | binary,
              list | map | struct | binary,
              [{atom, any}] | map
            ) ::
              {:ok, Message.t()} | {:error, Error.t()}
      def send_rich_message(chat_id, rich_message),
        do: send_rich_message(chat_id, rich_message, [])

      @doc group: "Messages"
      def send_rich_message(%Client{} = client, chat_id, rich_message) do
        send_rich_message(client, chat_id, rich_message, [])
      end

      def send_rich_message(chat_id, rich_message, options) do
        api_request(
          "sendRichMessage",
          request_options(
            [chat_id: chat_id, rich_message: encode_json_payload(rich_message)],
            encode_rich_message_options(options)
          )
        )
      end

      @doc group: "Messages"
      def send_rich_message(%Client{} = client, chat_id, rich_message, options) do
        api_request(
          client,
          "sendRichMessage",
          request_options(
            [chat_id: chat_id, rich_message: encode_json_payload(rich_message)],
            encode_rich_message_options(options)
          )
        )
      end

      @doc group: "Messages"
      @doc """
      Use this method to forward messages of any kind.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `from_chat_id` - Unique identifier for the chat where the original message was sent
      or username of the target channel (in the format @channelusername)
      * `message_id` - Unique message identifier
      * `options` - keyword list of options

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

      @doc group: "Messages"
      def forward_message(%Client{} = client, chat_id, from_chat_id, message_id) do
        forward_message(client, chat_id, from_chat_id, message_id, [])
      end

      def forward_message(chat_id, from_chat_id, message_id, options) do
        api_request(
          "forwardMessage",
          [chat_id: chat_id, from_chat_id: from_chat_id, message_id: message_id] ++ options
        )
      end

      @doc group: "Messages"
      def forward_message(%Client{} = client, chat_id, from_chat_id, message_id, options) do
        api_request(
          client,
          "forwardMessage",
          [chat_id: chat_id, from_chat_id: from_chat_id, message_id: message_id] ++ options
        )
      end

      @doc group: "Messages"
      @doc """
      Use this method to forward multiple messages of any kind.
      On success, an array of MessageId objects is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `from_chat_id` - Unique identifier for the chat where the original messages were sent
      or username of the target channel (in the format @channelusername)
      * `message_ids` - List of message identifiers
      * `options` - keyword list of options

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

      @doc group: "Messages"
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

      @doc group: "Messages"
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

      @doc group: "Messages"
      @doc """
      Use this method to copy messages of any kind.
      On success, the MessageId of the sent message is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `from_chat_id` - Unique identifier for the chat where the original message was sent
      or username of the target channel (in the format @channelusername)
      * `message_id` - Unique message identifier
      * `options` - keyword list of options

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

      @doc group: "Messages"
      def copy_message(%Client{} = client, chat_id, from_chat_id, message_id) do
        copy_message(client, chat_id, from_chat_id, message_id, [])
      end

      def copy_message(chat_id, from_chat_id, message_id, options) do
        api_request(
          "copyMessage",
          [chat_id: chat_id, from_chat_id: from_chat_id, message_id: message_id] ++ options
        )
      end

      @doc group: "Messages"
      def copy_message(%Client{} = client, chat_id, from_chat_id, message_id, options) do
        api_request(
          client,
          "copyMessage",
          [chat_id: chat_id, from_chat_id: from_chat_id, message_id: message_id] ++ options
        )
      end

      @doc group: "Messages"
      @doc """
      Use this method to copy multiple messages of any kind.
      On success, an array of MessageId objects is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `from_chat_id` - Unique identifier for the chat where the original messages were sent
      or username of the target channel (in the format @channelusername)
      * `message_ids` - List of message identifiers
      * `options` - keyword list of options

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

      @doc group: "Messages"
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

      @doc group: "Messages"
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

      @doc group: "Messages"
      @doc """
      Use this method to send photos.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `photo` - Photo to send. Either a `file_id` to resend a photo that is already on
      the Telegram servers, or a `file_path` to upload a new photo
      * `options` - keyword list of options

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

      @doc group: "Messages"
      def send_photo(%Client{} = client, chat_id, photo),
        do: send_photo(client, chat_id, photo, [])

      def send_photo(chat_id, photo, options) do
        api_request("sendPhoto", [chat_id: chat_id, photo: photo] ++ options, :photo)
      end

      @doc group: "Messages"
      def send_photo(%Client{} = client, chat_id, photo, options) do
        api_request(client, "sendPhoto", [chat_id: chat_id, photo: photo] ++ options, :photo)
      end

      @doc group: "Messages"
      @doc """
      Use this method to send audio files, if you want Telegram clients to display
      them in the music player. Your audio must be in MP3 or M4A format.
      On success, the sent Message is returned.
      Bots can currently send audio files of up to 50 MB in size, this limit may
      be changed in the future.

      For sending voice messages, use `send_voice` instead.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `audio` - Audio to send. Either a `file_id` to resend an audio that is already on
      the Telegram servers, or a `file_path` to upload a new audio
      * `options` - keyword list of options

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

      @doc group: "Messages"
      def send_audio(%Client{} = client, chat_id, audio),
        do: send_audio(client, chat_id, audio, [])

      def send_audio(chat_id, audio, options) do
        api_request("sendAudio", [chat_id: chat_id, audio: audio] ++ options, :audio)
      end

      @doc group: "Messages"
      def send_audio(%Client{} = client, chat_id, audio, options) do
        api_request(client, "sendAudio", [chat_id: chat_id, audio: audio] ++ options, :audio)
      end

      @doc group: "Messages"
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
      * `options` - keyword list of options

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

      @doc group: "Messages"
      def send_document(%Client{} = client, chat_id, document) do
        send_document(client, chat_id, document, [])
      end

      def send_document(chat_id, document, options) do
        api_request("sendDocument", [chat_id: chat_id, document: document] ++ options, :document)
      end

      @doc group: "Messages"
      def send_document(%Client{} = client, chat_id, document, options) do
        api_request(
          client,
          "sendDocument",
          [chat_id: chat_id, document: document] ++ options,
          :document
        )
      end

      @doc group: "Messages"
      @doc """
      Use this method to send .webp stickers.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `sticker` - File to send. Either a `file_id` to resend a sticker that is already on
      the Telegram servers, or a `file_path` to upload a new sticker
      * `options` - keyword list of options

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

      @doc group: "Messages"
      def send_sticker(%Client{} = client, chat_id, sticker) do
        send_sticker(client, chat_id, sticker, [])
      end

      def send_sticker(chat_id, sticker, options) do
        api_request("sendSticker", [chat_id: chat_id, sticker: sticker] ++ options, :sticker)
      end

      @doc group: "Messages"
      def send_sticker(%Client{} = client, chat_id, sticker, options) do
        api_request(
          client,
          "sendSticker",
          [chat_id: chat_id, sticker: sticker] ++ options,
          :sticker
        )
      end

      @doc group: "Messages"
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
      * `options` - keyword list of options

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

      @doc group: "Messages"
      def send_video(%Client{} = client, chat_id, video),
        do: send_video(client, chat_id, video, [])

      def send_video(chat_id, video, options) do
        api_request("sendVideo", [chat_id: chat_id, video: video] ++ options, :video)
      end

      @doc group: "Messages"
      def send_video(%Client{} = client, chat_id, video, options) do
        api_request(client, "sendVideo", [chat_id: chat_id, video: video] ++ options, :video)
      end

      @doc group: "Messages"
      @doc """
      Use this method to send audio files, if you want Telegram clients to display
      the file as a playable voice message. Supported formats are OGG with OPUS,
      MP3, and M4A (other formats may be sent as Audio or Document).
      On success, the sent Message is returned.
      Bots can currently send voice messages of up to 50 MB in size, this limit may be
      changed in the future.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `voice` - Audio to send. Either a `file_id` to resend an audio that is already on
      the Telegram servers, or a `file_path` to upload a new audio
      * `options` - keyword list of options

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

      @doc group: "Messages"
      def send_voice(%Client{} = client, chat_id, voice),
        do: send_voice(client, chat_id, voice, [])

      def send_voice(chat_id, voice, options) do
        api_request("sendVoice", [chat_id: chat_id, voice: voice] ++ options, :voice)
      end

      @doc group: "Messages"
      def send_voice(%Client{} = client, chat_id, voice, options) do
        api_request(client, "sendVoice", [chat_id: chat_id, voice: voice] ++ options, :voice)
      end

      @doc group: "Messages"
      @doc """
      Use this method to send video messages.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `video_note` - Video note to send. Either a `file_id` to resend a video note that is
      already on the Telegram servers, or a `file_path` to upload a new video note
      * `options` - keyword list of options
      """
      @spec send_video_note(integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
      @spec send_video_note(Client.t(), integer | binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
      def send_video_note(chat_id, video_note), do: send_video_note(chat_id, video_note, [])

      @doc group: "Messages"
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

      @doc group: "Messages"
      def send_video_note(%Client{} = client, chat_id, video_note, options) do
        api_request(
          client,
          "sendVideoNote",
          [chat_id: chat_id, video_note: video_note] ++ options,
          :video_note
        )
      end

      @doc group: "Messages"
      @doc """
      Use this method to send live photos.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `live_photo` - Live photo media to send
      * `photo` - Cover photo to send as a regular Telegram parameter
      * `options` - keyword list of options
      """
      @spec send_live_photo(integer | binary, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
      @spec send_live_photo(Client.t(), integer | binary, binary, binary, [{atom, any}]) ::
              {:ok, Message.t()} | {:error, Error.t()}
      def send_live_photo(chat_id, live_photo, photo) do
        send_live_photo(chat_id, live_photo, photo, [])
      end

      @doc group: "Messages"
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

      @doc group: "Messages"
      def send_live_photo(%Client{} = client, chat_id, live_photo, photo, options) do
        api_request(
          client,
          "sendLivePhoto",
          [chat_id: chat_id, live_photo: live_photo, photo: photo] ++ options,
          :live_photo
        )
      end

      @doc group: "Messages"
      @doc """
      Use this method to send an album of photos, videos, documents or audios.
      On success, an array of sent Messages is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `media` - JSON-serializable media array or a pre-encoded JSON string
      * `options` - keyword list of options
      """
      @spec send_media_group(integer | binary, list | map | struct | binary, [{atom, any}]) ::
              {:ok, [Message.t()]} | {:error, Error.t()}
      @spec send_media_group(Client.t(), integer | binary, list | map | struct | binary, [
              {atom, any}
            ]) ::
              {:ok, [Message.t()]} | {:error, Error.t()}
      def send_media_group(chat_id, media), do: send_media_group(chat_id, media, [])

      @doc group: "Messages"
      def send_media_group(%Client{} = client, chat_id, media) do
        send_media_group(client, chat_id, media, [])
      end

      def send_media_group(chat_id, media, options) do
        api_request(
          "sendMediaGroup",
          [chat_id: chat_id, media: encode_json_payload(media)] ++ options
        )
      end

      @doc group: "Messages"
      def send_media_group(%Client{} = client, chat_id, media, options) do
        api_request(
          client,
          "sendMediaGroup",
          [chat_id: chat_id, media: encode_json_payload(media)] ++ options
        )
      end

      @doc group: "Messages"
      @doc """
      Use this method to send paid media.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `star_count` - Amount of Telegram Stars to be paid for the media
      * `media` - JSON-serializable paid media array or a pre-encoded JSON string
      * `options` - keyword list of options
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

      @doc group: "Messages"
      def send_paid_media(%Client{} = client, chat_id, star_count, media) do
        send_paid_media(client, chat_id, star_count, media, [])
      end

      def send_paid_media(chat_id, star_count, media, options) do
        api_request(
          "sendPaidMedia",
          [chat_id: chat_id, star_count: star_count, media: encode_json_payload(media)] ++ options
        )
      end

      @doc group: "Messages"
      def send_paid_media(%Client{} = client, chat_id, star_count, media, options) do
        api_request(
          client,
          "sendPaidMedia",
          [chat_id: chat_id, star_count: star_count, media: encode_json_payload(media)] ++ options
        )
      end

      @doc group: "Messages"
      @doc """
      Use this method to send a native poll.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `question` - Poll question
      * `params` - keyword list or map of Telegram parameters, including required `:options`
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

      @doc group: "Messages"
      def send_poll(%Client{} = client, chat_id, question, params) when is_list(params) do
        api_request(
          client,
          "sendPoll",
          [chat_id: chat_id, question: question] ++ encode_poll_options(params)
        )
      end

      @doc group: "Messages"
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

      @doc group: "Messages"
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
      @doc group: "Messages"
      def send_dice(%Client{} = client, chat_id), do: send_dice(client, chat_id, [])
      def send_dice(chat_id, options), do: api_request("sendDice", [chat_id: chat_id] ++ options)

      @doc group: "Messages"
      def send_dice(%Client{} = client, chat_id, options) do
        api_request(client, "sendDice", [chat_id: chat_id] ++ options)
      end

      @doc group: "Messages"
      @doc """
      Use this method to send a game.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat
      * `game_short_name` - Short name of the game
      * `options` - keyword list or map of options
      """
      @spec send_game(integer | binary, binary) :: {:ok, Message.t()} | {:error, Error.t()}
      @spec send_game(integer | binary, binary, [{atom, any}] | map) ::
              {:ok, Message.t()} | {:error, Error.t()}
      @spec send_game(Client.t(), integer | binary, binary) ::
              {:ok, Message.t()} | {:error, Error.t()}
      @spec send_game(Client.t(), integer | binary, binary, [{atom, any}] | map) ::
              {:ok, Message.t()} | {:error, Error.t()}
      def send_game(chat_id, game_short_name), do: send_game(chat_id, game_short_name, [])

      @doc group: "Messages"
      def send_game(%Client{} = client, chat_id, game_short_name) do
        send_game(client, chat_id, game_short_name, [])
      end

      def send_game(chat_id, game_short_name, options) do
        api_request(
          "sendGame",
          request_options([chat_id: chat_id, game_short_name: game_short_name], options)
        )
      end

      @doc group: "Messages"
      def send_game(%Client{} = client, chat_id, game_short_name, options) do
        api_request(
          client,
          "sendGame",
          request_options([chat_id: chat_id, game_short_name: game_short_name], options)
        )
      end

      @doc group: "Messages"
      @doc """
      Use this method to send a checklist on behalf of a connected business account.
      On success, the sent Message is returned.

      Args:
      * `business_connection_id` - Unique identifier of the business connection
      * `chat_id` - Unique identifier for the target chat or username of the target bot
      * `checklist` - JSON-serializable checklist object or a pre-encoded JSON string
      * `options` - keyword list of options
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

      @doc group: "Messages"
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

      @doc group: "Messages"
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

      @doc group: "Messages"
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

      @doc group: "Messages"
      def send_message_draft(%Client{} = client, chat_id, draft_id) do
        send_message_draft(client, chat_id, draft_id, [])
      end

      def send_message_draft(chat_id, draft_id, options) do
        api_request("sendMessageDraft", [chat_id: chat_id, draft_id: draft_id] ++ options)
      end

      @doc group: "Messages"
      def send_message_draft(%Client{} = client, chat_id, draft_id, options) do
        api_request(client, "sendMessageDraft", [chat_id: chat_id, draft_id: draft_id] ++ options)
      end

      @doc group: "Messages"
      @doc """
      Use this method to stream a partial rich message to a user while the message is
      being generated.
      Returns `:ok` on success.
      """
      @spec send_rich_message_draft(integer, integer, list | map | struct | binary) ::
              :ok | {:error, Error.t()}
      @spec send_rich_message_draft(integer, integer, list | map | struct | binary, [
              {atom, any}
            ]) ::
              :ok | {:error, Error.t()}
      @spec send_rich_message_draft(Client.t(), integer, integer, list | map | struct | binary) ::
              :ok | {:error, Error.t()}
      @spec send_rich_message_draft(
              Client.t(),
              integer,
              integer,
              list | map | struct | binary,
              [{atom, any}]
            ) ::
              :ok | {:error, Error.t()}
      def send_rich_message_draft(chat_id, draft_id, rich_message) do
        send_rich_message_draft(chat_id, draft_id, rich_message, [])
      end

      @doc group: "Messages"
      def send_rich_message_draft(%Client{} = client, chat_id, draft_id, rich_message) do
        send_rich_message_draft(client, chat_id, draft_id, rich_message, [])
      end

      def send_rich_message_draft(chat_id, draft_id, rich_message, options) do
        api_request(
          "sendRichMessageDraft",
          [chat_id: chat_id, draft_id: draft_id, rich_message: encode_json_payload(rich_message)] ++
            options
        )
      end

      @doc group: "Messages"
      def send_rich_message_draft(%Client{} = client, chat_id, draft_id, rich_message, options) do
        api_request(
          client,
          "sendRichMessageDraft",
          [chat_id: chat_id, draft_id: draft_id, rich_message: encode_json_payload(rich_message)] ++
            options
        )
      end

      @doc group: "Messages"
      @doc """
      Use this method to send point on the map.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `latitude` - Latitude of location
      * `longitude` - Longitude of location
      * `options` - keyword list of options

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

      @doc group: "Messages"
      def send_location(%Client{} = client, chat_id, latitude, longitude) do
        send_location(client, chat_id, latitude, longitude, [])
      end

      def send_location(chat_id, latitude, longitude, options) do
        api_request(
          "sendLocation",
          [chat_id: chat_id, latitude: latitude, longitude: longitude] ++ options
        )
      end

      @doc group: "Messages"
      def send_location(%Client{} = client, chat_id, latitude, longitude, options) do
        api_request(
          client,
          "sendLocation",
          [chat_id: chat_id, latitude: latitude, longitude: longitude] ++ options
        )
      end

      @doc group: "Messages"
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
      * `options` - keyword list of options

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

      @doc group: "Messages"
      def send_venue(%Client{} = client, chat_id, latitude, longitude, title, address) do
        send_venue(client, chat_id, latitude, longitude, title, address, [])
      end

      def send_venue(chat_id, latitude, longitude, title, address, options) do
        api_request(
          "sendVenue",
          [
            chat_id: chat_id,
            latitude: latitude,
            longitude: longitude,
            title: title,
            address: address
          ] ++
            options
        )
      end

      @doc group: "Messages"
      def send_venue(%Client{} = client, chat_id, latitude, longitude, title, address, options) do
        api_request(
          client,
          "sendVenue",
          [
            chat_id: chat_id,
            latitude: latitude,
            longitude: longitude,
            title: title,
            address: address
          ] ++
            options
        )
      end

      @doc group: "Messages"
      @doc """
      Use this method to send phone contacts.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the target chat or username of the target channel
      (in the format @channelusername)
      * `phone_number` - Contact's phone number
      * `first_name` - Contact's first name
      * `options` - keyword list of options

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

      @doc group: "Messages"
      def send_contact(%Client{} = client, chat_id, phone_number, first_name) do
        send_contact(client, chat_id, phone_number, first_name, [])
      end

      def send_contact(chat_id, phone_number, first_name, options) do
        api_request(
          "sendContact",
          [chat_id: chat_id, phone_number: phone_number, first_name: first_name] ++ options
        )
      end

      @doc group: "Messages"
      def send_contact(%Client{} = client, chat_id, phone_number, first_name, options) do
        api_request(
          client,
          "sendContact",
          [chat_id: chat_id, phone_number: phone_number, first_name: first_name] ++ options
        )
      end

      @doc group: "Messages"
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
      * `options` - keyword list of options

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

      @doc group: "Messages"
      def send_chat_action(%Client{} = client, chat_id, action) do
        send_chat_action(client, chat_id, action, [])
      end

      def send_chat_action(chat_id, action, options) do
        api_request("sendChatAction", [chat_id: chat_id, action: action] ++ options)
      end

      @doc group: "Messages"
      def send_chat_action(%Client{} = client, chat_id, action, options) do
        api_request(client, "sendChatAction", [chat_id: chat_id, action: action] ++ options)
      end

      @doc group: "Messages"
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

      @doc group: "Messages"
      def send_animation(%Client{} = client, chat_id, animation) do
        send_animation(client, chat_id, animation, [])
      end

      def send_animation(chat_id, animation, options) do
        api_request(
          "sendAnimation",
          [chat_id: chat_id, animation: animation] ++ options,
          :animation
        )
      end

      @doc group: "Messages"
      def send_animation(%Client{} = client, chat_id, animation, options) do
        api_request(
          client,
          "sendAnimation",
          [chat_id: chat_id, animation: animation] ++ options,
          :animation
        )
      end

      @doc group: "Messages"
      @doc """
      Use this method to get a list of profile pictures for a user.
      Returns a UserProfilePhotos object.

      Args:
      * `user_id` - Unique identifier of the target user
      * `options` - keyword list of options

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

      @doc group: "Messages"
      def get_user_profile_photos(%Client{} = client, user_id) do
        get_user_profile_photos(client, user_id, [])
      end

      def get_user_profile_photos(user_id, options) do
        api_request("getUserProfilePhotos", [user_id: user_id] ++ options)
      end

      @doc group: "Messages"
      def get_user_profile_photos(%Client{} = client, user_id, options) do
        api_request(client, "getUserProfilePhotos", [user_id: user_id] ++ options)
      end

      @doc group: "Messages"
      @doc """
      Use this method to get a list of profile audios for a user.
      Returns a UserProfileAudios object.

      Args:
      * `user_id` - Unique identifier of the target user
      * `options` - keyword list of options

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

      @doc group: "Messages"
      def get_user_profile_audios(%Client{} = client, user_id) do
        get_user_profile_audios(client, user_id, [])
      end

      def get_user_profile_audios(user_id, options) do
        api_request("getUserProfileAudios", request_options([user_id: user_id], options))
      end

      @doc group: "Messages"
      def get_user_profile_audios(%Client{} = client, user_id, options) do
        api_request(client, "getUserProfileAudios", request_options([user_id: user_id], options))
      end
    end
  end
end
