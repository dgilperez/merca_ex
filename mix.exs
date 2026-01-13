defmodule MercaEx.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/dgilperez/merca_ex"

  def project do
    [
      app: :merca_ex,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Hex.pm
      name: "MercaEx",
      description: "Elixir client for the Mercadona API",
      source_url: @source_url,
      homepage_url: @source_url,
      package: package(),
      docs: docs(),
      # Testing
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {MercaEx.Application, []}
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5"},
      {:jason, "~> 1.4"},

      # Testing
      {:mox, "~> 1.1", only: :test},
      {:excoveralls, "~> 0.18", only: :test},

      # Docs
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      maintainers: ["David Gil"],
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}"
    ]
  end
end
