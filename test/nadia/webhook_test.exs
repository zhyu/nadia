defmodule Nadia.WebhookTest do
  use ExUnit.Case, async: true

  alias Nadia.Client
  alias Nadia.Context
  alias Nadia.Model.{Message, Update}
  alias Nadia.Webhook

  defmodule TestHandler do
    @behaviour Nadia.Handler

    @impl Nadia.Handler
    def handle_update(%Update{} = update, %Context{} = context) do
      send(self(), {:webhook_update, update, context})
      {:ok, :handled}
    end
  end

  defmodule RaisingHandler do
    @behaviour Nadia.Handler

    @impl Nadia.Handler
    def handle_update(_update, _context), do: raise("webhook failed")
  end

  describe "parse_body/1" do
    test "parses raw Telegram webhook JSON bodies" do
      assert {:ok, %Update{update_id: 100, message: %Message{text: "hello"}}} =
               Webhook.parse_body(update_body("hello"))
    end

    test "parses decoded maps and existing updates" do
      decoded = Jason.decode!(update_body("hello"))

      assert {:ok, %Update{} = update} = Webhook.parse_body(decoded)
      assert Webhook.parse_body(update) == {:ok, update}
    end

    test "returns parser errors" do
      assert {:error, %Jason.DecodeError{}} = Webhook.parse_body("{")
      assert_raise Jason.DecodeError, fn -> Webhook.parse_body!("{") end
    end
  end

  describe "verify_secret/2" do
    test "passes when no expected secret is configured" do
      assert :ok = Webhook.verify_secret([], nil)
    end

    test "checks Telegram secret token headers case-insensitively" do
      assert :ok =
               Webhook.verify_secret(
                 [{"X-Telegram-Bot-Api-Secret-Token", "secret"}],
                 "secret"
               )

      assert :ok =
               Webhook.verify_secret(
                 %{x_telegram_bot_api_secret_token: ["secret"]},
                 "secret"
               )
    end

    test "rejects missing or mismatched secrets" do
      assert {:error, :invalid_secret_token} = Webhook.verify_secret([], "secret")

      assert {:error, :invalid_secret_token} =
               Webhook.verify_secret([{"x-telegram-bot-api-secret-token", "wrong"}], "secret")
    end
  end

  describe "context/2" do
    test "builds a context with an explicit client after secret verification" do
      client = Client.new(token: "123:explicit")

      assert {:ok, %Context{client: ^client, message: %Message{text: "hello"}}} =
               Webhook.context(update_body("hello"),
                 headers: [{"x-telegram-bot-api-secret-token", "secret"}],
                 secret_token: "secret",
                 client: client
               )
    end
  end

  describe "dispatch_body/3" do
    test "verifies, parses, builds context, and dispatches to a handler" do
      client = Client.new(token: "123:explicit")

      assert {:ok, :handled} =
               Webhook.dispatch_body(update_body("hello"), TestHandler,
                 headers: [{"x-telegram-bot-api-secret-token", "secret"}],
                 secret_token: "secret",
                 client: client
               )

      assert_receive {:webhook_update, %Update{update_id: 100},
                      %Context{client: ^client, message: %Message{text: "hello"}}}
    end

    test "dispatches to route lists" do
      routes = [
        {:text, "hello",
         fn context ->
           send(self(), {:route_context, context})
           :ok
         end}
      ]

      assert :ok = Webhook.dispatch_body(update_body("hello"), routes)
      assert_receive {:route_context, %Context{message: %Message{text: "hello"}}}
    end

    test "passes bot username options through route matching" do
      routes = [
        {:command, "start",
         fn _context, match ->
           send(self(), {:command_match, match})
           :ok
         end}
      ]

      assert :ok =
               Webhook.dispatch_body(update_body("/start@nadia_bot"), routes,
                 bot_username: "nadia_bot"
               )

      assert_receive {:command_match, %{command: "start", bot: "nadia_bot"}}
    end

    test "does not parse or dispatch when secret verification fails" do
      assert {:error, :invalid_secret_token} =
               Webhook.dispatch_body("not json", TestHandler,
                 headers: [{"x-telegram-bot-api-secret-token", "wrong"}],
                 secret_token: "secret"
               )

      refute_receive {:webhook_update, _update, _context}
    end

    test "lets handler exceptions bubble" do
      assert_raise RuntimeError, "webhook failed", fn ->
        Webhook.dispatch_body(update_body("hello"), RaisingHandler)
      end
    end
  end

  test "exposes Telegram's secret header name" do
    assert Webhook.secret_token_header() == "x-telegram-bot-api-secret-token"
  end

  defp update_body(text) do
    Jason.encode!(%{
      update_id: 100,
      message: %{
        message_id: 10,
        date: 1_700_000_000,
        text: text,
        chat: %{id: 123, type: "private"}
      }
    })
  end
end
