# Tests: Codex Plugin Support

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | none |
| Test directory | none |
| File pattern | none |

## Manual Test Plan

### Release Workflow

#### Codex release compilation

- [x] **Scenario: Compiler builds Codex plugin release**
  - Setup: Repository contains `src/.codex-plugin/plugin.json` and `src/codex/templates/agents.md`.
  - Action: Run `bash scripts/compile-skills.sh`.
  - Verify: `.codex-plugin/plugin.json`, `skills/specshift/SKILL.md`, templates, and action files exist.

- [x] **Scenario: Claude release still compiles**
  - Setup: Existing Claude source files remain under `src/`.
  - Action: Run `bash scripts/compile-skills.sh`.
  - Verify: `.claude/.claude-plugin/plugin.json` and `.claude/skills/specshift/actions/*.md` are regenerated.

- [x] **Scenario: Codex generated output has no stale Claude-only paths**
  - Setup: Compiler has generated `.codex-plugin/` and `skills/specshift/`.
  - Action: Scan generated Codex files.
  - Verify: No `CLAUDE.md`, `${CLAUDE_PLUGIN_ROOT}`, or `.claude/worktrees` references remain in Codex runtime files.

#### Root plugin metadata

- [x] **Scenario: Codex root manifest points to generated skills**
  - Setup: `.codex-plugin/plugin.json` exists.
  - Action: Parse manifest JSON.
  - Verify: The generated manifest uses `skills: ./skills/` and `skills/specshift/SKILL.md` exists.

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 4 |
| Automated tests | 0 |
| Manual test items | 4 |
| Preserved (@manual) | 0 |
| Edge case tests | 1 |
| Warnings | 0 |
