---
has_decisions: true
---
# Technical Design: Enforce Template-Version Bump

## Context

PR #16 modified `src/templates/workflow.md` and `src/templates/changes/tasks.md` without bumping their `template-version` fields. The automated review passed, and the issue was only caught during manual human review. The original design (`2026-04-08-spec-frontmatter-tracking`) accepted this as an assumption — "Plugin maintainers will remember to bump template-version when changing template content." This assumption is now invalidated.

The `template-version` field is consumed by `specshift init` merge detection logic. When versions aren't bumped, consumer projects silently miss template updates — their local copies remain stale with no merge prompt.

The project uses convention-based enforcement (agent reads instructions, follows them) rather than hard validation scripts. The fix adds the missing convention: a SHALL-statement, a preflight catch, and a finalize safety net.

## Architecture & Components

Three files need spec-level changes (already done in the specs stage):
1. **`docs/specs/workflow-contract.md`** — New "Template-Version Bump Discipline" requirement with SHALL-statement
2. **`docs/specs/quality-gates.md`** — New preflight dimension (H) "Template-Version Freshness" + new "Finalize Template-Version Validation" requirement

Four files need implementation changes:
1. **`src/templates/changes/preflight.md`** — Add Section H template for Template-Version Freshness
2. **`src/templates/workflow.md`** — Update finalize instruction to include template-version validation step
3. **`.specshift/WORKFLOW.md`** — Sync finalize instruction from src template
4. **`src/actions/finalize.md`** — Add requirement link for the new finalize validation

The enforcement operates at two points in the pipeline:
- **Preflight (during propose)**: Agent compares git diff for `src/templates/` changes against `template-version` fields. Unbumped versions → BLOCKED.
- **Finalize (before compilation)**: Agent validates all modified templates have bumped versions before running `bash scripts/compile-skills.sh`. Unbumped versions → stop before compilation.

## Goals & Success Metrics

* Preflight dimension (H) detects unbumped template-version when `src/templates/` files have content changes — verified as PASS/FAIL in review.md
* Finalize stops before compilation when template-versions are unbumped — verified as PASS/FAIL in review.md
* No false positives when templates are unchanged or when only whitespace changes — verified via edge case scenarios

## Non-Goals

- Hard enforcement via git hooks or CI scripts (contradicts convention-based philosophy)
- Automated template-version bumping (agent should flag, not silently fix)
- Changes to init merge logic (already works correctly when versions are bumped)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Convention-based enforcement (preflight + finalize instructions) rather than shell script validation | Consistent with project philosophy (ADR-004, ADR-006, ADR-015); the gap was missing convention, not missing tooling | Git pre-commit hook; CI GitHub Action; custom shell script in `scripts/` |
| Two enforcement points (preflight early, finalize late) rather than one | Preflight catches it early before implementation; finalize provides a safety net if preflight is bypassed or the change touches templates during apply | Preflight only; finalize only; review.md dimension |
| BLOCKED severity for unbumped versions in preflight | Template-version staleness directly breaks consumer init detection — this is not a warning-level issue | WARNING severity (too permissive); auto-fix (contradicts non-goal) |

## Risks & Trade-offs

- [Convention-based enforcement can still be bypassed] → Acceptable — the entire project relies on this model; adding the convention closes the specific gap identified in issue #17
- [Preflight comparison requires git diff access] → Already required for other preflight dimensions; if no merge base is available, check is skipped gracefully

## Open Questions

No open questions.

## Assumptions

- The agent can compare template content between the current branch and base branch using git diff or file reads. <!-- ASSUMPTION: Git diff availability for template comparison -->
- Whitespace-only changes are distinguishable from content changes by the agent reading the diff. <!-- ASSUMPTION: Whitespace detection capability -->
