defmodule Nadia.Polling do
  @moduledoc """
  Supervised long polling runtime for Nadia bots.

  Add it to a supervision tree with a handler module:

      children = [
        {Nadia.Polling,
         client: Nadia.Client.from_config(:support),
         handler: MyApp.SupportBot,
         allowed_updates: ["message", "callback_query"],
         timeout: 30}
      ]

  The runtime calls `Nadia.get_updates/2`, dispatches updates sequentially
  through `Nadia.Dispatcher`, and advances the offset only after each update is
  handled successfully. Handler `{:error, reason}` returns and exceptions are
  treated as failed dispatches: polling backs off and retries from the failed
  update without dispatching later updates in the batch.
  """

  use GenServer

  require Logger

  alias Nadia.Client
  alias Nadia.Dispatcher
  alias Nadia.Model.Update

  @default_timeout 30
  @default_backoff_ms 1_000
  @default_max_backoff_ms 30_000
  @default_poll_interval_ms 0

  defstruct api: Nadia,
            allowed_updates: nil,
            backoff_ms: @default_backoff_ms,
            bot_username: nil,
            client: nil,
            current_backoff_ms: @default_backoff_ms,
            handler: nil,
            limit: nil,
            log_errors: true,
            max_backoff_ms: @default_max_backoff_ms,
            offset: nil,
            poll_interval_ms: @default_poll_interval_ms,
            timeout: @default_timeout

  @type handler :: module | [Dispatcher.route()]

  @type option ::
          {:allowed_updates, [binary] | binary}
          | {:api, module | {module, term}}
          | {:backoff_ms, non_neg_integer}
          | {:bot, atom}
          | {:bot_username, binary}
          | {:client, Client.t() | atom | nil}
          | {:handler, handler}
          | {:limit, pos_integer}
          | {:log_errors, boolean}
          | {:max_backoff_ms, non_neg_integer}
          | {:offset, integer}
          | {:poll_interval_ms, non_neg_integer}
          | {:timeout, non_neg_integer}

  @doc """
  Starts a polling process.

  `:handler` is required and may be a module implementing `Nadia.Handler` or an
  ordered route list accepted by `Nadia.Dispatcher`.
  """
  @spec start_link([option]) :: GenServer.on_start()
  def start_link(opts) when is_list(opts) do
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

  @impl GenServer
  def init(opts) do
    state = build_state(opts)
    schedule_poll(0)
    {:ok, state}
  end

  @impl GenServer
  def handle_info(:poll, %__MODULE__{} = state) do
    case get_updates(state) do
      {:ok, updates} when is_list(updates) ->
        state
        |> reset_backoff()
        |> dispatch_updates(updates)
        |> handle_dispatch_result()

      {:error, reason} ->
        log_error(state, "Nadia polling getUpdates failed: #{inspect(reason)}")
        {:noreply, schedule_backoff(state)}

      other ->
        log_error(
          state,
          "Nadia polling getUpdates returned unexpected response: #{inspect(other)}"
        )

        {:noreply, schedule_backoff(state)}
    end
  end

  defp build_state(opts) do
    handler = Keyword.fetch!(opts, :handler)
    backoff_ms = Keyword.get(opts, :backoff_ms, @default_backoff_ms)

    %__MODULE__{
      api: Keyword.get(opts, :api, Nadia),
      allowed_updates: Keyword.get(opts, :allowed_updates),
      backoff_ms: backoff_ms,
      bot_username: Keyword.get(opts, :bot_username),
      client: resolve_client(opts),
      current_backoff_ms: backoff_ms,
      handler: handler,
      limit: Keyword.get(opts, :limit),
      log_errors: Keyword.get(opts, :log_errors, true),
      max_backoff_ms: Keyword.get(opts, :max_backoff_ms, @default_max_backoff_ms),
      offset: Keyword.get(opts, :offset),
      poll_interval_ms: Keyword.get(opts, :poll_interval_ms, @default_poll_interval_ms),
      timeout: Keyword.get(opts, :timeout, @default_timeout)
    }
  end

  defp resolve_client(opts) do
    case Keyword.fetch(opts, :client) do
      {:ok, %Client{} = client} ->
        client

      {:ok, name} when is_atom(name) and not is_nil(name) ->
        Client.from_config(name)

      _ ->
        case Keyword.fetch(opts, :bot) do
          {:ok, name} when is_atom(name) and not is_nil(name) -> Client.from_config(name)
          _ -> nil
        end
    end
  end

  defp get_updates(%__MODULE__{} = state) do
    request_options = request_options(state)

    case state.api do
      {api, extra} -> get_updates(api, state.client, request_options, extra)
      api -> get_updates(api, state.client, request_options)
    end
  end

  defp get_updates(api, nil, request_options), do: api.get_updates(request_options)

  defp get_updates(api, %Client{} = client, request_options),
    do: api.get_updates(client, request_options)

  defp get_updates(api, nil, request_options, extra),
    do: api.get_updates(request_options, extra)

  defp get_updates(api, %Client{} = client, request_options, extra),
    do: api.get_updates(client, request_options, extra)

  defp request_options(%__MODULE__{} = state) do
    []
    |> maybe_put(:offset, state.offset)
    |> maybe_put(:limit, state.limit)
    |> maybe_put(:timeout, state.timeout)
    |> maybe_put(:allowed_updates, state.allowed_updates)
  end

  defp maybe_put(options, _key, nil), do: options
  defp maybe_put(options, key, value), do: Keyword.put(options, key, value)

  defp dispatch_updates(%__MODULE__{} = state, updates) do
    Enum.reduce_while(updates, {:ok, state}, fn update, {:ok, current_state} ->
      case dispatch_update(update, current_state) do
        :ok ->
          {:cont, {:ok, advance_offset(current_state, update)}}

        {:error, reason} ->
          {:halt, {:error, current_state, update, reason}}
      end
    end)
  end

  defp dispatch_update(update, %__MODULE__{} = state) do
    result = Dispatcher.dispatch(update, state.handler, dispatcher_options(state))

    case result do
      :ok -> :ok
      :ignore -> :ok
      {:ok, _value} -> :ok
      {:error, reason} -> {:error, reason}
      other -> {:error, {:unexpected_handler_result, other}}
    end
  rescue
    exception -> {:error, exception}
  catch
    kind, reason -> {:error, {kind, reason}}
  end

  defp dispatcher_options(%__MODULE__{} = state) do
    []
    |> maybe_put(:client, state.client)
    |> maybe_put(:bot_username, state.bot_username)
  end

  defp advance_offset(%__MODULE__{} = state, %Update{update_id: update_id})
       when is_integer(update_id) do
    %{state | offset: max_offset(state.offset, update_id + 1)}
  end

  defp advance_offset(%__MODULE__{} = state, _update), do: state

  defp max_offset(nil, offset), do: offset
  defp max_offset(current, offset), do: max(current, offset)

  defp handle_dispatch_result({:ok, state}) do
    {:noreply, schedule_poll(state, state.poll_interval_ms)}
  end

  defp handle_dispatch_result({:error, state, update, reason}) do
    update_id =
      case update do
        %Update{update_id: update_id} -> update_id
        _ -> nil
      end

    log_error(
      state,
      "Nadia polling handler returned an error for update #{inspect(update_id)}: #{inspect(reason)}"
    )

    {:noreply, schedule_backoff(state)}
  end

  defp reset_backoff(%__MODULE__{} = state), do: %{state | current_backoff_ms: state.backoff_ms}

  defp schedule_backoff(%__MODULE__{} = state) do
    wait_ms = state.current_backoff_ms

    state
    |> bump_backoff()
    |> schedule_poll(wait_ms)
  end

  defp bump_backoff(%__MODULE__{} = state) do
    next_backoff =
      state.current_backoff_ms
      |> max(state.backoff_ms)
      |> Kernel.*(2)
      |> min(state.max_backoff_ms)

    %{state | current_backoff_ms: next_backoff}
  end

  defp schedule_poll(%__MODULE__{} = state, delay_ms) do
    schedule_poll(delay_ms)
    state
  end

  defp schedule_poll(delay_ms) do
    Process.send_after(self(), :poll, delay_ms)
  end

  defp log_error(%__MODULE__{log_errors: true}, message), do: Logger.warning(message)
  defp log_error(%__MODULE__{log_errors: false}, _message), do: :ok
end
