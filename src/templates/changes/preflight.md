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

## Traceability Matrix
<!-- Mapping: Every Story → Scenarios → Architecture Components -->
- [ ] Story 1 → Scenario 1.1 → Component X

## Gap Analysis
<!-- Missing edge cases? Error handling? Offline? Empty states? -->

## Side-Effect Analysis
<!-- Which existing systems could be affected? Regression risks? -->

## Constitution Check
<!-- Do global rules need updating due to new patterns? -->

## Duplication & Consistency
<!-- Overlapping stories? Contradictions between specs? Inconsistencies with existing specs in docs/specs/? -->

## Assumption Audit
<!-- Collect all <!-- ASSUMPTION --> markers from spec.md and design.md.
     Verify each has visible text before the HTML tag.
     Rate each: Acceptable Risk / Needs Clarification / Blocking. -->

## Review Marker Audit
<!-- Scan for any remaining <!-- REVIEW --> or <!-- REVIEW: ... --> markers.
     Any REVIEW marker found = Blocking (must be resolved before implementation). -->
