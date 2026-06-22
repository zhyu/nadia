defmodule Nadia.Mixfile do
  use Mix.Project

  @source_url "https://github.com/zhyu/nadia"
  @version "1.5.0"

  def project do
    [
      app: :nadia,
      version: @version,
      elixir: "~> 1.20",
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      test_ignore_filters: [~r"test/support/"]
    ]
  end

  def cli do
    [
      preferred_envs: [docs: :docs]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:req, "~> 0.6.1"},
      {:ex_doc, ">= 0.0.0", only: :docs, runtime: false}
    ]
  end

  defp package do
    [
      description: "Telegram Bot API and Telegraph client for Elixir",
      files: [
        ".formatter.exs",
        "CHANGELOG.md",
        "examples",
        "LICENSE.md",
        "README.md",
        "guides",
        "lib",
        "mix.exs"
      ],
      maintainers: ["zhyu"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => @source_url <> "/blob/master/CHANGELOG.md",
        "Telegram Bot API" => "https://core.telegram.org/bots/api",
        "Telegraph API" => "https://telegra.ph/api"
      }
    ]
  end

  defp docs do
    [
      extras: [
        "README.md": [title: "Overview"],
        "guides/build-your-first-bot.md": [title: "Build Your First Bot"],
        "guides/examples.md": [title: "Examples And Learning Paths"],
        "guides/examples/inline-keyboards.md": [title: "Commands And Inline Keyboards"],
        "guides/examples/conversation-state.md": [title: "Conversation State"],
        "guides/examples/persistent-sessions.md": [title: "Persistent Session Backends"],
        "guides/examples/media-and-files.md": [title: "Media And Files"],
        "guides/examples/errors-and-rate-limits.md": [title: "Errors And Rate Limits"],
        "guides/receive-webhook-updates.md": [title: "Receive Webhook Updates"],
        "guides/multiple-bots.md": [title: "Run Multiple Bots"],
        "guides/testing-bots.md": [title: "Test Bot Handlers"],
        "guides/production-checklist.md": [title: "Production Checklist"],
        "guides/telegraph.md": [title: "Use The Telegraph API"],
        "CHANGELOG.md": [title: "Changelog"],
        "LICENSE.md": [title: "License"]
      ],
      groups_for_extras: [
        "Start Here": [
          "README.md",
          "guides/build-your-first-bot.md",
          "guides/examples.md"
        ],
        Examples: ~r|guides/examples/|,
        "Integrate And Operate": [
          "guides/receive-webhook-updates.md",
          "guides/multiple-bots.md",
          "guides/testing-bots.md",
          "guides/production-checklist.md"
        ],
        Telegraph: ["guides/telegraph.md"],
        Project: ["CHANGELOG.md", "LICENSE.md"]
      ],
      groups_for_modules: [
        "Bot API": [Nadia, Nadia.Behaviour, Nadia.Client, Nadia.InputFile],
        "Bot Runtime": [
          Nadia.Context,
          Nadia.Dispatcher,
          Nadia.Handler,
          Nadia.Polling,
          Nadia.SessionStore,
          Nadia.SessionStore.ETS,
          Nadia.Webhook
        ],
        "HTTP And Parsing": [
          Nadia.API,
          Nadia.Config,
          Nadia.HTTPClient,
          Nadia.HTTPClient.Req,
          Nadia.HTTPRequest,
          Nadia.HTTPResponse,
          Nadia.Parser
        ],
        Telegraph: ~r/^Nadia\.Graph/,
        Models: ~r/^Nadia\.Model/,
        "Mix Tasks": ~r/^Mix\.Tasks\.Nadia/
      ],
      main: "readme",
      source_url: @source_url,
      formatters: ["html"]
    ]
  end
end
