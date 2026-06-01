# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## 0.8.0 - 2026-06-01

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
