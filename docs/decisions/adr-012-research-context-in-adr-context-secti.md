# ADR-012: Research Context Integrated into ADR Context Section

## Status

Accepted (2026-03-04)

## Context

Research data (approaches investigated, findings, open questions) provides valuable context for understanding decisions. This data could be placed in a separate research log or integrated into the ADR Context section alongside design context.

## Decision

Research context integrated into ADR Context section — one place for "why did we decide this?"

## Rationale

Avoids a separate research log. Each ADR contains all relevant context — design context plus research findings — in one place.

## Alternatives Considered

- Separate `docs/research/` output (more files, less focused)

## Consequences

- ADR Context sections are richer with research findings.
- No separate research log to maintain.
- Research data is associated directly with the decisions it informed.
