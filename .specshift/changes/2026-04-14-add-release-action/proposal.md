---
status: completed
branch: claude/automate-pr-review-merge-E3KOL
capabilities:
  new: [release-lifecycle]
  modified: [workflow-contract, three-layer-architecture, release-workflow]
  removed: []
---
## Why

After `specshift finalize`, the PR is ready (code, docs, changelog, version) but review handling and merge happen manually. This adds a `release` action that automates the PR review-to-merge lifecycle — processing review comments, running self-review, and merging with user confirmation. The action is formalized as a built-in action with a dedicated spec and compiled requirements, consistent with the other 4 built-in actions.

## What Changes

- Add `release` built-in action with dedicated spec (`docs/specs/release-lifecycle.md`) defining 6 formal requirements
- Add `src/actions/release.md` requirement links for AOT compilation
- Add `release` action definition in WORKFLOW.md (consumer template + project instance)
- Add `release` configuration block to WORKFLOW.md frontmatter (`request_review: false | copilot | true`)
- Add `release` built-in dispatch section in router (`src/skills/specshift/SKILL.md`)
- Add conditional `finalize → release` auto-dispatch in router
- Update "4 built-in actions" → "5 built-in actions" across all specs

## Capabilities

### New Capabilities

- `release-lifecycle`: Defines the `specshift release` action behavior — a re-entrant PR state machine that reads GitHub PR state, manages draft-to-ready transition, processes review comments, runs self-review, and executes merge with mandatory user confirmation. The spec has 6 requirements covering: PR state assessment, draft-to-ready transition, review request dispatch, review comment processing, safety limits, and merge execution.

### Modified Capabilities

- `workflow-contract`: Add `release` configuration block to WORKFLOW.md frontmatter, update "4 built-in actions" to "5 built-in actions" in Inline Action Definitions and Router Dispatch Pattern requirements, add release to router fallback list.
- `three-layer-architecture`: Update "4 built-in actions" to "5 built-in actions" in Router + Actions Layer requirement.
- `release-workflow`: Update compilation scope from "4 built-in actions" to "5 built-in actions".

### Removed Capabilities

None.

### Consolidation Check

Existing specs reviewed: artifact-pipeline, change-workspace, constitution-management, documentation, human-approval-gate, project-init, quality-gates, release-workflow, roadmap-tracking, spec-format, task-implementation, test-generation, three-layer-architecture, workflow-contract.

- `release-lifecycle` (new) covers PR state machine behavior. No existing spec covers this domain. `workflow-contract` covers config surface only. `release-workflow` covers versioning/packaging. `change-workspace` covers worktree cleanup (cross-referenced, not duplicated).
- The new spec will have 6 requirements with 19 scenarios — well above the 3+ requirement minimum.
- Cross-references: `release-lifecycle` references `workflow-contract` for config and `change-workspace` for post-merge cleanup.

## Impact

- **`docs/specs/release-lifecycle.md`** (new): 6 requirements, ~280 lines
- **`src/actions/release.md`** (new): 8 requirement links (6 from release-lifecycle, 1 from workflow-contract, 1 from change-workspace)
- **`src/skills/specshift/SKILL.md`**: New `### release` built-in dispatch section, updated custom action fallback
- **`docs/specs/workflow-contract.md`**: "4 built-in" → "5 built-in" at 3 locations
- **`docs/specs/three-layer-architecture.md`**: "4 built-in" → "5 built-in"
- **`docs/specs/release-workflow.md`**: Compilation scope updated
- **Consumer projects**: `specshift init` detects template-version bump. Compilation now produces 5 action files.

## Scope & Boundaries

**In scope:**
- New spec `release-lifecycle.md` with 6 formal requirements
- `src/actions/release.md` requirement links for compilation
- Router built-in dispatch for release
- Spec counter updates ("4 built-in" → "5 built-in")
- Compilation producing `actions/release.md`

**Out of scope:**
- Changes to CONSTITUTION.md
- GitHub Actions or CI/CD integration
- WORKFLOW.md instruction text changes (already correct from previous iteration)
- Consumer template changes (already correct from previous iteration)
