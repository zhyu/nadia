# Media And Files

Telegram accepts file IDs, selected HTTP URLs, and multipart uploads. Nadia
keeps existing binary arguments compatible and provides `Nadia.InputFile` when
source intent, upload metadata, or nested `attach://` composition must be
explicit. `Nadia.InputMedia` and `Nadia.InputSticker` add fixed-discriminator
builders. `Nadia.InputPaidMedia`, `Nadia.InputPollMedia`,
`Nadia.InputProfilePhoto`, and `Nadia.InputStoryContent` cover the other
current outgoing-content families, while `Nadia.download_file/3,4,5` provides
bounded download-to-file.

The complete tested helper is
[`examples/media_files.ex`](https://github.com/zhyu/nadia/blob/master/examples/media_files.ex).
Files under `examples/` ship in the Hex package but are not compiled into Nadia.
Copy the module under your application's `lib/` directory and rename it.

## Choose A Source

```elixir
alias Nadia.InputFile

Nadia.send_document(client, chat_id, InputFile.file_id(document.file_id))

Nadia.send_document(
  client,
  chat_id,
  InputFile.url("https://cdn.example.com/manual.pdf")
)

Nadia.send_document(
  client,
  chat_id,
  InputFile.path("/srv/my_app/manual.pdf", max_bytes: 50_000_000)
)
```

Bare binaries retain Nadia's previous rule: an existing regular local path is
uploaded; any other binary is passed to Telegram as a file ID, URL, or other
string. Because a missing bare path is indistinguishable from a file ID, use
`InputFile.path/2` whenever path intent matters. Explicit paths are checked for
existence, regular-file type, readability, and `:max_bytes` before the HTTP
adapter is called. A file can still change between validation and streaming,
so normal transport error handling remains necessary.

File IDs are bot-scoped and cannot change media type. `file_unique_id` is useful
for cross-bot correlation but cannot download or reuse a file. URLs must be
HTTP or HTTPS and reachable by Telegram; method-specific support varies. For
example, `sendDocument` URL fetching is documented for PDF and ZIP, video notes
and live photos cannot use URLs, and thumbnails can only be new uploads.

On Telegram's hosted API, the current general limits are 5 MB for photo URLs,
20 MB for other URLs, 10 MB for multipart photos, and 50 MB for other multipart
files. Individual methods can be narrower. Treat the official
[Sending files](https://core.telegram.org/bots/api#sending-files) section as
authoritative.

## Build Typed Media

The six members of Telegram's `InputMedia` union have public builders:

```elixir
alias Nadia.InputFile
alias Nadia.InputMedia

media = [
  InputMedia.video(
    InputFile.path("/srv/media/demo.mp4"),
    thumbnail: InputFile.bytes(thumbnail, "thumbnail.jpg", max_bytes: 200_000),
    cover: InputFile.path("/srv/media/cover.jpg"),
    supports_streaming: true
  ),
  InputMedia.photo(InputFile.file_id(photo.file_id), has_spoiler: false)
]

Nadia.send_media_group(client, chat_id, media)
```

Builders fix `type`, reject missing required fields, omit `nil`, and preserve
explicit `false`. Multiple nested files receive collision-safe binary
attachment names and become `attach://name` references. An explicit
`:attach_name` is validated and made unique within the request. Attachment
names, filenames, paths, IDs, and parameter keys never create atoms.

| Variant | Edit | Album | Paid media | Poll description / explanation | Poll option |
| --- | --- | --- | --- | --- | --- |
| Animation | Yes | No | No | Yes | Yes |
| Audio | Yes | Audio-only | No | Yes | No |
| Document | Yes | Document-only | No | Yes | No |
| Live photo | Yes | Yes | Yes | Yes | Yes |
| Photo | Yes | Yes | Yes | Yes | Yes |
| Video | Yes | Yes | Yes | Yes | Yes |
| Location | No | No | No | Yes | Yes |
| Venue | No | No | No | Yes | Yes |
| Link | No | No | No | No | Yes |
| Sticker | No | No | No | No | Yes |

Typed media groups are checked locally: they must contain 2-10 items,
animations are rejected, audio/document albums must be homogeneous, and
photo/live-photo/video items may mix. An inline `editMessageMedia` call cannot
upload a new file; use file IDs or a supported URL. Live-photo video and photo
fields do not support URLs.

Thumbnails are new JPEG multipart uploads only, under 200 KB and at most
320x320. They cannot be file IDs or URLs. Video covers may be file IDs, URLs,
or uploads.

Poll-only values use a separate module because they are invalid for albums and
media edits:

```elixir
options = [
  Nadia.InputPollOption.new(
    "Read the guide",
    media: Nadia.InputPollMedia.link("https://hexdocs.pm/nadia")
  ),
  Nadia.InputPollOption.new("Visit the office")
]

Nadia.send_poll(
  client,
  chat_id,
  "Where next?",
  options: options,
  media: Nadia.InputPollMedia.location(35.6762, 139.6503),
  allows_revoting: false
)
```

`link/1` is poll-option-only. `sticker/2` is also option-only; HTTP sticker
URLs must identify WEBP files, while uploads use WEBP, TGS, or WEBM filenames.
`location/3` and `venue/5` work in descriptions, quiz explanations, and
options. Typed quiz explanation media requires `type: "quiz"`.

`Nadia.InputPollOption.new/2` validates 1-100 UTF-8 characters, makes
`:text_parse_mode` and `:text_entities` mutually exclusive, and checks typed
media against the official option context. When typed options are present,
Nadia also validates the 1-12 option count and locally inspectable quiz
`correct_option_ids` ordering, uniqueness, and bounds. Telegram still validates
entity offsets and the current custom-emoji-only option formatting rule.

## Build Paid Media

```elixir
paid_media = [
  Nadia.InputPaidMedia.photo(Nadia.InputFile.file_id(photo_id)),
  Nadia.InputPaidMedia.video(
    Nadia.InputFile.path("/srv/media/paid.mp4"),
    thumbnail: Nadia.InputFile.path("/srv/media/paid-thumb.jpg"),
    supports_streaming: false
  )
]

Nadia.send_paid_media(client, chat_id, 25, paid_media)
```

Typed paid-media lists contain 1-10 live photos, photos, or videos. Live-photo
video and photo fields do not accept URLs. Video thumbnails must be new
multipart uploads; covers can be file IDs, URLs, or uploads. Telegram enforces
the 1-25,000 Star price, payload and caption lengths, media contents, and
thumbnail JPEG dimensions. Nadia validates only the typed list shape and
locally inspectable source rules.

## Upload Profile Photos And Stories

These typed families intentionally accept only explicit new uploads:

```elixir
profile =
  Nadia.InputProfilePhoto.static(
    Nadia.InputFile.path("/srv/media/profile.jpg", max_bytes: 10_000_000)
  )

story =
  Nadia.InputStoryContent.video(
    Nadia.InputFile.path("/srv/media/story.mp4", max_bytes: 30_000_000),
    duration: 12.5,
    cover_frame_timestamp: 0,
    is_animation: false
  )

Nadia.set_my_profile_photo(client, profile)
Nadia.post_story(client, business_connection_id, story, 86_400)
```

Typed profile photos and stories reject bare binaries, file IDs, URLs, and
manual `attach://` references because Telegram forbids reuse. Paths, bounded
iodata, and known-size streams are supported. Nadia validates timestamps,
story duration, and booleans. It does not decode media to verify JPG/MPEG4
format, 1080x1920 story photos, 720x1280 H.265 streamable story videos,
one-second keyframes, sound, or actual dimensions. Telegram enforces those
content rules. Caller `:max_bytes` bounds provide local size policy.

See [Rich Messages And Stories](rich-messages-and-stories.md) for complete
typed story-area construction and the rich-message formatting boundary.

## Compatibility

| Existing input | Behavior after typed builders |
| --- | --- |
| Raw map or keyword object | Preserved and JSON encoded |
| Arbitrary struct | Preserved through its fields |
| Pre-encoded JSON binary | Preserved without re-encoding |
| Nested `Nadia.InputFile` in structured values | Discovered as multipart |
| Valid typed value | Validated, encoded, and traversed |
| Malformed typed value | Returns `%Nadia.Model.Error{}` before HTTP |
| Mixed typed and raw paid/poll list | Typed members validate; raw members pass through |
| Mixed typed and raw media-group list | Preserved as the existing raw compatibility path |

Raw values remain useful for forward compatibility, but Nadia cannot enforce
context, discriminator, or upload-only rules for them. A pre-encoded JSON
string cannot contain a live Elixir `InputFile`.

## Build Typed Stickers

Use the format-specific builders with the current sticker-set methods:

```elixir
alias Nadia.InputSticker

stickers = [
  InputSticker.static(
    InputFile.path("/srv/stickers/hello.webp", max_bytes: 512_000),
    ["👋"],
    keywords: ["hello", "wave"]
  ),
  InputSticker.video(
    InputFile.path("/srv/stickers/party.webm"),
    ["🎉"]
  )
]

Nadia.create_new_sticker_set(
  client,
  owner_user_id,
  "nadia_by_bot",
  "Nadia",
  stickers,
  sticker_type: "regular"
)
```

| Builder | Fixed format | Accepted source |
| --- | --- | --- |
| `static/3` | `static` | file ID, HTTP URL, or WEBP/PNG upload |
| `animated/3` | `animated` | file ID or TGS upload; no URL |
| `video/3` | `video` | file ID or WEBM upload; no URL |

Each sticker requires 1-20 emoji strings. Keywords accept 0-20 strings with a
combined length of at most 64 characters. `mask_position` is for mask sets;
keywords are for regular and custom-emoji sets.

Current `upload_sticker_file/3,4`, `create_new_sticker_set/4,5,6`,
`add_sticker_to_set/3,4`, and `replace_sticker_in_set/4,5` shapes are exposed.
Historical PNG-and-emoji create/add calls remain compatible and are translated
to one static `InputSticker`. `contains_masks: true` becomes
`sticker_type: "mask"`, and the legacy `mask_position` moves inside the
sticker. Migrate new code to the typed forms because the old request fields no
longer describe Telegram's current API.

Raw outgoing-content maps, keyword lists, arbitrary structs, and pre-encoded
JSON remain pass-through values. Use a structured value when Nadia must
discover `InputFile` uploads.

## Bound Memory And Streams

`InputFile.bytes/3` accepts iodata, calculates its size without flattening it,
and sends the existing data without a temporary-file copy:

```elixir
file =
  InputFile.bytes(generated_pdf, "report.pdf",
    content_type: "application/pdf",
    max_bytes: 5_000_000
  )
```

The application already owns that in-memory data; Nadia does not make it small.
Always set an application limit before accumulating user-controlled or generated
content.

For a producer that is finite and replay is not required, use a known-size
Enumerable:

```elixir
file =
  InputFile.stream(chunks, "archive.bin",
    size: exact_byte_count,
    max_bytes: 50_000_000,
    content_type: "application/octet-stream"
  )
```

Nadia yields chunks to Req without collecting them, checks emitted iodata
against the declared size, disables Req retries and redirects, and sends a
Content-Length. A mismatch can be discovered only after part of the request was
written. Nadia does not support unknown-size or infinite streams, arbitrary IO
devices, rewind/replay, or automatic ownership of caller-opened resources.
`File.Stream` owns its open/close lifecycle during enumeration; callers own the
cleanup behavior of custom `Stream.resource/3` producers. Never blindly retry
an ambiguous upload failure.

## Download To A File

Use a mandatory application limit:

```elixir
Nadia.download_file(
  client,
  document.file_id,
  "/srv/my_app/downloads/report.pdf",
  20_000_000,
  receive_timeout: 30_000
)
```

A file ID performs one fresh `getFile` metadata request. Passing an existing
`%Nadia.Model.File{}` skips that request and may therefore use an expired path.
Telegram's optional `file_size` is checked before transfer when available; the
real byte count is enforced on every chunk and checked against `Content-Length`
and the final file.

The default Req adapter:

* never buffers the whole response and keeps only one transport chunk in
  Nadia-managed memory;
* disables redirects, retries, decompression, and response-body decoding;
* refuses an existing destination unless `overwrite: true` is explicit;
* writes an exclusive hidden temp in the destination directory, syncs it, and
  publishes only after status and size validation;
* removes partial temps after ordinary status, timeout, transport, size,
  write, and publication failures;
* returns normalized errors without the URL, token, redirect location,
  response body, or raw Req exception.

No-overwrite publication uses a same-filesystem hard link so a racing
destination cannot be replaced. Filesystems without reliable exclusive
creation and hard-link semantics fail with
`:atomic_publication_unsupported`. Explicit overwrite uses a same-directory
rename. A VM or host crash can still leave a hidden `.nadia-download-*` temp;
operations teams may scavenge old files with that pattern.

On Telegram's hosted API, downloads are currently limited to 20 MB and the URL
is guaranteed valid for at least one hour. Preserve the original message's
filename and MIME type before `getFile`, because its download metadata may lose
them. Nadia does not silently retry an expired path, timeout, partial transfer,
or ambiguous failure.

For a trusted local Bot API server started in local mode, configure:

```elixir
client =
  Nadia.Client.new(
    token: token,
    base_url: "http://bot-api.internal/bot",
    file_mode: :local
  )
```

Local mode requires the absolute `file_path` returned by Telegram to be
accessible in Nadia's filesystem namespace. Nadia performs the same bounded
temp-file copy without constructing a token URL. Remote mode rejects absolute
paths; local mode rejects relative paths. A local Bot API server on another
host without a shared filesystem is unsupported.

Custom adapters keep their existing `post/1` compatibility. To support
downloads they must implement Nadia's optional adapter download callback and
obey `Nadia.HTTPDownloadRequest`'s no-buffer, no-redirect, no-retry,
no-token-log contract. Nadia cannot enforce those properties inside an
untrusted custom adapter.

Arbitrary sinks, caller-owned IO devices, in-memory binary downloads, ranges,
resume, automatic retries, redirects, remote object stores, and filesystems
without atomic local publication are intentionally unsupported.

`Nadia.get_file_link/1,2` remains a lower-level compatibility helper for remote
relative paths. Its result embeds the bot token and must be treated as a
credential. It rejects absolute local paths and is not used by the recommended
download flow.
