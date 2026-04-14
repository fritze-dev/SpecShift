## Review: Add Release Action

### Summary

| Dimension | Status |
|-----------|--------|
| Tasks | 4/4 complete (implementation tasks) |
| Requirements | 6/6 verified |
| Scenarios | 7/7 covered |
| Tests | 11/11 defined (manual) |
| Scope | Clean — all changed files trace to tasks |

### Dimension Details

**1. Task Completion**: 4/4 implementation tasks complete (1.1, 1.2, 2.1, 2.2).

**2. Task-Diff Mapping**:
- Task 1.1 (consumer template) → `src/templates/workflow.md`: template-version 4→5, `release` in actions array, `release:` config block, `## Action: release` section. ✓
- Task 1.2 (project WORKFLOW) → `.specshift/WORKFLOW.md`: `release` in actions array, `release: { request_review: copilot }`, `## Action: release` section. ✓
- Task 2.1 (router auto-dispatch) → `src/skills/specshift/SKILL.md`: conditional finalize→release auto-dispatch line added in finalize section. ✓
- Task 2.2 (compilation) → `.claude/skills/specshift/SKILL.md` and `.claude/skills/specshift/templates/workflow.md`: compiled output contains all changes. ✓

**3. Requirement Verification** (from `docs/specs/workflow-contract.md`):
- Release Action Configuration requirement: `release` config block in both templates with `request_review` field. ✓
- Auto-dispatch scenario updated: finalize→release when auto_approve and release in actions. ✓
- Skip scenario: conditional on actions array membership. ✓
- Always user confirmation: instruction text says "ask user for explicit merge confirmation". ✓
- Re-entrant: instruction says "Re-entrant: can be run in any session" and describes state-reading pattern. ✓
- WORKFLOW.md frontmatter field added to spec. ✓

**4. Scenario Coverage**:
- request_review false: consumer template default is `false`. ✓
- request_review copilot: project instance uses `copilot`. ✓
- request_review true: documented in consumer template comments. ✓
- Always user confirmation: instruction text explicit. ✓
- Re-entrant: instruction describes GitHub state reading. ✓
- Auto-dispatch: SKILL.md conditional added. ✓
- Skip dispatch: conditional checks actions array. ✓

**5. Design Adherence**:
- Custom action (not built-in) — instruction in WORKFLOW.md, no compiled requirements. ✓
- Re-entrant state machine reading PR state from GitHub. ✓
- `request_review` config in frontmatter with tool-agnostic values. ✓
- Default `request_review: false`. ✓
- Always user confirmation for merge. ✓

**6. Scope Control**: All changed files trace to tasks:
- `src/templates/workflow.md` → Task 1.1
- `.specshift/WORKFLOW.md` → Task 1.2
- `src/skills/specshift/SKILL.md` → Task 2.1
- `.claude/skills/specshift/SKILL.md` → Task 2.2 (compilation output)
- `.claude/skills/specshift/templates/workflow.md` → Task 2.2 (compilation output)
- `docs/specs/workflow-contract.md` → Specs stage (proposal capability: modified workflow-contract)
- `.specshift/changes/2026-04-14-add-release-action/*` → Pipeline artifacts

No untraced files.

**7. Preflight Side-Effects**: Consumer template version bump (4→5) addressed — `specshift init` will prompt consumers. No other side effects. ✓

**8. Test Coverage**: 11 manual test scenarios defined in tests.md covering all spec scenarios plus 4 edge cases. No automated test framework (plugin is Markdown/YAML). ✓

### Findings

#### CRITICAL

(none)

#### WARNING

(none)

#### SUGGESTION

(none)

### Verdict

**PASS**
