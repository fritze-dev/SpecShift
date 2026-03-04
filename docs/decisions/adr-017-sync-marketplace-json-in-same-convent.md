# ADR-017: Sync marketplace.json in Same Convention

## Status

Accepted (2026-03-04)

## Context

The marketplace.json version was out of sync with plugin.json (1.0.0 vs 1.0.3). Both files need to stay aligned for the plugin system to work correctly. The auto-bump convention could handle both files or use a separate convention.

## Decision

Sync marketplace.json version in the same auto-bump convention — one operation, no drift.

## Rationale

One operation, no drift between the two version files.

## Alternatives Considered

- Separate convention (unnecessary complexity)

## Consequences

- Both files always stay in sync with a single convention entry.
- If files are found out of sync before bumping, the convention uses plugin.json as source of truth.
