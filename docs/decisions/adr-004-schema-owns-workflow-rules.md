# ADR-004: Schema Owns Workflow Rules

## Status

Accepted (2026-03-02)

## Context

The first real workflow run revealed that workflow rules were scattered across config.yaml, constitution, and schema with heavy redundancy. A rule ownership audit identified that the Definition of Done (DoD) and post-apply workflow sequence apply to ALL projects using opsx-enhanced — making them schema-level concerns, not project-specific.

Research confirmed that OpenSpec config.yaml supports per-artifact `rules` for targeted enforcement, and that the schema's `instruction` fields are the correct location for universal workflow rules.

## Decision

Schema owns workflow rules. DoD and post-apply sequence moved to schema instruction fields.

## Rationale

DoD and post-apply sequence apply to ALL projects using opsx-enhanced — they belong in the shared schema, not per-project config.

## Alternatives Considered

- config.yaml rules (per-project duplication)
- Constitution (also per-project)

## Consequences

- Reduced defense-in-depth: rules now live in one place instead of being duplicated. Schema enforcement + skill guardrails are sufficient.
