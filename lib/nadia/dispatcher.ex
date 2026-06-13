defmodule Nadia.Dispatcher do
  @moduledoc """
  Lightweight dispatch helpers for incoming Telegram updates.

  The behaviour-first path dispatches a parsed update to a module implementing
  `Nadia.Handler`:

      Nadia.Dispatcher.dispatch(update, MyApp.Bot, client: client)

  For small bots or tests, an ordered route list can match commands, message
  text, callback data, and fallback updates without a macro DSL:

      routes = [
        {:command, "start", &MyApp.Bot.start/1},
        {:text, ~r/^echo\\s+(.+)/, &MyApp.Bot.echo/2},
        {:callback, {:prefix, "confirm:"}, &MyApp.Bot.confirm/1},
        {:fallback, &MyApp.Bot.fallback/1}
      ]

      Nadia.Dispatcher.dispatch(update, routes)

  `dispatch/3` returns the handler or route action result unchanged. If the
  handler or action raises, the exception bubbles to the caller.
  """

  alias Nadia.Context
  alias Nadia.Model.{CallbackQuery, Message, Update}

  @type action ::
          (Context.t() -> term)
          | (Context.t(), map -> term)
          | {module, atom}

  @type route ::
          {:command, binary | Regex.t(), action}
          | {:text, binary | Regex.t(), action}
          | {:callback, binary | {:prefix, binary} | Regex.t(), action}
          | {:fallback, action}

  @type dispatchable :: Update.t() | Context.t()

  @doc """
  Dispatches an update or context to a handler module or ordered route list.

  When dispatching a `%Nadia.Model.Update{}`, the third argument is passed to
  `Nadia.Context.new/2`, so `%Nadia.Client{}` values and `client: client`
  options are preserved in the context.
  """
  @spec dispatch(dispatchable, module | [route], keyword | map | Nadia.Client.t() | nil) :: term
  def dispatch(update_or_context, handler_or_routes, client_or_opts \\ [])

  def dispatch(update_or_context, routes, client_or_opts) when is_list(routes) do
    with {:ok, context} <- context_for(update_or_context, client_or_opts) do
      dispatch_routes(context, routes, client_or_opts)
    end
  end

  def dispatch(update_or_context, handler, client_or_opts) when is_atom(handler) do
    with {:ok, %Context{update: update} = context} <-
           context_for(update_or_context, client_or_opts) do
      handler.handle_update(update, context)
    end
  end

  def dispatch(_update_or_context, _handler_or_routes, _client_or_opts),
    do: {:error, :invalid_handler}

  @doc """
  Matches a message command such as `/start` or `/start arg`.

  String matchers compare the command name without the leading slash and without
  any `@botname` suffix. Commands with a bot suffix match only when
  `:bot_username` is provided and matches that suffix. Regex matchers run
  against the normalized command name.
  """
  @spec match_command(dispatchable, binary | Regex.t(), keyword | map) :: {:ok, map} | :nomatch
  def match_command(update_or_context, command, opts \\ []) do
    with {:ok, context} <- context_for(update_or_context, []),
         text when is_binary(text) <- message_text(context),
         {:ok, command_match} <- parse_command(text),
         true <- command_matches?(command_match.command, command),
         true <- bot_matches?(command_match.bot, option_value(opts, :bot_username)) do
      {:ok, Map.put(command_match, :kind, :command)}
    else
      _ -> :nomatch
    end
  end

  @doc """
  Matches the effective message text.

  String matchers require exact text equality. Regex matchers return captures in
  the match metadata.
  """
  @spec match_text(dispatchable, binary | Regex.t()) :: {:ok, map} | :nomatch
  def match_text(update_or_context, pattern) do
    with {:ok, context} <- context_for(update_or_context, []),
         text when is_binary(text) <- message_text(context),
         {:ok, captures} <- match_value(text, pattern, :exact) do
      {:ok, %{kind: :text, text: text, captures: captures}}
    else
      _ -> :nomatch
    end
  end

  @doc """
  Matches callback query data.

  String matchers require exact data equality. `{:prefix, value}` matchers keep
  common callback namespaces like `"confirm:"` concise. Regex matchers return
  captures in the match metadata.
  """
  @spec match_callback(dispatchable, binary | {:prefix, binary} | Regex.t()) ::
          {:ok, map} | :nomatch
  def match_callback(update_or_context, pattern) do
    with {:ok, context} <- context_for(update_or_context, []),
         data when is_binary(data) <- callback_data(context),
         {:ok, captures} <- match_value(data, pattern, :exact) do
      {:ok, %{kind: :callback, data: data, captures: captures}}
    else
      _ -> :nomatch
    end
  end

  defp dispatch_routes(%Context{} = context, routes, opts) do
    case Enum.find_value(routes, &matched_route(context, &1, opts)) do
      nil -> :ignore
      {action, match} -> invoke_action(action, context, match)
    end
  end

  defp matched_route(context, {:command, command, action}, opts) do
    case match_command(context, command, opts) do
      {:ok, match} -> {action, match}
      :nomatch -> nil
    end
  end

  defp matched_route(context, {:text, pattern, action}, _opts) do
    case match_text(context, pattern) do
      {:ok, match} -> {action, match}
      :nomatch -> nil
    end
  end

  defp matched_route(context, {:callback, pattern, action}, _opts) do
    case match_callback(context, pattern) do
      {:ok, match} -> {action, match}
      :nomatch -> nil
    end
  end

  defp matched_route(_context, {:fallback, action}, _opts), do: {action, %{kind: :fallback}}
  defp matched_route(_context, _route, _opts), do: nil

  defp invoke_action(action, context, match) when is_function(action, 2) do
    action.(context, match)
  end

  defp invoke_action(action, context, _match) when is_function(action, 1) do
    action.(context)
  end

  defp invoke_action({module, function}, context, match)
       when is_atom(module) and is_atom(function) do
    cond do
      function_exported?(module, function, 2) -> apply(module, function, [context, match])
      function_exported?(module, function, 1) -> apply(module, function, [context])
      true -> raise UndefinedFunctionError, module: module, function: function, arity: 2
    end
  end

  defp invoke_action(action, _context, _match) do
    raise ArgumentError,
          "expected a route action function or {module, function}, got: #{inspect(action)}"
  end

  defp context_for(%Context{} = context, _client_or_opts), do: {:ok, context}

  defp context_for(%Update{} = update, client_or_opts),
    do: {:ok, Context.new(update, client_or_opts)}

  defp context_for(_update_or_context, _client_or_opts), do: {:error, :invalid_update}

  defp message_text(%Context{message: %Message{text: text}}), do: text
  defp message_text(_context), do: nil

  defp callback_data(%Context{callback_query: %CallbackQuery{data: data}}), do: data
  defp callback_data(_context), do: nil

  defp parse_command("/" <> rest) do
    [token | args] = String.split(rest, ~r/\s+/, parts: 2)
    [command | bot] = String.split(token, "@", parts: 2)

    {:ok,
     %{
       command: command,
       bot: List.first(bot),
       args: args |> List.first() |> blank_to_empty(),
       text: "/" <> rest
     }}
  end

  defp parse_command(_text), do: :nomatch

  defp command_matches?(command, pattern) when is_binary(pattern) do
    command == String.trim_leading(pattern, "/")
  end

  defp command_matches?(command, %Regex{} = regex), do: Regex.match?(regex, command)
  defp command_matches?(_command, _pattern), do: false

  defp bot_matches?(nil, _bot_username), do: true
  defp bot_matches?(_bot, nil), do: false

  defp bot_matches?(bot, bot_username) when is_binary(bot_username) do
    String.downcase(bot) == String.downcase(String.trim_leading(bot_username, "@"))
  end

  defp bot_matches?(_bot, _bot_username), do: false

  defp match_value(value, pattern, mode) when is_binary(pattern) do
    case mode do
      :exact when value == pattern -> {:ok, []}
      _ -> :nomatch
    end
  end

  defp match_value(value, {:prefix, prefix}, _mode) when is_binary(prefix) do
    if String.starts_with?(value, prefix), do: {:ok, []}, else: :nomatch
  end

  defp match_value(value, %Regex{} = regex, _mode) do
    case Regex.run(regex, value) do
      nil -> :nomatch
      [_full | captures] -> {:ok, captures}
    end
  end

  defp match_value(_value, _pattern, _mode), do: :nomatch

  defp blank_to_empty(nil), do: ""
  defp blank_to_empty(value), do: value

  defp option_value(options, key) when is_list(options), do: Keyword.get(options, key)
  defp option_value(options, key) when is_map(options), do: Map.get(options, key)
  defp option_value(_options, _key), do: nil
end
