Code.require_file("../../examples/inline_keyboard_bot.ex", __DIR__)
Code.require_file("../../examples/conversation_bot.ex", __DIR__)

defmodule Nadia.DocumentationExamplesTest do
  use ExUnit.Case, async: false

  alias Nadia.Client
  alias Nadia.Context
  alias Nadia.HTTPRequest
  alias Nadia.HTTPResponse
  alias Nadia.Model.{CallbackQuery, Chat, Message, Update, User}
  alias Nadia.SessionStore

  defmodule FakeHTTPClient do
    @behaviour Nadia.HTTPClient

    @impl Nadia.HTTPClient
    def post(%HTTPRequest{} = request) do
      send(self(), {:nadia_request, request})

      result =
        if String.ends_with?(request.url, "/answerCallbackQuery") do
          true
        else
          %{
            message_id: 2,
            date: 1_700_000_001,
            chat: %{id: 123, type: "private"},
            text: "ok"
          }
        end

      {:ok,
       %HTTPResponse{
         status_code: 200,
         body: Jason.encode!(%{ok: true, result: result})
       }}
    end
  end

  setup do
    client = Client.new(token: "123:test-token", http_client: FakeHTTPClient)
    %{client: client}
  end

  test "inline keyboard example routes commands and callback queries", %{client: client} do
    update = message_update("/start")
    context = Context.new(update, client)

    assert {:ok, %Message{}} =
             Nadia.Examples.InlineKeyboardBot.handle_update(update, context)

    assert_receive {:nadia_request, %HTTPRequest{body: {:form, params}}}
    assert {"text", "Choose a color:"} in params

    assert {"reply_markup", encoded_keyboard} = List.keyfind(params, "reply_markup", 0)

    assert %{
             "inline_keyboard" => [
               [
                 %{"callback_data" => "color:blue"},
                 %{"callback_data" => "color:green"}
               ]
             ]
           } = Jason.decode!(encoded_keyboard)

    update = callback_update("color:blue")
    context = Context.new(update, client)

    assert :ok = Nadia.Examples.InlineKeyboardBot.handle_update(update, context)

    assert_receive {:nadia_request, %HTTPRequest{url: answer_url}}
    assert String.ends_with?(answer_url, "/answerCallbackQuery")

    assert_receive {:nadia_request, %HTTPRequest{body: {:form, params}}}
    assert {"text", "You chose blue."} in params
  end

  test "conversation example advances and clears explicit session state", %{client: client} do
    start_supervised!({Nadia.SessionStore.ETS, name: Nadia.Examples.ConversationBot.Sessions})

    start = message_update("/start")
    start_context = Context.new(start, client)

    assert :ok = Nadia.Examples.ConversationBot.handle_update(start, start_context)
    assert_receive {:nadia_request, _request}

    assert {:ok, key} = SessionStore.chat_user_key(start_context)
    assert {:ok, %{step: :name}} = SessionStore.get(Nadia.Examples.ConversationBot.store(), key)

    name = message_update("Ada", 2)
    assert :ok = Nadia.Examples.ConversationBot.handle_update(name, Context.new(name, client))
    assert_receive {:nadia_request, _request}

    assert {:ok, %{step: :email, name: "Ada"}} =
             SessionStore.get(Nadia.Examples.ConversationBot.store(), key)

    email = message_update("ada@example.com", 3)
    assert :ok = Nadia.Examples.ConversationBot.handle_update(email, Context.new(email, client))
    assert_receive {:nadia_request, _request}

    assert {:ok, %{}} = SessionStore.get(Nadia.Examples.ConversationBot.store(), key)
  end

  defp message_update(text, update_id \\ 1) do
    %Update{
      update_id: update_id,
      message: message(text)
    }
  end

  defp callback_update(data) do
    %Update{
      update_id: 10,
      callback_query: %CallbackQuery{
        id: "callback-1",
        data: data,
        from: user(),
        message: message(nil)
      }
    }
  end

  defp message(text) do
    %Message{
      message_id: 1,
      date: 1_700_000_000,
      text: text,
      from: user(),
      chat: %Chat{id: 123, type: "private"}
    }
  end

  defp user, do: %User{id: 456, first_name: "User"}
end
