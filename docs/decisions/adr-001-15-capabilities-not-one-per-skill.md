# ADR-001: 15 Capabilities (Not One Per Skill)

## Status

Accepted (2026-03-02)

## Context

The opsx-enhanced-flow plugin was fully functional with 13 skills, a 6-stage artifact pipeline, and a three-layer architecture, but had no formal specifications. A documentation-only bootstrap was needed to create baseline specs so that future feature development could use the spec-driven workflow (delta specs, verify, sync, archive). The central question was how to organize specs across the 13 existing skills.

Research identified three levels of abstraction for organizing capabilities: design concepts (structural components like three-layer-architecture), operational features (like artifact-generation covering both continue and ff), and supporting concerns (like docs-generation). The key trade-off was between granularity and traceability. One spec per skill would yield 19 specs with excessive granularity and redundant overlap between related commands. A single monolithic spec would make change tracking impossible. Grouping by logical capability ensures comprehensive coverage without gaps or overlaps, while keeping each spec focused on one coherent concern.

The initial-spec bootstrap approach was not choosing between implementation alternatives, since the system already existed. Instead, it was purely a documentation structure decision about how to partition the spec surface area.

## Decision

15 capabilities (not one per skill). Groups related behavior logically -- e.g., continue+ff under artifact-generation, docs+changelog under docs-generation.

## Rationale

Groups related behavior logically -- e.g., continue+ff under artifact-generation, docs+changelog under docs-generation.

## Alternatives Considered

- One per skill (19 specs, too granular)
- Monolithic (1 spec, untraceable)

## Consequences

### Positive

- Each spec covers one coherent capability with clear boundaries, making specs self-contained and easy to navigate
- Related behavior is grouped logically, reducing redundancy across specs
- 15 specs is a manageable number to maintain with drift detection available via bootstrap re-run mode

### Negative

- 15 specs is still a significant number to keep in sync; spec content may not perfectly match actual skill behavior over time

## References

- [Spec: three-layer-architecture](../../openspec/specs/three-layer-architecture/spec.md)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
