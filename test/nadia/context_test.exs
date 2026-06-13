defmodule Nadia.ContextTest do
  use Nadia.HTTPCase, async: true

  alias Nadia.Client
  alias Nadia.Context

  alias Nadia.Model.{
    CallbackQuery,
    Chat,
    ChatJoinRequest,
    Error,
    InlineQuery,
    Message,
    MessageReactionUpdated,
    PollAnswer,
    Update,
    User
  }

  describe "new/2" do
    test "extracts message chat, user, and ids" do
      update = %Update{
        update_id: 1,
        message: %Message{
          message_id: 10,
          text: "hello",
          from: %User{id: 20, first_name: "Nadia"},
          chat: %Chat{id: 30, type: "private"}
        }
      }

      context = Context.new(update)

      assert context.update == update
      assert context.message == update.message
      assert context.chat == update.message.chat
      assert context.from == update.message.from
      assert context.chat_id == 30
      assert context.message_id == 10
      assert context.client == nil
    end

    test "keeps an explicit client" do
      client = Client.new(token: "123:explicit", http_client: Nadia.HTTPCase.StubHTTPClient)
      update = %Update{inline_query: %InlineQuery{id: "inline-1"}}

      assert %Context{client: ^client} = Context.new(update, client)
      assert %Context{client: ^client} = Context.new(update, client: client)
      assert %Context{client: ^client} = Context.new(update, %{client: client})
    end

    test "uses callback query message as effective message and callback user as effective user" do
      user = %User{id: 20, first_name: "Button"}
      message = %Message{message_id: 10, chat: %Chat{id: 30, type: "private"}}

      update = %Update{
        callback_query: %CallbackQuery{id: "callback-1", from: user, message: message}
      }

      context = Context.new(update)

      assert context.message == message
      assert context.chat == message.chat
      assert context.from == user
      assert context.chat_id == 30
      assert context.message_id == 10
      assert context.callback_query == update.callback_query
    end

    test "extracts inline query users without a chat" do
      user = %User{id: 20, first_name: "Inline"}
      update = %Update{inline_query: %InlineQuery{id: "inline-1", from: user}}

      context = Context.new(update)

      assert context.inline_query == update.inline_query
      assert context.from == user
      assert context.chat == nil
      assert context.chat_id == nil
      assert context.message_id == nil
    end

    test "keeps inline-only callback queries nil-safe" do
      user = %User{id: 20, first_name: "Button"}

      update = %Update{
        callback_query: %CallbackQuery{
          id: "callback-1",
          from: user,
          inline_message_id: "inline-message-1"
        }
      }

      context = Context.new(update)

      assert context.callback_query == update.callback_query
      assert context.from == user
      assert context.message == nil
      assert context.chat == nil
      assert context.chat_id == nil
      assert context.message_id == nil
    end
  end

  describe "effective helpers" do
    test "extract chat and user values from non-message updates" do
      chat = %Chat{id: -100, type: "supergroup", title: "Group"}
      user = %User{id: 20, first_name: "Nadia"}

      chat_join_request = %Update{chat_join_request: %ChatJoinRequest{chat: chat, from: user}}

      message_reaction = %Update{
        message_reaction: %MessageReactionUpdated{chat: chat, user: user}
      }

      poll_answer = %Update{poll_answer: %PollAnswer{user: user}}

      assert Context.effective_chat(chat_join_request) == chat
      assert Context.effective_user(chat_join_request) == user
      assert Context.chat_id(chat_join_request) == -100

      assert Context.effective_chat(message_reaction) == chat
      assert Context.effective_user(message_reaction) == user
      assert Context.chat_id(message_reaction) == -100

      assert Context.effective_chat(poll_answer) == nil
      assert Context.effective_user(poll_answer) == user
      assert Context.chat_id(poll_answer) == nil
    end

    test "return nil when an update has no matching value" do
      update = %Update{poll: %Nadia.Model.Poll{id: "poll-1"}}
      context = Context.new(update)

      assert Context.effective_message(update) == nil
      assert Context.effective_chat(update) == nil
      assert Context.effective_user(update) == nil
      assert Context.chat_id(update) == nil

      assert Context.effective_message(context) == nil
      assert Context.effective_chat(context) == nil
      assert Context.effective_user(context) == nil
      assert Context.chat_id(context) == nil
    end
  end

  describe "reply/3" do
    test "delegates to send_message with the default client" do
      stub_telegram_result(%{message_id: 11, chat: %{id: 30, type: "private"}, text: "pong"})

      context = %Context{chat_id: 30}

      assert {:ok, %Message{text: "pong"}} =
               Context.reply(context, "pong", disable_notification: true)

      request = assert_telegram_request("sendMessage")

      assert form_params(request) == %{
               "chat_id" => "30",
               "disable_notification" => "true",
               "text" => "pong"
             }
    end

    test "delegates to send_message with an explicit client" do
      client = Client.new(token: "123:explicit", http_client: Nadia.HTTPCase.StubHTTPClient)
      stub_telegram_result(%{message_id: 11, chat: %{id: 30, type: "private"}, text: "pong"})

      assert {:ok, %Message{text: "pong"}} =
               Context.reply(%Context{client: client, chat_id: 30}, "pong")

      assert_telegram_request("sendMessage",
        url: "https://api.telegram.org/bot123:explicit/sendMessage"
      )
    end

    test "returns an error when there is no effective chat" do
      assert {:error, %Error{reason: "cannot reply without an effective chat"}} =
               Context.reply(%Context{}, "pong")
    end
  end

  describe "answer_callback/2" do
    test "delegates to answer_callback_query with callback id" do
      stub_telegram_result(true)

      context = %Context{callback_query: %CallbackQuery{id: "callback-1"}}

      assert :ok = Context.answer_callback(context, text: "done")

      request = assert_telegram_request("answerCallbackQuery")
      assert form_params(request) == %{"callback_query_id" => "callback-1", "text" => "done"}
    end

    test "delegates to answer_callback_query with an explicit client" do
      client = Client.new(token: "123:explicit", http_client: Nadia.HTTPCase.StubHTTPClient)
      stub_telegram_result(true)

      context = %Context{client: client, callback_query: %CallbackQuery{id: "callback-1"}}

      assert :ok = Context.answer_callback(context)

      assert_telegram_request(
        "answerCallbackQuery",
        url: "https://api.telegram.org/bot123:explicit/answerCallbackQuery"
      )
    end

    test "returns an error when there is no callback query" do
      assert {:error, %Error{reason: "cannot answer callback without a callback query"}} =
               Context.answer_callback(%Context{})
    end
  end
end
