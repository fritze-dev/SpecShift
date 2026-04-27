---
title: "Multi-Target Distribution"
capability: "multi-target-distribution"
description: "How SpecShift packages and ships to multiple AI-coding-tool targets from a single source repository."
lastUpdated: "2026-04-27"
---

# Multi-Target Distribution

SpecShift ships from one source tree to multiple AI-coding-tool plugin marketplaces. The same skill body, templates, and workflow rules reach Claude Code and OpenAI Codex CLI consumers without content duplication and without per-target rewrites.

## Purpose

Without a multi-target distribution model, a workflow plugin that already works in one AI tool has to be re-authored, re-tested, and re-versioned to reach users of another tool. Bootstrap rules drift across targets when copy-pasted, plugin manifests fall out of sync on version, and supporting two install paths becomes a maintenance tax that makes adding a third target prohibitive.

## Rationale

The plugin keeps target-specific surface (manifest schemas, marketplace files) thin and target-portable surface (skill body, bootstrap content) shared. Each target owns its own manifest hand-edited at the repo root (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`) so per-target metadata (display name, capabilities, branding, default prompts) lives where the host CLI expects it; the compile script reads the version from the Claude manifest (the source of truth) and stamps it into the Codex manifest in place via `jq`, preserving all other Codex fields verbatim, so manifests cannot disagree on which release they represent. The skill body, templates, and action specs are authored agnostically (no `${CLAUDE_PLUGIN_ROOT}` env vars, no Claude-specific worktree paths in compiled-into-skill files, no product names where prose generalizes naturally) so the same compiled `./skills/specshift/` tree serves both runtimes without per-target rewrite passes. Bootstrap content uses a single source of truth pattern: `AGENTS.md` carries the full agent directives (Codex reads it natively); `CLAUDE.md` is a one-line `@AGENTS.md` import stub that Claude Code expands at session start to load the AGENTS.md body into context. Both bootstrap files are generated on fresh init so the documented Claude Code memory-import pattern is active without manual setup; SSOT is preserved because the stub is a pointer, not a content duplicate. The Shopify-AI-Toolkit was the reference implementation for this layout.

## Features

- Per-target plugin manifests hand-edited at the repo root (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`)
- Single shared agnostic skill tree at `./skills/specshift/` referenced by every target manifest
- Codex marketplace entry generated alongside the existing Claude marketplace
- Bootstrap single source of truth: full body in AGENTS.md; CLAUDE.md is a one-line `@AGENTS.md` import stub generated on fresh init so Claude Code's memory-import pattern is active without manual setup. The stub is a pointer, not a content duplicate
- Multi-target install instructions in the README, one section per supported target

## Behavior

### Compilation

The compile script (`bash scripts/compile-skills.sh`) runs from the repo root and produces all distribution artifacts in one pass. It reads the version from `.claude-plugin/plugin.json` (the source of truth, hand-edited at the root), copies the shared skill tree from `src/` to `./skills/specshift/`, stamps the version into `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json` in place via `jq` (preserving every other field verbatim), removes any legacy compiled tree from before the migration, and verifies that the emitted Codex version equals the Claude source after stamping. The script does not copy plugin manifests or marketplace files from `src/` — they all live at the root and are hand-edited.

### Installation per Target

Claude Code consumers install via `claude plugin marketplace add fritze-dev/specshift` followed by `claude plugin install specshift`. The marketplace source resolves to the repo root, and Claude Code finds the skill at `./skills/specshift/`.

Codex consumers run `codex /plugins`, browse for SpecShift, and install. The Codex CLI resolves the manifest's `skills` field to the same shared tree. The Codex manifest now ships with discoverability metadata (long description, developer name, website URL, default prompts, brand color) so the listing renders rich.

### Bootstrap File Generation

When `specshift init` runs in a fresh consumer project, it writes both `AGENTS.md` (full body, including Workflow, Planning, and Knowledge Management sections plus any project-specific content from the codebase scan) and `CLAUDE.md` (a single `@AGENTS.md` line). Codex reads `AGENTS.md` natively at session start; Claude Code reads `CLAUDE.md` and expands the `@AGENTS.md` import to load the AGENTS.md body into context. Updating workflow rules requires editing only the `agents.md` template — the change reaches both tools without duplication, and the CLAUDE.md stub never needs touching because it just imports.

On re-init, existing AGENTS.md and CLAUDE.md files are never modified. AGENTS.md is checked against the bootstrap template's section headings and missing standard sections are reported as WARNING; CLAUDE.md is checked the same way but with WARNING-only reporting (CLAUDE.md content is intentionally minimal and may legitimately diverge from the stub). User edits to either file remain authoritative — re-init reports drift but never auto-edits.

### Source Agnostic-ness

Compiled-into-skill files (the action specs, the SKILL.md, the templates) reference plugin-bundled assets in prose ("the plugin's `templates/` directory") rather than via runtime-specific environment variables. Codex has no equivalent of `${CLAUDE_PLUGIN_ROOT}` (verified against `developers.openai.com/codex/skills` and the Shopify-AI-Toolkit), so prose-based references resolve correctly under both runtimes via the agent's understanding of the skill's installed location. Worktree path examples in compiled-into-skill files use the `.specshift/worktrees/` namespace; the actual project-instance configuration lives in `.specshift/WORKFLOW.md` `worktree.path_pattern`.

## Known Limitations

- Does not auto-install Codex hooks. Workflow enforcement on Codex relies on the AGENTS.md text rule; users who want hard `[hooks.PreToolUse]` blocking add the snippet to their personal `~/.codex/config.toml`.
- Does not register MCP servers. SpecShift currently uses no MCP tools.
- Does not enforce non-version manifest field parity. The compile script enforces only the `version` field across Claude and Codex manifests; agnostic metadata (`author`, `repository`, `license`, `keywords`) is hand-edited and reviewed manually for parity.
- Does not target Cursor or Gemini. The Shopify-AI-Toolkit reference includes both, but they are out of scope for the current SpecShift distribution.

## Future Enhancements

- CI parity check for agnostic manifest metadata fields across targets
- Logo SVG, brand color refinement, and screenshots for the Codex listing
- Cursor plugin manifest at `.cursor-plugin/plugin.json` with corresponding marketplace entry
- Gemini extension manifest

## Edge Cases

- If the Codex manifest at the root carries a different version than the Claude manifest, the compile script restamps the Codex `.version` to the Claude source and verifies equality post-stamp — releases never disagree on version.
- If a consumer project initialized by a pre-multi-target plugin version still has only `CLAUDE.md`, re-running `specshift init` adds `AGENTS.md` (full body) without overwriting the existing CLAUDE.md, and reports that the user may want to collapse CLAUDE.md to a `@AGENTS.md` import stub manually if a single-source-of-truth pattern is desired.
- If a project has only `AGENTS.md` (e.g., AGENTS.md was hand-written before init ran), re-running `specshift init` generates the `CLAUDE.md` import stub alongside it without modifying AGENTS.md.
- The compile script removes the legacy `.claude/skills/` location during compilation; if a consumer's local install retained that path from before the migration, a `marketplace update` rebuilds it correctly.
- If `jq` is missing on the developer machine, the compile script fails preflight with an instructive message naming the missing dependency.
