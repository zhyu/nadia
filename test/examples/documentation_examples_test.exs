Code.require_file("../../examples/inline_keyboard_bot.ex", __DIR__)
Code.require_file("../../examples/conversation_bot.ex", __DIR__)
Code.require_file("../../examples/disk_session_store.ex", __DIR__)
Code.require_file("../../examples/media_files.ex", __DIR__)
Code.require_file("../../examples/retry_errors.ex", __DIR__)

defmodule Nadia.DocumentationExamplesTest do
  use ExUnit.Case, async: false

  alias Nadia.Client
  alias Nadia.Context
  alias Nadia.HTTPRequest
  alias Nadia.HTTPResponse
  alias Nadia.Model.{CallbackQuery, Chat, Error, Message, ResponseParameters, Update, User}
  alias Nadia.SessionStore

  defmodule FakeHTTPClient do
    @behaviour Nadia.HTTPClient

    @impl Nadia.HTTPClient
    def post(%HTTPRequest{} = request) do
      send(self(), {:nadia_request, request})

      case request.body do
        {:multipart, parts} ->
          {:file, path, _disposition, _headers} = List.keyfind(parts, :file, 0)
          send(self(), {:uploaded_file, path, File.read!(path)})

        _ ->
          :ok
      end

      result =
        cond do
          String.ends_with?(request.url, "/answerCallbackQuery") ->
            true

          String.ends_with?(request.url, "/getFile") ->
            %{
              file_id: "file-1",
              file_unique_id: "unique-1",
              file_size: 12,
              file_path: "documents/file_1.txt"
            }

          true ->
            %{
              message_id: 2,
              date: 1_700_000_001,
              chat: %{id: 123, type: "private"},
              text: "ok"
            }
        end

      {:ok,
       %HTTPResponse{
         status_code: 200,
         body: Jason.encode!(%{ok: true, result: result})
       }}
    end
  end

  setup do
    client = Client.new(token: "123:test-token", http_client: FakeHTTPClient)
    %{client: client}
  end

  test "inline keyboard example routes commands and callback queries", %{client: client} do
    update = message_update("/start")
    context = Context.new(update, client)

    assert {:ok, %Message{}} =
             Nadia.Examples.InlineKeyboardBot.handle_update(update, context)

    assert_receive {:nadia_request, %HTTPRequest{body: {:form, params}}}
    assert {"text", "Choose a color:"} in params

    assert {"reply_markup", encoded_keyboard} = List.keyfind(params, "reply_markup", 0)

    assert %{
             "inline_keyboard" => [
               [
                 %{"callback_data" => "color:blue"},
                 %{"callback_data" => "color:green"}
               ]
             ]
           } = Jason.decode!(encoded_keyboard)

    update = callback_update("color:blue")
    context = Context.new(update, client)

    assert :ok = Nadia.Examples.InlineKeyboardBot.handle_update(update, context)

    assert_receive {:nadia_request, %HTTPRequest{url: answer_url}}
    assert String.ends_with?(answer_url, "/answerCallbackQuery")

    assert_receive {:nadia_request, %HTTPRequest{body: {:form, params}}}
    assert {"text", "You chose blue."} in params
  end

  test "conversation example advances and clears explicit session state", %{client: client} do
    start_supervised!({Nadia.SessionStore.ETS, name: Nadia.Examples.ConversationBot.Sessions})

    start = message_update("/start")
    start_context = Context.new(start, client)

    assert :ok = Nadia.Examples.ConversationBot.handle_update(start, start_context)
    assert_receive {:nadia_request, _request}

    assert {:ok, key} = SessionStore.chat_user_key(start_context)
    assert {:ok, %{step: :name}} = SessionStore.get(Nadia.Examples.ConversationBot.store(), key)

    name = message_update("Ada", 2)
    assert :ok = Nadia.Examples.ConversationBot.handle_update(name, Context.new(name, client))
    assert_receive {:nadia_request, _request}

    assert {:ok, %{step: :email, name: "Ada"}} =
             SessionStore.get(Nadia.Examples.ConversationBot.store(), key)

    email = message_update("ada@example.com", 3)
    assert :ok = Nadia.Examples.ConversationBot.handle_update(email, Context.new(email, client))
    assert_receive {:nadia_request, _request}

    assert {:ok, %{}} = SessionStore.get(Nadia.Examples.ConversationBot.store(), key)
  end

  test "media example distinguishes file IDs, URLs, paths, and byte uploads", %{client: client} do
    assert {:ok, %Message{}} =
             Nadia.Examples.MediaFiles.send_document(
               client,
               123,
               {:file_id, "document-file-id"},
               caption: "reuse"
             )

    assert_receive {:nadia_request, %HTTPRequest{body: {:form, file_id_params}}}
    assert {"document", "document-file-id"} in file_id_params

    assert {:ok, %Message{}} =
             Nadia.Examples.MediaFiles.send_document(
               client,
               123,
               {:url, "https://cdn.example.test/manual.pdf"}
             )

    assert_receive {:nadia_request, %HTTPRequest{body: {:form, url_params}}}
    assert {"document", "https://cdn.example.test/manual.pdf"} in url_params

    path = Path.join(System.tmp_dir!(), "nadia-example-#{System.unique_integer([:positive])}.txt")
    File.write!(path, "from disk")
    on_exit(fn -> File.rm(path) end)

    assert {:ok, %Message{}} =
             Nadia.Examples.MediaFiles.send_document(client, 123, {:path, path})

    assert_receive {:nadia_request, %HTTPRequest{body: {:multipart, parts}}}
    assert {:file, ^path, _disposition, []} = List.keyfind(parts, :file, 0)
    assert_receive {:uploaded_file, ^path, "from disk"}

    assert {:ok, %Message{}} =
             Nadia.Examples.MediaFiles.upload_bytes(
               client,
               123,
               "from memory",
               "../unsafe-name.txt"
             )

    assert_receive {:nadia_request, %HTTPRequest{body: {:multipart, _parts}}}
    assert_receive {:uploaded_file, temporary_path, "from memory"}
    refute File.exists?(temporary_path)

    missing = path <> ".missing"

    assert {:error, {:file_error, :enoent}} =
             Nadia.Examples.MediaFiles.send_document(client, 123, {:path, missing})

    refute_receive {:nadia_request, _request}

    assert {:error, {:file_error, :not_regular}} =
             Nadia.Examples.MediaFiles.send_document(client, 123, {:path, System.tmp_dir!()})

    assert {:error, {:invalid_file_url, "file:///tmp/manual.pdf"}} =
             Nadia.Examples.MediaFiles.send_document(
               client,
               123,
               {:url, "file:///tmp/manual.pdf"}
             )
  end

  test "media example resolves getFile metadata to an explicit-client URL" do
    client =
      Client.new(
        token: "999:file-token",
        file_base_url: "https://files.example/bot",
        http_client: FakeHTTPClient
      )

    assert {:ok,
            %Nadia.Model.File{
              file_id: "file-1",
              file_unique_id: "unique-1",
              file_path: "documents/file_1.txt"
            }} = Nadia.get_file(client, "file-1")

    assert_receive {:nadia_request, %HTTPRequest{body: {:form, metadata_params}}}
    assert {"file_id", "file-1"} in metadata_params

    assert {:ok, "https://files.example/bot999:file-token/documents/file_1.txt"} =
             Nadia.Examples.MediaFiles.download_url(client, "file-1")

    assert_receive {:nadia_request, %HTTPRequest{body: {:form, params}}}
    assert {"file_id", "file-1"} in params
  end

  test "disk session example persists and serializes updates" do
    path =
      Path.join(
        System.tmp_dir!(),
        "nadia-disk-sessions-#{System.unique_integer([:positive])}.dets"
      )

    table = Nadia.DocumentationExamplesTest.DiskSessions
    on_exit(fn -> File.rm(path) end)

    {:ok, first} = Nadia.Examples.DiskSessionStore.start_link(path: path, table: table)
    store = {Nadia.Examples.DiskSessionStore, first}
    key = {:chat, 123}

    assert :ok = SessionStore.put(store, key, %{count: 0})
    GenServer.stop(first)

    {:ok, second} = Nadia.Examples.DiskSessionStore.start_link(path: path, table: table)
    store = {Nadia.Examples.DiskSessionStore, second}
    assert {:ok, %{count: 0}} = SessionStore.get(store, key)

    1..20
    |> Task.async_stream(
      fn _ ->
        SessionStore.update(store, key, fn session ->
          Map.update!(session, :count, &(&1 + 1))
        end)
      end,
      max_concurrency: 8,
      ordered: false
    )
    |> Enum.each(fn {:ok, {:ok, %{count: count}}} -> assert count in 1..20 end)

    assert {:ok, %{count: 20}} = SessionStore.get(store, key)

    assert {:error, :keep_current} =
             SessionStore.update(store, key, fn _session -> {:error, :keep_current} end)

    assert {:ok, %{count: 20}} = SessionStore.get(store, key)
    GenServer.stop(second)

    {:ok, third} = Nadia.Examples.DiskSessionStore.start_link(path: path, table: table)

    assert {:ok, %{count: 20}} =
             SessionStore.get({Nadia.Examples.DiskSessionStore, third}, key)

    assert :ok = SessionStore.delete({Nadia.Examples.DiskSessionStore, third}, key)
    GenServer.stop(third)

    {:ok, fourth} = Nadia.Examples.DiskSessionStore.start_link(path: path, table: table)
    assert {:ok, %{}} = SessionStore.get({Nadia.Examples.DiskSessionStore, fourth}, key)
    GenServer.stop(fourth)
  end

  test "retry example obeys server delay and attempt bounds" do
    rate_limit =
      {:error,
       %Error{
         reason: "Too Many Requests",
         error_code: 429,
         parameters: %ResponseParameters{retry_after: 2}
       }}

    {:ok, responses} = Agent.start_link(fn -> [rate_limit, {:ok, :sent}] end)

    operation = fn ->
      Agent.get_and_update(responses, fn [response | rest] -> {response, rest} end)
    end

    assert {:ok, :sent} =
             Nadia.Examples.RetryErrors.retry(operation,
               max_attempts: 2,
               max_delay_seconds: 5,
               sleep: fn milliseconds -> send(self(), {:slept, milliseconds}) end
             )

    assert_receive {:slept, 2_000}

    too_long = put_in(elem(rate_limit, 1).parameters.retry_after, 60)

    assert ^too_long =
             Nadia.Examples.RetryErrors.retry(fn -> too_long end,
               max_attempts: 3,
               max_delay_seconds: 5,
               sleep: fn _milliseconds -> flunk("must not sleep") end
             )

    permanent = {:error, %Error{reason: "Bad Request", error_code: 400}}

    assert ^permanent =
             Nadia.Examples.RetryErrors.retry(fn -> permanent end,
               sleep: fn _milliseconds -> flunk("must not sleep") end
             )

    {:ok, calls} = Agent.start_link(fn -> 0 end)

    assert ^rate_limit =
             Nadia.Examples.RetryErrors.retry(
               fn ->
                 Agent.update(calls, &(&1 + 1))
                 rate_limit
               end,
               max_attempts: 2,
               sleep: fn _milliseconds -> :ok end
             )

    assert Agent.get(calls, & &1) == 2
  end

  test "retry example exposes migration without retrying blindly" do
    error = %Error{
      reason: "migrated",
      error_code: 400,
      parameters: %ResponseParameters{migrate_to_chat_id: -1_001_234_567_890}
    }

    assert {:ok, -1_001_234_567_890} = Nadia.Examples.RetryErrors.migration_target(error)
    assert :error = Nadia.Examples.RetryErrors.migration_target(%Error{reason: "permanent"})
  end

  defp message_update(text, update_id \\ 1) do
    %Update{
      update_id: update_id,
      message: message(text)
    }
  end

  defp callback_update(data) do
    %Update{
      update_id: 10,
      callback_query: %CallbackQuery{
        id: "callback-1",
        data: data,
        from: user(),
        message: message(nil)
      }
    }
  end

  defp message(text) do
    %Message{
      message_id: 1,
      date: 1_700_000_000,
      text: text,
      from: user(),
      chat: %Chat{id: 123, type: "private"}
    }
  end

  defp user, do: %User{id: 456, first_name: "User"}
end
