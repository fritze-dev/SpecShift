<!--
---
status: active
branch: claude/centralize-versioning-compilation-vGtAO
capabilities:
  new: []
  modified: []
  removed: []
---
-->
## Why

PR #16 modified templates without bumping `template-version`, which went undetected through the review flow. The original design assumption ("plugin maintainers will remember") was invalidated. Without enforcement, consumer projects running `specshift init` silently miss template updates — their local copies remain stale with no merge prompt.

## What Changes

- Add git-diff-based `template-version` validation to `scripts/compile-skills.sh` — compilation fails if a template under `src/templates/` was modified (vs `main`) without bumping its `template-version`
- Add a "Template-version discipline" convention to `.specshift/CONSTITUTION.md` documenting the rule
- Update finalize instruction in `.specshift/WORKFLOW.md` to mention that compilation enforces template-version freshness

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — this is a local project tooling change, not a spec-level behavior change)

### Removed Capabilities
(none)

### Consolidation Check
N/A — no new specs proposed. All changes are to local project files: build script, constitution convention, and workflow instruction.

## Impact

- `scripts/compile-skills.sh` — new validation section between preflight and copy steps
- `.specshift/CONSTITUTION.md` — new convention entry
- `.specshift/WORKFLOW.md` — updated finalize instruction text
- No spec changes, no distributed template changes, no consumer-facing behavior changes

## Scope & Boundaries

**In scope:**
- Template-version enforcement in the compilation step
- Constitution convention documentation
- Finalize instruction update

**Out of scope:**
- Changes to distributed templates (`src/templates/`)
- New spec requirements
- Pre-commit hooks or CI-level checks
- Content-hash-based validation (overkill for this use case)
