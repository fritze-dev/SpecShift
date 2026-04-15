# Implementation Tasks: Fix Squash-Merge Commit Messages

## 1. Foundation

No foundation tasks — all changes are to existing files.

## 2. Implementation

- [x] 2.1. [P] Update `src/templates/workflow.md` review action step 8: add squash merge commit message composition instruction. Bump `template-version` from 6 to 7.
- [x] 2.2. [P] Update `.specshift/WORKFLOW.md` review action step 8: mirror the same change, preserving project-specific worktree cleanup detail.
- [x] 2.3. [P] Update `src/skills/specshift/SKILL.md` propose step 4: change commit message format from `WIP: <change-name> — <artifact-id>` to `specshift(<change-name>): <artifact-id>`.

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - `grep -r "WIP:" src/ docs/specs/` returns zero matches in requirement text and instruction text — PASS / FAIL
  - Compiled actions at `.claude/skills/specshift/actions/review.md` contain squash commit message composition text — PASS / FAIL
  - `bash scripts/compile-skills.sh` succeeds without warnings — PASS / FAIL
  - `src/templates/workflow.md` has `template-version: 7` — PASS / FAIL
- [x] 3.2. Auto-Verify: generate audit.md using the audit template.
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: Classify each correction before fixing. Update all stale artifacts before re-implementing. Specs must match code before proceeding.
  - **Tweak**: wrong value/typo → fix in place
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks + re-implement
  - **Scope Change**: wrong requirements → update specs + design + re-implement fully
- [ ] 3.5. Final Verify: regenerate audit.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable (e.g., `Closes #31`)
- [ ] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
