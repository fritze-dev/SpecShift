---
title: "Project Bootstrap"
capability: "project-bootstrap"
description: "Initial codebase scanning, constitution generation, and recovery mode"
lastUpdated: "2026-03-05"
---

# Project Bootstrap

The `/opsx:bootstrap` command scans your existing codebase, generates a project constitution from observed patterns, creates an initial change workspace, and hands off to the standard pipeline. It also provides recovery mode for detecting drift between code and specs.

## Why This Exists

Starting spec-driven development on an existing project means bridging the gap between what your code already does and what the spec system needs to know. Without bootstrap, you would have to manually write a constitution, guess at conventions, and set up the first change workspace -- all tedious and error-prone. Bootstrap also solves the ongoing problem of code-spec drift by detecting when your codebase has evolved beyond what the specs describe.

## Design Rationale

Bootstrap relies on static file analysis (file extensions, configuration files, package manifests) rather than executing project code. This keeps the scan safe and fast across any project size. Recovery mode compares structural and naming patterns rather than performing deep semantic analysis, making drift detection practical without requiring full code understanding.

## Features

- Scans the entire codebase to identify tech stack, frameworks, languages, and conventions
- Generates a constitution reflecting actual project patterns, not generic defaults
- Creates an initial change workspace and hands off to the standard pipeline
- Provides recovery mode that detects drift between code and existing specs
- Skips binary files and respects .gitignore patterns during scanning
- Handles projects of any size with reasonable depth limits

## Behavior

### First-Run Scan

When you run `/opsx:bootstrap` on a project without existing specs, the system scans your codebase and identifies your tech stack, frameworks, file structure, and coding conventions. It then generates a constitution.md with Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions sections populated from what it observed.

### Constitution Generation

The generated constitution reflects your actual project. If your project uses 4-space indentation and camelCase variables, the constitution captures that. If your project uses conventional commits, the Conventions section references that format. The constitution only contains patterns the system actually observed -- it does not invent rules.

### Initial Change Creation

After generating the constitution, bootstrap creates a change workspace via the OpenSpec CLI and informs you of the next steps: run `/opsx:ff` or `/opsx:continue` to generate artifacts, then `/opsx:apply` for the QA loop, then `/opsx:archive` to complete.

### Recovery Mode

If baseline specs already exist in your project, bootstrap enters recovery mode instead. It scans the codebase, compares against existing specs, and produces a drift report listing discrepancies. For minor drift (e.g., renamed functions), it suggests creating a targeted change with `/opsx:new`. For major drift (e.g., rewritten modules), it suggests a full re-bootstrap after backing up specs. Recovery mode never overwrites existing specs or the constitution.

## Known Limitations

- Tech stack detection relies on static file analysis and may miss dynamically loaded technologies
- Recovery mode uses structural and naming comparison, not deep semantic analysis
- Very deep directory structures may hit scan depth limits for performance reasons

## Edge Cases

- If the project has no source code files (empty repository), bootstrap generates a minimal constitution with placeholder sections and asks you to update it manually.
- If the codebase uses multiple languages or conflicting conventions, the constitution documents the primary patterns and notes the variations as exceptions.
- If constitution.md exists but specs/ is empty, bootstrap treats this as a partial first-run and skips constitution generation while proceeding to change creation.
- If the OpenSpec CLI is not installed, bootstrap instructs you to run `/opsx:init` first.
