# Tests: enforce-template-version-bump

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### Workflow Contract

#### Template-Version Bump Discipline

- [ ] **Scenario: Template content change requires version bump**
  - Setup: Smart Template `src/templates/changes/tasks.md` with `template-version: 2`
  - Action: Modify the template's content (instruction text, section structure, or markdown body)
  - Verify: `template-version` is incremented to 3 before the change is merged

- [ ] **Scenario: Whitespace-only change does not require version bump**
  - Setup: Smart Template `src/templates/workflow.md` with `template-version: 2`
  - Action: Make only whitespace changes (trailing spaces, blank lines) without altering meaningful content
  - Verify: `template-version` field is NOT required to change

- [ ] **Scenario: Multiple templates changed in one PR**
  - Setup: Change modifies content in both `src/templates/changes/tasks.md` (version 2) and `src/templates/changes/design.md` (version 1)
  - Action: Prepare the change for merge
  - Verify: `tasks.md` has `template-version: 3` and `design.md` has `template-version: 2`

- [ ] **Scenario: New template file gets initial version**
  - Setup: New Smart Template file created at `src/templates/changes/new-artifact.md`
  - Action: Add the template to the plugin
  - Verify: File has `template-version: 1` in YAML frontmatter

### Quality Gates

#### Preflight Quality Check — Dimension H

- [ ] **Scenario: Preflight detects unbumped template-version**
  - Setup: Change modifies content of `src/templates/changes/tasks.md`; `template-version` field has NOT been incremented from base branch value
  - Action: Invoke `specshift propose`
  - Verify: Template-Version Freshness dimension flags the file as BLOCKED with message indicating content changed but template-version not incremented; recommends incrementing the field

- [ ] **Scenario: Preflight passes when template-version is bumped**
  - Setup: Change modifies content in `src/templates/changes/tasks.md`; `template-version` has been incremented (e.g., 2 to 3)
  - Action: Invoke `specshift propose`
  - Verify: Template-Version Freshness dimension reports no issues for this file

- [ ] **Scenario: Preflight skips template-version check when no templates changed**
  - Setup: Change does not modify any files under `src/templates/`
  - Action: Invoke `specshift propose`
  - Verify: Template-Version Freshness dimension reports "No template changes detected — skipped"

#### Finalize Template-Version Validation

- [ ] **Scenario: Finalize detects unbumped template-version**
  - Setup: Change modified `src/templates/changes/tasks.md` content; `template-version` was not incremented
  - Action: Invoke `specshift finalize`
  - Verify: System reports the unbumped template-version; stops before running skill compilation; requests maintainer to increment the version

- [ ] **Scenario: Finalize passes when all template-versions are bumped**
  - Setup: Change modified `src/templates/changes/tasks.md` and incremented its `template-version`
  - Action: Invoke `specshift finalize`
  - Verify: Template-version validation passes; finalize proceeds to skill compilation

- [ ] **Scenario: Finalize skips check when no templates modified**
  - Setup: Change did not modify any files under `src/templates/`
  - Action: Invoke `specshift finalize`
  - Verify: Template-version validation is skipped silently

### Edge Cases

- [ ] **Edge: Template-version field missing from modified template**
  - Setup: Modified template under `src/templates/` has no `template-version` field
  - Action: Run preflight or finalize
  - Verify: Flagged as BLOCKED — field is required by Smart Template Format requirement

- [ ] **Edge: No merge base for template-version comparison**
  - Setup: No merge base available (orphan branch, detached HEAD)
  - Action: Run preflight or finalize
  - Verify: Template-version check is skipped with note "No merge base available — template-version check skipped"

- [ ] **Edge: Template file renamed or moved**
  - Setup: Existing template is renamed or moved from an old path to a new path under `src/templates/`
  - Action: Run preflight
  - Verify: Renamed/moved template is compared against the base-branch file at the previous path; `template-version` is carried forward and must be incremented if the template content changed

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 13 |
| Automated tests | 0 |
| Manual test items | 13 |
| Preserved (@manual) | 0 |
| Edge case tests | 3 |
| Warnings | 0 |
