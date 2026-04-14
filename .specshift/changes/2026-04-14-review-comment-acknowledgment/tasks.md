# Implementation Tasks: Review Comment Acknowledgment

## 1. Foundation

N/A — documentation-only change, no setup needed.

## 2. Implementation

- [ ] 2.1. [P] Add "Review comment acknowledgment" convention to `## Conventions` in `.specshift/CONSTITUTION.md`
- [ ] 2.2. [P] Add Pre-Merge checkbox to `## Standard Tasks` in `.specshift/CONSTITUTION.md`
- [ ] 2.3. Fix template path in `src/skills/specshift/SKILL.md` line 64: `<templates_dir>/<id>.md` → `<templates_dir>/changes/<id>.md`

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] Convention text exists in `## Conventions` — PASS / FAIL
  - [ ] Pre-Merge checkbox exists in `## Standard Tasks` — PASS / FAIL
  - [ ] SKILL.md template path matches actual directory structure — PASS / FAIL
- [ ] 3.2. Auto-Verify: generate review.md using the review template.
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: Classify each correction before fixing.
  - **Tweak**: wrong value/typo → fix in place
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks + re-implement
  - **Scope Change**: wrong requirements → update specs + design + re-implement fully
- [ ] 3.5. Final Verify: regenerate review.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references (Closes #23)
- [ ] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
