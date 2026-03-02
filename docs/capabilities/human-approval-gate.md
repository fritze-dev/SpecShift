---
title: "Human Approval Gate"
capability: "human-approval-gate"
description: "Mandatory explicit approval before archiving with fix-verify loop support"
order: 10
lastUpdated: "2026-03-02"
---

# Human Approval Gate

No change can be archived without your explicit approval. The QA loop runs verification, presents findings, and waits for you to say "Approved" before proceeding.

## Features

- Mandatory human approval before any change is archived
- Success metrics from design.md carried over as PASS/FAIL checkboxes
- Fix-verify loop for resolving issues iteratively
- Final verification pass after the fix loop to catch issues introduced by fixes
- Bidirectional feedback: updating specs is a valid fix when implementation reveals design issues

## Behavior

### Approval Flow

After implementation, the system runs `/opsx:verify`, presents the findings, and waits for explicit approval. You must say "Approved" to proceed. Ambiguous responses like "looks ok" are not accepted.

### Approval Requirements

Approval is only requested after all CRITICAL issues are resolved and a final verification pass confirms consistency. You can approve with outstanding warnings. Every success metric from design.md appears as a PASS/FAIL checkbox in the QA loop section of tasks.md, and all must pass.

### Final Verify

After the fix loop completes, the system runs `/opsx:verify` one final time before requesting approval. This ensures that all changes made during fixes — including spec updates, design changes, and code fixes — are verified as consistent. If the final verify finds new issues, you return to the fix loop. If the initial verify was clean and no fixes were needed, the final verify step is automatically satisfied.

### Fix-Verify Loop

When verification finds issues, you resolve each one by either fixing code to match the spec or updating the spec to match the implementation. Then re-run `/opsx:verify`. This cycle continues until all critical issues are resolved and you're satisfied.

### Bidirectional Feedback

If implementation reveals that a spec or design was wrong, updating the spec is a valid resolution. The system supports updating design.md, specs, or tasks.md during the fix loop.

## Edge Cases

- If you haven't run `/opsx:verify`, the archive step warns that verification was not performed.
- If code changes happen after the last verify run, the report may be stale.
- If design.md has no success metrics, the QA loop still includes the mandatory approval checkbox.
- If all issues are SUGGESTION-level only, the system proceeds directly to requesting approval.
- The fix loop has no maximum iteration count; it continues until you're satisfied.
