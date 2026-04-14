# Implementation Tasks: Explicit Plan-Mode Scope Commitment

## 1. Foundation

N/A — no shared infrastructure needed.

## 2. Implementation

- [x] 2.1. Add `## Planning` section to CLAUDE.md between `## Workflow` and `## Knowledge Management`, with scope commitment instruction

## 3. QA Loop & Human Approval
- [x] 3.1. Metric Check:
  - [x] CLAUDE.md contains a `## Planning` section with scope commitment instructions — PASS
  - [x] Instruction requires visible scope summary (in-scope, out-of-scope, non-goals) — PASS
  - [x] Instruction requires user confirmation of scope before proceeding — PASS
- [x] 3.2. Auto-Verify: generate review.md using the review template.
- [x] 3.3. User Testing: (auto_approve — skipped)
- [x] 3.4. Fix Loop: Not entered (no fixes needed)
- [x] 3.5. Final Verify: Skipped (3.4 not entered)
- [x] 3.6. Approval: auto_approve — PASS verdict

## 4. Standard Tasks (Post-Implementation)
- [x] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [x] 4.2. Bump version (0.1.8-beta → 0.1.9-beta)
- [x] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable (e.g., `Closes #X`)
- [ ] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable)

## 5. Post-Merge Reminders
- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
