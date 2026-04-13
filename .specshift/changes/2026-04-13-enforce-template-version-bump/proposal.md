---
status: completed
branch: claude/add-dark-mode-gFEcV
capabilities:
  new: []
  modified: [workflow-contract, quality-gates]
  removed: []
---
## Why

PR #16 modified template content in `src/templates/` without bumping `template-version`, and the existing review flow did not catch it. The original design explicitly accepted "plugin maintainers will remember to bump template-version" as an assumption — this assumption has been invalidated. Without enforcement, consumer projects running `specshift init` after a plugin update silently miss template changes because the version-based merge detection sees no version change.

## What Changes

- Add a SHALL-statement to `workflow-contract.md` requiring `template-version` to be incremented when template content changes
- Add a new preflight dimension (H) to `quality-gates.md` that validates template-version freshness against the diff — detecting when `src/templates/` files have content changes but unchanged `template-version` fields
- Add a finalize check that validates template-version bump as a safety net before release compilation

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `workflow-contract`: Add a SHALL-statement requiring template-version bump when Smart Template content changes
- `quality-gates`: Add preflight dimension (H) Template-Version Freshness that validates template-version fields were bumped for changed templates; add finalize-time safety net check

### Removed Capabilities

(none)

### Consolidation Check

1. Existing specs reviewed: workflow-contract, quality-gates, project-init, release-workflow, spec-format, artifact-pipeline, change-workspace, task-implementation
2. Overlap assessment: The template-version bump requirement naturally belongs in `workflow-contract` (where the Smart Template Format is defined) and `quality-gates` (where preflight dimensions and verification are defined). No new spec needed — these are extensions of existing requirements.
3. Merge assessment: N/A — no new capabilities proposed.

## Impact

- `docs/specs/workflow-contract.md`: New requirement for template-version bump discipline
- `docs/specs/quality-gates.md`: New preflight dimension (H) and finalize validation
- `src/templates/workflow.md`: Finalize instruction updated to include template-version check
- Compiled action files regenerated via `bash scripts/compile-skills.sh`

## Scope & Boundaries

**In scope:**
- SHALL-statement in workflow-contract for template-version bump requirement
- Preflight dimension checking template-version freshness
- Finalize safety net check before compilation
- Convention-based enforcement (agent reads instructions and follows them)

**Out of scope:**
- Hard enforcement via git hooks or CI scripts (contradicts project philosophy)
- Automated version bumping (the agent should detect and flag, not silently fix)
- Changes to init merge logic (already works correctly when versions are bumped)
