defmodule Nadia do

  @base_url "https://api.telegram.org/bot"

  defp token, do: Application.get_env(:nadia, :token)

  defp build_url(method), do: @base_url <> token <> "/" <> method

end
