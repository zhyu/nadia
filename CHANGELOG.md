# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Added `%Nadia.Client{}` for explicit bot configuration, including default and
  named application-config constructors.
- Added token-redacted inspect output for `%Nadia.Client{}`.
- Added client-aware public Telegram wrapper arities, such as
  `Nadia.send_message(client, chat_id, text, options)`, while preserving legacy
  single-bot arities.
- Added client-aware `Nadia.API.request/4`, `Nadia.API.request?/4`, and
  `Nadia.API.build_file_url/2`.
- Added a Nadia-owned HTTP boundary with normalized `Nadia.HTTPRequest` and
  `Nadia.HTTPResponse` structs and configurable HTTP adapters.
- Added default-off `:telegram_live` smoke tests for two explicit bot clients.

### Changed

- Promoted Req to Nadia's production HTTP transport for both Telegram Bot API
  and Telegraph API requests.
- Replaced Bot API and Telegraph cassette coverage with deterministic offline
  request/response tests.
- Normalized Telegraph transport errors and malformed JSON responses into
  `Nadia.Graph.Model.Error`.

### Removed

- Removed HTTPoison, hackney, ExVCR, and hackney-specific SOCKS proxy
  configuration.

## 0.8.0 - 2026-06-02

### Changed

- Raised the minimum supported Elixir version to 1.15.
- Refreshed runtime dependencies for modern Elixir and Erlang/OTP releases:
  `httpoison` 2.3, `jason` 1.4, and the current compatible Hackney dependency
  graph.
- Updated CI to verify formatting, compilation with warnings as errors, tests,
  and documentation generation on modern Elixir/OTP versions.

### Removed

- Removed the legacy `inch_ex` documentation check in favor of ExDoc generation
  with warnings treated as errors.
