defmodule Nadia.Mixfile do
  use Mix.Project

  @source_url "https://github.com/zhyu/nadia"
  @version "0.7.0"

  def project do
    [
      app: :nadia,
      version: @version,
      elixir: "~> 1.8",
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      preferred_cli_env: [docs: :docs]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.8.0"},
      {:jason, "~> 1.1"},
      {:exvcr, "~> 0.13.4", only: [:dev, :test]},
      {:earmark, "~> 1.2", only: :docs},
      {:ex_doc, ">= 0.0.0", only: :docs, runtime: false},
      {:inch_ex, "~> 2.0.0", only: :docs}
    ]
  end

  defp package do
    [
      description: "Telegram Bot API Wrapper written in Elixir",
      maintainers: ["zhyu"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/zhyu/nadia"}
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      formatters: ["html"]
    ]
  end
end
