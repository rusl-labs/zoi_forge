defmodule Mix.Tasks.ZoiForge.Verify do
  @moduledoc """
  Verifies generated schema modules are up to date with vendored JSON Schema files.

      mix zoi_forge.verify
      mix zoi_forge.verify --prefix Rusl --source priv/schemas --output lib/schemas
  """

  use Mix.Task

  @shortdoc "Verifies generated schema modules are fresh"

  @switches [
    prefix: :string,
    source: :string,
    output: :string
  ]

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.config")

    {opts, _argv, _invalid} = OptionParser.parse(args, strict: @switches)

    config =
      opts
      |> Map.new()
      |> Map.take([:prefix, :source, :output])
      |> Map.new(fn
        {:source, value} -> {:source_dir, value}
        {:output, value} -> {:output_dir, value}
        other -> other
      end)
      |> Mix.ZoiForge.Config.build()

    case ZoiForge.Verify.run(config) do
      :ok ->
        Mix.shell().info(
          "Derived schemas are up to date with #{config[:source_dir] || "priv/schemas"}"
        )

      {:error, {:stale, stale}} ->
        Mix.shell().error("Derived schemas are stale. Run: mix schemas:generate")
        Mix.shell().error("Stale files:")

        Enum.each(stale, fn path ->
          Mix.shell().error("  #{path}")
        end)

        Mix.raise("stale generated schema modules")
    end
  end
end
