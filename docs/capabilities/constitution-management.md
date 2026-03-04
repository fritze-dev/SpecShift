---
title: "Constitution Management"
capability: "constitution-management"
description: "Project constitution lifecycle: generation, global enforcement, updates, and deduplication"
order: 6
lastUpdated: "2026-03-04"
---

# Constitution Management

The project constitution is a single file that defines global rules governing all AI behavior. It is generated from your codebase, read before every action, and updated as your project evolves.

## Why This Exists

The constitution previously contained 12 rules that duplicated what the schema already defines. Cleaning up this redundancy established clean rule ownership: the constitution holds only project-specific knowledge, while the schema handles universal workflow rules.

## Background

A rule ownership audit revealed heavy duplication between the constitution and schema instructions. Additionally, there was no convention for capturing workflow friction systematically. The cleanup removed redundancies and added a friction tracking convention requiring friction to be captured as GitHub Issues with the `friction` label.

## Features

- Bootstrap-generated constitution from codebase observation — reflects actual patterns, not generic best practices
- Automatic global context enforcement — every AI action reads the constitution
- Design-phase updates — new technologies and patterns are captured as your project grows
- Deduplication with schema — constitution contains only project-specific rules
- Friction tracking convention — workflow friction captured as GitHub Issues with the `friction` label
- Uncertain patterns marked with `<!-- REVIEW -->` for user confirmation

## Behavior

### Bootstrap Generation

When you run `/opsx:bootstrap`, the agent scans your codebase and generates a constitution from observed patterns — tech stack, architecture rules, code style, constraints, and conventions. Every entry is traceable to an observed pattern; nothing is invented.

### Global Context Enforcement

The constitution is referenced by all AI actions through `config.yaml`. Every skill invocation and artifact generation step reads the constitution before proceeding. If the constitution is missing, the system warns you and recommends running `/opsx:bootstrap`.

### Design-Phase Updates

When a design introduces a new technology or pattern, the agent updates the constitution automatically. Updates are additive — existing entries are not removed without your approval. Constitution changes are noted in the design document for visibility.

### No Redundancy with Schema

The constitution does not duplicate rules defined by the schema or its templates. Rules about spec format, task format, assumption markers, capability naming, or artifact pipeline ordering exist only in the schema.

### Friction Tracking

A convention in the constitution requires that workflow friction discovered during any workflow run be captured as a GitHub Issue with the `friction` label, including what happened, expected behavior, and a suggested fix.

## Known Limitations

- The constitution does not contain workflow rules that apply universally — those live in the schema's instruction fields.
- `<!-- REVIEW -->` markers require manual user confirmation; the system does not auto-resolve uncertain conventions.

## Edge Cases

- On an empty project, a minimal constitution with placeholder sections is generated, all marked `<!-- REVIEW -->`.
- Contradictory patterns in the codebase (e.g., mixed camelCase and snake_case) result in both being documented with a `<!-- REVIEW -->` marker.
- Manual edits to the constitution are treated as authoritative and not overwritten by subsequent bootstrap or design updates.
- When a new schema version adds rules, the constitution should be audited for newly-redundant entries.
- In a monorepo with mixed tech stacks, all observed stacks are documented with notes on which directories each applies to.
