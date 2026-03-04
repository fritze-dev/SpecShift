# ADR-008: Split docs-generation into Focused Capabilities

## Status

Accepted (2026-03-04)

## Context

`/opsx:docs` previously generated capability docs from baseline specs only, leaving valuable context from archived artifacts unused. The `docs-generation` capability was too broad — it mixed user docs, changelog, and would need to gain architecture overview and ADRs. Research showed that ADR conventions, enriched capability docs, and architecture overviews each had distinct requirements.

Consolidating all three tiers into `/opsx:docs` was chosen over separate skills, based on user preference and the principle of avoiding skill proliferation.

## Decision

Split `docs-generation` into `user-docs`, `architecture-docs`, `decision-docs`. Changelog moved to `release-workflow`.

## Rationale

Each concern is independently spec'd and testable; changelog fits better under `release-workflow`.

## Alternatives Considered

- Keep everything in one bloated `docs-generation` spec

## Consequences

- SKILL.md prompt length increases (~150 to ~300 lines) — acceptable for a comprehensive doc generation skill.
- `docs-generation` spec is removed; three new specs are created.
- No risk to `/opsx:changelog` — unchanged behavior, skill untouched, spec just moves to different capability.
