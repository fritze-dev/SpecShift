# Implementation Tasks: Enforce Template-Version in Compilation

## 1. Foundation

(no foundational setup needed — all target files already exist)

## 2. Implementation

- [x] 2.1. [P] Add template-version enforcement section to `scripts/compile-skills.sh` between Preflight and Copy sections
- [x] 2.2. [P] Add "Template-version discipline" convention to `.specshift/CONSTITUTION.md`
- [x] 2.3. [P] Update finalize instruction in `.specshift/WORKFLOW.md` to mention template-version enforcement

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] Compilation fails when template modified without version bump — PASS
  - [x] Compilation succeeds when all modified templates have bumped versions — PASS
  - [x] Compilation succeeds when no templates are modified — PASS
  - [x] Compilation skips check when no main branch exists — PASS
- [x] 3.2. Auto-Verify: generate review.md
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: Classify each correction before fixing.
  - **Tweak**: wrong value/typo → fix in place
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks
  - **Scope Change**: wrong requirements → update specs + design + re-implement
- [ ] 3.5. Final Verify: regenerate review.md after all fixes.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references (Closes #17)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
