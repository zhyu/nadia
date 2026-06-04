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

    assert [
             {"chat_id", "123"},
             {"photo", {%File.Stream{path: ^file_path}, file_options}}
           ] = options[:form_multipart]

    assert file_options[:filename] == "photo.txt"

    assert {:ok, %HTTPResponse{status_code: 200, body: "ok"}} = ReqClient.post(request)

    assert_received {:req_request, req_request}

    headers = Req.get_headers_list(req_request)
    assert {"content-type", content_type} = List.keyfind(headers, "content-type", 0)
    assert String.starts_with?(content_type, "multipart/form-data; boundary=")
  end

  test "translates HTTPoison timeout and HTTP proxy options to Req options" do
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
end
