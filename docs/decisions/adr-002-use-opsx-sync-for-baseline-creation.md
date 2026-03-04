# ADR-002: Use /opsx:sync for Baseline Creation

## Status

Accepted (2026-03-02)

## Context

The initial bootstrap needed to create baseline specs from delta specs. The OpenSpec CLI's programmatic archive merge had limitations — it expects `## Purpose` + `## Requirements` format and has header matching issues. An alternative approach was needed.

## Decision

Use `/opsx:sync` for baseline creation, not programmatic archive merge.

## Rationale

Programmatic merge has format limitations (missing Purpose, header matching issues). Agent-driven sync produces coherent, well-structured baseline specs.

## Alternatives Considered

- Direct `openspec archive` (failed in previous attempt due to format limitations)

## Consequences

- Sync agent may produce inconsistent baseline format — mitigated by validating all baselines after sync and fixing format issues before committing.
