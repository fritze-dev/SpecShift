---
id: docs-adr
template-version: 2
description: Architecture Decision Record template
generates: "docs/decisions/adr-*.md"
requires: []
instruction: |
  Generate ADRs from completed changes' design.md Decisions tables.
  Use inline rationale via em-dash in the Decision section.
  Use semantic link text for references.
  Context should be 2-6 sentences. Do not pad short contexts to hit a length —
  if the decision is straightforward, two clear sentences are sufficient.
  Avoid filler restating the decision; Context is for motivation and constraints,
  not for re-asserting what was decided.
  The Consequences section is OPTIONAL for straightforward decisions where
  the positives and negatives are self-evident from Decision and Alternatives.
  Include Consequences only when it adds non-obvious information.
---
# ADR-NNN: [Decision Title]

## Status

Accepted (YYYY-MM-DD)

## Context

<!-- 2-6 sentences. Include:
     - What motivated the decision (the problem being solved)
     - What was investigated or researched
     - Key constraints or trade-offs that shaped the decision
     Enrich with proposal.md "## Discovery" (or legacy research.md) from the
     same change if available.
     Anti-padding: do NOT restate the decision here, do NOT repeat
     alternatives wording, and do NOT pad to hit 4+ sentences if 2 suffice. -->

[Context text]

## Decision

<!-- For consolidated ADRs (multiple sub-decisions):
     Use a numbered list with inline rationale via em-dash:
     1. **Sub-decision text** — rationale explaining why
     2. **Sub-decision text** — rationale explaining why

     For single-decision ADRs:
     **Decision text** — rationale explaining why

     Rationale is always inline. There is no separate Rationale section. -->

[From the Decisions table. Each decision includes its rationale inline via em-dash.]

## Alternatives Considered

- [From the Decisions table "Alternatives" column, expanded into bullet points]

## Consequences

<!-- OPTIONAL section. Omit entirely for straightforward decisions where
     the positives and negatives are self-evident from Decision and
     Alternatives. Include only when there are non-obvious consequences
     worth stating. -->

### Positive

- [Benefits of this decision, derived from rationale, context, and positive outcomes]

### Negative

- [Drawbacks, risks, or trade-offs from design.md "Risks & Trade-offs",
   filtered to relevance for this specific decision where possible.
   If no relevant negative consequences: "No significant negative consequences identified."]

## References

<!-- Use semantic link text that describes what the reference IS, not the file path.
     ALWAYS use proper markdown link syntax: [descriptive text](path).

     CORRECT:
     - [Spec: three-layer-architecture](../../docs/specs/three-layer-architecture.md)
     - [ADR-019: Constitution Convention Only](adr-019-constitution-convention-only.md)
     - [GitHub Issue #21](https://github.com/owner/repo/issues/21)

     WRONG (raw path as link text):
     - [../../docs/specs/three-layer-architecture.md](../../docs/specs/three-layer-architecture.md)
-->

- [Spec: <capability-name>](../../docs/specs/<capability>.md)
- [ADR-NNN: <decision-title>](adr-NNN-slug.md)
- [GitHub Issue #N](https://github.com/owner/repo/issues/N)
