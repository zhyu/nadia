defmodule Nadia.Config do
  @default_timeout 5
  @default_base_url "https://api.telegram.org/bot"
  @default_graph_base_url "https://api.telegra.ph"
  @default_file_base_url "https://api.telegram.org/file/bot"

  def token, do: config_or_env(:token)
  def proxy, do: config_or_env(:proxy)
  def proxy_auth, do: config_or_env(:proxy_auth)
  def socks5_user, do: config_or_env(:socks5_user)
  def socks5_pass, do: config_or_env(:socks5_pass)
  def recv_timeout, do: config_or_env(:recv_timeout) || @default_timeout
  def base_url, do: config_or_env(:base_url) || @default_base_url
  def graph_base_url, do: config_or_env(:graph_base_url) || @default_graph_base_url
  def file_base_url, do: config_or_env(:file_base_url) || @default_file_base_url

  defp config_or_env(key) do
    case Application.fetch_env(:nadia, key) do
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
