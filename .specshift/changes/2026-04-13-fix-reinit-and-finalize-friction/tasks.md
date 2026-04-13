# Implementation Tasks: Fix CLAUDE.md re-init drift + finalize version-bump conditionality

## 1. Foundation

Spec edits already completed during propose phase (specs stage).

## 2. Implementation

- [ ] 2.1. [P] Update `src/templates/workflow.md` finalize step 3 — make version-bump conditional on `plugin.json` existence
- [ ] 2.2. [P] Update `.specshift/WORKFLOW.md` finalize step 3 — mirror conditional from `src/templates/workflow.md`
- [ ] 2.3. [P] Update `.specshift/CONSTITUTION.md` line 40 — add consumer-project skip clause to version-bump convention
- [ ] 2.4. [P] Update `.specshift/CONSTITUTION.md` line 48 — fix template synchronization direction
- [ ] 2.5. [P] Update `CLAUDE.md` — add File Ownership section documenting `src/` vs `.specshift/` vs `docs/`

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check: `project-init.md` contains "CLAUDE.md" in Template Merge paragraph — PASS / FAIL
- [ ] 3.2. Metric Check: `project-init.md` contains "missing standard section detected on re-init" scenario — PASS / FAIL
- [ ] 3.3. Metric Check: `release-workflow.md` contains `## Edge Cases` section — PASS / FAIL
- [ ] 3.4. Metric Check: `src/templates/workflow.md` finalize step 3 contains conditional — PASS / FAIL
- [ ] 3.5. Metric Check: `.specshift/WORKFLOW.md` finalize step 3 mirrors conditional — PASS / FAIL
- [ ] 3.6. Metric Check: `.specshift/CONSTITUTION.md` version-bump convention mentions "consumer projects" — PASS / FAIL
- [ ] 3.7. Metric Check: `.specshift/CONSTITUTION.md` template sync says `src/templates/` is authoritative — PASS / FAIL
- [ ] 3.8. Metric Check: `CLAUDE.md` contains File Ownership section — PASS / FAIL
- [ ] 3.9. Auto-Verify: generate review.md using the review template
- [ ] 3.10. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.11. Fix Loop: On verify issues or bug reports → fix → re-verify.
- [ ] 3.12. Final Verify: regenerate review.md after all fixes. Skip if 3.11 was not entered.
- [ ] 3.13. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references (Closes #10, Closes #11)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift`)
