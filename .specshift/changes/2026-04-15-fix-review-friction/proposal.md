<!--
---
status: active
branch: claude/fix-friction-issues-Mq3iy
capabilities:
  new: []
  modified: [review-lifecycle]
  removed: []
---
-->
## Why

Three sequencing bugs in the `specshift review` action cause friction during the PR review-to-merge lifecycle. A dirty working tree leads to incomplete review diffs (#36), merge is offered before a requested review arrives (#36), `auto_approve` skips review dispatch even when `request_review` is configured (#40), and `status: completed` is set after the squash merge creating an extra commit on main (#41).

Closes #36
Closes #40
Closes #41

## What Changes

- Add clean-tree check before review dispatch: verify no uncommitted changes, commit and push if dirty
- Add review-pending gate before merge confirmation: block merge offer while a requested review has no decision
- Fix `auto_approve` instruction wording: use existing `request_review` config as the explicit branch condition instead of vague "no reviews pending or needed"
- Move `status: completed` to before merge: set on feature branch, commit, push, then squash merge (included in squash)

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `review-lifecycle`: Amend "Review Request Dispatch" (clean-tree prerequisite), amend "Merge Execution with Mandatory Confirmation" (review-pending gate, status timing)

### Removed Capabilities

None.

### Consolidation Check

N/A — no new specs proposed. Single existing spec `review-lifecycle` is modified. The `workflow-contract` spec defines the config surface (`review.request_review`, `auto_approve`) but its requirements are unchanged — only the instruction text that references them is fixed.

## Impact

- `docs/specs/review-lifecycle.md` — 2 requirements amended, 2 new scenarios added
- `src/templates/workflow.md` — review action instruction reworded (4 changes)
- `.specshift/WORKFLOW.md` — mirrored instruction changes
- `.claude/skills/specshift/` — regenerated via compilation (finalize)

## Scope & Boundaries

**In scope:**
- Amend spec requirements and scenarios for clean-tree, review-pending gate, status timing
- Fix instruction wording for auto_approve behavior and status timing
- Bump spec version (2 → 3) and template-version (7 → 8)

**Out of scope:**
- auto_approve behavior for non-review actions (propose, apply, finalize) — already correct
- Merge confirmation requirement (always required) — already correct
- New configuration fields — existing `request_review` is sufficient
- Review action structural refactoring — current structure is fine
