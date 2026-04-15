# Tests: Post PR Summary Comment

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) — plugin is Markdown/YAML artifacts, no executable tests |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### review-lifecycle

#### Pre-Merge Summary Comment

- [ ] **Scenario: Summary comment posted before merge confirmation**
  - Setup: Review action has processed 4 review threads and resolved all of them, implemented 3 fixes across 2 review cycles, self-check passed with no findings
  - Action: No unresolved comments remain and CI checks are passing
  - Verify: Action posts a PR comment containing the summary; comment includes "4 threads resolved, 3 fixes applied, self-check passed"; action proceeds to ask the user for merge confirmation

- [ ] **Scenario: Summary posted with zero counts when no review comments existed**
  - Setup: PR received no review comments; CI checks are passing
  - Action: Review action reaches the pre-merge phase
  - Verify: Action posts a summary comment with "0 threads resolved, 0 fixes applied, self-check passed"; proceeds to merge confirmation

- [ ] **Scenario: Summary comment failure does not block merge**
  - Setup: Review action has completed processing; posting the PR comment fails due to a tooling error
  - Action: Action attempts to post the summary
  - Verify: Logs a warning with the failure reason; continues to ask the user for merge confirmation

- [ ] **Scenario: Re-entrant invocation updates existing summary instead of duplicating**
  - Setup: Previous session posted a summary comment with "2 threads resolved, 2 fixes applied"; new review cycle resolved 1 additional thread with 1 fix
  - Action: Review action reaches the pre-merge phase in the new session
  - Verify: Detects existing summary comment by its marker; updates to cumulative totals "3 threads resolved, 3 fixes applied"; does NOT post a second summary comment

#### Edge Cases

- [ ] **Edge case: Summary comment permissions denied**
  - Setup: GitHub token lacks permission to post comments
  - Action: Review action attempts to post summary
  - Verify: Logs a warning and proceeds to merge confirmation without the summary

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 4 |
| Automated tests | 0 |
| Manual test items | 5 |
| Preserved (@manual) | 0 |
| Edge case tests | 1 |
| Warnings | 0 |
