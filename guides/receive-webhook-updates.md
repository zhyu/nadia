# Receive Webhook Updates

Nadia's core webhook support is framework-neutral. It verifies Telegram's
optional secret token header, parses raw webhook bodies into
`Nadia.Model.Update`, builds `Nadia.Context`, and dispatches to your handler.
It does not add Plug, Phoenix, or another web framework dependency.

## Configure Telegram

Set a webhook URL with Telegram and a high-entropy secret token:

```elixir
Nadia.set_webhook(
  url: "https://example.com/telegram/webhook",
  secret_token: System.fetch_env!("TELEGRAM_WEBHOOK_SECRET"),
  allowed_updates: ["message", "callback_query"]
)
```

Telegram stops returning updates through `getUpdates` while a webhook is set.
Stop polling workers before enabling the webhook; call
`Nadia.delete_webhook/1` before switching back to polling.

## Dispatch A Request Body

In your web framework endpoint, read the request body as a binary and collect
the request headers. Pass those values to `Nadia.Webhook.dispatch_body/3`:

```elixir
case Nadia.Webhook.dispatch_body(
       raw_body,
       MyApp.Bot,
       headers: request_headers,
       secret_token: System.fetch_env!("TELEGRAM_WEBHOOK_SECRET")
     ) do
  {:error, :invalid_secret_token} ->
    {:error, :unauthorized}

  {:error, %Jason.DecodeError{}} ->
    {:error, :bad_request}

  :ok ->
    :ok

  :ignore ->
    :ok

  {:ok, _value} ->
    :ok

  {:error, _reason} = error ->
    error
end
```

Translate the final `:ok` into a successful HTTP response. Return an error
status, or let the request fail, when you want Telegram to retry the update.
Handler return values are passed through unchanged, and handler exceptions
bubble to your framework so you can use its normal error handling.

When using a named bot, add `client: Nadia.Client.from_config(:support)` after
defining that bot in runtime configuration. Otherwise the default Nadia token
configuration is used.

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

Omitting `:secret_token` disables verification. That can be useful in a test,
but production endpoints should verify the header and also enforce HTTPS,
request body limits, and normal infrastructure access controls.

See the [Production Checklist](production-checklist.md) for duplicate delivery,
idempotency, timeouts, and background work guidance.
