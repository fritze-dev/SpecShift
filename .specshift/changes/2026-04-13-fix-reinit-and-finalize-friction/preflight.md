# Pre-Flight Check: Fix CLAUDE.md re-init drift + finalize version-bump conditionality

## A. Traceability Matrix

- [x] Template Merge on Re-Init (project-init.md) → CLAUDE.md section-level check paragraph → `docs/specs/project-init.md`
- [x] CLAUDE.md Bootstrap (project-init.md) → Updated scenario + new scenario → `docs/specs/project-init.md`
- [x] First-Run Codebase Scan (project-init.md) → Version file detection → `docs/specs/project-init.md`
- [x] Constitution Generation (project-init.md) → Version-bump convention generation → `docs/specs/project-init.md`
- [x] Finalize instruction → Constitution-driven version-bump → `src/templates/workflow.md`
- [x] Consumer constitution template → Version-bump detection instructions → `src/templates/constitution.md`
- [x] Template synchronization convention → Fix direction → `.specshift/CONSTITUTION.md`
- [x] Agent instructions → File Ownership section → `CLAUDE.md`

## B. Gap Analysis

No gaps identified. Both issues have well-defined expected behavior documented in the GitHub issues. The CLAUDE.md section check is WARNING-only (non-blocking), which is appropriate for a user-authoritative file. The consumer version-bump is handled via constitution-driven templates — no release-workflow spec changes needed.

## C. Side-Effect Analysis

- **project-init.md**: Adding a paragraph, scenarios, and extending existing requirements does not affect other requirements. The existing fresh-init and recovery-mode behaviors are unchanged.
- **src/templates/workflow.md**: Finalize step 3 becomes constitution-driven — consumer projects without a version-bump convention skip silently; projects with one follow it.
- **src/templates/constitution.md**: Adding version-bump detection instructions is additive. The template skeleton gains guidance for constitution generation but doesn't change existing section structure.
- **CONSTITUTION.md**: Template sync direction fix corrects a documentation error — no behavioral change (the actual sync has always been manual).
- **.specshift/WORKFLOW.md**: Intentionally NOT changed — this project has its own version-bump convention that stays unconditional.

## D. Constitution Check

Yes — CONSTITUTION.md is being updated in this change:
1. Template synchronization convention gets corrected direction

## E. Duplication & Consistency

- The consumer workflow template (`src/templates/workflow.md`) and project instance (`.specshift/WORKFLOW.md`) intentionally differ: consumer uses constitution-driven version-bump, project uses explicit plugin.json bump. This is consistent with the template synchronization convention (skill reference phrasing and project-specific overrides may differ).
- No contradictions with other specs.

## F. Assumption Audit

No `<!-- ASSUMPTION -->` markers found in specs or design for this change.

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found.

## Verdict: PASS
