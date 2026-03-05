---
title: "Constitution Management"
capability: "constitution-management"
description: "Project constitution lifecycle including generation, updates, and enforcement"
lastUpdated: "2026-03-05"
---

# Constitution Management

This capability manages the project constitution lifecycle: generating it from codebase observation during bootstrap, automatically updating it during design phases, and enforcing it as global context across all AI actions.

## Purpose

Without a constitution, AI-generated code and specs default to generic best practices that may conflict with your project's actual conventions. Every time the AI produces output, you would need to manually correct style, architecture, and tooling choices. The constitution captures your project's real patterns once and enforces them automatically across every AI action.

## Rationale

The constitution is generated from observed patterns rather than templates to ensure accuracy. Uncertain conventions are marked with `<!-- REVIEW -->` rather than guessed at, so you can confirm or correct them. Updates during design phases are additive by default -- existing entries are never removed without your explicit approval -- to prevent accidental loss of established conventions.

## Features

- Generates constitution from codebase scan during `/opsx:bootstrap`
- Every entry is traceable to an observed pattern -- no invented rules
- Uncertain conventions marked with `<!-- REVIEW -->` for your confirmation
- All AI actions read the constitution automatically via config.yaml
- Automatically updated when design phases introduce new technologies or patterns
- Updates are additive -- existing entries preserved unless you approve removal
- Constitution changes documented in the design artifact for visibility
- Contains only project-specific rules, not duplicates of schema-defined rules
- Includes a friction tracking convention for capturing workflow issues as GitHub Issues

## Behavior

### Constitution Generation

During `/opsx:bootstrap`, the system scans source files, configurations, directory structures, and dependency manifests. It generates constitution.md with Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions sections. If the codebase shows conflicting patterns (e.g., both tabs and spaces), the system documents both and marks the entry with `<!-- REVIEW -->`.

### Global Context Enforcement

Every skill invocation and artifact generation step reads the constitution before proceeding. If constitution.md is missing, the system warns you and recommends running `/opsx:bootstrap`. This ensures generated code, specs, and documentation are consistent with your project conventions.

### Automatic Updates During Design

When a design introduces a new technology (e.g., Redis as a caching layer), the system adds it to the Tech Stack section. When a design replaces an existing technology (e.g., switching from Jest to Vitest), the system adds the new entry and marks the old one with `<!-- REVIEW -->` rather than removing it. All constitution changes are noted in the design document so you can review them.

### No Redundancy with Schema

The constitution contains only project-specific rules. Rules about spec format, task format, assumption markers, and pipeline ordering live in the schema, not the constitution.

### Friction Tracking

The Conventions section includes a rule requiring that workflow friction discovered during any run be captured as a GitHub Issue with the `friction` label, including what happened, expected behavior, and a suggested fix.

## Edge Cases

- If the project has no source files (empty repository), bootstrap generates a minimal constitution with placeholder sections, all marked `<!-- REVIEW -->`.
- If you manually edit the constitution outside the workflow, the system treats your edits as authoritative and does not overwrite them.
- If sequential design phases each add to the constitution, later updates preserve additions from earlier changes.
- In a monorepo with mixed tech stacks, the constitution documents all observed stacks and notes which directories each applies to.
