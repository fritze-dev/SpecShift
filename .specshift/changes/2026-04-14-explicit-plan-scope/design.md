---
has_decisions: true
---
# Technical Design: Explicit Plan-Mode Scope Commitment

## Context

When users enter plan mode (Claude Code built-in) to discuss a change before invoking `specshift propose`, scope decisions emerge naturally in conversation but aren't formally captured. The proposal template already has a `## Scope & Boundaries` section and the design template has `## Non-Goals`, but these capture the *result* — the *agreement* during planning is implicit. Users then encounter scope assumptions in the design that they never consciously committed to.

CLAUDE.md currently has three sections (Workflow, Knowledge Management, File Ownership). It does not address plan mode behavior.

## Architecture & Components

Single file affected: `CLAUDE.md` (project root).

Add a new `## Planning` section that instructs the agent to produce an explicit scope summary before exiting plan mode. This summary feeds directly into the proposal's Scope & Boundaries section.

## Goals & Success Metrics

- PASS/FAIL: CLAUDE.md contains a `## Planning` section with scope commitment instructions
- PASS/FAIL: The instruction requires a visible scope summary (in-scope, out-of-scope, non-goals) before exiting plan mode
- PASS/FAIL: The instruction requires user confirmation of the scope before proceeding

## Non-Goals

- Modifying the proposal or design Smart Templates (they already have scope sections)
- Adding this instruction to the plugin consumer template (project-specific)
- Automated enforcement or tooling changes
- Changing the specshift pipeline or skill behavior

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Add to CLAUDE.md, not CONSTITUTION.md | Agent instructions belong in CLAUDE.md per constitution convention ("Agent instructions: Project-level agent instructions live in CLAUDE.md") | CONSTITUTION.md — but that's for code/architecture rules, not agent interaction patterns |
| Place section between Workflow and Knowledge Management | Planning happens before workflow execution, so it logically follows the Workflow section | At the end — but it would be easy to miss |
| Require explicit scope summary, not just "discuss scope" | The friction is that scope *is discussed* but not *captured* — a visible summary forces commitment | Softer language — but that's what we have now (implicit), which causes the problem |

## Risks & Trade-offs

- [Overhead for trivial changes] → The instruction should allow the agent to keep the summary minimal for small changes. The point is explicitness, not bureaucracy.
- [Users skip plan mode] → No impact — proposal template still has Scope & Boundaries as a fallback.

## Open Questions

No open questions.

## Assumptions

- Plan mode is the primary entry point for non-trivial changes in this project. <!-- ASSUMPTION: plan mode usage -->
