# Tests: Review Comment Acknowledgment

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### Constitution Convention

- [ ] **Verify: Convention text present**
  - Setup: Open `.specshift/CONSTITUTION.md`
  - Action: Locate `## Conventions` section
  - Verify: A "Review comment acknowledgment" convention exists covering reply, resolve, and both reviewer types

- [ ] **Verify: Pre-Merge checkbox present**
  - Setup: Open `.specshift/CONSTITUTION.md`
  - Action: Locate `## Standard Tasks > ### Pre-Merge`
  - Verify: A checkbox for replying to and resolving PR review comments exists

### Template Path Fix

- [ ] **Verify: SKILL.md template path corrected**
  - Setup: Open `src/skills/specshift/SKILL.md`
  - Action: Locate propose pipeline traversal instruction (line 64)
  - Verify: Path reads `<templates_dir>/changes/<id>.md` instead of `<templates_dir>/<id>.md`

- [ ] **Verify: Compiled skill matches source**
  - Setup: Run `bash scripts/compile-skills.sh`
  - Action: Compare `.claude/skills/specshift/SKILL.md` line 64 with source
  - Verify: Compiled version contains the corrected path

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 4 |
| Automated tests | 0 |
| Manual test items | 4 |
| Preserved (@manual) | 0 |
| Edge case tests | 0 |
| Warnings | 0 |
