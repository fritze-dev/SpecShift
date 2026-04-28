---
title: "Project Init"
capability: "project-init"
description: "One-command project initialization with template merge, codebase scanning, constitution generation, agnostic bootstrap-file generation (AGENTS.md + CLAUDE.md), Claude Code Web settings generation, and health checks"
lastUpdated: "2026-04-28"
---

# Project Init

Sets up a project for the spec-driven workflow via `specshift init` -- installing templates, generating a constitution from your codebase, generating both bootstrap files (`AGENTS.md` as the agnostic source of truth and `CLAUDE.md` as a one-line `@AGENTS.md` import stub), generating Claude Code Web settings for cloud sessions, and running health checks for spec and documentation drift.

## Purpose

Without a structured setup process, adopting spec-driven development requires manually creating configuration files, writing a constitution from scratch, wiring up agent-instruction files for whichever AI tool runs the project, and hoping the environment supports the features you need. Existing projects that drift from their specs have no way to detect the gap. Project Init handles all of this in a single command, whether you are starting fresh, migrating from a legacy layout, or checking the health of an established project.

## Rationale

A single `specshift init` command covers fresh installs, legacy migrations, and re-initialization after plugin updates because these are all variations of the same concern: ensuring the project has the right files in the right state. Template merge detection uses a `template-version` field rather than blind overwrites so that user customizations survive plugin updates. The codebase scan runs on first setup to generate a project-specific constitution rather than a generic placeholder, since the constitution drives all subsequent AI behavior. The bootstrap pattern generates both `AGENTS.md` (full body, agnostic source of truth — Codex reads it natively) and `CLAUDE.md` (one-line `@AGENTS.md` import stub — Claude Code reads it and expands the documented memory-import) so consumers get working setups for either AI tool from a single init run. The CLAUDE.md stub is a pointer, not a content duplicate, so single source of truth is preserved while both runtimes work without manual setup. Drift detection for specs and docs runs as a health check rather than auto-fixing, keeping the user in control of resolution decisions.

## Features

- **One-command setup** via `specshift init` -- copies Smart Templates, installs WORKFLOW.md, creates CONSTITUTION.md placeholder, generates both bootstrap files (AGENTS.md + CLAUDE.md), and validates the result
- **Agnostic bootstrap files** -- `AGENTS.md` carries the full body (Workflow, Planning with scope commitment and workflow routing, Knowledge Management) adapted with project-specific rules from the codebase scan; `CLAUDE.md` is a one-line `@AGENTS.md` import stub. Generated unconditionally on fresh init — no environment detection
- **Re-init preserves existing bootstrap files** -- existing `AGENTS.md` and `CLAUDE.md` are never overwritten; standard-section completeness is reported as WARNING only
- **Mid-migration recovery** -- if only `CLAUDE.md` exists (legacy single-target install), `AGENTS.md` is generated alongside it; if only `AGENTS.md` exists, the `CLAUDE.md` import stub is generated
- **Version-aware template merge** -- uses `template-version` fields to detect user customizations and merge plugin updates instead of overwriting
- **Constitution section-level merge** -- detects missing sections from newer template versions and offers to generate content for them based on the codebase
- **Codebase scanning** -- analyzes tech stack, frameworks, languages, file structure, and coding conventions to populate the constitution with project-specific values
- **Constitution generation** -- produces Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, and Standard Tasks sections from scan results
- **Environment checks** -- detects GitHub tooling availability and authentication status, reported informationally without blocking init
- **Legacy migration** -- detects old schema-based layouts and automatically migrates to the WORKFLOW.md format
- **Idempotent re-initialization** -- skips already-completed steps when run on an initialized project
- **Spec drift detection** -- compares existing specs against the codebase and reports discrepancies with suggested corrective actions
- **Documentation drift verification** -- checks capability docs, ADRs, and README against current specs across three dimensions with CLEAN/DRIFTED/OUT OF SYNC verdicts
- **Initial change creation** -- creates the first change workspace after constitution generation and hands off to the standard pipeline

## Behavior

### Fresh Project Initialization

When you run `specshift init` on a project without the workflow installed, the system copies Smart Templates from the plugin's templates directory, installs WORKFLOW.md from the plugin template, creates a CONSTITUTION.md placeholder, and generates `AGENTS.md` and `CLAUDE.md` from the bootstrap templates. The command validates that all files are in place and reports a summary. If the bootstrap files already exist, init skips their generation and preserves the existing files.

### Codebase Scanning and Constitution Generation

On first run (no existing CONSTITUTION.md), the system scans the entire project -- skipping binary files and respecting `.gitignore` patterns -- to identify the tech stack, frameworks, file structure, and coding conventions. The scan results populate a project-specific constitution with Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, and an empty Standard Tasks section with an explanatory comment.

### Template Merge on Re-Init

When re-running init after a plugin update, the system compares `template-version` fields between local and plugin templates. Unchanged templates are updated silently. User-customized templates are preserved with a notification. Templates with both local customizations and plugin updates prompt for manual merge resolution. For CONSTITUTION.md, the merge operates at section level -- missing sections from newer template versions are offered for interactive generation. For CLAUDE.md, the system checks section headings against the bootstrap template and reports missing standard sections as WARNING without modifying the file -- user edits to CLAUDE.md are authoritative.

### Legacy Migration

When the system detects a legacy project layout (presence of `.specshift/schemas/` without WORKFLOW.md), it generates WORKFLOW.md from schema.yaml, moves and converts templates to Smart Template format, renames the constitution file, and removes legacy directories.

### Recovery Mode (Spec Drift Detection)

When existing specs are found, init enters recovery mode: scanning the codebase, comparing against specs, and producing a read-only drift report. Minor drift prompts a targeted change suggestion; major drift suggests a full re-bootstrap.

### Documentation Drift Verification

As a health check, init verifies generated documentation against current specs across three dimensions: capability docs vs specs (missing docs are CRITICAL, omitted requirements are WARNING), ADRs vs design decisions (missing ADRs are WARNING, using `has_decisions` frontmatter to skip irrelevant designs), and README vs current state (missing capabilities are CRITICAL, stale ADR references are WARNING). The verdict is CLEAN, DRIFTED, or OUT OF SYNC. No issues are auto-fixed; the system recommends running `specshift finalize` to regenerate.

### Environment Checks

Init checks GitHub tooling availability and authentication. Results are informational -- they do not block init but determine which optional features (e.g., PR creation during the workflow) are available.

## Known Limitations

- Codebase scanning relies on static file analysis (file extensions, config files, package manifests) without executing project code.
- Recovery mode compares structural and naming patterns rather than performing deep semantic analysis of code behavior.
- Documentation drift detection checks structural alignment, not prose-level semantic equivalence.

## Edge Cases

- If the user lacks write permissions, init fails before making changes.
- If both lowercase `constitution.md` and uppercase `CONSTITUTION.md` exist during migration, init uses the lowercase content and renames to uppercase.
- If WORKFLOW.md exists alongside legacy `schema.yaml` (partial manual migration), init preserves WORKFLOW.md and skips migration.
- If the plugin `template-version` is lower than the local version (plugin downgrade), init warns and skips rather than downgrading.
- If an empty repository has no source code files, init generates a minimal constitution with placeholder sections.
- If the CLAUDE.md or AGENTS.md bootstrap template is missing from the plugin, init skips the corresponding bootstrap-file generation with a warning rather than blocking.
