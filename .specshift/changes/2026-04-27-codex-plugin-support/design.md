# Technical Design: Codex Plugin Support

## Context

SpecShift is source-driven: maintainers edit `src/`, then `scripts/compile-skills.sh` generates a consumable plugin release. The new Codex support should fit this model so Claude and Codex releases do not drift.

## Architecture & Components

- `src/.codex-plugin/plugin.json`: Codex manifest source with interface metadata.
- `src/codex/templates/agents.md`: Codex-specific bootstrap template for `AGENTS.md`.
- `scripts/compile-skills.sh`: one compiler that builds:
  - Claude release at `.claude/`
  - Codex root-plugin release at `.codex-plugin/` and `skills/specshift/`
- `README.md`: platform-specific install/update sections.

## Goals & Success Metrics

- PASS if `bash scripts/compile-skills.sh` regenerates `.claude/`, `.codex-plugin/`, and `skills/specshift/`.
- PASS if both `src/.codex-plugin/plugin.json` and `.codex-plugin/plugin.json` are valid JSON.
- PASS if generated Codex manifest uses `skills: "./skills/"` and exposes `skills/specshift/SKILL.md`.
- PASS if generated Codex runtime files contain no stale `CLAUDE.md`, `${CLAUDE_PLUGIN_ROOT}`, or `.claude/worktrees` references.
- PASS if existing Claude release generation still succeeds.

## Non-Goals

- No official publication workflow.
- No new runtime dependency for compilation.
- No change to existing Claude marketplace behavior.

## Decisions

- Generate the Codex release from source rather than committing an independent hand-maintained plugin.
  - Alternative considered: copy the local draft into the repo. Rejected because it would drift from `src/`.
- Use the Shopify AI Toolkit root plugin layout for Codex (`.codex-plugin/` plus root `skills/`).
  - Alternative considered: nested `plugins/specshift/` plus `.agents/plugins/marketplace.json`. Rejected because it does not match the public Codex plugin repository layout requested by review.
- Keep platform-specific files under `src/codex/`.
  - Alternative considered: put `agents.md` in `src/templates/`. Rejected because the Claude release would then include a Codex-only bootstrap template.
- Use deterministic text rewriting for compiled Codex files.
  - Alternative considered: duplicate every action and template for Codex. Rejected because duplicated requirements would diverge.

## Risks & Trade-offs

- Text rewriting can miss a future Claude-specific phrase -> mitigate with validation checks that scan generated Codex output.
- Codex plugin UI behavior may evolve -> document the Shopify-style `/plugins` flow and keep the repository layout compatible with root plugin discovery.
- Codex and Claude trigger behavior differ -> use a Codex-specific generated skill description.

## Migration Plan

Existing Claude users are unaffected. Codex users can install the repository as a Codex plugin source after the PR lands.

## Open Questions

No blocking open questions.

## Assumptions

- Codex can load a root plugin repository containing `.codex-plugin/plugin.json` and `skills/`, matching Shopify AI Toolkit. <!-- ASSUMPTION: codex-root-plugin-layout -->
- Codex plugin discovery uses `.codex-plugin/plugin.json` plus the `skills` path. <!-- ASSUMPTION: codex-plugin-discovery -->
