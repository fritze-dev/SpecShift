# ADR-028: README Shortening Is a Separate Implementation Task

## Status

Accepted (2026-03-05)

## Context

The project README.md was 462 lines long and duplicated content now available in auto-generated docs. As part of the docs quality improvement, the README needed to be shortened and updated with links to the docs directory. The question was whether to include README shortening in the same implementation task as the docs regeneration or to handle it separately.

The README is hand-written content with editorial judgment about what to include, how to phrase it, and which sections to keep. The docs regeneration, in contrast, is automated output from specs and archives. Mixing hand-written editorial changes with automated generation in the same task list would create confusion about what is auto-generated and what requires human judgment.

Research evaluated two approaches. Including README shortening in the docs regeneration task would make it a single delivery but mix concerns. Separating it allows independent review: the auto-generated docs can be verified against the templates and specs, while the README changes can be reviewed for editorial quality. This clearer separation of concerns also allows the README changes to be deferred or revised without blocking the docs regeneration.

The decision aligns with the principle that hand-written and auto-generated artifacts should be managed independently to maintain clarity about ownership and review standards.

## Decision

README shortening is a separate implementation task from docs regeneration. README is hand-written; changes are independent of auto-generated docs; allows separate review.

## Rationale

README is hand-written; changes are independent of auto-generated docs; allows separate review.

## Alternatives Considered

- Include in docs regeneration (rejected: mixes auto-generated and hand-written concerns)

## Consequences

### Positive

- Clear separation between auto-generated and hand-written changes
- Independent review for editorial quality of README changes
- Docs regeneration is not blocked by README editorial decisions

### Negative

- No significant negative consequences identified.

## References

- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
