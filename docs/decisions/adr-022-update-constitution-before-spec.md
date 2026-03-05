# ADR-022: Update Constitution Before Spec

## Status

Accepted (2026-03-05)

## Context

The design review checkpoint requires changes to both the constitution (adding the convention) and the artifact-generation spec (formalizing the behavioral change). The question was the implementation order: should the constitution convention be added first, or should the spec be updated first?

The constitution establishes governance rules that are authoritative across the project. A spec formalizes behavioral requirements that implementations must satisfy. For the design review checkpoint, the governance rule ("agents must pause after design for review") is the foundation, and the spec requirement ("ff runs in two phases with a review checkpoint") is the formalization of that rule.

Updating the spec first would create a behavioral requirement without governance backing -- the spec would describe a pause, but no constitution convention would explain why agents should pause or establish the rule's authority. Updating the constitution first establishes the governance rule, which the spec then formalizes into testable requirements. This follows the project's three-layer architecture: constitution sets the rules, schema/specs formalize them, skills implement them.

Research into the three-layer architecture confirmed that the constitution is the top-level authority. Changes that introduce new governance rules should establish the rule in the constitution before formalizing it in specs, ensuring the governance chain is maintained.

## Decision

Update constitution before spec. Constitution establishes the governance rule; spec formalizes the behavioral change.

## Rationale

Constitution establishes the governance rule; spec formalizes the behavioral change.

## Alternatives Considered

- Spec first (would lack governance backing)

## Consequences

### Positive

- Governance chain is maintained: constitution rule precedes spec formalization
- Agents reading the constitution during implementation will already have the rule before the spec is updated
- Consistent with the three-layer architecture hierarchy

### Negative

- No significant negative consequences identified.

## References

- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [Spec: constitution-management](../../openspec/specs/constitution-management/spec.md)
- [ADR-019: Constitution Convention Only](adr-019-constitution-convention-only.md)
