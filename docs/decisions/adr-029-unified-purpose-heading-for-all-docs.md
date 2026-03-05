# ADR-029: Unified "Purpose" heading for all docs

## Status

Accepted (2026-03-05)

## Context

After the v1.0.7 `improve-docs-quality` change, generated capability docs used inconsistent heading names depending on whether they had archive enrichment data. Enriched docs used "Why This Exists" while initial-spec-only docs used a different variant. This created a confusing reading experience where structurally identical sections had different names across docs. The inconsistency also complicated the SKILL.md guidance, which had to reference different heading names for different enrichment scenarios. A unified heading name was needed that would be standard, unambiguous, and appropriate for both enriched and spec-only docs.

## Decision

Use "Purpose" as the unified heading name for all capability docs, replacing "Why This Exists."

## Rationale

"Purpose" is a standard, unambiguous term that eliminates the inconsistency between enriched and spec-only docs. It clearly communicates the section's intent without being informal or change-focused.

## Alternatives Considered

- Keep "Why This Exists" -- informal and inconsistent with ADR/spec terminology
- Use "Motivation" -- too change-focused; implies motivation for a specific change rather than the capability's ongoing purpose

## Consequences

### Positive

- All 18 capability docs now use identical heading structure regardless of enrichment level
- "Purpose" aligns with standard documentation terminology (ADRs, specs)
- Simpler SKILL.md guidance -- one heading name to reference, not multiple variants

### Negative

- Existing docs required heading renames across all 18 files (one-time migration cost)

## References

- [User Documentation spec](../../openspec/specs/user-docs/spec.md)
- [ADR-017: "Why This Exists" uses newest archive's proposal](adr-017-why-this-exists-uses-newest-archives-proposal.md) -- historical decision using the old naming
