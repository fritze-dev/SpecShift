---
title: "Multi-Target Distribution"
capability: "multi-target-distribution"
description: "How SpecShift packages and ships to multiple AI-coding-tool targets from a single source repository."
lastUpdated: "2026-04-27"
---

# Multi-Target Distribution

SpecShift ships from one source tree to multiple AI-coding-tool plugin marketplaces. The same skill body, templates, and workflow rules reach Claude Code and OpenAI Codex CLI consumers without content duplication.

## Purpose

Without a multi-target distribution model, a workflow plugin that already works in one AI tool has to be re-authored, re-tested, and re-versioned to reach users of another tool. Bootstrap rules drift across targets when copy-pasted, plugin manifests fall out of sync on version, and supporting two install paths becomes a maintenance tax that makes adding a third target prohibitive.

## Rationale

The plugin keeps target-specific surface (manifest schemas, marketplace files) thin and target-portable surface (skill body, bootstrap content) shared. Each target owns its own manifest at `.<target>-plugin/plugin.json` so per-target metadata (display name, capabilities, branding) lives where the host CLI expects it; the compile script stamps a single version source of truth into every output so manifests cannot disagree on which release they represent. The skill body and bootstrap templates live once at the repo root and are referenced by all manifests via relative paths, eliminating duplication. Bootstrap content uses a single source of truth pattern: `AGENTS.md` carries the full agent directives (Codex reads it natively), and `CLAUDE.md` is reduced to a `@AGENTS.md` import (Claude Code expands the import at session start), which means workflow rule updates touch one file and propagate to both tools. The Shopify-AI-Toolkit was the reference implementation for this layout.

## Features

- Per-target plugin manifests authored under `src/<target>-plugin/` and emitted at the repo root by the compile script
- Single shared skill tree at `./skills/specshift/` referenced by every target manifest
- Codex marketplace entry generated alongside the existing Claude marketplace
- Bootstrap single source of truth: full body in AGENTS.md, import stub in CLAUDE.md
- Multi-target install instructions in the README, one section per supported target

## Behavior

### Compilation

The compile script (`bash scripts/compile-skills.sh`) runs from the repo root and produces all distribution artifacts in one pass. It reads sources under `src/`, copies the shared skill tree to `./skills/specshift/`, emits both manifest files (`.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`) at the repo root, writes the Codex marketplace file to `.agents/plugins/marketplace.json`, removes any legacy compiled tree from before the migration, and stamps the same version (read from the Claude source manifest) into every generated file.

### Installation per Target

Claude Code consumers install via `claude plugin marketplace add fritze-dev/specshift` followed by `claude plugin install specshift`. The marketplace source resolves to the repo root, and Claude Code finds the skill at `./skills/specshift/`.

Codex consumers run `codex /plugins`, browse for SpecShift, and install. The Codex CLI resolves the manifest's `skills` field to the same shared tree.

### Bootstrap File Generation

When `specshift init` runs in a fresh consumer project, it writes both `AGENTS.md` (full body, including Workflow, Planning, and Knowledge Management sections plus any project-specific content from the codebase scan) and `CLAUDE.md` (a single-line `@AGENTS.md` import). Codex reads AGENTS.md natively; Claude Code reads CLAUDE.md and expands the `@AGENTS.md` import to load AGENTS.md content into the session context. Updating workflow rules requires editing only the `agents.md` template — the change reaches both tools without duplication.

## Known Limitations

- Does not auto-install Codex hooks. Workflow enforcement on Codex relies on the AGENTS.md text rule; users who want hard `[hooks.PreToolUse]` blocking add the snippet to their personal `~/.codex/config.toml`.
- Does not register MCP servers. SpecShift currently uses no MCP tools, so `.mcp.json` is left empty.
- Does not ship branding assets. The Codex `interface.logo`, `composerIcon`, and `brandColor` fields are unset in the manifest; the listing displays without branding.
- Does not target Cursor or Gemini. The Shopify-AI-Toolkit reference includes both, but they are out of scope for the current SpecShift distribution.

## Future Enhancements

- Branding assets (logo SVG, brand color, composer icon) for the Codex listing
- Cursor plugin manifest at `.cursor-plugin/plugin.json` with corresponding marketplace entry
- Gemini extension manifest

## Edge Cases

- If the Codex source manifest declares a different version than the Claude source, the compile script silently overwrites the Codex output with the Claude version — preventing inconsistent releases.
- If a consumer project initialized by a pre-multi-target plugin version still has only `CLAUDE.md`, re-running `specshift init` adds `AGENTS.md` (full body) without overwriting the existing CLAUDE.md. The user is responsible for collapsing CLAUDE.md to an import stub manually.
- The compile script removes the legacy `.claude/skills/` location during compilation; if a consumer's local install retained that path from before the migration, a `marketplace update` rebuilds it correctly.
