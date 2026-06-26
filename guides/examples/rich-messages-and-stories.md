# Rich Messages And Stories

Nadia provides typed construction for Telegram rich messages, poll options,
and clickable story areas. These helpers validate facts available without
parsing Telegram's formatting languages or decoding media.

The tested rich-message, inline-content, and photo-story helper source lives in
`examples/media_files.ex`. Copy and rename that module under your application's
`lib/` directory, then replace its sample content and application-specific
limits. The snippets below match those helpers where they show a complete
request; the variant tables describe the broader typed builder surface.

## Send Rich Messages

Choose the formatting mode at construction time:

```elixir
rich_message =
  Nadia.InputRichMessage.html(
    "<h2>Nadia</h2><p>Typed Telegram Bot API helpers.</p>",
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

The tested draft helper sends only the draft preview:

```elixir
rich_message =
  Nadia.InputRichMessage.html(
    "<tg-thinking>Preparing the summary.</tg-thinking><p>Almost ready.</p>"
  )

:ok = Nadia.send_rich_message_draft(client, chat_id, draft_id, rich_message)
```

A rich-message draft is an ephemeral 30-second preview. It does not become a
chat message: send the final content with `sendRichMessage` when it is ready.
The example source tests the draft request and the normal rich send as separate
helpers; composing them into one generator workflow is application code.
`<tg-thinking>` is draft-only. Typed values containing the literal opening tag
are rejected in send, edit, and inline-content contexts. The detection is
intentionally conservative because Nadia does not parse the surrounding
formatting grammar.

## Edit And Use Inline Content

```elixir
rich_message =
  Nadia.InputRichMessage.markdown(
    "## Updated\nThe example guide is ready.",
    skip_entity_detection: true
  )

Nadia.edit_message_text(
  client,
  chat_id,
  message_id,
  nil,
  nil,
  rich_message: rich_message
)

result = %Nadia.Model.InlineQueryResult.Article{
  id: "rich-guide",
  title: "Rich guide",
  input_message_content:
    "<p>Inline <b>Nadia</b> result.</p>"
    |> Nadia.InputRichMessage.html()
    |> Nadia.InputRichMessageContent.new()
}

Nadia.answer_inline_query(client, inline_query_id, [result], cache_time: 60)
```

Typed inline content is traversed by the same JSON encoder used for inline
queries, guest replies, Web App replies, and prepared inline messages.
The tested `answer_inline_content_query/2` helper also covers the other current
inline content variants:
`Nadia.InputTextMessageContent`, `Nadia.InputInvoiceMessageContent`,
`Nadia.InputLocationMessageContent`, `Nadia.InputVenueMessageContent`, and
`Nadia.InputContactMessageContent`. Invoice price portions can use
`Nadia.LabeledPrice`.

## Add Clickable Story Areas

```elixir
content =
  story_path
  |> Nadia.InputFile.path(max_bytes: 10_000_000)
  |> Nadia.InputStoryContent.photo()

position = Nadia.StoryArea.position(50, 85, 40, 10, 0, 2)

areas = [
  Nadia.StoryArea.link(position, "https://hexdocs.pm/nadia")
]

Nadia.post_story(client, business_connection_id, content, 86_400, areas: areas)
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

The `post_photo_story/4` helper exercises a link area in a real request. The
other typed area constructors are listed below; their local validation is
covered by focused builder tests.

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
| `Input*MessageContent` | No | No | No | Yes | No |
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
