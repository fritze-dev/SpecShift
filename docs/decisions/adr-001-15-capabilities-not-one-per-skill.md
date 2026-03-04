# ADR-001: 15 Capabilities (Not One Per Skill)

## Status

Accepted (2026-03-02)

## Context

This is a documentation-only bootstrap — no code changes. The plugin is fully functional with 13 skills, a 6-stage artifact pipeline, and a three-layer architecture. This change creates baseline specs so that future feature development can use the spec-driven workflow. The key question was how to organize specs: one per skill (19 specs, too granular), one monolithic spec (untraceable), or logical capability groupings.

Research identified three levels of abstraction: design concepts, structural components, and operational features. Grouping by logical capability (e.g., continue+ff under artifact-generation) ensures comprehensive coverage without gaps or overlaps.

## Decision

15 capabilities grouped logically (not one per skill). Groups related behavior — e.g., continue+ff under artifact-generation, docs+changelog under docs-generation.

## Rationale

Groups related behavior logically — e.g., continue+ff under artifact-generation, docs+changelog under docs-generation.

## Alternatives Considered

- One per skill (19 specs, too granular)
- Monolithic (1 spec, untraceable)

## Consequences

- 15 specs is a manageable number to maintain, with each spec focused and self-contained.
- Drift detection available via bootstrap re-run mode.
- Risk: spec content may not perfectly match actual skill behavior — mitigated by verify step.
