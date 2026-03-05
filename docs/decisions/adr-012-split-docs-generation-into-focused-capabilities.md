# ADR-012: Split docs-generation into Focused Capabilities

## Status

Accepted (2026-03-04)

## Context

The `/opsx:docs` skill was being enhanced to generate not just capability docs but also an architecture overview, ADRs, and enriched documentation from archived artifacts. The existing `docs-generation` spec covered both `/opsx:docs` and `/opsx:changelog` in a single capability with two requirements. This single-spec approach was becoming unwieldy as the documentation ecosystem grew in scope.

Research showed that the enriched docs skill would have three distinct output types: user-facing capability documentation, architecture overview content, and architecture decision records. Each output type has different source data (specs vs. constitution vs. design.md decisions tables), different generation logic, and different output formats. Combining all three under one spec would create a bloated specification that was hard to test and maintain.

Additionally, the changelog functionality had a natural home in the `release-workflow` capability, since changelog generation is part of the release process. Keeping it under `docs-generation` was a historical accident from the initial spec bootstrap where docs and changelog shared a skill file.

The split produced three focused capabilities: `user-docs` (capability documentation from specs and archives), `architecture-docs` (architecture overview from constitution and design decisions), and `decision-docs` (ADRs from design.md decisions tables). Each could be independently spec'd, tested, and evolved.

## Decision

Split `docs-generation` into `user-docs`, `architecture-docs`, `decision-docs`. Each concern is independently spec'd and testable; changelog fits better under `release-workflow`.

## Rationale

Each concern is independently spec'd and testable; changelog fits better under `release-workflow`.

## Alternatives Considered

- Keep everything in one bloated `docs-generation` spec

## Consequences

### Positive

- Each documentation concern has a focused, independently testable spec
- Changelog moves to its natural home in `release-workflow`
- Future changes to one doc type don't require touching unrelated specs

### Negative

- SKILL.md prompt length increases from approximately 150 to 300 lines, though clear section headers maintain readability.

## References

- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
