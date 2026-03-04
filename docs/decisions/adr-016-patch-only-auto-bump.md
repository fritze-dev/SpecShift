# ADR-016: Patch-Only Auto-Bump

## Status

Accepted (2026-03-04)

## Context

Plugin consumers can't detect updates because `/plugin update` requires a version bump. Automating version bumps needed a strategy — auto-detect from changelog (complex), prompt for bump type (manual step), or always bump patch.

## Decision

Patch-only auto-bump on archive. 95%+ of changes are patches; minor/major are rare and intentional.

## Rationale

95%+ of changes are patches; minor/major are rare and intentional. Auto-detect from changelog is complex and unreliable.

## Alternatives Considered

- Auto-detect from changelog (complex, unreliable)

## Consequences

- Version inflation — each archive creates a patch bump. Acceptable trade-off vs. forgotten bumps.
- No rollback for bad versions — consumers must wait for next patch. Acceptable at current scale.
