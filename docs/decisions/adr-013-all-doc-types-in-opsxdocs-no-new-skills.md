# ADR-013: All Doc Types in /opsx:docs, No New Skills

## Status

Accepted (2026-03-04)

## Context

With the documentation ecosystem expanding to include enriched capability docs, architecture overview, and ADRs, the question was whether to create separate skills for each output type (e.g., `/opsx:adr`, `/opsx:research-log`) or consolidate everything under the existing `/opsx:docs` skill.

Research evaluated three approaches. Enriching `/opsx:docs` with all tiers provided a single entry point with no skill proliferation, though it made the skill prompt longer and more complex. Separate skills per tier offered clean separation of concerns but meant 2 new skills to maintain and required users to remember multiple commands. A partial approach (enrich docs only, defer ADRs) would reduce scope but lose valuable output and require multiple changes.

The user explicitly preferred a single entry point approach, and the project's skill immutability principle discourages unnecessary skill proliferation. Since all three output types share the same source data (specs and archives) and are generated together in a single pass, separating them into different skills would create artificial boundaries. One command that generates all documentation is simpler for users and consistent with the plugin's design philosophy of minimal commands with rich behavior.

## Decision

All doc types in `/opsx:docs`, no new skills. User preference, avoids skill proliferation, single entry point.

## Rationale

User preference, avoids skill proliferation, single entry point.

## Alternatives Considered

- Separate `/opsx:adr` + `/opsx:research-log` skills

## Consequences

### Positive

- Single entry point for all documentation generation -- users run one command
- No skill proliferation; maintenance burden stays low
- All doc types share the same archive-reading logic, reducing code duplication

### Negative

- Longer, more complex skill prompt (approximately 300 lines), though clear section headers maintain readability.

## References

- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
