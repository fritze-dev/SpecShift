# Research: Explicit Scope Commitment in Plan Mode

## 1. Current State

Plan mode is a Claude Code built-in feature used before invoking `specshift propose`. During plan mode, users discuss what they want to build. Scope decisions — what's in, what's out, non-goals — often emerge during this discussion but aren't formally captured.

The specshift pipeline already has scope-related sections:
- **proposal.md** has `## Scope & Boundaries` (line 98-100 in template)
- **design.md** has `## Non-Goals` section (line 20 in template instruction)

The gap: plan mode discussions happen *before* the pipeline. By the time propose runs, the agent may treat discussed scope decisions as settled without explicit confirmation. The proposal's Scope & Boundaries section captures the *output*, but the *discussion* that led there lacks structure.

**CLAUDE.md** is the correct location for this rule — it's where agent instructions live (per CONSTITUTION.md: "Agent instructions: Project-level agent instructions live in CLAUDE.md"). CLAUDE.md currently has three sections: Workflow, Knowledge Management, File Ownership. None address plan mode behavior.

## 2. External Research

N/A — this is an internal workflow convention, no external dependencies.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Add plan mode section to CLAUDE.md | Right location for agent behavior; directly addresses the friction; consumers inherit it via CLAUDE.md conventions | Only affects this project (not plugin consumers) |
| B: Add to CONSTITUTION.md | Version-controlled convention | Constitution is for code/architecture rules, not agent interaction patterns |
| C: Add to proposal template instruction | Would fire every time propose runs | Too late — the problem is in plan mode, not propose |

**Recommended:** Approach A. CLAUDE.md is the right place for agent instructions about how to conduct plan mode discussions.

## 4. Risks & Constraints

- The instruction must be clear enough that the agent produces a visible scope summary, not just mentions it in passing
- Must not make plan mode overly rigid — the point is to surface decisions, not add bureaucracy
- CLAUDE.md is project-specific — plugin consumers would need to add this to their own CLAUDE.md if they want the same behavior

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Add a plan mode section to CLAUDE.md with scope commitment rule |
| Behavior | Clear | Agent must produce explicit scope/non-goals summary before exiting plan mode |
| Data Model | Clear | No data model changes — plain markdown instruction |
| UX | Clear | User reviews scope summary and commits to it before propose starts |
| Integration | Clear | Feeds into proposal.md Scope & Boundaries section |
| Edge Cases | Clear | What if user skips plan mode entirely → no impact, proposal still has Scope section |
| Constraints | Clear | Must not conflict with existing CLAUDE.md rules |
| Terminology | Clear | "Plan mode" = Claude Code built-in planning feature |
| Non-Functional | Clear | No performance or tooling impact |

## 6. Open Questions

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
