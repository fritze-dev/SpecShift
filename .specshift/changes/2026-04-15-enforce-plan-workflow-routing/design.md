---
has_decisions: true
---
# Technical Design: Enforce Plan-Mode Workflow Routing

## Context

Issue #32 reports that plan mode does not enforce the specshift workflow. Plans can describe direct file edits, bypassing the `## Workflow` rule in CLAUDE.md. The `## Planning` section (from PR #28) handles scope commitment but not implementation method. This is a text-only change to three files.

## Architecture & Components

Three files affected, all Markdown:

1. **`src/templates/claude.md`** (plugin source template) — add workflow-routing paragraph to `## Planning`, bump `template-version` 3 -> 4
2. **`CLAUDE.md`** (project instance) — add same paragraph to `## Planning`
3. **`docs/specs/project-init.md`** (spec) — expand CLAUDE.md Bootstrap requirement item (2) to mention workflow routing

No code, no templates beyond claude.md, no architectural changes.

## Goals & Success Metrics

* Both `CLAUDE.md` and `src/templates/claude.md` contain the workflow-routing paragraph — PASS/FAIL
* `src/templates/claude.md` has `template-version: 4` — PASS/FAIL
* `docs/specs/project-init.md` requirement text mentions workflow routing — PASS/FAIL
* `bash scripts/compile-skills.sh` passes (validates template-version bump) — PASS/FAIL

## Non-Goals

- No required plan format or structural template for plans
- No automated enforcement or linting of plan content
- No CONSTITUTION.md changes
- No changes to specshift actions themselves

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Reference specshift skill generically, not enumerate actions | Workflow section already lists actions; avoids duplication and staleness | List all actions in paragraph (rejected: maintenance burden, two sources of truth) |
| Place rule in CLAUDE.md Planning section | Agent instructions belong in CLAUDE.md per constitution convention; Planning section is the natural home | CONSTITUTION.md (rejected: wrong file for agent behavior); new section (rejected: unnecessary) |
| Update src/templates/claude.md alongside CLAUDE.md | src/ is plugin source for consumers; per File Ownership, behavioral changes go to src/ first | Only CLAUDE.md (rejected: consumers wouldn't get the rule) |

## Risks & Trade-offs

- [Behavioral-only enforcement] No tooling validates plan content against the rule. Mitigation: the rule is simple and clear; the specshift skill TRIGGER conditions also reinforce routing. Acceptable risk.
- [Template-version bump triggers consumer WARNING] Existing consumer projects will see a warning on next `specshift init`. Mitigation: this is by design and informational only.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
