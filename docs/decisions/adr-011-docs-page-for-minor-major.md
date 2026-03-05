# ADR-011: Docs Page for Minor/Major

## Status

Accepted (2026-03-04)

## Context

With patch versions handled automatically via the archive convention (ADR-009), the remaining question was how to handle minor and major version bumps. These are rare events -- the plugin had been through multiple changes without needing anything beyond patch bumps -- and they carry significant semantic meaning: minor bumps signal new features, major bumps signal breaking changes.

Three approaches were considered. A dedicated `/opsx:release` skill would provide a structured workflow but was over-engineering for something that happens rarely. Embedding the process in the archive skill was rejected for the same skill immutability reasons as ADR-008. A documented manual process in the form of a docs page was the lightest-weight solution that still provided clear guidance when needed.

Research showed that at the current project scale (single-developer plugin with one consumer), a docs page with step-by-step instructions for manual minor/major releases was sufficient. The process would include updating the version manually, creating a git tag, and optionally creating a GitHub Release. If the need for more structured releases grew, a dedicated skill could be added later without conflicting with this approach.

## Decision

Docs page for minor/major. Rare enough for manual process.

## Rationale

Rare enough for manual process.

## Alternatives Considered

- Dedicated skill (over-engineering)

## Consequences

### Positive

- Lightweight solution that matches the frequency of minor/major releases
- Clear documentation provides guidance without adding maintenance burden of a new skill
- Does not preclude adding a dedicated release skill later if the need grows

### Negative

- Manual process can still be forgotten or executed inconsistently, though the rarity of the event makes this a low-risk concern.

## References

- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
- [ADR-009: Patch-Only Auto-Bump](adr-009-patch-only-auto-bump.md)
