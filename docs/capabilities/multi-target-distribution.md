---
title: "Multi-Target Distribution"
capability: "multi-target-distribution"
description: "Ship SpecShift to Claude Code and OpenAI Codex CLI from one repository with one shared skill body and one agnostic version source of truth."
lastUpdated: "2026-04-27"
---
# Multi-Target Distribution

SpecShift is packaged from a single repository for two AI-coding-tool targets — Claude Code and OpenAI Codex CLI — via per-target plugin manifests and marketplace files at the repository root, one shared agnostic skill tree at `./skills/specshift/`, a bootstrap pattern that lets both runtimes read the same instructions without content duplication, and a single version source of truth at `src/VERSION` stamped symmetrically into all three root manifest/marketplace files at compile time.

## Purpose

Without a multi-target distribution layout, packaging SpecShift for a second AI tool would require either a forked repository (drift between targets, doubled maintenance) or per-target rewrite passes in the build (token substitution, per-target skill variants — fragile, hard to debug). Without a single agnostic version source of truth, the per-target manifests carry dual responsibility ("target metadata" plus "repo version SoT"), and one target's version inevitably becomes the canonical source while the others are stamped from it — asymmetric and fragile. Without an agnostic bootstrap pattern, workflow rules end up duplicated across `AGENTS.md` and `CLAUDE.md` templates, and updates drift over time.

## Rationale

The Shopify-flat layout (manifests side-by-side at the repo root, one shared `./skills/` tree) matches the verified Shopify-AI-Toolkit precedent and eliminates per-target duplication. Manifests are hand-edited at the root rather than rendered from `src/` because they carry per-target metadata only — there is no source/output relationship that would justify an indirection layer. The version source of truth lives in `src/VERSION` (plain text, single line, SemVer) so that bumping the version is a single small edit, decoupled from any per-target metadata file. The compile script reads `src/VERSION` and stamps the value into all three root manifest/marketplace files via `jq` (preserving all non-version keys and values semantically; JSON formatting may be normalized), then re-reads each file and verifies the stamped value matches `src/VERSION`; any mismatch fails the build with an error naming the offending file. The bootstrap content lives once in `src/templates/agents.md` (full body) — Codex reads `AGENTS.md` natively at session start, Claude Code reads `CLAUDE.md` and expands the documented `@AGENTS.md` memory-import. The `src/templates/claude.md` stub is a one-line pointer, not a content duplicate, so single source of truth is preserved while both runtimes work without manual setup.

## Features

- Hand-edited per-target plugin manifests at the repository root: `.claude-plugin/plugin.json` (Claude Code), `.codex-plugin/plugin.json` (Codex CLI)
- Hand-edited Claude marketplace at the repository root: `.claude-plugin/marketplace.json`
- Codex auto-discovery via `codex plugin marketplace add github:owner/repo` reading `.codex-plugin/plugin.json` directly — no separate Codex marketplace catalog file needed for single-plugin repos
- One shared agnostic skill tree at `./skills/specshift/` consumed by both targets via their respective manifests' skill-path field
- Single agnostic version source of truth at `src/VERSION` (plain text, single line, SemVer)
- Symmetric version stamping via `jq` into all three root manifest/marketplace files with post-stamp cross-check that fails the build on drift
- Bootstrap single-source-of-truth pattern: `AGENTS.md` carries the full body (read by Codex natively, by Claude Code via `@AGENTS.md` import), `CLAUDE.md` is a one-line import stub
- `specshift init` generates both bootstrap files unconditionally on fresh init; existing files are never overwritten on re-init
- Multi-target install documentation in `README.md` with one section per target at the same heading level

## Behavior

### Per-Target Plugin Manifest

Each target ships one plugin manifest at the repo root. The Claude manifest at `.claude-plugin/plugin.json` carries the established Claude schema (`name`, `description`, `version`, `author`, `repository`, `license`, `keywords`). The Codex manifest at `.codex-plugin/plugin.json` carries the Codex schema (`name`, `version`, `description`, `skills` referencing the shared `./skills/`, `interface` block with `displayName`, `shortDescription`, `category`, plus optional UI fields like `longDescription`, `developerName`, `defaultPrompt`, `brandColor`, `screenshots`). Manifests are hand-edited; only the `version` field is touched by automation.

### Shared Skill Tree at the Repository Root

The compile script writes the entire compiled skill tree to `./skills/specshift/` — `SKILL.md`, the `templates/` directory, and the compiled `actions/` directory. The Claude marketplace declares `source: "./"` so Claude Code resolves the plugin root to the repo root and discovers the skill at `./skills/specshift/`. The Codex manifest declares `skills: "./skills/"` so Codex resolves the same shared tree. There is exactly one skill body — no per-target SKILL variants and no token-substitution rewrite passes.

### Codex Discovery via Marketplace Add

Codex consumers install via `codex plugin marketplace add github:fritze-dev/specshift` (or an equivalent direct-repo install command). Codex resolves the repository, reads `.codex-plugin/plugin.json` at the root, and creates the marketplace entry automatically — no separate `.agents/plugins/marketplace.json` catalog file is shipped. This matches the documented Codex single-plugin auto-discovery pattern. If a future change introduces multiple plugins from this repository, or the plugin needs to control installation policy or curated ordering, a `.agents/plugins/marketplace.json` can be added at that time using the official Codex schema (`name`, `interface.displayName`, `plugins[].source: {source, path}`, `plugins[].policy`, `plugins[].category`).

