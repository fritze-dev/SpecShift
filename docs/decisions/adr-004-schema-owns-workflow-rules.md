# ADR-004: Schema Owns Workflow Rules

## Status

Accepted (2026-03-02)

## Context

The first dogfooding run of the opsx-enhanced-flow plugin revealed that workflow rules were scattered across three locations: config.yaml (9 global context rules), the constitution, and the schema. A rule ownership audit (Issue #1) found heavy redundancy -- 12 rules in the constitution duplicated instructions already present in schema templates. This duplication created maintenance burden and drift risk, where the same rule could be expressed differently in different locations.

The core question was which layer should own universal workflow rules like Definition of Done (DoD) for tasks and post-apply workflow sequences. Research into OpenSpec's config.yaml customization confirmed three injection points: `context` (global, all artifacts), `rules` (per-artifact), and templates. Per-artifact rules proved to be the correct mechanism for targeted enforcement rather than broad global context injection.

Two key rules needed a home: the DoD-emergent rule (ensuring tasks are complete before apply) and the post-apply workflow sequence (what happens after tasks are applied). Both apply universally to ALL projects using the opsx-enhanced schema, making them schema-level concerns rather than per-project configuration.

The investigation showed that config.yaml's purpose is per-project customization, the constitution is for project-specific governance rules, and the schema is for universal workflow behavior shared across all consumer projects.

## Decision

Schema owns workflow rules. DoD and post-apply sequence apply to ALL projects using opsx-enhanced -- they belong in the shared schema, not per-project config.

## Rationale

DoD and post-apply sequence apply to ALL projects using opsx-enhanced -- they belong in the shared schema, not per-project config.

## Alternatives Considered

- config.yaml rules (per-project duplication)
- Constitution (also per-project)

## Consequences

### Positive

- Universal rules are enforced consistently across all consumer projects via the shared schema
- Single source of truth for workflow rules prevents drift between locations
- Schema enforcement plus skill guardrails provide sufficient governance without redundancy

### Negative

- Reduced defense-in-depth: rules now live in one place instead of being duplicated across layers. Accepted trade-off since schema enforcement plus skill guardrails are sufficient.

## References

- [Spec: three-layer-architecture](../../openspec/specs/three-layer-architecture/spec.md)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [Spec: constitution-management](../../openspec/specs/constitution-management/spec.md)
