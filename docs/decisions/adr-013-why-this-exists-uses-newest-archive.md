# ADR-013: "Why This Exists" Uses Newest Archive's Proposal

## Status

Accepted (2026-03-04)

## Context

When a capability has been touched by multiple archived changes, the "Why This Exists" enrichment section needs to choose which proposal's "Why" to use. The oldest archive may have an outdated motivation, while concatenating all proposals would be too verbose.

## Decision

"Why This Exists" uses the newest archive's proposal for the most current motivation.

## Rationale

Most current motivation — older motivations may be superseded by newer changes.

## Alternatives Considered

- Concatenate all (too verbose)
- Oldest only (may be outdated)

## Consequences

- Users see the most current motivation for each capability.
- Historical motivations from older archives are not lost — they remain in the archive artifacts and ADR records.
