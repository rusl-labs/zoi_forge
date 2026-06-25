defmodule Mix.Tasks.ZoiForge.Clean do
  @moduledoc """
  Removes generated schema modules from the output directory.

      mix zoi_forge.clean
      mix zoi_forge.clean --output lib/schemas
  """

  use Mix.Task

  @shortdoc "Removes generated schema modules"

  @switches [
    output: :string
  ]

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.config")

    {opts, _argv, _invalid} = OptionParser.parse(args, strict: @switches)

    output_dir =
      opts
      |> Map.new()
      |> Map.take([:output])
      |> Map.new(fn {_, value} -> {:output_dir, value} end)
      |> Mix.ZoiForge.Config.build()
      |> Keyword.fetch!(:output_dir)

    output_dir = Path.expand(output_dir)

    if File.exists?(output_dir) do
      case File.rm_rf(output_dir) do
        {:ok, _} ->
          Mix.shell().info("Removed generated schemas from #{output_dir}")

        {:error, reason, path} ->
          Mix.raise("failed to remove #{path}: #{inspect(reason)}")
      end
    else
      Mix.shell().info("No generated schemas at #{output_dir}")
    end
  end
end
