# Media And Files

Telegram accepts file IDs, selected HTTP URLs, and multipart uploads. Nadia
keeps existing binary arguments compatible and provides `Nadia.InputFile` when
source intent, upload metadata, or nested `attach://` composition must be
explicit.

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

## Compose Nested Uploads

Pass structured maps, keyword lists, or structs containing `InputFile` values.
Nadia assigns collision-safe binary attachment names, replaces each nested
value with `attach://name`, and adds every multipart part:

```elixir
media = [
  %{
    type: "video",
    media: InputFile.path("/srv/media/demo.mp4"),
    thumbnail: InputFile.bytes(thumbnail, "thumbnail.jpg", max_bytes: 200_000),
    cover: InputFile.path("/srv/media/cover.jpg")
  },
  %{
    type: "document",
    media: InputFile.path("/srv/media/notes.pdf")
  }
]

Nadia.send_media_group(client, chat_id, media)
```

The same traversal supports paid media, edited media, profile photos, stories,
stickers, and other JSON payloads used by Nadia wrappers. Pre-encoded JSON
strings remain pass-through values; use a structured payload when Nadia must
discover `InputFile` values. An optional `:attach_name` is validated and made
unique within the request. Attachment names, filenames, paths, and parameter
keys never create atoms.

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

## Resolve A Download URL

`getFile` returns metadata, not bytes. `Nadia.get_file_link/2` builds a URL only
when `file_path` is present. The URL embeds the bot token and is a credential:
redact it from logs, traces, analytics, and error reports; never redirect an
untrusted browser or client to it; and do not store it as a public permanent
URL.

On Telegram's hosted API, downloads are currently limited to 20 MB and the URL
is guaranteed valid for **at least** one hour. Request `getFile` again after
expiry. Preserve the original message's filename and MIME type before calling
`getFile`, because the download metadata may lose them. Preflight the optional
`file_size`, but enforce the real byte cap while streaming because the field can
be absent or stale. The application-owned downloader must also bound redirects,
timeouts, destination size, partial-file cleanup, and backpressure.

A self-hosted local Bot API server permits uploads up to 2000 MB, downloads
without a size limit, local paths/file URIs, and may return an absolute local
`file_path`. Authorize and handle that as server-local filesystem data. Do not
concatenate an absolute path into Nadia's token-bearing hosted file URL.
`InputFile.path/2` always means “multipart-upload this path from Nadia's host”;
pass a server-local file URI as a plain Telegram string only when that local
Bot API deployment and its filesystem authorization are intentional.
