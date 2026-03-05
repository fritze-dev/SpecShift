# ADR-033: Manual doc fixes + deferred regeneration

## Status

Accepted (2026-03-05)

## Context

After the v1.0.7 content regressions were identified (11 Rationale sections, 4 Purpose sections affected), two paths were available: manually fix the 18 docs immediately and defer regeneration, or fix the SKILL.md guardrails and regenerate immediately. The risk of regenerating immediately was that the same regression could recur if the guardrails were not yet proven effective. Manual fixes were safer because they preserved the known-good content while the guardrails were validated separately. The full regeneration was deferred to friction issue #18, which would serve as the validation pass for the new guardrails.

## Decision

Manually fix the 18 docs and defer full regeneration to friction issue #18.

## Rationale

Manual fixes are safer for this change because they preserve established quality. Regeneration validates guardrails separately, reducing the risk of compounding regressions.

## Alternatives Considered

- Regenerate as part of this change -- risks new regressions before the guardrails are proven effective in practice

## Consequences

### Positive

- Known-good content preserved immediately
- Guardrails validated separately in a dedicated pass (issue #18)
- Reduced risk of compounding quality issues

### Negative

- Current docs are manually curated, not generated -- they may diverge from what `/opsx:docs` would produce until the regeneration pass completes
- Requires a separate issue (#18) and additional work to complete the validation

## References

- [User Documentation spec](../../openspec/specs/user-docs/spec.md)
- [GitHub Issue #18](https://github.com/fritze-dev/opsx-enhanced-flow/issues/18) -- the deferred regeneration pass
- [ADR-032: "Read before write" guardrail](adr-032-read-before-write-guardrail-in-skillmd.md)
