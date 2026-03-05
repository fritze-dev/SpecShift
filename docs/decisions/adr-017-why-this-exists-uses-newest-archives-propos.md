# ADR-017: "Why This Exists" Uses Newest Archive's Proposal

## Status

Accepted (2026-03-04)

## Context

Enriched capability documentation includes a "Why This Exists" section that explains the motivation behind a capability. This section is derived from the `## Why` section of the proposal.md in the archive that created or most recently modified the capability. The question was which archive's proposal to use when a capability appears in multiple archives.

Three approaches were considered. Using the oldest archive's proposal preserves the original motivation but may be outdated if the capability has evolved. Concatenating all proposals provides comprehensive history but creates verbose, repetitive sections. Using the newest archive's proposal gives the most current motivation, which is most useful for readers trying to understand why a capability exists in its current form.

Research confirmed that newer archives typically build on and sometimes supersede the motivations of earlier ones. For example, if a capability was created in the initial spec bootstrap and later refined in a friction-fix change, the friction-fix proposal better explains why the capability exists in its current form. The older motivation is still accessible in the archive for historical reference.

This decision only applies to capabilities that have been touched by post-bootstrap archives. Initial-spec-only capabilities are handled by a separate decision (ADR-018).

## Decision

"Why This Exists" uses newest archive's proposal. Most current motivation, older may be superseded.

## Rationale

Most current motivation, older may be superseded.

## Alternatives Considered

- Concatenate all (verbose)
- Oldest only (may be outdated)

## Consequences

### Positive

- Documentation reflects the most current and relevant motivation for each capability
- Avoids verbose, repetitive content from concatenating multiple proposals
- Older motivations remain accessible in archives for historical reference

### Negative

- Historical context from earlier proposals is not directly visible in the capability doc, though it is preserved in the archives.

## References

- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
