# Implementation Tasks: Post PR Summary Comment

## 1. Foundation

(No foundational tasks — this is a spec/template change with no shared infrastructure.)

## 2. Implementation

- [ ] 2.1. Add requirement link to `src/actions/review.md` — insert `[Pre-Merge Summary Comment]` link between Safety Limit and Merge Execution links
- [ ] 2.2. [P] Update `src/templates/workflow.md` — bump template-version 6→7, convert numbered steps to phase labels, add Pre-merge summary and Merge confirmation phases
- [ ] 2.3. [P] Update `.specshift/WORKFLOW.md` — bump template-version 6→7, mirror phase-label conversion preserving local customizations (Copilot config, worktree cleanup detail)
- [ ] 2.4. Run `bash scripts/compile-skills.sh` to regenerate `.claude/skills/specshift/actions/review.md` and `.claude/skills/specshift/templates/workflow.md`

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] Compilation succeeds with 9 requirement links extracted — PASS / FAIL
  - [ ] Compiled action contains "Pre-Merge Summary Comment" requirement block — PASS / FAIL
  - [ ] Compiled workflow template contains "Pre-merge summary" phase label — PASS / FAIL
  - [ ] Spec passes format validation: normative text before user story, `####` scenario headings, visible assumption text with HTML comment tag — PASS / FAIL
- [ ] 3.2. Auto-Verify: generate audit.md using the audit template
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: Classify each correction before fixing. Update all stale artifacts before re-implementing.
  - **Tweak**: wrong value/typo → fix in place
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks + re-implement
  - **Scope Change**: wrong requirements → update specs + design + re-implement fully
- [ ] 3.5. Final Verify: regenerate audit.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable (e.g., `Closes #29`)
- [ ] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
