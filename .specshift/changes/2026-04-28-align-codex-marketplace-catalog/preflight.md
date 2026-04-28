# Pre-Flight Check: Align Codex Marketplace Catalog Documentation

## A. Traceability Matrix

| Story | Scenarios | Components |
|-------|-----------|------------|
| Codex user installs SpecShift via verified two-step path | `Codex install resolves the plugin via the catalog`, `Codex marketplace catalog file shipped at root` (multi-target-distribution.md) | `.agents/plugins/marketplace.json`, README.md Codex install section |
| Maintainer reads spec to understand catalog schema | `Catalog declares a Git-URL source`, `Catalog declares the install policy` (multi-target-distribution.md, new Requirement "Codex Marketplace Catalog Schema") | `docs/specs/multi-target-distribution.md` v5 |
| Maintainer reads release-workflow spec to understand the four root files | The "four files" sentence in Requirement "Source and Release Directory Structure" | `docs/specs/release-workflow.md` v6 |
| Reader of AGENTS.md understands File Ownership block accurately | (no spec scenario — descriptive doc) | `AGENTS.md` File Ownership block |
| Reader of CONSTITUTION.md understands Architecture Rules accurately | (no spec scenario — descriptive doc) | `.specshift/CONSTITUTION.md` Architecture Rules block |
| Future maintainer understands Git-URL-vs-`local`-path schema decision | (no spec scenario — ADR captures decision) | `docs/decisions/adr-003-shopify-flat-multi-target-distribution.md` Decision 6 amendment |

All stories trace to at least one updated artifact. No orphaned scenarios.

## B. Gap Analysis

- **Edge cases**: covered by the rewritten Edge Case "Codex catalog schema change" in `multi-target-distribution.md`.
- **Error handling**: not applicable — doc-only change. Codex CLI handles install errors itself; no new code paths.
- **Empty states**: not applicable — the catalog file is always present (committed) for repos that ship it.
- **Migration**: covered in design.md's Migration Plan section: no migration needed for either consumer base.

No gaps.

## C. Side-Effect Analysis

- **Existing systems affected**: none functionally. The catalog file stays as-is. The compile script stays as-is. The CI workflow stays as-is.
- **Regression risk for Claude consumers**: zero — Claude marketplace at `source: "./"` is untouched.
- **Regression risk for Codex consumers**: zero — the catalog is the path that already works; we are only describing it accurately.
- **Spec-vs-implementation drift**: this change *closes* drift, doesn't introduce it.
- **Compile-script header comment drift**: lines 6–9 and 147 mention "four root files" while the code path stamps three. This drift pre-existed (introduced as a preemptive comment) and is intentionally tolerated. CHANGELOG and design.md note it as a known follow-up; no regression vs. main.

## D. Constitution Check

The constitution's "Per-target manifests at the repo root" rule is updated in this change to mention four files. The change is descriptive (matching new shipped reality), not a new rule. No new patterns introduced. No new tech-stack additions. No build-dependency changes.

The "Plugin source layout" convention (line 43 of CONSTITUTION) describes the layout — does not currently mention the catalog. Apply phase update will keep it consistent with the rule update.

No contradictions detected.

## E. Duplication & Consistency

- The "no separate Codex marketplace catalog file is shipped" sentence appears in three places (AGENTS.md L33, CONSTITUTION.md L24, release-workflow.md L359). The specs phase already updated `release-workflow.md`. AGENTS.md and CONSTITUTION.md updates are scheduled for the apply phase. All three will be consistent at end of apply.
- Schema description in `multi-target-distribution.md` (new Requirement "Codex Marketplace Catalog Schema") and the description in `AGENTS.md` File Ownership are intentionally redundant — spec is normative, AGENTS.md is descriptive cross-reference. Both list the same fields (`source.source: "url"`, `source.url`, `policy.installation: "AVAILABLE"`, `policy.authentication: "ON_INSTALL"`, `category`). No drift.
- README's "stamps the value into all three root manifest/marketplace files via `jq`" sentence stays as-is — still accurate (catalog has no `version` field). Tree diagram now shows four files; the asymmetry (4 listed, 3 stamped) is explained by the AGENTS.md and CONSTITUTION updates. Acceptable readability cost vs. rewriting the README's stamping paragraph for a descriptive nuance.

No contradictions.

## F. Assumption Audit

Collected from `design.md` and `research.md`. (No new spec assumptions added beyond the rewritten "Codex catalog-mediated install" in `multi-target-distribution.md`, which has visible text.)

| Assumption | Visible? | Rating |
|-----------|----------|--------|
| Codex CLI marketplace schema stable for our subset (`source: url`, `policy.installation: AVAILABLE`, `policy.authentication: ON_INSTALL`) | Yes (design.md) | Acceptable Risk — this is the documented schema; if it breaks we update spec + catalog together (covered by Edge Case). |
| User-verified functional state of the committed catalog file is accurate | Yes (design.md) | Acceptable Risk — user explicitly stated "wir haben den marktplatz für codex gefixed". Smoke test on a clean machine remains as a separate Issue #51 acceptance criterion. |
| `bash scripts/compile-skills.sh` continues to run without `verify_catalog_shape()` errors | Yes (design.md) | Acceptable Risk — the script never references `.agents/plugins/marketplace.json`. Verified by reading lines 26–31 and 176–178: only three files are touched. |
| Codex catalog-mediated install via Git-URL source is the verified path (replacing the falsified auto-discovery assumption) | Yes (multi-target-distribution.md) | Acceptable Risk — recorded as the spec's assumption with the falsification note. |

All assumptions have visible text and are rated Acceptable Risk. No Blocking, no Needs Clarification.

## G. Review Marker Audit

Scanning for `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` in the change artifacts and edited specs.

```
$ grep -r "<!-- REVIEW" .specshift/changes/2026-04-28-align-codex-marketplace-catalog/ docs/specs/multi-target-distribution.md docs/specs/release-workflow.md
(no matches)
```

No REVIEW markers present.

## Verdict

**PASS** — 0 blockers, 0 warnings.

All seven dimensions clear. Proceed to tests.
