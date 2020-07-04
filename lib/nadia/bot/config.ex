defmodule Nadia.Bot.Config do
  @default_timeout 5
  @default_base_url "https://api.telegram.org/bot"
  @default_graph_base_url "https://api.telegra.ph"
  @default_file_base_url "https://api.telegram.org/file/bot"

  @spec token(atom) :: binary
  def token(bot), do: config_or_env(bot, :token)

  @spec proxy(atom) :: binary
  def proxy(bot), do: config_or_env(bot, :proxy)
  def proxy_auth(bot), do: config_or_env(bot, :proxy_auth)
  def socks5_user(bot), do: config_or_env(bot, :socks5_user)
  def socks5_pass(bot), do: config_or_env(bot, :socks5_pass)
  def recv_timeout(bot), do: config_or_env(bot, :recv_timeout) || @default_timeout
  def base_url(bot), do: config_or_env(bot, :base_url) || @default_base_url
  def graph_base_url(bot), do: config_or_env(bot, :graph_base_url) || @default_graph_base_url
  def file_base_url(bot), do: config_or_env(bot, :file_base_url) || @default_file_base_url

  defp config_or_env(bot, key) do
    case Application.fetch_env(bot, key) do
      {:ok, {:system, var}} ->
        System.get_env(var)

      {:ok, {:system, var, default}} ->
        case System.get_env(var) do
          nil -> default
          val -> val
        end

      {:ok, value} ->
        value

      :error ->
        nil
    end
  end
end
