defmodule Mix.ZoiForge.Config do
  @moduledoc false

  @config_keys [:prefix, :source_dir, :output_dir]

  @default_source_dir "priv/schemas"
  @default_output_dir "lib/schemas"

  @doc """
  Builds generator options from Mix CLI switches, falling back to `config :zoi_forge`
  and then the active Mix project app name.

  Set `config :zoi_forge, auto_prefix: false` to derive module names from paths only.
  """
  @spec build(keyword() | map()) :: keyword()
  def build(cli_opts) do
    cli_opts = Map.new(cli_opts)
    app_config = Application.get_all_env(:zoi_forge)

    Enum.reduce(@config_keys, [], fn key, acc ->
      value = resolve(key, cli_opts, app_config)
      Keyword.put(acc, key, value)
    end)
  end

  @doc """
  Derives a module prefix from a Mix project app name.

      app_to_prefix(:foo_de_fafa)
      #=> "FooDeFafa"
  """
  @spec app_to_prefix(atom()) :: String.t()
  def app_to_prefix(app) when is_atom(app) do
    app
    |> Atom.to_string()
    |> String.split("_", trim: true)
    |> Enum.map_join("", &Macro.camelize/1)
  end

  @doc """
  Returns the module prefix for the Mix project `mix` was invoked from.
  """
  @spec project_prefix!() :: String.t()
  def project_prefix! do
    case Mix.Project.config()[:app] do
      app when is_atom(app) -> app_to_prefix(app)
      _ -> Mix.raise("could not determine module prefix from Mix project :app")
    end
  end

  defp resolve(:prefix, cli_opts, app_config) do
    cond do
      Map.has_key?(cli_opts, :prefix) ->
        Map.get(cli_opts, :prefix)

      app_config[:auto_prefix] == false ->
        nil

      is_binary(app_config[:prefix]) ->
        app_config[:prefix]

      true ->
        project_prefix!()
    end
  end

  defp resolve(key, cli_opts, app_config) do
    Map.get(cli_opts, key) ||
      Keyword.get(app_config, key) ||
      default(key)
  end

  defp default(:source_dir), do: @default_source_dir
  defp default(:output_dir), do: @default_output_dir
end
