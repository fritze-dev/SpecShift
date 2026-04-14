# Implementation Tasks: Fix SpecShift Skill Flow Triggering

## 1. Foundation

No foundational tasks — all changes are text edits to existing files.

## 2. Implementation

- [x] 2.1. [P] Add TRIGGER/DO NOT TRIGGER conditions to `src/skills/specshift/SKILL.md` description field (line 3)
- [x] 2.2. [P] Strengthen workflow enforcement text in `CLAUDE.md` (line 5) to cover ALL file types and name specshift skill explicitly
- [x] 2.3. [P] Sync enforcement text to consumer template `src/templates/claude.md` (line 17) and bump `template-version` from 1 to 2 (line 3)

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - SKILL.md description includes TRIGGER/DO NOT TRIGGER conditions — PASS / FAIL
  - CLAUDE.md says "Before editing ANY file" and names specshift skill — PASS / FAIL
  - Consumer template version bumped to 2 — PASS / FAIL
  - `compile-skills.sh` runs without errors — PASS / FAIL
- [x] 3.2. Auto-Verify: generate review.md using the review template.
- [x] 3.3. User Testing: Skipped (auto_approve: true, review verdict: PASS)
- [x] 3.4. Fix Loop: Not entered (review PASS, no fixes needed)
- [x] 3.5. Final Verify: Skipped (3.4 was not entered)
- [x] 3.6. Approval: Auto-approved (auto_approve: true, review verdict: PASS)

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [x] 4.2. Bump version
- [x] 4.3. Commit and push to remote
- [x] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable (e.g., `Closes #X`)
- [x] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
