# ADR-041: Replace priority rule with section-completeness rule

## Status

Accepted (2026-03-05)

## Context

When `/opsx:docs` regenerates all documentation from scratch, 9 of 18 capability docs lost their Known Limitations section and 6 lost Future Enhancements. The root cause was a "space-constrained" priority rule in SKILL.md Step 3 that marked Known Limitations, Future Enhancements, and Rationale as `(optional)`. This gave the agent permission to drop these sections even when source data existed. Investigation showed that no capability doc exceeds 1.3 pages — the space constraint that the rule assumed does not actually exist. The per-section maximum limits (Purpose max 3 sentences, Known Limitations max 5 bullets, etc.) already serve as sufficient conciseness guards. The fix needed to replace this negative guidance ("drop when constrained") with positive guidance ("include when data exists") to prevent section dropping while maintaining conciseness through the existing per-section limits.

## Decision

Replace priority rule with section-completeness rule.

## Rationale

Positive guidance ("include when data exists") prevents section dropping without removing conciseness guards (per-section max limits remain).

## Alternatives Considered

- Remove priority line entirely — rejected because it leaves no guidance at all, which could lead to inconsistent behavior across regeneration runs

## Consequences

### Positive

- All template sections are included when source data exists, ensuring Known Limitations and Future Enhancements are no longer silently dropped
- Per-section max limits remain as conciseness guards, preventing doc bloat
- Capability docs are more complete and informative for end users

### Negative

- Agent may still drop sections despite the rule change if the instruction is not followed precisely — mitigated by imperative language ("SHALL include ALL sections") and the existing per-section limits as secondary guard

## References

- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [ADR-042: Add enrichment reads only to Step 4](adr-042-add-enrichment-reads-only-to-step-4-not-al.md)
- [ADR-043: Add step independence as a guardrail](adr-043-add-step-independence-as-a-guardrail-not-a.md)
- [GitHub Issue #29](https://github.com/fritze-dev/opsx-enhanced-flow/issues/29)
