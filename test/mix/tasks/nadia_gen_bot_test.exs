defmodule Mix.Tasks.Nadia.Gen.BotTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  @task "nadia.gen.bot"

  setup do
    tmp = Path.join(System.tmp_dir!(), "nadia_gen_bot_#{System.unique_integer([:positive])}")
    File.rm_rf!(tmp)
    File.mkdir_p!(tmp)

    previous_cwd = File.cwd!()
    repo_path = previous_cwd

    on_exit(fn ->
      File.cd!(previous_cwd)
      File.rm_rf!(tmp)
      Mix.Task.reenable(@task)
    end)

    File.cd!(tmp)
    Mix.Task.reenable(@task)

    {:ok, repo_path: repo_path, tmp: tmp}
  end

  test "generates a polling bot handler, offline test, and next steps" do
    output =
      with_ansi_enabled(true, fn ->
        capture_io(fn ->
          Mix.Task.run(@task, ["MyApp.Bot", "--polling"])
        end)
      end)
      |> strip_ansi()

    assert File.read!("lib/my_app/bot.ex") =~ "defmodule MyApp.Bot do"
    assert File.read!("lib/my_app/bot.ex") =~ "@behaviour Nadia.Handler"
    assert File.read!("lib/my_app/bot.ex") =~ "Nadia.Dispatcher.match_command(context, \"start\")"

    assert File.read!("test/my_app/bot_test.exs") =~ "defmodule MyApp.BotTest do"
    assert File.read!("test/my_app/bot_test.exs") =~ "defmodule FakeHTTPClient do"
    assert File.read!("test/my_app/bot_test.exs") =~ "Client.new(token: \"123:test-token\""
    assert File.read!("test/my_app/bot_test.exs") =~ "test \"echoes plain text messages\""

    assert output =~ "* creating lib/my_app/bot.ex"
    assert output =~ "* creating test/my_app/bot_test.exs"
    assert output =~ "Add the polling worker to your supervision tree"
    assert output =~ "{Nadia.Polling"

    refute File.exists?("config/config.exs")
    refute File.exists?("lib/my_app/application.ex")
    refute File.exists?("README.md")
  end

  test "polling is the default generated runtime" do
    capture_io(fn ->
      Mix.Task.run(@task, ["MyApp.Bot"])
    end)

    assert File.read!("lib/my_app/bot.ex") =~ "Nadia.Context.reply(context, \"Ready\")"
    assert File.read!("test/my_app/bot_test.exs") =~ "defmodule MyApp.BotTest do"
  end

  test "does not overwrite existing files unless forced" do
    File.mkdir_p!("lib/my_app")
    File.write!("lib/my_app/bot.ex", "# existing\n")

    output =
      capture_io(fn ->
        Mix.Task.run(@task, ["MyApp.Bot"])
      end)
      |> strip_ansi()

    assert output =~ "* skipping lib/my_app/bot.ex"
    assert File.read!("lib/my_app/bot.ex") == "# existing\n"

    Mix.Task.reenable(@task)

    capture_io(fn ->
      Mix.Task.run(@task, ["MyApp.Bot", "--force"])
    end)

    assert File.read!("lib/my_app/bot.ex") =~ "defmodule MyApp.Bot do"
  end

  test "generated files pass mix test in a fixture project", %{repo_path: repo_path} do
    capture_io(fn ->
      Mix.Task.run(@task, ["MyApp.SupportBot", "--polling"])
    end)

    File.write!("test/test_helper.exs", "ExUnit.start()\n")

    File.write!("mix.exs", """
    defmodule FixtureBot.MixProject do
      use Mix.Project

      def project do
        [
          app: :fixture_bot,
          version: "0.1.0",
          elixir: "~> 1.20",
          deps: deps()
        ]
      end

      def application do
        [
          extra_applications: [:logger]
        ]
      end

      defp deps do
        [
          {:nadia, path: #{inspect(repo_path)}}
        ]
      end
    end
    """)

    env = [
      {"MIX_ENV", "test"},
      {"MIX_DEPS_PATH", Path.join(repo_path, "deps")},
      {"MIX_BUILD_PATH", Path.join(File.cwd!(), "_build")}
    ]

    {deps_get_output, deps_get_status} =
      System.cmd("mix", ["deps.get"], stderr_to_stdout: true, env: env)

    assert deps_get_status == 0, deps_get_output

    {test_output, test_status} =
      System.cmd("mix", ["test"], stderr_to_stdout: true, env: env)

    assert test_status == 0, test_output
    assert test_output =~ "Result: 3 passed"
  end

  test "rejects invalid module names" do
    assert_raise Mix.Error, ~r/expected a valid Elixir module name/, fn ->
      Mix.Task.run(@task, ["my_app.Bot"])
    end
  end

  test "rejects webhook endpoint generation until a framework adapter exists" do
    assert_raise Mix.Error, ~r/use Nadia.Webhook in your web framework/, fn ->
      Mix.Task.run(@task, ["MyApp.Bot", "--webhook"])
    end
  end

  defp with_ansi_enabled(enabled?, fun) do
    previous = Application.fetch_env(:elixir, :ansi_enabled)
    Application.put_env(:elixir, :ansi_enabled, enabled?)

    try do
      fun.()
    after
      case previous do
        {:ok, value} -> Application.put_env(:elixir, :ansi_enabled, value)
        :error -> Application.delete_env(:elixir, :ansi_enabled)
      end
    end
  end

  defp strip_ansi(output) do
    Regex.replace(~r/\e\[[0-9;]*m/, output, "")
  end
end
