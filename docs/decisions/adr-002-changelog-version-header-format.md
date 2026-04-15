# ADR-002: Changelog version header format and orphan entry consolidation

**Status:** Accepted (2026-04-15)

## Context

The project's CHANGELOG.md accumulated 15 entries using date-only headers (e.g., `## 2026-04-15 — Title`) without version numbers, making it impossible to map entries to releases. Two PRs (#34 and #35) were merged between v0.2.1-beta and v0.2.2-beta without version bumps in `plugin.json`, creating changelog entries with no corresponding tags or GitHub releases. When PR #37 bumped to v0.2.2-beta, the `release.yml` workflow captured only the topmost `## ` section, silently excluding #34 and #35 from the release notes.

Investigation confirmed that the v0.2.2-beta git tag (`3d3f89f`) sits after both orphan commits — they are part of that release. The `release.yml` sed extraction (`sed -n '/^## /{p;:a;n;/^## /q;p;ba}'`) works with any `## `-prefixed header, so the format change is backward-compatible. The Keep a Changelog standard uses `## [version] - date` headers, which the project had not adopted.

## Decision

1. **Consolidate orphan entries under the release that includes them** — PRs #34 and #35 are grouped under `## [v0.2.2-beta] — 2026-04-15` because their commits are ancestors of that tag. Creating retroactive tags would be revisionist; leaving them as orphans would perpetuate confusion.

2. **Use `## [version] — date` headers with `### Title` sub-headers uniformly** — every changelog version uses the same two-level format regardless of whether it contains one or multiple changes. This follows the Keep a Changelog convention and ensures consistency over a compact single-line format that would diverge for multi-change versions.

3. **Use only the release date in the version header, not per-entry merge dates** — the `## [version] — date` header carries the tag/release date. Individual merge dates are available in the git history. This avoids verbose per-entry date annotations while staying within the Keep a Changelog standard.

## Alternatives Considered

- **Retroactive tags for #34/#35**: Would create tags pointing to commits where `plugin.json` still shows the previous version — technically misleading.
- **Compact `## [version] — date — Title` format for single-change versions**: Less consistent when a version later acquires additional changes.
- **Per-entry dates in parentheses** (e.g., `### Title (2026-04-14)`): Adds information but clutters the changelog and diverges from Keep a Changelog.
- **Leave drift in place (forward-only fix)**: Quick but leaves consumers unable to map older entries to releases.

## Consequences

### Positive
- Every changelog entry now maps to a git tag, enabling consumers to see exactly what changed in each version
- Multi-change releases are properly represented with all changes visible
- The `release.yml` pipeline automatically produces well-formatted GitHub release notes
- Format is compatible with tooling that parses Keep a Changelog

### Negative
- Large diff for the reformatting commit (76 insertions, 52 deletions) — purely cosmetic, but creates noise in blame history
- The `release.yml` sed pipeline now includes additional transformation steps (strip version header, promote headings) — slightly more complex than the original single-line extraction

## References

- [Change: fix-version-drift](../../.specshift/changes/2026-04-15-fix-version-drift/)
- [Spec: release-workflow](../../docs/specs/release-workflow.md)
