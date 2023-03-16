defmodule Xod.MixProject do
  use Mix.Project

  @version "0.1.0"
  @repo_url "https://github.com/ernestoittig/xod"

  def project do
    [
      app: :xod,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
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
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
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
