defmodule ZoiForge.Config do
  @moduledoc """
  Generation options for `ZoiForge.Generator`.
  """

  @default_source_dir "priv/schemas"
  @default_output_dir "lib/schemas"

  defstruct source_dir: @default_source_dir,
            output_dir: @default_output_dir,
            prefix: nil

  @type t :: %__MODULE__{
          source_dir: String.t(),
          output_dir: String.t(),
          prefix: String.t() | nil
        }

  @doc """
  Builds a config struct from a keyword list or returns the given `%#{__MODULE__}{}` unchanged.

  When `:prefix` is `nil`, module names are derived from schema file paths only.
  """
  @spec new(t() | keyword()) :: t()
  def new(%__MODULE__{} = config), do: config

  def new(opts) when is_list(opts) do
    %__MODULE__{}
    |> struct!(opts)
  end
end
