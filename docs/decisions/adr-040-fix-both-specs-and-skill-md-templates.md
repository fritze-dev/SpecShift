# ADR-040: Fix Both Specs AND SKILL.md/Templates

## Status
Accepted (2026-03-05)

## Context
The docs skill quality regressions required fixes in both the specification layer (baseline specs defining requirements) and the execution layer (SKILL.md and templates defining runtime behavior). The fix-docs-skill-regressions change investigated whether to fix only SKILL.md/templates (leaving specs to drift from the updated implementation) or only specs (which the agent does not read at runtime — it reads SKILL.md). Both approaches create a consistency gap between the authoritative requirement definition and the actual execution instructions. Since the opsx-enhanced plugin uses a three-layer architecture where specs define requirements and SKILL.md defines execution, both must agree to prevent future drift. Updating only one layer means the other becomes stale, which compounds over time and makes future changes harder to reason about.

## Decision
Fix both specs AND SKILL.md/templates together for any regression fix.

## Rationale
Specs define requirements; SKILL.md defines execution; both must agree to prevent future drift.

## Alternatives Considered
- SKILL.md-only fixes (specs drift from implementation, creating a consistency gap)
- Specs-only fixes (agent reads SKILL.md at runtime, not specs — behavior wouldn't actually change)

## Consequences

### Positive
- Specs and execution instructions stay synchronized, maintaining the three-layer architecture contract
- Future contributors can trust that specs accurately describe what the skill does
- Prevents the accumulation of spec-implementation drift over time

### Negative
- Template comments increase file size in the schema layer. Templates are only read by the agent at generation time, so no user impact, but the files become longer.

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
