# Research: Fix Review Action Friction

## 1. Current State

The review action (`specshift review`) is defined in three layers:
- **Spec**: `docs/specs/review-lifecycle.md` (v2) — 7 requirements, 28 scenarios
- **Instruction (plugin template)**: `src/templates/workflow.md` lines 86-103 — `## Action: review` section
- **Instruction (project instance)**: `.specshift/WORKFLOW.md` lines 85-102 — mirrors template with project-specific overrides

Three friction issues (#36, #40, #41) filed after PR #39 review. All affect the review action's sequencing in the same instruction section.

**Affected requirements:**
- "Review Request Dispatch" (review-lifecycle.md line 64) — no clean-tree prerequisite
- "Merge Execution with Mandatory Confirmation" (review-lifecycle.md line 182) — no review-pending gate, status set after merge

**Affected instruction lines:**
- `src/templates/workflow.md` line 93 (review dispatch — no clean-tree check)
- `src/templates/workflow.md` line 100-101 (merge confirmation/execution — no pending gate, status timing)
- `src/templates/workflow.md` line 102 (auto_approve — vague "no reviews pending or needed" wording)

## 2. External Research

N/A — all changes are internal to the spec and instruction text.

## 3. Approaches

Single approach: amend the existing spec requirements and instruction text. No structural changes needed.

| Approach | Pro | Contra |
|----------|-----|--------|
| Amend existing spec + instruction | Minimal change, fixes root cause, no new config | None identified |

## 4. Risks & Constraints

- **Self-referential change**: The review action instruction is modified while review will be used to merge this change. This is actually desirable — the fix validates itself.
- **Template sync**: `src/templates/workflow.md` and `.specshift/WORKFLOW.md` must stay in sync (per constitution). The project instance has intentional differences (worktree detail, skill reference phrasing) that must be preserved.
- **Compilation enforcement**: `template-version` must be bumped from 7 to 8 or `scripts/compile-skills.sh` will fail.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 3 issues, 3 files, well-defined fixes |
| Behavior | Clear | Issues describe exact current vs expected behavior |
| Data Model | Clear | No data model changes — text amendments only |
| UX | Clear | No UI changes |
| Integration | Clear | Compilation regenerates compiled actions automatically |
| Edge Cases | Clear | Scenarios cover pending review, clean tree, status timing |
| Constraints | Clear | Template-version bump required, sync discipline |
| Terminology | Clear | Existing terminology (auto_approve, request_review, status) |
| Non-Functional | Clear | No performance or security implications |

All categories Clear — no open questions.

## 6. Open Questions

N/A — all Clear.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Amend existing requirements, no new requirements | All fixes modify behavior within existing requirement scope | Adding new standalone requirements would fragment the spec |
| 2 | No new configuration | Existing `request_review` config is sufficient as the branch condition for auto_approve behavior | Adding a separate `skip_review_on_auto_approve` flag would add unnecessary complexity |
