# Pre-Flight Check: Fix Background Sync Race Condition

## A. Traceability Matrix

- [x] "Archive Completed Change" (modified) → Scenario: Auto-sync before archiving → `src/skills/archive/SKILL.md` step 4 (subagent prompt)
- [x] "Archive Completed Change" (modified) → Scenario: Sync agent result validation prevents premature archive → `src/skills/archive/SKILL.md` step 4 (new validation gate)
- [x] "Archive Completed Change" (modified) → Scenario: Sync agent reports failure → `src/skills/archive/SKILL.md` step 4 (existing failure path, reinforced by validation)
- [x] Edge case: Sync agent result is ambiguous → `src/skills/archive/SKILL.md` step 4 (validation treats ambiguous as failure)

## B. Gap Analysis

No gaps identified. The change is narrow:
- Subagent prompt rewrite: single bullet point in step 4
- Result validation: new bullet point between existing lines 60-61
- All failure paths (sync fails, ambiguous result) converge to "stop and report"

## C. Side-Effect Analysis

- **Sync skill**: Not modified. The sync skill's output format ("Specs Synced: <name>") is used for validation but not changed.
- **Other archive steps**: Steps 1-3 and 5-7 are untouched. Only step 4 changes.
- **Other skills invoking sync**: `/opsx:sync` standalone is unaffected — the fix is only in the archive skill's invocation path.
- **Regression risk**: Minimal. The prompt change improves context; the validation is a new gate that only blocks on failure/ambiguity.

## D. Constitution Check

No constitution changes needed. The skill immutability rule is respected — this is a bug fix to the archive skill, not a project-specific behavior.

## E. Duplication & Consistency

- The delta spec's "Auto-sync before archiving" scenario is consistent with the existing baseline scenario but adds the subagent prompt and validation requirements.
- The new "Sync agent result validation prevents premature archive" scenario does not overlap with the existing "Sync failure" edge case — it covers the validation gate mechanism, while the edge case covers the failure response.
- No contradictions with `spec-sync` spec — its assumption about sequential execution is reinforced by this fix.

## F. Assumption Audit

| Source | Assumption | Visible Text | Rating |
|--------|-----------|--------------|--------|
| design.md | `<!-- ASSUMPTION: Sync output format stability -->` | "The sync skill's output format ('Specs Synced: <name>' on success) is stable and can be used as a validation signal." | Acceptable Risk — the format is documented in the sync skill and under our control. If it changes, the validation should fail safe (ambiguous = block). |

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any artifacts.
