---
description: Agent guide for zoi_forge — schema-driven codegen with Rusl and Elixir.
globs: "*.ex, *.exs, *.json, mix.exs"
alwaysApply: false
---

IRON RULE: Before creating, modifying, or generating code for any data type, you must read [SCHEMA.md](SCHEMA.md) first.

# zoi_forge — agent guide

This repo builds **zoi_forge** — a Mix task and library that generates typed Elixir modules from JSON Schema using [Zoi](https://hex.pm/packages/zoi). It also **dogfoods Rusl**: vendored shapes live in `priv/schemas/`, generated modules in `lib/schemas/`.

## Quick rules

- **Never** hand-write `Zoi.map/2`, `Zoi.object/2`, or `@type` definitions for Rusl-managed shapes.
- **Never** edit vendored `priv/schemas/`, `rusl.lock`, or generated `lib/schemas/` by hand.
- **`rusl.bundle.toml`** is the schema deps manifest — use `rusl add` / `rusl remove`, or edit constraints then `rusl install`.
- **Tooling changes** go in `lib/` directly.
- **Run** `mix schemas:verify` after schema dependency or codegen changes.

## Commands

| Task | Command |
|------|---------|
| Install Elixir deps | `mix deps.get` |
| Test | `mix test` |
| Format | `mix format` |
| Sync Rusl + regenerate modules | `mix schemas:sync` |
| Generate modules from vendored schemas | `mix schemas:generate` |
| Verify derived output is fresh | `mix schemas:verify` |
| Clean zoi_forge output | `mix schemas:clean` |
| Generate (custom paths) | `mix zoi_forge.gen --prefix Rusl --source priv/schemas --output lib/schemas` |

## Layout

```
rusl.bundle.toml     ← schema deps (like package.json)
rusl.config.toml     ← Rusl install paths (schema_dir = priv/schemas)
rusl.lock            ← pins from rusl install — do not edit
priv/schemas/        ← vendored JSON Schema — do not edit
lib/schemas/         ← zoi_forge output — do not edit
lib/zoi_forge/       ← generator library
lib/mix/tasks/       ← Mix tasks (gen, verify, clean)
test/fixtures/       ← test-only schema fixtures (not Rusl)
```

## When schemas change

1. `rusl search` → `rusl add …` (or edit `rusl.bundle.toml`)
2. `mix schemas:sync`
3. `mix schemas:verify`

Rusl MCP, CLI reference, and shape vs meaning — see [SCHEMA.md](SCHEMA.md).

## Elixir

- Use `mix format` and `mix test` as the standard checks.
- Generated modules compile as normal `lib/` code — do not add `lib/schemas/` to `.gitignore`; commit regenerated output with schema changes.
- Prefer `ZoiForge.Generator.run/1` for programmatic codegen; Mix tasks are thin wrappers.
- Defensive error handling for file I/O; generator prunes `output_dir` before writing.
- `mix test` runs `schemas:verify` first — regenerate before pushing if vendored or generated files changed.
