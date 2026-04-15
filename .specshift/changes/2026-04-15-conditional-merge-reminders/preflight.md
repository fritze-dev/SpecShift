# Pre-Flight Check: Conditional Post-Merge Reminders

## A. Traceability Matrix

- [x] Conditional post-merge filtering → Scenario: "Conditional post-merge item excluded by scope" (task-implementation.md) → `src/templates/changes/tasks.md` instruction
- [x] Conditional post-merge inclusion → Scenario: "Conditional post-merge item included by scope" (task-implementation.md) → `src/templates/changes/tasks.md` instruction
- [x] Scope-aware Standard Tasks Directive → Requirement update in artifact-pipeline.md → `src/templates/changes/tasks.md` instruction
- [x] Constitution scope hint → `.specshift/CONSTITUTION.md` post-merge item
- [x] Consumer template example → `src/templates/constitution.md` post-merge comment

## B. Gap Analysis

No gaps identified. The change is instruction-text-only — no code paths, no error handling needed. Edge case (ambiguous scope) is covered by "err on inclusion" policy documented in the spec.

## C. Side-Effect Analysis

- **Consumer projects**: Template-version bump (tasks.md 3→4, constitution.md 1→2) will trigger merge prompts when consumers run `specshift init` in update mode. Low risk — the changes are to instruction text and example comments only.
- **Existing changes in progress**: Generated tasks.md files in active changes are unaffected — the template instruction only applies during new task generation.

## D. Constitution Check

No new patterns introduced. The scope hint is a natural-language annotation within existing constitution structure — no new sections or conventions needed.

## E. Duplication & Consistency

- The post-merge filtering behavior is mentioned in both `task-implementation.md` (requirement + scenarios) and `artifact-pipeline.md` (directive). This mirrors the existing pattern where both specs reference post-merge behavior. No contradiction.

## F. Assumption Audit

1. `proposal-context-availability` (design.md): "The proposal.md is available as context when the tasks artifact is generated." — **Acceptable Risk**. The tasks template `requires: [tests]` which transitively requires proposal. Verified by pipeline dependency chain.
2. `llm-scope-evaluation` (design.md): "Constitution post-merge items are human-readable enough for the LLM to evaluate scope relevance." — **Acceptable Risk**. The items are already natural language. Scope hints add minimal complexity.

## G. Review Marker Audit

No REVIEW markers found in any change artifacts or modified spec files.

**Verdict: PASS**
