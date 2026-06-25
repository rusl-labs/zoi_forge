defmodule Mix.Tasks.ZoiForge.Gen do
  @moduledoc """
  Generates Elixir modules from JSON Schema files.

      mix zoi_forge.gen
      mix zoi_forge.gen --prefix Rusl --source priv/schemas --output lib/schemas

  ## Switches

    * `--prefix` - Top-level module namespace prefix (default: active Mix project app name)
    * `--source` - Directory containing `*.schema.json` files (default: `"priv/schemas"`)
    * `--output` - Directory for generated Elixir modules (default: `"lib/schemas"`)
  """

  use Mix.Task

  @shortdoc "Generates Elixir modules from JSON Schema files"

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

    case ZoiForge.Generator.run(config) do
      {:ok, generated} ->
        Enum.each(generated, fn {module_name, output_path} ->
          Mix.shell().info("Generated: #{module_name} -> #{output_path}")
        end)

      {:error, reason} ->
        Mix.raise("zoi_forge.gen failed: #{inspect(reason)}")
    end
  end
end
