# ADR-005: Config as Bootstrap-Only

## Status

Accepted (2026-03-02)

## Context

With workflow rules moved to the schema and project rules in the constitution, config.yaml's purpose was clarified. The config had 9 global workflow rules, but these were redundant with schema instructions and constitution rules.

## Decision

Config.yaml reduced to bootstrap-only: schema reference + constitution pointer.

## Rationale

config.yaml's purpose is per-project customization. With rules in schema and project rules in constitution, config just needs to point to the constitution.

## Alternatives Considered

- Keep rules in config (redundancy)
- No config at all (no constitution pointer)

## Consequences

- config.yaml reduced from 9 global rules to a single constitution pointer, eliminating redundancy.
