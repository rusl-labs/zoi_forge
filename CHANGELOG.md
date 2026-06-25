# Changelog

All notable changes to this project will be documented in this file.

## v0.1.0 — 2026-06-25

### Added

- `ZoiForge.Generator` — scan `*.schema.json` files and emit Zoi-backed Elixir modules
- `ZoiForge.Verify` — detect stale generated output
- Mix tasks: `zoi_forge.gen`, `zoi_forge.verify`, `zoi_forge.clean`
- Nested module generation for JSON Schema `$defs` / `definitions`
- Configurable source dir, output dir, and module prefix via CLI or `config :zoi_forge`
