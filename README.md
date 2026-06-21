# Nadia

[![Elixir CI](https://github.com/zhyu/nadia/actions/workflows/elixir.yml/badge.svg)](https://github.com/zhyu/nadia/actions/workflows/elixir.yml)
[![Module Version](https://img.shields.io/hexpm/v/nadia.svg)](https://hex.pm/packages/nadia)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/nadia/)
[![Total Download](https://img.shields.io/hexpm/dt/nadia.svg)](https://hex.pm/packages/nadia)
[![License](https://img.shields.io/hexpm/l/nadia.svg)](https://github.com/zhyu/nadia/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/zhyu/nadia.svg)](https://github.com/zhyu/nadia/commits/master)

Nadia is an Elixir client for the Telegram Bot API and Telegraph API. It
combines complete Bot API method coverage with small, explicit helpers for
building bots in an OTP application.

* Call every Telegram Bot API method through `Nadia`.
* Receive updates with supervised polling or framework-neutral webhooks.
* Route commands, text, and callback queries without a macro DSL.
* Use explicit clients for multi-bot applications and fake HTTP adapters for
  offline tests.
* Add optional conversation state without requiring a persistence dependency.

## Installation

Nadia requires Elixir 1.20 or later and Erlang/OTP 27 or later.

Add `:nadia` to `mix.exs`:

```elixir
def deps do
  [
    {:nadia, "~> 1.5"}
  ]
end
```

Then run:

```sh
mix deps.get
```

## Quick Start

Create a bot with [@BotFather](https://t.me/BotFather). Read its token at
runtime instead of committing it to application configuration:

```elixir
# config/runtime.exs
import Config

config :nadia,
  token: {:system, "TELEGRAM_BOT_TOKEN"}
```

Direct Bot API calls return `{:ok, result}` or
`{:error, %Nadia.Model.Error{}}`:

```elixir
case Nadia.get_me() do
  {:ok, bot} -> IO.puts("Connected as @#{bot.username}")
  {:error, error} -> IO.warn("Telegram error: #{inspect(error.reason)}")
end

Nadia.send_message(chat_id, "Hello from Nadia")
```

For an OTP bot, generate a handler and offline test:

```sh
mix nadia.gen.bot MyApp.Bot --polling
```

Then supervise long polling:

```elixir
children = [
  {Nadia.Polling,
   handler: MyApp.Bot,
   allowed_updates: ["message"],
   timeout: 30}
]
```

Run the app with the token in its environment:

```sh
TELEGRAM_BOT_TOKEN=123:token mix run --no-halt
```

The [Build Your First Bot](guides/build-your-first-bot.md) guide walks through
the complete setup.

## Learn By Example

The [Examples And Learning Paths](guides/examples.md) page connects Nadia's
API reference to complete bot-building tasks.

| Build | Guide |
| --- | --- |
| A generated polling bot | [Build Your First Bot](guides/build-your-first-bot.md) |
| Commands and inline buttons | [Commands And Inline Keyboards](guides/examples/inline-keyboards.md) |
| A multi-step conversation | [Conversation State](guides/examples/conversation-state.md) |
| An HTTP endpoint | [Receive Webhook Updates](guides/receive-webhook-updates.md) |
| Several bot identities | [Run Multiple Bots](guides/multiple-bots.md) |
| Credential-free tests | [Test Bot Handlers](guides/testing-bots.md) |
| A production deployment | [Production Checklist](guides/production-checklist.md) |
| Telegraph pages | [Use The Telegraph API](guides/telegraph.md) |

Tested, copyable handler modules live in the
[`examples`](https://github.com/zhyu/nadia/tree/master/examples) directory.

## Configuration

The top-level token config is the default client used by calls such as
`Nadia.get_me/0` and `Nadia.send_message/3`. Applications with more than one bot
can configure named clients:

```elixir
config :nadia,
  bots: [
    support: [
      token: {:system, "SUPPORT_BOT_TOKEN"},
      recv_timeout: 10
    ],
    alerts: [
      token: {:system, "ALERTS_BOT_TOKEN"}
    ]
  ]
```

```elixir
support = Nadia.Client.from_config(:support)
Nadia.send_message(support, support_chat_id, "How can we help?")
```

See [Run Multiple Bots](guides/multiple-bots.md) before supervising several
pollers; each worker needs a distinct child ID.

Nadia uses Req as its HTTP transport. Optional HTTP or HTTPS proxy settings are
passed to Req/Mint:

```elixir
config :nadia,
  proxy: "http://proxy.example.com:8080",
  proxy_auth: {"user", "password"},
  recv_timeout: 10
```

Custom Bot API, file, or Telegraph endpoints can be configured with
`:base_url`, `:file_base_url`, and `:graph_base_url`. Most applications should
use the defaults.

## Testing

Nadia's normal test suite is offline and credential-free:

```sh
mix test
```

The [Test Bot Handlers](guides/testing-bots.md) guide shows how application
tests can inject a fake `Nadia.HTTPClient` and assert outgoing requests.

Optional maintainer smoke tests against Telegram are tagged
`:telegram_live`. They require the two-bot environment documented in
`.env.live.local.example` and are run with:

```sh
mix test --only telegram_live
```

## API Coverage

Since Nadia 1.0.0, the wrapper covers all 180 official methods in Telegram Bot
API 10.1, published on June 11, 2026. Current releases preserve that complete
method coverage. Modeled response fields are parsed into Nadia structs;
unknown future fields are ignored until Nadia explicitly models them.

Use the [`Nadia` reference](https://hexdocs.pm/nadia/Nadia.html) for Elixir
signatures and the [official Telegram Bot API
documentation](https://core.telegram.org/bots/api) for Telegram's field
semantics.

## License

Copyright (c) 2015 Yu Zhang

Nadia is released under the [MIT License](LICENSE.md).
