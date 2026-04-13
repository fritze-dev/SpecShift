# Pre-Flight Check: Enforce Template-Version Bump

## A. Traceability Matrix

| Capability | Spec | Requirement | Scenarios | Components |
|------------|------|-------------|-----------|------------|
| workflow-contract | docs/specs/workflow-contract.md | Template-Version Bump Discipline | 4 scenarios (content change, whitespace-only, multiple templates, new template) | src/templates/ (all Smart Templates) |
| quality-gates | docs/specs/quality-gates.md | Preflight Quality Check (dim H) | 3 scenarios (unbumped detected, bumped passes, no templates changed) | src/templates/changes/preflight.md |
| quality-gates | docs/specs/quality-gates.md | Finalize Template-Version Validation | 3 scenarios (unbumped detected, bumped passes, no templates modified) | src/templates/workflow.md, src/actions/finalize.md |

All requirements have scenarios. All scenarios trace to components. **PASS**

## B. Gap Analysis

- **Edge case: template-version field missing from modified template** — Covered in quality-gates.md edge cases: "SHALL flag it as BLOCKED — the field is required by the Smart Template Format requirement." **No gap.**
- **Edge case: no merge base available** — Covered: "SHALL skip the template-version freshness check and note it." **No gap.**
- **Edge case: template renamed/moved** — Covered: "new file SHALL have template-version: 1." **No gap.**
- **Edge case: whitespace-only changes** — Covered in workflow-contract.md scenario: "SHALL NOT be required to change." **No gap.**

**PASS** — no missing edge cases.

## C. Side-Effect Analysis

| Area | Risk | Assessment |
|------|------|------------|
| Existing preflight dimensions (A-G) | Could be disrupted by adding dimension H | NONE — dimension H is additive, independent section in preflight.md |
| Finalize workflow order | Template-version check before compilation could block legitimate changes | LOW — only blocks when versions are genuinely unbumped; stop-before-compile is intentional |
| Consumer projects | Init merge detection unchanged | NONE — no changes to init logic |
| Compiled action files | finalize.md will have a new requirement link | LOW — additive change, no existing links removed |

**PASS** — no significant side-effects.

## D. Constitution Check

- Convention-based enforcement: **Consistent** — project uses convention-based enforcement per ADR-004, ADR-006, ADR-015.
- Commit conventions: **Consistent** — imperative present tense maintained.
- Template synchronization: **Consistent** — changes to `src/templates/workflow.md` will be synced to `.specshift/WORKFLOW.md`.
- AOT compilation: **Consistent** — `bash scripts/compile-skills.sh` will be run during finalize.

**PASS** — no constitution violations.

## E. Duplication & Consistency

- Template-version bump discipline in `workflow-contract.md` is the authoritative requirement. The preflight dimension in `quality-gates.md` and finalize check reference this requirement but do not duplicate it — they describe enforcement mechanisms.
- No contradictions between specs. The workflow-contract says "SHALL increment" and quality-gates says "SHALL verify that it was incremented" — consistent.

**PASS** — no duplication or contradictions.

## F. Assumption Audit

| # | Assumption | Source | Rating |
|---|-----------|--------|--------|
| 1 | The agent can compare template content between the current branch and base branch using git diff or file reads. <!-- ASSUMPTION: Git diff availability --> | design.md | Acceptable Risk — git diff is required for other preflight dimensions already |
| 2 | Whitespace-only changes are distinguishable from content changes by the agent reading the diff. <!-- ASSUMPTION: Whitespace detection --> | design.md | Acceptable Risk — the agent can inspect diff content; exact whitespace distinction is convention-based |

**PASS** — all assumptions rated Acceptable Risk.

## G. Review Marker Audit

Scanned: `docs/specs/workflow-contract.md`, `docs/specs/quality-gates.md`, `design.md`

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found.

**PASS**

## H. Template-Version Freshness

No `src/templates/` files have been modified in this change yet (specs stage only modified `docs/specs/` files). Template modifications will occur during the apply stage.

**SKIPPED** — will be validated during apply/finalize when template files are actually modified.

---

## Summary

| Dimension | Verdict |
|-----------|---------|
| A. Traceability | PASS |
| B. Gap Analysis | PASS |
| C. Side-Effect Analysis | PASS |
| D. Constitution Check | PASS |
| E. Duplication & Consistency | PASS |
| F. Assumption Audit | PASS |
| G. Review Marker Audit | PASS |
| H. Template-Version Freshness | SKIPPED (no template changes yet) |

**Overall Verdict: PASS**

0 blockers, 0 warnings.
