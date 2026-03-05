---
title: "Quality Gates"
capability: "quality-gates"
description: "Pre-implementation preflight checks and post-implementation verification"
lastUpdated: "2026-03-05"
---

# Quality Gates

This capability provides two quality checkpoints: `/opsx:preflight` for pre-implementation quality checks across six dimensions, and `/opsx:verify` for post-implementation verification of completeness, correctness, and coherence.

## Why This Exists

Specifications and designs can contain gaps, contradictions, and untested assumptions that only surface during implementation -- when they are expensive to fix. Without pre-implementation checks, these issues propagate into code. Without post-implementation verification, divergence between specs and code goes undetected until it causes problems.

## Design Rationale

Preflight checks six specific dimensions rather than performing a generic review to ensure structured, repeatable coverage. Verification uses heuristic code search rather than exhaustive analysis, which means it may miss some things but runs quickly on large codebases. When uncertain about severity, verification errs on the side of lower severity (SUGGESTION over WARNING, WARNING over CRITICAL) to avoid false alarms.

## Features

- `/opsx:preflight` checks traceability, gaps, side effects, constitution compliance, duplication, and assumptions
- Produces a preflight.md artifact with a verdict: PASS, PASS WITH WARNINGS, or BLOCKED
- `/opsx:verify` assesses completeness, correctness, and coherence after implementation
- Issues classified as CRITICAL (must fix), WARNING (should fix), or SUGGESTION (nice to fix)
- Verification produces actionable recommendations with file and line references
- Both commands serve as stateless checks against the current state

## Behavior

This capability spans two commands used at different points in the workflow: `/opsx:preflight` runs after design and before task creation; `/opsx:verify` runs after implementation and during the QA loop.

### Preflight Check (/opsx:preflight)

When you run `/opsx:preflight`, the system reads your constitution, all change artifacts, and existing baseline specs, then evaluates six dimensions:

- **Traceability Matrix**: Maps every requirement to scenarios and components
- **Gap Analysis**: Identifies missing edge cases, error handling, and empty states
- **Side-Effect Analysis**: Assesses impact on existing systems and regression risks
- **Constitution Check**: Verifies consistency with project rules
- **Duplication and Consistency**: Detects overlaps and contradictions across specs
- **Assumption Audit**: Rates every `<!-- ASSUMPTION -->` marker as Acceptable Risk, Needs Clarification, or Blocking

The result is a preflight.md with a verdict. If blockers are found, you cannot proceed to task creation until they are resolved. The system reports findings but does not auto-fix them.

### Post-Implementation Verification (/opsx:verify)

When you run `/opsx:verify`, the system checks three dimensions:

- **Completeness**: Task completion and spec coverage
- **Correctness**: Whether requirements are implemented accurately and scenarios are satisfied
- **Coherence**: Whether the code follows the design and project patterns

Each issue includes a specific recommendation. The same command serves as both the initial verification and the final verification in the QA loop -- it always checks the current state with no special modes needed.

## Known Limitations

- Verification uses heuristic keyword search, which may produce false positives on large codebases
- Verification focuses on files referenced in design.md and recently modified files rather than exhaustive search
- Preflight does not auto-fix issues; all findings require manual resolution

## Edge Cases

- If required artifacts (specs, design) are missing when you run preflight, the system aborts and tells you which artifacts need to be generated.
- If a change has only tasks.md (no specs or design), verify checks task completion only and notes which checks were skipped.
- If a change has no delta specs (documentation-only), verify skips requirement-level checks and focuses on task completion and code pattern coherence.
