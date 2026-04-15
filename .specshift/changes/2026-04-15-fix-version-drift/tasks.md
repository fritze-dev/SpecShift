# Implementation Tasks: Fix Version Drift

## 1. Foundation

(No foundation work needed — this is a documentation/formatting fix.)

## 2. Implementation

- [ ] 2.1. Reformat CHANGELOG.md: add `## [version] — date` headers to all entries, use `### Title` sub-headers, consolidate orphan entries (#34, #35) under `## [v0.2.2-beta] — 2026-04-15`
- [ ] 2.2. Update v0.2.2-beta GitHub release notes to include all three changes (#34, #35, #37)
- [ ] 2.3. Verify `release.yml` sed extraction works with new format: run `sed -n '/^## /{p;:a;n;/^## /q;p;ba}' CHANGELOG.md` and confirm full block is captured

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] Every `## ` header in CHANGELOG.md has a version matching a git tag — PASS / FAIL
  - [ ] v0.2.2-beta GitHub release notes include all three changes — PASS / FAIL
  - [ ] sed extraction captures full first `## [version]` block — PASS / FAIL
- [ ] 3.2. Auto-Verify: generate audit.md using the audit template.
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: Classify each correction before fixing. Update all stale artifacts before re-implementing. Specs must match code before proceeding.
  - **Tweak**: wrong value/typo → fix in place
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks + re-implement
  - **Scope Change**: wrong requirements → update specs + design + re-implement fully
- [ ] 3.5. Final Verify: regenerate audit.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable
- [ ] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`) — applies when change modifies files under `src/` or `.claude/skills/`
