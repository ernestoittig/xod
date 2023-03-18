defmodule Xod.MixProject do
  use Mix.Project

  @version "0.1.1"
  @repo_url "https://github.com/ernestoittig/xod"

  def project do
    [
      app: :xod,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      description: "Parsing and schema validation library for Elixir",
      name: "Xod",
      package: package(),
      source_url: @repo_url,
      docs: docs()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp docs do
    [
      main: Xod,
      groups_for_docs: [
        Schemata: &(&1[:section] == :schemas),
        Utilities: &(&1[:section] == :utils),
        Modifiers: &(&1[:section] == :mods)
      ]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @repo_url},
      mantainers: ["Ernesto Ittig"]
    ]
  end
end
