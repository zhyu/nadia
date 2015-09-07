defmodule Nadia do
  @moduledoc """
  Provides access to Telegram Bot API.

  ## Reference
  https://core.telegram.org/bots/api#available-methods
  """

  alias Nadia.Model.User
  alias Nadia.Model.Message
  alias Nadia.Model.Update
  alias Nadia.Model.UserProfilePhotos
  alias Nadia.Model.Error

  import Nadia.API

  @doc """
  A simple method for testing your bot's auth token. Requires no parameters.
  Returns basic information about the bot in form of a User object.
  """
  @spec get_me :: {:ok, User.t} | {:error, Error.t}
  def get_me, do: request("getMe")

  @doc """
  Use this method to send text messages.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the message recipient — `Nadia.Model.User `or
  `Nadia.Model.GroupChat` id
  * `text` - Text of the message to be sent
  * `options` - orddict of options

  Options:
  * `:disable_web_page_preview` - Disables link previews for links in this message
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_message(integer, binary, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
  def send_message(chat_id, text, options \\ []) do
    request("sendMessage", [chat_id: chat_id, text: text] ++ options)
  end

  @doc """
  Use this method to forward messages of any kind.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the message recipient — `Nadia.Model.User `or
  `Nadia.Model.GroupChat` id
  * `from_chat_id` - Unique identifier for the chat where the original message was
  sent — `Nadia.Model.User `or `Nadia.Model.GroupChat` id
  * `message_id` - Unique message identifier
  """
  @spec forward_message(integer, integer, integer) :: {:ok, Message.t} | {:error, Error.t}
  def forward_message(chat_id, from_chat_id, message_id) do
    request("forwardMessage", chat_id: chat_id, from_chat_id: from_chat_id, message_id: message_id)
  end

  @doc """
  Use this method to send photos.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the message recipient — `Nadia.Model.User `or
  `Nadia.Model.GroupChat` id
  * `photo` - Photo to send. Either a `file_id` to resend a photo that is already on
  the Telegram servers, or a `file_path` to upload a new photo
  * `options` - orddict of options

  Options:
  * `:caption` - Photo caption (may also be used when resending photos by `file_id`)
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_photo(integer, binary, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
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
  * `chat_id` - Unique identifier for the message recipient — `Nadia.Model.User `or
  `Nadia.Model.GroupChat` id
  * `audio` - Audio to send. Either a `file_id` to resend an audio that is already on
  the Telegram servers, or a `file_path` to upload a new audio
  * `options` - orddict of options

  Options:
  * `:duration` - Duration of the audio in seconds
  * `:performer` - Performer
  * `:title` - Track name
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_audio(integer, binary, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
  def send_audio(chat_id, audio, options \\ []) do
    request("sendAudio", [chat_id: chat_id, audio: audio] ++ options, :audio)
  end

  @doc """
  Use this method to send general files.
  On success, the sent Message is returned.
  Bots can currently send files of any type of up to 50 MB in size, this limit
  may be changed in the future.

  Args:
  * `chat_id` - Unique identifier for the message recipient — `Nadia.Model.User `or
  `Nadia.Model.GroupChat` id
  * `document` - File to send. Either a `file_id` to resend a file that is already on
  the Telegram servers, or a `file_path` to upload a new file
  * `options` - orddict of options

  Options:
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_document(integer, binary, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
  def send_document(chat_id, document, options \\ []) do
    request("sendDocument", [chat_id: chat_id, document: document] ++ options, :document)
  end

  @doc """
  Use this method to send .webp stickers.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the message recipient — `Nadia.Model.User `or
  `Nadia.Model.GroupChat` id
  * `sticker` - File to send. Either a `file_id` to resend a sticker that is already on
  the Telegram servers, or a `file_path` to upload a new sticker
  * `options` - orddict of options

  Options:
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_sticker(integer, binary, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
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
  * `chat_id` - Unique identifier for the message recipient — `Nadia.Model.User `or
  `Nadia.Model.GroupChat` id
  * `video` - Video to send. Either a `file_id` to resend a video that is already on
  the Telegram servers, or a `file_path` to upload a new video
  * `options` - orddict of options

  Options:
  * `:duration` - Duration of the video in seconds
  * `:caption` - Video caption (may also be used when resending videos by `file_id`)
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_video(integer, binary, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
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
  * `chat_id` - Unique identifier for the message recipient — `Nadia.Model.User `or
  `Nadia.Model.GroupChat` id
  * `voice` - Audio to send. Either a `file_id` to resend an audio that is already on
  the Telegram servers, or a `file_path` to upload a new audio
  * `options` - orddict of options

  Options:
  * `:duration` - Duration of the audio in seconds
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_voice(integer, binary, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
  def send_voice(chat_id, voice, options \\ []) do
    request("sendVoice", [chat_id: chat_id, voice: voice] ++ options, :voice)
  end

  @doc """
  Use this method to send point on the map.
  On success, the sent Message is returned.

  Args:
  * `chat_id` - Unique identifier for the message recipient — `Nadia.Model.User `or
  `Nadia.Model.GroupChat` id
  * `latitude` - Latitude of location
  * `longitude` - Longitude of location
  * `options` - orddict of options

  Options:
  * `:reply_to_message_id` - If the message is a reply, ID of the original message
  * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to
  force a reply from the user - `Nadia.Model.ReplyKeyboardMarkup` or
  `Nadia.Model.ReplyKeyboardHide` or `Nadia.Model.ForceReply`
  """
  @spec send_location(integer, float, float, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
  def send_location(chat_id, latitude, longitude, options \\ []) do
    request("sendLocation", [chat_id: chat_id, latitude: latitude, longitude: longitude] ++ options)
  end

  @doc """
  Use this method when you need to tell the user that something is happening on
  the bot's side. The status is set for 5 seconds or less (when a message
  arrives from your bot, Telegram clients clear its typing status).

  Args:
  * `chat_id` - Unique identifier for the message recipient — `Nadia.Model.User `or
  `Nadia.Model.GroupChat` id
  * `action` - Type of action to broadcast. Choose one, depending on what the user is
  about to receive:
      * `typing` for text messages
      * `upload_photo` for photos
      * `record_video` or `upload_video` for videos
      * `record_audio` or `upload_audio` for audio files
      * `upload_document` for general files
      * `find_location` for location data
  """
  @spec send_chat_action(integer, binary) :: :ok | {:error, Error.t}
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
  @spec get_user_profile_photos(integer, [{atom, any}]) :: {:ok, UserProfilePhotos.t} | {:error, Error.t}
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
  @spec get_updates([{atom, any}]) :: {:ok, [Update.t]} | {:error, Error.t}
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
  @spec set_webhook([{atom, any}]) :: :ok | {:error, Error.t}
  def set_webhook(options \\ []), do: request("setWebhook", options)
end
