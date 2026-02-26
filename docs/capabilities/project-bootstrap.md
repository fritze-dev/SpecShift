---
title: "Project Bootstrap"
capability: "project-bootstrap"
description: "Initial codebase scanning, constitution generation, change creation, and drift recovery"
order: 3
lastUpdated: "2026-03-02"
---

# Project Bootstrap

Run `/opsx:bootstrap` to analyze your codebase, generate a project constitution, and create your first change workspace. If specs already exist, bootstrap enters recovery mode to detect drift.

## Features

- Scans your entire codebase to understand tech stack, conventions, and architecture
- Generates a constitution based on observed patterns, not generic defaults
- Creates an initial change workspace and hands off to the standard pipeline
- Detects drift between code and specs when run on an already-bootstrapped project

## Behavior

### First-Run: Codebase Scan

On a project without a constitution or specs, bootstrap scans all source and configuration files. It identifies languages, frameworks, file structure, dependencies, and coding conventions. Binary files and `.gitignore` patterns are skipped.

### First-Run: Constitution Generation

Based on the scan, bootstrap generates `openspec/constitution.md` with sections for Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. Every entry is traceable to an observed pattern. Uncertain items are marked with `<!-- REVIEW -->` for you to confirm.

### First-Run: Handoff to Pipeline

After generating the constitution, bootstrap creates a change workspace (e.g., `initial-spec`) and tells you the next steps: generate artifacts with `/opsx:ff` or `/opsx:continue`, run the QA loop with `/opsx:apply`, then sync and archive with `/opsx:sync` and `/opsx:archive`. The initial change is documentation-only with no code tasks.

### Recovery Mode

When specs already exist, bootstrap enters recovery mode. It scans the codebase, compares against existing specs, and reports drift. For minor drift (e.g., renamed functions), it suggests `/opsx:new` to create a targeted change. For major drift, it suggests a full re-bootstrap. Recovery mode never overwrites existing specs or the constitution.

## Edge Cases

- If the project has no source files, bootstrap generates a minimal constitution with placeholder sections.
- If the codebase uses multiple languages or conflicting conventions, the constitution documents all observed patterns and notes variations.
- If `openspec/constitution.md` exists but `openspec/specs/` is empty, bootstrap treats this as a partial first-run and skips constitution generation.
- If the OpenSpec CLI is not installed, bootstrap tells you to run `/opsx:init` first.
- If the project has an extremely deep directory structure, the scan uses reasonable depth limits.
