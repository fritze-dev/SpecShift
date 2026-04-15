# Tests: fix-review-friction

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### review-lifecycle

#### Review Request Dispatch

- [ ] **Scenario: Uncommitted changes committed before review dispatch**
  - Setup: Working tree has uncommitted changes after finalize (e.g., compiled plugin.json version sync)
  - Action: Run `specshift review` — action reaches review dispatch phase
  - Verify: Uncommitted changes are committed and pushed before requesting external review

#### Merge Execution with Mandatory Confirmation

- [ ] **Scenario: Merge after user confirmation with passing CI**
  - Setup: No unresolved review threads, all CI checks pass, no requested review pending without a decision
  - Action: Action asks for merge confirmation, user confirms
  - Verify: Action sets proposal `status` to `completed`, commits, and pushes BEFORE merging the PR via squash; post-merge cleanup triggers

- [ ] **Scenario: Review pending blocks merge offer**
  - Setup: Review requested from Copilot, review not yet submitted (no decision), CI checks passing
  - Action: Action checks merge readiness
  - Verify: Reports "Review pending — waiting for reviewer decision", does NOT offer merge confirmation, suggests re-running later

### Edge Cases (review-lifecycle)

- [ ] **Edge: Reviewer requests changes but leaves no inline comments**
  - Setup: Reviewer submits "changes-requested" review with no inline comments
  - Action: Action checks review state
  - Verify: Reports the review status and asks the user how to proceed (existing edge case — verify no regression from new review-pending gate)

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 3 (new) + 1 (edge case regression check) |
| Automated tests | 0 |
| Manual test items | 4 |
| Preserved (@manual) | 0 |
| Edge case tests | 1 |
| Warnings | 0 |
