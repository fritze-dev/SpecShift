# ADR-007: Init Generates Minimal Config Template

## Status

Accepted (2026-03-02)

## Context

The `/opsx:init` skill sets up consumer projects to use the opsx-enhanced-flow plugin by generating initial configuration files. Previously, the init skill copied the full project config.yaml, which contained project-specific rules and references specific to the plugin's own development. This meant consumer projects received configuration that was irrelevant or actively misleading for their context.

With config.yaml reduced to a bootstrap-only role (ADR-005), the init skill needed to generate a clean starting point that gave consumers the minimal wiring -- schema reference and constitution pointer -- without leaking project-specific content. The alternative of copying the full project config was rejected because it would propagate opsx-enhanced-flow's own development rules into unrelated consumer projects.

Research confirmed that the init skill should provide a template with placeholder values that consumers fill in for their project. This aligns with the three-layer architecture principle: the schema provides universal behavior, the constitution provides project-specific rules, and config.yaml just wires them together. A minimal template makes this clear to consumers.

The change ensures that new consumer projects start with a clean, understandable configuration rather than inheriting the plugin developer's project-specific setup.

## Decision

Init generates minimal config template. Prevents project-specific rules from leaking into consumer projects. Init should provide a clean starting point.

## Rationale

Prevents project-specific rules from leaking into consumer projects. Init should provide a clean starting point.

## Alternatives Considered

- Copy full project config (leaks project-specific content)

## Consequences

### Positive

- Consumer projects start with a clean, understandable configuration
- No project-specific rules leak into consumer projects
- Template with placeholder values guides consumers to fill in their own project-specific settings

### Negative

- No significant negative consequences identified.

## References

- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
- [ADR-005: Config as Bootstrap-Only](adr-005-config-as-bootstrap-only.md)
