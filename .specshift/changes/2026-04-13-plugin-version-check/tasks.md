# Implementation Tasks: Plugin Version Check

## 1. Foundation

- [ ] 1.1. Update `src/templates/workflow.md`: add `plugin-version: ""` to frontmatter, bump `template-version` from 2 to 3

## 2. Implementation

- [ ] 2.1. [P] Restructure `src/skills/specshift/SKILL.md` — rewrite Steps 1-5:
  - Step 1: Load Configuration (read WORKFLOW.md once — all frontmatter + body sections, follow Context instructions)
  - Step 2: Identify Action (parse argument, validate against loaded `actions` array, handle missing WORKFLOW.md)
  - Step 3: Plugin Version Check (skip for `init`; read `plugin.json`; compare against `plugin-version`; warn/note/silent)
  - Step 4: Change Context Detection (unchanged logic, skip for `init`)
  - Step 5: Dispatch (load compiled requirements + execute with instruction already loaded in Step 1; all subsections unchanged)
  - Update Guardrails to reflect new step structure
- [ ] 2.2. [P] Update `.specshift/WORKFLOW.md` (project instance): add `plugin-version: 0.1.3-beta`, bump `template-version` to 3
- [ ] 2.3. Sync `src/templates/workflow.md` body sections to `.specshift/WORKFLOW.md` — ensure Action instructions match (respecting intentional project-specific overrides per constitution)

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] SKILL.md reads WORKFLOW.md exactly once (Step 1) — PASS / FAIL
  - [ ] Version mismatch produces advisory warning with both versions — PASS / FAIL
  - [ ] Version match produces no output — PASS / FAIL
  - [ ] Missing `plugin-version` field produces note — PASS / FAIL
  - [ ] `init` action skips version check — PASS / FAIL
  - [ ] Template `template-version` bumped to 3 — PASS / FAIL
- [ ] 3.2. Auto-Verify: generate review.md using the review template.
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: Classify each correction before fixing.
  - **Tweak**: wrong value/typo → fix in place
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks + re-implement
  - **Scope Change**: wrong requirements → update specs + design + re-implement fully
- [ ] 3.5. Final Verify: regenerate review.md after all fixes. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
