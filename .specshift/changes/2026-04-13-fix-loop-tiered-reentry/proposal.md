---
status: active
branch: fix-loop-tiered-reentry
capabilities:
  new: []
  modified: [human-approval-gate]
  removed: []
---
## Why

When PR review reveals an approach change (different files, different abstraction, wrong scope), the apply agent enters "patch mode" rather than re-entering the spec flow. This produces multiple revert/fix commits, leaves change artifacts (design.md, tasks.md, review.md) describing the original wrong approach, and breaks the spec-as-source-of-truth principle. The Fix Loop exists but lacks explicit classification guidance — agents cannot self-detect "approach change" vs. "typo fix" without concrete criteria.

## What Changes

- **Tiered Fix Loop classification** added to the `Fix Loop` requirement in `human-approval-gate.md`: three tiers (Tweak / Design Pivot / Scope Change) with concrete detection signals and per-tier re-entry depth
- **Apply instruction updated** in `src/templates/workflow.md` (and synced to `.specshift/WORKFLOW.md`): explicit tier classification step before patching, and artifact staleness rule for Design Pivot / Scope Change corrections
- **Fix Loop step 3.4 updated** in `src/templates/changes/tasks.md` (and synced to `.specshift/templates/changes/tasks.md`): tiered classification in the step description

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `human-approval-gate`: Add tiered re-entry classification (Tweak / Design Pivot / Scope Change) with concrete detection signals to the Fix Loop requirement. Add artifact staleness rule: Design Pivot and Scope Change corrections SHALL update all stale change artifacts before re-implementing.

### Removed Capabilities

(none)

### Consolidation Check

1. **Existing specs reviewed**: artifact-pipeline, workflow-contract, release-workflow, three-layer-architecture, change-workspace, task-implementation, quality-gates, human-approval-gate, documentation, project-init, constitution-management, spec-format, test-generation, roadmap-tracking
2. **Overlap assessment**: The Fix Loop behavior is owned by `human-approval-gate` (Fix Loop requirement, lines 102-166). `task-implementation` defines how the apply agent processes tasks — no Fix Loop classification there. `quality-gates` covers preflight and review dimensions — not fix loop re-entry. No overlap with other specs.
3. **Merge assessment**: N/A — only one modified capability proposed.
4. **Granularity check**: Tiered re-entry is a feature detail within the existing Fix Loop requirement — it adds sub-classification to an existing behavior rather than introducing a new testable surface area. It belongs as enhanced requirements in `human-approval-gate`, not as a new spec.

## Impact

- **Affected files**: `docs/specs/human-approval-gate.md` (Fix Loop requirement), `src/templates/workflow.md` (apply instruction), `.specshift/WORKFLOW.md` (synced from src), `src/templates/changes/tasks.md` (step 3.4), `.specshift/templates/changes/tasks.md` (synced from src), `.claude/skills/specshift/actions/apply.md` (AOT compiled)
- **No breaking changes**: This is a refinement of existing behavior, not a change to the apply action's interface or flow

## Scope & Boundaries

- **In scope**: Tiered classification heuristic (Tweak / Design Pivot / Scope Change), concrete detection signals, artifact staleness rule, template and workflow instruction updates, AOT recompilation
- **Out of scope**: New workflow actions for re-entry; changing how custom actions work; modifying the spec pipeline ordering; changing the review template format
