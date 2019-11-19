defmodule Nadia.Graph.API do
  @moduledoc """
  Provides basic functionalities for Telegram Bot API.
  """

  alias Nadia.Bot.GraphAPI

  @doc """
  Generic method to call Telegram Bot API.

  Args:
  * `method` - name of API method
  * `options` - orddict of options
  * `file_field` - specify the key of file_field in `options` when sending files
  """
  def request(method, options \\ [], file_field \\ nil),
    do: GraphAPI.request(:nadia, method, options, file_field)
end
