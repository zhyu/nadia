defmodule Nadia.Examples.DatabaseSessionStore do
  @moduledoc """
  Application-owned optimistic database backend for `Nadia.SessionStore`.

  This source example deliberately depends on a small repository behaviour
  instead of Ecto or a database driver. Copy it under your application's
  `lib/` directory, rename it, and implement `Repository` with the database
  already owned by your application.

  Update callbacks can run more than once after compare-and-swap conflicts.
  They must be short, deterministic, and free of Telegram calls or other side
  effects. Only exact `:conflict` results are retried, and retries are bounded.
  """

  @behaviour Nadia.SessionStore

  defmodule Repository do
    @moduledoc """
    Persistence contract implemented by the application.

    `transaction/2` must apply every operation atomically or preserve the
    complete previous state. A `{:put_session, ..., expected, ...}` operation
    returns `{:error, :conflict}` when its version precondition is no longer
    true. The database should enforce unique constraints for processed updates
    and outbox IDs.
    """

    @type expected_version :: :any | :missing | non_neg_integer

    @type operation ::
            {:put_session, binary, term, expected_version, map}
            | {:delete_session, binary, term}
            | {:record_update, binary, integer | binary}
            | {:enqueue_outbox, map}

    @callback fetch_session(repo :: term, namespace :: binary, key :: term) ::
                {:ok, nil | %{version: non_neg_integer, session: map}} | {:error, term}

    @callback transaction(repo :: term, [operation]) ::
                :ok | {:error, :conflict | :duplicate_update | term}
  end

  @enforce_keys [:repository, :repo, :namespace, :conflict_retries]
  defstruct [:repository, :repo, :namespace, :conflict_retries]

  @type t :: %__MODULE__{
          repository: module,
          repo: term,
          namespace: binary,
          conflict_retries: non_neg_integer
        }

  @doc "Builds backend state for `{#{inspect(__MODULE__)}, state}`."
  @spec new(module, term, keyword) :: t
  def new(repository, repo, options \\ []) when is_atom(repository) do
    namespace = Keyword.get(options, :namespace, "telegram_sessions")
    conflict_retries = Keyword.get(options, :conflict_retries, 3)

    unless is_binary(namespace) and byte_size(namespace) > 0 do
      raise ArgumentError, ":namespace must be a non-empty application-owned binary"
    end

    unless is_integer(conflict_retries) and conflict_retries >= 0 do
      raise ArgumentError, ":conflict_retries must be a non-negative integer"
    end

    %__MODULE__{
      repository: repository,
      repo: repo,
      namespace: namespace,
      conflict_retries: conflict_retries
    }
  end

  @impl Nadia.SessionStore
  def get(%__MODULE__{} = state, key) do
    with {:ok, row} <- state.repository.fetch_session(state.repo, state.namespace, key),
         {:ok, _expected, session} <- normalize_row(row) do
      {:ok, session}
    end
  end

  @impl Nadia.SessionStore
  def put(%__MODULE__{}, _key, session) when not is_map(session),
    do: {:error, :invalid_session}

  def put(%__MODULE__{} = state, key, session) do
    state.repository.transaction(
      state.repo,
      [{:put_session, state.namespace, key, :any, session}]
    )
  end

  @impl Nadia.SessionStore
  def update(%__MODULE__{} = state, key, fun) when is_function(fun, 1) do
    update_with_cas(state, key, fun, state.conflict_retries)
  end

  def update(%__MODULE__{}, _key, _fun), do: {:error, :invalid_update}

  @impl Nadia.SessionStore
  def delete(%__MODULE__{} = state, key) do
    state.repository.transaction(
      state.repo,
      [{:delete_session, state.namespace, key}]
    )
  end

  @doc """
  Atomically records an incoming update, changes one session, and enqueues
  application-owned outbox rows.

  This function commits only database intent. A separate worker must send each
  Telegram request *after* the transaction commits. Telegram cannot participate
  in this transaction, so an ambiguous send can still be delivered more than
  once.
  """
  @spec process_update(
          t,
          binary,
          integer | binary,
          term,
          (map -> map | {:ok, map} | {:error, term}),
          [map]
        ) ::
          {:ok, map | :duplicate} | {:error, term}
  def process_update(
        %__MODULE__{} = state,
        bot_ref,
        update_id,
        key,
        fun,
        outbox_rows
      )
      when is_binary(bot_ref) and byte_size(bot_ref) > 0 and
             (is_integer(update_id) or is_binary(update_id)) and is_function(fun, 1) and
             is_list(outbox_rows) do
    process_update_with_cas(
      state,
      bot_ref,
      update_id,
      key,
      fun,
      outbox_rows,
      state.conflict_retries
    )
  end

  def process_update(%__MODULE__{}, _bot_ref, _update_id, _key, _fun, _outbox_rows),
    do: {:error, :invalid_update_transaction}

  defp update_with_cas(state, key, fun, retries_left) do
    with {:ok, row} <- state.repository.fetch_session(state.repo, state.namespace, key),
         {:ok, expected, current} <- normalize_row(row),
         {:ok, next} <- apply_update(fun, current) do
      operations = [{:put_session, state.namespace, key, expected, next}]

      case state.repository.transaction(state.repo, operations) do
        :ok ->
          {:ok, next}

        {:error, :conflict} when retries_left > 0 ->
          update_with_cas(state, key, fun, retries_left - 1)

        {:error, :conflict} ->
          {:error, :conflict_retries_exhausted}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp process_update_with_cas(
         state,
         bot_ref,
         update_id,
         key,
         fun,
         outbox_rows,
         retries_left
       ) do
    with :ok <- validate_outbox_rows(outbox_rows),
         {:ok, row} <- state.repository.fetch_session(state.repo, state.namespace, key),
         {:ok, expected, current} <- normalize_row(row),
         {:ok, next} <- apply_update(fun, current) do
      operations =
        [
          {:record_update, bot_ref, update_id},
          {:put_session, state.namespace, key, expected, next}
        ] ++ Enum.map(outbox_rows, &{:enqueue_outbox, &1})

      case state.repository.transaction(state.repo, operations) do
        :ok ->
          {:ok, next}

        {:error, :duplicate_update} ->
          {:ok, :duplicate}

        {:error, :conflict} when retries_left > 0 ->
          process_update_with_cas(
            state,
            bot_ref,
            update_id,
            key,
            fun,
            outbox_rows,
            retries_left - 1
          )

        {:error, :conflict} ->
          {:error, :conflict_retries_exhausted}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp normalize_row(nil), do: {:ok, :missing, %{}}

  defp normalize_row(%{version: version, session: session})
       when is_integer(version) and version >= 0 and is_map(session) do
    {:ok, version, session}
  end

  defp normalize_row(_row), do: {:error, :invalid_repository_record}

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

  defp validate_outbox_rows(rows) do
    if Enum.all?(rows, fn
         %{id: id} when is_binary(id) and byte_size(id) > 0 -> true
         %{"id" => id} when is_binary(id) and byte_size(id) > 0 -> true
         _row -> false
       end) do
      :ok
    else
      {:error, :invalid_outbox_row}
    end
  end
end
