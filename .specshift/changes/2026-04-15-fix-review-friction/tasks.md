# Implementation Tasks: fix-review-friction

## 1. Foundation

N/A — no shared infrastructure needed. All changes are text amendments.

## 2. Implementation

- [x] 2.1. [P] Edit `src/templates/workflow.md`: insert clean-tree check bullet between Draft transition and Review dispatch
- [x] 2.2. [P] Edit `src/templates/workflow.md`: insert review-pending gate bullet between Pre-merge summary and Merge confirmation
- [x] 2.3. [P] Edit `src/templates/workflow.md`: replace auto_approve wording (line 102) with explicit `request_review` config reference
- [x] 2.4. [P] Edit `src/templates/workflow.md`: move "Set proposal status: completed" to before merge in Merge execution bullet
- [x] 2.5. Edit `src/templates/workflow.md`: bump template-version 7 → 8
- [x] 2.6. [P] Edit `.specshift/WORKFLOW.md`: mirror changes 2.1-2.4, preserving project-specific wording
- [x] 2.7. Edit `.specshift/WORKFLOW.md`: bump template-version 7 → 8

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [ ] Compiled action file includes new scenarios (clean-tree, review-pending gate) — PASS / FAIL
  - [ ] Both workflow files have template-version 8 — PASS / FAIL
  - [ ] `scripts/compile-skills.sh` exits 0 — PASS / FAIL
- [x] 3.2. Auto-Verify: generate audit.md using the audit template.
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: Classify each correction before fixing. Update all stale artifacts before re-implementing. Specs must match code before proceeding.
  - **Tweak**: wrong value/typo → fix in place
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks + re-implement
  - **Scope Change**: wrong requirements → update specs + design + re-implement fully
- [ ] 3.5. Final Verify: regenerate audit.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [x] 4.2. Bump version
- [x] 4.3. Commit and push to remote
- [x] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable (e.g., `Closes #X`)
- [x] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`) — applies when change modifies files under `src/` or `.claude/skills/`
