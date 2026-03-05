# ADR-030: Unified "Rationale" heading for all docs

## Status

Accepted (2026-03-05)

## Context

Generated capability docs used inconsistent heading names for their design reasoning section. Enriched docs used "Background" while initial-spec-only docs used "Design Rationale." This inconsistency made it harder for readers to locate the design reasoning across different capability docs. The heading also needed to be distinct from the ADR "Context" section to avoid confusion, since both describe reasoning but at different levels (capability-level vs decision-level). A unified name was needed that would be standard across both enriched and spec-only docs.

## Decision

Use "Rationale" as the unified heading name for all capability docs, replacing both "Background" and "Design Rationale."

## Rationale

"Rationale" is standard ADR terminology and covers both research-based design reasoning (for enriched docs) and assumption-based reasoning (for spec-only docs). It is distinct from ADR "Context" while clearly communicating design reasoning.

## Alternatives Considered

- Keep "Background" -- too vague; does not communicate that the section contains design reasoning
- Keep "Design Rationale" -- redundant with ADR Context sections; the word "Design" is unnecessary when the section is already within a design-focused document

## Consequences

### Positive

- Consistent terminology across all 18 capability docs
- Aligns with standard ADR terminology used in the decision-docs capability
- Clearer reader expectation: "Rationale" signals design reasoning, not historical narrative

### Negative

- Heading renames required across all 18 files (one-time migration cost, same as ADR-029)

## References

- [User Documentation spec](../../openspec/specs/user-docs/spec.md)
- [ADR-029: Unified "Purpose" heading](adr-029-unified-purpose-heading-for-all-docs.md)
