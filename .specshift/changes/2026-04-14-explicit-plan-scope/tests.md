# Tests: explicit-plan-scope

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### CLAUDE.md Agent Instructions

#### Planning Section Presence

- [ ] **Scenario: CLAUDE.md contains Planning section**
  - Setup: Read CLAUDE.md after implementation
  - Action: Search for `## Planning` section
  - Verify: Section exists between Workflow and Knowledge Management

#### Scope Summary Requirement

- [ ] **Scenario: Instruction requires explicit scope summary**
  - Setup: Read the Planning section content
  - Action: Check instruction text
  - Verify: Instruction mentions producing a scope summary with in-scope, out-of-scope, and non-goals

#### User Confirmation Requirement

- [ ] **Scenario: Instruction requires user confirmation before proceeding**
  - Setup: Read the Planning section content
  - Action: Check instruction text
  - Verify: Instruction requires the user to review and confirm the scope before exiting plan mode

#### Minimal Scope for Trivial Changes

- [ ] **Scenario: Instruction allows minimal summaries**
  - Setup: Read the Planning section content
  - Action: Check for flexibility language
  - Verify: Instruction does not mandate heavy process for small changes

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 4 |
| Automated tests | 0 |
| Manual test items | 4 |
| Preserved (@manual) | 0 |
| Edge case tests | 0 |
| Warnings | 0 |
