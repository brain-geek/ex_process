defmodule ExProcess.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_process,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExProcess.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:sweet_xml, "~> 0.6"},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:excoveralls, ">= 0.0.0", only: :test}
    ]
  end
end
