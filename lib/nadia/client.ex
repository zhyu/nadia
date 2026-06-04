defmodule Nadia.Client do
  @moduledoc """
  Immutable Telegram Bot API client configuration.
  """

  @default_timeout 5
  @default_base_url "https://api.telegram.org/bot"
  @default_file_base_url "https://api.telegram.org/file/bot"
  @default_api_environment :production
  @default_http_client Nadia.HTTPClient.Req

  defstruct token: nil,
            base_url: @default_base_url,
            file_base_url: @default_file_base_url,
            api_environment: @default_api_environment,
            recv_timeout: @default_timeout,
            proxy: nil,
            proxy_auth: nil,
            http_client: @default_http_client

  @type api_environment :: :production | :test

  @type t :: %__MODULE__{
          token: binary | nil,
          base_url: binary,
          file_base_url: binary,
          api_environment: api_environment,
          recv_timeout: non_neg_integer,
          proxy: term,
          proxy_auth: term,
          http_client: module
        }

  @config_keys [
    :token,
    :base_url,
    :file_base_url,
    :api_environment,
    :recv_timeout,
    :proxy,
    :proxy_auth,
    :http_client
  ]

  @doc """
  Builds a client from explicit options.
  """
  @spec new(keyword | map) :: t
  def new(opts \\ []) do
    opts = normalize_opts(opts)

    %__MODULE__{
      token: resolve(Keyword.get(opts, :token)),
      base_url: resolve(Keyword.get(opts, :base_url, @default_base_url)) || @default_base_url,
      file_base_url:
        resolve(Keyword.get(opts, :file_base_url, @default_file_base_url)) ||
          @default_file_base_url,
      api_environment:
        opts
        |> Keyword.get(:api_environment, @default_api_environment)
        |> resolve()
        |> normalize_api_environment(),
      recv_timeout:
        resolve(Keyword.get(opts, :recv_timeout, @default_timeout)) || @default_timeout,
      proxy: resolve(Keyword.get(opts, :proxy)),
      proxy_auth: resolve(Keyword.get(opts, :proxy_auth)),
      http_client:
        resolve(Keyword.get(opts, :http_client, @default_http_client)) || @default_http_client
    }
  end

  @doc """
  Builds the legacy default client from application config.
  """
  @spec default() :: t
  def default, do: from_config()

  @doc """
  Builds the legacy default client from top-level application config.
  """
  @spec from_config() :: t
  def from_config do
    @config_keys
    |> Enum.reduce([], fn key, opts ->
      case Application.fetch_env(:nadia, key) do
        {:ok, value} -> Keyword.put(opts, key, value)
        :error -> opts
      end
    end)
    |> new()
  end

  @doc """
  Builds a named client from `config :nadia, bots: [...]`.
  """
  @spec from_config(atom) :: t
  def from_config(name) when is_atom(name) do
    :nadia
    |> Application.get_env(:bots, [])
    |> fetch_named_config(name)
    |> new()
  end

  defp fetch_named_config(bots, name) when is_list(bots) do
    case Keyword.fetch(bots, name) do
      {:ok, opts} -> opts
      :error -> raise_unknown_bot!(name)
    end
  end

  defp fetch_named_config(bots, name) when is_map(bots) do
    case Map.fetch(bots, name) do
      {:ok, opts} -> opts
      :error -> raise_unknown_bot!(name)
    end
  end

  defp fetch_named_config(_bots, name), do: raise_unknown_bot!(name)

  defp raise_unknown_bot!(name) do
    raise ArgumentError, "unknown Nadia bot config #{inspect(name)}"
  end

  defp normalize_opts(opts) when is_map(opts), do: Map.to_list(opts)
  defp normalize_opts(opts) when is_list(opts), do: opts

  defp resolve({:system, var}), do: System.get_env(var)

  defp resolve({:system, var, default}) do
    case System.get_env(var) do
      nil -> default
      value -> value
    end
  end

  defp resolve(value), do: value

  defp normalize_api_environment(:test), do: :test
  defp normalize_api_environment("test"), do: :test
  defp normalize_api_environment(_), do: :production
end

defimpl Inspect, for: Nadia.Client do
  import Inspect.Algebra

  def inspect(client, opts) do
    fields =
      client
      |> Map.from_struct()
      |> Map.put(:token, redact(client.token))

    concat(["#Nadia.Client<", to_doc(fields, opts), ">"])
  end

  defp redact(nil), do: nil
  defp redact(_token), do: "[REDACTED]"
end
