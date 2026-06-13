# Build Your First Bot

This guide shows the shortest OTP path from a new supervised Mix app to a
Nadia bot. It uses long polling, so no web framework or webhook endpoint is
required.

Start with an OTP application:

```sh
mix new my_app --sup
cd my_app
```

## 1. Add Nadia

Add Nadia to your dependencies and fetch it:

```elixir
def deps do
  [
    {:nadia, "~> 1.3"}
  ]
end
```

```sh
mix deps.get
```

## 2. Generate a bot handler

Run the generator with the module name you want for your bot:

```sh
mix nadia.gen.bot MyApp.Bot --polling
```

The task creates a handler module and an offline test that uses a fake Nadia
HTTP client. It also prints the config and supervision snippets to paste into
your application.

## 3. Configure the bot token

Store the token outside source control and read it at runtime in
`config/runtime.exs`:

```elixir
config :nadia,
  token: {:system, "TELEGRAM_BOT_TOKEN"}
```

For applications with more than one bot, use a named client instead in the same
runtime config:

```elixir
config :nadia,
  bots: [
    support: [
      token: {:system, "SUPPORT_BOT_TOKEN"}
    ]
  ]
```

Then pass `client: Nadia.Client.from_config(:support)` in the polling child
spec.

## 4. Supervise polling

Add the polling worker to the `children` list in `lib/my_app/application.ex`:

```elixir
children = [
  {Nadia.Polling,
   handler: MyApp.Bot,
   allowed_updates: ["message"],
   timeout: 30}
]
```

`Nadia.Polling` calls `getUpdates`, dispatches each update through your handler,
and stores the next offset in memory. It acknowledges an update after the handler
returns `:ok`, `:ignore`, or `{:ok, value}`. Handler errors and API errors are
retried with bounded backoff without acknowledging the failed update.

## 5. Run locally

Run the generated test first:

```sh
mix test
```

Then start the app with your bot token:

```sh
TELEGRAM_BOT_TOKEN=123:token mix run --no-halt
```

Send `/start` to the bot in Telegram. The generated handler replies with
`Ready` and echoes plain text messages.
