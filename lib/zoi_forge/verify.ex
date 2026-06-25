defmodule ZoiForge.Verify do
  @moduledoc """
  Verifies that generated schema modules match a fresh codegen run.
  """

  alias ZoiForge.{Config, Generator}

  @doc """
  Verifies generated output is up to date with vendored schemas.

  Returns `:ok` when fresh, or `{:error, {:stale, paths}}` when output differs.
  """
  @spec run(Config.t() | keyword()) :: :ok | {:error, {:stale, [String.t()]}}
  def run(config_or_opts) do
    config = Config.new(config_or_opts)

    temp_root =
      Path.join(System.tmp_dir!(), "zoi_forge_verify_#{System.unique_integer([:positive])}")

    temp_output = Path.join(temp_root, config.output_dir)

    try do
      with {:ok, _generated} <-
             Generator.run(
               source_dir: config.source_dir,
               output_dir: temp_output,
               prefix: config.prefix
             ),
           stale <- diff_directories(temp_output, Path.expand(config.output_dir)) do
        if stale == [] do
          :ok
        else
          {:error, {:stale, Enum.sort(stale)}}
        end
      end
    after
      File.rm_rf(temp_root)
    end
  end

  @doc """
  Runs verification and raises when generated output is stale.
  """
  @spec run!(Config.t() | keyword()) :: :ok
  def run!(config_or_opts) do
    case run(config_or_opts) do
      :ok ->
        :ok

      {:error, {:stale, stale}} ->
        raise "Derived schemas are stale. Run: mix schemas:generate\nStale files:\n#{format_stale(stale)}"
    end
  end

  defp diff_directories(expected_root, actual_root) do
    expected = collect_files(expected_root)
    actual = collect_files(actual_root)

    stale =
      Enum.flat_map(expected, fn {relative_path, content} ->
        case Map.get(actual, relative_path) do
          ^content -> []
          _ -> [relative_path]
        end
      end)

    extra =
      actual
      |> Map.keys()
      |> Enum.reject(&Map.has_key?(expected, &1))
      |> Enum.map(&"+#{&1}")

    stale ++ extra
  end

  defp collect_files(root) do
    if File.exists?(root) do
      root
      |> Path.join("**/*")
      |> Path.wildcard()
      |> Enum.filter(&File.regular?/1)
      |> Map.new(fn path ->
        {Path.relative_to(path, root), normalize_content(File.read!(path))}
      end)
    else
      %{}
    end
  end

  defp normalize_content(content) do
    String.trim_trailing(content, "\n")
  end

  defp format_stale(stale) do
    stale
    |> Enum.map_join("\n", fn path -> "  #{path}" end)
  end
end
