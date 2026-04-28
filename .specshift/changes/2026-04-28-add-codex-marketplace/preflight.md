# Pre-Flight Check: Add Codex Marketplace Catalog File

## Summary

| Verdict | Blockers | Warnings |
|---------|----------|----------|
| PASS | 0 | 0 |

## A. Traceability Matrix

| Story | Spec | Requirement | Scenarios | Components |
|-------|------|-------------|-----------|------------|
| As a Codex user I want to install SpecShift directly from its GitHub repository | docs/specs/multi-target-distribution.md | Codex Discovery via Marketplace Add | Codex install resolves via catalog; Codex marketplace catalog file shipped | `.agents/plugins/marketplace.json`, `.codex-plugin/plugin.json`, README Codex section |
| As a Codex user I want the marketplace catalog file to follow the documented Codex schema exactly | docs/specs/multi-target-distribution.md | Codex Marketplace Catalog Schema | Catalog file declares the documented top-level fields; Catalog plugin entry uses object-form source; Catalog plugin entry omits version field | `.agents/plugins/marketplace.json`, `scripts/compile-skills.sh` (shape verifier) |
| As a maintainer I want released artifacts to always agree on the version, including the new catalog file | docs/specs/multi-target-distribution.md | Symmetric Version Stamping with Cross-Check | All three version-bearing files stamped from one source; Post-stamp cross-check fails on drift; Codex catalog file shape-checked but not version-stamped; Release CI cross-check includes catalog file; Workflow template version stamped from same source | `scripts/compile-skills.sh`, `.github/workflows/release.yml` |
| As a new user I want to find install instructions for my AI tool of choice | docs/specs/multi-target-distribution.md | Multi-Target Install Documentation | README contains both install sections (updated to require correct Codex commands + Update subsection); Future target addition follows the same pattern | `README.md` |

All requirement scenarios trace to a defined component. The new Requirement "Codex Marketplace Catalog Schema" introduces three scenarios all anchored to the new file.

## B. Gap Analysis

- **File-permissions gap**: not applicable — `.agents/plugins/marketplace.json` is a static JSON file, no special permissions required.
- **Empty-state gap**: not applicable — the catalog ships with one plugin entry and stays at one entry until SpecShift adopts a multi-plugin layout (out of scope for this change).
- **Error-state gap (malformed catalog)**: covered by the new shape verifier in `scripts/compile-skills.sh` and the shape check in `.github/workflows/release.yml` cross-check loop. Both fail loudly with maintainer-actionable error messages.
- **Backward-compatibility gap**: existing Claude Code consumers are unaffected — no Claude file is changed. Existing Codex consumers who failed to install will now succeed; consumers who somehow had a working install path against the prior layout (none reported) would also continue to work because `.codex-plugin/plugin.json` remains in place.
- **Schema-evolution gap**: covered by the Edge Case "Codex marketplace catalog schema change" — additive schema fields are preserved verbatim by the build; deletions or renames require a maintainer edit, which is the same posture as `.codex-plugin/plugin.json` itself.

No gaps found.

## C. Side-Effect Analysis

| System | Risk | Mitigation |
|--------|------|------------|
| Claude Code distribution | None — no Claude file modified | Audit verifies `.claude-plugin/` files are byte-identical to pre-change |
| Existing Codex installs | New file may conflict with consumer-cached marketplace state | Codex CLI documented behavior is to refresh on `marketplace update`; README Update subsection instructs consumers to run it once |
| `scripts/compile-skills.sh` | Adding a fourth file to preflight may break runs in repos that don't have the catalog file yet | The script preflight already errors on missing files; the catalog file lands in the same commit as the script change, so the script's first run after this change finds it present |
| `.github/workflows/release.yml` | Cross-check now includes the catalog | The catalog file is committed before any push to `main` triggers release; CI will see it |
| Plugin version stamping | `src/VERSION` continues to drive only the three version-bearing files | Spec scenario "Codex catalog file shape-checked but not version-stamped" makes this explicit |
| Existing tags / past releases | Past tagged versions did not ship the catalog | Past tags are immutable; this change applies to the next release (`0.2.6-beta`) and forward |

No regressions identified.

## D. Constitution Check

