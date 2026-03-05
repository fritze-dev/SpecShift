# ADR-005: Config as Bootstrap-Only

## Status

Accepted (2026-03-02)

## Context

The config.yaml file in the opsx-enhanced-flow plugin originally contained 9 workflow rules in its global `context` section, serving as the primary location for rule injection into all artifact generation prompts. The rule ownership audit (Issue #1) and friction point analysis (Issue #6) revealed that these rules duplicated content from the schema and constitution, creating a three-way redundancy problem.

With the decision to move universal workflow rules to the schema (ADR-004) and keep project-specific governance in the constitution, config.yaml's original role was significantly reduced. Research into OpenSpec's customization model confirmed that the prompt injection order is `<context>` then `<rules>` then `<template>`, and config.yaml's `context` is injected globally into ALL artifacts. This made it the wrong place for targeted rules.

The remaining legitimate purpose of config.yaml was per-project customization: pointing to the project's schema and constitution. With rules moved to the schema and project rules in the constitution, config.yaml only needed to reference these two sources. This reduced it from a rule repository to a pure bootstrap configuration file.

The alternative of keeping rules in config alongside schema and constitution was rejected because it perpetuated redundancy. Eliminating config entirely was also rejected because the constitution pointer must live somewhere accessible to the OpenSpec CLI.

## Decision

Config as bootstrap-only. config.yaml's purpose is per-project customization. With rules in schema and project rules in constitution, config just needs to point to the constitution.

## Rationale

config.yaml's purpose is per-project customization. With rules in schema and project rules in constitution, config just needs to point to the constitution.

## Alternatives Considered

- Keep rules in config (redundancy)
- No config at all (no constitution pointer)

## Consequences

### Positive

- config.yaml is minimal and clear in purpose -- just schema reference and constitution pointer
- Eliminates redundant rule definitions that could drift out of sync
- Makes the three-layer architecture cleaner: constitution for project rules, schema for universal rules, config for wiring

### Negative

- Reduced defense-in-depth: removing rules from config means one fewer enforcement point. Accepted because schema and constitution together provide sufficient coverage.

## References

- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
- [Spec: three-layer-architecture](../../openspec/specs/three-layer-architecture/spec.md)
- [ADR-004: Schema Owns Workflow Rules](adr-004-schema-owns-workflow-rules.md)
