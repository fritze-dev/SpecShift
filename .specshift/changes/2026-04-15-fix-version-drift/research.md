# Research: Fix Version Drift

## 1. Current State

**CHANGELOG.md** has 15 entries but uses date-only headers (`## 2026-04-15 — Title`) with no version numbers — only the initial entry (`## [0.1.0-beta]`) has a version.

**GitHub Releases** has 13 releases (v0.1.0-beta through v0.2.2-beta), each with a unique tag. Every release was auto-created by `.github/workflows/release.yml` when `src/.claude-plugin/plugin.json` changed on `main`.

**Drift:** Between v0.2.1-beta and v0.2.2-beta, two PRs were merged without bumping `plugin.json`:
- `35fb842` — #34 "Conditional Post-Merge Reminders" → changelog entry exists, no tag/release
- `b849fbe` — #35 "Fix Squash-Merge Commit Messages" → changelog entry exists, no tag/release

The v0.2.2-beta tag (`3d3f89f`) sits after both commits, so it includes their changes — but its release notes only describe #37 ("Enforce Plan-Mode Workflow Routing").

**Root cause:** `release.yml` triggers on `plugin.json` changes. PRs #34 and #35 didn't bump the version. When #37 bumped to 0.2.2-beta, the workflow extracted only the first `## ` section from CHANGELOG.md, skipping #34 and #35.

**Current `release.yml` extraction logic** (line 29):
```bash
NOTES=$(sed -n '/^## /{p;:a;n;/^## /q;p;ba}' CHANGELOG.md)
```
This grabs the first `## ` block — works correctly when each version has one entry, but fails when orphan entries exist above the latest release's entry.

**Current plugin.json:** `0.2.2-beta` (matches latest tag).

## 2. External Research

The [Keep a Changelog](https://keepachangelog.com/) standard uses `## [version] - date` headers. Entries within a version use `### Added/Changed/Fixed/etc.` sub-sections. This is the format referenced in the project's release-workflow spec.

The release.yml `sed` command will correctly extract a `## [v0.2.3-beta] — 2026-04-15` block — the regex matches any `## ` prefix, so the version-in-header format is fully compatible.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Consolidate orphans into v0.2.2-beta, add version headers to all entries | Honest (those changes ARE in v0.2.2-beta), fixes CHANGELOG format permanently | v0.2.2-beta release notes grow; minor history rewrite |
| B: Create retroactive tags/releases for #34 and #35 | Each change gets its own release | Tags point to commits with wrong version in plugin.json; revisionist |
| C: Only fix going forward | Minimal change | Leaves drift in place, confusing for consumers |

**Recommendation:** Approach A — consolidate + add version headers.

## 4. Risks & Constraints

- **release.yml compatibility:** The `sed` extraction must still work with the new header format. Verified: `## [v0.2.3-beta] — 2026-04-15` starts with `## `, so the regex matches.
- **Existing release notes:** Updating the v0.2.2-beta release notes on GitHub is an explicit action (not automated). Need MCP tools or `gh` CLI.
- **No spec changes needed:** This is a CHANGELOG format fix + GitHub release update. No behavioral changes to the plugin.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Reformat CHANGELOG, update GH release, bump version |
| Behavior | Clear | No plugin behavior changes |
| Data Model | Clear | No data model changes |
| UX | Clear | Consumers see accurate release notes |
| Integration | Clear | release.yml compatible with new format |
| Edge Cases | Clear | Multi-change versions use single release-date header |
| Constraints | Clear | Keep a Changelog format, release.yml sed compatibility |
| Terminology | Clear | Standard versioning terminology |
| Non-Functional | Clear | No performance/security implications |

## 6. Open Questions

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Consolidate orphan entries under v0.2.2-beta | Those changes are included in the v0.2.2-beta tag; creating retroactive tags would be revisionist | Retroactive tags (B), forward-only fix (C) |
| 2 | Use `## [version] — date` with `### Title` sub-headers uniformly | Consistent format whether a version has one or many changes | Compact single-line format for single-change versions |
| 3 | Only use release date in header, not per-entry dates | Standard Keep a Changelog convention; Git history has merge dates | Per-entry dates in parentheses |
