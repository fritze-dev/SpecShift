# Research: Review Comment Acknowledgment Convention

## 1. Current State

The project constitution (`.specshift/CONSTITUTION.md`) defines conventions and standard tasks that govern agent behavior during the specshift workflow. Currently:

- **Conventions** section has 13 rules covering commits, versions, plugin layout, templates, README accuracy, friction capture, knowledge transparency, etc.
- **Standard Tasks** has Pre-Merge (1 checkbox: update PR) and Post-Merge (1 reminder: update plugin locally).
- **No convention exists** for responding to or resolving GitHub PR review comments after fixes are pushed.

Code review is outside the specshift pipeline (propose → apply → finalize). PR subscription and review responses happen ad-hoc in conversation.

## 2. External Research

N/A — this is a project convention, not a technical integration.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| Constitution convention + Pre-Merge checkbox | Simple, immediately actionable, covers both behavioral rule and checklist enforcement | None significant — lightweight and appropriate for the scope |
| Workflow action (e.g., `respond`) | More structured, could automate detection | Over-engineered for current needs; code review is outside the pipeline |
| CLAUDE.md instruction | Quick to add | Wrong location — project knowledge belongs in constitution per knowledge transparency convention |

## 4. Risks & Constraints

- No technical risk — this is a documentation/convention change only
- The convention must be tool-agnostic per existing convention #13 (no hardcoded CLI tools)
- CONSTITUTION.md is edited directly per File Ownership rules in CLAUDE.md

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Add convention + standard task checkbox |
| Behavior | Clear | Reply to comments, resolve threads |
| Data Model | Clear | No data model — text artifacts only |
| UX | Clear | No user-facing UI changes |
| Integration | Clear | GitHub PR comments (tool-agnostic) |
| Edge Cases | Clear | Covers both human and automated reviewer comments |
| Constraints | Clear | Must be tool-agnostic |
| Terminology | Clear | "review comment acknowledgment" |
| Non-Functional | Clear | N/A |

## 6. Open Questions

All categories are Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Constitution convention + Pre-Merge checkbox | Simplest approach; code review is outside pipeline, so workflow integration is premature | Workflow action, CLAUDE.md instruction |
| 2 | Apply to both human and automated reviewer comments | Both types of review comments deserve acknowledgment | Human-only |
