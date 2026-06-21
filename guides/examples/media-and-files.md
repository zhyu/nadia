# Media And Files

Telegram accepts a file ID, an HTTP URL, or a multipart upload for most
single-file methods. Nadia represents all three as binaries, so application
code should make the intended source explicit before calling the API.

The complete tested helper is
[`examples/media_files.ex`](https://github.com/zhyu/nadia/blob/master/examples/media_files.ex).
Files under `examples/` ship in the Hex package but are not compiled into the
Nadia application. Copy the module into your application's `lib/`, rename it
for your application, and keep the explicit `%Nadia.Client{}` argument. Nadia's
test suite loads the source directly and exercises it without credentials.

## Choose A Source

```elixir
alias MyApp.MediaFiles

MediaFiles.send_document(client, chat_id, {:file_id, document.file_id})

MediaFiles.send_document(
  client,
  chat_id,
  {:url, "https://cdn.example.com/manual.pdf"}
)

MediaFiles.send_document(client, chat_id, {:path, "/srv/my_app/manual.pdf"})
```

The same underlying `Nadia.send_document/4` call is used in each case:

* A file ID is the cheapest option because Telegram already stores the bytes.
  IDs are scoped to one bot, cannot change the media type, and more than one ID
  can identify the same file.
* For a URL, Telegram fetches the remote file. It must be reachable by Telegram
  and have the expected MIME type. URL support varies by method; for example,
  `sendDocument` currently accepts PDF and ZIP URLs, while video notes do not
  accept URLs.
* An existing local path makes Nadia build multipart form data. The Req adapter
  streams the path from disk rather than reading the complete file into one
  binary.

On Telegram's hosted Bot API, the documented generic limits are 5 MB for photo
URLs and 20 MB for other URLs, versus 10 MB for multipart photos and 50 MB for
other multipart files. Individual methods can impose narrower format or size
rules. Treat the current [Sending files](https://core.telegram.org/bots/api#sending-files)
section as authoritative.

## Report Path Errors Locally

Nadia's low-level wrappers cannot tell a nonexistent path from a file ID. A
bare missing path therefore becomes a normal form value and Telegram rejects
it later. The example's tagged `{:path, path}` source checks `File.stat/1` and
returns one of these results without making a request:

```elixir
{:error, {:file_error, :enoent}}
{:error, {:file_error, :not_regular}}
```

Validate paths after authorization, use application-owned directories, and do
not let user input select arbitrary server files. A file can also disappear or
become unreadable after validation; retain normal error handling around the
request.

## Upload Bytes Deliberately

Nadia does not currently expose an in-memory `InputFile` type. The example's
`upload_bytes/5` helper writes bytes to a uniquely named temporary file, uses
the tested path upload, and removes the file in an `after` block:

```elixir
MediaFiles.upload_bytes(client, chat_id, generated_pdf, "report.pdf")
```

This duplicates the supplied data to disk. Before using the pattern in an
application, cap input size, choose a private writable directory with enough
space, sanitize filenames, and decide how abandoned files are cleaned after a
VM or host crash. For large producers, an application-owned streaming upload
abstraction is preferable to first building a large in-memory binary.

## Resolve A Download URL

`getFile` returns metadata, not file bytes. The example combines
`Nadia.get_file/2` and `Nadia.get_file_link/2`:

```elixir
{:ok, url} = MediaFiles.download_url(client, file_id)
```

The returned URL embeds the bot token. Never log it, expose it to untrusted
clients, or store it as a public permanent URL. Fetch it with an
application-owned HTTP client, stream to a bounded destination, and preserve
the original message's filename and MIME type when needed because `getFile`
does not guarantee them.

On Telegram's hosted Bot API, downloads are limited to 20 MB and the URL is
guaranteed for at least one hour. Request `getFile` again after expiry.
`file_path` is optional; Nadia returns
`{:error, %Nadia.Model.Error{reason: :file_path_unavailable}}` when it is absent.

## Know The Current Boundary

The single-file wrappers support file IDs, URLs where Telegram allows them,
and one local multipart field. Nadia does not yet provide general
`attach://...` composition for local files in media groups, paid media, covers,
or thumbnails. Do not pass a local path inside a JSON media array and expect it
to upload.

A self-hosted local Bot API server has different limits and can return an
absolute local `file_path`. Nadia's standard token-bearing file URL helper is
designed for downloadable paths, not those server-local absolute paths. Handle
that deployment mode explicitly in application code.
