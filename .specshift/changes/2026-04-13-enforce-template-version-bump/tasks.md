# Implementation Tasks: Enforce Template-Version Bump

## 1. Foundation

(No foundation tasks — specs already updated in the specs stage.)

## 2. Implementation

- [x] 2.1. [P] Add Section H to preflight template: edit `src/templates/changes/preflight.md` to add `## H. Template-Version Freshness` section with instructions for checking `src/templates/` changes against `template-version` fields
- [x] 2.2. [P] Update finalize instruction in `src/templates/workflow.md`: add a template-version validation step between "Check review.md exists" and "Compile" (step 3.5: "Template-version validation: for each file under `src/templates/` modified in this change, verify template-version was incremented; stop before compilation if not")
- [x] 2.3. Sync finalize instruction to `.specshift/WORKFLOW.md`: copy the updated finalize instruction from `src/templates/workflow.md` to `.specshift/WORKFLOW.md`
- [x] 2.4. [P] Add requirement link in `src/actions/finalize.md`: add link to the new "Finalize Template-Version Validation" requirement from `docs/specs/quality-gates.md`
- [x] 2.5. Bump `template-version` in modified templates: increment `template-version` in `src/templates/changes/preflight.md` (1→2) and `src/templates/workflow.md` (2→3), and sync `preflight.md` to `.specshift/templates/changes/preflight.md` and `workflow.md` to `.specshift/WORKFLOW.md`

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] Preflight dimension (H) detects unbumped template-version — PASS
  - [x] Finalize stops before compilation when template-versions are unbumped — PASS
  - [x] No false positives when templates are unchanged — PASS
- [x] 3.2. Auto-Verify: generate review.md using the review template
- [x] 3.3. User Testing: auto_approve is true — skipped.
- [x] 3.4. Fix Loop: not entered (no fixes needed).
- [x] 3.5. Final Verify: skipped (3.4 was not entered).
- [x] 3.6. Approval: auto_approve is true — proceeding to finalize.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references (Closes #17)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
