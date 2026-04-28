---
title: "Multi-Target Distribution"
capability: "multi-target-distribution"
description: "Ship SpecShift to Claude Code and OpenAI Codex CLI from one repository with one shared skill body, four root manifest/marketplace files, and one agnostic version source of truth."
lastUpdated: "2026-04-28"
---
# Multi-Target Distribution

SpecShift is packaged from a single repository for two AI-coding-tool targets — Claude Code and OpenAI Codex CLI — via per-target plugin manifests and marketplace files at the repository root, one shared agnostic skill tree at `./skills/specshift/`, a bootstrap pattern that lets both runtimes read the same instructions without content duplication, and a single version source of truth at `src/VERSION` stamped symmetrically into the three version-bearing root files at compile time. The Codex marketplace catalog at `.agents/plugins/marketplace.json` is the fourth root file — it carries pure metadata (no `version` field) and resolves the plugin to the repository via a Git-URL source.

## Purpose

Without a multi-target distribution layout, packaging SpecShift for a second AI tool would require either a forked repository (drift between targets, doubled maintenance) or per-target rewrite passes in the build (token substitution, per-target skill variants — fragile, hard to debug). Without a single agnostic version source of truth, the per-target manifests carry dual responsibility ("target metadata" plus "repo version SoT"), and one target's version inevitably becomes the canonical source while the others are stamped from it — asymmetric and fragile. Without an agnostic bootstrap pattern, workflow rules end up duplicated across `AGENTS.md` and `CLAUDE.md` templates, and updates drift over time. Without a Codex marketplace catalog file, `codex plugin marketplace add github:owner/repo` cannot resolve the plugin — the auto-discovery pattern documented at the time of `0.2.5-beta` was falsified against a live Codex install, and the catalog at `.agents/plugins/marketplace.json` is now the verified install path.

## Rationale

