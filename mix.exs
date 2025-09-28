defmodule ExUtcp.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_utcp,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/universal-tool-calling-protocol/ex-utcp",
      docs: [
        main: "ExUtcp",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # HTTP client
      {:req, "~> 0.4"},
      {:jason, "~> 1.4"},

      # WebSocket support
      {:websockex, "~> 0.4"},

      # gRPC support
      {:grpc, "~> 0.7"},
      {:protobuf, "~> 0.12"},

      # GraphQL support
      {:absinthe, "~> 1.7"},
      {:absinthe_plug, "~> 1.5"},

      # Environment variables
      {:dotenvy, "~> 0.8"},

      # Testing
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:mox, "~> 1.0", only: :test}
    ]
  end

  defp description do
    "Elixir implementation of the Universal Tool Calling Protocol (UTCP)"
  end

  defp package do
    [
      maintainers: ["Universal Tool Calling Protocol Team"],
      licenses: ["MPL-2.0"],
      links: %{
        "GitHub" => "https://github.com/universal-tool-calling-protocol/ex-utcp",
        "Documentation" => "https://hexdocs.pm/ex_utcp"
      }
    ]
  end
end
