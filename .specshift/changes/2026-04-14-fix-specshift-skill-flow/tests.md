# Tests: fix-specshift-skill-flow

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) — plugin is Markdown/YAML artifacts, no executable tests |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### three-layer-architecture

#### Proactive Skill Invocation

- [ ] **Scenario: Skill triggers proactively on implementation request**
  - Setup: A project with the specshift plugin installed. A user exits plan mode.
  - Action: User says "implement this"
  - Verify: The AI invokes the specshift skill (propose or apply depending on change context) instead of editing files directly

- [ ] **Scenario: Skill does not trigger on read-only activities**
  - Setup: A project with the specshift plugin installed
  - Action: User asks "how does the pipeline work?" or "read the CONSTITUTION.md"
  - Verify: The AI does NOT invoke the specshift skill and handles the request directly

- [ ] **Scenario: CLAUDE.md enforces workflow for all file types**
  - Setup: A project with the generated CLAUDE.md from the plugin template
  - Action: Inspect the CLAUDE.md workflow section
  - Verify: It instructs the AI to invoke the specshift skill before editing ANY file (source code, specs, skills, templates, docs, or configuration)

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 3 |
| Automated tests | 0 |
| Manual test items | 3 |
| Preserved (@manual) | 0 |
| Edge case tests | 0 |
| Warnings | 0 |
