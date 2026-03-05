# ADR-024: Consolidated README Replaces 3 Separate Files

## Status

Accepted (2026-03-05)

## Context

The v1.0.5 docs generation produced 5 files serving as entry points or indexes: `docs/README.md` (thin TOC with 3 links), `docs/architecture-overview.md` (the actual architecture document), and `docs/decisions/README.md` (ADR index that duplicated the overview's Key Design Decisions table). This multi-file structure required navigation hops to find information and created maintenance overhead from cross-linking between files.

Research evaluated two approaches. Consolidating into a single `docs/README.md` eliminates navigation hops and positions the architecture overview as the natural entry point for the docs directory. The ADR index is just a table that fits naturally within the overview alongside the Key Design Decisions table. The alternative of keeping separate files with better cross-linking was rejected because it still required maintaining 3 files with 3 sets of links.

The architecture overview IS the entry point -- it provides system context, tech stack, design decisions, and conventions. Making it the README.md means readers entering the docs directory immediately see the most important content. The thin TOC and separate ADR index added indirection without adding value.

This consolidation reduces the number of generated files while improving discoverability. Consumer projects running `/opsx:docs` after upgrading will get the new structure automatically since docs are fully regenerated each run.

## Decision

Consolidated README replaces 3 separate files. Eliminates navigation hops; architecture overview IS the entry point; ADR index is just a table that fits in the overview.

## Rationale

Eliminates navigation hops; architecture overview IS the entry point; ADR index is just a table that fits in the overview.

## Alternatives Considered

- Keep separate files with better cross-linking (rejected: still 3 files to maintain)

## Consequences

### Positive

- Single entry point for all documentation -- readers immediately find the architecture overview
- Eliminates redundant cross-linking between files
- Fewer generated files to maintain

### Negative

- Breaking external links: `docs/architecture-overview.md` and `docs/decisions/README.md` URLs will break. Low impact since docs are internal to the repo.

## References

- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
