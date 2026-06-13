# Nadia

[![Elixir CI](https://github.com/zhyu/nadia/actions/workflows/elixir.yml/badge.svg)](https://github.com/zhyu/nadia/actions/workflows/elixir.yml)
[![Module Version](https://img.shields.io/hexpm/v/nadia.svg)](https://hex.pm/packages/nadia)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/nadia/)
[![Total Download](https://img.shields.io/hexpm/dt/nadia.svg)](https://hex.pm/packages/nadia)
[![License](https://img.shields.io/hexpm/l/nadia.svg)](https://github.com/zhyu/nadia/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/zhyu/nadia.svg)](https://github.com/zhyu/nadia/commits/master)

Telegram Bot API Wrapper written in Elixir ([document](https://hexdocs.pm/nadia/))

## API Coverage

As of Nadia 1.3.0, the Telegram Bot API wrapper covers all 180 official methods
in Telegram Bot API 10.1, published on June 11, 2026. Nadia keeps response
parsing strict: modeled response fields are parsed into Nadia structs, while
unknown future fields are ignored until the library explicitly models them.

## Installation

Nadia requires Elixir 1.20 or later and Erlang/OTP 27 or later.

Add `:nadia` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:nadia, "~> 1.3"}
  ]
end
```

And run `$ mix deps.get`.

## Configuration

In `config/config.exs`, add your Telegram Bot token like [this](config/config.exs.example)

```elixir
config :nadia,
  token: "bot token"
```

You can also add an optional `recv_timeout` in seconds (defaults to 5s):

```elixir
config :nadia,
  recv_timeout: 10
```

You can also add a proxy support:

```elixir
config :nadia,
  proxy: "http://proxy_host:proxy_port",
  proxy_auth: {"user", "password"}
```

Nadia uses Req as its HTTP client. Proxy configuration supports HTTP and HTTPS
proxies accepted by Req/Mint; hackney-specific SOCKS options are no longer
supported.

You can also configure the the base url for the api if you need to for some
reason:

```elixir
config :nadia,
  # Telegram API. Default: https://api.telegram.org/bot
  base_url: "http://my-own-endpoint.com/whatever/",

  # Telegram Graph API. Default: https://api.telegra.ph
  graph_base_url: "http://my-own-endpoint.com/whatever/"
```

Environment variables may be used as well:

```elixir
config :nadia,
  token: {:system, "ENVVAR_WITH_MYAPP_TOKEN", "default_value_if_needed"}
```

For applications that need more than one bot, configure named bots and build
explicit clients from those names:

```elixir
config :nadia,
  bots: [
    support: [
      token: {:system, "SUPPORT_BOT_TOKEN"},
      recv_timeout: 10
    ],
    alerts: [
      token: {:system, "ALERTS_BOT_TOKEN"},
      proxy: "http://proxy_host:proxy_port"
    ]
  ]
```

```elixir
support_bot = Nadia.Client.from_config(:support)
alerts_bot = Nadia.Client.from_config(:alerts)

Nadia.send_message(support_bot, support_chat_id, "How can we help?")
Nadia.send_message(alerts_bot, alerts_chat_id, "Alert triggered")
```

The top-level `:token` configuration remains the default client for existing
calls such as `Nadia.get_me()` and `Nadia.send_message(chat_id, text)`.

## Usage

### `get_me`

```elixir
iex> Nadia.get_me
{:ok,
 %Nadia.Model.User{first_name: "Nadia", id: 666, last_name: nil,
  username: "nadia_bot"}}
```

### `get_updates`

```elixir
iex> Nadia.get_updates limit: 5
{:ok, []}

iex> {:ok,
 [%Nadia.Model.Update{callback_query: nil, chosen_inline_result: nil,
   edited_message: nil, inline_query: nil,
   message: %Nadia.Model.Message{audio: nil, caption: nil,
    channel_chat_created: nil,
    chat: %Nadia.Model.Chat{first_name: "Nadia", id: 123,
     last_name: "TheBot", title: nil, type: "private", username: "nadia_the_bot"},
    contact: nil, date: 1471208260, delete_chat_photo: nil, document: nil,
    edit_date: nil, entities: nil, forward_date: nil, forward_from: nil,
    forward_from_chat: nil,
    from: %Nadia.Model.User{first_name: "Nadia", id: 123,
     last_name: "TheBot", username: "nadia_the_bot"}, group_chat_created: nil,
    left_chat_member: nil, location: nil, message_id: 543,
    migrate_from_chat_id: nil, migrate_to_chat_id: nil, new_chat_member: nil,
    new_chat_photo: [], new_chat_title: nil, photo: [], pinned_message: nil,
    reply_to_message: nil, sticker: nil, supergroup_chat_created: nil,
    text: "rew", venue: nil, video: nil, voice: nil}, update_id: 98765}]}
```

### Incoming update helpers

Webhook handlers and custom polling loops can parse raw Telegram update payloads
without reaching into Nadia internals:

```elixir
with {:ok, update} <- Nadia.Parser.parse_update(raw_body) do
  context = Nadia.Context.new(update)

  if context.message && context.message.text == "/start" do
    Nadia.Context.reply(context, "Ready")
  end
end
```

`Nadia.Parser.parse_update/1` accepts a decoded update map, an existing
`%Nadia.Model.Update{}`, or a raw JSON object binary. `parse_updates/1` accepts
a decoded list, a JSON array binary, or a decoded/encoded Bot API response
envelope with a `"result"` update list.

Contexts preserve explicit clients for multi-bot applications:

```elixir
client = Nadia.Client.from_config(:support)
context = Nadia.Context.new(update, client)

Nadia.Context.reply(context, "Support bot here")
```

### Dispatching updates

For non-polling update intake, define a small handler and dispatch parsed
updates to it:

```elixir
defmodule MyApp.Bot do
  @behaviour Nadia.Handler

  @impl true
  def handle_update(_update, context) do
    case Nadia.Dispatcher.match_command(context, "start") do
      {:ok, _match} ->
        Nadia.Context.reply(context, "Ready")

      :nomatch ->
        :ignore
    end
  end
end

with {:ok, update} <- Nadia.Parser.parse_update(raw_body) do
  Nadia.Dispatcher.dispatch(update, MyApp.Bot, client: Nadia.Client.from_config(:support))
end
```

`Nadia.Dispatcher.dispatch/3` returns the handler result unchanged. Handler
exceptions are not swallowed, so callers and future supervisors can decide how
to handle failed updates.

### Supervised polling

To run a bot under OTP, add `Nadia.Polling` to your supervision tree:

```elixir
children = [
  {Nadia.Polling,
   client: Nadia.Client.from_config(:support),
   handler: MyApp.Bot,
   allowed_updates: ["message", "callback_query"],
   timeout: 30}
]
```

`Nadia.Polling` calls `getUpdates` with long polling, dispatches updates
sequentially through `Nadia.Dispatcher`, and tracks the next offset in memory.
It advances the offset after `:ok`, `:ignore`, or `{:ok, value}` handler
results. Handler `{:error, reason}` results, handler exceptions, and
`getUpdates` errors are retried with bounded backoff without acknowledging the
failed update.

To generate a starter handler and offline test, run:

```sh
mix nadia.gen.bot MyApp.Bot --polling
```

See [Build Your First Bot](guides/build-your-first-bot.md) for the full
walkthrough.

### `send_message`

```elixir
iex> case Nadia.send_message(tlg_id, "The message text goes here") do
  {:ok, _result} ->
    :ok
  {:error, %Nadia.Model.Error{reason: "Please wait a little"}} ->
    :wait
  end

:ok
```

Refer to [Nadia document](https://hexdocs.pm/nadia/) and [Telegram Bot API document](https://core.telegram.org/bots/api) for more details.

## Testing

The default test suite is offline and credential-free:

```sh
mix test
```

Optional live Telegram smoke tests are tagged with `:telegram_live` and are not
run by default:

```sh
mix test --only telegram_live
```

Live tests require two bots with Bot-to-Bot Communication Mode enabled in
BotFather. Configure credentials by copying the committed seed file to the
ignored local env file, then edit the local file:

```sh
cp .env.live.local.example .env.live.local
chmod 600 .env.live.local
${EDITOR:-vi} .env.live.local
```

The local `.env.live.local` file should define:

```sh
export NADIA_LIVE_BOT_A_TOKEN="123:bot-a-token"
export NADIA_LIVE_BOT_A_USERNAME="bot_a_username"
export NADIA_LIVE_BOT_B_TOKEN="456:bot-b-token"
export NADIA_LIVE_BOT_B_USERNAME="bot_b_username"
```

Then source the local file and run the live suite from the same shell:

```sh
source .env.live.local
mix test --only telegram_live
```

Set `NADIA_LIVE_API_ENV=test` in `.env.live.local` to route live smoke tests
through Telegram's Bot API test environment.

## Copyright and License

Copyright (c) 2015 Yu Zhang

This library licensed under the [MIT license](./LICENSE.md).
