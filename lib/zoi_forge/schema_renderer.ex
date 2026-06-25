defmodule ZoiForge.SchemaRenderer do
  @moduledoc false

  @doc """
  Renders an Elixir module (and nested `$defs` modules) for a JSON Schema document.
  """
  @spec render(String.t(), map(), String.t()) :: String.t()
  def render(module_name, json_map, raw_json) do
    render_module(module_name, json_map, raw_json, root?: true)
    |> Code.format_string!()
    |> IO.iodata_to_binary()
  end

  defp render_module(module_name, json_map, raw_json, opts) do
    root? = Keyword.get(opts, :root?, false)
    nested? = Keyword.get(opts, :nested?, false)
    defs_only? = root? && defs?(json_map) && !has_root_validator?(json_map)
    schema = Zoi.from_json_schema(json_map)
    describeable? = describeable?(schema)
    raw_schema_literal = inspect(raw_json, limit: :infinity, printable_limit: :infinity)
    nested_defs = render_nested_def_modules(json_map, parent_module: module_name, indent: nested?)
    module_label = module_label(module_name, nested?)

    moduledoc = moduledoc(module_label, schema, json_map, describeable?)

    raw_schema_attr = "@raw_schema #{raw_schema_literal}"

    validator_section =
      if defs_only? do
        """
        @doc "Returns the raw JSON schema string."
        def raw_schema, do: @raw_schema
        """
      else
        """
        @schema Zoi.from_json_schema(Jason.decode!(@raw_schema))

        #{moduledoc}

        @type t :: unquote(Zoi.type_spec(@schema))

        @doc "Returns the parsed Zoi schema structure."
        def schema, do: @schema

        @doc "Returns the raw JSON schema string."
        def raw_schema, do: @raw_schema

        @doc "Validates data against the schema structure."
        def parse(data), do: Zoi.parse(@schema, data)
        """
      end

    indent = if nested?, do: "  ", else: ""

    body_after_raw_schema =
      if defs_only? do
        """
        #{moduledoc}
        #{validator_section |> String.trim_trailing()}
        """
      else
        validator_section |> String.trim_trailing()
      end

    """
    #{indent}defmodule #{module_segment(module_name, nested?)} do
    #{indent}  #{raw_schema_attr}
    #{indent}  #{body_after_raw_schema}
    #{nested_defs}
    #{indent}end
    """
  end

  defp moduledoc(module_label, schema, json_map, describeable?) do
    if describeable? do
      """
      @moduledoc \"\"\"
      Configuration for #{module_label}.

      \#{Zoi.describe(@schema)}
      \"\"\"
      """
    else
      fallback = fallback_description(schema, json_map)

      """
      @moduledoc \"\"\"
      Configuration for #{module_label}.#{fallback_moduledoc(fallback)}
      \"\"\"
      """
    end
  end

  defp render_nested_def_modules(json_map, opts) do
    parent_module = Keyword.get(opts, :parent_module)
    indent = if Keyword.get(opts, :indent, false), do: "  ", else: ""

    json_map
    |> def_entries()
    |> Enum.sort_by(fn {key, _} -> key end)
    |> Enum.map_join("\n\n", fn {def_key, def_json} ->
      def_module_name = def_module_name(def_key)
      full_module_name = "#{parent_module}.#{def_module_name}"
      def_raw_json = Jason.encode!(def_json)

      render_module(
        full_module_name,
        def_json,
        def_raw_json,
        root?: false,
        nested?: true
      )
      |> indent_nested_module(indent)
    end)
  end

  defp indent_nested_module(source, indent) when indent == "" do
    source
  end

  defp indent_nested_module(source, indent) do
    source
    |> String.split("\n")
    |> Enum.map_join("\n", fn line ->
      if line == "" do
        ""
      else
        indent <> line
      end
    end)
  end

  defp module_segment(module_name, nested?) do
    if nested? do
      module_name |> String.split(".") |> List.last()
    else
      module_name
    end
  end

  defp module_label(module_name, _nested?) do
    module_name |> String.split(".") |> List.last()
  end

  defp def_entries(json_map) do
    case Map.get(json_map, "$defs") || Map.get(json_map, "definitions") do
      defs when is_map(defs) -> defs
      _ -> %{}
    end
  end

  defp defs?(json_map), do: def_entries(json_map) != %{}

  defp has_root_validator?(json_map) do
    Map.has_key?(json_map, "$ref") or
      Map.has_key?(json_map, "type") or
      Map.has_key?(json_map, "const") or
      Map.has_key?(json_map, "enum") or
      Map.has_key?(json_map, "allOf") or
      Map.has_key?(json_map, "anyOf") or
      Map.has_key?(json_map, "oneOf") or
      Map.has_key?(json_map, "properties") or
      Map.has_key?(json_map, "items")
  end

  defp def_module_name(def_key) do
    def_key
    |> String.split(~r/[^a-zA-Z0-9]+/, trim: true)
    |> Enum.map_join("", &Macro.camelize/1)
  end

  defp describeable?(schema) do
    try do
      _ = Zoi.describe(schema)
      true
    rescue
      ArgumentError -> false
    end
  end

  defp fallback_description(schema, json_map) do
    case Zoi.description(schema) do
      description when is_binary(description) and description != "" ->
        description

      _ ->
        case Map.get(json_map, "description") do
          description when is_binary(description) -> description
          _ -> ""
        end
    end
  end

  defp fallback_moduledoc(""), do: ""

  defp fallback_moduledoc(fallback) do
    "\n\n" <> escape_moduledoc(fallback)
  end

  defp escape_moduledoc(text) do
    text
    |> String.replace("\\", "\\\\")
    |> String.replace("\"\"\"", "\\\"\\\"\\\"")
  end
end