### Bootstrap Single Source of Truth Pattern

The plugin maintains `src/templates/agents.md` (full body, agnostic SoT) and `src/templates/claude.md` (one-line `@AGENTS.md` import stub). On fresh `specshift init`, both files are generated unconditionally — there is no environment detection that picks one over the other. Codex reads `AGENTS.md` natively at session start; Claude Code reads `CLAUDE.md` and expands the `@AGENTS.md` import. Updates to shared bootstrap content are made only in `agents.md`. The `claude.md` stub never duplicates normative rules from `agents.md`. Project-specific content (e.g., a File Ownership section reflecting the consumer project's directory layout) is added by the agent during `specshift init`'s codebase scan, not in the bootstrap template.

### Agnostic Skill Body

The shared skill body (`SKILL.md`, `templates/`, action specs and the spec files those actions link into) is authored in tool-agnostic language: plugin-bundled-asset references use prose like "the plugin's `templates/` directory" rather than runtime-specific environment variables, product names appear only where the surrounding paragraph is target-scoped (e.g., describing Claude Code's `@AGENTS.md` memory-import behavior), and worktree path patterns refer to the configured `.specshift/WORKFLOW.md` `worktree.path_pattern` value rather than a hardcoded `.claude/worktrees/...` string. The compiled tree contains 0 `${CLAUDE_PLUGIN_ROOT}` references and 0 hardcoded `.claude/worktrees/...` strings.

### Version Source of Truth & Symmetric Stamping

`src/VERSION` is the single agnostic version source of truth — plain text, single line, SemVer (e.g., `0.2.5-beta`). The compile script validates it against the SemVer 2.0 regex, then reads it once and stamps the value into the three root files (`.claude-plugin/plugin.json` `.version`, `.claude-plugin/marketplace.json` `.plugins[].version`, `.codex-plugin/plugin.json` `.version`) via `jq`. After stamping, the script re-reads each file and verifies the stamped value matches `src/VERSION`; any mismatch fails the build with an error naming the offending file. The same cross-check is also enforced in CI (`.github/workflows/release.yml`) before tag creation, so a maintainer who edits `src/VERSION` without recompiling is caught at push time. The compile script also stamps the version into the compiled workflow template's `plugin-version` frontmatter field. To bump the plugin version, the maintainer edits `src/VERSION` and runs `bash scripts/compile-skills.sh` — the three root files are updated in one consistent pass.

### Multi-Target Install Documentation

The `README.md` carries one install section per supported target at the same heading level. Claude Code consumers run `claude plugin marketplace add fritze-dev/specshift` and `claude plugin install specshift`. Codex consumers discover the plugin via `codex /plugins`. Update flows are target-specific and documented in their respective sections.

## Known Limitations

- Per-target manifest non-version fields (description, keywords, author URL) are not enforced for parity across targets — drift is a maintainer-review concern, not a compile-time error.
- Codex CLI plugin schema is still maturing; new required `interface` fields or marketplace location changes may require compile-script updates. Mitigation: the jq-stamping approach preserves all non-version fields verbatim, so additive schema changes Just Work.
- Live install verification on a real Codex installation is performed manually; no automated end-to-end smoke test runs in CI.
- Branding assets (logo, screenshots) for the Codex listing are not yet provided — the listing installs successfully but displays without branding.

## Future Enhancements

- Branding assets (logo, brand color confirmation, screenshots) for the Codex listing
- Cursor and Gemini target manifests (would follow the same hand-edited-at-root pattern)
- Live install smoke test in CI (Claude Code + Codex)

## Edge Cases

- **Existing Claude Code install with the pre-migration marketplace cache**: on the first `claude plugin marketplace update specshift` after upgrading, the new `source: "./"` and the new `./skills/specshift/` location are picked up transparently. No data migration required.
- **Manual edit to a manifest version field**: the next compile run overwrites the manual edit with the value from `src/VERSION`. The supported workflow is to edit `src/VERSION` and recompile.
- **`src/VERSION` malformed or missing**: a missing, empty, or multi-line `src/VERSION` fails the compile run with a descriptive error before any stamping occurs.
- **Mixed-target consumer project**: a project that uses both Claude Code and Codex needs no special setup — both bootstrap files are generated on fresh init, and `AGENTS.md` is the single agnostic source of truth that both runtimes read (Codex natively, Claude Code via `@AGENTS.md` import).
- **Mid-migration project with only `CLAUDE.md`**: re-running `specshift init` generates `AGENTS.md` alongside the existing `CLAUDE.md` (the existing file is preserved unmodified). If the legacy `CLAUDE.md` does not contain an `@AGENTS.md` import line, init reports a WARNING.
- **Codex marketplace upstream schema change**: jq stamping preserves all non-version fields verbatim, so an additive schema change (new optional fields) Just Works. A change to the marketplace file location would require updating the compile script.
