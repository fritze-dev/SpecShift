---
title: "Human Approval Gate"
capability: "human-approval-gate"
description: "QA loop with audit.md artifact, tiered fix-verify cycles, auto_approve bypass, and mandatory human approval"
lastUpdated: "2026-04-13"
---

# Human Approval Gate

No change is finalized without explicit human sign-off. The QA loop ensures that every change is verified via a persistent `audit.md` artifact, issues are resolved through a structured tiered fix cycle, and the user gives a clear "Approved" before the change can proceed to finalization.

## Purpose

Automated workflows risk finalizing changes that have unresolved issues or do not meet the developer's expectations. Without an explicit approval gate, a change could be merged with critical verification failures, misunderstood requirements, or untested behavior. The human approval gate prevents this by requiring the user to explicitly approve after reviewing the audit.md verification report and success metrics.

## Rationale

The QA loop places verification before approval so that the user reviews concrete findings rather than making a judgment call without data. Verification produces a `audit.md` artifact in the change directory — persistent, PR-visible, and not skippable (file existence is the check). The fix loop uses a three-tier classification (Tweak, Design Pivot, Scope Change) with concrete detection signals so agents can mechanically determine correction depth rather than relying on subjective judgment. Three tiers strike the right balance: two tiers (fix vs. re-enter) proved too coarse in practice, while four or more add unnecessary complexity. The `auto_approve` configuration allows fully autonomous pipeline execution when desired, while a FAIL verdict always stops regardless of the setting.

## Features

- **Mandatory Human Approval**: The system requires an explicit "Approved" response before a change can proceed to the post-apply workflow. Ambiguous responses are not accepted.
- **audit.md as Approval Gate**: Verification produces a persistent `audit.md` artifact in the change directory. The artifact is PR-visible and not skippable.
- **Structured QA Loop**: The tasks.md template includes a QA section with steps in order: Metric Check, Auto-Verify, User Testing, Fix Loop, Final Verify, and Approval.
- **Success Metric Checkboxes**: Every success metric from `design.md` is carried over as a PASS/FAIL checkbox. All must be marked PASS before approval.
- **Tiered Fix-Verify Cycles**: Corrections are classified into three tiers with matching re-entry depth — from fixing a value in place to full re-implementation from updated specs.
- **Detection Signals**: Observable signals (reverted tasks, invalidated metrics, reversed design decisions, out-of-scope files) guide tier classification mechanically.
- **Artifact Staleness Rule**: Design Pivot and Scope Change corrections update all stale change artifacts before re-implementing.
- **Final Verification Pass**: After the fix loop completes, a final `audit.md` is regenerated to confirm all fixes are consistent.
- **Bidirectional Feedback**: When implementation reveals that a spec or design is wrong, updating the spec is a valid resolution path at all tiers.
- **Auto-Approve Configuration**: When `auto_approve: true` is set in WORKFLOW.md, the pipeline proceeds without user confirmation after a passing audit.md verdict.

## Behavior

Run `specshift apply` for implementation and the QA loop. The apply action implements tasks, generates audit.md, runs the fix loop if needed, and requests approval.

### Approval After Clean Verification (specshift apply)

When all tasks are complete, apply generates `audit.md` in the change directory. If the report shows no CRITICAL or WARNING issues and all success metric checkboxes are marked PASS, the system presents the report and asks for explicit approval. The user responds "Approved" and the system proceeds to the post-apply workflow.

### Critical Issues Block Approval (specshift apply)

When a audit.md report contains CRITICAL issues, the system does not request approval. It states that critical issues must be resolved first and lists the specific issues.

### Warnings Can Be Acknowledged (specshift apply)

When a report contains no CRITICAL issues but does contain WARNINGs, the system requests approval while highlighting the warnings. The user may respond "Approved" to accept them.

### Success Metrics Are Carried Into the QA Loop (specshift apply)

When `design.md` contains success metrics, the generated tasks.md includes a PASS/FAIL checkbox for each one. All must be marked PASS before approval can be granted.

### Tiered Fix Loop (specshift apply)

Before applying any fix, the system classifies the correction into one of three tiers:

- **Tier 1 — Tweak**: The correction changes a value, line, or detail within the current approach (wrong value, typo, missing line). The system fixes it in place and regenerates audit.md.
- **Tier 2 — Design Pivot**: The correction changes which files are modified or which approach is used, but requirements are still correct. The system updates design.md, discards and re-generates affected task sections, re-implements from the corrected design, then regenerates audit.md.
- **Tier 3 — Scope Change**: The correction changes which requirements apply or who the target audience is. The system updates specs and proposal.md, updates design.md, re-generates tasks, re-implements fully, then regenerates audit.md.

The system checks observable detection signals before classifying: whether completed tasks need reverting, whether success metrics still apply, whether design decisions are reversed, whether corrections touch files outside the design, and whether requirements no longer apply to the correct audience.

### Artifact Staleness Rule (specshift apply)

For Design Pivot and Scope Change corrections, all stale change artifacts (design.md, tasks.md, preflight.md, audit.md) are updated before re-implementing. A stale artifact is one that still describes the original wrong approach. The system does not leave stale artifacts in the change directory.

### Final Verify Runs After the Fix Loop (specshift apply)

When the fix loop resolves all issues, a final `audit.md` is regenerated. The final report must confirm 0 CRITICAL issues before approval is requested. If new issues are found, the developer returns to the fix loop.

### Auto-Approve Skips Human Gate (specshift apply)

When `auto_approve: true` is set in WORKFLOW.md and audit.md's verdict is PASS (no CRITICAL, no WARNING), the pipeline skips the user testing pause and proceeds directly to finalize. A FAIL or BLOCKED verdict always stops regardless of the setting, and PASS WITH WARNINGS still pauses for acknowledgment.

## Known Limitations

- Spec updates during the fix loop do not automatically re-trigger preflight.
- The fix loop has no maximum iteration count; it continues until the user is satisfied.
- Agents reading the tiered re-entry instructions must apply the classification before patching — no runtime enforcement beyond the instruction text.

## Edge Cases

- If audit.md has never been generated, the system warns that verification has not been performed.
- If code changes are made after the last verify run, the audit.md may be stale. The system notes the timestamp relative to recent changes.
- If the user provides an ambiguous response, the system clarifies that it needs an explicit "Approved."
- If the system cannot determine whether a correction is Tier 1 or Tier 2, it errs toward Design Pivot to ensure artifact freshness.
- If a Tier 1 fix reveals that the underlying problem is a Tier 2 or Tier 3 issue, the system re-classifies at the higher tier and applies the corresponding re-entry depth.
- If a Scope Change is identified after partial implementation, the system updates the spec first, then re-generates design and tasks before continuing. Partial work that conflicts with the new scope is reverted.
