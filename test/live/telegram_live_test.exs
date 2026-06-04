defmodule Nadia.TelegramLiveTest do
  use ExUnit.Case, async: false

  alias Nadia.Client
  alias Nadia.Model.{Message, Update, User}

  @moduletag :telegram_live

  @required_env [
    "NADIA_LIVE_BOT_A_TOKEN",
    "NADIA_LIVE_BOT_A_USERNAME",
    "NADIA_LIVE_BOT_B_TOKEN",
    "NADIA_LIVE_BOT_B_USERNAME"
  ]

  @missing_env Enum.reject(@required_env, &System.get_env/1)

  if @missing_env != [] do
    @moduletag skip: "set #{Enum.join(@missing_env, ", ")} to run live Telegram tests"
  end

  setup_all do
    if @missing_env == [] do
      bot_a = live_client("NADIA_LIVE_BOT_A_TOKEN")
      bot_b = live_client("NADIA_LIVE_BOT_B_TOKEN")

      {:ok,
       bot_a: bot_a,
       bot_a_username: live_username("NADIA_LIVE_BOT_A_USERNAME"),
       bot_b: bot_b,
       bot_b_username: live_username("NADIA_LIVE_BOT_B_USERNAME")}
    else
      :ok
    end
  end

  setup %{bot_a: bot_a, bot_b: bot_b} do
    clear_updates(bot_a)
    clear_updates(bot_b)

    on_exit(fn ->
      clear_updates(bot_a)
      clear_updates(bot_b)
    end)

    :ok
  end

  test "get_me returns both configured bot identities", %{
    bot_a: bot_a,
    bot_a_username: bot_a_username,
    bot_b: bot_b,
    bot_b_username: bot_b_username
  } do
    assert {:ok, %User{username: ^bot_a_username}} = Nadia.get_me(bot_a)
    assert {:ok, %User{username: ^bot_b_username}} = Nadia.get_me(bot_b)
  end

  test "two explicit bot clients can exchange messages by username", %{
    bot_a: bot_a,
    bot_a_username: bot_a_username,
    bot_b: bot_b,
    bot_b_username: bot_b_username
  } do
    nonce = "nadia-live-#{System.unique_integer([:positive])}"
    bot_a_text = "#{nonce} from #{bot_a_username}"
    bot_b_text = "#{nonce} from #{bot_b_username}"

    assert {:ok, %Message{text: ^bot_a_text}} =
             Nadia.send_message(bot_a, mention(bot_b_username), bot_a_text)

    assert {:ok, %Update{message: %Message{text: ^bot_a_text}}} =
             wait_for_message(bot_b, bot_a_text)

    assert {:ok, %Message{text: ^bot_b_text}} =
             Nadia.send_message(bot_b, mention(bot_a_username), bot_b_text)

    assert {:ok, %Update{message: %Message{text: ^bot_b_text}}} =
             wait_for_message(bot_a, bot_b_text)
  end

  defp live_client(token_env) do
    Client.new(token: System.fetch_env!(token_env), api_environment: api_environment())
  end

  defp live_username(username_env) do
    username_env
    |> System.fetch_env!()
    |> String.trim_leading("@")
  end

  defp api_environment do
    case System.get_env("NADIA_LIVE_API_ENV") do
      "test" -> :test
      _ -> :production
    end
  end

  defp mention(username), do: "@" <> String.trim_leading(username, "@")

  defp clear_updates(%Client{} = client) do
    case Nadia.get_updates(client, timeout: 0, limit: 100) do
      {:ok, []} ->
        :ok

      {:ok, updates} ->
        _ = Nadia.get_updates(client, offset: next_offset(updates), timeout: 0, limit: 1)
        :ok

      {:error, error} ->
        flunk("failed to clear live Telegram updates: #{inspect(error)}")
    end
  end

  defp wait_for_message(client, text), do: wait_for_message(client, text, nil, 8)

  defp wait_for_message(_client, text, _offset, 0) do
    flunk("timed out waiting for live Telegram message: #{inspect(text)}")
  end

  defp wait_for_message(client, text, offset, attempts_left) do
    options = [timeout: 2, limit: 100] ++ offset_option(offset)

    case Nadia.get_updates(client, options) do
      {:ok, updates} ->
        case Enum.find(updates, &message_text?(&1, text)) do
          nil ->
            Process.sleep(500)
            wait_for_message(client, text, next_offset(updates) || offset, attempts_left - 1)

          update ->
            {:ok, update}
        end

      {:error, error} ->
        flunk("failed to poll live Telegram updates: #{inspect(error)}")
    end
  end

  defp offset_option(nil), do: []
  defp offset_option(offset), do: [offset: offset]

  defp next_offset([]), do: nil

  defp next_offset(updates) do
    updates
    |> Enum.map(& &1.update_id)
    |> Enum.max()
    |> Kernel.+(1)
  end

  defp message_text?(%Update{message: %Message{text: text}}, text), do: true
  defp message_text?(_update, _text), do: false
end
