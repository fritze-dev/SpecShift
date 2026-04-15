---
has_decisions: true
---
# Technical Design: Fix Version Drift

## Context

CHANGELOG.md has 15 entries using date-only headers with no version numbers. Two entries (PRs #34, #35) have no corresponding GitHub releases because they were merged without bumping `plugin.json`. The v0.2.2-beta release notes only describe PR #37 but the tag includes all three changes.

## Architecture & Components

**Files affected:**

1. `CHANGELOG.md` — reformat all entries with `## [version] — date` headers and `### Title` sub-headers. Group the two orphan entries under `## [v0.2.2-beta]`.
2. `docs/specs/release-workflow.md` — already updated (specs stage): new "Changelog Version Headers" requirement.
3. GitHub Release v0.2.2-beta — update body via MCP tools to include all three changes.
4. `src/.claude-plugin/plugin.json` — bump to 0.2.3-beta during finalize.
5. `.claude/.claude-plugin/plugin.json` — synced via compile step.

**No changes to:**
- `.github/workflows/release.yml` — the `sed` extraction already works with `## [version]` headers
- `.specshift/WORKFLOW.md` — no workflow changes
- Smart Templates — no template changes

## Goals & Success Metrics

* Every `## ` header in CHANGELOG.md contains a version number matching a git tag — PASS/FAIL by counting headers vs tags
* v0.2.2-beta GitHub release notes include all three changes (#34, #35, #37) — PASS/FAIL by reading release body
* `release.yml` sed extraction captures the full first `## [version]` block — PASS/FAIL by simulating extraction on reformatted file

## Non-Goals

- Retroactive git tags for PRs #34/#35
- CI guardrails to prevent future version drift
- Changes to `release.yml` trigger mechanism

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Consolidate orphans under v0.2.2-beta | Those commits are ancestors of the v0.2.2-beta tag — they ARE part of that release | Retroactive tags (revisionist), skip (leaves drift) |
| Use `## [version] — date` + `### Title` uniformly | Consistent format for single and multi-change versions | Compact `## [version] — date — Title` for single-change (inconsistent) |
| Release date only, no per-entry dates | Keep a Changelog standard; Git history has merge dates | Per-entry dates in parentheses (verbose) |

## Risks & Trade-offs

- [CHANGELOG reformat touches all entries] → Low risk: no semantic changes, purely formatting. Diff will be large but reviewable.
- [v0.2.2-beta release update is manual] → Acceptable: one-time fix via MCP tools.

## Open Questions

No open questions.

## Assumptions

- The `sed` extraction in `release.yml` (line 29) treats any line starting with `## ` as a section boundary. Verified by reading the regex. <!-- ASSUMPTION: sed compatibility -->
