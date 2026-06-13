defmodule Nadia.DispatcherTest do
  use ExUnit.Case, async: true

  alias Nadia.Client
  alias Nadia.Context
  alias Nadia.Dispatcher
  alias Nadia.Model.{CallbackQuery, Chat, Message, Update, User}

  defmodule TestHandler do
    @behaviour Nadia.Handler

    @impl Nadia.Handler
    def handle_update(update, context) do
      send(self(), {:handled, update, context})
      {:ok, :handled}
    end
  end

  defmodule RaisingHandler do
    @behaviour Nadia.Handler

    @impl Nadia.Handler
    def handle_update(_update, _context), do: raise("handler failed")
  end

  defmodule ReturnHandler do
    @behaviour Nadia.Handler

    @impl Nadia.Handler
    def handle_update(_update, %Context{message: %Message{text: text}}) do
      case text do
        ":ok" -> :ok
        ":ignore" -> :ignore
        ":ok_tuple" -> {:ok, :value}
        ":error_tuple" -> {:error, :reason}
      end
    end
  end

  defmodule RouteActions do
    def echo(context, match) do
      send(self(), {:echo, context, match})
      {:ok, :echo}
    end

    def fallback(context) do
      send(self(), {:fallback, context})
      :fallback
    end
  end

  describe "dispatch/3 with handler modules" do
    test "builds a context and calls handle_update/2" do
      update = message_update("/start")
      client = Client.new(token: "123:explicit")

      assert {:ok, :handled} = Dispatcher.dispatch(update, TestHandler, client)

      assert_receive {:handled, ^update, %Context{} = context}
      assert context.client == client
      assert context.chat_id == 30
      assert context.message.text == "/start"
    end

    test "accepts an existing context" do
      update = message_update("hello")
      context = Context.new(update)

      assert {:ok, :handled} = Dispatcher.dispatch(context, TestHandler)

      assert_receive {:handled, ^update, ^context}
    end

    test "returns handler results unchanged" do
      assert :ok = Dispatcher.dispatch(message_update(":ok"), ReturnHandler)
      assert :ignore = Dispatcher.dispatch(message_update(":ignore"), ReturnHandler)
      assert {:ok, :value} = Dispatcher.dispatch(message_update(":ok_tuple"), ReturnHandler)

      assert {:error, :reason} =
               Dispatcher.dispatch(message_update(":error_tuple"), ReturnHandler)
    end

    test "lets handler exceptions bubble" do
      assert_raise RuntimeError, "handler failed", fn ->
        Dispatcher.dispatch(message_update("boom"), RaisingHandler)
      end
    end

    test "rejects invalid inputs" do
      assert {:error, :invalid_update} = Dispatcher.dispatch(%{}, TestHandler)
      assert {:error, :invalid_handler} = Dispatcher.dispatch(message_update("hello"), 123)
    end
  end

  describe "dispatch/3 with route lists" do
    test "dispatches the first matching command route" do
      routes = [
        {:command, "start",
         fn context, match ->
           send(self(), {:command, context, match})
           {:ok, :start}
         end},
        {:fallback, &RouteActions.fallback/1}
      ]

      assert {:ok, :start} = Dispatcher.dispatch(message_update("/start hello"), routes)

      assert_receive {:command, %Context{chat_id: 30}, match}
      assert match.kind == :command
      assert match.command == "start"
      assert match.args == "hello"
      assert match.text == "/start hello"
      refute_receive {:fallback, _context}
    end

    test "matches command names with allowed bot suffixes" do
      assert {:ok, match} =
               Dispatcher.match_command(message_update("/start@nadia_bot hello"), "start",
                 bot_username: "nadia_bot"
               )

      assert match.kind == :command
      assert match.command == "start"
      assert match.bot == "nadia_bot"
      assert match.args == "hello"

      assert :nomatch = Dispatcher.match_command(message_update("/start@other_bot"), "start")
      assert :nomatch = Dispatcher.match_command(message_update("/startled"), "start")
    end

    test "dispatches text regex routes with captures" do
      routes = [
        {:text, ~r/^echo\s+(.+)/, {RouteActions, :echo}},
        {:fallback, &RouteActions.fallback/1}
      ]

      assert {:ok, :echo} = Dispatcher.dispatch(message_update("echo Nadia"), routes)

      assert_receive {:echo, %Context{chat_id: 30}, match}
      assert match.kind == :text
      assert match.text == "echo Nadia"
      assert match.captures == ["Nadia"]
      refute_receive {:fallback, _context}
    end

    test "dispatches callback prefix routes" do
      routes = [
        {:callback, {:prefix, "confirm:"},
         fn context, match ->
           send(self(), {:callback, context, match})
           :confirmed
         end}
      ]

      assert :confirmed = Dispatcher.dispatch(callback_update("confirm:42"), routes)

      assert_receive {:callback, %Context{callback_query: %CallbackQuery{id: "callback-1"}},
                      match}

      assert match.kind == :callback
      assert match.data == "confirm:42"
      assert match.captures == []
    end

    test "runs fallback routes when nothing else matches" do
      routes = [
        {:command, "start", fn _context -> :start end},
        {:fallback, &RouteActions.fallback/1}
      ]

      assert :fallback = Dispatcher.dispatch(message_update("plain text"), routes)

      assert_receive {:fallback, %Context{chat_id: 30}}
    end

    test "returns :ignore when no route matches" do
      assert :ignore =
               Dispatcher.dispatch(message_update("plain text"), [
                 {:command, "start", fn _ -> :ok end}
               ])
    end

    test "lets route action exceptions bubble" do
      routes = [
        {:text, "boom", fn _context -> raise "route failed" end}
      ]

      assert_raise RuntimeError, "route failed", fn ->
        Dispatcher.dispatch(message_update("boom"), routes)
      end
    end
  end

  describe "matching helpers" do
    test "return :nomatch for missing values" do
      update = %Update{inline_query: %Nadia.Model.InlineQuery{id: "inline-1"}}

      assert :nomatch = Dispatcher.match_command(update, "start")
      assert :nomatch = Dispatcher.match_text(update, "hello")
      assert :nomatch = Dispatcher.match_callback(update, {:prefix, "confirm:"})
    end

    test "match exact text and callback regexes" do
      assert {:ok, %{kind: :text, captures: []}} =
               Dispatcher.match_text(message_update("hello"), "hello")

      assert {:ok, %{kind: :callback, captures: ["42"]}} =
               Dispatcher.match_callback(callback_update("confirm:42"), ~r/^confirm:(\d+)$/)

      assert {:ok, %{kind: :callback, captures: []}} =
               Dispatcher.match_callback(callback_update("confirm:42"), "confirm:42")

      assert :nomatch = Dispatcher.match_callback(callback_update("confirm:42"), "confirm:")
    end
  end

  defp message_update(text) do
    %Update{
      update_id: 1,
      message: %Message{
        message_id: 10,
        text: text,
        from: %User{id: 20, first_name: "Nadia"},
        chat: %Chat{id: 30, type: "private"}
      }
    }
  end

  defp callback_update(data) do
    %Update{
      update_id: 1,
      callback_query: %CallbackQuery{
        id: "callback-1",
        from: %User{id: 20, first_name: "Nadia"},
        message: %Message{
          message_id: 10,
          chat: %Chat{id: 30, type: "private"}
        },
        data: data
      }
    }
  end
end
