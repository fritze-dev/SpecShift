---
status: active
branch: claude/fix-version-drift-ZivIM
capabilities:
  new: []
  modified: [release-workflow]
  removed: []
---
## Why

Two PRs (#34, #35) were merged between v0.2.1-beta and v0.2.2-beta without version bumps, creating changelog entries with no corresponding tags or GitHub releases. The CHANGELOG also lacks version headers, making it impossible to map entries to releases.

## What Changes

- Reformat all CHANGELOG.md entries to use `## [version] — date` headers with `### Title` sub-headers
- Consolidate the two orphan entries (#34 Conditional Post-Merge Reminders, #35 Fix Squash-Merge Commit Messages) under v0.2.2-beta
- Update the v0.2.2-beta GitHub release notes to include all three changes
- Add a "Changelog Version Header" requirement to the release-workflow spec mandating version headers in changelog entries

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `release-workflow`: Add requirement that changelog entries MUST use `## [version] — date` version headers (not date-only headers), ensuring each entry maps to a release

### Removed Capabilities

(none)

### Consolidation Check

1. Existing specs reviewed: `release-workflow.md` (covers changelog generation, automated GitHub release, version bumping)
2. Overlap assessment: The changelog format requirement belongs in `release-workflow.md` which already covers "Generate Changelog from Completed Changes" — this extends that requirement with a format constraint
3. Merge assessment: N/A — single modified capability

## Impact

- `CHANGELOG.md` — complete reformatting (all entries)
- `docs/specs/release-workflow.md` — new requirement for version headers
- GitHub Release v0.2.2-beta — release notes updated
- `release.yml` — no changes needed (sed regex already compatible with new format)

## Scope & Boundaries

**In scope:**
- CHANGELOG.md reformatting with version headers
- Orphan entry consolidation under v0.2.2-beta
- GitHub release notes update for v0.2.2-beta
- Spec update for changelog format requirement
- Version bump to v0.2.3-beta

**Out of scope:**
- Retroactive tags for #34/#35 — those changes are in v0.2.2-beta, not separate releases
- Changes to `release.yml` trigger mechanism — the current trigger is correct
- CI guardrails to prevent future drift — separate change
