---
id: preflight
template-version: 2
description: "Quality gate: traceability, gaps, side effects, assumption audit"
generates: preflight.md
requires: [design]
instruction: |
  Mandatory quality review BEFORE task creation.
  Map every story to scenarios and components (traceability).
  Identify gaps, side effects, duplication across stories, and inconsistencies with existing specs or constitution.
  Audit all assumption markers from spec.md and design.md — rate each as Acceptable Risk, Needs Clarification, or Blocking.
---
# Pre-Flight Check: [Feature Name]

## A. Traceability Matrix
<!-- Mapping: Every Story → Scenarios → Architecture Components -->
- [ ] Story 1 → Scenario 1.1 → Component X

## B. Gap Analysis
<!-- Missing edge cases? Error handling? Offline? Empty states? -->

## C. Side-Effect Analysis
<!-- Which existing systems could be affected? Regression risks? -->

## D. Constitution Check
<!-- Do global rules need updating due to new patterns? -->

## E. Duplication & Consistency
<!-- Overlapping stories? Contradictions between specs? Inconsistencies with existing specs in docs/specs/? -->

## F. Assumption Audit
<!-- Collect all <!-- ASSUMPTION --> markers from spec.md and design.md.
     Verify each has visible text before the HTML tag.
     Rate each: Acceptable Risk / Needs Clarification / Blocking. -->

## G. Review Marker Audit
<!-- Scan for any remaining <!-- REVIEW --> or <!-- REVIEW: ... --> markers.
     Any REVIEW marker found = Blocking (must be resolved before implementation). -->

## H. Template-Version Freshness
<!-- For changes that modify files under src/templates/:
     1. Identify all template files changed in this branch vs. the base branch (added, modified, renamed, or deleted).
     2. If no src/templates/ files changed: report "No template changes detected — skipped."
     3. If no merge base is available: skip and note "No merge base available — template-version check skipped."
     4. For each changed template:
        - Modified (same path): read template-version and compare against the base branch value.
        - Newly added (no base-branch file): must have template-version: 1. Any other value: BLOCKED.
        - Renamed/moved: compare against the base-branch file at the previous path.
        - Deleted: no version increment required; exclude from checks.
     5. If content changed but template-version was NOT incremented relative to the base: BLOCKED.
     6. If content is unchanged (rename-only, whitespace-only): no increment required. -->
