# ADR-032: "Read before write" guardrail in SKILL.md

## Status

Accepted (2026-03-05)

## Context

The v1.0.7 docs regeneration demonstrated that without explicit guidance, the AI agent rewrites capability docs from scratch on each run. This caused quality regressions: 11 Rationale sections replaced carefully written design reasoning with change-event descriptions, and 4 Purpose sections were weakened compared to manually curated originals. The root cause was that the agent treated each run as a fresh generation rather than an update to existing content. Investigation of three approaches (fix SKILL.md only, fix SKILL.md + regenerate, fix SKILL.md + guardrails + manual fixes) led to adding an explicit guardrail that requires reading existing content before writing.

## Decision

Add a "read before write" guardrail to the SKILL.md Guardrails section requiring the agent to read existing docs before generating.

## Rationale

Prevents quality regression by requiring the agent to read existing doc content before generating. This preserves established tone, phrasing, and structure. The agent only adds or modifies sections where enrichment data provides genuinely new information.

## Alternatives Considered

- Template-only guidance -- too easy to miss; templates define structure, not process behavior
- No guardrail, rely on template alone -- regression-prone, as demonstrated by v1.0.7

## Consequences

### Positive

- Preserves established quality across regeneration runs
- Agent enriches rather than replaces, building on prior work
- Reduces risk of content regression from future `/opsx:docs` runs

### Negative

- SKILL.md guidance is advisory, not enforced -- relies on agent compliance with well-written guidance. Mitigated by clear, explicit language and placement in the Guardrails section.

## References

- [User Documentation spec](../../openspec/specs/user-docs/spec.md)
- [GitHub Issue #18](https://github.com/fritze-dev/opsx-enhanced-flow/issues/18) -- full docs regeneration after guardrails were added
