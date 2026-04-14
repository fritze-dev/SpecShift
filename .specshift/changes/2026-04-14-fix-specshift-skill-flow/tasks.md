# Implementation Tasks: Fix SpecShift Skill Flow Triggering

## 1. Foundation

No foundational tasks — all changes are text edits to existing files.

## 2. Implementation

- [ ] 2.1. [P] Add TRIGGER/DO NOT TRIGGER conditions to `src/skills/specshift/SKILL.md` description field (line 3)
- [ ] 2.2. [P] Strengthen workflow enforcement text in `CLAUDE.md` (line 5) to cover ALL file types and name specshift skill explicitly
- [ ] 2.3. [P] Sync enforcement text to consumer template `src/templates/claude.md` (line 17) and bump `template-version` from 1 to 2 (line 3)

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - SKILL.md description includes TRIGGER/DO NOT TRIGGER conditions — PASS / FAIL
  - CLAUDE.md says "Before editing ANY file" and names specshift skill — PASS / FAIL
  - Consumer template version bumped to 2 — PASS / FAIL
  - `compile-skills.sh` runs without errors — PASS / FAIL
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
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable (e.g., `Closes #X`)
- [ ] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
