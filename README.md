Nadia [![Build Status](https://travis-ci.org/zhyu/nadia.svg?branch=master)](https://travis-ci.org/zhyu/nadia) [![Inline docs](http://inch-ci.org/github/zhyu/nadia.svg)](http://inch-ci.org/github/zhyu/nadia) [![Hex pm](https://img.shields.io/hexpm/v/nadia.svg)](https://hex.pm/packages/nadia)
=====

Telegram Bot API Wrapper written in Elixir ([document](https://hexdocs.pm/nadia/))

## Installation
Add Nadia to your `mix.exs` dependencies:

```elixir
def deps do
  [{:nadia, "~> 0.3"}]
end
```
and run `$ mix deps.get`.

## Configuration

In `config/config.exs`, add your Telegram Bot token like [this](config/config.exs.example)

```elixir
config :nadia,
  token: "bot token"
```

And then, in `mix.exs`, list `:nadia` as an application inside `application/0`:

```elixir
def application do
  [applications: [:nadia]]
end
```

Now Mix will guarantee the `:nadia` application is started before your application is started.

## Usage

### get_me

```elixir
iex(1)> Nadia.get_me
{:ok,
 %Nadia.Model.User{first_name: "Nadia", id: 666, last_name: nil,
  username: "nadia_bot"}}
```

Refer to [Nadia document](https://hexdocs.pm/nadia/) and [Telegram Bot API document](https://core.telegram.org/bots/api) for more details.
