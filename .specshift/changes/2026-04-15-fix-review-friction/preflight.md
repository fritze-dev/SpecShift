# Preflight: fix-review-friction

## A. Traceability Matrix

| Capability | Spec File | Updated | Status |
|------------|-----------|---------|--------|
| review-lifecycle | docs/specs/review-lifecycle.md | Yes (v2 → v3) | OK |

All proposed changes in the proposal map to amendments in `review-lifecycle.md`. No orphan requirements.

## B. Gap Analysis

- Clean-tree check: scenario covers dirty tree → commit/push. Clean tree case is implicit (no action needed). **OK**
- Review-pending gate: scenario covers pending review → block merge. No-pending case covered by existing merge scenario. **OK**
- Status timing: existing merge scenario updated to reflect new ordering. **OK**
- auto_approve fix: instruction-level change only, no spec scenario needed (behavior is instruction guidance, not a testable requirement). **OK**

No gaps detected.

## C. Side-Effect Analysis

- Changing status-completed timing from post-merge to pre-merge: The proposal's `status: completed` will be committed on the feature branch before merge. After squash merge, this status is part of the squash commit on main. No regression — the end state is identical, just the commit location changes.
- Review-pending gate: Could delay merge when Copilot review is slow. Acceptable — this is the intended behavior (wait for the review you requested).
- Clean-tree check: Extra commit if working tree is dirty. Acceptable — better than reviewing an incomplete diff.

No regressions identified.

## D. Constitution Check

- Commit convention: `specshift(<change-name>): <artifact>` — followed. **OK**
- Template-version discipline: Will bump 7 → 8 in both workflow files. **OK**
- Template synchronization: Changes to `src/templates/workflow.md` mirrored to `.specshift/WORKFLOW.md` with intentional project-specific differences preserved. **OK**
- Tool-agnostic instructions: No CLI-specific hardcoding introduced. **OK**

No contradictions.

## E. Duplication and Consistency

- The clean-tree prerequisite is added to the "Review Request Dispatch" requirement only — not duplicated elsewhere. **OK**
- The review-pending gate is added to "Merge Execution" requirement only. **OK**
- No contradictions with `workflow-contract.md` (config surface unchanged). **OK**

## F. Marker Audit

- Scanned `docs/specs/review-lifecycle.md`: 4 ASSUMPTION markers, all with visible text. **OK**
- No REVIEW markers found. **OK**
- Scanned design.md: "No assumptions made." **OK**

## G. Draft Spec Validation

- `docs/specs/review-lifecycle.md` has `status: stable` — not draft. **OK**
- No draft specs with mismatched `change` fields found.

## Verdict: PASS

0 blockers, 0 warnings.
