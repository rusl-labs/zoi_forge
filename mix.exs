defmodule ZoiForge.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/rusl-labs/zoi_forge"

  def project do
    [
      app: :zoi_forge,
      version: @version,
      elixir: "~> 1.18",
      name: "ZoiForge",
      description: "Generate typed, validated Elixir modules from JSON Schema files using Zoi.",
      authors: ["Daniel Neighman"],
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      config_path: "config/config.exs",
      package: package(),
      docs: docs()
    ]
  end

  defp aliases do
    [
      "schemas:generate": "zoi_forge.gen",
      "schemas:sync": ["cmd rusl install", "schemas:generate"],
      "schemas:verify": "zoi_forge.verify",
      "schemas:clean": "zoi_forge.clean",
      test: ["schemas:verify", "test"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "lib/mix", "test/support"]
  defp elixirc_paths(_), do: ["lib", "lib/mix"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:zoi, "~> 0.18"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end

  defp package do
    [
      maintainers: ["Daniel Neighman"],
      licenses: ["Apache-2.0"],
      organization: "rusl",
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "https://hexdocs.pm/zoi_forge/changelog.html"
      },
      files:
        ~w(.formatter.exs lib/mix lib/zoi_forge lib/zoi_forge.ex mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: extras(),
      groups_for_modules: groups_for_modules(),
      filter_modules: fn module, _ ->
        module
        |> Atom.to_string()
        |> then(&(!String.starts_with?(&1, "ZoiForge.Schemas.")))
      end
    ]
  end

  defp extras do
    [
      "README.md": [title: "Overview"],
      "CHANGELOG.md": [title: "Changelog"],
      LICENSE: [title: "License"]
    ]
  end

  defp groups_for_modules do
    [
      Core: [
        ZoiForge,
        ZoiForge.Generator,
        ZoiForge.Config,
        ZoiForge.Verify
      ],
      "Mix Tasks": [
        Mix.Tasks.ZoiForge.Gen,
        Mix.Tasks.ZoiForge.Verify,
        Mix.Tasks.ZoiForge.Clean
      ]
    ]
  end
end
