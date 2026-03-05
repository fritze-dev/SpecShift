# ADR-016: Research Context Integrated into ADR Context Section

## Status

Accepted (2026-03-04)

## Context

Each archived change includes a research.md file documenting approaches investigated, decisions made, and open questions. When generating ADRs from design.md decisions tables, the question was where to incorporate this research context. Two options were considered: integrating research findings into the ADR Context section, or creating a separate research log output in `docs/research/`.

The standard ADR format (as popularized by Michael Nygard) uses the Context section to explain "what is the issue that is motivating this decision or change." Research findings -- approaches evaluated, constraints discovered, external research conducted -- are precisely this contextual information. Putting them in a separate research log would fragment the narrative: a reader would need to cross-reference the ADR with a separate document to understand why a decision was made.

Research into ADR best practices confirmed that Context sections should include the forces at play, including the technological, political, and project context. The research.md Approaches section maps directly to this: it documents what was investigated and why certain approaches were favored or rejected. Integrating this information produces richer, more self-contained ADRs.

A separate `docs/research/` output would create more files with less focused content, since research context is only meaningful in relation to specific decisions.

## Decision

Research context integrated into ADR Context section. One place for "why did we decide this?", avoids separate research log.

## Rationale

One place for "why did we decide this?", avoids separate research log.

## Alternatives Considered

- Separate `docs/research/` output (more files, less focused)

## Consequences

### Positive

- ADRs are self-contained: readers find all relevant context in one place
- Research findings are preserved in a meaningful location rather than a separate, potentially ignored directory
- Richer Context sections improve ADR quality and usefulness for onboarding

### Negative

- No significant negative consequences identified.

## References

- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [ADR-015: ADRs Fully Regenerated Each Run](adr-015-adrs-fully-regenerated-each-run.md)
