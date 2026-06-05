defmodule Nadia.API do
  @moduledoc """
  Provides basic functionalities for Telegram Bot API.
  """

  alias Nadia.Client
  alias Nadia.HTTPClient
  alias Nadia.HTTPRequest
  alias Nadia.HTTPResponse
  alias Nadia.Model.Error

  defp build_url(%Client{api_environment: :test} = client, method) do
    client.base_url <> client.token <> "/test/" <> method
  end

  defp build_url(%Client{} = client, method), do: client.base_url <> client.token <> "/" <> method

  defp process_response(response, method) do
    case decode_response(response) do
      {:ok, true} ->
        :ok

      {:ok, %{"ok" => false, "description" => description}} ->
        {:error, %Error{reason: description}}

      {:ok, result} ->
        {:ok, Nadia.Parser.parse_result(result, method)}

      {:error, error} ->
        {:error, %Error{reason: error}}
    end
  end

  defp decode_response(response) do
    with {:ok, %HTTPResponse{body: body}} <- response,
         {:ok, %{"result" => result}} <- Jason.decode(body),
         do: {:ok, result}
  end

  defp build_multipart_request(params, file_field) do
    file_field = to_string(file_field)
    {{_, file_path}, params} = List.keytake(params, file_field, 0)

    {:multipart,
     params ++
       [
         {:file, file_path,
          {"form-data", [{"name", to_string(file_field)}, {"filename", file_path}]}, []}
       ]}
  end

  defp calculate_timeout(%Client{} = client, options) when is_list(options) do
    (Keyword.get(options, :timeout, 0) + client.recv_timeout) * 1000
  end

  defp calculate_timeout(%Client{} = client, options) when is_map(options) do
    (Map.get(options, :timeout, 0) + client.recv_timeout) * 1000
  end

  defp build_request(params, file_field) when is_list(params) do
    params
    |> Keyword.update(:reply_markup, nil, &Jason.encode!(&1))
    |> map_params(file_field)
  end

  defp build_request(params, file_field) when is_map(params) do
    params
    |> Map.update(:reply_markup, nil, &Jason.encode!(&1))
    |> map_params(file_field)
  end

  defp map_params(params, file_field) do
    params =
      params
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.map(fn {k, v} -> {to_string(k), to_string(v)} end)

    file_path = file_path(params, file_field)

    if file_path && File.exists?(file_path) do
      build_multipart_request(params, file_field)
    else
      {:form, params}
    end
  end

  defp file_path(_params, nil), do: nil

  defp file_path(params, file_field) do
    case List.keyfind(params, to_string(file_field), 0) do
      {_, file_path} -> file_path
      nil -> nil
    end
  end

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
  * `options` - orddict of options
  * `file_field` - specify the key of file_field in `options` when sending files
  """
  @spec request(binary, [{atom, any}], atom) :: :ok | {:error, Error.t()} | {:ok, any}
  def request(method, options \\ [], file_field \\ nil) do
    request(Client.default(), method, options, file_field)
  end

  @spec request(Client.t(), binary, [{atom, any}] | map, atom | nil) ::
          :ok | {:error, Error.t()} | {:ok, any}
  def request(%Client{} = client, method, options, file_field) do
    %HTTPRequest{
      method: :post,
      url: build_url(client, method),
      body: build_request(options, file_field),
      headers: [],
      options: build_options(client, options)
    }
    |> then(&HTTPClient.post(client.http_client, &1))
    |> process_response(method)
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
