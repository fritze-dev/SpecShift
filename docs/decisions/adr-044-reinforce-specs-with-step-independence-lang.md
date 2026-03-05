# ADR-044: Reinforce specs with step independence language

## Status

Accepted (2026-03-05)

## Context

The `user-docs` and `decision-docs` specs already described the correct behavior — Step 4 should enrich ADR Context from design.md Context and research.md Approaches, and capability docs should include Known Limitations and Future Enhancements when source data exists. However, the SKILL.md implementation diverged from the specs: it added a "space-constrained" priority rule not present in the specs, and Step 4 lacked explicit read instructions matching the spec requirements. While fixing SKILL.md alone would resolve the regressions, the project convention requires spec changes to go through the OpenSpec flow. Adding explicit "step independence" language to both specs reinforces the requirement and prevents future drift between spec and skill implementation. This is particularly important because the specs are the normative source — if the skill drifts again, the spec language provides a clear reference point for detection and correction.

## Decision

Reinforce specs with step independence language.

## Rationale

Keeps specs and skill explicitly aligned. Adding step independence language to specs prevents future drift.

## Alternatives Considered

- Skip spec changes — rejected because the convention requires changes to go through the spec flow, and explicit spec language prevents future spec-skill divergence

## Consequences

### Positive

- Specs and SKILL.md are explicitly aligned on step independence requirements
- Future drift between spec and skill is detectable through spec review
- Step independence is formally specified, not just an implementation detail

### Negative

- Template comments increase file size in the spec layer, though this is negligible

## References

- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [ADR-041: Replace priority rule with section-completeness rule](adr-041-replace-priority-rule-with-section-comple.md)
- [ADR-042: Add enrichment reads only to Step 4](adr-042-add-enrichment-reads-only-to-step-4-not-al.md)
