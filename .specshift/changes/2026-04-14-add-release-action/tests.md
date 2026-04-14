# Tests: Add Release Action

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) — plugin is Markdown/YAML artifacts, no executable tests |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### Workflow Contract

#### Release Action Configuration

- [ ] **Scenario: Release configuration with request_review false (default)**
  - Setup: WORKFLOW.md contains `release: { request_review: false }` and `release` is in the `actions` array
  - Action: Run `specshift release`
  - Verify: PR is marked ready for review, body updated, no reviewer requested, existing review comments are processed

- [ ] **Scenario: Release configuration with request_review copilot**
  - Setup: WORKFLOW.md contains `release: { request_review: copilot }`
  - Action: Run `specshift release`
  - Verify: Copilot review is requested using available GitHub tooling; if request fails, warning is logged and action continues

- [ ] **Scenario: Release configuration with request_review true**
  - Setup: WORKFLOW.md contains `release: { request_review: true }`
  - Action: Run `specshift release`
  - Verify: Review is requested from repository's default reviewers

- [ ] **Scenario: Release action always requires user confirmation for merge**
  - Setup: `auto_approve: true`, PR is approved, all checks passing
  - Action: Release action reaches merge phase
  - Verify: Action pauses and asks user for explicit confirmation; only merges after user confirms

- [ ] **Scenario: Release action is re-entrant across sessions**
  - Setup: Release action started in previous session, session ended with comments partially processed
  - Action: Run `specshift release` in new session
  - Verify: Action reads current PR state from GitHub and continues from current state

#### Router Auto-Dispatch

- [ ] **Scenario: Router auto-dispatches propose→apply→finalize→release when auto_approve is true**
  - Setup: `auto_approve: true`, `actions: [init, propose, apply, finalize, release]`
  - Action: Run `specshift propose`
  - Verify: Full chain executes through release; release pauses at merge confirmation

- [ ] **Scenario: Router skips release auto-dispatch when release not in actions**
  - Setup: `auto_approve: true`, `actions: [init, propose, apply, finalize]` (no release)
  - Action: Finalize completes successfully
  - Verify: Router stops after finalize, does not attempt release dispatch

### Edge Cases

- [ ] **Scenario: No PR exists for branch**
  - Setup: Branch has no associated PR
  - Action: Run `specshift release`
  - Verify: Error reported, finalize suggested

- [ ] **Scenario: Review tool unavailable**
  - Setup: `request_review: copilot`, but Copilot unavailable
  - Action: Run `specshift release`
  - Verify: Warning logged, action continues without review request

- [ ] **Scenario: PR already merged**
  - Setup: PR for the branch is already merged
  - Action: Run `specshift release`
  - Verify: Worktree cleanup performed, merge skipped

- [ ] **Scenario: Review cycle exceeds safety limit**
  - Setup: Reviewer posts new comments after 3 fix cycles
  - Action: Release action processes fourth cycle
  - Verify: Action pauses, reports cycle limit reached

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 11 |
| Automated tests | 0 |
| Manual test items | 11 |
| Preserved (@manual) | 0 |
| Edge case tests | 4 |
| Warnings | 0 |
