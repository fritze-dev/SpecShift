# Implementation Tasks: Review Workflow Artifacts

## 1. Foundation

No foundation tasks — all changes are line-level edits to existing files.

## 2. Implementation

- [ ] 2.1. [P] Fix 1: Remove compile step from consumer template (`src/templates/workflow.md` line 78) and bump `template-version` 3→4
- [ ] 2.2. [P] Fix 2: Replace hardcoded version-bump in project WORKFLOW.md (`.specshift/WORKFLOW.md` line 77) with delegation phrasing
- [ ] 2.3. [P] Fix 3: Remove preflight reference from `src/actions/init.md` (line 8)
- [ ] 2.4. Fix 4a: Remove auto-dispatch language from consumer template (`src/templates/workflow.md` lines 42, 62, 68)
- [ ] 2.5. Fix 4b: Remove auto-dispatch language from project WORKFLOW.md (`.specshift/WORKFLOW.md` lines 42, 62, 68)
- [ ] 2.6. Fix 5: Remove design checkpoint convention from `.specshift/CONSTITUTION.md` (line 49)
- [ ] 2.7. Sync `.specshift/WORKFLOW.md` template-version to 4 (matching consumer template bump)

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
  - `compile-skills.sh` exits 0
  - Compiled `init.md` contains 0 references to "Preflight Quality Check"
  - Compiled `workflow.md` has `template-version: 4` and 0 occurrences of "compile-skills"
  - `diff` consumer vs project shows only expected differences
  - `grep "auto-continue\|auto-dispatch" src/templates/workflow.md` returns 0
  - `grep "Design review checkpoint" .specshift/CONSTITUTION.md` returns 0
- [ ] 3.2. Auto-Verify: generate review.md using the review template.
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: Classify each correction before fixing. Update all stale artifacts before re-implementing. Specs must match code before proceeding.
  - **Tweak**: wrong value/typo → fix in place
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks + re-implement
  - **Scope Change**: wrong requirements → update specs + design + re-implement fully
- [ ] 3.5. Final Verify: regenerate review.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] Update PR: mark ready for review, update body with change summary and issue references if applicable (e.g., `Closes #X`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
