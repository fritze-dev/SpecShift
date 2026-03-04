---
title: "Spec Format"
capability: "spec-format"
description: "Format rules for specifications including normative descriptions, scenarios, and delta operations"
order: 14
lastUpdated: "2026-03-04"
---

# Spec Format

Specifications follow a structured format that combines formal requirement descriptions, user stories, and behavioral scenarios. This format ensures consistency, enables automated verification, and supports the delta-to-baseline sync workflow.

## Why This Exists

A consistent spec format is essential for both human readability and system automation. The format rules define how requirements are written, how scenarios describe behavior, how delta specs express changes, and how baseline specs represent the current state -- ensuring that specs are reliable across the entire workflow.

## Features

- Normative descriptions using RFC 2119 keywords (SHALL, MUST, SHOULD, MAY) for clear obligation levels
- Optional user stories in "As a [role] I want [goal], so that [benefit]" format
- Gherkin-style scenarios with GIVEN/WHEN/THEN clauses for behavioral specification
- Delta spec operations (ADDED, MODIFIED, REMOVED, RENAMED) for expressing changes
- Clean baseline format without change-tracking markers
- Strict heading levels: `###` for requirements, `####` for scenarios

## Behavior

### Requirement Structure

Each requirement starts with a heading, followed immediately by its normative description -- the formal, binding text that uses keywords like SHALL and MUST. An optional user story may follow the description. The description always comes first; placing the user story before the description is a format violation caught during preflight.

### Scenarios

Every requirement has at least one scenario using Gherkin format. Scenarios use GIVEN (preconditions), WHEN (trigger or action), and THEN (expected outcome) clauses. Additional conditions use AND clauses after the relevant step. Scenarios must use exactly four hashtags (`####`) in their heading. Using three hashtags causes the scenario to be misinterpreted as a requirement-level heading, breaking the document structure.

### Delta Specs

When a change introduces, modifies, or removes requirements, the delta spec uses operation-prefixed sections: ADDED Requirements, MODIFIED Requirements, REMOVED Requirements, or RENAMED Requirements. Modified requirements include the full updated content, not partial diffs. Removed requirements include a reason and a migration path. Renamed requirements use FROM/TO format.

### Baseline Specs

Baseline specs represent the current merged state. They use a Purpose section followed by a Requirements section, with no operation prefixes. Each requirement follows the same structure as in delta specs.

## Edge Cases

- If a delta spec contains both ADDED and MODIFIED sections, the sync process handles each operation independently.
- If a delta spec uses an unrecognized operation prefix (e.g., "UPDATED"), it is flagged as an error and the sync process refuses to merge.
- If a requirement has zero scenarios, the spec is considered invalid and flagged during preflight.
- If the same requirement name appears in both ADDED and MODIFIED sections of the same delta, it is treated as a conflict and flagged during preflight.
- If a RENAMED requirement's target name conflicts with an existing requirement in the baseline, the sync process flags the naming collision.
