defmodule Nadia.API do
  @moduledoc """
  Provides basic functionalities for Telegram Bot API.
  """

  alias Nadia.Model.Error

  @default_timeout 5
  @base_url "https://api.telegram.org/bot"

  defp token, do: Application.get_env(:nadia, :token)
  defp opt_recv_timeout, do: Application.get_env(:nadia, :recv_timeout)

  defp build_url(method), do: @base_url <> token <> "/" <> method

  defp process_response(response, method) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Poison.decode!(body, keys: :atoms) do
          %{ok: false, description: description} -> {:error, %Error{reason: description}}
          %{result: true} -> :ok
          %{result: result} -> {:ok, Nadia.Parser.parse_result(result, method)}
        end
      {:ok, %HTTPoison.Response{body: body}} -> {:error, %Error{reason: body}}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, %Error{reason: reason}}
    end
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

  @doc """
  Generic method to call Telegram Bot API.

  Args:
  * `method` - name of API method
  * `options` - orddict of options
  * `file_field` - specify the key of file_field in `options` when sending files
  """
  def request(method, options \\ [], file_field \\ nil) do
    timeout = ((options[:timeout] || 0) + (opt_recv_timeout || @default_timeout)) * 1000
    method
    |> build_url
    |> HTTPoison.post(build_request(options, file_field), [], recv_timeout: timeout)
    |> process_response(method)
  end
end
