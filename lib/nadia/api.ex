defmodule Nadia.API do
  @moduledoc """
  Provides basic functionalities for Telegram Bot API.
  """

  alias Nadia.Model.Error

  @default_timeout 5
  @base_url "https://api.telegram.org/bot"

  defp token, do: config_or_env(:token)
  defp recv_timeout, do: config_or_env(:recv_timeout) || @default_timeout

  defp config_or_env(key) do
    case Application.fetch_env(:nadia, key) do
      {:ok, {:system, var}} -> System.get_env(var)
      {:ok, {:system, var, default}} ->
        case System.get_env(var) do
          nil -> default
          val -> val
        end
      {:ok, value} -> value
      :error -> nil
    end
  end

  defp build_url(method), do: @base_url <> token() <> "/" <> method

  defp process_response(response, method) do
    case decode_response(response) do
      {:ok, true} -> :ok
      {:ok, result} -> {:ok, Nadia.Parser.parse_result(result, method)}
      %{ok: false, description: description} -> {:error, %Error{reason: description}}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, %Error{reason: reason}}
    end
  end

  defp decode_response(response) do
    with {:ok, %HTTPoison.Response{body: body}} <- response,
          %{result: result} <- Poison.decode!(body, keys: :atoms),
      do: {:ok, result}
  end

  defp build_multipart_request(params, file_field) do
    {file_path, params} = Keyword.pop(params, file_field)
    params = for {k, v} <- params, do: {to_string(k), v}
    {:multipart, params ++ [
      {:file, file_path,
       {"form-data", [{"name", to_string(file_field)}, {"filename", file_path}]}, []}
    ]}
  end

  defp build_request(params, file_field) do
    params = params
    |> Keyword.update(:reply_markup, nil, &(Poison.encode!(&1)))
    |> Enum.filter_map(fn {_, v} -> v end, fn {k, v} -> {k, to_string(v)} end)
    if !is_nil(file_field) and File.exists?(params[file_field]) do
      build_multipart_request(params, file_field)
    else
      {:form, params}
    end
  end

  defp build_options(options) do
    timeout = (Keyword.get(options, :timeout, 0) + recv_timeout()) * 1000
    opts = [recv_timeout: timeout]

    case config_or_env(:proxy) do
      proxy when byte_size(proxy) > 0 -> Keyword.put(opts, :proxy, proxy)
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
  def request(method, options \\ [], file_field \\ nil) do
    method
    |> build_url
    |> HTTPoison.post(build_request(options, file_field), [], build_options(options))
    |> process_response(method)
  end
end
