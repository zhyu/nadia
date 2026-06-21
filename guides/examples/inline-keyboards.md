# Commands And Inline Keyboards

This example combines ordered routes, an inline keyboard, and callback query
acknowledgement. The complete tested source is
[`examples/inline_keyboard_bot.ex`](https://github.com/zhyu/nadia/blob/master/examples/inline_keyboard_bot.ex).

## Define The Handler

An ordered route list keeps a small bot easy to scan. The first matching route
runs; a fallback returns `:ignore` for updates this bot does not use.

```elixir
defmodule MyApp.MenuBot do
  @behaviour Nadia.Handler

  alias Nadia.Context
  alias Nadia.Dispatcher
  alias Nadia.Model.{InlineKeyboardButton, InlineKeyboardMarkup}

  @impl Nadia.Handler
  def handle_update(_update, context) do
    Dispatcher.dispatch(context, [
      {:command, "start", {__MODULE__, :show_menu}},
      {:callback, {:prefix, "color:"}, {__MODULE__, :choose_color}},
      {:fallback, {__MODULE__, :ignore}}
    ])
  end

  def show_menu(context) do
    keyboard = %InlineKeyboardMarkup{
      inline_keyboard: [
        [
          %InlineKeyboardButton{text: "Blue", callback_data: "color:blue"},
          %InlineKeyboardButton{text: "Green", callback_data: "color:green"}
        ]
      ]
    }

    Context.reply(context, "Choose a color:", reply_markup: keyboard)
  end

  def choose_color(context, %{data: "color:" <> color}) do
    with :ok <- Context.answer_callback(context, text: "Saved"),
         {:ok, _message} <- Context.reply(context, "You chose #{color}.") do
      :ok
    end
  end

  def ignore(_context), do: :ignore
end
```

Always answer a callback query, even when no notification text is needed.
Telegram clients keep showing a progress indicator until the bot calls
`answerCallbackQuery`. A callback from an inline message may not have a chat,
so `Context.reply/3` can return an error; use the callback's
`inline_message_id` with a direct Nadia editing method for that case.

## Receive Both Update Types

Add the handler to your supervision tree and request the update types used by
the routes:

```elixir
children = [
  {Nadia.Polling,
   handler: MyApp.MenuBot,
   allowed_updates: ["message", "callback_query"],
   timeout: 30}
]
```

When commands may include a bot suffix such as `/start@my_bot`, pass the bot's
username to polling:

```elixir
{Nadia.Polling,
 handler: MyApp.MenuBot,
 bot_username: "my_bot",
 allowed_updates: ["message", "callback_query"]}
```

Without `:bot_username`, unsuffixed commands still match, while suffixed
commands deliberately do not.
