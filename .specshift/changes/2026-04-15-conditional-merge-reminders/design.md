<!--
has_decisions: true
-->
# Technical Design: Conditional Post-Merge Reminders

## Context

Post-merge reminders in tasks.md are always included unconditionally. The tasks.md Smart Template instruction (lines 39-44) tells the generating agent to copy all post-merge items from the constitution without checking relevance. This creates noise for changes that don't affect plugin-distributed files.

The proposal.md is already available as transitive context during task generation (tasks requires tests, which transitively requires proposal). The proposal's "What Changes" and "Scope & Boundaries" sections describe what the change affects — the agent can use this to evaluate relevance.

## Architecture & Components

**Files modified:**

1. `src/templates/changes/tasks.md` — Update instruction text (lines 39-44) to add scope-aware filtering logic for post-merge items. Bump template-version 3→4.
2. `.specshift/CONSTITUTION.md` — Add a scope hint to the post-merge item (line 67) describing when it applies.
3. `src/templates/constitution.md` — Update the example comment (lines 50-51) to show scope-aware post-merge items. Bump template-version 1→2.

**Interaction:** During `specshift propose`, the agent reads the tasks template instruction, reads the constitution's post-merge items (with scope hints), reads the proposal's scope, and decides which items to include. No new files or modules.

## Goals & Success Metrics

* The tasks.md template instruction references proposal scope when deciding which post-merge items to include — PASS/FAIL by inspecting instruction text.
* The project constitution's plugin update item has a scope hint — PASS/FAIL by inspecting `.specshift/CONSTITUTION.md`.
* The consumer constitution template example shows scope-aware post-merge items — PASS/FAIL by inspecting `src/templates/constitution.md`.
* `bash scripts/compile-skills.sh` succeeds after template changes — PASS/FAIL by exit code.

## Non-Goals

- Formal annotation syntax (e.g., `when:` clauses) — natural language is sufficient for this LLM-driven system
- Conditional logic for pre-merge standard tasks — not requested
- Changes to apply or finalize phases — filtering happens at generation time only

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Natural-language scope hints in constitution items | LLM-driven system — the generating agent reads and evaluates natural language natively. No parsing infrastructure needed. | Formal `when:` syntax (adds documentation burden, over-engineers for LLM context), hardcoded path checks (SpecShift-specific, not generalizable) |
| Err on inclusion when scope is ambiguous | Status quo is 100% inclusion; false negatives (missing a needed reminder) are worse than false positives (showing an unnecessary one) | Err on exclusion (could miss important reminders) |
| Scope hints are optional — items without hints always included | Full backward compatibility with existing constitutions | Require all items to have hints (breaking change for consumers) |

## Risks & Trade-offs

- **LLM interpretation variance**: Different invocations may evaluate scope hints differently for edge cases. → Mitigated by "err on inclusion" default. Status quo is always-include, so any filtering is an improvement.
- **Template-version bump triggers consumer merge prompt**: Consumers running `specshift init` in update mode will see the new template version. → Low impact: the change is to instruction text and example comments only.

## Open Questions

No open questions.

## Assumptions

- The proposal.md is available as context when the tasks artifact is generated. <!-- ASSUMPTION: proposal-context-availability -->
- Constitution post-merge items are human-readable enough for the LLM to evaluate scope relevance. <!-- ASSUMPTION: llm-scope-evaluation -->
