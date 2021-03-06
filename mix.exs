defmodule Tracer.MixProject do
  use Mix.Project

  def project do
    [
      app: :tracer,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Tracer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:tesla, "~> 1.3"},
      {:con_cache, "~> 0.14.0"}
    ]
  end
end
