defmodule Nadia.FileDownloadTest do
  use ExUnit.Case, async: false

  alias Nadia.Client
  alias Nadia.HTTPDownloadRequest
  alias Nadia.HTTPDownloadResponse
  alias Nadia.HTTPRequest
  alias Nadia.HTTPResponse
  alias Nadia.Model.Error
  alias Nadia.Model.File, as: TelegramFile

  defmodule ChunkAdapter do
    @behaviour Nadia.HTTPClient

    @impl Nadia.HTTPClient
    def post(%HTTPRequest{} = request) do
      send(self(), {:download_post, request})

      file = Process.get(:download_file_metadata)

      {:ok,
       %HTTPResponse{
         status_code: 200,
         body: Jason.encode!(%{ok: true, result: file})
       }}
    end

    @impl Nadia.HTTPClient
    def download(%HTTPDownloadRequest{} = request) do
      send(self(), {:download_request, request, inspect(request)})

      case Process.get(:download_response) do
        {:chunks, chunks, headers} ->
          stream(request, chunks, headers)

        {:status, status, headers} ->
          {:ok, %HTTPDownloadResponse{status_code: status, bytes_written: 0, headers: headers}}

        {:fail_after, chunks, reason} ->
          with {:ok, _bytes} <- feed(request, chunks) do
            {:error, reason}
          end

        {:raise, message} ->
          raise message <> request.url

        {:race, [first | rest], destination} ->
          with :ok <- request.sink.(first) do
            File.write!(destination, "racer")

            with {:ok, response} <- stream(request, rest, []) do
              {:ok, %{response | bytes_written: response.bytes_written + IO.iodata_length(first)}}
            end
          end
      end
    end

    defp stream(request, chunks, headers) do
      with {:ok, bytes} <- feed(request, chunks) do
        {:ok, %HTTPDownloadResponse{status_code: 200, bytes_written: bytes, headers: headers}}
      end
    end

    defp feed(request, chunks) do
      Enum.reduce_while(chunks, {:ok, 0}, fn chunk, {:ok, count} ->
        case request.sink.(chunk) do
          :ok -> {:cont, {:ok, count + IO.iodata_length(chunk)}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end
  end

  defmodule PostOnlyAdapter do
    @behaviour Nadia.HTTPClient

    @impl Nadia.HTTPClient
    def post(%HTTPRequest{}), do: {:error, :not_used}
  end

  setup do
    directory =
      Path.join(System.tmp_dir!(), "nadia-download-#{System.unique_integer([:positive])}")

    File.mkdir_p!(directory)
    on_exit(fn -> File.rm_rf(directory) end)

    client =
      Client.new(
        token: "999:secret-download-token",
        http_client: ChunkAdapter,
        recv_timeout: 2
      )

    %{client: client, directory: directory}
  end

  test "downloads exact-limit and missing-size responses without buffering", context do
    destination = Path.join(context.directory, "exact.bin")
    Process.put(:download_response, {:chunks, ["abc", ["de", "f"]], [{"content-length", "6"}]})

    file = %TelegramFile{file_id: "file-1", file_path: "documents/file.bin", file_size: 6}

    assert {:ok, ^destination} = Nadia.download_file(context.client, file, destination, 6)
    assert File.read!(destination) == "abcdef"
    assert_receive {:download_request, request, inspected}
    assert request.max_bytes == 6
    assert request.expected_bytes == 6
    refute inspected =~ "secret-download-token"
    assert inspected =~ "[REDACTED]"

    destination = Path.join(context.directory, "unknown.bin")
    Process.put(:download_response, {:chunks, ["unknown"], []})
    file = %TelegramFile{file_id: "file-2", file_path: "documents/unknown.bin"}

    assert {:ok, ^destination} = Nadia.download_file(context.client, file, destination, 7)
    assert File.read!(destination) == "unknown"

    destination = Path.join(context.directory, "empty.bin")
    Process.put(:download_response, {:chunks, [], [{"content-length", "0"}]})
    file = %TelegramFile{file_id: "file-3", file_path: "documents/empty.bin", file_size: 0}

    assert {:ok, ^destination} = Nadia.download_file(context.client, file, destination, 0)
    assert File.read!(destination) == ""
  end

  test "file-size preflight and oversized chunks leave no destination or temp", context do
    destination = Path.join(context.directory, "too-large.bin")
    file = %TelegramFile{file_id: "file-1", file_path: "documents/file.bin", file_size: 7}

    assert {:error, %Error{reason: {:download, {:file_too_large, 7, 6}}}} =
             Nadia.download_file(context.client, file, destination, 6)

    refute_receive {:download_request, _request, _inspect}
    refute File.exists?(destination)
    assert temp_files(context.directory) == []

    Process.put(:download_response, {:chunks, ["1234567"], []})
    file = %TelegramFile{file_id: "file-2", file_path: "documents/chunked.bin"}

    assert {:error, %Error{reason: {:download, {:too_large, 7, 6}}}} =
             Nadia.download_file(context.client, file, destination, 6)

    refute File.exists?(destination)
    assert temp_files(context.directory) == []
  end

  test "short reads and transport failures remove partial files", context do
    destination = Path.join(context.directory, "short.bin")
    Process.put(:download_response, {:chunks, ["abc"], []})
    file = %TelegramFile{file_id: "file-1", file_path: "documents/file.bin", file_size: 5}

    assert {:error, %Error{reason: {:download, {:size_mismatch, 5, 3}}}} =
             Nadia.download_file(context.client, file, destination, 5)

    refute File.exists?(destination)
    assert temp_files(context.directory) == []

    Process.put(:download_response, {:fail_after, ["abc"], :timeout})
    file = %{file | file_size: nil}

    assert {:error, %Error{reason: {:download, :timeout}}} =
             Nadia.download_file(context.client, file, destination, 5)

    refute File.exists?(destination)
    assert temp_files(context.directory) == []

    Process.put(
      :download_response,
      {:raise, "adapter failed at "}
    )

    assert {:error, %Error{reason: {:download, :transport_error}} = error} =
             Nadia.download_file(context.client, file, destination, 5)

    refute inspect(error) =~ "secret-download-token"
    refute File.exists?(destination)
    assert temp_files(context.directory) == []
  end

  test "redirect and status failures are token-free and never publish", context do
    destination = Path.join(context.directory, "redirect.bin")
    evil = "https://evil.example/steal/999:secret-download-token"
    Process.put(:download_response, {:status, 302, [{"location", evil}]})
    file = %TelegramFile{file_id: "file-1", file_path: "documents/file.bin"}

    assert {:error, %Error{reason: {:download, :redirect_not_allowed}} = error} =
             Nadia.download_file(context.client, file, destination, 10)

    refute inspect(error) =~ "secret-download-token"
    refute inspect(error) =~ evil
    refute File.exists?(destination)
    assert temp_files(context.directory) == []

    Process.put(:download_response, {:status, 404, []})

    assert {:error, %Error{reason: {:download, {:http_status, 404}}}} =
             Nadia.download_file(context.client, file, destination, 10)
  end

  test "malformed and repeated content lengths fail closed", context do
    destination = Path.join(context.directory, "length.bin")
    file = %TelegramFile{file_id: "file-1", file_path: "documents/file.bin"}

    Process.put(:download_response, {:chunks, ["abc"], [{"content-length", "bad"}]})

    assert {:error, %Error{reason: {:download, :invalid_content_length}}} =
             Nadia.download_file(context.client, file, destination, 10)

    refute File.exists?(destination)
    assert temp_files(context.directory) == []

    Process.put(
      :download_response,
      {:chunks, ["abc"], [{"content-length", "3"}, {"content-length", "3"}]}
    )

    assert {:error, %Error{reason: {:download, :invalid_content_length}}} =
             Nadia.download_file(context.client, file, destination, 10)

    refute File.exists?(destination)
    assert temp_files(context.directory) == []
  end

  test "existing destinations and publication races never overwrite", context do
    destination = Path.join(context.directory, "existing.bin")
    File.write!(destination, "original")
    Process.put(:download_response, {:chunks, ["replacement"], []})
    file = %TelegramFile{file_id: "file-1", file_path: "documents/file.bin"}

    assert {:error, %Error{reason: {:download, :destination_exists}}} =
             Nadia.download_file(context.client, file, destination, 20)

    assert File.read!(destination) == "original"
    refute_receive {:download_request, _request, _inspect}

    File.rm!(destination)
    Process.put(:download_response, {:race, ["abc", "def"], destination})

    assert {:error, %Error{reason: {:download, :destination_exists}}} =
             Nadia.download_file(context.client, file, destination, 20)

    assert File.read!(destination) == "racer"
    assert temp_files(context.directory) == []
  end

  test "overwrite is explicit and atomically replaces a completed destination", context do
    destination = Path.join(context.directory, "replace.bin")
    File.write!(destination, "old")
    Process.put(:download_response, {:chunks, ["new"], [{"content-length", "3"}]})
    file = %TelegramFile{file_id: "file-1", file_path: "documents/file.bin", file_size: 3}

    assert {:ok, ^destination} =
             Nadia.download_file(context.client, file, destination, 3, overwrite: true)

    assert File.read!(destination) == "new"
  end

  test "file ids perform one metadata preflight before streaming", context do
    destination = Path.join(context.directory, "from-id.bin")

    Process.put(:download_file_metadata, %{
      file_id: "file-1",
      file_unique_id: "unique-1",
      file_size: 4,
      file_path: "documents/file.bin"
    })

    Process.put(:download_response, {:chunks, ["file"], [{"content-length", "4"}]})

    assert {:ok, ^destination} = Nadia.download_file(context.client, "file-1", destination, 4)
    assert_receive {:download_post, %HTTPRequest{body: {:form, [{"file_id", "file-1"}]}}}
    assert File.read!(destination) == "file"
  end

  test "missing paths, invalid bounds, and post-only adapters fail deterministically", context do
    destination = Path.join(context.directory, "missing.bin")

    assert {:error, %Error{reason: {:download, :file_path_unavailable}}} =
             Nadia.download_file(
               context.client,
               %TelegramFile{file_id: "file-1"},
               destination,
               10
             )

    assert {:error, %Error{reason: {:download, :invalid_max_bytes}}} =
             Nadia.download_file(context.client, %TelegramFile{}, destination, -1)

    assert {:error, %Error{reason: {:download, :invalid_options}}} =
             Nadia.download_file(context.client, %TelegramFile{}, destination, 10, %{})

    client = %{context.client | http_client: PostOnlyAdapter}
    file = %TelegramFile{file_id: "file-1", file_path: "documents/file.bin"}

    assert {:error, %Error{reason: {:download, :unsupported_http_adapter}}} =
             Nadia.download_file(client, file, destination, 10)

    refute File.exists?(destination)
    assert temp_files(context.directory) == []
  end

  test "remote mode rejects absolute paths and local mode bounded-copies trusted paths",
       context do
    source = Path.join(context.directory, "source.bin")
    destination = Path.join(context.directory, "local-copy.bin")
    File.write!(source, "local")
    file = %TelegramFile{file_id: "file-1", file_path: source, file_size: 5}

    assert {:error, %Error{reason: {:download, :absolute_file_path_not_allowed}}} =
             Nadia.download_file(context.client, file, destination, 5)

    local_client = %{context.client | file_mode: :local, http_client: PostOnlyAdapter}

    assert {:ok, ^destination} = Nadia.download_file(local_client, file, destination, 5)
    assert File.read!(destination) == "local"
    refute_receive {:download_request, _request, _inspect}

    relative = %{file | file_path: "remote/path.bin"}

    assert {:error, %Error{reason: {:download, :local_file_path_expected}}} =
             Nadia.download_file(local_client, relative, destination <> ".2", 5)

    oversized = %{file | file_size: nil}

    assert {:error, %Error{reason: {:download, {:file_too_large, 5, 4}}}} =
             Nadia.download_file(local_client, oversized, destination <> ".3", 4)
  end

  test "request inspection redacts Bot API tokens" do
    request = %HTTPRequest{
      method: :get,
      url: "https://api.telegram.org/file/bot999:super-secret/documents/file.bin"
    }

    refute inspect(request) =~ "super-secret"
    assert inspect(request) =~ "/bot[REDACTED]/documents/file.bin"
  end

  defp temp_files(directory), do: Path.wildcard(Path.join(directory, ".*.nadia-download-*"))
end
