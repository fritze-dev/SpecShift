---
title: "Human Approval Gate"
capability: "human-approval-gate"
description: "Mandatory human approval before archiving, with verification, fix loops, and success metrics"
order: 10
lastUpdated: "2026-03-04"
---

# Human Approval Gate

No change is finalized without your explicit review and sign-off. The system enforces a structured QA loop that includes verification, issue resolution, and mandatory approval before archiving.

## Why This Exists

The QA loop runs verification once, then enters a fix loop where code, specs, or design may be modified. Without a final verification pass after fixes, post-fix changes could go unverified before archiving. This capability formalizes the checkpoint so that all changes -- including those made during the fix loop -- are verified as consistent before you give approval.

## Features

- Mandatory explicit approval before any change can be archived
- Automated verification via `/opsx:verify` with structured findings
- Fix-verify loop for resolving issues iteratively
- Final verification pass after all fixes are applied
- Success metric checkboxes carried from design into the QA loop
- Bidirectional feedback: fix the code or update the spec, whichever is correct

## Behavior

### Verification and Approval

Run `/opsx:verify` to produce a verification report. If the report has no critical or warning issues and all success metric checkboxes pass, the system asks for your explicit approval. Respond with "Approved" to allow archiving. Ambiguous responses like "looks ok" or "seems fine" are not accepted -- the system asks you to confirm with an explicit "Approved."

If critical issues exist, the system does not request approval. It lists the specific issues that must be resolved first. If there are warnings but no critical issues, the system requests approval while highlighting the warnings, and you may approve to accept them.

### Fix Loop

When verification finds issues, you resolve each one by either fixing the code to match the spec or updating the spec to match the intended implementation. After applying fixes, re-run `/opsx:verify` to confirm resolution. This cycle continues until all critical issues are resolved and you are satisfied with any remaining warnings. Updating a spec or design is a valid resolution -- when implementation reveals a better approach, the specs should reflect reality.

### Final Verification

After the fix loop completes, a final `/opsx:verify` runs to confirm that all changes made during the fix loop are consistent. If the final verification finds new issues introduced by the fixes, you return to the fix loop to resolve them. If the initial verification was clean and no fixes were needed, the final verification step is marked complete automatically.

### Success Metrics

Every success metric from the design is carried into the QA loop as a pass/fail checkbox. All checkboxes must be marked as passing before approval can be granted. If the design has no explicit success metrics, the approval checkbox still appears but without metric checkboxes.

## Known Limitations

- Does not automatically re-verify when code changes are made after the last verification run; the system notes the timestamp of the last run relative to recent changes
- Does not enforce a maximum number of fix-verify iterations; the loop continues until you are satisfied

## Edge Cases

- If you attempt to archive without ever running verification, the system warns that verification has not been performed.
- If code changes are made after the last verification run, the verification report may be stale. The system notes this when you request archive.
- If the user provides a partial or ambiguous approval response, the system clarifies that it needs an explicit "Approved."
- If verification produces only suggestion-level findings with no critical or warning issues, the system proceeds directly to requesting approval without requiring fixes.
- If a critical issue turns out to be a false positive, re-running verification with the same code is a valid fix loop iteration.
