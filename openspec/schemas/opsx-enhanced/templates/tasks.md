# Implementation Tasks: [Feature Name]

## 1. Foundation
<!-- Shared infrastructure, setup, dependencies — must complete first -->
- [ ] 1.1. [Task description]

## 2. Implementation
<!-- Group by feature/story. Mark independent tasks with [P]. -->
- [ ] 2.1. [P] [Task description]
- [ ] 2.2. [Task description]

## 3. QA Loop & Human Approval
- [ ] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
- [ ] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before archiving.
- [ ] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)
<!-- Universal post-implementation steps. Always include this section.
     If the constitution defines ## Standard Tasks, append those items after these. -->
- [ ] 4.1. Archive change (`/opsx:archive`)
- [ ] 4.2. Generate changelog (`/opsx:changelog`)
- [ ] 4.3. Generate/update docs (`/opsx:docs`)
- [ ] 4.4. Commit and push to remote
