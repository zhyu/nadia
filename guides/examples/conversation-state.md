# Conversation State

Multi-step bots need to remember what answer is expected next. Nadia keeps
that choice explicit: the handler owns the state machine and reads or writes a
`Nadia.SessionStore` backend.

This example collects a name and email address. Its complete tested source is
[`examples/conversation_bot.ex`](https://github.com/zhyu/nadia/blob/master/examples/conversation_bot.ex).

```text
/start -> ask for name -> ask for email -> clear the session
                   \-> /cancel --------> clear the session
```

## Supervise State Before Polling

The built-in ETS backend must be running before the handler uses it:

```elixir
children = [
  {Nadia.SessionStore.ETS, name: MyApp.BotSessions},
  {Nadia.Polling,
   handler: MyApp.ConversationBot,
   allowed_updates: ["message"],
   timeout: 30}
]
```

The handler refers to the same store by backend and process name:

```elixir
@store {Nadia.SessionStore.ETS, MyApp.BotSessions}
```

## Key State Deliberately

For a private conversation, a combined chat and user key prevents state from
leaking between users or chats:

```elixir
case Nadia.SessionStore.chat_user_key(context) do
  {:ok, key} -> continue_conversation(context, key)
  {:error, :missing_chat_id} -> :ignore
  {:error, :missing_user_id} -> :ignore
end
```

Returning `:ignore` for an update that cannot have a conversation key matters
when using `Nadia.Polling`: arbitrary return values are failures and will be
retried. Use `chat_key/1` for chat-wide state or `user_key/1` when the same
state should follow a user across chats.

## Advance The State Machine

Start a conversation by writing the next expected step:

```elixir
with {:ok, _message} <- Nadia.Context.reply(context, "What is your name?"),
     :ok <- Nadia.SessionStore.put(@store, key, %{step: :name}) do
  :ok
end
```

On later messages, read the session and handle the current step:

```elixir
with {:ok, session} <- Nadia.SessionStore.get(@store, key) do
  case {session, context.message} do
    {%{step: :name}, %{text: name}} when is_binary(name) ->
      with {:ok, _message} <-
             Nadia.Context.reply(context, "What is your email address?"),
           :ok <- Nadia.SessionStore.put(@store, key, %{step: :email, name: name}) do
        :ok
      end

    {%{step: :email, name: name}, %{text: email}} when is_binary(email) ->
      with {:ok, _message} <-
             Nadia.Context.reply(context, "Thanks #{name}. Received #{email}."),
           :ok <- Nadia.SessionStore.delete(@store, key) do
        :ok
      end

    _ ->
      :ignore
  end
end
```

Treat prompts and side effects as repeatable. Polling advances its offset only
after a successful handler result, and webhook providers may redeliver when a
response is lost. A handler can therefore see an update more than once.

Telegram sends and session mutations cannot share one transaction. This
learning example replies before changing the step so a failed send does not
misinterpret the same update after retry; a lost response can still produce a
duplicate prompt. Durable business workflows need application-level
idempotency and often a transactional outbox.

## Choose A Production Backend

`Nadia.SessionStore.ETS` is local, in-memory state. It disappears on restart
and is not shared between nodes. It is suitable for learning, development, and
simple single-node bots where losing a conversation is acceptable.

Implement the `Nadia.SessionStore` behaviour with application storage when
state must survive deploys, be shared by several nodes, or participate in a
larger transaction. Store only conversational progress in a session; durable
business records belong in the application's primary database.

See [Persistent Session Backends](persistent-sessions.md) for the complete
backend contract and a tested application-owned DETS example.
