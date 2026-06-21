# Test Bot Handlers

Bot logic can be tested without a Telegram token or network connection. Build
an update struct, create a client with a fake `Nadia.HTTPClient`, and call the
handler directly.

The examples in Nadia's [`examples`](https://github.com/zhyu/nadia/tree/master/examples)
directory are tested this way by the normal `mix test` suite.

## Define A Fake HTTP Adapter

The adapter receives a public `Nadia.HTTPRequest` and returns a public
`Nadia.HTTPResponse`. A useful fake sends requests back to the test process so
assertions can inspect the outgoing Bot API call.

```elixir
defmodule MyApp.FakeHTTPClient do
  @behaviour Nadia.HTTPClient

  @impl Nadia.HTTPClient
  def post(%Nadia.HTTPRequest{} = request) do
    send(self(), {:nadia_request, request})

    {:ok,
     %Nadia.HTTPResponse{
       status_code: 200,
       body: ~s({"ok":true,"result":{"message_id":2,"date":1700000001,"chat":{"id":123,"type":"private"},"text":"Ready"}})
     }}
  end
end
```

Return the response shape expected by the method under test. For example,
`answerCallbackQuery` returns a JSON `true`, while `sendMessage` returns a
message object.

## Construct An Update

Keep fixture builders small and set only the fields the handler uses:

```elixir
defp message_update(text) do
  %Nadia.Model.Update{
    update_id: 1,
    message: %Nadia.Model.Message{
      message_id: 1,
      date: 1_700_000_000,
      text: text,
      from: %Nadia.Model.User{id: 456, first_name: "User"},
      chat: %Nadia.Model.Chat{id: 123, type: "private"}
    }
  }
end
```

Then invoke the same handler entry point used by polling or a webhook:

```elixir
test "replies to start" do
  update = message_update("/start")

  client =
    Nadia.Client.new(
      token: "123:test-token",
      http_client: MyApp.FakeHTTPClient
    )

  context = Nadia.Context.new(update, client)

  assert {:ok, %Nadia.Model.Message{}} =
           MyApp.Bot.handle_update(update, context)

  assert_received {:nadia_request,
                   %Nadia.HTTPRequest{body: {:form, params}}}

  assert {"chat_id", "123"} in params
  assert {"text", "Ready"} in params
end
```

Use a syntactically plausible test token; the fake adapter prevents it from
leaving the process.

## Test Raw Webhook Input

Use `Nadia.Webhook.dispatch_body/3` when parsing and secret verification are
part of the behavior under test:

```elixir
assert {:ok, %Nadia.Model.Message{}} =
         Nadia.Webhook.dispatch_body(
           Jason.encode!(%{
             update_id: 1,
             message: %{
               message_id: 1,
               date: 1_700_000_000,
               text: "/start",
               chat: %{id: 123, type: "private"}
             }
           }),
           MyApp.Bot,
           headers: [{"x-telegram-bot-api-secret-token", "test-secret"}],
           secret_token: "test-secret",
           client: client
         )
```

Add separate tests for invalid JSON, an invalid secret, callback updates,
updates without a message, and Bot API error responses. Handler tests should
assert both the returned value and the meaningful outgoing parameters.

For a new bot, `mix nadia.gen.bot MyApp.Bot --polling` generates this testing
pattern with the starter handler.
