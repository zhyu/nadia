defmodule Mix.Tasks.Nadia.Gen.Bot do
  @shortdoc "Generates a Nadia bot handler"

  @moduledoc """
  Generates a small Nadia bot handler and offline test.

      mix nadia.gen.bot MyApp.Bot --polling

  Polling is the default generated runtime. `--polling` is accepted for
  clarity. Webhook handlers use the same generated bot module, but endpoint
  generation is intentionally deferred until a framework-specific adapter
  exists.

  The task creates:

  * `lib/my_app/bot.ex`
  * `test/my_app/bot_test.exs`

  It also prints the config and supervision snippets needed to run the bot with
  `Nadia.Polling`. Application supervision files are not modified
  automatically.
  """

  use Mix.Task

  @switches [
    force: :boolean,
    polling: :boolean,
    webhook: :boolean
  ]

  @impl Mix.Task
  def run(args) do
    {opts, argv, invalid} = OptionParser.parse(args, strict: @switches)

    if invalid != [] do
      Mix.raise("invalid option(s): #{Enum.map_join(invalid, ", ", &elem(&1, 0))}")
    end

    if Keyword.get(opts, :webhook, false) do
      Mix.raise(
        "webhook endpoint generation is not included; use Nadia.Webhook in your web framework"
      )
    end

    case argv do
      [module_name] ->
        module = parse_module!(module_name)
        force? = Keyword.get(opts, :force, false)

        create_file(handler_path(module), handler_template(module), force?)
        create_file(test_path(module), test_template(module), force?)
        print_next_steps(module)

      _ ->
        Mix.raise("expected a bot module, for example: mix nadia.gen.bot MyApp.Bot --polling")
    end
  end

  defp parse_module!(module_name) do
    if Regex.match?(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/, module_name) do
      Module.concat([module_name])
    else
      Mix.raise("expected a valid Elixir module name, got: #{inspect(module_name)}")
    end
  end

  defp handler_path(module) do
    module
    |> module_segments()
    |> Path.join()
    |> then(&Path.join("lib", &1 <> ".ex"))
  end

  defp test_path(module) do
    module
    |> module_segments()
    |> Path.join()
    |> then(&Path.join("test", &1 <> "_test.exs"))
  end

  defp module_segments(module) do
    module
    |> Module.split()
    |> Enum.map(&Macro.underscore/1)
  end

  defp create_file(path, contents, true) do
    Mix.Generator.create_file(path, contents, force: true)
  end

  defp create_file(path, contents, false) do
    if File.exists?(path) do
      Mix.shell().info("* skipping #{path}")
    else
      Mix.Generator.create_file(path, contents)
    end
  end

  defp handler_template(module) do
    module = inspect(module)

    """
    defmodule #{module} do
      @behaviour Nadia.Handler

      @impl Nadia.Handler
      def handle_update(_update, context) do
        case Nadia.Dispatcher.match_command(context, "start") do
          {:ok, _match} ->
            Nadia.Context.reply(context, "Ready")

          :nomatch ->
            echo_text(context)
        end
      end

      defp echo_text(%Nadia.Context{message: %{text: text}} = context) when is_binary(text) do
        Nadia.Context.reply(context, text)
      end

      defp echo_text(_context), do: :ignore
    end
    """
  end

  defp test_template(module) do
    module = inspect(module)
    test_module = module <> "Test"

    """
    defmodule #{test_module} do
      use ExUnit.Case, async: true

      alias Nadia.Client
      alias Nadia.Context
      alias Nadia.HTTPRequest
      alias Nadia.HTTPResponse
      alias Nadia.Model.{Chat, Message, Update, User}

      defmodule FakeHTTPClient do
        @behaviour Nadia.HTTPClient

        @impl Nadia.HTTPClient
        def post(%HTTPRequest{} = request) do
          send(self(), {:nadia_request, request})

          {:ok,
           %HTTPResponse{
             status_code: 200,
             body: ~s({"ok":true,"result":{"message_id":2,"date":1700000001,"chat":{"id":123,"type":"private"},"text":"Ready"}})
           }}
        end
      end

      test "replies to the start command" do
        update = message_update("/start")
        client = Client.new(token: "123:test-token", http_client: FakeHTTPClient)
        context = Context.new(update, client)

        assert {:ok, %Message{text: "Ready"}} = #{module}.handle_update(update, context)

        assert_received {:nadia_request, %HTTPRequest{body: {:form, params}}}
        assert {"chat_id", "123"} in params
        assert {"text", "Ready"} in params
      end

      test "echoes plain text messages" do
        update = message_update("hello")
        client = Client.new(token: "123:test-token", http_client: FakeHTTPClient)
        context = Context.new(update, client)

        assert {:ok, %Message{}} = #{module}.handle_update(update, context)

        assert_received {:nadia_request, %HTTPRequest{body: {:form, params}}}
        assert {"chat_id", "123"} in params
        assert {"text", "hello"} in params
      end

      test "ignores updates without message text" do
        update = %Update{update_id: 2}

        assert :ignore = #{module}.handle_update(update, Context.new(update))
      end

      defp message_update(text) do
        %Update{
          update_id: 1,
          message: %Message{
            message_id: 1,
            date: 1_700_000_000,
            text: text,
            from: %User{id: 456, first_name: "User"},
            chat: %Chat{id: 123, type: "private"}
          }
        }
      end
    end
    """
  end

  defp print_next_steps(module) do
    Mix.shell().info("""

    Add a bot token to your runtime config:

        config :nadia,
          token: {:system, "TELEGRAM_BOT_TOKEN"}

    Add the polling worker to your supervision tree:

        children = [
          {Nadia.Polling,
           handler: #{inspect(module)},
           allowed_updates: ["message"],
           timeout: 30}
        ]

    Then run:

        mix test
        TELEGRAM_BOT_TOKEN=123:token mix run --no-halt
    """)
  end
end
