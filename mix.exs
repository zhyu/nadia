defmodule Nadia.Mixfile do
  use Mix.Project

  @source_url "https://github.com/zhyu/nadia"
  @version "1.3.0"

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
      description: "Telegram Bot API Wrapper written in Elixir",
      files: [
        ".formatter.exs",
        "CHANGELOG.md",
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
        "Changelog" => @source_url <> "/blob/master/CHANGELOG.md"
      }
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [title: "Changelog"],
        "guides/build-your-first-bot.md": [title: "Build Your First Bot"],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      formatters: ["html"]
    ]
  end
end
