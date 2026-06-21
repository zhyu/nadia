# Nadia Agent Notes

## Start Every Session

- Read the relevant local files before acting; prefer `README.md`,
  `CHANGELOG.md`, `mix.exs`, `.github/workflows/*.yml`, tests, and commit
  history over stale planning notes.
- Expect a dirty worktree may contain user work. Do not revert unrelated
  changes unless explicitly asked.

## Project Shape

Nadia is a Mix library for the Telegram Bot API and Telegraph API.

- Public Telegram wrappers live mainly in `lib/nadia.ex`.
- Request/response plumbing lives in `lib/nadia/api.ex`,
  `lib/nadia/graph/api.ex`, `lib/nadia/http_request.ex`,
  `lib/nadia/http_response.ex`, and `lib/nadia/http_client.ex`.
- The default HTTP adapter is `Nadia.HTTPClient.Req` in
  `lib/nadia/http_client/req.ex`.
- Structs and parsing live in `lib/nadia/model.ex` and `lib/nadia/parser.ex`.
- Bot usability helpers live in modules such as `Nadia.Context`,
  `Nadia.Dispatcher`, `Nadia.Polling`, `Nadia.Webhook`, and
  `Nadia.SessionStore`.
- Telegraph support lives under `lib/nadia/graph*`.
- Tests use ExUnit with deterministic offline fixtures under
  `test/fixtures/telegram/responses`. Optional live Telegram smoke tests live
  in `test/live` and are tagged `:telegram_live`.

Nadia requires Elixir 1.20 or later. CI verifies formatting, compilation with
warnings as errors, tests, and docs on current Elixir/OTP versions defined in
`.github/workflows/elixir.yml`.

Req is the production HTTP transport. Do not reintroduce HTTPoison, hackney,
ExVCR, VCR cassettes, or hackney-specific SOCKS proxy configuration as current
patterns.

Telegram and Telegraph response parsing should avoid creating atoms from remote
JSON keys. Unknown future response fields should remain ignored until Nadia
explicitly models them.

## Common Commands

Development checks:

```sh
mix deps.get
mix format --check-formatted
mix compile --warnings-as-errors
mix test
mix docs --warnings-as-errors
git diff --check
```

Optional live Telegram smoke tests are default-off:

```sh
mix test --only telegram_live
```

They require credentials from `.env.live.local`, seeded from
`.env.live.local.example`, and two bots with Bot-to-Bot Communication Mode
enabled.

Mix may need permission to open a local TCP socket for `Mix.PubSub` or docs
filesystem locking in sandboxed environments. If `mix docs --warnings-as-errors`
fails with a TCP/filesystem-lock `:eperm`, rerun that exact command with the
required sandbox escalation rather than inventing a workaround.

## Docs And Planning

When making user-facing changes, update `CHANGELOG.md` in the same slice or in
a follow-up changelog commit.

User-facing changes include public API changes, configuration changes,
dependency or transport changes, behavior changes, new Mix tasks, guides, and
notable test or live-test workflow changes. Internal-only refactors do not need
changelog entries unless they affect users or release risk.

`README.md` is the user-facing overview and install/configuration guide.
Generated ExDoc output goes to `doc/`, which is ignored by git; verify docs
with `mix docs --warnings-as-errors` rather than committing generated HTML.

## Release Workflow

Publishing is done by GitHub Actions, not by local `mix hex.publish`.

The release workflow is `.github/workflows/release.yml`. It runs on release tag
pushes, verifies that the tag version matches `mix.exs`, runs the full release
checks, builds the Hex package, and publishes to Hex from CI with the
`HEX_API_KEY` secret after the `hex-publish` environment is approved.

Before tagging a release:

- Confirm `mix.exs` `@version`, `CHANGELOG.md`, README install snippets, and
  ExDoc guides match the intended release.
- Confirm package docs/guides that ExDoc references are included in the Hex
  package files. `mix hex.build` should show expected guide files.
- Run:

```sh
mix format --check-formatted
mix compile --warnings-as-errors
mix test
mix docs --warnings-as-errors
git diff --check
mix hex.build
```

Tag releases with annotated tags, for example:

```sh
git tag -a v1.5.0 <release-commit> -m "Release 1.5.0"
git push origin v1.5.0
```

Do not run `mix hex.publish` locally. If a local publish command is requested,
verify that the user really wants to bypass CI.

When a release train has multiple version commits, tag and publish one version
at a time. After pushing each tag:

1. Find the CI run for the tag:

   ```sh
   gh run list --repo zhyu/nadia --workflow release.yml --limit 10
   ```

2. Wait for `Verify Release` to pass.
3. Approve the pending `hex-publish` deployment if authorized, or ask the user
   to approve it in GitHub. The pending deployment can be inspected with:

   ```sh
   gh api repos/zhyu/nadia/actions/runs/<run-id>/pending_deployments
   ```

4. Wait for `Publish to Hex` to pass:

   ```sh
   gh run watch <run-id> --repo zhyu/nadia --exit-status
   ```

5. Verify Hex reports the exact version and docs before tagging the next
   release:

   ```sh
   curl -fsS https://hex.pm/api/packages/nadia/releases/<version>
   ```

If a wrong tag was pushed and the publish job is waiting for approval, cancel
the workflow run before deleting the tag. Then delete the bad remote tag and
local tag, repair the release history, and push corrected tags only after the
fixed commits are in place.

## Bot API Maintenance

For Bot API updates, verify Telegram method names and response shapes against
the current official docs before adding or changing wrappers. Preserve
backwards-compatible Elixir function names where practical, and update README,
CHANGELOG, tests, parser/model coverage, and package docs when public coverage
changes.
