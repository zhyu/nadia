defmodule Nadia.API do
  @moduledoc """
  Provides basic functionalities for Telegram Bot API.
  """

  alias Nadia.Client
  alias Nadia.HTTPClient
  alias Nadia.HTTPRequest
  alias Nadia.HTTPResponse
  alias Nadia.InputFile
  alias Nadia.InputFile.JSONPayload
  alias Nadia.Model.Error

  defp build_url(%Client{api_environment: :test} = client, method) do
    client.base_url <> client.token <> "/test/" <> method
  end

  defp build_url(%Client{} = client, method), do: client.base_url <> client.token <> "/" <> method

  defp validate_request(%Client{} = client, options) do
    with :ok <- validate_token(client.token),
         :ok <- validate_options(options) do
      :ok
    end
  end

  defp validate_token(token) when is_binary(token) and byte_size(token) > 0, do: :ok
  defp validate_token(_token), do: {:error, :missing_token}

  defp validate_options(options) when is_map(options), do: :ok

  defp validate_options(options) when is_list(options) do
    if Enum.all?(options, &match?({_key, _value}, &1)) do
      :ok
    else
      {:error, :invalid_options}
    end
  end

  defp validate_options(_options), do: {:error, :invalid_options}

  defp process_response(response, method) do
    case decode_response(response) do
      {:ok, true} ->
        :ok

      {:telegram_error, error_response} ->
        {:error, parse_telegram_error(error_response)}

      {:ok, result} ->
        {:ok, Nadia.Parser.parse_result(result, method)}

      {:error, error} ->
        {:error, %Error{reason: error}}
    end
  end

  defp decode_response({:ok, %HTTPResponse{body: body}}) do
    with {:ok, decoded} <- Jason.decode(body) do
      case decoded do
        %{"ok" => true, "result" => result} -> {:ok, result}
        %{"ok" => false} = error_response -> {:telegram_error, error_response}
        _other -> {:error, :invalid_response}
      end
    end
  end

  defp decode_response({:error, reason}), do: {:error, reason}

  defp parse_telegram_error(error_response) do
    %Error{
      reason: telegram_error_reason(error_response),
      error_code: integer_value(error_response["error_code"]),
      parameters: parse_error_parameters(error_response["parameters"])
    }
  end

  defp telegram_error_reason(%{"description" => description}) when is_binary(description),
    do: description

  defp telegram_error_reason(_error_response), do: :invalid_response

  defp parse_error_parameters(%{} = parameters),
    do: Nadia.Parser.parse_response_parameters(parameters)

  defp parse_error_parameters(_parameters), do: nil

  defp integer_value(value) when is_integer(value), do: value
  defp integer_value(_value), do: nil

  defp calculate_timeout(%Client{} = client, options) when is_list(options) do
    (Keyword.get(options, :timeout, 0) + client.recv_timeout) * 1000
  end

  defp calculate_timeout(%Client{} = client, options) when is_map(options) do
    (Map.get(options, :timeout, 0) + client.recv_timeout) * 1000
  end

  defp build_request(params, file_field) when is_list(params) do
    params
    |> Keyword.update(:reply_markup, nil, &encode_json_param/1)
    |> normalize_params(file_field)
  end

  defp build_request(params, file_field) when is_map(params) do
    params
    |> Map.update(:reply_markup, nil, &encode_json_param/1)
    |> normalize_params(file_field)
  end

  defp encode_json_param(nil), do: nil
  defp encode_json_param(value), do: Jason.encode!(value)

  defp normalize_params(params, file_field) do
    entries = Enum.reject(params, fn {_key, value} -> is_nil(value) end)
    field_names = entries |> Enum.map(fn {key, _value} -> to_string(key) end) |> MapSet.new()

    state = %{
      parts: [],
      used_names: collect_entry_attach_names(entries, field_names),
      next_name: 0
    }

    entries
    |> Enum.reduce_while({:ok, [], state}, fn {key, value}, {:ok, normalized, state} ->
      key = to_string(key)

      case normalize_param(key, value, file_field, state) do
        {:ok, :file_part, state} -> {:cont, {:ok, normalized, state}}
        {:ok, value, state} -> {:cont, {:ok, [{key, value} | normalized], state}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, normalized, %{parts: []}} ->
        {:ok, {:form, Enum.reverse(normalized)}}

      {:ok, normalized, state} ->
        {:ok, {:multipart, Enum.reverse(normalized) ++ Enum.reverse(state.parts)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp normalize_param(_key, %JSONPayload{value: value}, _file_field, state) do
    with {:ok, value, state} <- normalize_json_value(value, state) do
      {:ok, Jason.encode!(value), state}
    end
  end

  defp normalize_param(key, %InputFile{} = input_file, _file_field, state) do
    normalize_top_level_input_file(key, input_file, state)
  end

  defp normalize_param(key, value, file_field, state)
       when is_binary(value) and not is_nil(file_field) do
    if key == to_string(file_field) do
      normalize_legacy_file(key, value, state)
    else
      {:ok, value, state}
    end
  end

  defp normalize_param(_key, value, _file_field, state), do: {:ok, to_string(value), state}

  defp normalize_legacy_file(key, path_or_reference, state) do
    case File.stat(path_or_reference) do
      {:ok, %File.Stat{type: :regular}} ->
        with :ok <- validate_readable(path_or_reference) do
          part = file_part(key, path_or_reference, path_or_reference, [])
          {:ok, :file_part, %{state | parts: [part | state.parts]}}
        else
          {:error, reason} -> {:error, {:input_file, reason}}
        end

      {:ok, %File.Stat{}} ->
        {:error, {:input_file, {:not_regular, path_or_reference}}}

      {:error, _reason} ->
        {:ok, path_or_reference, state}
    end
  end

  defp normalize_top_level_input_file(key, input_file, state) do
    case normalize_input_file(input_file) do
      {:ok, {:reference, value}} ->
        {:ok, value, state}

      {:ok, {:upload, source, filename, headers}} ->
        part = file_part(key, source, filename, headers)
        {:ok, :file_part, %{state | parts: [part | state.parts]}}

      {:error, reason} ->
        {:error, {:input_file, reason}}
    end
  end

  defp normalize_json_value(%InputFile{} = input_file, state) do
    case normalize_input_file(input_file) do
      {:ok, {:reference, value}} ->
        {:ok, value, state}

      {:ok, {:upload, source, filename, headers}} ->
        with {:ok, name, state} <- allocate_attachment_name(input_file.attach_name, state) do
          part = file_part(name, source, filename, headers)
          {:ok, "attach://" <> name, %{state | parts: [part | state.parts]}}
        end

      {:error, reason} ->
        {:error, {:input_file, reason}}
    end
  end

  defp normalize_json_value(%Nadia.InputContactMessageContent{} = input_content, state) do
    case Nadia.InputContactMessageContent.to_map(input_content) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:input_contact_message_content, reason}}
    end
  end

  defp normalize_json_value(%Nadia.InputInvoiceMessageContent{} = input_content, state) do
    case Nadia.InputInvoiceMessageContent.to_map(input_content) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:input_invoice_message_content, reason}}
    end
  end

  defp normalize_json_value(%Nadia.InputLocationMessageContent{} = input_content, state) do
    case Nadia.InputLocationMessageContent.to_map(input_content) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:input_location_message_content, reason}}
    end
  end

  defp normalize_json_value(%Nadia.InputMedia{} = input_media, state) do
    case Nadia.InputMedia.to_map(input_media) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:input_media, reason}}
    end
  end

  defp normalize_json_value(%Nadia.InputPaidMedia{} = input_paid_media, state) do
    case Nadia.InputPaidMedia.to_map(input_paid_media) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:input_paid_media, reason}}
    end
  end

  defp normalize_json_value(%Nadia.InputPollOption{} = input_poll_option, state) do
    case Nadia.InputPollOption.to_map(input_poll_option) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:input_poll_option, reason}}
    end
  end

  defp normalize_json_value(%Nadia.InputPollMedia{} = input_poll_media, state) do
    case Nadia.InputPollMedia.to_map(input_poll_media) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:input_poll_media, reason}}
    end
  end

  defp normalize_json_value(%Nadia.InputProfilePhoto{} = input_profile_photo, state) do
    case Nadia.InputProfilePhoto.to_map(input_profile_photo) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:input_profile_photo, reason}}
    end
  end

  defp normalize_json_value(%Nadia.InputRichMessage{} = input_rich_message, state) do
    case Nadia.InputRichMessage.to_map(input_rich_message) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:input_rich_message, reason}}
    end
  end

  defp normalize_json_value(
         %Nadia.InputRichMessageContent{} = input_rich_message_content,
         state
       ) do
    case Nadia.InputRichMessageContent.to_map(input_rich_message_content) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:input_rich_message_content, reason}}
    end
  end

  defp normalize_json_value(%Nadia.InputTextMessageContent{} = input_content, state) do
    case Nadia.InputTextMessageContent.to_map(input_content) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:input_text_message_content, reason}}
    end
  end

  defp normalize_json_value(%Nadia.InputVenueMessageContent{} = input_content, state) do
    case Nadia.InputVenueMessageContent.to_map(input_content) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:input_venue_message_content, reason}}
    end
  end

  defp normalize_json_value(%Nadia.LabeledPrice{} = labeled_price, state) do
    case Nadia.LabeledPrice.to_map(labeled_price) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:labeled_price, reason}}
    end
  end

  defp normalize_json_value(%Nadia.ReactionType{} = reaction_type, state) do
    case Nadia.ReactionType.to_map(reaction_type) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:reaction_type, reason}}
    end
  end

  defp normalize_json_value(%Nadia.InputSticker{} = input_sticker, state) do
    case Nadia.InputSticker.to_map(input_sticker) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:input_sticker, reason}}
    end
  end

  defp normalize_json_value(%Nadia.StoryArea{} = story_area, state) do
    case Nadia.StoryArea.to_map(story_area) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:story_area, reason}}
    end
  end

  defp normalize_json_value(%Nadia.InputStoryContent{} = input_story_content, state) do
    case Nadia.InputStoryContent.to_map(input_story_content) do
      {:ok, value} -> normalize_json_value(value, state)
      {:error, reason} -> {:error, {:input_story_content, reason}}
    end
  end

  defp normalize_json_value(value, state) when is_list(value) do
    value
    |> Enum.reduce_while({:ok, [], state}, fn item, {:ok, normalized, state} ->
      case normalize_json_value(item, state) do
        {:ok, item, state} -> {:cont, {:ok, [item | normalized], state}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, normalized, state} -> {:ok, Enum.reverse(normalized), state}
      error -> error
    end
  end

  defp normalize_json_value(value, state) when is_map(value) do
    value
    |> Enum.reduce_while({:ok, %{}, state}, fn {key, item}, {:ok, normalized, state} ->
      case normalize_json_value(item, state) do
        {:ok, item, state} -> {:cont, {:ok, Map.put(normalized, key, item), state}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp normalize_json_value(value, state), do: {:ok, value, state}

  defp normalize_input_file(%InputFile{source: {:file_id, file_id}})
       when is_binary(file_id) and byte_size(file_id) > 0 do
    {:ok, {:reference, file_id}}
  end

  defp normalize_input_file(%InputFile{source: {:url, url}}) when is_binary(url) do
    case URI.parse(url) do
      %URI{scheme: scheme, host: host}
      when scheme in ["http", "https"] and is_binary(host) and byte_size(host) > 0 ->
        {:ok, {:reference, url}}

      _other ->
        {:error, {:invalid_url, url}}
    end
  end

  defp normalize_input_file(%InputFile{source: {:path, path}} = input_file)
       when is_binary(path) do
    with {:ok, %File.Stat{type: :regular, size: size}} <- stat_regular_file(path),
         :ok <- validate_max_bytes(input_file.max_bytes, size),
         :ok <- validate_readable(path),
         {:ok, filename} <- validate_filename(input_file.filename || Path.basename(path)),
         {:ok, headers} <- input_file_headers(input_file.content_type) do
      {:ok, {:upload, path, filename, headers}}
    end
  end

  defp normalize_input_file(%InputFile{source: {:bytes, bytes}} = input_file) do
    with {:ok, size} <- iodata_size(bytes),
         :ok <- validate_max_bytes(input_file.max_bytes, size),
         {:ok, filename} <- validate_filename(input_file.filename),
         {:ok, headers} <- input_file_headers(input_file.content_type) do
      {:ok, {:upload, {:bytes, bytes, size}, filename, headers}}
    end
  end

  defp normalize_input_file(%InputFile{source: {:stream, stream}, size: size} = input_file) do
    with :ok <- validate_stream(stream, size),
         :ok <- validate_max_bytes(input_file.max_bytes, size),
         {:ok, filename} <- validate_filename(input_file.filename),
         {:ok, headers} <- input_file_headers(input_file.content_type) do
      {:ok, {:upload, {:stream, stream, size}, filename, headers}}
    end
  end

  defp normalize_input_file(%InputFile{}), do: {:error, :invalid_source}

  defp stat_regular_file(path) do
    case File.stat(path) do
      {:ok, %File.Stat{type: :regular} = stat} -> {:ok, stat}
      {:ok, %File.Stat{}} -> {:error, {:not_regular, path}}
      {:error, reason} -> {:error, {:file_error, path, reason}}
    end
  end

  defp validate_readable(path) do
    case File.open(path, [:read]) do
      {:ok, device} -> File.close(device)
      {:error, reason} -> {:error, {:file_error, path, reason}}
    end
  end

  defp iodata_size(bytes) do
    {:ok, IO.iodata_length(bytes)}
  rescue
    _error -> {:error, :invalid_iodata}
  end

  defp validate_stream(stream, size) when is_integer(size) and size >= 0 do
    if Enumerable.impl_for(stream), do: :ok, else: {:error, :invalid_stream}
  end

  defp validate_stream(_stream, _size), do: {:error, :stream_size_required}

  defp validate_max_bytes(nil, _size), do: :ok

  defp validate_max_bytes(max_bytes, size)
       when is_integer(max_bytes) and max_bytes >= 0 and size <= max_bytes,
       do: :ok

  defp validate_max_bytes(max_bytes, size) when is_integer(max_bytes) and max_bytes >= 0,
    do: {:error, {:too_large, size, max_bytes}}

  defp validate_max_bytes(_max_bytes, _size), do: {:error, :invalid_max_bytes}

  defp validate_filename(filename) when is_binary(filename) and byte_size(filename) > 0,
    do: {:ok, Path.basename(filename)}

  defp validate_filename(_filename), do: {:error, :invalid_filename}

  defp input_file_headers(nil), do: {:ok, []}

  defp input_file_headers(content_type)
       when is_binary(content_type) and byte_size(content_type) > 0 do
    if String.contains?(content_type, ["\r", "\n"]) do
      {:error, :invalid_content_type}
    else
      {:ok, [{"content-type", content_type}]}
    end
  end

  defp input_file_headers(_content_type), do: {:error, :invalid_content_type}

  defp file_part(name, source, filename, headers) do
    {:file, source, {"form-data", [{"name", name}, {"filename", filename}]}, headers}
  end

  defp allocate_attachment_name(nil, state), do: allocate_generated_name(state)

  defp allocate_attachment_name(name, state) when is_binary(name) do
    if Regex.match?(~r/\A[A-Za-z0-9_-]+\z/, name) do
      allocated = unique_name(name, state.used_names, 1)
      {:ok, allocated, %{state | used_names: MapSet.put(state.used_names, allocated)}}
    else
      {:error, {:invalid_attach_name, name}}
    end
  end

  defp allocate_attachment_name(name, _state), do: {:error, {:invalid_attach_name, name}}

  defp allocate_generated_name(state) do
    name = "nadia_file_#{state.next_name}"

    if MapSet.member?(state.used_names, name) do
      allocate_generated_name(%{state | next_name: state.next_name + 1})
    else
      {:ok, name,
       %{
         state
         | used_names: MapSet.put(state.used_names, name),
           next_name: state.next_name + 1
       }}
    end
  end

  defp unique_name(name, used_names, suffix) do
    cond do
      not MapSet.member?(used_names, name) -> name
      not MapSet.member?(used_names, "#{name}_#{suffix}") -> "#{name}_#{suffix}"
      true -> unique_name(name, used_names, suffix + 1)
    end
  end

  defp collect_entry_attach_names(entries, names) do
    Enum.reduce(entries, names, fn {_key, value}, names -> collect_attach_names(value, names) end)
  end

  defp collect_attach_names(%JSONPayload{value: value}, names),
    do: collect_attach_names(value, names)

  defp collect_attach_names(%Nadia.InputContactMessageContent{}, names), do: names
  defp collect_attach_names(%Nadia.InputInvoiceMessageContent{}, names), do: names
  defp collect_attach_names(%Nadia.InputLocationMessageContent{}, names), do: names
  defp collect_attach_names(%Nadia.InputTextMessageContent{}, names), do: names
  defp collect_attach_names(%Nadia.InputVenueMessageContent{}, names), do: names
  defp collect_attach_names(%Nadia.LabeledPrice{}, names), do: names

  defp collect_attach_names(%Nadia.InputMedia{} = value, names) do
    case Nadia.InputMedia.to_map(value) do
      {:ok, value} -> collect_attach_names(value, names)
      {:error, _reason} -> names
    end
  end

  defp collect_attach_names(%Nadia.InputPaidMedia{} = value, names) do
    case Nadia.InputPaidMedia.to_map(value) do
      {:ok, value} -> collect_attach_names(value, names)
      {:error, _reason} -> names
    end
  end

  defp collect_attach_names(%Nadia.InputPollOption{} = value, names) do
    case Nadia.InputPollOption.to_map(value) do
      {:ok, value} -> collect_attach_names(value, names)
      {:error, _reason} -> names
    end
  end

  defp collect_attach_names(%Nadia.InputPollMedia{} = value, names) do
    case Nadia.InputPollMedia.to_map(value) do
      {:ok, value} -> collect_attach_names(value, names)
      {:error, _reason} -> names
    end
  end

  defp collect_attach_names(%Nadia.InputProfilePhoto{} = value, names) do
    case Nadia.InputProfilePhoto.to_map(value) do
      {:ok, value} -> collect_attach_names(value, names)
      {:error, _reason} -> names
    end
  end

  defp collect_attach_names(%Nadia.InputRichMessage{} = value, names) do
    case Nadia.InputRichMessage.to_map(value) do
      {:ok, value} -> collect_attach_names(value, names)
      {:error, _reason} -> names
    end
  end

  defp collect_attach_names(%Nadia.InputRichMessageContent{} = value, names) do
    case Nadia.InputRichMessageContent.to_map(value) do
      {:ok, value} -> collect_attach_names(value, names)
      {:error, _reason} -> names
    end
  end

  defp collect_attach_names(%Nadia.ReactionType{} = value, names) do
    case Nadia.ReactionType.to_map(value) do
      {:ok, value} -> collect_attach_names(value, names)
      {:error, _reason} -> names
    end
  end

  defp collect_attach_names(%Nadia.InputSticker{} = value, names) do
    case Nadia.InputSticker.to_map(value) do
      {:ok, value} -> collect_attach_names(value, names)
      {:error, _reason} -> names
    end
  end

  defp collect_attach_names(%Nadia.StoryArea{} = value, names) do
    case Nadia.StoryArea.to_map(value) do
      {:ok, value} -> collect_attach_names(value, names)
      {:error, _reason} -> names
    end
  end

  defp collect_attach_names(%Nadia.InputStoryContent{} = value, names) do
    case Nadia.InputStoryContent.to_map(value) do
      {:ok, value} -> collect_attach_names(value, names)
      {:error, _reason} -> names
    end
  end

  defp collect_attach_names(%InputFile{}, names), do: names

  defp collect_attach_names("attach://" <> name, names), do: MapSet.put(names, name)

  defp collect_attach_names(value, names) when is_list(value),
    do: Enum.reduce(value, names, &collect_attach_names/2)

  defp collect_attach_names(value, names) when is_map(value),
    do: Enum.reduce(value, names, fn {_key, item}, names -> collect_attach_names(item, names) end)

  defp collect_attach_names(_value, names), do: names

  defp build_options(%Client{} = client, options) do
    timeout = calculate_timeout(client, options)
    opts = [recv_timeout: timeout]

    opts =
      case client.proxy do
        proxy when byte_size(proxy) > 0 -> Keyword.put(opts, :proxy, proxy)
        proxy when is_tuple(proxy) and tuple_size(proxy) == 3 -> Keyword.put(opts, :proxy, proxy)
        _ -> opts
      end

    opts =
      case client.proxy_auth do
        proxy_auth when is_tuple(proxy_auth) and tuple_size(proxy_auth) == 2 ->
          Keyword.put(opts, :proxy_auth, proxy_auth)

        _ ->
          opts
      end

    opts
  end

  @doc """
  Generic method to call Telegram Bot API.

  Args:
  * `method` - name of API method
  * `options` - keyword list of options
  * `file_field` - legacy binary field whose existing local path should be uploaded

  Explicit `Nadia.InputFile` values are discovered in every top-level option
  and in Nadia's structured JSON media payloads.
  """
  @spec request(binary, [{atom, any}], atom) :: :ok | {:error, Error.t()} | {:ok, any}
  def request(method, options \\ [], file_field \\ nil) do
    request(Client.default(), method, options, file_field)
  end

  @spec request(Client.t(), binary, [{atom, any}] | map, atom | nil) ::
          :ok | {:error, Error.t()} | {:ok, any}
  def request(%Client{} = client, method, options, file_field) do
    with :ok <- validate_request(client, options),
         {:ok, body} <- build_request(options, file_field) do
      %HTTPRequest{
        method: :post,
        url: build_url(client, method),
        body: body,
        headers: [],
        options: build_options(client, options)
      }
      |> then(&HTTPClient.post(client.http_client, &1))
      |> process_response(method)
    else
      {:error, reason} ->
        {:error, %Error{reason: reason}}
    end
  end

  def request?(method, options \\ [], file_field \\ nil) do
    {_, response} = request(method, options, file_field)
    response
  end

  def request?(%Client{} = client, method, options, file_field) do
    {_, response} = request(client, method, options, file_field)
    response
  end

  @doc ~S"""
  Use this function to build file url.

  iex> Nadia.API.build_file_url("document/file_10")
  "https://api.telegram.org/file/bot#{Nadia.Config.token()}/document/file_10"
  """
  @spec build_file_url(binary) :: binary
  def build_file_url(file_path) do
    build_file_url(Client.default(), file_path)
  end

  @spec build_file_url(Client.t(), binary) :: binary
  def build_file_url(%Client{} = client, file_path) do
    client.file_base_url <> client.token <> "/" <> file_path
  end
end
