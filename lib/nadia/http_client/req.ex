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
      case Req.request(options) do
        {:ok, response} ->
          {:ok, to_nadia_response(response)}

        {:error, %{__struct__: Req.TransportError, reason: reason}} ->
          {:error, reason}

        {:error, error} ->
          {:error, error}
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
    with {:ok, http_options} <- translate_options(options) do
      {:ok,
       [
         method: :post,
         url: url,
         headers: headers,
         decode_body: false,
         redirect: false,
         retry: false
       ]
       |> Keyword.merge(body_options(body))
       |> Keyword.merge(http_options)}
    end
  end

  defp body_options({:form, params}), do: [form: params]

  defp body_options({:multipart, parts}) do
    [form_multipart: Enum.map(parts, &multipart_part/1)]
  end

  defp body_options(nil), do: []
  defp body_options(body), do: [body: body]

  defp multipart_part({:file, file_path, {"form-data", disposition}, _headers}) do
    name = disposition_value(disposition, "name")
    filename = disposition_value(disposition, "filename") || Path.basename(file_path)

    {multipart_name(name), {File.stream!(file_path), filename: filename}}
  end

  defp multipart_part({name, value}), do: {multipart_name(name), value}

  defp multipart_name(name) when is_atom(name), do: name
  defp multipart_name(name) when is_binary(name), do: String.to_atom(name)

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
    {:ok, {String.to_atom(scheme), host, port || default_proxy_port(scheme), []}}
  rescue
    _ -> {:error, {:unsupported_proxy, original}}
  end

  defp proxy_from_uri(_uri, original), do: {:error, {:unsupported_proxy, original}}

  defp default_proxy_port("http"), do: 80
  defp default_proxy_port("https"), do: 443

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
