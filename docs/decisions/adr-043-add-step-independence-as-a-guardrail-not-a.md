# ADR-043: Add step independence as a guardrail, not a structural change

## Status

Accepted (2026-03-05)

## Context

The ADR Context depth regression revealed that `/opsx:docs` steps can implicitly depend on data loaded in earlier steps. While Step 4 was the only step with this problem, future steps or modifications could introduce similar implicit dependencies. Two approaches were considered: adding a guardrail rule to the existing SKILL.md structure, or restructuring all steps into fully self-contained subagent instructions. The guardrail approach matches the existing SKILL.md pattern (a Guardrails section already exists with other rules like "read before write" and "internal consistency check"). A structural restructure would be more robust for autonomous agent execution but adds unnecessary scope when only one step has the problem. The guardrail explicitly states that each step must read its own source materials independently, backed by the explicit read instructions added to Step 4.

## Decision

Add step independence as a guardrail, not a structural change.

## Rationale

A guardrail rule is simpler and matches the existing SKILL.md structure. If insufficient, per-step restructure is the documented fallback.

## Alternatives Considered

- Restructure all steps into self-contained subagent instructions — more robust for autonomous agent execution but adds unnecessary scope when only Step 4 has the implicit dependency problem

## Consequences

### Positive

- Simple, additive change that fits the existing SKILL.md structure
- Catches future regressions in other steps by making step independence an explicit expectation
- Backed by concrete read instructions in Step 4, making the guardrail actionable rather than purely advisory

### Negative

- Guardrail is advisory, not programmatically enforced — depends on agent instruction compliance
- If other steps develop similar dependency issues, the guardrail alone may not be sufficient and the per-step restructure (Approach C) would need to be implemented

## References

- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [ADR-041: Replace priority rule with section-completeness rule](adr-041-replace-priority-rule-with-section-comple.md)
- [ADR-042: Add enrichment reads only to Step 4](adr-042-add-enrichment-reads-only-to-step-4-not-al.md)
