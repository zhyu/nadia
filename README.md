# Nadia

[![Elixir CI](https://github.com/zhyu/nadia/actions/workflows/elixir.yml/badge.svg)](https://github.com/zhyu/nadia/actions/workflows/elixir.yml)
[![Module Version](https://img.shields.io/hexpm/v/nadia.svg)](https://hex.pm/packages/nadia)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/nadia/)
[![Total Download](https://img.shields.io/hexpm/dt/nadia.svg)](https://hex.pm/packages/nadia)
[![License](https://img.shields.io/hexpm/l/nadia.svg)](https://github.com/zhyu/nadia/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/zhyu/nadia.svg)](https://github.com/zhyu/nadia/commits/master)

Telegram Bot API Wrapper written in Elixir ([document](https://hexdocs.pm/nadia/))

## Installation

Add `:nadia` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:nadia, "~> 0.7.0"}
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
  proxy: "http://proxy_host:proxy_port", # or {:socks5, 'proxy_host', proxy_port}
  proxy_auth: {"user", "password"},
  ssl: [versions: [:'tlsv1.2']]
```

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

## Copyright and License

Copyright (c) 2015 Yu Zhang

This library licensed under the [MIT license](./LICENSE.md).
