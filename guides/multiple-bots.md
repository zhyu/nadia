# Run Multiple Bots

Use named bot configuration when one OTP application controls more than one
Telegram identity. Tokens stay in runtime configuration and each polling
worker receives the name of the client it should use.

## Configure Named Bots

In `config/runtime.exs`:

```elixir
import Config

config :nadia,
  bots: [
    support: [token: {:system, "SUPPORT_BOT_TOKEN"}],
    alerts: [token: {:system, "ALERTS_BOT_TOKEN"}]
  ]
```

Direct API calls can use an explicit client:

```elixir
support = Nadia.Client.from_config(:support)
alerts = Nadia.Client.from_config(:alerts)

Nadia.send_message(support, support_chat_id, "How can we help?")
Nadia.send_message(alerts, alerts_chat_id, "Alert triggered")
```

## Give Workers Distinct Child IDs

The default child ID for every polling worker is `Nadia.Polling`. Override
`:id` when supervising more than one:

```elixir
children = [
  {Nadia.Polling,
   id: MyApp.SupportPolling,
   client: :support,
   handler: MyApp.SupportBot,
   allowed_updates: ["message"]},
  {Nadia.Polling,
   id: MyApp.AlertsPolling,
   client: :alerts,
   handler: MyApp.AlertsBot,
   allowed_updates: ["message"]}
]
```

`client: :support` and `client: :alerts` resolve the named clients at worker
startup. Contexts built by polling retain the selected client, so
`Nadia.Context.reply/3` replies through the correct bot.

Use distinct child IDs for multiple named ETS session stores as well:

```elixir
children = [
  {Nadia.SessionStore.ETS,
   id: MyApp.SupportSessions,
   name: MyApp.SupportSessions},
  {Nadia.SessionStore.ETS,
   id: MyApp.AlertsSessions,
   name: MyApp.AlertsSessions}
]
```

Keep each bot's webhook, allowed update types, session key space, and
observability labels separate. A token identifies the bot at Telegram; the
local client name is only application configuration.
