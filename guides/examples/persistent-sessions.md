# Persistent Session Backends

`Nadia.SessionStore` is a small behaviour, not a database. Applications choose
the storage, supervision, consistency, retention, and security policy that
their conversations require.

`Nadia.SessionStore.ETS` serializes operations through one GenServer and owns a
private ETS table. Its `update/3` operation is atomic relative to other calls to
that store, but the table is node-local and disappears when the process stops.
It is suitable only when losing session state is acceptable.

## Implement The Contract

A backend receives backend-specific state and a session key. It must implement:

```elixir
@callback get(state, key) :: {:ok, map} | {:error, term}
@callback put(state, key, map) :: :ok | {:error, term}
@callback update(state, key, (map -> map | {:ok, map} | {:error, term})) ::
            {:ok, map} | {:error, term}
@callback delete(state, key) :: :ok | {:error, term}
```

A missing key returns `{:ok, %{}}`. An update callback receives that empty map
for a missing session. It may return a map, `{:ok, map}`, or `{:error, reason}`;
an error must not replace the stored value.

Use `Nadia.SessionStore.update/3` for contested read-modify-write operations.
Separate `get/2` and `put/3` calls can lose an update when handlers run
concurrently.

## Run The Disk Example

The complete
[`examples/disk_session_store.ex`](https://github.com/zhyu/nadia/blob/master/examples/disk_session_store.ex)
uses a supervised GenServer and OTP's built-in DETS disk term storage. It adds
no extra database dependency. Example files are packaged as source, not
compiled into Nadia; copy this module under your application's `lib/` and
rename it before adding it to a supervision tree.

```elixir
children = [
  {MyApp.DiskSessionStore,
   name: MyApp.BotSessions,
   table: MyApp.BotSessions.DETSTable,
   path: "/var/lib/my_app/bot_sessions.dets"}
]

store = {MyApp.DiskSessionStore, MyApp.BotSessions}

{:ok, session} =
  Nadia.SessionStore.update(store, {:chat, chat_id}, fn session ->
    Map.update(session, :seen, 1, &(&1 + 1))
  end)
```

The table atom is application-owned and fixed in source; never create atoms
from chat IDs or other external strings. The path must be writable before the
bot starts. The example syncs each mutation before replying, closes the table
on orderly termination, restores state after restart, and serializes updates
through one process. Nadia's offline tests exercise restart persistence and
concurrent increments.

## Understand The Example's Limits

This DETS backend is educational single-host storage, not a general production
database:

* One GenServer serializes every key, so a slow callback or disk operation
  blocks all sessions. Update callbacks must be short and free of external side
  effects; calling the same store from inside one will deadlock.
* DETS is not distributed and has no multi-record transaction. The documented
  table size limit is 2 GB, fragmented files consume extra memory, and crash
  repair can be slow.
* `terminate/2` is not guaranteed on every VM or host failure. Use durable
  storage, backups, and recovery testing appropriate to the value of the data.
* A session mutation and a Telegram API call cannot be one atomic transaction.
  Design handlers for duplicate updates and ambiguous network outcomes.

For a multi-node or high-value workflow, implement the same behaviour over the
application's existing database. Make `update/3` one transaction using a row
lock, optimistic version check, or compare-and-swap. Define schema versions,
expiry, cleanup, backup, restore, and encryption policies. Keep sensitive
message contents and durable business records out of an ungoverned session map.

No backend can make Telegram delivery exactly once. Use `update_id` or an
application event ID for idempotency, and use an outbox or job system when a
durable state transition must eventually cause an external send.
