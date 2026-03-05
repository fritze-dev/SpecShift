# ADR-022: Update Constitution Before Spec

## Status

Accepted (2026-03-05)

## Context

The design review checkpoint change required updates to both the constitution (governance rule) and the artifact-generation spec (formal requirement). The order of these updates matters for consistency — both are read by agents during workflow execution.

## Decision

Update constitution before spec.

## Rationale

Constitution establishes the governance rule; spec formalizes the behavioral change. The convention must exist in the constitution before the spec references it, ensuring agents encounter the rule even if they only read the constitution.

## Alternatives Considered

- Spec first — would lack governance backing; agents reading only the constitution would not know about the checkpoint

## Consequences

- Implementation order is deterministic: governance layer first, then formal requirements, then documentation.
- Agents reading the constitution during ff execution will encounter the checkpoint rule before consulting the spec.
