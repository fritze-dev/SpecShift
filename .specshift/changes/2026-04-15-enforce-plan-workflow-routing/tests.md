# Tests: enforce-plan-workflow-routing

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### Project Init

#### CLAUDE.md Bootstrap

- [ ] **Scenario: CLAUDE.md generated on fresh init (updated)**
  - Setup: A project without a `CLAUDE.md` file; plugin has bootstrap template at `${CLAUDE_PLUGIN_ROOT}/templates/claude.md`
  - Action: Run `specshift init`
  - Verify: Generated `CLAUDE.md` contains a `## Planning` section that includes both the scope commitment rule and the workflow-routing rule

- [ ] **Scenario: Plan describes specshift workflow routing (conforming)**
  - Setup: A project with the updated CLAUDE.md containing the workflow-routing rule
  - Action: User creates a plan in plan mode that says "implementation via `specshift propose` -> `specshift apply` -> `specshift finalize`"
  - Verify: The plan is conforming — it routes implementation through specshift

- [ ] **Scenario: Plan describes direct file edits (non-conforming)**
  - Setup: A project with the updated CLAUDE.md containing the workflow-routing rule
  - Action: User creates a plan in plan mode that says "edit src/foo.ts to add the feature"
  - Verify: The plan is non-conforming — it describes direct file edits without invoking specshift

- [ ] **Scenario: Trivial plan references specshift minimally**
  - Setup: A project with the updated CLAUDE.md
  - Action: User creates a one-line plan: "Route through `specshift propose`"
  - Verify: The plan is conforming — it references the specshift skill as the implementation method

- [ ] **Scenario: Template-version bumped correctly**
  - Setup: `src/templates/claude.md` has been updated with the new paragraph
  - Action: Run `bash scripts/compile-skills.sh`
  - Verify: Compilation succeeds (template-version was bumped from 3 to 4)

- [ ] **Scenario: Template-version NOT bumped (compilation failure)**
  - Setup: `src/templates/claude.md` modified but template-version left at 3
  - Action: Run `bash scripts/compile-skills.sh`
  - Verify: Compilation fails with a template-version validation error

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 6 |
| Automated tests | 0 |
| Manual test items | 6 |
| Preserved (@manual) | 0 |
| Edge case tests | 2 |
| Warnings | 0 |
