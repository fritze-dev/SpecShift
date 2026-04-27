---
title: "Project Init"
capability: "project-init"
description: "One-command project initialization with template merge, codebase scanning, constitution generation, AGENTS.md + CLAUDE.md bootstrap, and health checks"
lastUpdated: "2026-04-27"
---

# Project Init

Sets up a project for the spec-driven workflow via `specshift init` -- installing templates, generating a constitution, writing both bootstrap files (`AGENTS.md` as the agnostic single source of truth and `CLAUDE.md` as a one-line `@AGENTS.md` import stub), configuring optional worktree isolation, and running health checks for spec and documentation drift.

## Purpose

Without a structured setup process, adopting spec-driven development requires manually creating configuration files, writing a constitution from scratch, and hoping the environment supports the features you need. Existing projects that drift from their specs have no way to detect the gap. Project Init handles all of this in a single command, whether you are starting fresh, migrating from a legacy layout, or checking the health of an established project.

## Rationale

A single `specshift init` command covers fresh installs, legacy migrations, and re-initialization after plugin updates because these are all variations of the same concern: ensuring the project has the right files in the right state. Template merge detection uses a `template-version` field rather than blind overwrites so that user customizations survive plugin updates. The codebase scan runs on first setup to generate a project-specific constitution rather than a generic placeholder, since the constitution drives all subsequent agent behavior. Bootstrap-file generation uses the agnostic single source of truth pattern: `AGENTS.md` carries the full agent directives (Codex reads it natively); `CLAUDE.md` is a one-line `@AGENTS.md` import stub that Claude Code expands at session start to load the AGENTS.md body into context. Init writes both files on fresh setup so the documented memory-import pattern is active without manual copy-paste, while SSOT is preserved because the stub is a pointer, not a content duplicate. Existing files are never overwritten on re-init — user edits are authoritative. Drift detection for specs and docs runs as a health check rather than auto-fixing, keeping the user in control of resolution decisions.

## Features

- **One-command setup** via `specshift init` -- copies Smart Templates, installs WORKFLOW.md, creates CONSTITUTION.md placeholder, generates both bootstrap files (`AGENTS.md` full body + `CLAUDE.md` one-line `@AGENTS.md` import stub), and validates the result
- **Agnostic bootstrap (full body)** -- generates `AGENTS.md` from the bootstrap template containing Workflow, Planning (with scope commitment and workflow routing), and Knowledge Management sections, adapted with project-specific rules from the codebase scan
- **CLAUDE.md import stub** -- generates `CLAUDE.md` containing a single `@AGENTS.md` line so Claude Code's documented memory-import pattern is active without manual setup. The stub is a pointer, not a content duplicate, so single source of truth is preserved
- **Version-aware template merge** -- uses `template-version` fields to detect user customizations and merge plugin updates instead of overwriting
- **Constitution section-level merge** -- detects missing sections from newer template versions and offers to generate content for them based on the codebase
- **Bootstrap section-level checks** -- during re-init, compares an existing AGENTS.md against bootstrap template section headings and reports missing standard sections as WARNING; CLAUDE.md (if present) is checked the same way but with WARNING-only reporting since its content is intentionally minimal. Init never modifies either bootstrap file -- user edits are authoritative
- **Partial bootstrap recovery** -- if a project from a pre-multi-target plugin version has only `CLAUDE.md`, re-running init writes a freshly generated `AGENTS.md` (full body) without overwriting the existing CLAUDE.md; if a project has only `AGENTS.md`, init generates the `CLAUDE.md` import stub alongside it
- **Codebase scanning** -- analyzes tech stack, frameworks, languages, file structure, and coding conventions to populate the constitution with project-specific values
- **Constitution generation** -- produces Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, and Standard Tasks sections from scan results
- **Environment checks** -- detects GitHub tooling availability, git version (2.5+ for worktree support), and `.gitignore` configuration
- **Worktree opt-in** -- offers to enable worktree-based change isolation when GitHub tooling is available, including GitHub merge strategy configuration
- **Legacy migration** -- detects old schema-based layouts and automatically migrates to the WORKFLOW.md format
- **Idempotent re-initialization** -- skips already-completed steps when run on an initialized project
- **Spec drift detection** -- compares existing specs against the codebase and reports discrepancies with suggested corrective actions
- **Documentation drift verification** -- checks capability docs, ADRs, and README against current specs across three dimensions with CLEAN/DRIFTED/OUT OF SYNC verdicts
- **Initial change creation** -- creates the first change workspace after constitution generation and hands off to the standard pipeline

## Behavior

