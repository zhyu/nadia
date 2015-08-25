defmodule Nadia.API do
  @moduledoc """
  Provides basic functionalities for Telegram Bot API.
  """

  alias Nadia.User
  alias Nadia.Message
  alias Nadia.Update
  alias Nadia.UserProfilePhotos
  alias Nadia.Error

  defmacro __using__(_) do
    quote do
      @base_url "https://api.telegram.org/bot"

      defp token, do: Application.get_env(:nadia, :token)

      defp build_url(method), do: @base_url <> token <> "/" <> method

      defp process_response(response, method) do
        case response do
          {:error, %HTTPoison.Error{reason: reason}} -> {:error, %Error{reason: reason}}
          {:ok, %HTTPoison.Response{status_code: 403}} -> {:error, %Error{reason: "token invalid"}}
          {:ok, %HTTPoison.Response{body: body}} ->
            case Poison.decode!(body, keys: :atoms) do
              %{ok: false, description: description} -> {:error, %Error{reason: description}}
              %{result: true} -> :ok
              %{result: result} -> {:ok, Nadia.Parser.parse_result(result, method)}
            end
        end
      end

      defp get_response(method, request \\ []) do
        method
        |> build_url
        |> HTTPoison.post(request)
        |> process_response(method)
      end

      defp build_multipart_request(params, file_field) do
        {file_path, params} = Keyword.pop(params, file_field)
        params = for {k, v} <- params, do: {to_string(k), v}
        {:multipart, params ++ [
          {:file, file_path,
           {"form-data", [{"name", to_string(file_field)}, {"filename", file_path}]}, []}
        ]}
      end

      defp build_request(params, file_field \\ nil) do
        params = params
        |> Keyword.update(:reply_markup, nil, &(Poison.encode!(&1)))
        |> Enum.map(fn {k, v} -> {k, to_string(v)} end)
        if !is_nil(file_field) and File.exists?(params[file_field]) do
          build_multipart_request(params, file_field)
        else
          {:form, params}
        end
      end

      @doc """
      A simple method for testing your bot's auth token. Requires no parameters.
      Returns basic information about the bot in form of a User object.
      """
      @spec get_me :: {:ok, User.t} | {:error, Error.t}
      def get_me do
        get_response("getMe")
      end

      @doc """
      Use this method to send text messages.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the message recipient — `Nadia.User `or `Nadia.GroupChat` id
      * `text` - Text of the message to be sent
      * `options` - orddict of options

      Options:
      * `:disable_web_page_preview` - Disables link previews for links in this message
      * `:reply_to_message_id` - If the message is a reply, ID of the original message
      * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to force a reply from the user.
      """
      @spec send_message(integer, binary, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
      def send_message(chat_id, text, options \\ []) do
        request = build_request([chat_id: chat_id, text: text] ++ options)
        get_response("sendMessage", request)
      end

      @doc """
      Use this method to forward messages of any kind.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the message recipient — `Nadia.User` or `Nadia.GroupChat` id
      * `from_chat_id` - Unique identifier for the chat where the original message was sent — `Nadia.User `or `Nadia.GroupChat` id
      * `message_id` - Unique message identifier
      """
      @spec forward_message(integer, integer, integer) :: {:ok, Message.t} | {:error, Error.t}
      def forward_message(chat_id, from_chat_id, message_id) do
        request = build_request(chat_id: chat_id, from_chat_id: from_chat_id, message_id: message_id)
        get_response("forwardMessage", request)
      end

      @doc """
      Use this method to send photos.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the message recipient — `Nadia.User `or `Nadia.GroupChat` id
      * `photo` - Photo to send. Either a `file_id` to resend a photo that is already on the Telegram servers,
      or a `file_path` to upload a new photo
      * `options` - orddict of options

      Options:
      * `:caption` - Photo caption (may also be used when resending photos by `file_id`)
      * `:reply_to_message_id` - If the message is a reply, ID of the original message
      * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to force a reply from the user
      """
      @spec send_photo(integer, binary, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
      def send_photo(chat_id, photo, options \\ []) do
        request = build_request([chat_id: chat_id, photo: photo] ++ options, :photo)
        get_response("sendPhoto", request)
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
      * `chat_id` - Unique identifier for the message recipient — `Nadia.User `or `Nadia.GroupChat` id
      * `audio` - Audio to send. Either a `file_id` to resend an audio that is already on the Telegram servers,
      or a `file_path` to upload a new audio
      * `options` - orddict of options

      Options:
      * `:duration` - Duration of the audio in seconds
      * `:performer` - Performer
      * `:title` - Track name
      * `:reply_to_message_id` - If the message is a reply, ID of the original message
      * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to force a reply from the user
      """
      @spec send_audio(integer, binary, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
      def send_audio(chat_id, audio, options \\ []) do
        request = build_request([chat_id: chat_id, audio: audio] ++ options, :audio)
        get_response("sendAudio", request)
      end

      @doc """
      Use this method to send general files.
      On success, the sent Message is returned.
      Bots can currently send files of any type of up to 50 MB in size, this limit
      may be changed in the future.

      Args:
      * `chat_id` - Unique identifier for the message recipient — `Nadia.User `or `Nadia.GroupChat` id
      * `document` - File to send. Either a `file_id` to resend a file that is already on the Telegram servers,
      or a `file_path` to upload a new file
      * `options` - orddict of options

      Options:
      * `:reply_to_message_id` - If the message is a reply, ID of the original message
      * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to force a reply from the user
      """
      @spec send_document(integer, binary, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
      def send_document(chat_id, document, options \\ []) do
        request = build_request([chat_id: chat_id, document: document] ++ options, :document)
        get_response("sendDocument", request)
      end

      @doc """
      Use this method to send .webp stickers.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the message recipient — `Nadia.User `or `Nadia.GroupChat` id
      * `sticker` - File to send. Either a `file_id` to resend a sticker that is already on the Telegram servers,
      or a `file_path` to upload a new sticker
      * `options` - orddict of options

      Options:
      * `:reply_to_message_id` - If the message is a reply, ID of the original message
      * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to force a reply from the user
      """
      @spec send_sticker(integer, binary, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
      def send_sticker(chat_id, sticker, options \\ []) do
        request = build_request([chat_id: chat_id, sticker: sticker] ++ options, :sticker)
        get_response("sendSticker", request)
      end

      @doc """
      Use this method to send video files, Telegram clients support mp4 videos
      (other formats may be sent as Document).
      On success, the sent Message is returned.
      Bots can currently send video files of up to 50 MB in size, this limit may be
      changed in the future.

      Args:
      * `chat_id` - Unique identifier for the message recipient — `Nadia.User `or `Nadia.GroupChat` id
      * `video` - Video to send. Either a `file_id` to resend a video that is already on the Telegram servers,
      or a `file_path` to upload a new video
      * `options` - orddict of options

      Options:
      * `:duration` - Duration of the video in seconds
      * `:caption` - Video caption (may also be used when resending videos by `file_id`)
      * `:reply_to_message_id` - If the message is a reply, ID of the original message
      * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to force a reply from the user
      """
      @spec send_video(integer, binary, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
      def send_video(chat_id, video, options \\ []) do
        request = build_request([chat_id: chat_id, video: video] ++ options, :video)
        get_response("sendVideo", request)
      end

      @doc """
      Use this method to send audio files, if you want Telegram clients to display
      the file as a playable voice message. For this to work, your audio must be in
      an .ogg file encoded with OPUS (other formats may be sent as Audio or Document).
      On success, the sent Message is returned.
      Bots can currently send voice messages of up to 50 MB in size, this limit may be
      changed in the future.

      Args:
      * `chat_id` - Unique identifier for the message recipient — `Nadia.User `or `Nadia.GroupChat` id
      * `voice` - Audio to send. Either a `file_id` to resend an audio that is already on the Telegram servers,
      or a `file_path` to upload a new audio
      * `options` - orddict of options

      Options:
      * `:duration` - Duration of the audio in seconds
      * `:reply_to_message_id` - If the message is a reply, ID of the original message
      * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to force a reply from the user
      """
      @spec send_voice(integer, binary, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
      def send_voice(chat_id, voice, options \\ []) do
        request = build_request([chat_id: chat_id, voice: voice] ++ options, :voice)
        get_response("sendVoice", request)
      end

      @doc """
      Use this method to send point on the map.
      On success, the sent Message is returned.

      Args:
      * `chat_id` - Unique identifier for the message recipient — `Nadia.User `or `Nadia.GroupChat` id
      * `latitude` - Latitude of location
      * `longitude` - Longitude of location
      * `options` - orddict of options

      Options:
      * `:reply_to_message_id` - If the message is a reply, ID of the original message
      * `:reply_markup` - Additional interface options. Instructions to hide keyboard or to force a reply from the user
      """
      @spec send_location(integer, float, float, [{atom, any}]) :: {:ok, Message.t} | {:error, Error.t}
      def send_location(chat_id, latitude, longitude, options \\ []) do
        request = build_request([chat_id: chat_id, latitude: latitude, longitude: longitude] ++ options)
        get_response("sendLocation", request)
      end

      @doc """
      Use this method when you need to tell the user that something is happening on
      the bot's side. The status is set for 5 seconds or less (when a message
      arrives from your bot, Telegram clients clear its typing status).

      Args:
      * `chat_id` - Unique identifier for the message recipient — `Nadia.User `or `Nadia.GroupChat` id
      * `action` - Type of action to broadcast. Choose one, depending on what the user is about to receive:
          * `typing` for text messages
          * `upload_photo` for photos
          * `record_video` or `upload_video` for videos
          * `record_audio` or `upload_audio` for audio files
          * `upload_document` for general files
          * `find_location` for location data
      """
      @spec send_chat_action(integer, binary) :: :ok | {:error, Error.t}
      def send_chat_action(chat_id, action) do
        request = build_request(chat_id: chat_id, action: action)
        get_response("sendChatAction", request)
      end

      @doc """
      Use this method to get a list of profile pictures for a user.
      Returns a UserProfilePhotos object.

      Args:
      * `user_id` - Unique identifier of the target user
      * `options` - orddict of options

      Options:
      * `:offset` - Sequential number of the first photo to be returned. By default, all photos are returned
      * `:limit` - Limits the number of photos to be retrieved. Values between 1—100 are accepted. Defaults to 100
      """
      @spec get_user_profile_photos(integer, [{atom, any}]) :: {:ok, UserProfilePhotos.t} | {:error, Error.t}
      def get_user_profile_photos(user_id, options \\ []) do
        request = build_request([user_id: user_id] ++ options)
        get_response("getUserProfilePhotos", request)
      end

      @doc """
      Use this method to receive incoming updates using long polling.
      An Array of Update objects is returned.

      Args:
      * `options` - orddict of options

      Options:
      * `:offset` - Identifier of the first update to be returned. Must be greater by one than the highest
      among the identifiers of previously received updates. By default, updates starting with the earliest
      unconfirmed update are returned. An update is considered confirmed as soon as `get_updates` is called
      with an `offset` higher than its `update_id`.
      * `:limit` - Limits the number of photos to be retrieved. Values between 1—100 are accepted. Defaults to 100
      * `:timeout` - Timeout in seconds for long polling. Defaults to 0, i.e. usual short polling
      """
      @spec get_updates([{atom, any}]) :: {:ok, [Update.t]} | {:error, Error.t}
      def get_updates(options \\ []) do
        request = build_request(options)
        get_response("getUpdates", request)
      end

      @doc """
      Use this method to specify a url and receive incoming updates via an outgoing
      webhook. Whenever there is an update for the bot, we will send an HTTPS POST
      request to the specified url, containing a JSON-serialized Update. In case of
      an unsuccessful request, we will give up after a reasonable amount of attempts.

      Args:
      * `options` - orddict of options

      Options:
      * `:url` - HTTPS url to send updates to. Use an empty string to remove webhook integration
      """
      @spec set_webhook([{atom, any}]) :: :ok | {:error, Error.t}
      def set_webhook(options \\ []) do
        request = build_request(options)
        get_response("setWebhook", request)
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end

end
