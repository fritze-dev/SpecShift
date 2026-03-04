# ADR-006: Remove Constitution Redundancies

## Status

Accepted (2026-03-02)

## Context

The constitution contained 12 rules that duplicated schema instructions and templates. This redundancy created maintenance burden and drift risk — when a rule was updated in one place, the duplicate could become stale.

## Decision

Remove 12 redundant rules from the constitution. Single source of truth prevents drift.

## Rationale

Single source of truth prevents drift and reduces constitution noise.

## Alternatives Considered

- Keep redundancies as "defense in depth" (causes maintenance burden and drift)

## Consequences

- Constitution is focused on project-specific knowledge only: tech stack, architecture rules, code style, constraints, conventions.
- Reduced defense-in-depth is an accepted trade-off — schema enforcement + skill guardrails are sufficient.
