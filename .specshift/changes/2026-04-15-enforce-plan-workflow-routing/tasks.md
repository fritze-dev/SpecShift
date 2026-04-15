# Implementation Tasks: Enforce Plan-Mode Workflow Routing

## 1. Foundation

No foundation tasks — this is a text-only change to existing files.

## 2. Implementation

- [x] 2.1. [P] Add workflow-routing paragraph to `src/templates/claude.md` `## Planning` section (after "For trivial changes..." paragraph) and bump `template-version` from 3 to 4
- [x] 2.2. [P] Add identical workflow-routing paragraph to `CLAUDE.md` `## Planning` section (after "For trivial changes..." paragraph)
- [x] 2.3. Verify `docs/specs/project-init.md` CLAUDE.md Bootstrap requirement (line 274) mentions workflow routing (already done during specs stage)

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] Both `CLAUDE.md` and `src/templates/claude.md` contain the workflow-routing paragraph — PASS
  - [x] `src/templates/claude.md` has `template-version: 4` — PASS
  - [x] `docs/specs/project-init.md` requirement text mentions workflow routing — PASS
  - [x] `bash scripts/compile-skills.sh` passes — PASS
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
- [x] 4.4. Update PR: mark ready for review, update body with change summary and issue references (Closes #32)
- [ ] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
