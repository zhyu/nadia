Code.require_file("../../examples/database_session_store.ex", __DIR__)

defmodule Nadia.DatabaseSessionStoreExampleTest do
  use ExUnit.Case, async: true

  alias Nadia.Examples.DatabaseSessionStore
  alias Nadia.SessionStore

  defmodule FakeRepository do
    @behaviour DatabaseSessionStore.Repository

    def start_link(_options) do
      Agent.start_link(fn ->
        %{
          sessions: %{},
          processed: MapSet.new(),
          outbox: %{},
          forced_conflicts: 0,
          forced_failure: nil,
          conflict_count: 0,
          fetch_delay: 0
        }
      end)
    end

    @impl true
    def fetch_session(repo, namespace, key) do
      case Agent.get(repo, fn state ->
             {Map.get(state.sessions, {namespace, key}), state.fetch_delay}
           end) do
        {row, delay} ->
          if delay > 0, do: Process.sleep(delay)
          {:ok, row}
      end
    end

    @impl true
    def transaction(repo, operations) do
      Agent.get_and_update(repo, fn state ->
        cond do
          state.forced_conflicts > 0 ->
            state = %{
              state
              | forced_conflicts: state.forced_conflicts - 1,
                conflict_count: state.conflict_count + 1
            }

            {{:error, :conflict}, state}

          state.forced_failure != nil ->
            reason = state.forced_failure
            {{:error, reason}, %{state | forced_failure: nil}}

          true ->
            case apply_operations(operations, state) do
              {:ok, next_state} ->
                {:ok, next_state}

              {:error, :conflict} ->
                {{:error, :conflict}, %{state | conflict_count: state.conflict_count + 1}}

              {:error, reason} ->
                {{:error, reason}, state}
            end
        end
      end)
    end

    def force_conflicts(repo, count),
      do: Agent.update(repo, &%{&1 | forced_conflicts: count})

    def fail_next(repo, reason), do: Agent.update(repo, &%{&1 | forced_failure: reason})
    def fetch_delay(repo, delay), do: Agent.update(repo, &%{&1 | fetch_delay: delay})
    def snapshot(repo), do: Agent.get(repo, & &1)

    def corrupt(repo, namespace, key, row) do
      Agent.update(repo, &put_in(&1.sessions[{namespace, key}], row))
    end

    defp apply_operations(operations, state) do
      Enum.reduce_while(operations, {:ok, state}, fn operation, {:ok, state} ->
        case apply_operation(operation, state) do
          {:ok, state} -> {:cont, {:ok, state}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end

    defp apply_operation({:put_session, namespace, key, :any, session}, state) do
      storage_key = {namespace, key}

      version =
        case Map.get(state.sessions, storage_key),
          do: (
            nil -> 0
            row -> row.version + 1
          )

      row = %{version: version, session: session}
      {:ok, %{state | sessions: Map.put(state.sessions, storage_key, row)}}
    end

    defp apply_operation({:put_session, namespace, key, :missing, session}, state) do
      storage_key = {namespace, key}

      if Map.has_key?(state.sessions, storage_key) do
        {:error, :conflict}
      else
        row = %{version: 0, session: session}
        {:ok, %{state | sessions: Map.put(state.sessions, storage_key, row)}}
      end
    end

    defp apply_operation({:put_session, namespace, key, expected, session}, state)
         when is_integer(expected) do
      storage_key = {namespace, key}

      case Map.get(state.sessions, storage_key) do
        %{version: ^expected} ->
          row = %{version: expected + 1, session: session}
          {:ok, %{state | sessions: Map.put(state.sessions, storage_key, row)}}

        _row ->
          {:error, :conflict}
      end
    end

    defp apply_operation({:delete_session, namespace, key}, state) do
      {:ok, %{state | sessions: Map.delete(state.sessions, {namespace, key})}}
    end

    defp apply_operation({:record_update, bot_ref, update_id}, state) do
      identity = {bot_ref, update_id}

      if MapSet.member?(state.processed, identity) do
        {:error, :duplicate_update}
      else
        {:ok, %{state | processed: MapSet.put(state.processed, identity)}}
      end
    end

    defp apply_operation({:enqueue_outbox, row}, state) do
      id = Map.get(row, :id) || Map.fetch!(row, "id")

      if Map.has_key?(state.outbox, id) do
        {:error, :duplicate_outbox_id}
      else
        {:ok, %{state | outbox: Map.put(state.outbox, id, row)}}
      end
    end
  end

  setup do
    repo =
      start_supervised!(%{
        id: make_ref(),
        start: {FakeRepository, :start_link, [[]]}
      })

    backend = DatabaseSessionStore.new(FakeRepository, repo, namespace: "bot-a")
    %{repo: repo, backend: backend, store: {DatabaseSessionStore, backend}}
  end

  test "persists in the repository across backend values and supports deletion", context do
    key = {:chat, 123}
    assert {:ok, %{}} = SessionStore.get(context.store, key)
    assert :ok = SessionStore.put(context.store, key, %{step: :ready})

    rebuilt = DatabaseSessionStore.new(FakeRepository, context.repo, namespace: "bot-a")
    assert {:ok, %{step: :ready}} = SessionStore.get({DatabaseSessionStore, rebuilt}, key)

    assert :ok = SessionStore.delete(context.store, key)
    assert {:ok, %{}} = SessionStore.get(context.store, key)
  end

  test "contested optimistic updates preserve every increment", context do
    backend = %{context.backend | conflict_retries: 30}
    store = {DatabaseSessionStore, backend}
    key = {:chat, 500}
    assert :ok = SessionStore.put(store, key, %{count: 0})
    FakeRepository.fetch_delay(context.repo, 1)

    results =
      1..20
      |> Task.async_stream(
        fn _index ->
          SessionStore.update(store, key, fn session ->
            Map.update!(session, :count, &(&1 + 1))
          end)
        end,
        max_concurrency: 20,
        ordered: false
      )
      |> Enum.to_list()

    assert Enum.all?(results, &match?({:ok, {:ok, %{count: _count}}}, &1))
    assert {:ok, %{count: 20}} = SessionStore.get(store, key)
    assert FakeRepository.snapshot(context.repo).conflict_count > 0
  end

  test "retries only conflicts within the configured bound", context do
    key = {:chat, 600}
    backend = %{context.backend | conflict_retries: 2}
    store = {DatabaseSessionStore, backend}
    assert :ok = SessionStore.put(store, key, %{count: 0})
    {:ok, calls} = Agent.start_link(fn -> 0 end)

    update = fn session ->
      Agent.update(calls, &(&1 + 1))
      Map.update!(session, :count, &(&1 + 1))
    end

    FakeRepository.force_conflicts(context.repo, 2)
    assert {:ok, %{count: 1}} = SessionStore.update(store, key, update)
    assert Agent.get(calls, & &1) == 3

    FakeRepository.force_conflicts(context.repo, 3)
    assert {:error, :conflict_retries_exhausted} = SessionStore.update(store, key, update)
    assert Agent.get(calls, & &1) == 6
    assert {:ok, %{count: 1}} = SessionStore.get(store, key)
  end

  test "callback and repository failures preserve the stored session", context do
    key = {:chat, 700}
    assert :ok = SessionStore.put(context.store, key, %{step: :current})

    assert {:error, :stop} =
             SessionStore.update(context.store, key, fn _session -> {:error, :stop} end)

    assert {:error, %RuntimeError{message: "boom"}} =
             SessionStore.update(context.store, key, fn _session -> raise "boom" end)

    assert {:error, :invalid_session} =
             SessionStore.update(context.store, key, fn _session -> :invalid end)

    FakeRepository.fail_next(context.repo, :database_unavailable)

    assert {:error, :database_unavailable} =
             SessionStore.update(context.store, key, fn _session -> %{step: :changed} end)

    assert {:ok, %{step: :current}} = SessionStore.get(context.store, key)
  end

  test "records idempotency and outbox intent in the same repository transaction", context do
    key = {:chat, 800}
    outbox = [%{id: "send-800", method: "sendMessage", params: %{chat_id: 800}}]
    update = fn session -> Map.update(session, :handled, 1, &(&1 + 1)) end

    assert {:ok, %{handled: 1}} =
             DatabaseSessionStore.process_update(
               context.backend,
               "primary-bot",
               9001,
               key,
               update,
               outbox
             )

    assert {:ok, :duplicate} =
             DatabaseSessionStore.process_update(
               context.backend,
               "primary-bot",
               9001,
               key,
               update,
               [%{id: "ignored-duplicate"}]
             )

    assert {:ok, %{handled: 2}} =
             DatabaseSessionStore.process_update(
               context.backend,
               "secondary-bot",
               9001,
               key,
               update,
               [%{id: "send-secondary-800"}]
             )

    snapshot = FakeRepository.snapshot(context.repo)
    assert MapSet.size(snapshot.processed) == 2
    assert Map.keys(snapshot.outbox) |> Enum.sort() == ["send-800", "send-secondary-800"]
    assert {:ok, %{handled: 2}} = SessionStore.get(context.store, key)
  end

  test "failed update transactions roll back session, marker, and outbox", context do
    key = {:chat, 900}
    FakeRepository.fail_next(context.repo, :commit_failed)

    assert {:error, :commit_failed} =
             DatabaseSessionStore.process_update(
               context.backend,
               "primary-bot",
               9002,
               key,
               fn _session -> %{handled: true} end,
               [%{id: "send-900"}]
             )

    snapshot = FakeRepository.snapshot(context.repo)
    assert snapshot.processed == MapSet.new()
    assert snapshot.outbox == %{}
    assert {:ok, %{}} = SessionStore.get(context.store, key)
  end

  test "isolates namespaces and rejects malformed repository rows", context do
    key = {:chat, 1000}
    other = DatabaseSessionStore.new(FakeRepository, context.repo, namespace: "bot-b")

    assert :ok = SessionStore.put(context.store, key, %{bot: :a})
    assert :ok = SessionStore.put({DatabaseSessionStore, other}, key, %{bot: :b})
    assert {:ok, %{bot: :a}} = SessionStore.get(context.store, key)
    assert {:ok, %{bot: :b}} = SessionStore.get({DatabaseSessionStore, other}, key)

    FakeRepository.corrupt(context.repo, "bot-a", key, %{version: "bad", session: %{}})
    assert {:error, :invalid_repository_record} = SessionStore.get(context.store, key)
  end
end