- **Multi-target distribution paragraph** in `.specshift/CONSTITUTION.md` Architecture Rules currently asserts "no separate Codex marketplace catalog file is shipped." This contradicts the proposal. **Resolution**: the implementation phase updates this paragraph as part of the change. Tracked as a task. No blocker.
- **Per-target manifest hand-edit rule**: respected — the new catalog file is hand-edited at the repo root, identical posture to `.claude-plugin/marketplace.json`.
- **`src/VERSION` SoT rule**: respected — the catalog has no `version` field, so SoT remains unchanged. The spec change makes the four-file vs three-version-bearing-files distinction explicit.
- **Tool-agnostic instruction rule**: respected — the spec uses prose like "the Codex marketplace catalog file" rather than tool-specific environment variables.
- **AOT compilation rule**: respected — the new catalog file's path is added to the compile script and CI cross-check; no `src/templates/` template was touched (no template-version bump needed).
- **`### Pre-Merge` standard task** "Update PR: mark ready for review, update body with change summary and issue references": will be executed during apply phase before merge.

No constitutional contradictions remain after the planned narrative updates.

## E. Duplication & Consistency

- The Codex distribution surface is now described in three places: `docs/specs/multi-target-distribution.md` (authoritative), `docs/decisions/adr-003-shopify-flat-multi-target-distribution.md` (decision history), `AGENTS.md` File Ownership (consumer-facing rule), `.specshift/CONSTITUTION.md` Architecture Rules (project-internal rule), and `README.md` Multi-Target Distribution section (user-facing). All five surfaces are updated in this change. Cross-checked manually.
- No new duplication introduced. The `.agents/plugins/marketplace.json` file's schema is documented once in the new spec requirement and referenced (not redefined) elsewhere.
- The compile script's existing top-of-file comment mentions four files (lines 6–9 reference `.agents/plugins/marketplace.json`); the implementation phase brings the script body into agreement with this comment. No comment churn.

## F. Assumption Audit

| # | Assumption | Source | Visible Text? | Rating |
|---|------------|--------|---------------|--------|
| 1 | The Codex marketplace catalog schema documented at developers.openai.com is authoritative for the listed fields | design.md | Yes | Acceptable Risk — the schema fields used in this change are pre-cited in `multi-target-distribution.md` (existing text from PR #46) and ADR-003. Risk: schema drift; mitigation: jq preserves non-version fields verbatim. |
| 2 | The `policy.installation` baseline `AVAILABLE` and `policy.authentication` baseline `ON_INSTALL` are accepted by current Codex | design.md | Yes | Verified locally against `codex-cli 0.125.0`; invalid prior values were rejected before marketplace add completed. |
| 3 | Relative paths in `plugins[].source.path` resolve from the marketplace root and must point at a non-empty plugin root | design.md | Yes | Verified locally: `./` is skipped by `/plugins`, escaping paths are rejected, and `./plugins/specshift` works with a generated payload. |
| 4 | A re-run of `codex plugin marketplace add fritze-dev/SpecShift` after this change lands on `main` will succeed | design.md | Yes | Acceptable Risk — local verification succeeded for an equivalent local marketplace layout; post-merge verification remains required against GitHub main. |
| 5 | The Codex CLI plugin manifest schema (`.codex-plugin/plugin.json`) and skill discovery paths described in OpenAI's documentation are stable as of 2026-04-28 | docs/specs/multi-target-distribution.md (existing, retained) | Yes | Acceptable Risk — pre-existing assumption from PR #46, retained. |
| 6 | Claude Code's `@AGENTS.md` import syntax loads the referenced file into the session context at startup | docs/specs/multi-target-distribution.md (existing, retained) | Yes | Acceptable Risk — pre-existing assumption from PR #46, unaffected by this change. |
| 7 | Codex catalog-driven install (REPLACES the falsified single-plugin auto-discovery assumption) | docs/specs/multi-target-distribution.md | Yes | Acceptable Risk — this is the corrected assumption replacing the falsified one; the spec records the falsifying observation inline. |
| 8 | Both Claude Code and Codex resolve plugin-bundled assets referenced in skill prose relative to the skill's installed location | docs/specs/multi-target-distribution.md (existing, retained) | Yes | Acceptable Risk — pre-existing assumption from PR #46. |
| 9 | `jq` is available on every maintainer's build machine | docs/specs/multi-target-distribution.md (existing, retained) | Yes | Acceptable Risk — pre-existing assumption; the new shape verifier also uses jq, identical posture. |

All assumptions have visible text. No invisible-only assumption tags found. No Blocking ratings.

## G. Review Marker Audit

Scanned all change artifacts (`research.md`, `proposal.md`, `design.md`) and the modified spec (`docs/specs/multi-target-distribution.md`). No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found.

## Verdict

**PASS** — 0 blockers, 0 warnings. Proceed to tests.
