# ADR-006: Remove Constitution Redundancies

## Status

Accepted (2026-03-02)

## Context

The constitution in the opsx-enhanced-flow plugin contained 12 rules that duplicated instructions already present in schema templates and skill definitions. This redundancy was discovered during the rule ownership audit (Issue #1) following the first dogfooding run. Examples included rules about artifact pipeline order, template usage, and verification requirements that were already enforced by schema instructions and skill prompts.

Having the same rules in multiple locations created two problems. First, maintenance burden: every rule change required updating multiple files. Second, drift risk: rules expressed slightly differently in different locations could lead to contradictory instructions, confusing the AI agent about which version to follow. The constitution's role should be project-specific governance (coding standards, architecture decisions, conventions), not restatement of universal workflow behavior already handled by the schema.

Research into the three approaches -- keeping redundancies as "defense in depth," removing all duplicates, or selectively removing -- showed that redundancies did not add safety. The schema enforcement mechanism plus skill guardrails provided sufficient coverage. Keeping duplicates as defense-in-depth only increased maintenance burden and created drift vectors.

The audit identified exactly which 12 rules were redundant and which were genuinely project-specific. After removal, the constitution was cleaner and focused exclusively on project-specific concerns including a new friction tracking convention.

## Decision

Remove constitution redundancies. 12 rules duplicated schema instructions/templates. Single source of truth prevents drift and reduces constitution noise.

## Rationale

12 rules duplicated schema instructions/templates. Single source of truth prevents drift and reduces constitution noise.

## Alternatives Considered

- Keep redundancies as "defense in depth" (causes maintenance burden and drift)

## Consequences

### Positive

- Single source of truth for each rule prevents drift between locations
- Constitution is cleaner and focused on project-specific concerns
- Reduced maintenance burden when updating workflow rules

### Negative

- Reduced defense-in-depth: rules now live in one place only. If the schema fails to inject a rule, there is no constitution backup. Accepted because schema enforcement is reliable.

## References

- [Spec: constitution-management](../../openspec/specs/constitution-management/spec.md)
- [Spec: three-layer-architecture](../../openspec/specs/three-layer-architecture/spec.md)
- [ADR-004: Schema Owns Workflow Rules](adr-004-schema-owns-workflow-rules.md)
