defmodule Nadia.Examples.DiskSessionStore do
  @moduledoc """
  Educational single-host persistent implementation of `Nadia.SessionStore`.

  The application owns the process, DETS table name, path, backup policy, and
  data lifecycle. Calls are serialized through one process and each mutation
  is synced before it returns.
  """

  use GenServer

  @behaviour Nadia.SessionStore

  defstruct [:table]

  @type option ::
          {:name, GenServer.name()}
          | {:id, term}
          | {:path, Path.t()}
          | {:table, atom}

  @spec start_link([option]) :: GenServer.on_start()
  def start_link(options) when is_list(options) do
    GenServer.start_link(__MODULE__, options, Keyword.take(options, [:name]))
  end

  def child_spec(options) do
    %{
      id: Keyword.get(options, :id, Keyword.get(options, :name, __MODULE__)),
      start: {__MODULE__, :start_link, [options]},
      type: :worker,
      restart: :permanent,
      shutdown: 5_000
    }
  end

  @impl Nadia.SessionStore
  def get(server, key), do: GenServer.call(server, {:get, key})

  @impl Nadia.SessionStore
  def put(_server, _key, session) when not is_map(session), do: {:error, :invalid_session}
  def put(server, key, session), do: GenServer.call(server, {:put, key, session})

  @impl Nadia.SessionStore
  def update(server, key, fun) when is_function(fun, 1),
    do: GenServer.call(server, {:update, key, fun})

  def update(_server, _key, _fun), do: {:error, :invalid_update}

  @impl Nadia.SessionStore
  def delete(server, key), do: GenServer.call(server, {:delete, key})

  @impl true
  def init(options) do
    with {:ok, path} <- Keyword.fetch(options, :path),
         table when is_atom(table) <- Keyword.get(options, :table, __MODULE__),
         :ok <- File.mkdir_p(Path.dirname(path)),
         {:ok, table} <-
           :dets.open_file(table, file: String.to_charlist(path), type: :set, repair: true) do
      {:ok, %__MODULE__{table: table}}
    else
      {:error, reason} -> {:stop, reason}
      table when not is_atom(table) -> {:stop, :invalid_table}
    end
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    reply =
      case :dets.lookup(state.table, key) do
        [{^key, session}] -> {:ok, session}
        [] -> {:ok, %{}}
        {:error, reason} -> {:error, reason}
      end

    {:reply, reply, state}
  end

  def handle_call({:put, key, session}, _from, state) do
    {:reply, persist(state.table, {:put, key, session}), state}
  end

  def handle_call({:update, key, fun}, _from, state) do
    current =
      case :dets.lookup(state.table, key) do
        [{^key, session}] -> session
        [] -> %{}
      end

    reply =
      case apply_update(fun, current) do
        {:ok, session} ->
          case persist(state.table, {:put, key, session}) do
            :ok -> {:ok, session}
            {:error, reason} -> {:error, reason}
          end

        {:error, reason} ->
          {:error, reason}
      end

    {:reply, reply, state}
  end

  def handle_call({:delete, key}, _from, state) do
    {:reply, persist(state.table, {:delete, key}), state}
  end

  @impl true
  def terminate(_reason, state) do
    :dets.sync(state.table)
    :dets.close(state.table)
    :ok
  end

  defp persist(table, {:put, key, session}) do
    with :ok <- :dets.insert(table, {key, session}),
         :ok <- :dets.sync(table),
         do: :ok
  end

  defp persist(table, {:delete, key}) do
    with :ok <- :dets.delete(table, key),
         :ok <- :dets.sync(table),
         do: :ok
  end

  defp apply_update(fun, current) do
    fun.(current)
    |> normalize_update()
  rescue
    exception -> {:error, exception}
  catch
    kind, reason -> {:error, {kind, reason}}
  end

  defp normalize_update(%{} = session), do: {:ok, session}
  defp normalize_update({:ok, %{} = session}), do: {:ok, session}
  defp normalize_update({:error, reason}), do: {:error, reason}
  defp normalize_update(_other), do: {:error, :invalid_session}
end
