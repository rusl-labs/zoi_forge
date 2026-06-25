defmodule ZoiForge do
  @moduledoc """
  Generate typed, documented Elixir modules from JSON Schema files using [Zoi](https://hex.pm/packages/zoi).

  ZoiForge is a code generator: point it at a directory of `*.schema.json` files
  and it writes Elixir modules with compile-time `@type t`, runtime `parse/1`,
  and docs derived from each schema. It works with any JSON Schema files on
  disk — no [Rusl](https://rusl.com) dependency required.

  ## Quick start

  Configure defaults (optional):

      config :zoi_forge,
        source_dir: "priv/schemas",
        output_dir: "lib/schemas"

  Generate modules:

      mix zoi_forge.gen

  Or call the generator directly:

      ZoiForge.Generator.run(
        prefix: "MyApp",
        source_dir: "priv/schemas",
        output_dir: "lib/schemas"
      )

  ## Generated modules

  Each schema file becomes a module exposing:

    * `@type t` — Elixir type from the JSON Schema
    * `schema/0` — parsed Zoi schema
    * `raw_schema/0` — original JSON Schema string
    * `parse/1` — `Zoi.parse/2` wrapper

  Schemas with `$defs` also emit nested modules for individual definitions.

  ## Mix tasks

    * `mix zoi_forge.gen` — generate modules
    * `mix zoi_forge.verify` — fail when output is stale
    * `mix zoi_forge.clean` — remove generated output

  See `Mix.Tasks.ZoiForge.Gen` for CLI switches and configuration details.
  """
end
