# Nadia Agent Notes

## Project shape

Nadia is a Mix library that wraps the Telegram Bot API and the Telegraph API.
The public Bot API wrapper lives mainly in `lib/nadia.ex`; request/response
plumbing is in `lib/nadia/api.ex`; structs and parsing are in
`lib/nadia/model.ex` and `lib/nadia/parser.ex`. Telegraph support lives under
`lib/nadia/graph*`.

Tests use ExUnit plus ExVCR cassettes under `fixture/vcr_cassettes`.

## Common commands

Development commands:

```sh
mix deps.get
mix test
mix format --check-formatted
mix compile --warnings-as-errors
```

If Hex or Rebar are missing:

```sh
mix local.hex --force
mix local.rebar --force
```

As of 2026-05-29 this project was verified with Elixir 1.19.5 and Erlang/OTP
29 after dependency modernization. Mix may need permission to open a local TCP
socket for `Mix.PubSub` when run from a sandboxed agent environment.

## Changelog

When making user-facing changes, update the `Unreleased` section of
`CHANGELOG.md` in the same slice or in a follow-up changelog commit.

User-facing changes include public API changes, configuration changes,
dependency or transport changes, behavior changes, and notable test or live-test
workflow changes. Internal-only refactors do not need changelog entries unless
they affect users or release risk.

## Current refresh context

The original locked dependency set did not compile on Elixir 1.19.5/OTP 29:
`ssl_verify_fun` 1.1.6 failed under Mix while compiling the `public_key` header
include. Updating the dependency graph through `httpoison` 2.3.0, `hackney`
1.25.0, and `ssl_verify_fun` 1.1.7 resolved that blocker.

The next major work item is API coverage, not basic build health. The official
Telegram Bot API has moved far beyond the wrapper surface currently modeled in
Nadia. Preserve backwards-compatible Elixir function names where practical, but
verify remote Telegram method names against the current official docs before
adding or changing wrappers.
