defmodule Nadia do

  @base_url "https://api.telegram.org/bot"

  defp token, do: Application.get_env(:nadia, :token)

  defp build_url(method), do: @base_url <> token <> "/" <> method

  defp process_response(response) do
    case response do
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
      {:ok, %HTTPoison.Response{status_code: 403}} -> {:error, "token invalid"}
      {:ok, %HTTPoison.Response{body: body}} ->
        case body |> Poison.decode! |> Dict.pop("ok") do
          {true, data} -> {:ok, data}
          {_, data} -> {:error, data}
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
    params = Enum.map(required ++ optional, fn {k, v} -> {k, to_string(v)} end)
    if !is_nil(file_field) and File.exists?(params[file_field]) do
      build_multipart_request(params, file_field)
    else
      {:form, params}
    end
  end

  def get_me do
    "getMe" |> get_response
  end

  def send_message(chat_id, text, options \\ []) do
    request = binding |> build_request
    get_response("sendMessage", request)
  end

  def forward_message(chat_id, from_chat_id, message_id) do
    request = binding |> build_request
    get_response("forwardMessage", request)
  end

  def send_photo(chat_id, photo, options \\ []) do
    request = binding |> build_request(:photo)
    get_response("sendPhoto", request)
  end

  def send_audio(chat_id, audio, options \\ []) do
    request = binding |> build_request(:audio)
    get_response("sendAudio", request)
  end

  def send_document(chat_id, document, options \\ []) do
    request = binding |> build_request(:document)
    get_response("sendDocument", request)
  end

  def send_sticker(chat_id, sticker, options \\ []) do
    request = binding |> build_request(:sticker)
    get_response("sendSticker", request)
  end

  def send_video(chat_id, video, options \\ []) do
    request = binding |> build_request(:video)
    get_response("sendVideo", request)
  end

  def send_voice(chat_id, voice, options \\ []) do
    request = binding |> build_request(:voice)
    get_response("sendVoice", request)
  end

  def send_location(chat_id, latitude, longitude, options \\ []) do
    request = binding |> build_request
    get_response("sendLocation", request)
  end

  def send_chat_action(chat_id, action) do
    request = binding |> build_request
    get_response("sendChatAction", request)
  end

  def get_user_profile_photos(user_id, options \\ []) do
    request = binding |> build_request
    get_response("getUserProfilePhotos", request)
  end

  def get_updates(options \\ []) do
    request = binding |> build_request
    get_response("getUpdates", request)
  end

  def set_webhook(options \\ []) do
    request = binding |> build_request
    get_response("setWebhook", request)
  end

end
