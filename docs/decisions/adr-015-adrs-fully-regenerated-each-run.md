# ADR-015: ADRs Fully Regenerated Each Run

## Status

Accepted (2026-03-04)

## Context

Architecture Decision Records are generated from the Decisions tables in design.md files across all archived changes. The question was whether to generate ADRs incrementally (only processing new or changed archives) or to fully regenerate all ADRs on every `/opsx:docs` run.

Incremental updates would require tracking which archives have been processed and detecting changes to previously processed archives. This state tracking adds complexity: a metadata file or index would need to be maintained, and edge cases around archive modifications or deletions would need handling. Additionally, ADR numbering would become unstable if archives were reordered or deleted.

Full regeneration avoids all of these problems. Since ADRs are derived deterministically from a chronological sort of archives and their design.md decisions tables, every run produces identical output for identical input. There is no state to track, numbering is always consistent, and the operation is fast because it only involves reading markdown files and writing markdown files.

Research confirmed that the number of archives and decisions tables is small enough that full regeneration completes in seconds. The standard ADR convention uses sequential numbering, which is naturally maintained by processing archives in chronological order.

## Decision

ADRs fully regenerated each run. Deterministic, no state to track, numbering always consistent.

## Rationale

Deterministic, no state to track, numbering always consistent.

## Alternatives Considered

- Incremental updates (requires tracking which archives are processed)

## Consequences

### Positive

- Deterministic output: same input always produces same ADR set
- No state or metadata files to maintain between runs
- ADR numbering is always consistent with the chronological archive order

### Negative

- ADR numbering instability if archives are reordered, though this does not happen in practice since archive directory names include dates.

## References

- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
