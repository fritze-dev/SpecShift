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
| `docs/specs/project-init.md` | Spec (source of truth) | Add CLAUDE.md section check to Template Merge; update + add scenarios |
| `docs/specs/release-workflow.md` | Spec (source of truth) | Add Edge Cases section |
| `src/templates/workflow.md` | Plugin template (authoritative) | Conditionalize finalize version-bump |
| `.specshift/WORKFLOW.md` | Project instance (synced from src/) | Mirror conditional version-bump |
| `.specshift/CONSTITUTION.md` | Project conventions | Add consumer skip clause; fix sync direction |
| `CLAUDE.md` | Agent instructions | Add File Ownership section |

## Goals & Success Metrics

* `project-init.md` contains "CLAUDE.md" in the Template Merge on Re-Init paragraph — PASS/FAIL
* `project-init.md` contains scenario "missing standard section detected on re-init" — PASS/FAIL
* `release-workflow.md` contains `## Edge Cases` section with consumer-project skip — PASS/FAIL
* `src/templates/workflow.md` finalize step 3 contains conditional "if.*plugin.json.*exists" — PASS/FAIL
* `.specshift/WORKFLOW.md` finalize step 3 mirrors the conditional — PASS/FAIL
* `.specshift/CONSTITUTION.md` version-bump convention mentions "consumer projects" skip — PASS/FAIL
* `.specshift/CONSTITUTION.md` template sync convention says `src/templates/` is authoritative — PASS/FAIL
* `CLAUDE.md` contains File Ownership or equivalent section — PASS/FAIL

## Non-Goals

- Auto-fixing missing CLAUDE.md sections (user must act on WARNING)
- Changing the consumer constitution template (`src/templates/constitution.md`)
- Regenerating capability docs (done by `specshift finalize`)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| WARNING-only for CLAUDE.md (no auto-merge) | Respects "user edits are authoritative" design (spec line 424) | Full template merge — rejected, conflicts with user-authoritative design |
| Single combined change | Both issues are small friction fixes; precedent from `2026-04-08-fix-friction-batch` | Separate changes — unnecessary pipeline overhead |
| Port edge cases from capability doc to spec | Spec is source of truth; capability doc was ahead of spec | Leave in capability doc only — inconsistent, spec should be authoritative |
| Fix template sync direction in same change | Convention was wrong; bundling prevents recurring confusion | Separate issue — too small for its own change |

## Risks & Trade-offs

- [False positive WARNING] Section-level heading check uses exact heading text. If user renames `## Workflow` to `## Project Workflow`, a WARNING fires. → Acceptable: WARNINGs are advisory, not blocking.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
