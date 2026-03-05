# ADR-010: Sync marketplace.json in Same Convention

## Status

Accepted (2026-03-04)

## Context

The plugin has two JSON files that carry version information: `plugin.json` (used by `/plugin update` to detect changes) and `marketplace.json` (used by `/plugin marketplace update` to refresh the listing). At the time of this decision, marketplace.json was three patch versions behind plugin.json (1.0.0 vs 1.0.3), demonstrating that maintaining two separate version fields manually is error-prone.

With auto-bump being added to the archive convention (ADR-008, ADR-009), the question was whether to sync marketplace.json in the same operation or handle it separately. A separate convention would add unnecessary complexity: two convention entries doing essentially the same thing (update a version field in a JSON file), with the same trigger (archive completion).

Research confirmed that both files follow a simple structure with a version field. The auto-bump convention could check for marketplace.json existence after updating plugin.json and sync the version in a single step. This prevents version drift between the two files with zero additional complexity.

## Decision

Sync marketplace.json in same convention. One operation, no drift.

## Rationale

One operation, no drift.

## Alternatives Considered

- Separate convention (unnecessary complexity)

## Consequences

### Positive

- Version fields in both files are always in sync after every archive
- No additional convention entries or manual steps required
- Eliminates the version drift that had already occurred (1.0.0 vs 1.0.3)

### Negative

- No significant negative consequences identified.

## References

- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
- [ADR-008: Convention in Constitution, Not Skill Modification](adr-008-convention-in-constitution-not-skill-modification.md)
- [ADR-009: Patch-Only Auto-Bump](adr-009-patch-only-auto-bump.md)