The Shopify-flat layout (manifests side-by-side at the repo root, one shared `./skills/` tree) matches the verified Shopify-AI-Toolkit precedent and eliminates per-target duplication. Manifests are hand-edited at the root rather than rendered from `src/` because they carry per-target metadata only — there is no source/output relationship that would justify an indirection layer. The version source of truth lives in `src/VERSION` (plain text, single line, SemVer) so that bumping the version is a single small edit, decoupled from any per-target metadata file. The compile script reads `src/VERSION` and stamps the value into the three version-bearing root files (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`) via `jq` (preserving all non-version keys and values semantically; JSON formatting may be normalized), then re-reads each file and verifies the stamped value matches `src/VERSION`; any mismatch fails the build with an error naming the offending file. The bootstrap content lives once in `src/templates/agents.md` (full body) — Codex reads `AGENTS.md` natively at session start, Claude Code reads `CLAUDE.md` and expands the documented `@AGENTS.md` memory-import. The `src/templates/claude.md` stub is a one-line pointer, not a content duplicate, so single source of truth is preserved while both runtimes work without manual setup. The Codex marketplace catalog at `.agents/plugins/marketplace.json` declares a Git-URL source pointing back at this repository — Codex re-clones the URL during install and resolves the existing `.codex-plugin/plugin.json` and `./skills/specshift/` at the repo root, so no generated sub-payload directory is needed.

## Features

- Hand-edited per-target plugin manifests at the repository root: `.claude-plugin/plugin.json` (Claude Code), `.codex-plugin/plugin.json` (Codex CLI)
- Hand-edited Claude marketplace at the repository root: `.claude-plugin/marketplace.json`
- Hand-edited Codex marketplace catalog at the repository root: `.agents/plugins/marketplace.json` (Git-URL source pointing at the repository)
- Codex consumers install via `codex plugin marketplace add fritze-dev/SpecShift` and then enable SpecShift from the in-session `/plugins` directory` — Codex resolves the plugin via the marketplace catalog
- One shared agnostic skill tree at `./skills/specshift/` consumed by both targets via their respective manifests' skill-path field
- Single agnostic version source of truth at `src/VERSION` (plain text, single line, SemVer)
- Symmetric version stamping via `jq` into the three version-bearing root files with post-stamp cross-check that fails the build on drift; the Codex marketplace catalog has no `version` field and is not stamped
- Bootstrap single-source-of-truth pattern: `AGENTS.md` carries the full body (read by Codex natively, by Claude Code via `@AGENTS.md` import), `CLAUDE.md` is a one-line import stub
- `specshift init` generates both bootstrap files unconditionally on fresh init; existing files are never overwritten on re-init
- Multi-target install documentation in `README.md` with one section per target at the same heading level

## Behavior

### Per-Target Plugin Manifest

Each target ships one plugin manifest at the repo root. The Claude manifest at `.claude-plugin/plugin.json` carries the established Claude schema (`name`, `description`, `version`, `author`, `repository`, `license`, `keywords`). The Codex manifest at `.codex-plugin/plugin.json` carries the Codex schema (`name`, `version`, `description`, `skills` referencing the shared `./skills/`, `interface` block with `displayName`, `shortDescription`, `category`, plus optional UI fields like `longDescription`, `developerName`, `defaultPrompt`, `brandColor`, `screenshots`). Manifests are hand-edited; only the `version` field is touched by automation.

### Shared Skill Tree at the Repository Root

The compile script writes the entire compiled skill tree to `./skills/specshift/` — `SKILL.md`, the `templates/` directory, and the compiled `actions/` directory. The Claude marketplace declares `source: "./"` so Claude Code resolves the plugin root to the repo root and discovers the skill at `./skills/specshift/`. The Codex manifest declares `skills: "./skills/"` so Codex resolves the same shared tree. There is exactly one skill body — no per-target SKILL variants and no token-substitution rewrite passes.

### Codex Discovery via Marketplace Catalog

Codex consumers install via `codex plugin marketplace add fritze-dev/SpecShift` and then enable SpecShift from the in-session `/plugins` directory`. Codex resolves the GitHub URL, reads the marketplace catalog at `.agents/plugins/marketplace.json`, and follows the declared `plugins[0].source` to fetch the plugin. The catalog is hand-edited at the repository root and carries no `version` field — its metadata is reviewed manually for parity, like other hand-edited per-target fields. The earlier `0.2.5-beta` framing (auto-discovery without a catalog file) was falsified on 2026-04-28; the catalog-mediated install is now the verified path.

### Codex Marketplace Catalog Schema

The catalog at `.agents/plugins/marketplace.json` conforms to the schema documented at `developers.openai.com/codex/plugins/build`. The plugin entry declares a Git-URL source: `plugins[0].source` is `{ "source": "url", "url": "https://github.com/fritze-dev/SpecShift.git" }`. The plugin entry declares an installation policy of `{ "installation": "AVAILABLE", "authentication": "ON_INSTALL" }` and a `category` field (currently `"Coding"`). The Git-URL source form is preferred over a `local`-path source because Codex re-clones the URL during install, which resolves the existing `.codex-plugin/plugin.json` and `./skills/specshift/` at the repository root without requiring a generated sub-payload directory.

### Bootstrap Single Source of Truth Pattern

The plugin maintains `src/templates/agents.md` (full body, agnostic SoT) and `src/templates/claude.md` (one-line `@AGENTS.md` import stub). On fresh `specshift init`, both files are generated unconditionally — there is no environment detection that picks one over the other. Codex reads `AGENTS.md` natively at session start; Claude Code reads `CLAUDE.md` and expands the `@AGENTS.md` import. Updates to shared bootstrap content are made only in `agents.md`. The `claude.md` stub never duplicates normative rules from `agents.md`. Project-specific content (e.g., a File Ownership section reflecting the consumer project's directory layout) is added by the agent during `specshift init`'s codebase scan, not in the bootstrap template.

### Agnostic Skill Body

The shared skill body (`SKILL.md`, `templates/`, action specs and the spec files those actions link into) is authored in tool-agnostic language: plugin-bundled-asset references use prose like "the plugin's `templates/` directory" rather than runtime-specific environment variables, product names appear only where the surrounding paragraph is target-scoped (e.g., describing Claude Code's `@AGENTS.md` memory-import behavior), and worktree path patterns refer to the configured `.specshift/WORKFLOW.md` `worktree.path_pattern` value rather than a hardcoded `.claude/worktrees/...` string. The compiled tree contains 0 `${CLAUDE_PLUGIN_ROOT}` references and 0 hardcoded `.claude/worktrees/...` strings.

### Version Source of Truth & Symmetric Stamping

`src/VERSION` is the single agnostic version source of truth — plain text, single line, SemVer (e.g., `0.2.6-beta`). The compile script validates it against the SemVer 2.0 regex, then reads it once and stamps the value into the three version-bearing root files (`.claude-plugin/plugin.json` `.version`, `.claude-plugin/marketplace.json` `.plugins[].version`, `.codex-plugin/plugin.json` `.version`) via `jq`. After stamping, the script re-reads each file and verifies the stamped value matches `src/VERSION`; any mismatch fails the build with an error naming the offending file. The same cross-check is also enforced in CI (`.github/workflows/release.yml`) before tag creation. The compile script also stamps the version into the compiled workflow template's `plugin-version` frontmatter field. The Codex marketplace catalog at `.agents/plugins/marketplace.json` carries no `version` field and is not part of the stamping loop. To bump the plugin version, the maintainer edits `src/VERSION` and runs `bash scripts/compile-skills.sh` — the three version-bearing root files are updated in one consistent pass.

### Multi-Target Install Documentation

The `README.md` carries one install section per supported target at the same heading level. Claude Code consumers run `claude plugin marketplace add fritze-dev/specshift` and `claude plugin install specshift`. Codex consumers run `codex plugin marketplace add fritze-dev/SpecShift` and then install or enable SpecShift from the in-session `/plugins` directory; updates use `codex plugin marketplace upgrade specshift`. Update flows are target-specific and documented in their respective sections.

## Known Limitations

- Per-target manifest non-version fields (description, keywords, author URL) are not enforced for parity across targets — drift is a maintainer-review concern, not a compile-time error.
- The Codex marketplace catalog at `.agents/plugins/marketplace.json` is hand-edited and not enforced by the build script — a regression in the catalog's `source`, `policy`, or `category` fields would be discovered only via a live Codex install. A follow-up `verify_catalog_shape()` issue can add jq-based shape verification.
- Codex CLI plugin schema is still maturing; new required `interface` fields, catalog schema changes, or `policy` enum changes may require coordinated updates of the catalog, the spec, and the README.
- Live install verification on a real Codex installation is performed manually; no automated end-to-end smoke test runs in CI.
- Branding assets (logo, screenshots) for the Codex listing are not yet provided — the listing installs successfully but displays without branding.

## Future Enhancements

- `verify_catalog_shape()` in `scripts/compile-skills.sh` (jq-based) and a CI cross-check loop entry for `.agents/plugins/marketplace.json`
- Branding assets (logo, brand color confirmation, screenshots) for the Codex listing
- Cursor and Gemini target manifests (would follow the same hand-edited-at-root pattern)
- Live install smoke test in CI (Claude Code + Codex)

## Edge Cases

- **Existing Claude Code install with the pre-migration marketplace cache**: on the first `claude plugin marketplace update specshift` after upgrading, the new `source: "./"` and the new `./skills/specshift/` location are picked up transparently. No data migration required.
- **Manual edit to a manifest version field**: the next compile run overwrites the manual edit with the value from `src/VERSION`. The supported workflow is to edit `src/VERSION` and recompile.
- **`src/VERSION` malformed or missing**: a missing, empty, or multi-line `src/VERSION` fails the compile run with a descriptive error before any stamping occurs.
- **Mixed-target consumer project**: a project that uses both Claude Code and Codex needs no special setup — both bootstrap files are generated on fresh init, and `AGENTS.md` is the single agnostic source of truth that both runtimes read (Codex natively, Claude Code via `@AGENTS.md` import).
- **Mid-migration project with only `CLAUDE.md`**: re-running `specshift init` generates `AGENTS.md` alongside the existing `CLAUDE.md` (the existing file is preserved unmodified). If the legacy `CLAUDE.md` does not contain an `@AGENTS.md` import line, init reports a WARNING.
- **Codex catalog schema change**: `jq` stamping does not touch the catalog. A schema change at upstream (new required fields, renamed source forms, different policy enums) requires updating the catalog, the spec, and the README together — the catalog field shape is hand-maintained.
- **Codex marketplace upstream schema change for the plugin manifest**: `jq` stamping preserves all non-version fields verbatim, so an additive schema change in `.codex-plugin/plugin.json` (new optional fields) Just Works.
