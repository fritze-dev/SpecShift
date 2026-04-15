# Tests: Fix Squash-Merge Commit Messages

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### review-lifecycle

#### Merge Execution with Mandatory Confirmation

- [ ] **Scenario: Squash merge uses clean commit message from proposal**
  - Setup: User has confirmed merge; PR title is "Fix auth timeout", PR number is 42; proposal.md has Why and What Changes sections; proposal.md references issue #31
  - Action: The action merges the PR
  - Verify: Commit title is `Fix auth timeout (#42)`; commit body contains Why section and What Changes bullets; commit body includes `Closes #31`; commit body does NOT contain pipeline commit messages

- [ ] **Edge case: Proposal missing Why or What Changes sections**
  - Setup: Proposal.md exists but has empty Why and/or What Changes sections
  - Action: The action composes the squash commit message
  - Verify: Falls back to PR body as commit message; if PR body also empty, uses PR title only

### artifact-pipeline

#### Post-Artifact Commit and PR Integration

- [ ] **Scenario: First artifact triggers branch and PR creation**
  - Setup: New change workspace with no feature branch; GitHub tooling available
  - Action: Agent finishes creating the first artifact
  - Verify: Agent creates feature branch, commits with `specshift(<change-name>): <artifact-id>` format, pushes, and creates draft PR

- [ ] **Scenario: Subsequent artifacts commit and push only**
  - Setup: Change workspace with existing feature branch and draft PR
  - Action: Agent finishes creating a subsequent artifact
  - Verify: Agent commits with `specshift(<change-name>): <artifact-id>` format and pushes; does NOT create a new PR

#### Post-Implementation Commit Before Approval

- [ ] **Scenario: Implementation committed before user testing**
  - Setup: Change with all implementation tasks complete and Auto-Verify passed
  - Action: Post-apply workflow reaches commit-before-approval step
  - Verify: System commits with message `specshift(<change-name>): implementation`; pushes to remote; PR diff available for review

- [ ] **Scenario: Implementation commit does not replace final commit**
  - Setup: Implementation commit created during post-apply; post-apply completes changelog, docs, version bump
  - Action: Standard Tasks commit step reached
  - Verify: Separate commit created for post-apply changes; implementation commit and final commit are distinct

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 6 |
| Automated tests | 0 |
| Manual test items | 6 |
| Preserved (@manual) | 0 |
| Edge case tests | 1 |
| Warnings | 0 |
