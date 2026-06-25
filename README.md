# ZoiForge

> ZoiForge is inspired by [Schema-Driven Development](https://schema-driven.dev):
> define your data in JSON Schema, derive the code from it. ZoiForge handles
> the Elixir side — typed modules, validators, and docs generated from your
> schema files.

Generate typed, validated Elixir modules from JSON Schema files.

ZoiForge scans a directory of `*.schema.json` files and writes Elixir modules
backed by [Zoi](https://hex.pm/packages/zoi). Each module gets compile-time
`@type t`, a runtime `parse/1` validator, and docs derived from the schema.
You define the shape once in JSON Schema; ZoiForge generates the rest.

## Why ZoiForge

- **Schema-driven types** — `@type t` is derived from JSON Schema at compile time.
- **Runtime validation** — `parse/1` wraps `Zoi.parse/2` with clear `{:ok, _}` / `{:error, _}` results.
- **No hand-written boilerplate** — skip manual `Zoi.object/2`, `Zoi.map/2`, and `@type` definitions for managed shapes.
- **Deterministic output** — formatted with `mix format` rules; verify freshness in CI with `mix zoi_forge.verify`.

## Installation

Add `zoi_forge` to your dependencies:

```elixir
def deps do
  [
    {:zoi_forge, "~> 0.1.0"}
  ]
end
```

Docs: [hexdocs.pm/zoi_forge](https://hexdocs.pm/zoi_forge)

## Quick start

### With your own schema files

1. Add schema files under `priv/schemas/` (any nested layout; files must end in `.schema.json`):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "name": { "type": "string" }
  },
  "required": ["name"]
}
```

Save as `priv/schemas/user.schema.json`.

2. Configure defaults (optional — these match ZoiForge's built-in defaults):

```elixir
# config/config.exs
config :zoi_forge,
  source_dir: "priv/schemas",
  output_dir: "lib/schemas"
```

3. Generate modules:

```sh
mix zoi_forge.gen
```

By default, module names use your Mix project app name as a prefix and mirror
the schema path. For an app named `:my_app` and `priv/schemas/user.schema.json`,
you get `MyApp.Schemas.User` in `lib/schemas/user.ex`.

4. Use the generated module:

```elixir
alias MyApp.Schemas.User

User.parse(%{"name" => "alice"})
#=> {:ok, %{name: "alice"}}

User.parse(%{})
#=> {:error, _}
```

### If using Rusl

[Rusl](https://rusl.com) is a package manager for JSON Schema — like npm or
Hex, but for schemas. You declare dependencies in a manifest, pull pinned
versions from the Rusl registry, and vendor them into your project (typically
`priv/schemas/`).

ZoiForge does not require Rusl. If your schemas already come from Rusl, the
flow is:

```sh
rusl install          # vendor *.schema.json files into priv/schemas/
mix zoi_forge.gen     # generate Elixir modules from those files
```

Add or update schema dependencies with the Rusl CLI first (e.g.
`rusl add schema rusl/schemas/common`), then run the commands above. In this
repo, `mix schemas:sync` runs both steps.

## Using with Rusl

Rusl solves schema *sourcing* — discovery, versioning, and vendoring shared
JSON Schema across teams. ZoiForge solves schema *codegen* — turning those
files into typed Elixir modules with `parse/1`. They are separate tools with
no hard dependency between them, but the fit is natural: Rusl lands the schemas
in `priv/schemas/`; ZoiForge reads them and writes `lib/schemas/`.

See [rusl.com](https://rusl.com) for the registry, CLI, and how to set up
`rusl.bundle.toml` and `rusl.config.toml` in your project.

## Generated module API

Every generated schema module (except `$defs`-only parents) exposes:

| Function | Purpose |
|----------|---------|
| `@type t` | Elixir type spec from the JSON Schema |
| `schema/0` | Parsed Zoi schema structure |
| `raw_schema/0` | Original JSON Schema string |
| `parse/1` | Validate and coerce input data |

Schemas with `$defs` (or legacy `definitions`) also emit nested modules for
each definition — e.g. `MyApp.Schemas.Common.AccountSlug` — so you can import
and validate individual defs without a root document validator.

## Configuration

Set defaults in `config/config.exs`:

```elixir
config :zoi_forge,
  source_dir: "priv/schemas",
  output_dir: "lib/schemas",
  prefix: "MyApp",       # optional; defaults to your Mix project app name
  auto_prefix: false     # optional; derive module names from paths only
```

CLI switches override config when present:

```sh
mix zoi_forge.gen --prefix MyApp --source priv/schemas --output lib/schemas
```

## Mix tasks

| Task | Description |
|------|-------------|
| `mix zoi_forge.gen` | Generate modules from JSON Schema files |
| `mix zoi_forge.verify` | Fail if generated output is stale |
| `mix zoi_forge.clean` | Remove generated modules from the output directory |

Programmatic API:

```elixir
ZoiForge.Generator.run(
  prefix: "MyApp",
  source_dir: "priv/schemas",
  output_dir: "lib/schemas"
)
```

## CI tip

Run verification before tests to catch stale generated code:

```sh
mix zoi_forge.verify
mix test
```

Or wire `mix zoi_forge.verify` into your CI pipeline after schema changes.

## License

Apache-2.0 — see [LICENSE](LICENSE).
