# ADR-014: Direct Glob Per Capability Instead of Pre-Built Index

## Status

Accepted (2026-03-04)

## Context

The enriched `/opsx:docs` skill needs to find which archives touched each capability in order to read proposal, research, design, and preflight artifacts for that capability's documentation. Two approaches were investigated for this capability-to-archive mapping.

The first approach was building a Capability-to-Change Index by pre-parsing all proposal.md files to extract capability mentions from their `### New Capabilities` and `### Modified Capabilities` sections. This would create a structured mapping before generating any docs. The second approach was a direct glob per capability: for each capability being documented, glob `openspec/changes/archive/*/specs/<capability>/` to find archives that touched it, then read artifacts from those archive root directories.

Research found that the proposal.md Capabilities section consistently uses a parseable format (`- \`capability-name\`: description`), making the index approach viable. However, the number of archives was small (5 at the time), and the direct glob approach was simpler with no separate step needed. The glob pattern reliably identifies archives that touched a capability because the archive directory structure includes spec subdirectories named after capabilities.

The index approach was classified as over-engineering for the current scale. If the number of archives grows significantly, a pre-built index could be introduced later without changing the output format.

## Decision

Direct glob per capability instead of pre-built index. Simpler, no separate step needed, archives are few.

## Rationale

Simpler, no separate step needed, archives are few.

## Alternatives Considered

- Capability-to-Change Index with proposal parsing (over-engineering)

## Consequences

### Positive

- Simpler implementation with no index-building step
- No state to maintain between docs generations
- Glob pattern reliably identifies archives that touched each capability

### Negative

- Missing archive artifacts (e.g., no design.md in some archives) must be handled gracefully with fallback behavior to skip enrichment from missing artifacts.

## References

- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
