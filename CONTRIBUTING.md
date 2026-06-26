# Contributing

Thanks for helping improve Nadia. Nadia is a Mix library for the Telegram Bot
API and Telegraph API, so changes should stay small, well-tested, and aligned
with the public APIs those services document.

## Supported Toolchain

Nadia requires Elixir 1.20 or later and Erlang/OTP 27 or later. CI currently
checks Elixir 1.20.1 on OTP 27.3 and OTP 29.0.

Install dependencies before running checks:

```sh
mix deps.get
```

## Local Checks

For ordinary changes, run the checks that match the files you touched. Before a
pull request is ready, run the full offline set:

```sh
mix format --check-formatted
mix compile --warnings-as-errors
mix test
mix docs --warnings-as-errors
git diff --check
```

The normal test suite is offline and does not need Telegram credentials.

## Live Telegram Tests

Optional maintainer smoke tests live under `test/live` and are tagged
`:telegram_live`:

```sh
mix test --only telegram_live
```

These tests are default-off. They require credentials from `.env.live.local`,
seeded from `.env.live.local.example`, and two bots with Bot-to-Bot
Communication Mode enabled.

## Public API And Changelog

Update `CHANGELOG.md` for user-facing changes. This includes public API
changes, configuration changes, dependency or transport changes, behavior
changes, new Mix tasks, guides, and notable workflow changes. Internal-only
refactors usually do not need a changelog entry.

Keep README and ExDoc guides current when changing installation,
configuration, public wrappers, runtime helpers, or release behavior. Generated
ExDoc output goes to `doc/` and should not be committed.

## Bot API Maintenance

When adding or changing Telegram Bot API wrappers, verify method names,
parameters, and response shapes against the current official Telegram
documentation. Preserve backwards-compatible Elixir function names where
practical, and add tests for wrapper request encoding and response parsing.

Telegram and Telegraph response parsing should not create atoms from remote JSON
keys. Unknown future fields should remain ignored until Nadia explicitly models
them.

Req is Nadia's production HTTP transport. Do not reintroduce HTTPoison, hackney,
ExVCR, VCR cassettes, or hackney-specific proxy configuration.

## Working In The Repository

The worktree may contain other people's unfinished work. Do not revert unrelated
changes. Keep commits focused, and avoid broad refactors unless they are needed
for the change being made.

## Release Process

Publishing is done by GitHub Actions, not by local `mix hex.publish`. The
release workflow is `.github/workflows/release.yml`; it verifies the tag version
against `mix.exs`, runs release checks, builds the Hex package, and publishes to
Hex after the `hex-publish` environment is approved.

Before tagging a release, confirm `mix.exs`, `CHANGELOG.md`, README install
snippets, ExDoc guides, and packaged files match the intended version. Release
tags should be annotated tags such as:

```sh
git tag -a v1.6.0 <release-commit> -m "Release 1.6.0"
git push origin v1.6.0
```

Do not run `mix hex.publish` locally unless the maintainer explicitly decides to
bypass CI.
