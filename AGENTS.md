# Nadia Agent Notes

## Project shape

Nadia is a Mix library that wraps the Telegram Bot API and the Telegraph API.
The public Bot API wrapper lives mainly in `lib/nadia.ex` and supports both the
legacy application-config client and explicit `%Nadia.Client{}` values.

Request/response plumbing lives in `lib/nadia/api.ex`,
`lib/nadia/graph/api.ex`, `lib/nadia/http_request.ex`,
`lib/nadia/http_response.ex`, and `lib/nadia/http_client.ex`. The default HTTP
adapter is `Nadia.HTTPClient.Req` in `lib/nadia/http_client/req.ex`.

Structs and parsing live in `lib/nadia/model.ex` and `lib/nadia/parser.ex`.
Telegraph support lives under `lib/nadia/graph*`.

Tests use ExUnit with deterministic offline request/response fixtures under
`test/fixtures/telegram/responses`. Optional live Telegram smoke tests live in
`test/live` and are tagged `:telegram_live`.

## Current status

The current stable release is Nadia 1.0.0. At the time this note was updated,
`master` was clean at `v1.0.0` and `CHANGELOG.md`/`README.md` documented
complete Telegram Bot API 10.1 method coverage: all 180 official methods, with
0 missing and 0 extra remote methods in the release inventory.

Nadia now requires Elixir 1.20 or later. CI currently verifies Elixir 1.20.1 on
Erlang/OTP 27.3.4.12 and 29.0.1, checks formatting, compiles with warnings as
errors, runs the test suite, and builds docs with warnings as errors.

The refresh/modernization work that replaced the old dependency stack is
complete. Req is the production HTTP transport. HTTPoison, hackney, ExVCR, VCR
cassettes, and hackney-specific SOCKS proxy configuration were removed in the
0.9.0 refresh and should not be treated as current project patterns.

Telegram and Telegraph response parsing should avoid creating atoms from remote
JSON keys. Unknown future response fields should remain ignored until Nadia
explicitly models them.

Local `.Codex/docs/plans` refresh trackers were removed after the 1.0.0 work.
Use `README.md`, `CHANGELOG.md`, `mix.exs`, CI workflow files, tests, and commit
history as the current source of truth. Create new `.Codex/docs` planning or
tracking documents only when there is active planning work to preserve.

## Common commands

Development commands:

```sh
mix deps.get
mix test
mix format --check-formatted
mix compile --warnings-as-errors
mix docs --warnings-as-errors
```

If Hex or Rebar are missing:

```sh
mix local.hex --force
mix local.rebar --force
```

Optional live Telegram smoke tests are default-off:

```sh
mix test --only telegram_live
```

They require credentials from `.env.live.local`, seeded from
`.env.live.local.example`, and two bots with Bot-to-Bot Communication Mode
enabled.

Mix may need permission to open a local TCP socket for `Mix.PubSub` when run
from a sandboxed agent environment.

## Docs and changelog

When making user-facing changes, update the `Unreleased` section of
`CHANGELOG.md` in the same slice or in a follow-up changelog commit.

User-facing changes include public API changes, configuration changes,
dependency or transport changes, behavior changes, and notable test or
live-test workflow changes. Internal-only refactors do not need changelog
entries unless they affect users or release risk.

`README.md` is the user-facing overview and install/configuration guide.
Generated ExDoc output goes to `doc/`, which is ignored by git; verify docs with
`mix docs --warnings-as-errors` rather than committing generated HTML.

## Bot API maintenance

Nadia 1.0.0 claims complete Bot API 10.1 method coverage. For future Bot API
updates, verify remote Telegram method names and response shapes against the
current official docs before adding or changing wrappers. Preserve
backwards-compatible Elixir function names where practical, and update README,
changelog, tests, and parser/model coverage when the public coverage claim
changes.
