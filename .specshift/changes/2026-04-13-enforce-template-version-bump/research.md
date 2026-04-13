# Research: Enforce Template-Version Bump

## 1. Current State

**template-version field**: Defined in `workflow-contract.md` (line 53) as part of the Smart Template Format requirement: "template-version (integer, monotonically increasing — bumped when the plugin changes the template content)." It enables `specshift init` merge detection (see `project-init.md` lines 74-134).

**Where template-version exists**: Every Smart Template in `src/templates/` has a `template-version` field in YAML frontmatter. Current values range from 1 to 2. Files with `template-version: 2` include `workflow.md` and `changes/tasks.md` (modified in PR #16 without bumping).

**How it's consumed**: The `init` action (`actions/init.md` lines 44-102) compares plugin vs. local template-version to decide whether to update, skip, or merge-prompt. If the version isn't bumped, consumer projects never see the update.

**What's missing (per issue #17)**:
1. No SHALL-statement requiring version bump when template content changes
2. No action instruction that checks for unbumped versions
3. No review dimension validating template-version freshness

**Design origin**: The `2026-04-08-spec-frontmatter-tracking` change explicitly accepted "plugin maintainers will remember to bump template-version" as an assumption. PR #16 proved this assumption invalid — the review flow did not catch it.

## 2. External Research

N/A — this is an internal workflow enforcement concern. No external APIs or libraries involved.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Add review dimension to preflight | Catches it before tasks/implementation; fits existing quality gate structure | Only runs during propose, not during apply or finalize; relies on convention-based enforcement |
| B: Add verify check in review.md | Catches it at the end of implementation; can compare git diff to template-version | Late in the cycle — ideally caught earlier; still convention-based |
| C: Add SHALL-statement + review dimension + finalize check | Comprehensive: requirement + preflight catch + finalize safety net | Touches multiple specs (workflow-contract + quality-gates); slightly more artifacts to update |
| D: Hard enforcement via git hook or CI script | Fully automated, can't be bypassed | Contradicts project's convention-based enforcement philosophy (ADR-004, ADR-006, ADR-015); requires shell scripting infrastructure |

**Recommendation**: Approach C — add the requirement to `workflow-contract.md`, add a preflight dimension to catch it early, and add a finalize check as a safety net. This stays within the project's convention-based enforcement philosophy while closing the gap at multiple points.

## 4. Risks & Constraints

- **Convention-based only**: The project explicitly avoids hard validation scripts (per ADR-004, ADR-006, ADR-015). Enforcement relies on the AI agent reading and following instructions. This is acceptable — the gap was not that convention-based enforcement can't work, but that no convention existed at all.
- **Scope**: Changes touch `workflow-contract.md` (new SHALL-statement) and `quality-gates.md` (new preflight dimension). Both are existing specs — no new capability needed.
- **Template-version detection**: The agent must compare the git diff against template-version fields. This is straightforward — read YAML frontmatter, check if content changed but version didn't.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Add requirement + preflight dimension + finalize check for template-version bump enforcement |
| Behavior | Clear | When src/templates/ content changes, template-version SHALL be incremented; preflight and finalize SHALL validate this |
| Data Model | Clear | No new data fields — uses existing template-version integer in YAML frontmatter |
| UX | Clear | Surfaces as preflight finding (BLOCKED if unbumped) and finalize check |
| Integration | Clear | Fits into existing preflight dimensions and finalize workflow |
| Edge Cases | Clear | New template (no previous version), template-version field missing (treated as 0), non-content changes (whitespace only) |
| Constraints | Clear | Convention-based enforcement only; no scripts or CI |
| Terminology | Clear | "template-version" is already well-defined in workflow-contract.md |
| Non-Functional | Clear | No performance or scalability concerns |

## 6. Open Questions

All categories are Clear — no questions needed.

## 7. Decisions

N/A — no user feedback required.