### Fresh Project Initialization

When you run `specshift init` on a project without the workflow installed, the system copies Smart Templates from the plugin's templates directory, installs WORKFLOW.md from the plugin template, creates a CONSTITUTION.md placeholder, generates `AGENTS.md` from the bootstrap template (full body — Workflow, Planning, Knowledge Management, plus any project-specific sections from the codebase scan), and generates `CLAUDE.md` containing a single `@AGENTS.md` line. Codex reads `AGENTS.md` natively at session start; Claude Code reads `CLAUDE.md` and expands the `@AGENTS.md` import to load the AGENTS.md body into context — both targets get the same rules from one authored source. If GitHub tooling is available and authenticated, init offers to enable worktree mode and configure the GitHub repository for rebase-merge. The command validates that all files are in place and reports a summary.

### Codebase Scanning and Constitution Generation

On first run (no existing CONSTITUTION.md), the system scans the entire project -- skipping binary files and respecting `.gitignore` patterns -- to identify the tech stack, frameworks, file structure, and coding conventions. The scan results populate a project-specific constitution with Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, and an empty Standard Tasks section with an explanatory comment.

### Template Merge on Re-Init

When re-running init after a plugin update, the system compares `template-version` fields between local and plugin templates. Unchanged templates are updated silently. User-customized templates are preserved with a notification. Templates with both local customizations and plugin updates prompt for manual merge resolution. For CONSTITUTION.md, the merge operates at section level — missing sections from newer template versions are offered for interactive generation. For AGENTS.md, the system checks section headings against the bootstrap template and reports missing standard sections as WARNING. For CLAUDE.md (if present), the system runs the same check with WARNING-only reporting; CLAUDE.md content is intentionally minimal and may legitimately diverge. Init never modifies either bootstrap file -- user edits are authoritative.

### Legacy Migration

When the system detects a legacy project layout (presence of `.specshift/schemas/` without WORKFLOW.md), it generates WORKFLOW.md from schema.yaml, moves and converts templates to Smart Template format, renames the constitution file, and removes legacy directories.

### Recovery Mode (Spec Drift Detection)

When existing specs are found, init enters recovery mode: scanning the codebase, comparing against specs, and producing a read-only drift report. Minor drift prompts a targeted change suggestion; major drift suggests a full re-bootstrap.

### Documentation Drift Verification

As a health check, init verifies generated documentation against current specs across three dimensions: capability docs vs specs (missing docs are CRITICAL, omitted requirements are WARNING), ADRs vs design decisions (missing ADRs are WARNING, using `has_decisions` frontmatter to skip irrelevant designs), and README vs current state (missing capabilities are CRITICAL, stale ADR references are WARNING). The verdict is CLEAN, DRIFTED, or OUT OF SYNC. No issues are auto-fixed; the system recommends running `specshift finalize` to regenerate.

### Environment Checks

Init checks GitHub tooling availability and authentication, git version for worktree support, and `.gitignore` for the `/.claude/` entry. Results are informational -- they do not block init but determine which optional features are available.

## Known Limitations

- Codebase scanning relies on static file analysis (file extensions, config files, package manifests) without executing project code.
- Recovery mode compares structural and naming patterns rather than performing deep semantic analysis of code behavior.
- Documentation drift detection checks structural alignment, not prose-level semantic equivalence.
- Init detects bootstrap drift but does not auto-edit existing files. Missing standard sections are reported as WARNING; the user decides whether to run a follow-up `specshift propose` to add them.

## Edge Cases

- If the user lacks write permissions, init fails before making changes.
- If both lowercase `constitution.md` and uppercase `CONSTITUTION.md` exist during migration, init uses the lowercase content and renames to uppercase.
- If WORKFLOW.md exists alongside legacy `schema.yaml` (partial manual migration), init preserves WORKFLOW.md and skips migration.
- If the plugin `template-version` is lower than the local version (plugin downgrade), init warns and skips rather than downgrading.
- If an empty repository has no source code files, init generates a minimal constitution with placeholder sections.
- If a bootstrap template is missing from the plugin (`templates/agents.md` or `templates/claude.md`), init skips that file's generation with a warning rather than blocking — the other file is still generated normally.
- A consumer project initialized by a pre-multi-target plugin version (CLAUDE.md present, no AGENTS.md) receives a freshly generated AGENTS.md alongside the existing CLAUDE.md on re-init; the existing CLAUDE.md is left untouched (no overwrite, no merge), and init suggests in its summary that the user may collapse the CLAUDE.md body to a `@AGENTS.md` import stub manually if a single-source-of-truth pattern is desired.
