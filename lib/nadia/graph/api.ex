defmodule Nadia.Graph.API do
  @moduledoc """
  Provides basic functionalities for Telegram Bot API.
  """

  alias Nadia.Graph.Model.Error
  alias Nadia.Config
  alias Nadia.HTTPClient
  alias Nadia.HTTPRequest
  alias Nadia.HTTPResponse

  defp build_url(method), do: Config.graph_base_url() <> "/" <> method

  defp process_response(response, method) do
    case decode_response(response) do
      {:ok, true} -> :ok
      {:ok, result} -> {:ok, Nadia.Graph.Parser.parse_result(result, method)}
      {:error, reason} -> {:error, %Error{reason: reason}}
    end
  end

  defp decode_response({:ok, %HTTPResponse{body: body}}) do
    case Jason.decode(body) do
      {:ok, %{"ok" => false, "description" => description}} -> {:error, description}
      {:ok, %{"ok" => false, "error" => error}} -> {:error, error}
      {:ok, %{"result" => result}} -> {:ok, result}
      {:error, error} -> {:error, error}
    end
  end

  defp decode_response({:error, reason}), do: {:error, reason}

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

  defp build_request(params, file_field) do
    params =
      params
      |> Keyword.update(:reply_markup, nil, &Jason.encode!(&1))
      |> Stream.filter(fn {_, v} -> v end)
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

  @doc """
  Generic method to call Telegram Bot API.

  Args:
  * `method` - name of API method
  * `options` - orddict of options
  * `file_field` - specify the key of file_field in `options` when sending files
  """
  def request(method, options \\ [], file_field \\ nil) do
    timeout = (Keyword.get(options, :timeout, 0) + Config.recv_timeout()) * 1000

    %HTTPRequest{
      method: :post,
      url: build_url(method),
      body: build_request(options, file_field),
      headers: [],
      options: [recv_timeout: timeout]
    }
    |> HTTPClient.post()
    |> process_response(method)
  end
end
