defmodule Nadia do
  @moduledoc """
  Provides access to Telegram Bot API.
  """

  @base_url "https://api.telegram.org/bot"

  defp token, do: Application.get_env(:nadia, :token)

  defp build_url(method), do: @base_url <> token <> "/" <> method

  defp process_response(response) do
    case response do
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
      {:ok, %HTTPoison.Response{status_code: 403}} -> {:error, "token invalid"}
      {:ok, %HTTPoison.Response{body: body}} ->
        data = Poison.decode!(body, keys: :atoms)
        case Dict.get(data, :ok) do
          true -> {:ok, data[:result]}
          _ -> {:error, data[:description]}
        end
    end
  end

  defp get_response(method, request \\ []) do
    method
    |> build_url
    |> HTTPoison.post(request)
    |> process_response
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
    {optional, required} = Keyword.pop(params, :options, [])
    params = required ++ optional
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
  def get_me do
    "getMe" |> get_response
  end

  @doc """
  Use this method to send text messages.
  On success, the sent Message is returned.
  """
  def send_message(chat_id, text, options \\ []) do
    request = binding |> build_request
    get_response("sendMessage", request)
  end

  @doc """
  Use this method to forward messages of any kind.
  On success, the sent Message is returned.
  """
  def forward_message(chat_id, from_chat_id, message_id) do
    request = binding |> build_request
    get_response("forwardMessage", request)
  end

  @doc """
  Use this method to send photos.
  On success, the sent Message is returned.
  """
  def send_photo(chat_id, photo, options \\ []) do
    request = binding |> build_request(:photo)
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
  """
  def send_audio(chat_id, audio, options \\ []) do
    request = binding |> build_request(:audio)
    get_response("sendAudio", request)
  end

  @doc """
  Use this method to send general files.
  On success, the sent Message is returned.
  Bots can currently send files of any type of up to 50 MB in size, this limit
  may be changed in the future.
  """
  def send_document(chat_id, document, options \\ []) do
    request = binding |> build_request(:document)
    get_response("sendDocument", request)
  end

  @doc """
  Use this method to send .webp stickers.
  On success, the sent Message is returned.
  """
  def send_sticker(chat_id, sticker, options \\ []) do
    request = binding |> build_request(:sticker)
    get_response("sendSticker", request)
  end

  @doc """
  Use this method to send video files, Telegram clients support mp4 videos
  (other formats may be sent as Document).
  On success, the sent Message is returned.
  Bots can currently send video files of up to 50 MB in size, this limit may be
  changed in the future.
  """
  def send_video(chat_id, video, options \\ []) do
    request = binding |> build_request(:video)
    get_response("sendVideo", request)
  end

  @doc """
  Use this method to send audio files, if you want Telegram clients to display
  the file as a playable voice message. For this to work, your audio must be in
  an .ogg file encoded with OPUS (other formats may be sent as Audio or Document).
  On success, the sent Message is returned.
  Bots can currently send voice messages of up to 50 MB in size, this limit may be
  changed in the future.
  """
  def send_voice(chat_id, voice, options \\ []) do
    request = binding |> build_request(:voice)
    get_response("sendVoice", request)
  end

  @doc """
  Use this method to send point on the map.
  On success, the sent Message is returned.
  """
  def send_location(chat_id, latitude, longitude, options \\ []) do
    request = binding |> build_request
    get_response("sendLocation", request)
  end

  @doc """
  Use this method when you need to tell the user that something is happening on
  the bot's side. The status is set for 5 seconds or less (when a message
  arrives from your bot, Telegram clients clear its typing status).
  """
  def send_chat_action(chat_id, action) do
    request = binding |> build_request
    get_response("sendChatAction", request)
  end

  @doc """
  Use this method to get a list of profile pictures for a user.
  Returns a UserProfilePhotos object.
  """
  def get_user_profile_photos(user_id, options \\ []) do
    request = binding |> build_request
    get_response("getUserProfilePhotos", request)
  end

  @doc """
  Use this method to receive incoming updates using long polling.
  An Array of Update objects is returned.
  """
  def get_updates(options \\ []) do
    request = binding |> build_request
    get_response("getUpdates", request)
  end

  @doc """
  Use this method to specify a url and receive incoming updates via an outgoing
  webhook. Whenever there is an update for the bot, we will send an HTTPS POST
  request to the specified url, containing a JSON-serialized Update. In case of
  an unsuccessful request, we will give up after a reasonable amount of attempts.
  """
  def set_webhook(options \\ []) do
    request = binding |> build_request
    get_response("setWebhook", request)
  end

end
