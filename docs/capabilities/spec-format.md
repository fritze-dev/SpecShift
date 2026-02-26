---
title: "Spec Format"
capability: "spec-format"
description: "Requirement format rules including normative descriptions, Gherkin scenarios, and delta operations"
order: 6
lastUpdated: "2026-03-02"
---

# Spec Format

Specifications follow a strict format: normative descriptions with SHALL/MUST keywords, optional User Stories, Gherkin scenarios with GIVEN/WHEN/THEN, and delta operations for tracking changes.

## Features

- Consistent requirement format with binding normative descriptions
- Gherkin scenarios for every requirement, suitable for test generation
- Delta spec operations (ADDED, MODIFIED, REMOVED, RENAMED) for tracking changes
- Clean baseline format with Purpose and Requirements sections

## Behavior

### Normative Descriptions

Every requirement starts with a normative description using RFC 2119 keywords (SHALL, MUST, SHOULD, MAY). This is the binding specification. An optional User Story may follow using the format "As a [role] I want [goal], so that [benefit]". The description always comes before the User Story.

### Gherkin Scenarios

Every requirement has at least one scenario using `#### Scenario:` (exactly 4 hashtags). Each scenario contains GIVEN (preconditions), WHEN (trigger), and THEN (expected outcome) clauses. Using 3 hashtags instead of 4 causes a silent failure where the scenario renders as a subsection heading. Additional conditions use `- **AND** ...`.

### Delta Spec Operations

Delta specs (in change directories) use operation-prefixed headers: `## ADDED Requirements` for new capabilities, `## MODIFIED Requirements` for changes (must include full updated content), `## REMOVED Requirements` for deprecations (must include Reason and Migration), and `## RENAMED Requirements` (FROM/TO format).

### Baseline Spec Format

Baseline specs (in `openspec/specs/`) use `## Purpose` followed by `## Requirements` with no operation prefixes. They represent the current merged state of all requirements.

## Edge Cases

- If a delta spec contains both ADDED and MODIFIED sections, the sync process handles each independently.
- If a delta spec uses an unrecognized operation prefix, the sync process flags it as an error.
- If a requirement has zero scenarios, it is flagged during preflight.
- If the same requirement name appears in both ADDED and MODIFIED sections, it is treated as a conflict.
- If a RENAMED requirement's target name conflicts with an existing requirement, the naming collision is flagged.
