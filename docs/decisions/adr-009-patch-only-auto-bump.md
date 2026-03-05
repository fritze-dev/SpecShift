# ADR-009: Patch-Only Auto-Bump

## Status

Accepted (2026-03-04)

## Context

With the decision to auto-bump versions as part of the archive convention (ADR-008), the question was which semver component to increment automatically. The plugin's changes are overwhelmingly backwards-compatible: skill tweaks, documentation updates, schema adjustments, and convention additions. These correspond to patch-level changes under semver (x.y.Z).

Minor and major version bumps carry semantic meaning -- they signal new features or breaking changes respectively -- and require human judgment to determine when they are appropriate. Automatically detecting the bump type from changelog entries or commit messages was investigated but found to be complex and unreliable, as the distinction between a "tweak" and a "feature" is subjective.

Research confirmed that 95%+ of changes in the plugin's history were patch-level. The rare minor or major bump would be an intentional human decision documented in a dedicated docs page. Auto-detecting bump type would add complexity without sufficient reliability to justify it.

The trade-off was version inflation (many small patches) versus forgotten bumps. Version inflation was the acceptable choice because consumers benefit from always having the latest changes detected by `/plugin update`, while forgotten bumps cause silent update failures.

## Decision

Patch-only auto-bump. 95%+ of changes are patches; minor/major are rare and intentional.

## Rationale

95%+ of changes are patches; minor/major are rare and intentional.

## Alternatives Considered

- Auto-detect from changelog (complex, unreliable)

## Consequences

### Positive

- Simple and predictable: every archive produces exactly one patch version increment
- Eliminates forgotten version bumps, which were the root cause of consumer update failures
- Minor/major bumps remain intentional human decisions with appropriate documentation

### Negative

- Version inflation: many small patches accumulate over time. Acceptable trade-off versus the alternative of forgotten bumps causing silent update failures.

## References

- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
- [ADR-008: Convention in Constitution, Not Skill Modification](adr-008-convention-in-constitution-not-skill-modifica.md)
