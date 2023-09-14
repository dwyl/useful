defmodule Useful.MixProject do
  use Mix.Project

  def project do
    [
      app: :useful,
      description: "A collection of useful functions",
      version: "1.13.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        c: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.json": :test,
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
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},

      # track test coverage: https://github.com/parroty/excoveralls
      {:excoveralls, "~> 0.17.0", only: [:test, :dev]},

      # Create Documentation Hex.docs: https://hex.pm/packages/ex_doc
      {:ex_doc, "~> 0.30.1", only: :dev},

      # Git pre-commit hook: https://github.com/dwyl/elixir-pre-commit
      {:pre_commit, "~> 0.3.4", only: :dev},

      # Plug helper functions: github.com/elixir-plug/plug
      # Used for %Plug.Upload{} Struct see: #49 & #52
      {:plug, "~> 1.14"}
    ]
  end

  #  package info for publishing to Hex.pm
  defp package() do
    [
      files: ~w(lib LICENSE mix.exs README.md),
      name: "useful",
      licenses: ["GPL-2.0-or-later"],
      maintainers: ["dwyl"],
      links: %{"GitHub" => "https://github.com/dwyl/useful"}
    ]
  end

  defp aliases do
    [
      c: ["coveralls.html"]
    ]
  end
end
