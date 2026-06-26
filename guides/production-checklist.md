# Production Checklist

Nadia provides Bot API calls and small OTP-friendly update helpers. Your
application still owns durability, concurrency, background work, and deployment
policy. Make those choices explicitly before sending real traffic.

## Choose One Update Transport

| Long polling | Webhooks |
| --- | --- |
| No public endpoint or TLS setup | Requires a public HTTPS endpoint |
| Simple for development and one worker | Fits existing web applications and horizontally scaled intake |
| `Nadia.Polling` processes updates sequentially | Your endpoint controls queuing and concurrency |
| Offset is kept in worker memory | Telegram retries non-successful deliveries |

Telegram does not deliver updates through polling while a webhook is set. Call
`Nadia.delete_webhook/1` before switching to polling. When switching to a
webhook, stop pollers before calling `Nadia.set_webhook/1`.

Request only the update types the bot handles with `:allowed_updates`. Some
types, such as chat member updates, are not delivered unless requested. Bot
privacy mode and other BotFather settings also affect what Telegram sends.

## Understand Delivery And Ordering

Treat update handling as at least once:

* `Nadia.Polling` advances its in-memory offset after `:ok`, `:ignore`, or
  `{:ok, value}`. It retries `{:error, reason}`, exceptions, and unexpected
  return values with bounded backoff.
* A failed update prevents later updates from the same fetched polling batch
  from being dispatched until it succeeds.
* A restart loses the poller's current in-memory offset. Telegram may therefore
  return an update the process handled shortly before stopping.
* Webhook updates can be delivered again when Telegram does not receive a
  successful response.

Use `update_id` or an application event key to make durable side effects
idempotent. Return quickly from webhook endpoints and move slow work to a
supervised queue or job system. Decide whether ordering is required per chat,
per user, or not at all before adding concurrency.

## Handle Bot API Failures

Match both success and error returns from Nadia calls:

```elixir
case Nadia.Context.reply(context, "Processed") do
  {:ok, message} ->
    {:ok, message}

  {:error, %Nadia.Model.Error{} = error} ->
    Logger.warning("Telegram send failed: #{inspect(error.reason)}")
    {:error, error}
end
```

Keep the polling request timeout below infrastructure shutdown deadlines. Use
bounded retries for transient failures and avoid retrying permanent input or
permission errors forever. Telegram enforces flood limits; pace bulk sends and
observe error rates rather than launching unbounded tasks.

See [Errors And Rate Limits](examples/errors-and-rate-limits.md) for tested
`retry_after` and chat-migration handling.

## Protect Credentials And Webhooks

* Read bot tokens and Telegraph access tokens from runtime environment or a
  secret manager. Never commit or log them.
* Use a high-entropy `secret_token` with `setWebhook` and pass the same value to
  `Nadia.Webhook.dispatch_body/3`.
* Enforce request body limits and HTTPS at the web server or proxy.
* Rotate a token with BotFather if it may have leaked.
* Keep production credentials out of tests; use an explicit fake HTTP client.
* Prefer `Nadia.download_file/3,4,5` over exposing `getFile` URLs. Always choose
  an application-owned destination and byte limit; keep no-overwrite behavior
  unless replacement is intentional.
* Treat `get_file_link/1,2` results as credentials because they contain the bot
  token. The default downloader disables redirects, retries, decompression, and
  token-bearing errors, but custom download adapters must uphold the same
  contract.
* Use `file_mode: :local` only for a trusted local Bot API server whose absolute
  file paths are authorized and accessible from Nadia's filesystem namespace.
  Remote filesystems without exclusive temp creation and atomic hard-link
  publication are unsupported.
* Prefer typed outgoing-content builders when uploads have context-specific
  rules. Profile-photo and story builders reject reusable file IDs and URLs;
  paid and poll media validate their typed variant contexts before HTTP.
  Typed poll options validate locally knowable option and quiz relationships,
  while typed story areas enforce documented per-variant counts.
* Treat rich HTML and Markdown as untrusted structured input. Nadia validates
  UTF-8, length, flags, and typed context, but Telegram remains the parser and
  enforces syntax, nesting, media permissions, rendered structure, and layout.
* Set `:max_bytes` on application-controlled uploads. Nadia does not inspect
  image dimensions, codecs, keyframes, MIME truth, or sticker contents, so
  Telegram can still reject a locally valid typed payload.
* Known-size upload streams are single-use. Do not automatically retry an
  ambiguous timeout after a stream may have been consumed.

## Choose Durable State

`Nadia.SessionStore.ETS` is local and disappears on restart. Replace it with a
backend implementing `Nadia.SessionStore` when sessions must survive deploys or
be visible to several nodes. Keep durable business data in application storage,
not only in a conversational session map.

The [Persistent Session Backends](examples/persistent-sessions.md) guide covers
atomic `update/3`, get-then-put races, row-lock and optimistic-CAS database
strategies, the tested DETS and database-boundary examples, and bounded conflict
handling. ETS and DETS are not multi-node transactional databases.

A Telegram request cannot commit atomically with database state. For durable
effects, commit the state change, `{bot_ref, update_id}` idempotency marker, and
outbox intent in one application database transaction. Send from a worker after
commit. An ambiguous Telegram timeout can still produce a duplicate, so an
outbox is at-least-once intent rather than exactly-once delivery.

Telegram chat and user IDs may exceed 32-bit integer ranges. Store them in an
Elixir integer or a database `BIGINT`, not a 32-bit column.

## Add Operational Visibility

At minimum, record:

* handler latency and result category;
* update type and `update_id`, without message contents by default;
* Bot API latency and error rate;
* polling retries or webhook response failures;
* queue depth and age for background work;
* the bot/client identity in a multi-bot application.

Do not log tokens, webhook secrets, payment details, or sensitive message
content. Add health checks for the application and its storage; a successful
`getMe` can be used as a separate readiness probe when an external Telegram
dependency is appropriate for your deployment.
