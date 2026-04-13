# Pre-Flight Check: Fix Loop Tiered Re-entry

## A. Traceability Matrix

- [ ] Modified capability `human-approval-gate` → Fix Loop requirement (tiered re-entry definition + detection signals + artifact staleness rule) → `docs/specs/human-approval-gate.md`
  - Scenario: Classify correction as Tweak — fix in place → human-approval-gate spec
  - Scenario: Classify correction as Design Pivot — update design and re-implement → human-approval-gate spec
  - Scenario: Design Pivot updates all stale artifacts → human-approval-gate spec
- [ ] Apply instruction update → `src/templates/workflow.md` + `.specshift/WORKFLOW.md`
- [ ] Tasks template step 3.4 update → `src/templates/changes/tasks.md` + `.specshift/templates/changes/tasks.md`
- [ ] AOT compilation → `.claude/skills/specshift/actions/apply.md`

## B. Gap Analysis

No gaps identified:
- Three tiers cover the full range: cosmetic fix, approach change, scope change
- Detection signals are observable facts, not subjective judgments
- Artifact staleness rule covers both Tier 2 and Tier 3
- Edge cases for ambiguous tier classification and mid-implementation Scope Change are documented in spec

## C. Side-Effect Analysis

- **Existing apply behavior**: The QA Loop steps 3.1–3.3, 3.5, 3.6 are unchanged. Only step 3.4 gains more specific guidance.
- **Existing changes in progress**: Not affected. The tiered re-entry applies to future fix loop invocations.
- **Compiled action file**: `apply.md` will be regenerated. The compiled file is a pure extraction of the WORKFLOW.md apply instruction — no other action files are affected.
- **Consumer projects**: The updated `src/templates/workflow.md` will be distributed to consumers on next install/update. The tier vocabulary is additive — consumers benefit from clearer guidance.
- **No regression risks**: All changes are text additions/refinements to existing requirements and instructions.

## D. Constitution Check

- **Template sync direction** (CONSTITUTION.md line 48): Changes go `src/templates/` → `.specshift/`. Both `workflow.md` and `tasks.md` are updated in `src/` first and synced to `.specshift/`. ✓
- **AOT compilation** (CONSTITUTION.md line 43): After editing specs, run `bash scripts/compile-skills.sh`. Task 1.1 covers this. ✓
- **Tool-agnostic instructions** (CONSTITUTION.md line 50): The updated apply instruction uses intent language ("classify", "update", "re-implement"), not CLI commands. ✓
- **No ADR references in specs** (CONSTITUTION.md line 48): The updated spec text contains no ADR references. ✓

## E. Duplication & Consistency

- No overlap between the Fix Loop change and other specs. `task-implementation.md` covers apply task execution (not fix loop classification). `quality-gates.md` covers preflight/review dimensions (not fix loop re-entry).
- The three-tier vocabulary (Tweak / Design Pivot / Scope Change) is new and not duplicated elsewhere.
- `human-approval-gate.md` spec version bumped from 3 to draft (will become 4 on finalize). ✓

## F. Assumption Audit

From `design.md`:
- "The `bash scripts/compile-skills.sh` script successfully extracts the updated apply instruction from WORKFLOW.md into the compiled action file." → **Acceptable Risk** (compile script is tested via finalize; any failure is caught immediately)
- "Agents reading the updated apply instruction will apply the tier classification before patching." → **Acceptable Risk** (the new instructions are explicit and observable; cannot guarantee agent compliance without runtime testing)

From updated `docs/specs/human-approval-gate.md`:
- "Spec updates during the fix loop do not require re-running the full artifact pipeline (preflight is not re-triggered automatically)." → **Acceptable Risk** (unchanged from prior version)
- "The fix loop does not have a maximum iteration count; it continues until the user is satisfied." → **Acceptable Risk** (unchanged from prior version)

## G. Review Marker Audit

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found in any affected files.

**Verdict: PASS**
