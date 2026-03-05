# ADR-025: Cleanup Step in SKILL.md Deletes Stale Files

## Status

Accepted (2026-03-05)

## Context

The consolidation of docs structure from 3 files to 1 (ADR-024) means that `docs/architecture-overview.md` and `docs/decisions/README.md` become stale after the transition. Consumer projects upgrading to the new plugin version and running `/opsx:docs` would get the new consolidated `docs/README.md` but still have the old files lingering, creating confusion about which file to read.

Two approaches were considered for handling the transition. Manual deletion requires consumers to know which files are stale and remember to delete them -- a fragile process that relies on reading release notes. A cleanup step in SKILL.md automates the transition: the docs generation skill checks for and removes known stale files before generating the new structure.

Research confirmed that the cleanup step is simple to implement (just file existence checks and deletions) and follows the same pattern as the docs skill's existing behavior of fully regenerating all output files. Since docs are already fully regenerated each run, adding a cleanup step for stale files is a natural extension.

The cleanup targets specific known files from the old structure, not arbitrary files, making it safe and predictable.

## Decision

Cleanup step in SKILL.md deletes stale files. Consumer projects need automated migration from old 3-file to new 1-file structure; manual deletion is fragile.

## Rationale

Consumer projects need automated migration from old 3-file to new 1-file structure; manual deletion is fragile.

## Alternatives Considered

- Manual deletion only (rejected: consumers would miss it)
- Migration guide only (rejected: automation is simple)

## Consequences

### Positive

- Consumer projects transition cleanly to the new docs structure without manual intervention
- No stale files create confusion about which documentation to read
- Predictable behavior: only known stale files from the old structure are removed

### Negative

- No significant negative consequences identified.

## References

- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [ADR-024: Consolidated README Replaces 3 Separate Files](adr-024-consolidated-readme-replaces-3-separate-files.md)
