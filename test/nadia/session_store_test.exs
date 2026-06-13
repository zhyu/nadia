defmodule Nadia.SessionStoreTest do
  use ExUnit.Case, async: true

  alias Nadia.Context
  alias Nadia.Model.{Chat, InlineQuery, Message, Poll, Update, User}
  alias Nadia.SessionStore
  alias Nadia.SessionStore.ETS

  describe "ETS store" do
    setup do
      pid = start_supervised!({ETS, []})
      {:ok, store: {ETS, pid}}
    end

    test "returns an empty session for missing keys", %{store: store} do
      assert {:ok, %{}} = SessionStore.get(store, {:chat, 123})
    end

    test "puts, updates, and deletes session maps", %{store: store} do
      key = {:chat, 123}

      assert :ok = SessionStore.put(store, key, %{step: :started})
      assert {:ok, %{step: :started}} = SessionStore.get(store, key)

      assert {:ok, %{step: :started, count: 1}} =
               SessionStore.update(store, key, fn session ->
                 Map.update(session, :count, 1, &(&1 + 1))
               end)

      assert {:ok, %{step: :started, count: 2}} =
               SessionStore.update(store, key, fn session ->
                 {:ok, Map.update!(session, :count, &(&1 + 1))}
               end)

      assert :ok = SessionStore.delete(store, key)
      assert {:ok, %{}} = SessionStore.get(store, key)
    end

    test "does not mutate stored sessions when update returns an error", %{store: store} do
      key = {:chat, 123}

      assert :ok = SessionStore.put(store, key, %{step: :started})
      assert {:error, :stop} = SessionStore.update(store, key, fn _session -> {:error, :stop} end)

      assert {:ok, %{step: :started}} = SessionStore.get(store, key)
    end

    test "rejects non-map session values", %{store: store} do
      key = {:chat, 123}

      assert {:error, :invalid_session} = SessionStore.put(store, key, :started)
      assert :ok = SessionStore.put(store, key, %{step: :started})

      assert {:error, :invalid_session} =
               SessionStore.update(store, key, fn _session -> :started end)

      assert {:ok, %{step: :started}} = SessionStore.get(store, key)
    end

    test "keeps the store alive when update functions fail", %{store: {ETS, pid} = store} do
      key = {:chat, 123}

      assert :ok = SessionStore.put(store, key, %{step: :started})

      assert {:error, %RuntimeError{message: "boom"}} =
               SessionStore.update(store, key, fn _ -> raise "boom" end)

      assert Process.alive?(pid)
      assert {:ok, %{step: :started}} = SessionStore.get(store, key)
    end

    test "keeps stores isolated instead of using hidden global state", %{store: first_store} do
      second_pid = start_supervised!({ETS, [id: {__MODULE__, :second_store}]})
      second_store = {ETS, second_pid}
      key = {:chat, 123}

      assert :ok = SessionStore.put(first_store, key, %{store: :first})

      assert {:ok, %{store: :first}} = SessionStore.get(first_store, key)
      assert {:ok, %{}} = SessionStore.get(second_store, key)
    end

    test "supports registered process names for supervised applications" do
      name = Module.concat(__MODULE__, RegisteredStore)
      store = {ETS, name}

      start_supervised!({ETS, [id: name, name: name]})

      assert :ok = SessionStore.put(store, {:user, 20}, %{step: :ready})
      assert {:ok, %{step: :ready}} = SessionStore.get(store, {:user, 20})
    end
  end

  describe "store facade" do
    test "returns explicit errors for invalid store references" do
      assert {:error, :invalid_store} = SessionStore.get(:missing_store, {:chat, 123})
      assert {:error, :invalid_store} = SessionStore.put(:missing_store, {:chat, 123}, %{})

      assert {:error, :invalid_store} =
               SessionStore.update(:missing_store, {:chat, 123}, fn session -> session end)

      assert {:error, :invalid_store} = SessionStore.delete(:missing_store, {:chat, 123})
    end
  end

  describe "session key helpers" do
    test "build chat, user, and chat_user keys from updates" do
      update = message_update()

      assert {:ok, {:chat, 30}} = SessionStore.chat_key(update)
      assert {:ok, {:user, 20}} = SessionStore.user_key(update)
      assert {:ok, {:chat_user, 30, 20}} = SessionStore.chat_user_key(update)
    end

    test "build keys from contexts" do
      context = Context.new(message_update())

      assert {:ok, {:chat, 30}} = SessionStore.chat_key(context)
      assert {:ok, {:user, 20}} = SessionStore.user_key(context)
      assert {:ok, {:chat_user, 30, 20}} = SessionStore.chat_user_key(context)
    end

    test "reports missing key parts explicitly" do
      user = %User{id: 20, first_name: "Inline"}
      inline_update = %Update{inline_query: %InlineQuery{id: "inline-1", from: user}}
      no_user_update = %Update{poll: %Poll{id: "poll-1"}}

      assert {:error, :missing_chat_id} = SessionStore.chat_key(inline_update)
      assert {:ok, {:user, 20}} = SessionStore.user_key(inline_update)
      assert {:error, :missing_chat_id} = SessionStore.chat_user_key(inline_update)

      assert {:error, :missing_user_id} = SessionStore.user_key(no_user_update)
      assert {:error, :missing_chat_id} = SessionStore.chat_user_key(no_user_update)
    end
  end

  defp message_update do
    %Update{
      update_id: 1,
      message: %Message{
        message_id: 10,
        text: "hello",
        from: %User{id: 20, first_name: "Nadia"},
        chat: %Chat{id: 30, type: "private"}
      }
    }
  end
end
