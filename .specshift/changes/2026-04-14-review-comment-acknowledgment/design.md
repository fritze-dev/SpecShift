<!--
has_decisions: true
-->
# Technical Design: Review Comment Acknowledgment Convention

## Context

Issue #23 identified a gap: PR review comments are fixed in code but not replied to or resolved on GitHub. Code review is outside the specshift pipeline, so a constitution convention is the appropriate mechanism.

## Architecture & Components

- `.specshift/CONSTITUTION.md` — add convention text + standard task checkbox
- `src/skills/specshift/SKILL.md` — fix template path from `<templates_dir>/<id>.md` to `<templates_dir>/changes/<id>.md` in propose pipeline traversal (line 64)

## Goals & Success Metrics

* Convention text exists in `## Conventions` section — PASS/FAIL
* Pre-Merge checkbox exists in `## Standard Tasks` section — PASS/FAIL
* SKILL.md template path matches actual directory structure — PASS/FAIL

## Non-Goals

- Automated enforcement or tooling for the convention
- A new workflow action for review response
- Changes to the specshift pipeline

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Constitution convention (not workflow action) | Code review is outside the pipeline; convention is simplest | Workflow action (over-engineered), CLAUDE.md instruction (wrong location) |
| Both convention + checkbox | Convention defines the rule, checkbox makes it actionable in tasks.md | Convention only (less enforceable), checkbox only (less descriptive) |
| Apply to human and automated reviewers | Both deserve acknowledgment | Human-only |

## Risks & Trade-offs

No technical risks — documentation-only change.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
