# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Added Telegram poll response structs and parser coverage for `Message.poll`,
  update-level `poll` and `poll_answer` updates, poll option service messages,
  and `stopPoll` results.
- Added Telegram reaction response structs and parser coverage for
  `message_reaction` and `message_reaction_count` updates.
- Added Telegram chat boost response structs and parser coverage for
  `chat_boost`, `removed_chat_boost`, `Message.boost_added`, and
  `getUserChatBoosts` results.
- Added Telegram paid media response structs and parser coverage for
  `Message.paid_media`, `purchased_paid_media` updates, and `sendPaidMedia`
  results.
- Added Telegram managed bot response structs and parser coverage for
  `Message.managed_bot_created`, `managed_bot` updates, and
  `getManagedBotAccessSettings` results.
- Added Telegram business and guest-query response structs and parser coverage
  for `business_connection`, `deleted_business_messages`, business chat profile
  fields, and `answerGuestQuery` results.
- Added Bot API wrappers for guest queries, business connections, managed bot
  token/access settings, user chat boosts, and user personal chat messages.
- Added Bot API wrappers for business account read/delete, profile, gift
  settings, and Stars transfer maintenance.
- Added Bot API wrappers for bulk message deletion and message reaction
  maintenance.
- Added Bot API wrappers for chat administration, membership restrictions,
  join-request moderation, chat metadata, pinned-message, and chat sticker-set
  maintenance.
- Added Bot API wrappers for bot lifecycle and public bot settings maintenance,
  including commands, descriptions, menu button, default administrator rights,
  and user emoji status updates.
- Added Bot API wrappers and response structs for object-returning bot settings
  getters, including commands, profile names/descriptions, menu buttons, and
  default administrator rights.
- Added Bot API wrappers and response structs for bot profile photos and Mini
  App prepared inline messages and keyboard buttons.
- Added Bot API forum topic wrappers, `%Nadia.Model.ForumTopic{}`, and parser
  coverage for `createForumTopic` and `getForumTopicIconStickers` results.
- Added Bot API wrappers for modern sticker set and custom emoji sticker
  maintenance, including `getCustomEmojiStickers` parser coverage.
- Added Bot API invite-link and user profile audio wrappers, plus
  `%Nadia.Model.ChatInviteLink{}` and `%Nadia.Model.UserProfileAudios{}`
  parser/model support.
- Added Bot API copy/forward wrappers for `copyMessage`, `copyMessages`, and
  `forwardMessages`, plus `%Nadia.Model.MessageId{}` parser/model support.
- Added Bot API send wrappers for `sendVideoNote`, `sendLivePhoto`,
  `sendMediaGroup`, `sendPaidMedia`, `sendPoll`, `sendDice`, and
  `sendMessageDraft`.
- Added Bot API `sendChecklist` wrapper plus checklist model/parser support for
  `Message.checklist`.
- Added Bot API updating-message wrappers for editing media, live locations,
  checklists, stopping polls, and approving or declining suggested posts.

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
- Added option-support arities for existing Bot API wrappers
  `forward_message`, `send_chat_action`, `delete_webhook`,
  `get_chat_administrators`, `unban_chat_member`, and `unpin_chat_message`.

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
