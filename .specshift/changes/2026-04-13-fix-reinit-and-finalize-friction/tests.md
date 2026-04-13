# Tests: fix-reinit-and-finalize-friction

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### project-init

#### Template Merge on Re-Init

- [ ] **Scenario: CLAUDE.md skipped when already exists but checked for missing sections**
  - Setup: Project with existing CLAUDE.md containing all standard sections (`## Workflow`, `## Knowledge Management`)
  - Action: Run `specshift init`
  - Verify: CLAUDE.md is NOT overwritten; report includes "all standard sections present"

- [ ] **Scenario: CLAUDE.md missing standard section detected on re-init**
  - Setup: Project with existing CLAUDE.md that has `## Workflow` but lacks `## Knowledge Management`
  - Action: Run `specshift init`
  - Verify: CLAUDE.md is NOT modified; WARNING reports "CLAUDE.md missing standard section: Knowledge Management"; suggestion to add section manually

### release-workflow

#### Auto Patch Version Bump — Edge Cases

- [ ] **Edge Case: Consumer project without plugin.json**
  - Setup: Consumer project without `src/.claude-plugin/plugin.json`
  - Action: Run `specshift finalize`
  - Verify: Version-bump step is silently skipped; no error or warning

- [ ] **Edge Case: Non-semver version field**
  - Setup: `plugin.json` with version field containing non-semver value
  - Action: Run `specshift finalize`
  - Verify: System warns and skips the bump

### Workflow & Constitution Consistency

- [ ] **Verify: WORKFLOW.md finalize instruction is conditional**
  - Setup: Read `src/templates/workflow.md` and `.specshift/WORKFLOW.md`
  - Action: Check finalize step 3
  - Verify: Both contain conditional "if src/.claude-plugin/plugin.json exists" phrasing

- [ ] **Verify: CONSTITUTION.md version-bump convention has skip clause**
  - Setup: Read `.specshift/CONSTITUTION.md`
  - Action: Check post-apply version bump convention
  - Verify: Contains "consumer projects" skip clause

- [ ] **Verify: Template sync direction corrected**
  - Setup: Read `.specshift/CONSTITUTION.md`
  - Action: Check template synchronization convention
  - Verify: States `src/templates/` is authoritative; direction is `src/templates/` → `.specshift/`

- [ ] **Verify: CLAUDE.md has File Ownership section**
  - Setup: Read `CLAUDE.md`
  - Action: Check for File Ownership or equivalent section
  - Verify: Section documents `src/` vs `.specshift/` vs `docs/` distinction

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 8 |
| Automated tests | 0 |
| Manual test items | 8 |
| Preserved (@manual) | 0 |
| Edge case tests | 2 |
| Warnings | 0 |
