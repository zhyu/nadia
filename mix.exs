defmodule Nadia.Mixfile do
  use Mix.Project

  @source_url "https://github.com/zhyu/nadia"
  @version "0.8.0"

  def project do
    [
      app: :nadia,
      version: @version,
      elixir: "~> 1.15",
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
      {:httpoison, "~> 2.3"},
      {:jason, "~> 1.4"},
      {:exvcr, "~> 0.17", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :docs, runtime: false}
    ]
  end

  defp package do
    [
      description: "Telegram Bot API Wrapper written in Elixir",
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
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      formatters: ["html"]
    ]
  end
end
