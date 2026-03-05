# ADR-042: Add enrichment reads only to Step 4, not all steps

## Status

Accepted (2026-03-05)

## Context

ADR Context sections lost approximately 50% of their depth when `/opsx:docs` regenerated documentation from scratch. The root cause was that Step 4 (ADR generation) only instructed the agent to read the Decisions table from `design.md`, implicitly depending on data loaded during Step 2 (archive enrichment for capability docs). When Step 4 ran in a subagent context without Step 2's loaded data, it lacked the full `design.md` Context section, `research.md` approaches, and `proposal.md` motivation — all essential for writing rich ADR Context sections. Analysis showed that only Step 4 has this implicit dependency problem. Step 3's quality regression (dropped sections) has a different root cause (the priority rule). Rather than restructuring all steps into self-contained subagent instructions (Approach C), adding explicit enrichment reads to Step 4 alone is sufficient. The full per-step restructure remains a documented fallback aligned with the planned autonomous agent transition.

## Decision

Add enrichment reads only to Step 4, not all steps.

## Rationale

Only Step 4 has the implicit dependency problem; Step 3's regression is a different root cause (priority rule). Step independence guardrail covers the general case.

## Alternatives Considered

- Full per-step restructure into self-contained subagent instructions — deferred as future enhancement for autonomous agent readiness, since currently only Step 4 suffers from the implicit dependency

## Consequences

### Positive

- Step 4 independently reads full `design.md` (Context, Architecture, Risks), `research.md`, and `proposal.md` for each archive
- ADR Context sections have consistent depth regardless of execution context (main or subagent)
- Minimal change scope — only Step 4 instructions modified

### Negative

- Other steps are not restructured for full self-containment — if they develop similar subagent issues in the future, the per-step restructure (Approach C) would be needed
- Enrichment reads add minor overhead to Step 4, though this is negligible (reading 2-3 additional markdown files per archive)

## References

- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [ADR-041: Replace priority rule with section-completeness rule](adr-041-replace-priority-rule-with-section-comple.md)
- [ADR-043: Add step independence as a guardrail](adr-043-add-step-independence-as-a-guardrail-not-a.md)
- [GitHub Issue #28](https://github.com/fritze-dev/opsx-enhanced-flow/issues/28)
