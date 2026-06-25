defmodule ZoiForge.Naming do
  @moduledoc false

  @schema_suffix ".schema.json"

  @doc """
  Builds a module name from an optional prefix, output directory, and schema path.

  Segments from `lib/` onward in `output_dir` are included so modules mirror
  where generated files live under `lib/`.

      module_name("ZoiForge", "lib/schemas", "rusl/schemas/common.schema.json")
      #=> "ZoiForge.Schemas.Rusl.Schemas.Common"

      module_name(nil, "lib/schemas", "rusl/schemas/common.schema.json")
      #=> "Schemas.Rusl.Schemas.Common"
  """
  @spec module_name(String.t() | nil, String.t(), String.t()) :: String.t()
  def module_name(prefix, output_dir, relative_path) do
    source_segments = source_path_segments(relative_path)
    output_segments = output_dir_segments(output_dir)

    prefix_segments =
      case {prefix, source_segments} do
        {nil, _} -> []
        {^prefix, [^prefix | _]} -> []
        {prefix, _} -> [prefix]
      end

    prefix_segments
    |> Kernel.++(output_segments)
    |> Kernel.++(source_segments)
    |> Enum.join(".")
  end

  @doc false
  @spec source_path_segments(String.t()) :: [String.t()]
  def source_path_segments(relative_path) do
    relative_path
    |> String.replace_suffix(@schema_suffix, "")
    |> String.split("/")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&Macro.camelize/1)
  end

  @doc false
  @spec output_dir_segments(String.t()) :: [String.t()]
  def output_dir_segments(output_dir) do
    output_dir
    |> Path.expand()
    |> lib_relative_path()
    |> source_path_segments_from_dir()
  end

  defp source_path_segments_from_dir(""), do: []

  defp source_path_segments_from_dir(path) do
    path
    |> String.split("/")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&Macro.camelize/1)
  end

  defp lib_relative_path(path) do
    parts = Path.split(path)

    case Enum.find_index(parts, &(&1 == "lib")) do
      nil -> ""
      index -> parts |> Enum.drop(index + 1) |> Path.join()
    end
  end
end
