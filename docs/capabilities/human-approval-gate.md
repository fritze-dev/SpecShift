---
title: "Human Approval Gate"
capability: "human-approval-gate"
description: "Mandatory human approval with QA loop, success metrics, and fix-verify cycles"
lastUpdated: "2026-03-05"
---

# Human Approval Gate

This capability defines the QA loop that requires explicit human approval before a change can be archived. It includes success metric validation, fix-verify cycles, and bidirectional feedback between code and specs.

## Purpose

Without a mandatory approval step, changes could be archived and finalized without anyone confirming they actually work correctly. Automated checks catch many issues, but only a human can verify that the implementation matches the intent. The approval gate ensures every change gets a deliberate sign-off from someone who understands the context.

## Rationale

Approval requires the explicit word "Approved" rather than accepting ambiguous responses like "looks ok" to prevent accidental sign-offs. The fix loop supports bidirectional feedback -- you can fix the code to match the spec or update the spec to match the code -- because implementation sometimes reveals that the original spec was wrong. A final verification pass runs after the fix loop to ensure that fixes themselves did not introduce new inconsistencies.

## Features

- Mandatory explicit "Approved" response required before archiving
- QA loop with success metric checkboxes carried from design.md
- Fix-verify cycle for resolving issues found by `/opsx:verify`
- Bidirectional feedback: fix code to match spec, or update spec to match code
- Final verification pass after fix loop to confirm consistency
- Approval blocked while CRITICAL issues remain unresolved
- Warnings can be acknowledged and approved with explicit sign-off

## Behavior

### QA Loop Sequence

The QA loop in tasks.md follows this sequence:

1. **Metric Check**: Validate success metrics from design.md as PASS/FAIL
2. **Auto-Verify**: Run `/opsx:verify` for initial verification
3. **User Testing**: You test the implementation manually
4. **Fix Loop**: Fix issues and re-verify as needed
5. **Final Verify**: Run `/opsx:verify` one final time to confirm all fixes are consistent
6. **Approval**: Only finish on explicit "Approved"

### Approval After Clean Verification

When verification produces no CRITICAL or WARNING issues and all success metric checkboxes are marked PASS, the system asks for your explicit approval. You respond "Approved" and the system proceeds to allow archiving.

### Handling Issues

If verification finds CRITICAL issues, the system does not request approval. It lists the specific issues and states they must be resolved first. If only WARNING issues exist, the system requests approval while highlighting the warnings -- you can approve with acknowledged warnings.

### Fix-Verify Cycles

When issues are found, you resolve each one by either fixing the code to match the spec or updating the spec to match the intended implementation. After fixing, you re-run `/opsx:verify`. This cycle repeats until all CRITICAL issues are resolved.

### Final Verification

After the fix loop completes, a final `/opsx:verify` runs to confirm that all changes made during fixing are consistent. If the first verification was clean and the fix loop was not entered, this step is satisfied automatically.

## Edge Cases

- If you attempt to archive without ever running `/opsx:verify`, the system warns that verification has not been performed.
- If code changes are made after the last verify run, the system notes the timestamp of the last verify relative to recent changes when you request archive.
- If design.md has no success metrics, the QA loop still includes the mandatory approval checkbox but has no PASS/FAIL metric checkboxes.
- If you respond with something ambiguous (e.g., "seems fine"), the system clarifies that it needs an explicit "Approved."
- If a fix introduces a new issue, the system reports it and you must address it before approval.
