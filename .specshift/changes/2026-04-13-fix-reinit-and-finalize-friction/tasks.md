# Implementation Tasks: Fix CLAUDE.md re-init drift + finalize version-bump conditionality

## 1. Foundation

Spec edits already completed during propose phase (specs stage).

## 2. Implementation

- [x] 2.1. [P] Update `src/templates/workflow.md` finalize step 3 — make version-bump constitution-driven (follow convention if defined, skip otherwise)
- [x] 2.2. [P] Update `src/templates/constitution.md` — add version-bump detection instructions to frontmatter and Conventions section
- [x] 2.3. [P] Update `.specshift/CONSTITUTION.md` line 48 — fix template synchronization direction
- [x] 2.4. [P] Update `CLAUDE.md` — add File Ownership section documenting `src/` vs `.specshift/` vs `docs/`

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: `project-init.md` contains "CLAUDE.md" in Template Merge paragraph — PASS
- [x] 3.2. Metric Check: `project-init.md` contains "missing standard section detected on re-init" scenario — PASS
- [x] 3.3. Metric Check: `project-init.md` Constitution Generation mentions version files — PASS
- [x] 3.4. Metric Check: `src/templates/workflow.md` finalize step 3 contains "if the constitution defines a version-bump convention" — PASS
- [x] 3.5. Metric Check: `src/templates/constitution.md` contains version-bump detection instructions — PASS
- [x] 3.6. Metric Check: `.specshift/CONSTITUTION.md` template sync says `src/templates/` is authoritative — PASS
- [x] 3.7. Metric Check: `CLAUDE.md` contains File Ownership section — PASS
- [x] 3.8. Auto-Verify: generate review.md using the review template — Verdict: PASS
- [x] 3.9. User Testing: User reviewed, identified wrong target files and plugin-specific logic in consumer templates
- [x] 3.10. Fix Loop: Corrected approach — reverted .specshift/ and release-workflow changes, made consumer templates agnostic, updated specs and all artifacts
- [x] 3.11. Final Verify: all 7 metrics PASS, out-of-scope files confirmed unchanged
- [x] 3.12. Approval: Approved by user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [x] 4.2. Bump version (0.1.0-beta → 0.1.1-beta)
- [x] 4.3. Commit and push to remote
- [x] 4.4. Update PR: mark ready for review, update body with change summary and issue references (Closes #10, Closes #11)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift`)
