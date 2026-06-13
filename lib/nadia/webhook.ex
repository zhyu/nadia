defmodule Nadia.Webhook do
  @moduledoc """
  Framework-neutral helpers for receiving Telegram webhook updates.

  Nadia does not require Plug or Phoenix. Web frameworks can pass the raw
  request body and request headers to this module, then translate the result into
  the framework's response type.

      Nadia.Webhook.dispatch_body(
        raw_body,
        MyApp.Bot,
        headers: request_headers,
        secret_token: System.fetch_env!("TELEGRAM_WEBHOOK_SECRET"),
        client: Nadia.Client.from_config(:support)
      )

  The Telegram secret token check uses the
  `x-telegram-bot-api-secret-token` header. If no `:secret_token` is supplied,
  verification is skipped.
  """

  import Bitwise

  alias Nadia.Context
  alias Nadia.Dispatcher
  alias Nadia.Model.Update

  @secret_token_header "x-telegram-bot-api-secret-token"

  @type headers ::
          [{binary | atom, binary | [binary]}] | %{optional(binary | atom) => binary | [binary]}
  @type option ::
          {:headers, headers}
          | {:secret_token, binary | nil}
          | {:client, Nadia.Client.t() | nil}
          | {:bot_username, binary}

  @doc """
  Returns the Telegram webhook secret token header name.
  """
  @spec secret_token_header() :: binary
  def secret_token_header, do: @secret_token_header

  @doc """
  Parses a raw Telegram webhook request body into an update.
  """
  @spec parse_body(binary | map | Update.t()) :: {:ok, Update.t()} | {:error, term}
  def parse_body(body), do: Nadia.Parser.parse_update(body)

  @doc """
  Parses a raw Telegram webhook request body into an update, raising on invalid
  JSON or invalid update shapes.
  """
  @spec parse_body!(binary | map | Update.t()) :: Update.t()
  def parse_body!(body), do: Nadia.Parser.parse_update!(body)

  @doc """
  Builds a `Nadia.Context` from a webhook body after optional secret validation.
  """
  @spec context(binary | map | Update.t(), [option] | map) ::
          {:ok, Context.t()} | {:error, term}
  def context(body, opts \\ []) do
    with :ok <- verify_secret(option_value(opts, :headers, []), option_value(opts, :secret_token)),
         {:ok, update} <- parse_body(body) do
      {:ok, Context.new(update, dispatch_options(opts))}
    end
  end

  @doc """
  Dispatches a raw webhook body to a Nadia handler or route list.

  Returns parser or secret verification errors as `{:error, reason}`. Handler
  results are returned unchanged, and handler exceptions bubble to the caller.
  """
  @spec dispatch_body(binary | map | Update.t(), module | [Dispatcher.route()], [option] | map) ::
          term | {:error, term}
  def dispatch_body(body, handler_or_routes, opts \\ []) do
    with :ok <- verify_secret(option_value(opts, :headers, []), option_value(opts, :secret_token)),
         {:ok, update} <- parse_body(body) do
      Dispatcher.dispatch(update, handler_or_routes, dispatch_options(opts))
    end
  end

  @doc """
  Verifies Telegram's optional webhook secret token header.

  Passing `nil` as the expected secret disables verification. Header names are
  matched case-insensitively.
  """
  @spec verify_secret(headers, binary | nil) :: :ok | {:error, :invalid_secret_token}
  def verify_secret(_headers, nil), do: :ok

  def verify_secret(headers, expected_secret) when is_binary(expected_secret) do
    with secret when is_binary(secret) <- header_value(headers, @secret_token_header),
         true <- secure_equal?(secret, expected_secret) do
      :ok
    else
      _ -> {:error, :invalid_secret_token}
    end
  end

  def verify_secret(_headers, _expected_secret), do: {:error, :invalid_secret_token}

  defp dispatch_options(opts) when is_list(opts) do
    Keyword.drop(opts, [:headers, :secret_token])
  end

  defp dispatch_options(opts) when is_map(opts) do
    Map.drop(opts, [:headers, :secret_token, "headers", "secret_token"])
  end

  defp header_value(headers, name) when is_list(headers) or is_map(headers) do
    headers
    |> Enum.find_value(fn {key, value} ->
      if header_name(key) == name, do: normalize_header_value(value)
    end)
  end

  defp header_value(_headers, _name), do: nil

  defp header_name(key) when is_binary(key) do
    key
    |> String.downcase()
    |> String.replace("_", "-")
  end

  defp header_name(key) when is_atom(key) do
    key
    |> Atom.to_string()
    |> header_name()
  end

  defp header_name(key), do: key |> to_string() |> header_name()

  defp normalize_header_value([value | _]) when is_binary(value), do: value
  defp normalize_header_value(value) when is_binary(value), do: value
  defp normalize_header_value(_value), do: nil

  defp secure_equal?(left, right) when byte_size(left) == byte_size(right) do
    left
    |> :binary.bin_to_list()
    |> Enum.zip(:binary.bin_to_list(right))
    |> Enum.reduce(0, fn {left_byte, right_byte}, diff ->
      diff ||| bxor(left_byte, right_byte)
    end)
    |> Kernel.==(0)
  end

  defp secure_equal?(_left, _right), do: false

  defp option_value(options, key, default \\ nil)

  defp option_value(options, key, default) when is_list(options),
    do: Keyword.get(options, key, default)

  defp option_value(options, key, default) when is_map(options) do
    Map.get(options, key, Map.get(options, Atom.to_string(key), default))
  end

  defp option_value(_options, _key, default), do: default
end
