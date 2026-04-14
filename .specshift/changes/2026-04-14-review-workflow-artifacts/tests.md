# Tests: Review Workflow Artifacts

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | None (plugin is Markdown/YAML artifacts) |
| Test directory | N/A |
| File pattern | N/A |

## Manual Test Plan

### Three-Layer Architecture

#### Layer Separation

- [ ] **Scenario: Constitution does not duplicate workflow instruction details**
  - Setup: WORKFLOW.md propose instruction defines checkpoint behavior (line 40: "pause after design for user alignment")
  - Action: Inspect `.specshift/CONSTITUTION.md`
  - Verify: No convention restating the same checkpoint rule exists; operational details live exclusively in WORKFLOW.md action instructions

- [ ] **Scenario: Consumer workflow template does not contain project-specific steps**
  - Setup: Consumer template is `src/templates/workflow.md`
  - Action: Inspect all action instructions in the file
  - Verify: No references to `scripts/compile-skills.sh` or other project-specific scripts/paths; project-specific steps exist only in `.specshift/WORKFLOW.md`

### Workflow Contract

#### Inline Action Definitions

- [ ] **Scenario: Action instructions describe intra-action behavior only**
  - Setup: Read `src/templates/workflow.md` and `.specshift/WORKFLOW.md` action instructions
  - Action: Search for inter-action dispatch language ("auto-continue to apply", "auto-continue to finalize", "auto-dispatch")
  - Verify: 0 occurrences found; cross-action dispatch is defined only in SKILL.md (lines 72, 79)

### Artifact Fix Verification

#### Preflight reference removal

- [ ] **Scenario: init.md does not reference Preflight Quality Check**
  - Setup: Run `bash scripts/compile-skills.sh` to regenerate compiled artifacts
  - Action: Read `.claude/skills/specshift/actions/init.md`
  - Verify: No reference to "Preflight Quality Check" or `quality-gates.md#requirement-preflight-quality-check`

#### Version-bump delegation

- [ ] **Scenario: Project WORKFLOW.md delegates version-bump to Constitution**
  - Setup: Read `.specshift/WORKFLOW.md` finalize action
  - Action: Inspect step 3
  - Verify: Text says "if the constitution defines a version-bump convention, follow it; otherwise skip" (not hardcoded file paths)

#### Compilation

- [ ] **Scenario: compile-skills.sh succeeds after all changes**
  - Setup: All 5 fixes applied
  - Action: Run `bash scripts/compile-skills.sh`
  - Verify: Exit code 0; compiled workflow.md has template-version 4

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 6 |
| Automated tests | 0 |
| Manual test items | 6 |
| Preserved (@manual) | 0 |
| Edge case tests | 0 |
| Warnings | 0 |
