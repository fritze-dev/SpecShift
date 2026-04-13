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

#### Constitution Generation — Version-Bump Detection

- [ ] **Scenario: Consumer project with package.json**
  - Setup: Consumer project with `package.json` containing a version field
  - Action: Run `specshift init`
  - Verify: Generated CONSTITUTION.md Conventions section includes a version-bump convention referencing `package.json`

- [ ] **Scenario: Consumer project without version files**
  - Setup: Consumer project with no version files (no package.json, pyproject.toml, etc.)
  - Action: Run `specshift init`
  - Verify: Generated CONSTITUTION.md Conventions section does NOT include a version-bump convention

#### Consumer Finalize — Constitution-Driven Version-Bump

- [ ] **Scenario: Consumer project with version-bump convention**
  - Setup: Consumer project whose CONSTITUTION.md defines a version-bump convention
  - Action: Run `specshift finalize`
  - Verify: Version-bump step follows the convention from the constitution

- [ ] **Scenario: Consumer project without version-bump convention**
  - Setup: Consumer project whose CONSTITUTION.md has no version-bump convention
  - Action: Run `specshift finalize`
  - Verify: Version-bump step is silently skipped; no error or warning

### Template & Convention Consistency

- [ ] **Verify: Consumer workflow template finalize is constitution-driven**
  - Setup: Read `src/templates/workflow.md`
  - Action: Check finalize step 3
  - Verify: Contains "if the constitution defines a version-bump convention, follow it; otherwise skip"

- [ ] **Verify: Consumer constitution template has version-bump detection**
  - Setup: Read `src/templates/constitution.md`
  - Action: Check frontmatter instruction and Conventions section
  - Verify: Frontmatter includes version-bump detection instructions; Conventions section mentions version-bump convention

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
| Total scenarios | 10 |
| Automated tests | 0 |
| Manual test items | 10 |
| Preserved (@manual) | 0 |
| Edge case tests | 2 |
| Warnings | 0 |
