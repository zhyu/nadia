defmodule Nadia.Examples.InlineKeyboardBot do
  @moduledoc false

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
