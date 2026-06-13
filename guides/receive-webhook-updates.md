# Receive Webhook Updates

Nadia's core webhook support is framework-neutral. It verifies Telegram's
optional secret token header, parses raw webhook bodies into
`Nadia.Model.Update`, builds `Nadia.Context`, and dispatches to your handler.
It does not add Plug, Phoenix, or another web framework dependency.

## Configure Telegram

Set a webhook URL with Telegram and, if you want request verification, a secret
token:

```elixir
Nadia.set_webhook(
  url: "https://example.com/telegram/webhook",
  secret_token: System.fetch_env!("TELEGRAM_WEBHOOK_SECRET")
)
```

## Dispatch A Request Body

In your web framework endpoint, read the raw request body and request headers,
then pass them to `Nadia.Webhook.dispatch_body/3`:

```elixir
case Nadia.Webhook.dispatch_body(
       raw_body,
       MyApp.Bot,
       headers: request_headers,
       secret_token: System.fetch_env!("TELEGRAM_WEBHOOK_SECRET"),
       client: Nadia.Client.from_config(:support)
     ) do
  {:error, :invalid_secret_token} ->
    {:error, :unauthorized}

  {:error, %Jason.DecodeError{}} ->
    {:error, :bad_request}

  _handler_result ->
    :ok
end
```

Return a successful HTTP response after dispatch succeeds. Handler return values
are passed through unchanged, and handler exceptions bubble to your framework so
you can use its normal error handling.

## Build A Context Manually

Use `Nadia.Webhook.context/2` when your endpoint wants to inspect the parsed
update before dispatching:

```elixir
with {:ok, context} <-
       Nadia.Webhook.context(raw_body,
         headers: request_headers,
         secret_token: System.fetch_env!("TELEGRAM_WEBHOOK_SECRET")
       ) do
  Nadia.Dispatcher.dispatch(context, MyApp.Bot)
end
```

For no-secret deployments, omit `:secret_token`. Nadia will parse and dispatch
without header verification.
