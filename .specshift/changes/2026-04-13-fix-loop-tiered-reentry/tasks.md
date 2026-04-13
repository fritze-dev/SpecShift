# Implementation Tasks: Fix Loop Tiered Re-entry

## 1. Foundation

- [x] 1.1. Run `bash scripts/compile-skills.sh` (dry run to confirm compile works before edits, establish baseline)

## 2. Implementation

- [x] 2.1. [P] Update `docs/specs/human-approval-gate.md`: add tiered re-entry classification (Tweak / Design Pivot / Scope Change), detection signals, artifact staleness rule, and three new Gherkin scenarios (classify-as-tweak, classify-as-design-pivot, design-pivot-updates-all-stale-artifacts) to the Fix Loop requirement. Update Edge Cases section with ambiguous-tier and mid-implementation-scope-change cases. Update frontmatter: status → draft, change → 2026-04-13-fix-loop-tiered-reentry, lastModified → 2026-04-13.
- [x] 2.2. [P] Update `src/templates/workflow.md` apply instruction: replace "Fix loop" + "Artifact freshness" lines with tiered classification instruction and artifact staleness rule.
- [x] 2.3. Sync `.specshift/WORKFLOW.md` apply instruction to match `src/templates/workflow.md`.
- [x] 2.4. [P] Update `src/templates/changes/tasks.md` step 3.4: add tier vocabulary (Tweak / Design Pivot / Scope Change) and artifact staleness reminder to the Fix Loop step description.
- [x] 2.5. Sync `.specshift/templates/changes/tasks.md` step 3.4 to match `src/templates/changes/tasks.md`.
- [x] 2.6. Run `bash scripts/compile-skills.sh` to regenerate `.claude/skills/specshift/actions/apply.md` from the updated WORKFLOW.md.

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
  - G1: human-approval-gate.md Fix Loop requirement defines Tweak/Design Pivot/Scope Change with detection signals — **PASS**
  - G2: human-approval-gate.md includes at least 2 new Gherkin scenarios for tiered re-entry — **PASS** (3 scenarios)
  - G3: src/templates/workflow.md apply instruction contains tier vocabulary and artifact staleness rule — **PASS**
  - G4: src/templates/changes/tasks.md step 3.4 references tier classification — **PASS**
  - G5: .specshift/WORKFLOW.md and .specshift/templates/changes/tasks.md are in sync with src counterparts — **PASS**
  - G6: scripts/compile-skills.sh runs without errors and regenerates apply.md — **PASS** (10/10 requirements extracted, 0 warnings)
- [x] 3.2. Auto-Verify: generate review.md using the review template.
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: Classify each correction before fixing — **Tweak** (wrong value/typo → fix in place) / **Design Pivot** (wrong files/approach → update design.md + re-generate affected tasks + re-implement) / **Scope Change** (wrong requirements → update specs + design + re-implement fully). Update all stale artifacts before re-implementing. Specs must match code before proceeding.
- [ ] 3.5. Final Verify: regenerate review.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references (Closes #13)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
