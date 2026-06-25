defmodule ZoiForge.Generator do
  @moduledoc """
  Core schema-to-module generator for ZoiForge.

  Scans a source directory for `*.schema.json` files, converts each JSON Schema
  into a typed Elixir module backed by `Zoi`, and writes formatted source files
  to the configured output directory.
  """

  alias ZoiForge.{Config, Naming, SchemaRenderer}

  @schema_suffix ".schema.json"

  @doc """
  Runs code generation with the given config struct or keyword options.

  Returns `{:ok, generated}` where `generated` is a list of
  `{module_name, output_path}` tuples in deterministic order.
  """
  @spec run(Config.t() | keyword()) :: {:ok, [{String.t(), String.t()}]} | {:error, term()}
  def run(config_or_opts) do
    config = Config.new(config_or_opts)

    with :ok <- prepare_output_dir(config.output_dir),
         {:ok, schema_files} <- discover_schema_files(config.source_dir),
         {:ok, generated} <- generate_modules(config, schema_files) do
      {:ok, generated}
    end
  end

  defp prepare_output_dir(output_dir) do
    output_dir = Path.expand(output_dir)

    if File.exists?(output_dir) do
      case File.rm_rf(output_dir) do
        {:ok, _} -> :ok
        {:error, reason, path} -> {:error, {:output_dir_cleanup_failed, reason, path}}
      end
    end

    case File.mkdir_p(output_dir) do
      :ok -> :ok
      {:error, reason} -> {:error, {:output_dir_create_failed, reason, output_dir}}
    end
  end

  defp discover_schema_files(source_dir) do
    source_dir = Path.expand(source_dir)

    unless File.exists?(source_dir) do
      {:error, {:source_dir_not_found, source_dir}}
    else
      files =
        source_dir
        |> Path.join("**/*#{@schema_suffix}")
        |> Path.wildcard()
        |> Enum.sort()

      {:ok, files}
    end
  end

  defp generate_modules(config, schema_files) do
    result =
      Enum.reduce_while(schema_files, [], fn schema_path, acc ->
        relative = Path.relative_to(schema_path, Path.expand(config.source_dir))
        module_name = Naming.module_name(config.prefix, config.output_dir, relative)
        output_path = output_path(config.output_dir, relative)

        with {:ok, raw_json} <- read_schema_file(schema_path),
             {:ok, source} <- build_module_source(module_name, raw_json) do
          case write_module_file(output_path, source) do
            :ok ->
              {:cont, [{module_name, output_path} | acc]}

            {:error, write_reason} ->
              {:halt, {:error, {:write_failed, output_path, write_reason}}}
          end
        else
          {:error, reason} -> {:halt, {:error, {:generation_failed, schema_path, reason}}}
        end
      end)

    case result do
      {:error, reason} -> {:error, reason}
      generated -> {:ok, Enum.reverse(generated)}
    end
  end

  defp read_schema_file(path) do
    case File.read(path) do
      {:ok, contents} -> {:ok, contents}
      {:error, reason} -> {:error, {:read_failed, reason, path}}
    end
  end

  defp write_module_file(path, source) do
    dir = Path.dirname(path)

    with :ok <- File.mkdir_p(dir),
         :ok <- File.write(path, ensure_trailing_newline(source)) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp ensure_trailing_newline(source) do
    if String.ends_with?(source, "\n") do
      source
    else
      source <> "\n"
    end
  end

  defp output_path(output_dir, relative_path) do
    relative_path
    |> String.replace_suffix(@schema_suffix, ".ex")
    |> then(&Path.join(output_dir, &1))
  end

  defp build_module_source(module_name, raw_json) do
    with {:ok, json_map} <- Jason.decode(raw_json) do
      {:ok, SchemaRenderer.render(module_name, json_map, raw_json)}
    else
      {:error, reason} -> {:error, {:json_decode_failed, reason}}
    end
  end
end
