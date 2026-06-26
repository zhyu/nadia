# Rich Messages And Stories

Nadia provides typed construction for Telegram rich messages, poll options,
and clickable story areas. These helpers validate facts available without
parsing Telegram's formatting languages or decoding media.

The tested source lives in `examples/media_files.ex`. Copy and rename that
module under your application's `lib/` directory, then replace its sample
content and application-specific limits.

## Send Rich Messages

Choose the formatting mode at construction time:

```elixir
rich_message =
  Nadia.InputRichMessage.html(
    "<h2>Nadia</h2><p>Typed Telegram Bot API helpers.</p>",
    is_rtl: false,
    skip_entity_detection: false
  )

Nadia.send_rich_message(client, chat_id, rich_message)
```

Use `markdown/2` for Telegram's rich Markdown style. Exactly one mode is
encoded. Nadia validates valid UTF-8, the 32,768-character source limit, and
Boolean flags. It does not parse HTML or Markdown.

Telegram enforces the formatting grammar and these rendered-structure limits:

| Telegram rich-message limit | Local Nadia validation |
| --- | --- |
| 32,768 UTF-8 characters in message text | Source characters and UTF-8 are checked |
| 500 blocks including nested blocks | Telegram-enforced |
| 16 nesting levels | Telegram-enforced |
| 50 media attachments | Telegram-enforced |
| 20 table columns | Telegram-enforced |
| Supported tags, entities, block structure, media URLs and MIME detection | Telegram-enforced |
| Permission to send embedded media | Telegram-enforced |

Media blocks accept HTTP and HTTPS URLs only. Nadia deliberately does not add a
formatting parser or fetch media to infer MIME types.

## Stream A Draft, Then Finalize It

```elixir
draft =
  Nadia.InputRichMessage.html(
    "<tg-thinking>Preparing the answer</tg-thinking>"
  )

:ok = Nadia.send_rich_message_draft(client, private_chat_id, draft_id, draft)

final =
  Nadia.InputRichMessage.html(
    "<h2>Answer</h2><p>The completed response.</p>"
  )

Nadia.send_rich_message(client, private_chat_id, final)
```

A rich-message draft is an ephemeral 30-second preview. It does not become a
chat message: always call `sendRichMessage` with the final content.
`<tg-thinking>` is draft-only. Typed values containing the literal opening tag
are rejected in send, edit, and inline-content contexts. The detection is
intentionally conservative because Nadia does not parse the surrounding
formatting grammar.

## Edit And Use Inline Content

```elixir
Nadia.edit_message_text(
  client,
  chat_id,
  message_id,
  nil,
  rich_message: Nadia.InputRichMessage.markdown("## Updated")
)

content =
  Nadia.InputRichMessageContent.new(
    Nadia.InputRichMessage.html("<p>Inline result</p>")
  )

result = %Nadia.Model.InlineQueryResult.Article{
  id: "rich-result",
  title: "Rich result",
  input_message_content: content
}

Nadia.answer_inline_query(client, inline_query_id, [result])
```

Typed inline content is traversed by the same JSON encoder used for inline
queries, guest replies, Web App replies, and prepared inline messages.

## Add Clickable Story Areas

```elixir
position = Nadia.StoryArea.position(50, 82, 40, 12, 0, 2)

areas = [
  Nadia.StoryArea.location(
    position,
    35.6762,
    139.6503,
    address: Nadia.StoryArea.location_address("JP", city: "Tokyo")
  ),
  Nadia.StoryArea.suggested_reaction(
    position,
    Nadia.ReactionType.emoji("👍"),
    is_dark: false,
    is_flipped: false
  ),
  Nadia.StoryArea.link(position, "https://hexdocs.pm/nadia"),
  Nadia.StoryArea.weather(position, 24.5, "☀️", 0xFF112233),
  Nadia.StoryArea.unique_gift(position, "Nadia Gift")
]

Nadia.post_story(
  client,
  business_connection_id,
  story_content,
  86_400,
  areas: areas
)
```

All six `StoryAreaPosition` fields are required and numeric. Nadia enforces the
official 0-360 rotation range. Telegram documents the remaining values as
percentages without publishing a numeric validity range, so Nadia does not
invent one: negative and greater-than-100 percentages remain representable.

Nadia applies conventional geographic latitude and longitude ranges, validates
uppercase two-letter country codes, accepts HTTP, HTTPS, and `tg://` links,
preserves explicit false reaction flags, and validates an unsigned 32-bit ARGB
weather color. Gift names and standard reaction emoji are kept as strings
without creating atoms or inventing undocumented naming rules.

## Official Variant Coverage

| Story area type | Typed builder | Per-story limit checked locally |
| --- | --- | --- |
| Location | `StoryArea.location/4` | 10 |
| Suggested reaction | `StoryArea.suggested_reaction/3` | 5 |
| Link | `StoryArea.link/2` | 3 |
| Weather | `StoryArea.weather/4` | 3 |
| Unique gift | `StoryArea.unique_gift/2` | 1 |

Suggested reactions support `ReactionType.emoji/1`,
`ReactionType.custom_emoji/1`, and `ReactionType.paid/0`.

## Context Coverage

| Typed value | Send | Draft | Edit | Inline result | Story post/edit |
| --- | --- | --- | --- | --- | --- |
| `InputRichMessage` | Yes | Yes | Yes | Through `InputRichMessageContent` | No |
| `<tg-thinking>` in typed rich content | No | Yes | No | No | No |
| `InputPollOption` | `sendPoll` only | No | No | No | No |
| `StoryArea` | No | No | No | No | Yes |

## Compatibility

| Existing input | Behavior |
| --- | --- |
| Raw map or keyword object | Preserved and JSON encoded |
| Arbitrary struct | Preserved through its fields |
| Mixed typed/raw list | Typed members validate; raw members pass through |
| Pre-encoded JSON binary | Preserved without re-encoding |
| Explicit `false` | Preserved |
| `nil` inside structured values | Omitted |
| Malformed typed opaque value | `%Nadia.Model.Error{}` before HTTP |

Raw inputs remain the forward-compatibility escape hatch. Nadia does not apply
typed discriminator, context, count, or relationship checks to raw future
variants, except that an empty poll option list is rejected as structurally
invalid.

The official field semantics are documented by Telegram under
[InputRichMessage](https://core.telegram.org/bots/api#inputrichmessage),
[InputPollOption](https://core.telegram.org/bots/api#inputpolloption), and
[StoryArea](https://core.telegram.org/bots/api#storyarea).
