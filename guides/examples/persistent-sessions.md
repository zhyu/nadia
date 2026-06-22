# Persistent Session Backends

`Nadia.SessionStore` is a storage contract, not a database, transaction
manager, or exactly-once delivery system. Applications own persistence,
consistency, retention, migrations, and security.

`Nadia.SessionStore.ETS` serializes all calls through one GenServer and owns a
private ETS table. `update/3` is atomic relative to other calls through that
store process. Separate `get/2` and `put/3` calls are not atomic and can lose a
concurrent update. ETS state is node-local and disappears with its owner; it is
not distributed or durable database storage.

## Implement The Contract

A missing key returns `{:ok, %{}}`. An update callback receives that empty map
and may return a map, `{:ok, map}`, or `{:error, reason}`. An error must preserve
the stored value.

Use `Nadia.SessionStore.update/3` for contested read-modify-write operations.
The backend decides how it makes the callback atomic. A database callback can
run more than once after a serialization failure or optimistic conflict, so it
must be short, deterministic, and free of Telegram calls, HTTP requests, email,
job insertion, or other side effects.

## Choose A Published Example

Example files ship as source artifacts; they are not compiled Nadia modules.
Copy the chosen module under your application's `lib/` directory and rename it
before adding it to your supervision tree.

[`examples/disk_session_store.ex`](https://github.com/zhyu/nadia/blob/master/examples/disk_session_store.ex)
uses DETS and a GenServer. It syncs each mutation, restores state after an
orderly restart, and serializes every key through one process. It is an
educational single-host option, not a distributed database: DETS has no
multi-record transactions, one slow callback blocks all sessions, crash repair
can be slow, and `terminate/2` is not guaranteed on host failure.

[`examples/database_session_store.ex`](https://github.com/zhyu/nadia/blob/master/examples/database_session_store.ex)
is a dependency-free application-owned database boundary. The copied module
uses an injected repository with two operations:

```elixir
@callback fetch_session(repo, namespace, key) ::
            {:ok, nil | %{version: non_neg_integer(), session: map()}} |
            {:error, term()}

@callback transaction(repo, [operation]) ::
            :ok | {:error, :conflict | :duplicate_update | term()}
```

Construct a store around your repository module and connection state:

```elixir
backend =
  MyApp.DatabaseSessionStore.new(MyApp.BotRepository, MyApp.Repo,
    namespace: "support_bot_sessions",
    conflict_retries: 3
  )

store = {MyApp.DatabaseSessionStore, backend}

{:ok, session} =
  Nadia.SessionStore.update(store, {:chat, chat_id}, fn session ->
    Map.update(session, :seen, 1, &(&1 + 1))
  end)
```

The namespace is a fixed application-owned binary. Do not use the bot token,
chat text, or dynamically created atoms. Nadia's offline suite exercises this
published source with a deterministic fake repository, including contested
updates, repository-owned persistence across backend values, deletion, bounded
conflicts, and failure preservation. The fake is test infrastructure, not a
durable database.

## Pick A Concurrency Strategy

The example uses optimistic compare-and-swap. Store a version with every row;
update with a condition such as `WHERE version = ?`, and guard first insertion
with a unique key. On an exact conflict, read the new row and rerun the callback
within a strict bound. Hot keys can exhaust that bound. Do not retry arbitrary
database errors or ambiguous transport failures as though they were conflicts.

A row-lock backend is also valid: begin a transaction, select the session row
`FOR UPDATE`, calculate the next map, write it, and commit. Missing-row creation
still needs a unique constraint or upsert strategy. Set database lock and
statement timeouts, handle deadlocks deliberately, and never hold the lock
while calling Telegram.

Whichever strategy is used, define the transaction isolation level and test
the exact adapter behavior. `SessionStore.update/3` is atomic only to the extent
that the backend's transaction or conditional write is correct.

## Use An Outbox For Durable Effects

A Telegram API call cannot share a database transaction. Sending before commit
can produce a message for state that later rolls back; sending inside the
transaction holds locks and still cannot roll Telegram back; sending after
commit can be lost if the process crashes first.

When a durable state transition must eventually trigger a send, commit these
items together in the application database:

1. the session or business-state change;
2. a processed-update marker keyed by `{bot_ref, update_id}`;
3. an outbox row describing the intended Telegram method and parameters.

The database example's `process_update/6` demonstrates that transaction shape.
`bot_ref` is a stable, non-secret application identifier. The outbox ID and the
`{bot_ref, update_id}` pair need unique constraints. `SessionStore.update/3`
alone cannot atomically insert a separate outbox row; use the application
repository transaction directly when several records must commit together.

An outbox worker claims a bounded batch, commits a lease or claim, sends outside
the database transaction, and then marks the row sent. PostgreSQL applications
often use `FOR UPDATE SKIP LOCKED` for queue-like claiming. A crash or timeout
after Telegram accepted the request but before `sent_at` is recorded remains
ambiguous. The outbox provides durable at-least-once intent, not exactly-once
Telegram delivery. Telegram methods do not provide one universal idempotency
key, so bound retries and design user-visible effects to tolerate duplicates.

## Operate The Data

Shared database constraints provide multi-node consistency; ETS, DETS, process
registration, and a supervisor name do not. Also define:

* a schema version per session and explicit migrations for old maps;
* expiry timestamps, an index, and bounded cleanup batches;
* minimum necessary data, retention/deletion policy, and privacy response flow;
* encryption in transit and at rest, plus application-level encryption and key
  rotation when the threat model requires it;
* database timeouts, conflict/deadlock metrics, backups, restore drills, and
  capacity limits;
* safe serialization. Never decode attacker-controlled stored terms with an
  unsafe `binary_to_term/1` mode.

Keep durable business records out of an ungoverned session map. Store only the
conversation state needed to resume the interaction.
