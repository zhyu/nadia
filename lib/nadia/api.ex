defmodule Nadia.API do
  @moduledoc """
  Provides basic functionalities for Telegram Bot API.
  """

  alias Nadia.Model.Error
  alias Nadia.Config

  defp build_url(method), do: Config.base_url() <> Config.token() <> "/" <> method

  defp process_response(response, method) do
    case decode_response(response) do
      {:ok, true} -> :ok
      {:ok, %{ok: false, description: description}} -> {:error, %Error{reason: description}}
      {:ok, result} -> {:ok, Nadia.Parser.parse_result(result, method)}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, %Error{reason: reason}}
      {:error, error} -> {:error, %Error{reason: error}}
    end
  end

  defp decode_response(response) do
    with {:ok, %HTTPoison.Response{body: body}} <- response,
         {:ok, %{result: result}} <- Poison.decode(body, keys: :atoms),
         do: {:ok, result}
  end

  defp build_multipart_request(params, file_field) do
    {file_path, params} = Keyword.pop(params, file_field)
    params = for {k, v} <- params, do: {to_string(k), v}

    {:multipart,
     params ++
       [
         {:file, file_path,
          {"form-data", [{"name", to_string(file_field)}, {"filename", file_path}]}, []}
       ]}
  end

  defp calculate_timeout(options) when is_list(options) do
    (Keyword.get(options, :timeout, 0) + Config.recv_timeout()) * 1000
  end

  defp calculate_timeout(options) when is_map(options) do
    (Map.get(options, :timeout, 0) + Config.recv_timeout()) * 1000
  end

  defp build_request(params, file_field) when is_list(params) do
    params
    |> Keyword.update(:reply_markup, nil, &Poison.encode!(&1))
    |> map_params(file_field)
  end

  defp build_request(params, file_field) when is_map(params) do
    params
    |> Map.update(:reply_markup, nil, &Poison.encode!(&1))
    |> map_params(file_field)
  end

  defp map_params(params, file_field) do
    params =
      params
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.map(fn {k, v} -> {k, to_string(v)} end)

    if !is_nil(file_field) and File.exists?(params[file_field]) do
      build_multipart_request(params, file_field)
    else
      {:form, params}
    end
  end

  defp build_options(options) do
    timeout = calculate_timeout(options)
    opts = [recv_timeout: timeout]

    opts =
      case Config.proxy() do
        proxy when byte_size(proxy) > 0 -> Keyword.put(opts, :proxy, proxy)
        proxy when is_tuple(proxy) and tuple_size(proxy) == 3 -> Keyword.put(opts, :proxy, proxy)
        _ -> opts
      end

    opts =
      case Config.proxy_auth() do
        proxy_auth when is_tuple(proxy_auth) and tuple_size(proxy_auth) == 2 ->
          Keyword.put(opts, :proxy_auth, proxy_auth)

        _ ->
          opts
      end

    opts =
      case Config.socks5_user() do
        socks5_user when byte_size(socks5_user) > 0 ->
          Keyword.put(opts, :socks5_user, socks5_user)

        _ ->
          opts
      end

    case Config.socks5_pass() do
      socks5_pass when byte_size(socks5_pass) > 0 -> Keyword.put(opts, :socks5_pass, socks5_pass)
      _ -> opts
    end
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
    method
    |> build_url
    |> HTTPoison.post(build_request(options, file_field), [], build_options(options))
    |> process_response(method)
  end

  def request?(method, options \\ [], file_field \\ nil) do
    {_, response} = request(method, options, file_field)
    response
  end

  @doc ~S"""
  Use this function to build file url.

  iex> Nadia.API.build_file_url("document/file_10")
  "https://api.telegram.org/file/bot#{Nadia.Config.token()}/document/file_10"
  """
  @spec build_file_url(binary) :: binary
  def build_file_url(file_path) do
    Config.file_base_url() <> Config.token() <> "/" <> file_path
  end
end
