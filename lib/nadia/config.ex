defmodule Nadia.Config do
  alias Nadia.Bot.Config

  @spec token :: binary
  def token, do: Config.token(:nadia)

  @spec proxy :: binary
  def proxy, do: Config.proxy(:nadia)

  @spec proxy_auth :: binary
  def proxy_auth, do: Config.proxy_auth(:nadia)

  @spec socks5_user :: binary
  def socks5_user, do: Config.socks5_user(:nadia)

  @spec socks5_pass :: binary
  def socks5_pass, do: Config.socks5_pass(:nadia)

  @spec recv_timeout :: binary
  def recv_timeout, do: Config.recv_timeout(:nadia)

  @spec base_url :: binary
  def base_url, do: Config.base_url(:nadia)

  @spec graph_base_url :: binary
  def graph_base_url, do: Config.graph_base_url(:nadia)

  @spec file_base_url :: binary
  def file_base_url, do: Config.file_base_url(:nadia)
end
