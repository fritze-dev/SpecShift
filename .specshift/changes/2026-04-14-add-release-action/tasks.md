# Implementation Tasks: Add Release Action

## 1. Foundation

- [x] 1.1. Update `src/templates/workflow.md`: bump `template-version` 4→5, add `release` to `actions` array, add `release:` config block to frontmatter, add `## Action: release` section with tool-agnostic instruction
- [x] 1.2. Update `.specshift/WORKFLOW.md`: add `release` to `actions` array, add `release:` config block (`request_review: copilot`), add `## Action: release` section with project-specific instruction

## 2. Implementation

- [x] 2.1. Update `src/skills/specshift/SKILL.md`: add conditional `finalize → release` auto-dispatch in the `### finalize` dispatch section (condition: `auto_approve: true` AND `release` in `actions` array)
- [x] 2.2. Run `bash scripts/compile-skills.sh` to regenerate `.claude/skills/specshift/` from updated source files

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] `specshift release` correctly identifies PR state on invocation — PASS
  - [x] Auto-dispatch chain finalize→release when auto_approve and release in actions — PASS
  - [x] Backward-compatible: consumers without release in actions see no change — PASS
  - [x] `bash scripts/compile-skills.sh` succeeds — PASS
  - [x] Consumer template has template-version 5 and includes release action — PASS
- [x] 3.2. Auto-Verify: generate review.md using the review template.
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
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable (e.g., `Closes #X`)
- [ ] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
