# Research: Enforce Plan-Mode Workflow Routing

## 1. Current State

The `## Planning` section in `CLAUDE.md` (added by PR #28, change `2026-04-14-explicit-plan-scope`) requires plan mode discussions to conclude with an explicit scope summary before exiting. However, it says nothing about *how the plan describes implementation*. A conforming plan can list scope correctly but then propose direct file edits — bypassing the `## Workflow` rule ("All changes MUST go through the spec-driven workflow").

The gap exists because plan mode operates *before* any editing happens, so the Workflow gate ("before editing ANY file, invoke the specshift skill") never fires during planning.

**Affected files:**
- `CLAUDE.md` — project-level agent instructions (Planning section)
- `src/templates/claude.md` — consumer bootstrap template (template-version: 3, identical Planning section)
- `docs/specs/project-init.md` — spec for `specshift init`, contains CLAUDE.md Bootstrap requirement (line 274)

**Prior art:** Change `2026-04-14-explicit-plan-scope` added the scope commitment rule. Change `2026-04-14-fix-specshift-skill-flow` added TRIGGER/DO NOT TRIGGER conditions to the skill description. Both address plan-to-implementation transition gaps but neither closes this specific loophole.

## 2. External Research

N/A — this is an internal instruction/rule change with no external dependencies.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A. Add workflow-routing paragraph to Planning section | Simple, future-proof, follows existing pattern | Behavioral only — no automated enforcement |
| B. Enumerate all actions in the paragraph | Very explicit about which actions to use | Creates duplication with Workflow section, maintenance burden if actions change |
| C. Add structural plan template requirement | Formal enforcement (must have ## Workflow section in plan) | Over-engineered for a behavioral rule, adds ceremony |

**Recommended:** Approach A — add a concise paragraph that references the specshift skill as the implementation method without enumerating all actions. The Workflow section already lists actions; the Planning section just needs to say "route through specshift."

## 4. Risks & Constraints

- **Very low risk**: Single paragraph addition to instruction files
- **Template-version discipline**: Must bump `src/templates/claude.md` from 3 to 4. The compile script enforces this.
- **Consumer impact**: Existing consumer projects will see a WARNING on next `specshift init` if their Planning section is outdated. This is by design (section-level WARNING-only per project-init spec).

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Add workflow-routing rule to Planning section |
| Behavior | Clear | Plans must reference specshift, not direct edits |
| Data Model | Clear | No data model changes — text additions only |
| UX | Clear | No user interaction changes |
| Integration | Clear | Template + spec update, compile script validates |
| Edge Cases | Clear | Trivial plans still flexible ("one-line scope" ethos preserved) |
| Constraints | Clear | Template-version bump required |
| Terminology | Clear | "specshift workflow skill" is established terminology |
| Non-Functional | Clear | No performance, security, or scalability impact |

## 6. Open Questions

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Reference the skill generically, not enumerate actions | Workflow section already lists actions; avoids duplication and maintenance burden | Listing all actions (rejected: staleness risk) |
| 2 | Place rule in CLAUDE.md, not CONSTITUTION.md | Agent instructions belong in CLAUDE.md per constitution convention | CONSTITUTION.md (rejected: wrong file for agent behavior) |
| 3 | Update both CLAUDE.md and src/templates/claude.md | src/ is plugin source for consumers; project CLAUDE.md is this project's instance | Only CLAUDE.md (rejected: consumers wouldn't get the rule) |
