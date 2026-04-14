---
has_decisions: true
---
# Technical Design: Review Workflow Artifacts

## Context

The SpecShift plugin's three-layer architecture defines clear boundaries: Constitution (rules), WORKFLOW.md (orchestration), SKILL.md (dispatch). A cross-layer audit found 5 violations where content leaked across boundaries or was duplicated. All fixes are line-level edits — no architectural changes needed.

## Architecture & Components

All changes are within existing files. No new files, modules, or patterns introduced.

| File | Layer | Change |
|------|-------|--------|
| `src/templates/workflow.md` | Schema (consumer) | Remove compile step (line 78), remove auto-dispatch language (lines 42, 62, 68), bump template-version 3→4 |
| `.specshift/WORKFLOW.md` | Schema (project) | Delegate version-bump (line 77), remove auto-dispatch language (lines 42, 62, 68) |
| `.specshift/CONSTITUTION.md` | Constitution | Remove design checkpoint convention (line 49) |
| `src/actions/init.md` | Actions | Remove preflight reference (line 8) |
| `.claude/skills/specshift/` | Compiled | Regenerated via `compile-skills.sh` |

## Goals & Success Metrics

* `compile-skills.sh` exits 0 after all edits
* Compiled `init.md` contains 0 references to "Preflight Quality Check"
* Compiled `workflow.md` has `template-version: 4` and 0 occurrences of "compile-skills"
* `diff src/templates/workflow.md .specshift/WORKFLOW.md` shows only expected differences: worktree config, plugin-version, compile step, skill-reference phrasing
* `grep -c "auto-continue\|auto-dispatch" src/templates/workflow.md` returns 0
* `grep -c "Design review checkpoint" .specshift/CONSTITUTION.md` returns 0

## Non-Goals

* Changing SKILL.md auto-dispatch logic (already correct)
* Changing how `auto_approve` works behaviorally
* Restructuring the three-layer architecture

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Remove auto-dispatch from WORKFLOW.md, keep in SKILL.md | Auto-dispatch is inter-action chaining — a router mechanical concern. SKILL.md lines 72/79 already handle it. The `workflow-contract.md` spec scenario "Router auto-dispatches" assigns it to the router. | Keep in both (rejected: DRY violation, drift risk) |
| Remove design checkpoint from Constitution, keep in WORKFLOW.md | The `## Context` section enforces reading CONSTITUTION.md anyway. The checkpoint is an operational detail of the propose action, not a project-wide governance rule. `three-layer-architecture.md` Layer Separation says constitution SHALL NOT embed workflow instruction details. | Keep in both (rejected: violates Layer Separation), Move to Constitution only (rejected: operational details belong in action instructions) |
| Consumer template finalize: 3 steps, project: 4 steps | Compile step is SpecShift-specific. Consumer projects don't have `scripts/compile-skills.sh`. The project instance adds it as a legitimate project-specific override. | Keep compile in consumer with "if script exists" guard (rejected: unnecessary complexity, step should not exist for consumers) |

## Risks & Trade-offs

* [Removing auto-dispatch language could cause agent to not auto-continue] → Mitigated: SKILL.md dispatch sections explicitly handle this. The Workflow instruction is read by the same agent that reads the Skill dispatch — the Skill dispatch takes precedence.
* [Design checkpoint removal from Constitution could be forgotten] → Mitigated: Rule remains in WORKFLOW.md propose instruction line 40. Agent reads both Constitution and WORKFLOW.md.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
