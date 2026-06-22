defmodule Nadia.InputFileTest do
  use Nadia.HTTPCase

  alias Nadia.InputFile
  alias Nadia.Model.Error

  test "explicit file IDs and URLs remain ordinary form values" do
    stub_telegram_result(true)

    assert :ok = Nadia.send_document(123, InputFile.file_id("document-file-id"))

    assert_telegram_request("sendDocument",
      body: {:form, [{"chat_id", "123"}, {"document", "document-file-id"}]}
    )

    assert :ok =
             Nadia.send_document(
               123,
               InputFile.url("https://cdn.example.test/manual.pdf")
             )

    assert_telegram_request("sendDocument",
      body:
        {:form,
         [
           {"chat_id", "123"},
           {"document", "https://cdn.example.test/manual.pdf"}
         ]}
    )
  end

  test "explicit paths are validated before requests and use safe filenames" do
    stub_telegram_result(true)
    path = temporary_file("input-file.txt", "from-disk")

    assert :ok = Nadia.send_document(123, InputFile.path(path))

    request = assert_telegram_request("sendDocument")

    assert {:multipart,
            [
              {"chat_id", "123"},
              {:file, ^path,
               {"form-data", [{"name", "document"}, {"filename", "input-file.txt"}]}, []}
            ]} = request.body

    missing = path <> ".missing"

    assert {:error, %Error{reason: {:input_file, {:file_error, ^missing, :enoent}}}} =
             Nadia.send_document(123, InputFile.path(missing))

    refute_receive {:nadia_http_request, _request}

    directory = System.tmp_dir!()

    assert {:error, %Error{reason: {:input_file, {:not_regular, ^directory}}}} =
             Nadia.send_document(123, InputFile.path(directory))

    refute_receive {:nadia_http_request, _request}
  end

  test "bytes preserve iodata, filename, content type, and application bounds" do
    stub_telegram_result(true)
    bytes = ["report", [?-], "bytes"]

    assert :ok =
             Nadia.send_document(
               123,
               InputFile.bytes(bytes, "../report.txt",
                 content_type: "text/plain",
                 max_bytes: 12
               )
             )

    request = assert_telegram_request("sendDocument")

    assert {:multipart, parts} = request.body

    assert {:file, {:bytes, ^bytes, 12},
            {"form-data", [{"name", "document"}, {"filename", "report.txt"}]},
            [{"content-type", "text/plain"}]} = List.keyfind(parts, :file, 0)

    assert {:error, %Error{reason: {:input_file, {:too_large, 12, 11}}}} =
             Nadia.send_document(123, InputFile.bytes(bytes, "report.txt", max_bytes: 11))

    refute_receive {:nadia_http_request, _request}
  end

  test "known-size streams stay streaming on the HTTP request boundary" do
    stub_telegram_result(true)
    stream = Stream.map(["abc", "def"], & &1)

    assert :ok =
             Nadia.send_document(
               123,
               InputFile.stream(stream, "stream.txt", size: 6, max_bytes: 6)
             )

    request = assert_telegram_request("sendDocument")
    assert {:multipart, parts} = request.body

    assert {:file, {:stream, ^stream, 6},
            {"form-data", [{"name", "document"}, {"filename", "stream.txt"}]}, []} =
             List.keyfind(parts, :file, 0)
  end

  test "multiple nested media uploads get collision-safe binary attachment names" do
    stub_telegram_result([])
    video_path = temporary_file("video.mp4", "video")
    atom_probe = "nadia_input_attachment_#{System.unique_integer([:positive])}"
    refute existing_atom?(atom_probe)

    media = [
      %{
        type: "video",
        media: InputFile.path(video_path, attach_name: "chat_id"),
        thumbnail: InputFile.bytes("thumb", "thumb.jpg", attach_name: atom_probe),
        cover: InputFile.bytes("cover", "cover.jpg", attach_name: atom_probe)
      }
    ]

    assert {:ok, []} = Nadia.send_media_group(123, media)
    request = assert_telegram_request("sendMediaGroup")
    assert {:multipart, [{"chat_id", "123"}, {"media", encoded} | parts]} = request.body

    assert [item] = Jason.decode!(encoded)

    names_by_filename =
      Map.new(parts, fn
        {:file, _source, {"form-data", disposition}, _headers} ->
          {List.keyfind(disposition, "filename", 0) |> elem(1),
           List.keyfind(disposition, "name", 0) |> elem(1)}
      end)

    assert item["media"] == "attach://#{names_by_filename["video.mp4"]}"
    assert item["thumbnail"] == "attach://#{names_by_filename["thumb.jpg"]}"
    assert item["cover"] == "attach://#{names_by_filename["cover.jpg"]}"
    assert names_by_filename["video.mp4"] == "chat_id_1"

    assert MapSet.new([names_by_filename["thumb.jpg"], names_by_filename["cover.jpg"]]) ==
             MapSet.new([atom_probe, atom_probe <> "_1"])

    refute existing_atom?(atom_probe)
  end

  test "secondary top-level files work even when a wrapper has no legacy file field" do
    stub_telegram_result(true)
    certificate = temporary_file("certificate.pem", "certificate")

    assert :ok =
             Nadia.set_webhook(
               url: "https://bot.example.test/webhook",
               certificate: InputFile.path(certificate)
             )

    request = assert_telegram_request("setWebhook")
    assert {:multipart, parts} = request.body
    assert {"url", "https://bot.example.test/webhook"} in parts

    assert {:file, ^certificate,
            {"form-data", [{"name", "certificate"}, {"filename", "certificate.pem"}]}, []} =
             List.keyfind(parts, :file, 0)
  end

  test "malformed explicit inputs fail without touching the HTTP adapter" do
    stub_telegram_result(true)

    assert {:error, %Error{reason: {:input_file, :invalid_source}}} =
             Nadia.send_document(123, InputFile.file_id(""))

    assert {:error, %Error{reason: {:input_file, {:invalid_url, "file:///tmp/a"}}}} =
             Nadia.send_document(123, InputFile.url("file:///tmp/a"))

    assert {:error, %Error{reason: {:input_file, :invalid_iodata}}} =
             Nadia.send_document(123, InputFile.bytes({:not, :iodata}, "bad.bin"))

    assert {:error, %Error{reason: {:input_file, :stream_size_required}}} =
             Nadia.send_document(123, InputFile.stream(Stream.cycle(["x"]), "bad.bin", []))

    assert {:error, %Error{reason: {:input_file, :invalid_filename}}} =
             Nadia.send_document(123, InputFile.bytes("bytes", ""))

    assert_raise ArgumentError, ~r/unsupported Nadia.InputFile option/, fn ->
      InputFile.path("/tmp/file", future_option: true)
    end

    refute_receive {:nadia_http_request, _request}
  end

  defp temporary_file(filename, contents) do
    directory =
      Path.join(
        System.tmp_dir!(),
        "nadia-input-file-#{System.unique_integer([:positive, :monotonic])}"
      )

    File.mkdir_p!(directory)
    path = Path.join(directory, filename)
    File.write!(path, contents)

    on_exit(fn -> File.rm_rf(directory) end)
    path
  end

  defp existing_atom?(name) do
    _ = String.to_existing_atom(name)
    true
  rescue
    ArgumentError -> false
  end
end
