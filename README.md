Nadia [![Hex pm](https://img.shields.io/hexpm/v/nadia.svg)](https://hex.pm/packages/nadia) [![Inline docs](http://inch-ci.org/github/zhyu/nadia.svg)](http://inch-ci.org/github/zhyu/nadia)
=====

Telegram Bot API Wrapper written in Elixir ([document](https://hex.pm/nadia))

## Installation
Add Nadia to your `mix.exs` dependencies:

```elixir
def deps do
  [{:nadia, "~> 0.2.0"}]
end
```
and run `$ mix deps.get`.

## Configuration

In `config/config.exs`, add your Telegram Bot token like [this](config/config.exs.example)

```elixir
config :nadia,
  token: "bot token"
```

## Usage

### get_me

```elixir
iex(1)> Nadia.get_me
{:ok,
 %Nadia.User{first_name: "Nadia", id: 81420469, last_name: nil,
  username: "nadia_bot"}}
```

Refer to [Nadia document](https://hex.pm/nadia) and [Telegram Bot API document](https://core.telegram.org/bots/api) for more details.
