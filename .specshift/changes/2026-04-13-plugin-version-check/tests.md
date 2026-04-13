# Tests: Plugin Version Check

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) — plugin is Markdown/YAML artifacts |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### Workflow Contract

#### Router Dispatch Pattern — Version Check

- [ ] **Scenario: Plugin version check — versions match**
  - Setup: WORKFLOW.md contains `plugin-version: 0.1.3-beta`, plugin.json contains `version: 0.1.3-beta`
  - Action: Run `specshift propose`
  - Verify: No version warning displayed, action proceeds normally

- [ ] **Scenario: Plugin version check — mismatch warns and continues**
  - Setup: WORKFLOW.md contains `plugin-version: 0.1.2-beta`, plugin.json contains `version: 0.1.3-beta`
  - Action: Run `specshift propose`
  - Verify: Advisory warning displayed with both versions, action proceeds normally

- [ ] **Scenario: Plugin version check — missing field shows note**
  - Setup: WORKFLOW.md has no `plugin-version` field
  - Action: Run `specshift propose`
  - Verify: Note displayed suggesting `specshift init`, action proceeds normally

- [ ] **Scenario: Plugin version check — skipped for init**
  - Setup: WORKFLOW.md contains `plugin-version: 0.1.2-beta`, plugin.json contains `version: 0.1.3-beta`
  - Action: Run `specshift init`
  - Verify: No version warning displayed, init proceeds normally and updates `plugin-version`

#### Router Dispatch Pattern — Restructured Steps

- [ ] **Scenario: WORKFLOW.md read exactly once in Step 1**
  - Setup: Project with valid WORKFLOW.md
  - Action: Run any `specshift` action
  - Verify: SKILL.md Step 1 loads all frontmatter and body sections; Steps 2-5 reference already-loaded data without re-reading WORKFLOW.md

#### WORKFLOW.md Pipeline Orchestration

- [ ] **Scenario: WORKFLOW.md frontmatter includes plugin-version field**
  - Setup: Inspect `src/templates/workflow.md`
  - Action: Read frontmatter
  - Verify: Contains `plugin-version: ""` and `template-version: 3`

### Project Init

#### Plugin Version Stamp

- [ ] **Scenario: Plugin version stamped on fresh install**
  - Setup: Project without `.specshift/WORKFLOW.md`, plugin.json version `0.1.3-beta`
  - Action: Run `specshift init`
  - Verify: Generated WORKFLOW.md contains `plugin-version: 0.1.3-beta`

- [ ] **Scenario: Plugin version updated on re-init**
  - Setup: WORKFLOW.md with `plugin-version: 0.1.2-beta`, plugin.json version `0.1.3-beta`
  - Action: Run `specshift init`
  - Verify: WORKFLOW.md `plugin-version` updated to `0.1.3-beta`

- [ ] **Scenario: Plugin version added to legacy WORKFLOW.md**
  - Setup: WORKFLOW.md without `plugin-version` field, plugin.json version `0.1.3-beta`
  - Action: Run `specshift init`
  - Verify: WORKFLOW.md has `plugin-version: 0.1.3-beta` added

### Edge Cases

- [ ] **Edge: Plugin manifest unreadable**
  - Setup: Remove or corrupt plugin.json
  - Action: Run `specshift propose`
  - Verify: Version check skipped silently, action proceeds

- [ ] **Edge: Plugin version downgrade**
  - Setup: WORKFLOW.md `plugin-version: 0.2.0`, plugin.json `version: 0.1.3-beta`
  - Action: Run `specshift propose`
  - Verify: Advisory warning displayed (same as upgrade mismatch)

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 11 |
| Automated tests | 0 |
| Manual test items | 11 |
| Preserved (@manual) | 0 |
| Edge case tests | 2 |
| Warnings | 0 |
