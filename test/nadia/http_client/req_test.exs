defmodule Nadia.HTTPClient.ReqTest do
  use ExUnit.Case, async: true

  alias Nadia.HTTPClient.Req, as: ReqClient
  alias Nadia.HTTPRequest
  alias Nadia.HTTPResponse

  test "posts form requests through Req and normalizes responses" do
    parent = self()

    adapter = fn request ->
      send(parent, {:req_request, request})

      response =
        Req.Response.new(
          status: 201,
          headers: [{"x-test", "ok"}],
          body: ~s({"ok":true,"result":true})
        )

      {request, response}
    end

    request = %HTTPRequest{
      method: :post,
      url: "https://api.example.test/sendMessage",
      body: {:form, [{"chat_id", "123"}, {"text", "hello"}]},
      headers: [{"accept", "application/json"}],
      options: [recv_timeout: 7000, adapter: adapter]
    }

    assert {:ok,
            %HTTPResponse{
              status_code: 201,
              body: ~s({"ok":true,"result":true}),
              headers: [{"x-test", "ok"}]
            }} = ReqClient.post(request)

    assert_received {:req_request, req_request}

    assert req_request.method == :post
    assert URI.to_string(req_request.url) == "https://api.example.test/sendMessage"
    assert req_request.options[:receive_timeout] == 7000
    assert req_request.options[:decode_body] == false
    assert req_request.options[:redirect] == false
    assert req_request.options[:retry] == false
    assert IO.iodata_to_binary(req_request.body) == "chat_id=123&text=hello"

    headers = Req.get_headers_list(req_request)

    assert {"accept", "application/json"} in headers
    assert {"content-type", "application/x-www-form-urlencoded"} in headers
  end

  test "posts multipart requests through Req" do
    parent = self()
    file_path = Path.join(System.tmp_dir!(), "nadia-req-test-#{System.unique_integer()}.txt")

    File.write!(file_path, "photo-bytes")

    on_exit(fn ->
      File.rm(file_path)
    end)

    adapter = fn request ->
      send(parent, {:req_request, request})
      {request, Req.Response.new(status: 200, body: "ok")}
    end

    request = %HTTPRequest{
      method: :post,
      url: "https://api.example.test/sendPhoto",
      body:
        {:multipart,
         [
           {"chat_id", "123"},
           {:file, file_path, {"form-data", [{"name", "photo"}, {"filename", "photo.txt"}]}, []}
         ]},
      headers: [],
      options: [adapter: adapter]
    }

    assert {:ok, options} = ReqClient.to_req_options(request)
    refute options[:form_multipart]
    assert is_list(options[:headers])
    assert multipart_body(options) =~ "name=\"chat_id\"\r\n\r\n123"
    assert multipart_body(options) =~ "name=\"photo\"; filename=\"photo.txt\""
    assert multipart_body(options) =~ "photo-bytes"

    assert {"content-length", content_length} =
             List.keyfind(options[:headers], "content-length", 0)

    assert String.to_integer(content_length) == byte_size(multipart_body(options))

    assert {:ok, %HTTPResponse{status_code: 200, body: "ok"}} = ReqClient.post(request)

    assert_received {:req_request, req_request}

    headers = Req.get_headers_list(req_request)
    assert {"content-type", content_type} = List.keyfind(headers, "content-type", 0)
    assert String.starts_with?(content_type, "multipart/form-data; boundary=")
  end

  test "encodes binary attachment names and bytes without creating atoms" do
    attachment_name = "nadia_attachment_#{System.unique_integer([:positive])}"
    refute existing_atom?(attachment_name)

    request = %HTTPRequest{
      method: :post,
      url: "https://api.example.test/sendMediaGroup",
      body:
        {:multipart,
         [
           {"media", ~s([{"type":"document","media":"attach://#{attachment_name}"}])},
           {:file, {:bytes, ["file", "-bytes"], 10},
            {"form-data", [{"name", attachment_name}, {"filename", "report.txt"}]},
            [{"content-type", "text/plain"}]}
         ]}
    }

    assert {:ok, options} = ReqClient.to_req_options(request)
    body = multipart_body(options)

    assert body =~ "name=\"#{attachment_name}\"; filename=\"report.txt\""
    assert body =~ "content-type: text/plain"
    assert body =~ "file-bytes"
    refute existing_atom?(attachment_name)
  end

  test "streams known-size multipart bodies once and runs producer cleanup" do
    parent = self()

    stream =
      Stream.resource(
        fn -> ["abc", "def"] end,
        fn
          [chunk | rest] -> {[chunk], rest}
          [] -> {:halt, []}
        end,
        fn _state -> send(parent, :stream_closed) end
      )

    request = %HTTPRequest{
      method: :post,
      url: "https://api.example.test/sendDocument",
      body:
        {:multipart,
         [
           {:file, {:stream, stream, 6},
            {"form-data", [{"name", "document"}, {"filename", "stream.txt"}]}, []}
         ]}
    }

    assert {:ok, options} = ReqClient.to_req_options(request)
    assert multipart_body(options) =~ "abcdef"
    assert_receive :stream_closed
  end

  test "rejects a stream that exceeds its declared size and still cleans up" do
    parent = self()

    stream =
      Stream.resource(
        fn -> :ready end,
        fn
          :ready -> {["three"], :done}
          :done -> {:halt, :done}
        end,
        fn _state -> send(parent, :mismatch_stream_closed) end
      )

    request = %HTTPRequest{
      method: :post,
      url: "https://api.example.test/sendDocument",
      body:
        {:multipart,
         [
           {:file, {:stream, stream, 3},
            {"form-data", [{"name", "document"}, {"filename", "stream.txt"}]}, []}
         ]}
    }

    assert {:ok, options} = ReqClient.to_req_options(request)

    assert_raise Nadia.InputFile.StreamError, ~r/exceeded its declared size/, fn ->
      multipart_body(options)
    end

    assert_receive :mismatch_stream_closed
  end

  test "normalizes stream size failures from the Req execution boundary" do
    stream = Stream.map(["too-long"], & &1)

    adapter = fn request ->
      request.body |> Enum.to_list() |> IO.iodata_to_binary()
      {request, Req.Response.new(status: 200, body: "ok")}
    end

    request = %HTTPRequest{
      method: :post,
      url: "https://api.example.test/sendDocument",
      body:
        {:multipart,
         [
           {:file, {:stream, stream, 3},
            {"form-data", [{"name", "document"}, {"filename", "stream.txt"}]}, []}
         ]},
      options: [adapter: adapter]
    }

    assert {:error, {:input_file, {:stream_error, message}}} = ReqClient.post(request)
    assert message =~ "exceeded its declared size"
  end

  test "translates Nadia timeout and HTTP proxy options to Req options" do
    request = %HTTPRequest{
      method: :post,
      url: "https://api.example.test/getMe",
      body: {:form, []},
      options: [
        recv_timeout: 5000,
        proxy: "http://proxy.example.test:8080",
        proxy_auth: {"proxy-user", "proxy-pass"}
      ]
    }

    assert {:ok, options} = ReqClient.to_req_options(request)

    assert options[:receive_timeout] == 5000
    assert options[:connect_options][:proxy] == {:http, "proxy.example.test", 8080, []}

    assert {"proxy-authorization", "Basic cHJveHktdXNlcjpwcm94eS1wYXNz"} in options[
             :connect_options
           ][:proxy_headers]
  end

  test "reports unsupported SOCKS proxy options" do
    request = %HTTPRequest{
      method: :post,
      url: "https://api.example.test/getMe",
      body: {:form, []},
      options: [proxy: {:socks5, ~c"localhost", 1080}]
    }

    assert {:error, {:unsupported_proxy, {:socks5, ~c"localhost", 1080}}} =
             ReqClient.to_req_options(request)

    request = %{request | options: [socks5_user: "user"]}

    assert {:error, {:unsupported_option, :socks5_user}} = ReqClient.to_req_options(request)
  end

  test "normalizes Req transport errors" do
    adapter = fn request ->
      {request, %Req.TransportError{reason: :timeout}}
    end

    request = %HTTPRequest{
      method: :post,
      url: "https://api.example.test/getMe",
      body: {:form, []},
      options: [adapter: adapter]
    }

    assert {:error, :timeout} = ReqClient.post(request)
  end

  defp multipart_body(options) do
    options[:body]
    |> Enum.to_list()
    |> IO.iodata_to_binary()
  end

  defp existing_atom?(name) do
    _ = String.to_existing_atom(name)
    true
  rescue
    ArgumentError -> false
  end
end
