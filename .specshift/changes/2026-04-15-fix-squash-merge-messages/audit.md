## Audit: Fix Squash-Merge Commit Messages

### Summary

| Dimension | Status |
|-----------|--------|
| Tasks | 3/3 complete |
| Requirements | 4/4 verified |
| Scenarios | 6/6 covered |
| Tests | 6/6 covered (manual) |
| Scope | Clean — all changed files trace to tasks |

### Detailed Verification

#### Task Completion (3/3)

- [x] 2.1. `src/templates/workflow.md` — review step 8 updated with squash commit message composition, template-version bumped 6 → 7
- [x] 2.2. `.specshift/WORKFLOW.md` — review step 8 mirrored with project-specific worktree cleanup detail preserved
- [x] 2.3. `src/skills/specshift/SKILL.md` — propose step 4 commit format changed from `WIP:` to `specshift():`; draft PR body updated

#### Requirement Verification (4/4)

1. **Merge Execution with Mandatory Confirmation (review-lifecycle)**: Spec extended with squash commit message composition text, new scenario added, edge case for missing proposal sections added. Instruction in both workflow templates updated to match. ✓
2. **Post-Artifact Commit and PR Integration (artifact-pipeline)**: Spec updated from `WIP:` to `specshift():` format. SKILL.md propose step 4 updated to match. ✓
3. **Post-Implementation Commit Before Approval (artifact-pipeline)**: Spec updated from `WIP:` to `specshift():` format. Scenario updated. ✓
4. **Implementation commit does not replace final commit (artifact-pipeline)**: Scenario renamed from "WIP commit" to "Implementation commit". ✓

#### Scenario Coverage (6/6)

1. Squash merge uses clean commit message from proposal → covered by review-lifecycle spec scenario + workflow instruction step 8
2. Proposal missing Why or What Changes → covered by review-lifecycle edge case
3. First artifact triggers branch and PR creation → artifact-pipeline spec scenario with new format
4. Subsequent artifacts commit and push only → artifact-pipeline spec scenario with new format
5. Implementation committed before user testing → artifact-pipeline spec scenario with new format
6. Implementation commit does not replace final commit → artifact-pipeline spec scenario renamed

#### Design Adherence

- Decision 1 (specshift() format): Implemented in SKILL.md step 4 and artifact-pipeline spec ✓
- Decision 2 (PR title + number): Implemented in review-lifecycle spec and workflow instruction ✓
- Decision 3 (Why + What Changes body): Implemented in review-lifecycle spec and workflow instruction ✓
- Decision 4 (Explicit squash merge): Implemented in review-lifecycle spec and workflow instruction ✓

#### Scope Control

Changed files (beyond change artifacts):
- `docs/specs/review-lifecycle.md` — traced to requirement modification in proposal
- `docs/specs/artifact-pipeline.md` — traced to requirement modification in proposal
- `src/templates/workflow.md` — traced to task 2.1
- `.specshift/WORKFLOW.md` — traced to task 2.2
- `src/skills/specshift/SKILL.md` — traced to task 2.3

All changes trace to tasks or proposal. No untraced files.

#### Spec Status Updates

- `docs/specs/review-lifecycle.md`: version 1 → 2, lastModified → 2026-04-15 (status remains stable — existing spec modified, not new)
- `docs/specs/artifact-pipeline.md`: version 3 → 4, lastModified → 2026-04-15 (status remains stable)

### Findings

#### CRITICAL

None.

#### WARNING

None.

#### SUGGESTION

None.

### Verdict

**PASS** — All tasks complete, all requirements verified, all scenarios covered, scope clean, design decisions implemented.
