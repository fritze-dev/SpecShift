# ADR-001: SpecShift v1.0 Architecture — Restructuring from OpenSpec

## Status
Accepted

## Context
The project evolved through 58 changes and 54 ADRs under the "OpenSpec/OPSX" name with an `openspec/` folder structure. This created deep nesting (`openspec/specs/<name>/spec.md`), template duplication (`src/templates/` + `openspec/templates/`), namespace confusion, and broken cross-client discovery (`.agents/` symlinks).

## Decision
Restructure the entire project as "SpecShift" with three architectural pillars:

1. **`.specshift/` (hidden infrastructure)**: WORKFLOW.md, CONSTITUTION.md, templates, and changes live in a hidden directory — same pattern as `.git/` and `.claude/`. Keeps the project root clean.

2. **`docs/` (project knowledge)**: Specs (flat files at `docs/specs/<name>.md`), capability docs, and ADRs all under `docs/`. Specs are source-of-truth input; capabilities and ADRs are generated output.

3. **`CLAUDE.md` (agent entry point)**: Single file, no symlinks. Replaces the AGENTS.md + CLAUDE.md symlink pattern.

Additional decisions:
- **Fork & Rewrite**: Repository duplicated (bare clone + mirror push) to preserve full git blame history while getting a clean repo name.
- **Skill renamed**: `workflow` → `specshift` for consistent branding (`specshift init`, `specshift propose`, etc.)
- **No template duplication**: Consumer templates live only in `.specshift/templates/`, copied from plugin's `src/templates/` during init.
- **Dogfooding 1:1 like client**: No symlinks between `src/` and `.specshift/`. Plugin registered locally via marketplace.
- **Beta phase**: Ship mechanics first, polish (ADR consolidation, docs regeneration) at v1.0.

## Consequences
- All `openspec/` paths change — every spec, template, skill, and config file updated
- Plugin name changes from `opsx` to `specshift` — consumers must reinstall
- Old repo archived on GitHub with redirect note
- 54 historical ADRs and 58 changes deleted from working tree (preserved in git history)
- Template version reset to 1 — no existing consumers affected (pre-release)
