defmodule AbsintheConstraints.MixProject do
  use Mix.Project

  def project do
    [
      app: :absinthe_constraints,
      description:
        "Defines a GraphQL directive to be used with Absinthe to validate input values.",
      package: package(),
      version: "0.1.1",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:absinthe, ">= 1.7.6"},
      {:elixir_uuid, ">= 1.2.1"},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false}
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/bounceapp/absinthe_constraints"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
