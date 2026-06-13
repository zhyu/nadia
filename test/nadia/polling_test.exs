defmodule Nadia.PollingTest do
  use ExUnit.Case, async: false

  alias Nadia.Client
  alias Nadia.Context
  alias Nadia.Model.{Chat, Error, Message, Update, User}
  alias Nadia.Polling

  defmodule FakeAPI do
    def get_updates(options, state), do: request(nil, options, state)
    def get_updates(client, options, state), do: request(client, options, state)

    defp request(client, options, {agent, owner}) do
      send(owner, {:poll_request, client, options})

      Agent.get_and_update(agent, fn
        [response | rest] -> {response, rest}
        [] -> {{:ok, []}, []}
      end)
    end
  end

  defmodule RecordingHandler do
    @behaviour Nadia.Handler

    @impl Nadia.Handler
    def handle_update(%Update{} = update, %Context{} = context) do
      send(test_owner(), {:handled, update.update_id, context})

      case context.message && context.message.text do
        "error" -> {:error, :handler_failed}
        "raise" -> raise "handler crashed"
        _ -> :ok
      end
    end

    defp test_owner do
      Application.fetch_env!(:nadia, :polling_test_owner)
    end
  end

  setup do
    previous_owner = Application.get_env(:nadia, :polling_test_owner)
    previous_bots = Application.get_env(:nadia, :bots)

    Application.put_env(:nadia, :polling_test_owner, self())

    on_exit(fn ->
      restore_env(:polling_test_owner, previous_owner)
      restore_env(:bots, previous_bots)
    end)

    :ok
  end

  test "polls getUpdates, dispatches sequentially, and advances offset" do
    client = Client.new(token: "123:explicit")

    pid =
      start_polling!(
        [
          allowed_updates: ["message", "callback_query"],
          client: client,
          limit: 2,
          poll_interval_ms: 10,
          timeout: 30
        ],
        [
          {:ok, [message_update(10, "first"), message_update(11, "second")]},
          {:ok, []}
        ]
      )

    assert_receive {:poll_request, ^client, request_options}
    assert Keyword.get(request_options, :timeout) == 30
    assert Keyword.get(request_options, :limit) == 2

    assert Keyword.get(request_options, :allowed_updates) == ["message", "callback_query"]

    refute Keyword.has_key?(request_options, :offset)

    assert_receive {:handled, 10, %Context{client: ^client, message: %Message{text: "first"}}}
    assert_receive {:handled, 11, %Context{client: ^client, message: %Message{text: "second"}}}

    assert_receive {:poll_request, ^client, next_request_options}
    assert Keyword.get(next_request_options, :offset) == 12

    GenServer.stop(pid)
  end

  test "does not advance a failed handler update and retries from the failed offset" do
    pid =
      start_polling!(
        [backoff_ms: 5, max_backoff_ms: 5, poll_interval_ms: 1_000],
        [
          {:ok, [message_update(20, "ok"), message_update(21, "error")]},
          {:ok, []}
        ]
      )

    assert_receive {:poll_request, nil, first_request_options}
    refute Keyword.has_key?(first_request_options, :offset)

    assert_receive {:handled, 20, %Context{message: %Message{text: "ok"}}}
    assert_receive {:handled, 21, %Context{message: %Message{text: "error"}}}

    assert_receive {:poll_request, nil, retry_request_options}
    assert Keyword.get(retry_request_options, :offset) == 21

    GenServer.stop(pid)
  end

  test "backs off after getUpdates errors without changing offset" do
    pid =
      start_polling!(
        [backoff_ms: 5, max_backoff_ms: 5, offset: 50, poll_interval_ms: 1_000],
        [
          {:error, %Error{reason: "timeout"}},
          {:ok, []}
        ]
      )

    assert_receive {:poll_request, nil, first_request_options}
    assert Keyword.get(first_request_options, :offset) == 50

    assert_receive {:poll_request, nil, retry_request_options}
    assert Keyword.get(retry_request_options, :offset) == 50

    GenServer.stop(pid)
  end

  test "resolves named bot clients and passes them to contexts" do
    Application.put_env(:nadia, :bots,
      support: [
        token: "support-token",
        http_client: Nadia.HTTPCase.StubHTTPClient
      ]
    )

    pid =
      start_polling!(
        [client: :support, poll_interval_ms: 1_000],
        [
          {:ok, [message_update(30, "named")]}
        ]
      )

    assert_receive {:poll_request, %Client{token: "support-token"} = client, _request_options}
    assert_receive {:handled, 30, %Context{client: ^client, message: %Message{text: "named"}}}

    GenServer.stop(pid)
  end

  test "supports a registered process name and clean stop" do
    name = Module.concat(__MODULE__, NamedPolling)

    pid =
      start_polling!(
        [name: name, poll_interval_ms: 1_000],
        [
          {:ok, []}
        ]
      )

    assert Process.whereis(name) == pid
    assert :ok = GenServer.stop(pid)
    refute Process.alive?(pid)
  end

  test "handler exceptions back off without advancing past the failed update" do
    pid =
      start_polling!(
        [backoff_ms: 5, max_backoff_ms: 5, poll_interval_ms: 1_000],
        [
          {:ok,
           [message_update(40, "ok"), message_update(41, "raise"), message_update(42, "later")]},
          {:ok, []}
        ]
      )

    ref = Process.monitor(pid)

    assert_receive {:poll_request, nil, first_request_options}
    refute Keyword.has_key?(first_request_options, :offset)

    assert_receive {:handled, 40, %Context{message: %Message{text: "ok"}}}
    assert_receive {:handled, 41, %Context{message: %Message{text: "raise"}}}
    refute_receive {:handled, 42, _context}, 20

    assert_receive {:poll_request, nil, retry_request_options}
    assert Keyword.get(retry_request_options, :offset) == 41
    refute_receive {:DOWN, ^ref, :process, ^pid, _reason}, 20

    Process.demonitor(ref, [:flush])
    GenServer.stop(pid)
  end

  defp start_polling!(opts, responses) do
    agent = start_supervised!({Agent, fn -> responses end})

    opts =
      Keyword.merge(
        [
          api: {FakeAPI, {agent, self()}},
          backoff_ms: 10,
          handler: RecordingHandler,
          log_errors: false,
          max_backoff_ms: 10,
          timeout: 0
        ],
        opts
      )

    start_supervised!({Polling, opts})
  end

  defp message_update(update_id, text) do
    %Update{
      update_id: update_id,
      message: %Message{
        message_id: update_id * 10,
        text: text,
        from: %User{id: 20, first_name: "Nadia"},
        chat: %Chat{id: 30, type: "private"}
      }
    }
  end

  defp restore_env(key, nil), do: Application.delete_env(:nadia, key)
  defp restore_env(key, value), do: Application.put_env(:nadia, key, value)
end
