# ADR-010: Direct Glob Per Capability

## Status

Accepted (2026-03-04)

## Context

When enriching capability docs, the agent needs to find which archives touched a given capability. Two approaches were considered: pre-building an index by parsing proposal.md Capabilities sections, or directly globbing `archive/*/specs/<capability>/` per capability.

## Decision

Direct glob per capability instead of pre-built index.

## Rationale

Simpler implementation, no separate index-building step needed. Archives are few enough that direct glob is efficient.

## Alternatives Considered

- Capability-to-Change Index with proposal parsing (over-engineering)

## Consequences

- Simpler implementation with fewer steps.
- Relies on archive structure being consistent — enforced by the archive skill.
