# Research: Review Workflow Artifacts

## 1. Current State

The SpecShift plugin uses a three-layer architecture (Constitution → WORKFLOW.md + Smart Templates → Router/SKILL.md + Actions). A review of the actual artifact contents revealed 5 issues: 3 bugs and 2 DRY violations that breach the Layer Separation requirement from `three-layer-architecture.md`.

**Key files involved:**
- `.specshift/CONSTITUTION.md` — project governance (Layer 1)
- `.specshift/WORKFLOW.md` — project workflow instance (Layer 2)
- `src/templates/workflow.md` — consumer workflow template (Layer 2 source)
- `src/skills/specshift/SKILL.md` — router (Layer 3)
- `src/actions/init.md` — init action requirements (Layer 3)

## 2. External Research

No external research needed — this is an internal artifact consistency review.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| Fix all 5 issues in one change | Clean separation achieved in one pass, no partial fixes | Touches 5 files across all 3 layers |
| Fix only the 3 bugs, defer overlaps | Smaller scope, less risk | Leaves DRY violations that will drift |

**Recommended:** Fix all 5 — the changes are small (line deletions/edits) and the overlaps are clear-cut violations of the Layer Separation requirement.

## 4. Risks & Constraints

- **Template-version discipline**: Changing `src/templates/workflow.md` requires bumping `template-version` (3 → 4). Compilation enforces this.
- **Compilation required**: After changing `src/actions/init.md` and `src/templates/workflow.md`, `bash scripts/compile-skills.sh` must regenerate the release directory.
- **Behavioral risk**: Removing auto-dispatch language from WORKFLOW.md instructions — the SKILL.md already handles this (lines 72, 79), so no behavioral change. Verified: the `workflow-contract.md` spec (Scenario: Router auto-dispatches) defines this as router behavior.
- **Constitution convention removal**: Removing the design checkpoint convention — the rule remains in WORKFLOW.md propose instruction (line 40), so no behavioral loss.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 5 specific issues, all identified with file:line references |
| Behavior | Clear | No behavioral changes — only removing redundant expressions of existing rules |
| Data Model | Clear | No data model changes (YAML frontmatter structure unchanged) |
| UX | Clear | No user-facing changes |
| Integration | Clear | Compilation pipeline validates consistency |
| Edge Cases | Clear | Consumer template loses compile step (was always failing for consumers anyway) |
| Constraints | Clear | Template-version bump + compilation required |
| Terminology | Clear | No terminology changes |
| Non-Functional | Clear | No performance or scalability impact |
