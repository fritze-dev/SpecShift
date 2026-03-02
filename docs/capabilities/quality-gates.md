---
title: "Quality Gates"
capability: "quality-gates"
description: "Pre-implementation preflight checks and post-implementation verification"
order: 9
lastUpdated: "2026-03-02"
---

# Quality Gates

Run `/opsx:preflight` before task creation to catch issues in your specs and design. Run `/opsx:verify` after implementation to check your code against the specs.

## Features

- Preflight checks across six dimensions before implementation begins
- Post-implementation verification for completeness, correctness, and coherence
- Issues classified by severity: CRITICAL, WARNING, or SUGGESTION
- Actionable recommendations with file and line references

## Behavior

### Preflight Quality Check

Running `/opsx:preflight` reviews your specs and design across six dimensions: (A) Traceability Matrix, (B) Gap Analysis, (C) Side-Effect Analysis, (D) Constitution Check, (E) Duplication and Consistency, and (F) Assumption Audit (rating every `<!-- ASSUMPTION -->` marker). The result is a `preflight.md` with a verdict of PASS, PASS WITH WARNINGS, or BLOCKED. Issues are reported for you to resolve; the system does not auto-fix.

### Post-Implementation Verification

Running `/opsx:verify` checks your implementation against the change artifacts across three dimensions: Completeness (task and spec coverage), Correctness (requirement accuracy and scenario coverage), and Coherence (design adherence and code pattern consistency). Each issue gets a severity level, with the system defaulting to lower severity when uncertain.

The verify command serves as both the initial verification (step 3.2 in the QA loop) and the final verification (step 3.5) after the fix loop. It operates identically in both cases — always checking the current state of code and artifacts. No special flags or modes are needed.

### Verification Report

The report includes a summary scorecard, issues grouped by priority, and specific recommendations. If critical issues exist, you must fix them before archiving. Warnings are recommended fixes. Suggestions are optional improvements.

## Edge Cases

- If no change name is provided and multiple exist, the system prompts you to select.
- If specs don't exist when running preflight, it aborts and tells you to create them first.
- If tasks.md doesn't exist when running verify, it suggests generating it.
- Verify uses heuristic search, so it prefers SUGGESTION severity for uncertain matches to avoid false positives.
- If only tasks.md exists (no specs or design), verify checks task completion only and notes skipped checks.
