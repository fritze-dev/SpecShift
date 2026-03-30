# Implementation Tasks: Fix Background Sync Race Condition

## 1. Foundation

No foundation tasks — single-file change with no dependencies.

## 2. Implementation

- [ ] 2.1. Rewrite the subagent prompt in `src/skills/archive/SKILL.md` step 4 (line 59) to convey that sync is a blocking prerequisite for archive. The prompt must explain that sync writes to `openspec/specs/` and these changes must be included in the archive commit.
- [ ] 2.2. Add a result validation gate in `src/skills/archive/SKILL.md` step 4 (between current lines 60-61). After the sync agent returns, validate the result contains a success indicator ("Specs Synced") before proceeding to step 5. If the result is ambiguous or indicates failure, stop and report.

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check: Prompt clarity — subagent prompt explicitly states sync is a blocking prerequisite — PASS / FAIL
- [ ] 3.2. Metric Check: Validation gate — archive skill contains explicit validation step checking sync agent result before step 5 — PASS / FAIL
- [ ] 3.3. Metric Check: Failure path — ambiguous or failed sync result blocks archive and reports issue — PASS / FAIL
- [ ] 3.4. Auto-Verify: Run `/opsx:verify`
- [ ] 3.5. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.6. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify.
- [ ] 3.7. Final Verify: Run `/opsx:verify` after all fixes. Skip if 3.6 was not entered.
- [ ] 3.8. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Archive change (`/opsx:archive`)
- [ ] 4.2. Generate changelog (`/opsx:changelog`)
- [ ] 4.3. Generate/update docs (`/opsx:docs`)
- [ ] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #X"`)
- [ ] 4.6. *(Post-Merge)* Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
