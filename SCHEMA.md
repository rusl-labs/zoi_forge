# Schema workflow (this repo)

This repo dogfoods [Rusl](https://rusl.com) for JSON Schema dependencies and **zoi_forge** for Elixir codegen.

**Decide what things are. Generate the rest.**

Query before guessing. Reuse before inventing. See [rusl.com/llms.txt](https://rusl.com/llms.txt) for the full Rusl agent guide.

---

## What lives where

| Layer | Path | Managed by |
|-------|------|------------|
| Shapes | `priv/schemas/` | `rusl install` (vendored) |
| Rusl paths | `rusl.config.toml` | manual (`schema_dir = "priv/schemas"`) |
| Dependencies | `rusl.bundle.toml` | `rusl add` / `rusl remove` / manual edit |
| Pins | `rusl.lock` | `rusl install` |
| Elixir modules | `lib/schemas/` | `mix schemas:generate` |
| Tooling | `lib/zoi_forge/`, `lib/mix/tasks/` | normal edits |
| Test fixtures | `test/fixtures/schemas/` | manual (not Rusl) |

---

## Hard rules

- **Rusl MCP first** (`user-rusl`) for discovery, resolution, and proposals when the task touches structured data.
- **Rusl CLI** for local dependency management — `rusl --help` for the current command surface.
- **Never** edit vendored `priv/schemas/`, `rusl.lock`, or generated `lib/schemas/` by hand.
- **Never** hand-write `Zoi.map/2`, `Zoi.object/2`, or `@type` for Rusl-managed shapes.
- **Propose** new or changed shapes through Rusl — don't patch vendored JSON files.
- Missing meaning → **`create_context_request`** (MCP), not guesses in code.

---

## Rusl MCP — `user-rusl`

| Category | Tools | Purpose |
|----------|-------|---------|
| **Discover** | `search` | Find schemas, bundles, annotation types, annotations |
| **Resolve** | `get_schema`, `get_bundle`, `get_annotation`, `get_annotation_type`, `list_schema_examples` | Full content after search |
| **Propose** | `create_schema`, `create_schema_proposal`, `get/update_schema_proposal`, review-thread tools | Change shapes through review — not file edits |
| **Context** | `create_context_request`, `create_domain_interpretation`, `create_semantic_link`, `create_trust_signal`, `create_source_attestation`, `create_migration_guide`, `create_usage_report`, `create_context_loading_hint` | Typed meaning; prefer `create_context_request` when blocked |
| **Trust** | `endorse` | Endorse useful existing annotations |

`search` ranks and previews. Follow with `get_*` for the full contract and load annotations before writing dependent code.

---

## Rusl CLI

Think **npm / mix**, but for JSON Schema:

| Task | Command |
|------|---------|
| Add a schema or bundle | `rusl add schema rusl/schemas/common` |
| Add with version pin | `rusl add schema acme/schemas/user -v ">=1.0.0"` |
| Remove a dependency | `rusl remove schema rusl/schemas/common` |
| Sync vendored schemas | `rusl install` |
| Inspect installed graph | `rusl list --tree` |
| Search registry | `rusl search "trust signal"` |
| Explain dependency | `rusl why rusl/schemas/common` |

`rusl.config.toml` sets `schema_dir = "priv/schemas"` so installs land in the Elixir-appropriate vendored tree.

After any dependency change: **`mix schemas:sync`**.

---

## zoi_forge — derive, don't edit

```sh
mix schemas:sync       # rusl install + generate
mix schemas:generate   # priv/schemas/ → lib/schemas/
mix schemas:verify     # fail if lib/schemas/ is stale
mix schemas:clean      # remove zoi_forge output only
```

Import derived modules — e.g.:

```elixir
alias Rusl.Schemas.Common

Common.schema()
Common.raw_schema()
Common.parse(%{"name" => "alice"})
```

Generated modules expose:

- `@type t` — from `Zoi.type_spec/1`
- `schema/0` — parsed Zoi schema
- `raw_schema/0` — original JSON Schema string
- `parse/1` — `Zoi.parse/2` wrapper

Module names map from vendored paths: `priv/schemas/rusl/schemas/common.schema.json` → `Rusl.Schemas.Common` when `--prefix Rusl`.

---

## Fast path

1. **`search`** (MCP) for the concept.
2. **`get_schema`** / **`get_bundle`** + annotations (MCP).
3. **`rusl add`** then **`mix schemas:sync`** to vendor into `priv/schemas/` and regenerate.
4. Import from `lib/schemas/`.
5. No match? **`create_schema`** / **`create_schema_proposal`** (MCP) — wait for approval.
6. Meaning missing? **`create_context_request`** (MCP).

---

## Shape vs meaning

| | Where | Who owns it |
|---|-------|-------------|
| **Shape** | JSON Schema in `priv/schemas/` | One author (Rusl registry) |
| **Registry meta** | `@moduledoc`, JSON `$id` / `title` | Derived at codegen |
| **Meaning** | Rusl annotations | Many authors (PII, trust, retention, …) |

A schema body alone is incomplete. Load annotations before code depends on semantics.

---

## References

- [rusl.com/llms.txt](https://rusl.com/llms.txt)
- [schema-driven.dev/llms.txt](https://schema-driven.dev/llms.txt)
- [rusl.com/d/cli/overview](https://rusl.com/d/cli/overview)
- [hex.pm/packages/zoi](https://hex.pm/packages/zoi)
