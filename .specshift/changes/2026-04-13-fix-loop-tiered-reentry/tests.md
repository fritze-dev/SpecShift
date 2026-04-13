# Tests: Fix Loop Tiered Re-entry

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### Human Approval Gate

#### Fix Loop — Tiered Re-entry

- [ ] **Scenario: Classify correction as Tweak — fix in place**
  - Setup: A review correction changes a wrong value in an already-edited file (e.g., wrong version string, missing newline). The approach and affected files remain the same.
  - Action: The system classifies the correction and applies the fix.
  - Verify: Classification is identified as Tier 1 — Tweak. The value is fixed in place. `review.md` is regenerated after the fix. No design.md or tasks.md changes are made.

- [ ] **Scenario: Classify correction as Design Pivot — update design and re-implement**
  - Setup: A review correction points out the wrong file was edited (e.g., `CONSTITUTION.md` changed instead of `src/templates/constitution.md`). Requirements are still correct, only the implementation target changed.
  - Action: The system checks detection signals and classifies the correction.
  - Verify: At least one detection signal fires ("correction touches files outside those listed in design.md"). Classification is Tier 2 — Design Pivot. `design.md` Architecture & Components is updated with the correct file targets. Affected task sections in `tasks.md` are discarded and re-generated. Re-implementation uses the corrected design. `review.md` is regenerated after re-implementation.

- [ ] **Scenario: Design Pivot updates all stale artifacts**
  - Setup: A Design Pivot correction has occurred. The existing `review.md` shows PASS against the original (wrong) approach.
  - Action: The system applies the Tier 2 re-entry.
  - Verify: `design.md` is updated to reflect the corrected approach. Affected sections of `tasks.md` are updated (old tasks removed, corrected tasks added). `review.md` is deleted before re-implementing. A new `review.md` is generated from the corrected implementation. No stale artifacts remain in the change directory.

- [ ] **Scenario: Fix code to resolve critical issue (existing)**
  - Setup: Verification report with CRITICAL issue "Requirement not found: Session Timeout".
  - Action: Developer implements session timeout logic and regenerates `review.md`.
  - Verify: New report no longer lists the session timeout issue as CRITICAL. Completeness dimension reflects the additional requirement coverage.

- [ ] **Scenario: Update spec to resolve warning (existing)**
  - Setup: Verification report with WARNING about auth using session cookies when spec requires JWT. Developer intentionally chose session cookies.
  - Action: Developer updates spec to reflect session cookie authentication and regenerates `review.md`.
  - Verify: New report no longer lists the divergence warning. Spec accurately reflects the implementation.

- [ ] **Scenario: Multiple fix-verify iterations (existing)**
  - Setup: First verification finds 3 CRITICAL and 2 WARNING issues.
  - Action: Developer fixes all 3 CRITICAL issues and regenerates `review.md`.
  - Verify: Second report shows 0 CRITICAL issues. Same or new warnings may appear. Developer may approve with acknowledged warnings.

#### Fix Loop — Edge Cases

- [ ] **Scenario: Ambiguous tier classification defaults to Design Pivot**
  - Setup: A correction is ambiguous — cannot clearly determine Tier 1 vs. Tier 2.
  - Action: System applies the "ambiguous → higher tier" rule.
  - Verify: System classifies as Design Pivot (Tier 2). Artifacts are updated accordingly. No stale artifacts remain.

- [ ] **Scenario: Tier 3 Scope Change mid-implementation**
  - Setup: A Scope Change is identified after partial implementation. Some completed tasks conflict with the new scope.
  - Action: System applies Tier 3 re-entry.
  - Verify: Spec is updated first. Design and tasks are re-generated. Partial work conflicting with new scope is reverted before re-implementation.

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 8 |
| Automated tests | 0 |
| Manual test items | 8 |
| Preserved (@manual) | 0 |
| Edge case tests | 2 |
| Warnings | 0 |
