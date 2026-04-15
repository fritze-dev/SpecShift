# Implementation Tasks: Conditional Post-Merge Reminders

## 1. Foundation

- [x] 1.1. Update `src/templates/changes/tasks.md` instruction (lines 39-44): add scope-aware filtering logic for post-merge items, referencing proposal scope. Bump template-version from 3 to 4.

## 2. Implementation

- [x] 2.1. [P] Update `.specshift/CONSTITUTION.md` (line 67): add scope hint to the plugin update post-merge item describing when it applies (plugin-distributed files under `src/` or `.claude/skills/`).
- [x] 2.2. [P] Update `src/templates/constitution.md` (lines 50-51): update the example comment in the `### Post-Merge` section to show a scope-aware post-merge item. Bump template-version from 1 to 2.
- [x] 2.3. Sync template changes: run `bash scripts/compile-skills.sh` to regenerate `.claude/skills/specshift/`.

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
- [x] 3.2. Auto-Verify: generate audit.md using the audit template.
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: Classify each correction before fixing. Update all stale artifacts before re-implementing. Specs must match code before proceeding.
  - **Tweak**: wrong value/typo → fix in place
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks + re-implement
  - **Scope Change**: wrong requirements → update specs + design + re-implement fully
- [x] 3.5. Final Verify: regenerate audit.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [x] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [x] 4.2. Bump version
- [x] 4.3. Commit and push to remote
- [x] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable (e.g., `Closes #30`)
- [x] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
