<!--
---
has_decisions: true
---
-->
# Technical Design: Fix CLAUDE.md re-init drift + finalize version-bump conditionality

## Context

Two friction issues (#10, #11) discovered during dogfooding across the SpecShift plugin and consumer projects. Both are spec/instruction gaps — no executable code is affected. The plugin is a Markdown/YAML artifact system where "implementation" means editing spec text, workflow instructions, and conventions.

## Architecture & Components

| File | Role | Change |
|------|------|--------|
| `docs/specs/project-init.md` | Spec (source of truth) | Add CLAUDE.md section check to Template Merge; add version file detection to Codebase Scan + Constitution Generation; update + add scenarios |
| `src/templates/workflow.md` | Plugin template (authoritative) | Make finalize version-bump constitution-driven |
| `src/templates/constitution.md` | Consumer constitution template | Add version-bump detection instructions |
| `.specshift/CONSTITUTION.md` | Project conventions | Fix template sync direction |
| `CLAUDE.md` | Agent instructions | Add File Ownership section |

## Goals & Success Metrics

* `project-init.md` contains "CLAUDE.md" in the Template Merge on Re-Init paragraph — PASS/FAIL
* `project-init.md` contains scenario "missing standard section detected on re-init" — PASS/FAIL
* `project-init.md` Constitution Generation requirement mentions version files — PASS/FAIL
* `src/templates/workflow.md` finalize step 3 contains "if the constitution defines a version-bump convention" — PASS/FAIL
* `src/templates/constitution.md` contains version-bump detection instructions — PASS/FAIL
* `.specshift/CONSTITUTION.md` template sync convention says `src/templates/` is authoritative — PASS/FAIL
* `CLAUDE.md` contains File Ownership or equivalent section — PASS/FAIL

## Non-Goals

- Auto-fixing missing CLAUDE.md sections (user must act on WARNING)
- Changing the release-workflow spec (consumer version-bump is handled via constitution-driven templates, not spec edge cases)
- Changing `.specshift/WORKFLOW.md` (project instance stays unconditional — this project has its own version-bump convention)
- Regenerating capability docs (done by `specshift finalize`)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| WARNING-only for CLAUDE.md (no auto-merge) | Respects "user edits are authoritative" design (spec line 424) | Full template merge — rejected, conflicts with user-authoritative design |
| Single combined change | Both issues are small friction fixes; precedent from `2026-04-08-fix-friction-batch` | Separate changes — unnecessary pipeline overhead |
| Constitution-driven version-bump (not `plugin.json` check) | Generalizes beyond plugin projects — any consumer with a version file gets auto-generated convention; projects without version files skip naturally | `plugin.json`-existence check — rejected, too narrow; only helps plugin projects |
| Fix template sync direction in same change | Convention was wrong; bundling prevents recurring confusion | Separate issue — too small for its own change |

## Risks & Trade-offs

- [False positive WARNING] Section-level heading check uses exact heading text. If user renames `## Workflow` to `## Project Workflow`, a WARNING fires. → Acceptable: WARNINGs are advisory, not blocking.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
