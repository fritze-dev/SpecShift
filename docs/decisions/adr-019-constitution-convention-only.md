# ADR-019: Constitution Convention Only

## Status

Accepted (2026-03-05)

## Context

The `/opsx:ff` command generates all 6 pipeline artifacts (research, proposal, specs, design, preflight, tasks) in a single uninterrupted loop. Issue #9 reported that users need a review checkpoint after the design stage -- the point where approach and architecture decisions are finalized -- before the system proceeds to preflight and tasks. The challenge was how to implement this pause without modifying the ff skill file.

Three approaches were investigated. Approach A was a constitution convention only: add a "Design review checkpoint" convention that instructs agents to pause after design in any multi-artifact workflow. Approach B combined the convention with a skill modification for hard enforcement in the loop logic. Approach C used a schema-level checkpoint to enforce the pause universally via the artifact pipeline.

The architecture's skill immutability principle (established by the three-layer architecture and reinforced by ADR-008) ruled out Approach B. Modifying the ff skill would create a project-specific fork, violating the principle that skills are shared generic code. Approach C was over-engineering: the schema defines artifact order and templates, not interaction pauses, and adding a pause mechanism to the schema would conflate concerns.

Approach A leverages the existing governance mechanism: the constitution is injected into every AI prompt via config.yaml, and agents are required to read and follow it. This means any agent executing `/opsx:ff` will encounter the design review convention and pause accordingly. The mechanism is already proven reliable through existing conventions like the post-archive auto-bump (ADR-008).

## Decision

Constitution convention only. Respects skill immutability; constitution is always loaded and authoritative.

## Rationale

Respects skill immutability; constitution is always loaded and authoritative.

## Alternatives Considered

- Skill modification (violates architecture)
- Schema checkpoint (over-engineering)

## Consequences

### Positive

- Respects skill immutability -- ff skill remains generic and shared
- Leverages the existing governance mechanism (constitution injection via config.yaml)
- Proven approach: same mechanism as post-archive auto-bump convention

### Negative

- Soft enforcement only: the convention relies on agent compliance, not hard code enforcement. Mitigated by the constitution being injected into every prompt via config.yaml.

## References

- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [Spec: constitution-management](../../openspec/specs/constitution-management/spec.md)
- [ADR-008: Convention in Constitution, Not Skill Modification](adr-008-convention-in-constitution-not-skill-modifica.md)
