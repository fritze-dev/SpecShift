# Tests: AOT Prompt Compilation

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### release-workflow

#### AOT Skill Compilation

- [ ] **Scenario: Finalize triggers AOT compilation**
  - Setup: A completed change with review.md verdict PASS
  - Action: `specshift finalize` executes the compilation step
  - Verify: Compiled action files exist at `.claude/skills/specshift/actions/{propose,apply,finalize,init}.md`; SKILL.md and templates/ copied to `.claude/skills/specshift/`

- [ ] **Scenario: Compiled file includes provenance frontmatter**
  - Setup: Compilation step runs with plugin version from `src/.claude-plugin/plugin.json`
  - Action: Inspect a compiled action file
  - Verify: YAML frontmatter contains `compiled-at` (ISO 8601), `specshift-version` (matches plugin.json), `sources` (list of spec file paths)

- [ ] **Scenario: Count validation detects missing requirements**
  - Setup: SKILL.md lists 8 requirement links for propose; one references a non-existent spec file
  - Action: Run `bash scripts/compile-skills.sh`
  - Verify: 7 requirements extracted; warning naming the unresolvable link; compilation continues

#### Compiled Action File Contract

- [ ] **Scenario: Compiled action file contains instruction and requirements**
  - Setup: Compiled action file at `.claude/skills/specshift/actions/propose.md`
  - Action: Inspect content
  - Verify: Has YAML frontmatter with `compiled-at`, `specshift-version`, `sources`; has `## Instruction` section; has `## Requirements` with `### Requirement:` blocks matching SKILL.md link count

- [ ] **Scenario: Compiled file with no requirement links**
  - Setup: A built-in action with no requirement links in SKILL.md
  - Action: Run compilation
  - Verify: Compiled file has `## Instruction` only, no `## Requirements` section

#### Dev Sync Script

- [ ] **Scenario: Dev script builds complete release directory**
  - Setup: Repository root with `src/`, `docs/specs/`, `.specshift/WORKFLOW.md`
  - Action: `bash scripts/compile-skills.sh`
  - Verify: `.claude/skills/specshift/` contains SKILL.md, templates/, actions/{propose,apply,finalize,init}.md; summary printed

- [ ] **Scenario: Dev script uses no external runtimes**
  - Setup: Machine with bash, no Node.js/Python
  - Action: `bash scripts/compile-skills.sh`
  - Verify: Completes successfully

- [ ] **Scenario: Dev script run outside repo root**
  - Setup: Run from a directory without `src/skills/specshift/SKILL.md`
  - Action: `bash scripts/compile-skills.sh`
  - Verify: Exits with error message

### workflow-contract

#### Inline Action Definitions

- [ ] **Scenario: Router executes built-in action via compiled action file**
  - Setup: User invokes `specshift apply`
  - Action: Router processes the command
  - Verify: Router reads `actions/apply.md` from skill directory; spawns sub-agent with instruction + requirements from compiled file

#### Router Dispatch Pattern

- [ ] **Scenario: Router dispatches apply via compiled action file**
  - Setup: User invokes `specshift apply`; compiled file `actions/apply.md` exists
  - Action: Router detects change and reads compiled file
  - Verify: Sub-agent receives pre-extracted instruction + requirement blocks

### Edge Cases

- [ ] **Compiled file has no requirements section** (workflow-contract)
  - Setup: Compiled file with instruction only
  - Action: Router reads the file
  - Verify: Router proceeds with instruction only

- [ ] **AOT compilation when WORKFLOW.md instruction is missing** (release-workflow)
  - Setup: WORKFLOW.md has no `## Action: finalize` section
  - Action: Run compilation
  - Verify: Action skipped with warning

- [ ] **Stale compiled files** (release-workflow)
  - Setup: Edit a spec, do NOT recompile
  - Action: Run `specshift propose`
  - Verify: Router uses outdated compiled file (expected — dev must recompile)

- [ ] **`.gitignore` whitelist** (release-workflow)
  - Setup: `.gitignore` has `/.claude/*` and `!/.claude/skills/`
  - Action: `git status`
  - Verify: `.claude/skills/specshift/` files are tracked

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 14 |
| Automated tests | 0 |
| Manual test items | 14 |
| Preserved (@manual) | 0 |
| Edge case tests | 4 |
| Warnings | 0 |
