# Errors And Rate Limits

Nadia returns Telegram failures as `%Nadia.Model.Error{}`. The human-readable
`reason` remains available for existing code, while structured fields support
the cases Telegram explicitly exposes:

```elixir
%Nadia.Model.Error{
  reason: "Too Many Requests: retry after 2",
  error_code: 429,
  parameters: %Nadia.Model.ResponseParameters{
    retry_after: 2,
    migrate_to_chat_id: nil
  }
}
```

Telegram says `error_code` contents can change. Record it for diagnosis, but do
not treat every code in one broad range as retryable. Unknown response fields
are ignored without creating atoms.

## Retry Only An Explicit Flood Delay

The complete tested example is
[`examples/retry_errors.ex`](https://github.com/zhyu/nadia/blob/master/examples/retry_errors.ex).
It is packaged as source rather than compiled into Nadia; copy it under your
application's `lib/` and rename it. Then wrap one operation and set finite
policy bounds:

```elixir
alias MyApp.RetryErrors

RetryErrors.retry(
  fn -> Nadia.send_message(client, chat_id, text) end,
  max_attempts: 3,
  max_delay_seconds: 30
)
```

The helper retries only an error containing a non-negative `retry_after`, waits
the full number of seconds Telegram supplied, and stops after the configured
attempt count. When the requested delay exceeds the inline wait limit, it
returns the original error so the application can put work in a durable
scheduler. It does not spawn tasks.

Do not clamp a long delay downward and retry early. Pace broadcasts before
they reach flood control, bound queue size and concurrency, and add jitter to
application scheduling where many independent workers could wake together.

## Do Not Blindly Retry Other Failures

Permanent input, permission, and not-found errors need a code or data change.
A timeout or disconnected transport is ambiguous: Telegram may have performed
the side effect even though the response was lost. Retrying a send can produce
a duplicate. Use an application operation key, reconciliation, or an outbox
when duplicate side effects matter.

The example deliberately leaves non-rate-limit errors unchanged. The caller
can log a redacted reason, route a permanent failure to review, or schedule an
operation according to domain-specific idempotency rules.

## Persist Chat Migration

When a group becomes a supergroup, Telegram can return
`migrate_to_chat_id`. Extract it without guessing from the description:

```elixir
case RetryErrors.migration_target(error) do
  {:ok, new_chat_id} ->
    MyApp.ChatDestinations.replace(old_chat_id, new_chat_id)

  :error ->
    {:error, error}
end
```

The replacement ID may exceed 32-bit storage. Persist it in an Elixir integer
or database `BIGINT`. Update the application's destination atomically before
deliberately issuing a new request. Do not build a generic automatic migration
retry for every Bot API method; the operation and its side effects determine
whether repetition is safe.

## Distinguish Error Sources

Malformed JSON and transport failures also return `%Nadia.Model.Error{}` with
their existing `reason` values. A valid JSON body that does not follow the Bot
API envelope returns the stable reason `:invalid_response` rather than exposing
unmodeled remote fields or being parsed as a successful method result.

Telegraph uses its own `%Nadia.Graph.Model.Error{reason: reason}` and does not
define Telegram's `error_code` or `ResponseParameters`. Nadia accepts the
official Telegraph `ok`/`result`/`error` envelope and normalizes malformed
valid JSON instead of raising.

See Telegram's current [response contract](https://core.telegram.org/bots/api#making-requests)
and [`ResponseParameters`](https://core.telegram.org/bots/api#responseparameters)
documentation for the authoritative field semantics.
