# Tests: Conditional Post-Merge Reminders

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### Task Implementation

#### Standard Tasks Exclusion from Apply Scope

- [ ] **Scenario: Conditional post-merge item excluded by scope**
  - Setup: Constitution has a Post-Merge item with scope hint indicating it applies when plugin files change. Proposal scope states only docs/ files are in scope.
  - Action: Generate the tasks artifact via `specshift propose`
  - Verify: The Post-Merge Reminders section is omitted from the generated tasks.md. The conditional item does not appear.

- [ ] **Scenario: Conditional post-merge item included by scope**
  - Setup: Constitution has a Post-Merge item with scope hint indicating it applies when src/ files change. Proposal lists modifications to files under src/.
  - Action: Generate the tasks artifact via `specshift propose`
  - Verify: The Post-Merge Reminders section includes the item as a plain bullet. The scope hint is stripped from the output.

### Artifact Pipeline

#### Standard Tasks Directive in Task Generation

- [ ] **Scenario: Post-merge items without scope hints always included**
  - Setup: Constitution has a Post-Merge item with no scope hint. Proposal scope is docs-only.
  - Action: Generate the tasks artifact via `specshift propose`
  - Verify: The Post-Merge Reminders section includes the item unconditionally.

### Edge Cases

- [ ] **Edge: Ambiguous proposal scope with scoped post-merge item**
  - Setup: Constitution has a Post-Merge item with scope hint. Proposal scope is ambiguous about whether plugin files are affected.
  - Action: Generate the tasks artifact
  - Verify: The item is included (err on inclusion).

- [ ] **Edge: All post-merge items filtered out**
  - Setup: Constitution has only scoped post-merge items, none matching the proposal scope.
  - Action: Generate the tasks artifact
  - Verify: Section 5 (Post-Merge Reminders) is omitted entirely.

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 5 |
| Automated tests | 0 |
| Manual test items | 5 |
| Preserved (@manual) | 0 |
| Edge case tests | 2 |
| Warnings | 0 |
