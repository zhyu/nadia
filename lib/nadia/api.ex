defmodule Nadia.API do
  @moduledoc """
  Provides basic functionalities for Telegram Bot API.
  """

  alias Nadia.Bot.API

  @doc """
  Generic method to call Telegram Bot API.

  Args:
  * `method` - name of API method
  * `options` - orddict of options
  * `file_field` - specify the key of file_field in `options` when sending files
  """
  @spec request(binary, [{atom, any}], atom) :: :ok | {:error, Error.t()} | {:ok, any}
  def request(method, options \\ [], file_field \\ nil),
    do: API.request(:nadia, method, options, file_field)

  def request?(method, options \\ [], file_field \\ nil),
    do: API.request?(:nadia, method, options, file_field)

  @doc ~S"""
  Use this function to build file url.

  iex> Nadia.API.build_file_url("document/file_10")
  "https://api.telegram.org/file/bot#{Nadia.Config.token()}/document/file_10"
  """
  @spec build_file_url(binary) :: binary
  def build_file_url(file_path), do: API.build_file_url(:nadia, file_path)
end
