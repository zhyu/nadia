# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed

- Expanded Telegram response parsing for selected modern `Update`, `Message`,
  `User`, `MessageEntity`, and `PhotoSize` fields, including fixture-backed
  `getUpdates` coverage with string-key JSON decoding and no atom creation for
  unknown response fields.
- Preserved explicit `false` Telegram Bot API and Telegraph API request
  parameters while continuing to omit `nil` parameters.
- Replaced obsolete Telegram Bot API method wrappers `kick_chat_member` and
  `get_chat_members_count` with current `ban_chat_member` and
  `get_chat_member_count` wrappers.

## 0.9.0 - 2026-06-05

### Added

- Added `%Nadia.Client{}` for explicit bot configuration, including default and
  named application-config constructors.
- Added token-redacted inspect output for `%Nadia.Client{}`.
- Added client-aware public Telegram wrapper arities, such as
  `Nadia.send_message(client, chat_id, text, options)`, while preserving legacy
  single-bot arities.
- Added client-aware `Nadia.API.request/4`, `Nadia.API.request?/4`, and
  `Nadia.API.build_file_url/2`.
- Added a Nadia-owned HTTP boundary with normalized request/response structs
  and configurable HTTP adapters.
- Added default-off `:telegram_live` smoke tests for two explicit bot clients.

### Changed

- Raised the minimum supported Elixir version to 1.20 and aligned CI/release
  workflows with Elixir 1.20 on current Erlang/OTP releases.
- Promoted Req to Nadia's production HTTP transport for both Telegram Bot API
  and Telegraph API requests.
- Decode Telegram Bot API and Telegraph API responses without creating atoms
  from remote JSON keys; unknown response fields remain ignored until Nadia
  explicitly models them.
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
