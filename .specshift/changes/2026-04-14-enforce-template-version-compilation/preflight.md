# Pre-Flight Check: Enforce Template-Version in Compilation

## A. Traceability Matrix

No spec changes in this change — all modifications are to local project files:
- [x] Compile script validation → `scripts/compile-skills.sh`
- [x] Convention documentation → `.specshift/CONSTITUTION.md`
- [x] Finalize instruction update → `.specshift/WORKFLOW.md`

## B. Gap Analysis

- **Edge case: deleted templates** — Handled: `[[ -f "$tpl" ]] || continue` skips deleted files.
- **Edge case: new templates** — Handled: git diff shows entire file with `+` prefix, so `+template-version:` is naturally present.
- **Edge case: no main branch** — Handled: graceful skip with informational message.
- **Edge case: on main branch** — No-op (zero diff). Correct behavior.
- No gaps identified.

## C. Side-Effect Analysis

- **Compilation script**: Adding a validation step that may cause compilation to fail on feature branches with unbumped templates. This is the desired behavior (enforcement). No regression to existing passing compilations — the check only triggers when templates differ from main.
- **CONSTITUTION.md**: Adding a convention entry. No behavioral side effects.
- **WORKFLOW.md**: Minor instruction text update. No behavioral side effects.

## D. Constitution Check

The constitution currently has an "AOT compilation" convention that says to run the compile script after editing specs. This change extends the compile script but does not change the convention's applicability. A new convention entry will be added for template-version discipline.

No constitution updates needed beyond the planned convention addition.

## E. Duplication & Consistency

- No overlapping changes with other specs or changes.
- The template-version field is already defined in `workflow-contract.md` (Smart Template Format requirement). This change does not modify that definition — it adds enforcement for an existing field.

## F. Assumption Audit

| # | Assumption | Source | Rating |
|---|-----------|--------|--------|
| 1 | The `main` branch (or `origin/main`) represents the stable baseline for comparison. | design.md | Acceptable Risk — standard git branching model |
| 2 | Template files always have `template-version:` as a top-level YAML frontmatter key. | design.md | Acceptable Risk — enforced by Smart Template Format requirement in workflow-contract.md |

## G. Review Marker Audit

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found in any artifacts.

## Verdict: PASS
