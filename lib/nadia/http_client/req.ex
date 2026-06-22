defmodule Nadia.HTTPClient.Req do
  @moduledoc false

  @behaviour Nadia.HTTPClient

  alias Nadia.HTTPRequest
  alias Nadia.HTTPResponse

  @req_passthrough_options [
    :adapter,
    :compressed,
    :connect_options,
    :decode_body,
    :decode_json,
    :finch,
    :finch_options,
    :http_errors,
    :into,
    :max_retries,
    :plug,
    :pool_timeout,
    :raw,
    :receive_timeout,
    :redirect,
    :request_timeout,
    :retry,
    :retry_delay,
    :retry_log_level
  ]

  @impl Nadia.HTTPClient
  def post(%HTTPRequest{} = request) do
    with :ok <- ensure_req(),
         {:ok, options} <- to_req_options(request) do
      try do
        case Req.request(options) do
          {:ok, response} ->
            {:ok, to_nadia_response(response)}

          {:error, %{__struct__: Req.TransportError, reason: reason}} ->
            {:error, reason}

          {:error, error} ->
            {:error, error}
        end
      rescue
        error in Nadia.InputFile.StreamError ->
          {:error, {:input_file, {:stream_error, error.message}}}
      end
    end
  end

  @doc false
  @spec to_req_options(HTTPRequest.t()) :: {:ok, keyword} | {:error, term}
  def to_req_options(%HTTPRequest{
        method: :post,
        url: url,
        body: body,
        headers: headers,
        options: options
      }) do
    with {:ok, http_options} <- translate_options(options),
         {:ok, body_options, headers} <- body_options(body, headers) do
      {:ok,
       [
         method: :post,
         url: url,
         headers: headers,
         decode_body: false,
         redirect: false,
         retry: false
       ]
       |> Keyword.merge(body_options)
       |> Keyword.merge(http_options)}
    end
  end

  defp body_options({:form, params}, headers), do: {:ok, [form: params], headers}

  defp body_options({:multipart, parts}, headers) do
    with {:ok, multipart} <- encode_multipart(parts) do
      headers =
        headers
        |> put_new_header("content-type", multipart.content_type)
        |> put_new_header("content-length", Integer.to_string(multipart.size))

      {:ok, [body: multipart.body], headers}
    end
  end

  defp body_options(nil, headers), do: {:ok, [], headers}
  defp body_options(body, headers), do: {:ok, [body: body], headers}

  defp encode_multipart(parts) do
    boundary = Base.encode16(:crypto.strong_rand_bytes(16), case: :lower)

    with {:ok, body, size} <- encode_multipart_parts(parts, boundary) do
      footer = [["--", boundary, "--\r\n"]]
      {body, size} = add_multipart_parts({body, size}, {footer, IO.iodata_length(footer)})

      {:ok,
       %{
         body: body,
         size: size,
         content_type: "multipart/form-data; boundary=#{boundary}"
       }}
    end
  end

  defp encode_multipart_parts(parts, boundary) do
    Enum.reduce_while(parts, {:ok, [], 0}, fn part, {:ok, body, size} ->
      case encode_multipart_part(part, boundary) do
        {:ok, part_body, part_size} ->
          {body, size} = add_multipart_parts({body, size}, {part_body, part_size})
          {:cont, {:ok, body, size}}

        {:error, reason} ->
          {:halt, {:error, reason}}
      end
    end)
  end

  defp encode_multipart_part({:file, source, {"form-data", disposition}, headers}, boundary) do
    name = disposition_value(disposition, "name")
    filename = disposition_value(disposition, "filename") || source_filename(source)

    with {:ok, body, body_size} <- multipart_source(source),
         {:ok, header} <- multipart_header(boundary, name, filename, headers) do
      closing = ["\r\n"]
      part_size = IO.iodata_length(header) + body_size + IO.iodata_length(closing)

      {part_body, _size} =
        add_multipart_parts({header, IO.iodata_length(header)}, {body, body_size})

      {part_body, _size} = add_multipart_parts({part_body, part_size - 2}, {closing, 2})
      {:ok, part_body, part_size}
    end
  end

  defp encode_multipart_part({name, value}, boundary) do
    name = to_string(name)
    value = to_string(value)

    with {:ok, header} <- multipart_header(boundary, name, nil, []) do
      closing = ["\r\n"]
      body = [header, value, closing]
      {:ok, body, IO.iodata_length(body)}
    end
  end

  defp multipart_source({:path, path, _declared_size}) do
    case File.stat(path) do
      {:ok, %File.Stat{type: :regular, size: size}} ->
        {:ok, File.stream!(path, 64 * 1024, []), size}

      {:ok, %File.Stat{}} ->
        {:error, {:input_file, {:not_regular, path}}}

      {:error, reason} ->
        {:error, {:input_file, {:file_error, path, reason}}}
    end
  end

  defp multipart_source({:bytes, bytes, size}), do: {:ok, bytes, size}

  defp multipart_source({:stream, stream, size}) do
    {:ok, verify_stream_size(stream, size), size}
  end

  defp multipart_source(path) when is_binary(path) do
    multipart_source({:path, path, nil})
  end

  defp multipart_source(_source), do: {:error, {:input_file, :invalid_source}}

  defp source_filename({:path, path, _size}), do: Path.basename(path)
  defp source_filename(path) when is_binary(path), do: Path.basename(path)
  defp source_filename(_source), do: "upload"

  defp multipart_header(boundary, name, filename, headers)
       when is_binary(name) and byte_size(name) > 0 do
    disposition = [
      "content-disposition: form-data; name=\"",
      escape_form_param(name),
      "\"",
      filename_param(filename),
      "\r\n"
    ]

    extra_headers =
      Enum.map(headers, fn {key, value} ->
        [escape_header_name(key), ": ", escape_form_param(value), "\r\n"]
      end)

    {:ok, [["--", boundary, "\r\n"], disposition, extra_headers, "\r\n"]}
  end

  defp multipart_header(_boundary, _name, _filename, _headers),
    do: {:error, {:input_file, :invalid_part_name}}

  defp filename_param(nil), do: []

  defp filename_param(filename) when is_binary(filename),
    do: ["; filename=\"", filename |> Path.basename() |> escape_form_param(), "\""]

  defp filename_param(_filename), do: []

  defp escape_header_name(name) do
    name
    |> to_string()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9-]/, "")
  end

  defp escape_form_param(value) when is_binary(value) do
    URI.encode(value, &(&1 not in [?\", ?\r, ?\n]))
  end

  defp verify_stream_size(stream, expected_size) do
    sentinel = make_ref()

    stream
    |> Stream.concat([sentinel])
    |> Stream.transform(0, fn
      ^sentinel, count ->
        if count != expected_size do
          raise Nadia.InputFile.StreamError,
                "multipart stream yielded #{count} bytes, expected #{expected_size} bytes"
        end

        {[], count}

      chunk, count ->
        size = stream_chunk_size(chunk)
        next_count = count + size

        if next_count > expected_size do
          raise Nadia.InputFile.StreamError,
                "multipart stream exceeded its declared size of #{expected_size} bytes"
        end

        {[chunk], next_count}
    end)
  end

  defp stream_chunk_size(chunk) do
    IO.iodata_length(chunk)
  rescue
    _error ->
      raise Nadia.InputFile.StreamError, "multipart stream yielded a non-iodata chunk"
  end

  defp add_multipart_parts({parts1, size1}, {parts2, size2})
       when is_list(parts1) and is_list(parts2) do
    {[parts1, parts2], size1 + size2}
  end

  defp add_multipart_parts({parts1, size1}, {parts2, size2}) do
    {Stream.concat(parts1, parts2), size1 + size2}
  end

  defp put_new_header(headers, name, value) do
    if Enum.any?(headers, fn {key, _value} -> String.downcase(to_string(key)) == name end) do
      headers
    else
      [{name, value} | headers]
    end
  end

  defp disposition_value(disposition, name) do
    Enum.find_value(disposition, fn
      {^name, value} -> value
      _ -> nil
    end)
  end

  defp translate_options(options) do
    Enum.reduce_while(options, {:ok, []}, fn {key, value}, {:ok, acc} ->
      case translate_option(key, value, acc) do
        {:ok, acc} -> {:cont, {:ok, acc}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp translate_option(:recv_timeout, timeout, acc) do
    {:ok, Keyword.put(acc, :receive_timeout, timeout)}
  end

  defp translate_option(:proxy, proxy, acc) do
    with {:ok, proxy} <- normalize_proxy(proxy) do
      {:ok, put_connect_option(acc, :proxy, proxy)}
    end
  end

  defp translate_option(:proxy_auth, {user, pass}, acc) do
    header = {"proxy-authorization", "Basic " <> Base.encode64("#{user}:#{pass}")}

    {:ok, put_connect_option(acc, :proxy_headers, [header])}
  end

  defp translate_option(:socks5_user, _user, _acc) do
    {:error, {:unsupported_option, :socks5_user}}
  end

  defp translate_option(:socks5_pass, _pass, _acc) do
    {:error, {:unsupported_option, :socks5_pass}}
  end

  defp translate_option(key, value, acc) when key in @req_passthrough_options do
    {:ok, Keyword.put(acc, key, value)}
  end

  defp translate_option(_key, _value, acc), do: {:ok, acc}

  defp normalize_proxy(proxy) when is_binary(proxy) do
    proxy
    |> proxy_uri()
    |> proxy_from_uri(proxy)
  end

  defp normalize_proxy({scheme, host, port})
       when scheme in [:http, :https] and is_integer(port) do
    {:ok, {scheme, to_string(host), port, []}}
  end

  defp normalize_proxy({scheme, host, port, options})
       when scheme in [:http, :https] and is_integer(port) and is_list(options) do
    {:ok, {scheme, to_string(host), port, options}}
  end

  defp normalize_proxy(proxy), do: {:error, {:unsupported_proxy, proxy}}

  defp proxy_uri(proxy) do
    uri = URI.parse(proxy)

    if uri.scheme in ["http", "https"] and is_binary(uri.host) do
      uri
    else
      URI.parse("http://" <> proxy)
    end
  end

  defp proxy_from_uri(%URI{scheme: scheme, host: host, port: port}, original)
       when scheme in ["http", "https"] and is_binary(host) do
    {:ok, {proxy_scheme(scheme), host, port || default_proxy_port(scheme), []}}
  rescue
    _ -> {:error, {:unsupported_proxy, original}}
  end

  defp proxy_from_uri(_uri, original), do: {:error, {:unsupported_proxy, original}}

  defp default_proxy_port("http"), do: 80
  defp default_proxy_port("https"), do: 443

  defp proxy_scheme("http"), do: :http
  defp proxy_scheme("https"), do: :https

  defp put_connect_option(options, key, value) do
    Keyword.update(options, :connect_options, [{key, value}], &Keyword.put(&1, key, value))
  end

  defp ensure_req do
    if Code.ensure_loaded?(Req) do
      :ok
    else
      {:error, {:missing_dependency, :req}}
    end
  end

  defp to_nadia_response(%{__struct__: Req.Response} = response) do
    %HTTPResponse{
      status_code: response.status,
      body: response.body,
      headers: Req.get_headers_list(response)
    }
  end
end
