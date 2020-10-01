defmodule Useful.MixProject do
  use Mix.Project

  def project do
    [
      app: :useful,
      description: "A collection of useful functions",
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Keep Code Tidy: https://github.com/rrrene/credo
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},

      # track test coverage: https://github.com/parroty/excoveralls
      {:excoveralls, "~> 0.13.2", only: [:test, :dev]},

      # Create Documentation Hex.docs: https://hex.pm/packages/ex_doc
      {:ex_doc, "~> 0.22.6", only: :dev},

      # Git pre-commit hook: https://github.com/dwyl/elixir-pre-commit
      {:pre_commit, "~> 0.3.4", only: :dev}
    ]
  end

  #  package info for publishing to Hex.pm
  defp package() do
    [
      files: ~w(lib LICENSE mix.exs README.md),
      name: "useful",
      licenses: ["GNU GPL v2.0"],
      maintainers: ["dwyl"],
      links: %{"GitHub" => "https://github.com/dwyl/useful"}
    ]
  end
end
