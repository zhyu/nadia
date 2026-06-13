defmodule Nadia.SessionStore.ETS do
  @moduledoc """
  Local ETS-backed session store for Nadia bot handlers.

  `Nadia.SessionStore.ETS` is an explicit, supervised process. It owns a
  private ETS table and implements `Nadia.SessionStore` for local development
  and simple single-node bots.

      {:ok, pid} = Nadia.SessionStore.ETS.start_link([])
      store = {Nadia.SessionStore.ETS, pid}
      Nadia.SessionStore.put(store, {:chat, 123}, %{step: :waiting_for_name})

  For application supervision, prefer a registered process name:

      children = [
        {Nadia.SessionStore.ETS, name: MyApp.BotSessions}
      ]

      store = {Nadia.SessionStore.ETS, MyApp.BotSessions}

  This store is not persistent or distributed. Use a custom
  `Nadia.SessionStore` backend when sessions must survive restarts or be shared
  across nodes.
  """

  use GenServer

  @behaviour Nadia.SessionStore

  defstruct table: nil

  @type option :: {:name, GenServer.name()} | {:id, term}

  @doc """
  Starts a local ETS session store.
  """
  @spec start_link([option]) :: GenServer.on_start()
  def start_link(opts \\ []) when is_list(opts) do
    GenServer.start_link(__MODULE__, opts, Keyword.take(opts, [:name]))
  end

  @doc false
  @spec child_spec([option]) :: Supervisor.child_spec()
  def child_spec(opts) do
    %{
      id: Keyword.get(opts, :id, __MODULE__),
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 5_000
    }
  end

  @impl Nadia.SessionStore
  def get(server, key) do
    GenServer.call(server, {:get, key})
  end

  @impl Nadia.SessionStore
  def put(_server, _key, session) when not is_map(session), do: {:error, :invalid_session}

  def put(server, key, session) do
    GenServer.call(server, {:put, key, session})
  end

  @impl Nadia.SessionStore
  def update(server, key, fun) when is_function(fun, 1) do
    GenServer.call(server, {:update, key, fun})
  end

  def update(_server, _key, _fun), do: {:error, :invalid_update}

  @impl Nadia.SessionStore
  def delete(server, key) do
    GenServer.call(server, {:delete, key})
  end

  @impl GenServer
  def init(_opts) do
    table = :ets.new(__MODULE__, [:set, :private])
    {:ok, %__MODULE__{table: table}}
  end

  @impl GenServer
  def handle_call({:get, key}, _from, %__MODULE__{} = state) do
    {:reply, {:ok, read_session(state.table, key)}, state}
  end

  def handle_call({:put, key, session}, _from, %__MODULE__{} = state) when is_map(session) do
    true = :ets.insert(state.table, {key, session})
    {:reply, :ok, state}
  end

  def handle_call({:update, key, fun}, _from, %__MODULE__{} = state) do
    current_session = read_session(state.table, key)

    case apply_update(fun, current_session) do
      {:ok, next_session} ->
        true = :ets.insert(state.table, {key, next_session})
        {:reply, {:ok, next_session}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:delete, key}, _from, %__MODULE__{} = state) do
    true = :ets.delete(state.table, key)
    {:reply, :ok, state}
  end

  defp read_session(table, key) do
    case :ets.lookup(table, key) do
      [{^key, session}] -> session
      [] -> %{}
    end
  end

  defp apply_update(fun, current_session) do
    fun
    |> safe_apply(current_session)
    |> normalize_update_result()
  end

  defp safe_apply(fun, current_session) do
    fun.(current_session)
  rescue
    exception -> {:error, exception}
  catch
    kind, reason -> {:error, {kind, reason}}
  end

  defp normalize_update_result(%{} = session), do: {:ok, session}
  defp normalize_update_result({:ok, %{} = session}), do: {:ok, session}
  defp normalize_update_result({:error, reason}), do: {:error, reason}
  defp normalize_update_result(_other), do: {:error, :invalid_session}
end
