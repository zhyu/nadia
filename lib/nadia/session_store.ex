defmodule Nadia.SessionStore do
  @moduledoc """
  Behaviour and helpers for optional bot session storage.

  Session storage is deliberately explicit. Nadia does not start or name a
  global session store for you; applications supervise a store backend and pass
  that store to their handlers when they need state.

      children = [
        {Nadia.SessionStore.ETS, name: MyApp.BotSessions}
      ]

      store = {Nadia.SessionStore.ETS, MyApp.BotSessions}
      {:ok, key} = Nadia.SessionStore.chat_key(context)
      {:ok, session} = Nadia.SessionStore.update(store, key, fn session ->
        Map.update(session, :seen, 1, &(&1 + 1))
      end)

  The built-in ETS backend is intended for local development and single-node
  bots. Production applications can implement this behaviour with their own
  storage when they need persistence, cross-node consistency, or stronger
  concurrency guarantees.
  """

  alias Nadia.Context
  alias Nadia.Model.{Update, User}

  @typedoc """
  Session keys used by Nadia helper functions.
  """
  @type key ::
          {:chat, integer | binary}
          | {:user, integer}
          | {:chat_user, integer | binary, integer}

  @typedoc """
  A session value.

  Nadia keeps sessions as maps so backends can store arbitrary application
  state without Nadia prescribing a schema.
  """
  @type session :: map

  @typedoc """
  A concrete store reference.

  The first element is the backend module implementing this behaviour. The
  second element is backend-specific state, such as a pid or registered process
  name for `Nadia.SessionStore.ETS`.
  """
  @type store :: {module, term}

  @type update_or_context :: Update.t() | Context.t()

  @callback get(store_state :: term, key) :: {:ok, session} | {:error, term}
  @callback put(store_state :: term, key, session) :: :ok | {:error, term}
  @callback update(store_state :: term, key, (session ->
                                                session | {:ok, session} | {:error, term})) ::
              {:ok, session} | {:error, term}
  @callback delete(store_state :: term, key) :: :ok | {:error, term}

  @doc """
  Reads a session from a store.

  Missing sessions return `{:ok, %{}}`.
  """
  @spec get(store, key) :: {:ok, session} | {:error, term}
  def get({backend, store_state}, key) when is_atom(backend) do
    backend.get(store_state, key)
  end

  def get(_store, _key), do: {:error, :invalid_store}

  @doc """
  Writes a complete session map to a store.
  """
  @spec put(store, key, session) :: :ok | {:error, term}
  def put(_store, _key, session) when not is_map(session), do: {:error, :invalid_session}

  def put({backend, store_state}, key, session) when is_atom(backend) do
    backend.put(store_state, key, session)
  end

  def put(_store, _key, _session), do: {:error, :invalid_store}

  @doc """
  Atomically updates a session in a store when the backend supports it.

  The update function receives the current session map, or `%{}` when the
  session is missing. It may return a new session map, `{:ok, session}`, or
  `{:error, reason}`. Error returns do not write a new value.

  Backend implementations may execute the function inside a serialized server
  or storage transaction. Keep it short and free of external side effects, and
  do not call the same serialized store from inside the function.
  """
  @spec update(store, key, (session -> session | {:ok, session} | {:error, term})) ::
          {:ok, session} | {:error, term}
  def update({backend, store_state}, key, fun) when is_atom(backend) and is_function(fun, 1) do
    backend.update(store_state, key, fun)
  end

  def update(_store, _key, fun) when is_function(fun, 1), do: {:error, :invalid_store}
  def update(_store, _key, _fun), do: {:error, :invalid_update}

  @doc """
  Deletes a session from a store.
  """
  @spec delete(store, key) :: :ok | {:error, term}
  def delete({backend, store_state}, key) when is_atom(backend) do
    backend.delete(store_state, key)
  end

  def delete(_store, _key), do: {:error, :invalid_store}

  @doc """
  Builds a chat-scoped session key from a context or update.
  """
  @spec chat_key(update_or_context) :: {:ok, key} | {:error, :missing_chat_id}
  def chat_key(update_or_context) do
    case Context.chat_id(update_or_context) do
      chat_id when is_integer(chat_id) or is_binary(chat_id) -> {:ok, {:chat, chat_id}}
      _ -> {:error, :missing_chat_id}
    end
  end

  @doc """
  Builds a user-scoped session key from a context or update.
  """
  @spec user_key(update_or_context) :: {:ok, key} | {:error, :missing_user_id}
  def user_key(update_or_context) do
    case Context.effective_user(update_or_context) do
      %User{id: user_id} when is_integer(user_id) -> {:ok, {:user, user_id}}
      _ -> {:error, :missing_user_id}
    end
  end

  @doc """
  Builds a combined chat/user session key from a context or update.
  """
  @spec chat_user_key(update_or_context) ::
          {:ok, key} | {:error, :missing_chat_id | :missing_user_id}
  def chat_user_key(update_or_context) do
    with {:ok, {:chat, chat_id}} <- chat_key(update_or_context),
         {:ok, {:user, user_id}} <- user_key(update_or_context) do
      {:ok, {:chat_user, chat_id, user_id}}
    end
  end
end
