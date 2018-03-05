defmodule Nadia do
  @moduledoc """
  Provides access to Telegram Bot API.

  ## Reference
  https://core.telegram.org/bots/api#available-methods
  """

  alias Nadia.Model.{User, Message, Update, UserProfilePhotos, File, Error}

  import Nadia.API

  @behaviour Nadia.Behaviour

  @base_file_url "https://api.telegram.org/file/bot"

  @doc """
  A simple method for testing your bot's auth token. Requires no parameters.
  Returns basic information about the bot in form of a User object.
  """
  @spec get_me :: {:ok, User.t()} | {:error, Error.t()}
  def get_me, do: request("getMe")

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
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_message(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  def send_message(chat_id, text, options \\ []) do
    request("sendMessage", [chat_id: chat_id, text: text] ++ options)
  end

  @doc """
  Use this method to forward messages of any kind.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target channel
  (in the format @channelusername)
  * `from_chat_id` - Unique identifier for the chat where the original message was sent
  or username of the target channel (in the format @channelusername)
  * `:disable_notification` - Sends the message silently or without notification
  * `message_id` - Unique message identifier
  """
  @spec forward_message(integer, integer, integer) :: {:ok, Message.t()} | {:error, Error.t()}
  def forward_message(chat_id, from_chat_id, message_id) do
    request(
      "forwardMessage",
      chat_id: chat_id,
      from_chat_id: from_chat_id,
      message_id: message_id
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
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_photo(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  def send_photo(chat_id, photo, options \\ []) do
    request("sendPhoto", [chat_id: chat_id, photo: photo] ++ options, :photo)
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
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_audio(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  def send_audio(chat_id, audio, options \\ []) do
    request("sendAudio", [chat_id: chat_id, audio: audio] ++ options, :audio)
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
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_document(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  def send_document(chat_id, document, options \\ []) do
    request("sendDocument", [chat_id: chat_id, document: document] ++ options, :document)
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
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_sticker(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  def send_sticker(chat_id, sticker, options \\ []) do
    request("sendSticker", [chat_id: chat_id, sticker: sticker] ++ options, :sticker)
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
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_video(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  def send_video(chat_id, video, options \\ []) do
    request("sendVideo", [chat_id: chat_id, video: video] ++ options, :video)
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
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_voice(integer, binary, [{atom, any}]) :: {:ok, Message.t()} | {:error, Error.t()}
  def send_voice(chat_id, voice, options \\ []) do
    request("sendVoice", [chat_id: chat_id, voice: voice] ++ options, :voice)
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
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_location(integer, float, float, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_location(chat_id, latitude, longitude, options \\ []) do
    request(
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
  `Nadia.Model.ReplyKeyboardMarkup` or `Nadia.Model.ReplyKeyboardHide` or
  `Nadia.Model.ForceReply`
  """
  @spec send_venue(integer, float, float, binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_venue(chat_id, latitude, longitude, title, address, options \\ []) do
    request(
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
  `Nadia.Model.ReplyKeyboardMarkup` or `Nadia.Model.ReplyKeyboardHide` or
  `Nadia.Model.ForceReply`
  """
  @spec send_contact(integer, binary, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def send_contact(chat_id, phone_number, first_name, options \\ []) do
    request(
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
  """
  @spec send_chat_action(integer, binary) :: :ok | {:error, Error.t()}
  def send_chat_action(chat_id, action) do
    request("sendChatAction", chat_id: chat_id, action: action)
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
  def get_user_profile_photos(user_id, options \\ []) do
    request("getUserProfilePhotos", [user_id: user_id] ++ options)
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
  * `:limit` - Limits the number of photos to be retrieved. Values between 1—100 are
  accepted. Defaults to 100
  * `:timeout` - Timeout in seconds for long polling. Defaults to 0, i.e. usual short
  polling
  """
  @spec get_updates([{atom, any}]) :: {:ok, [Update.t()]} | {:error, Error.t()}
  def get_updates(options \\ []), do: request("getUpdates", options)

  @doc """
  Use this method to specify a url and receive incoming updates via an outgoing
  webhook. Whenever there is an update for the bot, we will send an HTTPS POST
  request to the specified url, containing a JSON-serialized Update. In case of
  an unsuccessful request, we will give up after a reasonable amount of attempts.

  Args:
  * `options` - orddict of options

  Options:
  * `:url` - HTTPS url to send updates to. Use an empty string to remove webhook
  integration
  """
  @spec set_webhook([{atom, any}]) :: :ok | {:error, Error.t()}
  def set_webhook(options \\ []), do: request("setWebhook", options)

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
  def get_file(file_id), do: request("getFile", file_id: file_id)

  @doc ~S"""
  Use this method to get link for file for subsequent use.
  This method is an extension of the `get_file` method.

      iex> Nadia.get_file_link(%Nadia.Model.File{file_id: "BQADBQADBgADmEjsA1aqdSxtzvvVAg",
      ...> file_path: "document/file_10", file_size: 17680})
      {:ok,
      "https://api.telegram.org/file/bot#{Application.get_env(:nadia, :token)}/document/file_10"}

  """
  @spec get_file_link(File.t()) :: {:ok, binary} | {:error, Error.t()}
  def get_file_link(file) do
    token = Application.get_env(:nadia, :token)
    {:ok, @base_file_url <> token <> "/" <> file.file_path}
  end

  @doc """
  Use this method to kick a user from a group or a supergroup. In the case of supergroups,
  the user will not be able to return to the group on their own using invite links, etc.,
  unless unbanned first. The bot must be an administrator in the group for this to work.
  Returns True on success.

  Note: This will method only work if the ‘All Members Are Admins’ setting is off in the
  target group. Otherwise members may only be removed by the group's creator or by the
  member that added them.

  Args:
  * `chat_id` - Unique identifier for the target group or username of the target supergroup
  (in the format @supergroupusername)
  * `user_id` - Unique identifier of the target user
  """
  @spec kick_chat_member(integer | binary, integer) :: :ok | {:error, Error.t()}
  def kick_chat_member(chat_id, user_id) do
    request("kickChatMember", chat_id: chat_id, user_id: user_id)
  end

  @doc """
  Use this method for your bot to leave a group, supergroup or channel.
  Returns True on success.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target supergroup or
  channel (in the format @supergroupusername)
  """
  @spec leave_chat(integer | binary) :: :ok | {:error, Error.t()}
  def leave_chat(chat_id) do
    request("leaveChat", chat_id: chat_id)
  end

  @doc """
  Use this method to unban a previously kicked user in a supergroup. The user will not
  return to the group automatically, but will be able to join via link, etc. The bot
  must be an administrator in the group for this to work. Returns True on success.

  Args:
  * `chat_id` - Unique identifier for the target group or username of the target supergroup
  (in the format @supergroupusername)
  * `user_id` - Unique identifier of the target user
  """
  @spec unban_chat_member(integer | binary, integer) :: :ok | {:error, Error.t()}
  def unban_chat_member(chat_id, user_id) do
    request("unbanChatMember", chat_id: chat_id, user_id: user_id)
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
  def get_chat(chat_id) do
    request("getChat", chat_id: chat_id)
  end

  @doc """
  Use this method to get a list of administrators in a chat. On success, returns an Array of
  ChatMember objects that contains information about all chat administrators except other bots.
  If the chat is a group or a supergroup and no administrators were appointed, only the creator
  will be returned.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target supergroup or
  channel (in the format @channelusername)
  """
  @spec get_chat_administrators(integer | binary) :: {:ok, [ChatMember.t()]} | {:error, Error.t()}
  def get_chat_administrators(chat_id) do
    request("getChatAdministrators", chat_id: chat_id)
  end

  @doc """
  Use this method to get the number of members in a chat. Returns Int on success.

  Args:
  * `chat_id` - Unique identifier for the target chat or username of the target supergroup or
  channel (in the format @channelusername)
  """
  @spec get_chat_members_count(integer | binary) :: {:ok, integer} | {:error, Error.t()}
  def get_chat_members_count(chat_id) do
    request("getChatMembersCount", chat_id: chat_id)
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
  def get_chat_member(chat_id, user_id) do
    request("getChatMember", chat_id: chat_id, user_id: user_id)
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
  def answer_callback_query(callback_query_id, options \\ []) do
    request("answerCallbackQuery", [callback_query_id: callback_query_id] ++ options)
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
  @spec edit_message_text(integer | binary, integer, binary, [{atom, any}]) ::
          {:ok, Message.t()} | {:error, Error.t()}
  def edit_message_text(chat_id, message_id, inline_message_id, text, options \\ []) do
    request(
      "editMessageText",
      [chat_id: chat_id, message_id: message_id, inline_message_id: inline_message_id, text: text] ++
        options
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
  def edit_message_caption(chat_id, message_id, inline_message_id, options \\ []) do
    request(
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
  def edit_message_reply_markup(chat_id, message_id, inline_message_id, options \\ []) do
    request(
      "editMessageReplyMarkup",
      [chat_id: chat_id, message_id: message_id, inline_message_id: inline_message_id] ++ options
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
  def answer_inline_query(inline_query_id, results, options \\ []) do
    encoded_results =
      results
      |> Enum.map(fn result ->
        for {k, v} <- Map.from_struct(result), v != nil, into: %{}, do: {k, v}
      end)
      |> Poison.encode!()

    args = [inline_query_id: inline_query_id, results: encoded_results]

    request("answerInlineQuery", args ++ options)
  end
end
