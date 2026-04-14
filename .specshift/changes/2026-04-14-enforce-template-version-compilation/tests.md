# Tests: enforce-template-version-compilation

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### Compilation Script Enforcement

#### Template-version validation

- [ ] **Scenario: Modified template without version bump fails compilation**
  - Setup: On a feature branch, modify content in `src/templates/changes/research.md` without changing `template-version`
  - Action: Run `bash scripts/compile-skills.sh`
  - Verify: Script exits with error naming the unbumped file

- [ ] **Scenario: Modified template with version bump passes compilation**
  - Setup: On a feature branch, modify content in `src/templates/changes/research.md` AND increment `template-version`
  - Action: Run `bash scripts/compile-skills.sh`
  - Verify: Script completes successfully with "All modified templates have bumped versions"

- [ ] **Scenario: No modified templates passes compilation**
  - Setup: On a feature branch with no changes to `src/templates/`
  - Action: Run `bash scripts/compile-skills.sh`
  - Verify: Script completes successfully (zero templates to check)

- [ ] **Scenario: Compilation on main branch is a no-op**
  - Setup: Switch to `main` branch
  - Action: Run `bash scripts/compile-skills.sh`
  - Verify: Template-version check reports "All modified templates have bumped versions" (zero diff)

- [ ] **Scenario: No main branch available skips check**
  - Setup: In a repo without a `main` or `origin/main` branch
  - Action: Run `bash scripts/compile-skills.sh`
  - Verify: Script prints "Skipping template-version check" and continues normally

- [ ] **Scenario: New template file passes check**
  - Setup: On a feature branch, add a new template file under `src/templates/` with `template-version: 1`
  - Action: Run `bash scripts/compile-skills.sh`
  - Verify: Script passes (new file naturally has `+template-version:` in diff)

- [ ] **Scenario: Deleted template file is skipped**
  - Setup: On a feature branch, delete a template file from `src/templates/`
  - Action: Run `bash scripts/compile-skills.sh`
  - Verify: Script does not fail on the deleted file

### Constitution Convention

- [ ] **Scenario: Convention is documented**
  - Setup: Read `.specshift/CONSTITUTION.md`
  - Verify: A "Template-version discipline" convention exists describing the enforcement rule

### Workflow Finalize Instruction

- [ ] **Scenario: Finalize instruction mentions enforcement**
  - Setup: Read `.specshift/WORKFLOW.md` finalize instruction
  - Verify: Instruction text mentions template-version enforcement during compilation

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 9 |
| Automated tests | 0 |
| Manual test items | 9 |
| Preserved (@manual) | 0 |
| Edge case tests | 3 (new file, deleted file, no main branch) |
| Warnings | 0 |
