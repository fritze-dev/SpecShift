# Research: Conditional Post-Merge Reminders

## 1. Current State

The tasks.md Smart Template (`src/templates/changes/tasks.md`, lines 39-44) instructs the generating agent to unconditionally copy all post-merge items from the constitution's `### Post-Merge` subsection into section 5 of every generated tasks.md. The constitution (`.specshift/CONSTITUTION.md`, line 67) defines one post-merge item: "Update plugin locally".

This means every change — even docs-only or constitution-only changes — gets the "Update plugin locally" reminder, which is only relevant when plugin-distributed files (`src/`, `.claude/skills/`) are modified.

**Affected files:**
- `src/templates/changes/tasks.md` — template instruction (lines 39-44)
- `.specshift/CONSTITUTION.md` — post-merge item (line 67)
- `src/templates/constitution.md` — consumer template example (lines 50-51)
- `docs/specs/task-implementation.md` — spec for standard tasks (line 102)
- `docs/specs/artifact-pipeline.md` — Standard Tasks Directive (line 207)

## 2. External Research

N/A — this is an internal workflow improvement.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| Scope-aware filtering in template instruction | Simple, no new syntax, LLM evaluates relevance naturally from proposal context | LLM judgment may vary between invocations |
| Formal `when:` annotation syntax | Explicit, machine-parseable | Over-engineered for an LLM-driven system, adds documentation/spec burden |
| Hardcode path checks in template | Deterministic | SpecShift-specific, breaks generalizability for consumer projects |

**Recommended: Scope-aware filtering** — update the template instruction to tell the agent to evaluate each post-merge item's relevance against the proposal scope. Constitution items can include a natural-language scope hint. No formal syntax needed.

## 4. Risks & Constraints

- **LLM interpretation variance**: The agent might occasionally include or exclude an item incorrectly. Mitigated by erring on inclusion when ambiguous (status quo is 100% inclusion).
- **Backward compatibility**: Constitutions without scope hints must behave identically to today. The instruction must default to inclusion for un-annotated items.
- **Template-version discipline**: Modified `src/templates/` files require `template-version` bumps.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Update template instruction and constitution |
| Behavior | Clear | Filter post-merge items by relevance to proposal scope |
| Data Model | Clear | No structural changes — just instruction text and constitution wording |
| UX | Clear | Fewer irrelevant reminders in tasks.md |
| Integration | Clear | Proposal.md already available as context during task generation |
| Edge Cases | Clear | Ambiguous scope → include; no scope hint → include |
| Constraints | Clear | Template-version bumps required |
| Terminology | Clear | "scope hint" = natural-language note about when an item applies |
| Non-Functional | Clear | No performance impact |

## 6. Open Questions

All Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use scope-aware filtering via template instruction update | Simple, generalizable, leverages existing LLM capabilities | Formal `when:` syntax (over-engineered), hardcoded paths (not generalizable) |
| 2 | Err on inclusion when scope is ambiguous | Status quo is always-include; false negatives are worse than false positives | Err on exclusion (could miss important reminders) |
