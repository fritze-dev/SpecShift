# ADR-011: ADRs Fully Regenerated Each Run

## Status

Accepted (2026-03-04)

## Context

ADR generation could be incremental (tracking which archives have been processed) or fully regenerated from scratch each time `/opsx:docs` runs. Incremental updates require tracking state across runs.

## Decision

ADRs are fully regenerated on each run — not incremental.

## Rationale

Deterministic, no state to track, numbering always consistent.

## Alternatives Considered

- Incremental updates (requires tracking which archives are processed)

## Consequences

- ADR numbering may shift if archives are added between runs — but since all consumers regenerate, this is a non-issue.
- No state file needed to track previously processed archives.
