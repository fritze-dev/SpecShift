# ADR-023: SKILL.md References Templates via Read at Runtime

## Status

Accepted (2026-03-05)

## Context

The `/opsx:docs` skill prompt (SKILL.md) controls all documentation generation behavior. The v1.0.5 production run exposed quality gaps including inconsistent formatting, weak content for initial-spec-only capabilities, and thin ADR context sections. Fixing these issues required establishing a consistent output format, and the question was where to define that format.

The existing approach embedded format definitions inline in SKILL.md. This made the prompt longer (approximately 300 lines), harder to maintain, and coupled format changes to prompt edits. Any change to the ADR template, capability doc template, or README structure required editing the skill prompt itself.

Research evaluated two approaches. Runtime template references (SKILL.md reads template files via `Read openspec/schemas/opsx-enhanced/templates/docs/*.md`) follow the same pattern as pipeline artifact templates (research, proposal, etc.) which are already stored in the templates directory. This approach provides a single source of truth for doc structure, allows format changes without prompt edits, and keeps SKILL.md focused on generation logic rather than formatting details. The alternative of keeping inline format definitions was rejected as the current pain point.

Template extraction actually reduces SKILL.md length by moving structural format definitions to separate files, while the critical generation logic stays in the prompt. Consumer projects get templates via `/opsx:init` schema copy, following the same path as pipeline templates.

## Decision

SKILL.md references templates via Read at runtime. Consistent with pipeline artifact templates; format changes don't require prompt edits; single source of truth for doc structure.

## Rationale

Consistent with pipeline artifact templates; format changes don't require prompt edits; single source of truth for doc structure.

## Alternatives Considered

- Inline format in SKILL.md (current approach -- harder to maintain, bloats prompt)

## Consequences

### Positive

- Single source of truth for documentation format -- changes to templates do not require SKILL.md edits
- Consistent with existing pipeline artifact template pattern
- Reduces SKILL.md prompt length by extracting structural format definitions

### Negative

- SKILL.md prompt effectiveness could be affected by more detailed instructions causing the LLM to over-focus on formatting. Mitigated by template extraction actually reducing SKILL.md length.

## References

- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
