---
title: "Spec Format"
capability: "spec-format"
description: "Format rules for specifications including normative descriptions, scenarios, and delta operations"
lastUpdated: "2026-03-05"
---

# Spec Format

This capability defines the format rules for all specifications: normative descriptions with obligation keywords, Gherkin scenarios, delta spec operations, frontmatter metadata, and baseline spec structure.

## Purpose

Without consistent format rules, specifications become a patchwork of styles — some with formal requirements, others with vague descriptions, scenarios at wrong heading levels that break parsing. The spec format ensures every specification is structured identically, making them both human-readable and machine-parseable.

## Rationale

Scenarios use exactly 4 hashtags (`####`) because 3 hashtags would render as a requirement-level heading, silently breaking the relationship between scenarios and their parent requirement. This is a common mistake that causes subtle downstream problems. Delta specs require full content for MODIFIED requirements (not partial diffs) because partial content loses detail when archived into the baseline.

## Features

- Normative descriptions use RFC 2119 keywords (SHALL, MUST, SHOULD, MAY)
- Strict ordering: normative description first, then optional User Story
- Gherkin scenarios with GIVEN/WHEN/THEN clauses as bold-prefixed list items
- Scenarios must use `#### Scenario:` (exactly 4 hashtags)
- Delta spec operations: ADDED, MODIFIED, REMOVED, RENAMED
- Optional YAML frontmatter with `order` and `category` fields for documentation ordering
- Clean baseline format without delta operation prefixes

## Behavior

### Requirement Structure

Each requirement starts with a `### Requirement: <name>` header, followed immediately by the normative description using obligation keywords (SHALL, MUST, SHOULD, MAY). An optional User Story may follow using the format: `**User Story:** As a [role] I want [goal], so that [benefit]`. The description must always come before the User Story.

### Gherkin Scenarios

Every requirement has at least one scenario using `#### Scenario: <name>` (4 hashtags). Each scenario contains GIVEN (preconditions), WHEN (trigger), and THEN (expected outcome) as bold-prefixed list items. Additional conditions use `- **AND** ...` after the relevant clause.

### Delta Spec Operations

Delta specs (within change workspaces) use operation-prefixed headers:
- `## ADDED Requirements` for new capabilities
- `## MODIFIED Requirements` for changes (must include full updated content)
- `## REMOVED Requirements` for deprecations (must include reason and migration path)
- `## RENAMED Requirements` using FROM/TO format

### Frontmatter Metadata

Baseline specs may include YAML frontmatter with `order` (display position in docs) and `category` (workflow phase grouping). The `/opsx:docs` command uses these values for ordering and grouping capabilities.

### Baseline Spec Format

Baseline specs use a Purpose section followed by a Requirements section. They do not contain operation prefixes because they represent the current merged state, not a set of changes.

## Edge Cases

- If a scenario uses 3 hashtags instead of 4, it renders as a subsection heading instead of a scenario block, breaking automated parsing. Preflight flags this as a format violation.
- If a User Story is placed before the normative description, preflight flags it as a format violation.
- If a MODIFIED requirement in a delta only includes partial content, preflight flags this as a risk because archiving would replace the full baseline with incomplete content.
- If an unrecognized operation prefix is used (e.g., `## UPDATED Requirements`), the sync process flags it as an error.
- If two specs share the same `order` value, documentation generation uses alphabetical capability name as tiebreaker.
