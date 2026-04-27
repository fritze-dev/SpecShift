---
order: 12
category: setup
status: stable
version: 6
lastModified: 2026-04-27
---
## Purpose

Handles project initialization via `specshift init`, including template installation, constitution generation, bootstrap-file generation (AGENTS.md and CLAUDE.md), codebase scanning, and project health checks (spec drift, docs drift detection from the former docs-verify functionality).

## Requirements

### Requirement: Install Workflow
The system SHALL provide `specshift init` as the single entry point for project setup. The init command SHALL: (1) copy pipeline Smart Templates from the plugin's `templates/` directory (at `${CLAUDE_PLUGIN_ROOT}/templates/`) into the project's `.specshift/templates/` directory — excluding bootstrap templates (`workflow.md`, `constitution.md`, `agents.md`, `claude.md`) which are used only to generate their target files, (2) generate `.specshift/WORKFLOW.md` from the plugin's workflow template at `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md` (skip if WORKFLOW.md already exists), (3) generate `.specshift/CONSTITUTION.md` from the plugin's constitution template if none exists, and (4) generate both `AGENTS.md` and `CLAUDE.md` from the bootstrap templates at `${CLAUDE_PLUGIN_ROOT}/templates/agents.md` and `${CLAUDE_PLUGIN_ROOT}/templates/claude.md` (see "Bootstrap Files Generation" requirement). The init command SHALL be idempotent — running it on an already-initialized project SHALL skip completed steps.

The init command SHALL check for GitHub tooling availability (gh CLI, MCP tools, or API). If GitHub tooling is available and authenticated, the init command SHALL ask the user whether to enable worktree-based change isolation. If the user opts in, the init command SHALL uncomment the `worktree:` section in the generated WORKFLOW.md and set `enabled: true`. The init command SHALL also offer to configure the GitHub repository merge strategy for rebase-merge using available GitHub tooling.

The init command SHALL NOT install any external CLI tools or require Node.js/npm as prerequisites.

The init command SHALL ensure target directories exist (via `mkdir -p`) before copying files.

**User Story:** As a new user I want a single `specshift init` command that sets up everything including optional worktree mode, so that I do not have to manually configure the project.

#### Scenario: First-time project initialization
- **GIVEN** a project directory without the spec-driven workflow installed
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL copy Smart Templates from `${CLAUDE_PLUGIN_ROOT}/templates/` to `.specshift/templates/`, copy WORKFLOW.md from `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md`, create `.specshift/CONSTITUTION.md` placeholder, generate `CLAUDE.md` from the bootstrap template, and verify the setup

#### Scenario: Idempotent re-initialization
- **GIVEN** a project that has already been initialized
- **WHEN** the user runs `specshift init` again
- **THEN** the system SHALL skip already-completed steps, preserve existing CONSTITUTION.md and WORKFLOW.md, and report what was already in place

#### Scenario: WORKFLOW.md copied from template
- **GIVEN** a project directory without `.specshift/WORKFLOW.md`
- **AND** the plugin has `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md`
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL copy workflow.md to `.specshift/WORKFLOW.md`

#### Scenario: Worktree opt-in during init
- **GIVEN** GitHub tooling is available and authenticated
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL ask whether to enable worktree-based change isolation
- **AND** if the user opts in, SHALL uncomment the `worktree:` section in WORKFLOW.md and set `enabled: true`
- **AND** SHALL offer to configure the GitHub repo for rebase-merge

#### Scenario: No GitHub tooling available
- **GIVEN** no GitHub tooling is available or not authenticated
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL skip the worktree opt-in question
- **AND** SHALL leave the `worktree:` section commented out in WORKFLOW.md

### Requirement: Legacy Migration
The init command SHALL detect legacy project layouts (presence of `openspec/schemas/opsx-enhanced/schema.yaml` without `.specshift/WORKFLOW.md`) and perform migration: (1) generate WORKFLOW.md from schema.yaml content and config.yaml settings, (2) move templates from `openspec/schemas/opsx-enhanced/templates/` to `.specshift/templates/` converting them to Smart Template format, (3) rename `.specshift/constitution.md` to `.specshift/CONSTITUTION.md`, (4) remove the `openspec/schemas/` directory and `openspec/config.yaml` after successful migration.

**User Story:** As an existing user I want `specshift init` to automatically migrate my project from the old schema layout, so that I don't have to manually restructure files.

#### Scenario: Legacy layout detected and migrated
- **GIVEN** a project with `openspec/schemas/opsx-enhanced/schema.yaml` but no `.specshift/WORKFLOW.md`
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL generate WORKFLOW.md, move and convert templates, rename constitution, and remove legacy files

#### Scenario: Migration preserves existing content
- **GIVEN** a legacy project with custom constitution content
- **WHEN** migration runs
- **THEN** the CONSTITUTION.md SHALL contain the original constitution content (renamed, not regenerated)

#### Scenario: Already migrated project is not re-migrated
- **GIVEN** a project with `.specshift/WORKFLOW.md` already present
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL skip migration and report that WORKFLOW.md already exists

### Requirement: Template Merge on Re-Init
When `specshift init` runs on an already-initialized project (re-init after plugin update), the system SHALL use Smart Template `template-version` fields to detect user customizations and merge plugin updates instead of blindly overwriting. For each template file in `${CLAUDE_PLUGIN_ROOT}/templates/`:

1. **Read** the plugin template's `template-version` field and the local template's `template-version` field at `.specshift/templates/<path>`.
2. **Compare versions:**
   - If the local template does not exist: copy the plugin template (fresh install).
   - If the local `template-version` matches the plugin `template-version` AND content is identical: skip (already up to date).
   - If the local `template-version` matches the plugin `template-version` BUT content differs: the user has customized the template. Keep the local version and report: "Template <name> has local customizations — skipped."
   - If the plugin `template-version` is higher than the local `template-version` AND the local content matches the previous plugin version (no user changes): update silently to the new plugin template.
   - If the plugin `template-version` is higher AND the local content has been customized: merge is needed. The system SHALL present both versions to the user and ask them to resolve differences. Report: "Template <name> has both local customizations and plugin updates — merge required."
   - If the local template has no `template-version` field (legacy): treat as version 0 and apply the same logic (likely results in silent update if content matches plugin template, or merge prompt if customized).

The merge detection SHALL apply to all Smart Templates including docs templates in subdirectories, WORKFLOW.md, and CONSTITUTION.md. WORKFLOW.md is especially important for merge detection because the plugin frequently updates behavioral fields (`apply.instruction`, `context`) while users customize project-specific fields (`worktree`, `docs_language`, pipeline order). The existing skip-if-exists behavior for WORKFLOW.md is replaced by version-based merge detection.

For CONSTITUTION.md, the merge operates at **section level**: the system SHALL compare the template's section headings (e.g., `## Tech Stack`, `## Architecture Rules`, `## Standard Tasks`) against the existing CONSTITUTION.md. Missing sections from a newer template version SHALL be offered to the user for interactive generation (the agent reads the codebase and proposes content for the new section, as bootstrap does). Existing sections with user content SHALL be preserved. The generated CONSTITUTION.md SHALL include a `template-version` field in YAML frontmatter to track which template version generated its structure.

For CLAUDE.md, the merge operates at **section level with WARNING-only reporting**: the system SHALL compare the bootstrap template's section headings (e.g., `## Workflow`, `## Knowledge Management`) against the existing CLAUDE.md. Missing standard sections SHALL be reported as WARNING (e.g., "CLAUDE.md missing standard section: Knowledge Management"). The system SHALL NOT modify the existing CLAUDE.md — user edits are authoritative. This check ensures that standard agent directives are not silently lost when CLAUDE.md is manually edited or created before the plugin is installed.

**User Story:** As a user who has customized my templates I want plugin updates to preserve my customizations, so that re-running `specshift init` after a plugin update does not silently destroy my changes.

#### Scenario: Unchanged template updated silently
- **GIVEN** a local template `.specshift/templates/changes/research.md` with `template-version: 1` matching the plugin template content exactly
- **AND** the plugin update has `template-version: 2` with updated instruction text
- **WHEN** the user runs `specshift init`
- **THEN** the local template SHALL be replaced with the plugin's template-version 2 template
- **AND** the report SHALL show "Template research.md updated (v1 → v2)"

#### Scenario: User-customized template preserved
- **GIVEN** a local template `.specshift/templates/changes/research.md` with `template-version: 1` but modified instruction content
- **AND** the plugin template also has `template-version: 1`
- **WHEN** the user runs `specshift init`
- **THEN** the local template SHALL NOT be overwritten
- **AND** the report SHALL show "Template research.md has local customizations — skipped"

#### Scenario: Customized template with plugin update triggers merge
- **GIVEN** a local template with `template-version: 1` and custom content
- **AND** the plugin template has `template-version: 2` with new content
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL present both versions and ask the user to resolve
- **AND** SHALL NOT overwrite the local template without user confirmation

#### Scenario: Constitution gets new section from template update
- **GIVEN** an existing `.specshift/CONSTITUTION.md` with `template-version: 1` containing Tech Stack, Architecture Rules, Code Style, Constraints, Conventions
- **AND** the plugin's constitution template has `template-version: 2` with a new `## Security Rules` section
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL detect the missing "Security Rules" section
- **AND** SHALL offer to generate content for it based on the codebase
- **AND** SHALL preserve all existing sections and their user content

#### Scenario: Constitution with all sections up to date
- **GIVEN** an existing CONSTITUTION.md with `template-version: 2` matching the plugin template
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL skip CONSTITUTION.md (already up to date)

#### Scenario: Legacy template without version field
- **GIVEN** a local template with no `template-version` field in frontmatter
- **AND** the plugin template has `template-version: 1`
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL treat the local version as 0
- **AND** SHALL update silently if content matches the plugin template, or prompt for merge if customized

### Requirement: Init Validation
The init command SHALL validate after all steps complete. Validation SHALL confirm that `.specshift/WORKFLOW.md` is readable, `.specshift/templates/` contains Smart Templates, and `.specshift/CONSTITUTION.md` is present. The init command SHALL report a summary.

**User Story:** As a user I want init to verify everything works, so that I can trust the environment is ready.

#### Scenario: Successful validation after fresh init
- **GIVEN** the init command has completed all steps
- **WHEN** validation runs
- **THEN** the system SHALL verify WORKFLOW.md is readable, templates directory exists with files, and CONSTITUTION.md is present

#### Scenario: Validation detects partial init failure
- **GIVEN** the init completed but template copy failed
- **WHEN** validation runs
- **THEN** the system SHALL detect the missing templates and report the failure

### Requirement: WORKFLOW.md Template File

The plugin SHALL include a workflow template file at `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md` containing the default WORKFLOW.md content with YAML frontmatter (`templates_dir`, `pipeline`, `apply`, `context`, `docs_language`) and a commented-out `worktree:` section. The `specshift init` skill SHALL copy this template to `.specshift/WORKFLOW.md` instead of generating the content inline. This ensures WORKFLOW.md is maintained as a template file consistent with the constitution template pattern.

**User Story:** As a plugin maintainer I want WORKFLOW.md content maintained as a template file, so that it is consistent with the constitution template and easier to update across versions.

#### Scenario: Template contains default pipeline configuration

- **GIVEN** the workflow template at `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md`
- **WHEN** its content is inspected
- **THEN** it SHALL contain `templates_dir`, `pipeline`, `apply`, and `context` in YAML frontmatter

#### Scenario: Template contains commented-out worktree section

- **GIVEN** the workflow template at `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md`
- **WHEN** its content is inspected
- **THEN** it SHALL contain a commented-out `worktree:` section with `enabled`, `path_pattern`, and `auto_cleanup` fields

### Requirement: Environment Checks During Init

The init command SHALL check the environment for: (1) GitHub tooling availability (gh CLI, MCP tools, or API) and authentication status, (2) git version by running `git --version` and verifying it is 2.5+ (required for worktree support), (3) `.gitignore` contains a `/.claude/` entry (required for worktree paths to be excluded from version control). The results SHALL be reported in the init summary. The environment checks SHALL NOT block init — they only inform which optional features (worktree mode, PR creation, merge strategy) are available. If git version is below 2.5, the system SHALL skip the worktree opt-in question and report that worktree mode requires git 2.5+. If `/.claude/` is not in `.gitignore`, the system SHALL offer to add it when the user opts into worktree mode.

**User Story:** As a user I want init to detect my environment capabilities, so that I know which features are available without manual checking.

#### Scenario: GitHub tooling detected and authenticated

- **GIVEN** GitHub tooling is available and authenticated
- **WHEN** the user runs `specshift init`
- **THEN** the system reports "GitHub tooling: available and authenticated"
- **AND** offers worktree mode and merge strategy configuration

#### Scenario: No GitHub tooling found

- **GIVEN** no GitHub tooling is available
- **WHEN** the user runs `specshift init`
- **THEN** the system reports "GitHub tooling: not found"
- **AND** skips worktree and merge strategy options

#### Scenario: Git version supports worktrees

- **GIVEN** git version is 2.5 or higher
- **WHEN** the user runs `specshift init`
- **THEN** the system reports "git: version X.Y (worktree support: yes)"

#### Scenario: Git version too old for worktrees

- **GIVEN** git version is below 2.5
- **WHEN** the user runs `specshift init`
- **THEN** the system reports "git: version X.Y (worktree support: no — requires 2.5+)"
- **AND** skips the worktree opt-in question

#### Scenario: Gitignore missing .claude/ entry

- **GIVEN** `.gitignore` does not contain `/.claude/`
- **AND** the user opts into worktree mode
- **WHEN** init configures worktree mode
- **THEN** the system SHALL offer to add `/.claude/` to `.gitignore`
- **AND** if the user agrees, append the entry to `.gitignore`

#### Scenario: Gitignore already has .claude/ entry

- **GIVEN** `.gitignore` already contains `/.claude/`
- **WHEN** the user runs `specshift init`
- **THEN** the system reports ".gitignore: /.claude/ entry present"

### Requirement: GitHub Merge Strategy Configuration

When the user opts in during init and GitHub tooling is available, the system SHALL configure the GitHub repository merge strategy for rebase-merge by setting `allow_rebase_merge=true` on the repository using available GitHub tooling. The system SHALL report the configuration result. If the API call fails (e.g., insufficient permissions), the system SHALL report the failure and continue init.

**User Story:** As a team lead I want the repo configured for rebase-merge during init, so that worktree-based changes merge cleanly with linear history.

#### Scenario: Configure rebase-merge strategy

- **GIVEN** the user opts in to worktree mode during init
- **AND** GitHub tooling is authenticated with repo admin permissions
- **WHEN** init configures the merge strategy
- **THEN** the system sets `allow_rebase_merge=true` on the repository using available GitHub tooling
- **AND** reports "GitHub merge strategy: rebase-merge enabled"

#### Scenario: Merge strategy configuration fails

- **GIVEN** the user opts in to worktree mode
- **AND** GitHub tooling lacks admin permissions
- **WHEN** init attempts to configure the merge strategy
- **THEN** the system reports the failure
- **AND** continues with the rest of init

### Requirement: First-Run Codebase Scan
The `specshift init` command SHALL analyze the entire project codebase on first run (when no `.specshift/CONSTITUTION.md` exists or it is a placeholder). The scan SHALL identify the tech stack, frameworks, languages, file structure, configuration patterns, dependency management approach, coding conventions, and version files (e.g., `package.json`, `pyproject.toml`, `Cargo.toml`, `plugin.json`, `setup.cfg`). The scan results SHALL be used as input for constitution generation. The init command SHALL handle projects of any size, skipping binary files and respecting `.gitignore` patterns.

**User Story:** As a developer adopting spec-driven development on an existing project I want init to understand my codebase automatically, so that the generated constitution reflects my actual project rather than generic defaults.

#### Scenario: First-run scan of an existing project
- **GIVEN** a project with source code, configuration files, and dependencies but no `.specshift/CONSTITUTION.md`
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL scan the entire codebase and identify the tech stack, languages, frameworks, file structure, and coding conventions

#### Scenario: Large project with binary files
- **GIVEN** a project containing source code, images, compiled binaries, and a `.gitignore` file
- **WHEN** the init scan runs
- **THEN** the system SHALL skip binary files and files matching `.gitignore` patterns, analyzing only text-based source and configuration files

### Requirement: Constitution Generation
The `specshift init` command SHALL generate a `CONSTITUTION.md` file based on the observed patterns from the codebase scan. The constitution SHALL include Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, and Standard Tasks sections. The Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions sections SHALL be populated with project-specific values from the scan. If version files are detected, the Conventions section SHALL include a version-bump convention describing which file(s) to bump and how. If no version files are found, the version-bump convention SHALL be omitted — the finalize workflow skips the version-bump step when no convention is defined. The Standard Tasks section SHALL be generated empty with an HTML comment explaining its purpose, so that new projects are aware of the feature and know where to define project-specific post-implementation steps.

**User Story:** As a developer I want the constitution to be auto-generated from my codebase, so that it accurately captures my project's existing patterns rather than requiring me to write it from scratch.

#### Scenario: Constitution generated from scan results
- **GIVEN** the codebase scan has completed and identified TypeScript, React, and Jest as the primary technologies
- **WHEN** the constitution generation phase runs
- **THEN** the system SHALL create `.specshift/CONSTITUTION.md` with Tech Stack listing TypeScript, React, and Jest, along with Architecture Rules, Code Style, Constraints, Conventions, and an empty Standard Tasks section reflecting the observed patterns

#### Scenario: Standard Tasks section present but empty on first run
- **GIVEN** a new project being initialized for the first time
- **WHEN** the constitution generation phase runs
- **THEN** the generated constitution SHALL contain a `## Standard Tasks` section
- **AND** the section SHALL be empty except for an HTML comment explaining that project-specific extras can be added here to appear in every tasks.md after the universal standard tasks

#### Scenario: Constitution respects existing conventions
- **GIVEN** a project using 4-space indentation, camelCase variables, and conventional commits
- **WHEN** the constitution is generated
- **THEN** the Code Style section SHALL reflect the 4-space indentation and camelCase convention, and the Conventions section SHALL reference the conventional commits format

### Requirement: Bootstrap Files Generation
The `specshift init` command SHALL generate both `AGENTS.md` and `CLAUDE.md` at the project root to support both Codex CLI (which reads `AGENTS.md` natively) and Claude Code (which reads `CLAUDE.md`). Generation SHALL operate as follows:

1. **AGENTS.md (full content)**: Generated from the bootstrap template at `${CLAUDE_PLUGIN_ROOT}/templates/agents.md`. The generated AGENTS.md SHALL contain at minimum: (a) a `## Workflow` section directing all changes through the spec-driven workflow, (b) a `## Planning` section requiring explicit scope commitment before exiting plan mode and workflow routing through the specshift skill for implementation steps, and (c) a `## Knowledge Management` section directing the agent to use transparent artifacts instead of auto-memory for project knowledge. The agent SHALL adapt the template content to include project-specific rules discovered during the codebase scan (for example, adding a `## File Ownership` section reflecting the consumer project's directory layout), using REVIEW markers for uncertain items.

2. **CLAUDE.md (import stub)**: Generated from the bootstrap template at `${CLAUDE_PLUGIN_ROOT}/templates/claude.md`. The generated CLAUDE.md SHALL be a small stub containing an `@AGENTS.md` import directive (Claude Code's documented memory-import syntax) plus optional Claude-Code-specific instructions that do not apply to other targets. CLAUDE.md SHALL NOT duplicate normative rules from AGENTS.md.

If both files do not exist, init SHALL generate both. If only one exists, init SHALL generate the missing one and leave the existing one untouched. If both exist, init SHALL skip generation and report "AGENTS.md and CLAUDE.md already exist — skipped." Init SHALL never overwrite an existing AGENTS.md or CLAUDE.md.

When an existing AGENTS.md is detected, init SHALL check it against the bootstrap template's section headings and report WARNING for each missing standard section. The same check SHALL NOT be applied to CLAUDE.md when a custom CLAUDE.md exists, because CLAUDE.md content is intentionally minimal and may legitimately diverge from the stub template (e.g., a user may add Claude-specific overrides).

**User Story:** As a developer using either Claude Code or Codex (or both) I want init to generate the correct bootstrap files without me having to choose, so that whichever tool I open the project in finds the workflow rules already in place.

#### Scenario: Both files generated on fresh init
- **GIVEN** a project with no `AGENTS.md` and no `CLAUDE.md`
- **AND** the plugin has bootstrap templates at `${CLAUDE_PLUGIN_ROOT}/templates/agents.md` and `${CLAUDE_PLUGIN_ROOT}/templates/claude.md`
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL generate `AGENTS.md` containing `## Workflow`, `## Planning`, and `## Knowledge Management` sections (and any project-specific sections derived from the codebase scan)
- **AND** SHALL generate `CLAUDE.md` containing an `@AGENTS.md` import directive

#### Scenario: AGENTS.md exists but CLAUDE.md missing
- **GIVEN** a project with an existing `AGENTS.md` and no `CLAUDE.md`
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL generate `CLAUDE.md` (import stub)
- **AND** SHALL NOT overwrite the existing `AGENTS.md`
- **AND** SHALL run the standard-sections check on the existing AGENTS.md and report WARNING for any missing section

#### Scenario: CLAUDE.md exists but AGENTS.md missing
- **GIVEN** a project with an existing `CLAUDE.md` (e.g., from a pre-multi-target version of the plugin) and no `AGENTS.md`
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL generate `AGENTS.md` (full body)
- **AND** SHALL NOT overwrite the existing `CLAUDE.md`
- **AND** SHALL report that the existing CLAUDE.md may need to be reduced to an import stub manually

#### Scenario: Both files exist
- **GIVEN** a project where both `AGENTS.md` and `CLAUDE.md` already exist
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL NOT overwrite either file
- **AND** SHALL report "AGENTS.md and CLAUDE.md already exist — skipped"

#### Scenario: AGENTS.md missing standard section detected on re-init
- **GIVEN** a project with an existing `AGENTS.md` containing `## Workflow` but lacking `## Planning` or `## Knowledge Management`
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL NOT overwrite or modify `AGENTS.md`
- **AND** SHALL report WARNING for each missing standard section (e.g., "AGENTS.md missing standard section: Planning")
- **AND** SHALL suggest the user add the missing section manually

#### Scenario: AGENTS.md includes project-specific rules
- **GIVEN** a project with specific conventions discovered during the codebase scan
- **WHEN** the init command generates AGENTS.md
- **THEN** the generated file SHALL include project-specific agent rules beyond the standard sections
- **AND** uncertain items SHALL be marked with `<!-- REVIEW -->` for user resolution

#### Scenario: CLAUDE.md import directive resolves correctly
- **GIVEN** a project with the generated `AGENTS.md` and `CLAUDE.md` import-stub
- **WHEN** Claude Code starts a session in the project
- **THEN** Claude Code SHALL load `CLAUDE.md`
- **AND** SHALL expand the `@AGENTS.md` import to include AGENTS.md content in the session context

### Requirement: Initial Change Creation
After generating the constitution, the `specshift init` command SHALL create an initial change workspace and hand off to the standard pipeline. The initial change SHALL be named according to the project context (e.g., `initial-spec`). The init command SHALL then inform the user to continue with the standard pipeline.

**User Story:** As a developer I want init to create my first change workspace automatically, so that I can immediately start the spec-driven workflow without manual setup.

#### Scenario: Initial change workspace created after constitution
- **GIVEN** the constitution has been generated successfully
- **WHEN** the initial change creation phase runs
- **THEN** the system SHALL create a change workspace with an appropriate name and inform the user to run `specshift propose` to generate artifacts

#### Scenario: Handoff to standard pipeline
- **GIVEN** the initial change workspace has been created
- **WHEN** the init command completes
- **THEN** the system SHALL report the created change name and inform the user to run `specshift propose` to generate artifacts, followed by `specshift apply`, then `specshift finalize`

### Requirement: Recovery Mode (Spec Drift Detection)
The `specshift init` command SHALL detect when specs already exist in `docs/specs/`. When existing specs are found, the init command SHALL enter recovery mode: scanning the current codebase, comparing it against existing specs, and reporting drift findings. Recovery mode SHALL NOT overwrite existing specs or the constitution. Instead, it SHALL produce a drift report listing discrepancies between the codebase and the specs, and suggest corrective actions (e.g., `specshift propose hotfix-xyz` for small drift or a full re-bootstrap for large drift).

**User Story:** As a maintainer whose codebase has drifted from its specs I want init to detect and report the drift, so that I can decide how to reconcile without losing existing spec work.

#### Scenario: Recovery mode with minor drift
- **GIVEN** a project with existing specs and a codebase where two functions have been renamed without spec updates
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL detect the existing specs, enter recovery mode, report the two naming discrepancies, and suggest using `specshift propose hotfix-xyz` to create a targeted change for the drift

#### Scenario: Recovery mode with major drift
- **GIVEN** a project with existing specs and a codebase where an entire module has been rewritten without spec updates
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL detect the existing specs, enter recovery mode, report the extensive drift, and suggest a full re-bootstrap after backing up existing specs

#### Scenario: Recovery mode does not overwrite
- **GIVEN** a project with existing specs and constitution
- **WHEN** the user runs `specshift init` and recovery mode activates
- **THEN** the system SHALL NOT modify any existing spec files or the constitution, only producing a read-only drift report

### Requirement: Documentation Drift Verification (Health Check)

The system SHALL verify that generated documentation accurately reflects the current state of specs as part of `specshift init` project-level health checks. The verification SHALL assess three dimensions:

1. **Capability Docs vs Specs** — For each spec in `docs/specs/*.md`, the system SHALL check that a corresponding capability doc exists in `docs/capabilities/` and that the doc's Purpose section aligns with the spec's Purpose, and that documented features cover the spec's requirements. Missing capability docs SHALL be classified as CRITICAL. Capability docs that omit requirements present in the spec SHALL be classified as WARNING.

2. **ADRs vs Design Decisions** — The system SHALL scan all completed change directories' `design.md` files in `.specshift/changes/*/design.md`. For each design.md, the system SHALL first check the frontmatter `has_decisions` field — if `false` or absent, skip this design.md. If `true`, scan for Decisions tables and verify that each decision has a corresponding ADR in `docs/decisions/`. Missing ADRs SHALL be classified as WARNING. The system SHALL recognize manual ADRs (prefix `adr-MNNN`) and skip them during the cross-check, since they have no corresponding design.md entry.

3. **README vs Current State** — The system SHALL verify that `docs/README.md` lists all current capabilities from `docs/specs/` in its capabilities table, that the Key Design Decisions table references existing ADRs, and that the architecture overview is consistent with `.specshift/CONSTITUTION.md`. Missing capabilities in the README SHALL be classified as CRITICAL. Stale ADR references (pointing to deleted or renamed ADRs) SHALL be classified as WARNING.

Each issue found SHALL be classified as:
- **CRITICAL** — documentation is missing or fundamentally incorrect (e.g., capability doc missing entirely, README omits a capability)
- **WARNING** — documentation exists but has drifted from specs (e.g., requirement not reflected in capability doc, stale ADR reference)
- **INFO** — minor discrepancy or observation that may be intentional (e.g., manual ADR with no matching design decision, capability doc has extra context beyond spec)

The system SHALL produce a verification report with a summary (total issues by severity), followed by findings grouped by dimension, with file references for each issue. The report SHALL conclude with a verdict: **CLEAN** (0 critical, 0 warnings), **DRIFTED** (warnings but no criticals), or **OUT OF SYNC** (at least one critical). The system SHALL NOT automatically fix any issues; it SHALL recommend running `specshift finalize` to regenerate drifted documentation.

The system SHALL gracefully handle missing documentation directories: if `docs/capabilities/` does not exist, the system SHALL report all capabilities as missing (CRITICAL) rather than erroring. If `docs/decisions/` does not exist, the system SHALL skip the ADR dimension and note it. If `docs/README.md` does not exist, the system SHALL report it as a single CRITICAL issue.

**User Story:** As a developer I want to verify that my generated documentation still matches the current specs, so that I can detect documentation drift before it causes confusion or misinformation.

#### Scenario: All documentation is in sync

- **GIVEN** a project with 5 capabilities, each having a corresponding capability doc in `docs/capabilities/`
- **AND** all completed changes' design decisions have corresponding ADRs in `docs/decisions/`
- **AND** `docs/README.md` lists all 5 capabilities and references valid ADRs
- **WHEN** the user invokes `specshift init`
- **THEN** the system produces a verification report
- **AND** all three dimensions show no issues
- **AND** the verdict is "CLEAN"

#### Scenario: Capability doc missing for a spec

- **GIVEN** a project with specs for "user-auth" and "data-export"
- **AND** `docs/capabilities/` contains only `user-auth.md` (no `data-export.md`)
- **WHEN** the user invokes `specshift init`
- **THEN** the Capability Docs dimension reports a CRITICAL issue: "Missing capability doc for data-export"
- **AND** the recommendation is "Run `specshift finalize` to generate the missing documentation"
- **AND** the verdict is "OUT OF SYNC"

#### Scenario: Capability doc omits a requirement from spec

- **GIVEN** a spec for "quality-gates" with requirements for Preflight, Verify, and Docs-Verify
- **AND** the capability doc `docs/capabilities/quality-gates.md` only documents Preflight and Verify
- **WHEN** the system checks Capability Docs vs Specs
- **THEN** the report includes a WARNING: "Capability doc for quality-gates missing requirement: Documentation Drift Verification"
- **AND** the verdict is "DRIFTED"

#### Scenario: README missing a capability

- **GIVEN** a project with 6 specs in `docs/specs/`
- **AND** `docs/README.md` capabilities table lists only 5 of them
- **WHEN** the system checks README vs Current State
- **THEN** the report includes a CRITICAL issue: "README capabilities table missing: <capability-name>"
- **AND** recommends "Run `specshift finalize` to regenerate the README"

#### Scenario: Stale ADR reference in README

- **GIVEN** a README Key Design Decisions table referencing `adr-005-old-caching.md`
- **AND** the file `docs/decisions/adr-005-old-caching.md` does not exist
- **WHEN** the system checks README vs Current State
- **THEN** the report includes a WARNING: "README references non-existent ADR: adr-005-old-caching.md"

#### Scenario: Documentation directory does not exist

- **GIVEN** a project where `docs/capabilities/` has not been created yet
- **WHEN** the user invokes `specshift init`
- **THEN** the system reports each spec as a CRITICAL missing capability doc
- **AND** does not error or abort
- **AND** recommends "Run `specshift finalize` to generate initial documentation"

#### Scenario: No design decisions to check

- **GIVEN** a project with no completed changes in `.specshift/changes/`
- **WHEN** the user invokes `specshift init`
- **THEN** the system skips the ADR dimension
- **AND** notes "No design decisions to verify against"
- **AND** still checks the other two dimensions

#### Scenario: Manual ADR without design decision is not flagged

- **GIVEN** a manual ADR `docs/decisions/adr-M001-initial-approach.md`
- **AND** no corresponding entry in any completed change's design.md Decisions table
- **WHEN** the system checks ADRs vs Design Decisions
- **THEN** the manual ADR is recognized by its `adr-MNNN` prefix
- **AND** no issue is raised for it

## Edge Cases

- If the user does not have write permissions, init SHALL fail before making changes.
- If migration encounters both WORKFLOW.md and legacy schema.yaml (manual partial migration), init SHALL preserve WORKFLOW.md and skip migration.
- If `.specshift/constitution.md` (lowercase) and `.specshift/CONSTITUTION.md` (caps) both exist during migration, init SHALL use the lowercase content and rename to caps.
- **Workflow template missing from plugin**: If `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md` does not exist, report an error and suggest reinstalling the plugin.
- **Bootstrap template missing from plugin**: If `${CLAUDE_PLUGIN_ROOT}/templates/agents.md` or `${CLAUDE_PLUGIN_ROOT}/templates/claude.md` does not exist, skip the corresponding file generation and warn that the plugin may need updating. Do not block init.
- **CLAUDE.md or AGENTS.md manually edited after init**: User edits to either file are authoritative. Re-running init SHALL NOT overwrite a manually edited bootstrap file.
- **Project initialized before multi-target support**: A project with an existing CLAUDE.md but no AGENTS.md (initialized by a pre-multi-target version of the plugin) SHALL receive a freshly generated AGENTS.md with the full body, and the existing CLAUDE.md SHALL remain untouched. The user is responsible for collapsing CLAUDE.md to an import stub manually if they want the new pattern; init SHALL only suggest this in its summary, not enforce it.
- **Template merge with subdirectories**: The merge detection SHALL recursively process templates in subdirectories (e.g., `templates/docs/spec.md`, `templates/docs/capability.md`).
- **Plugin downgrades**: If the plugin `template-version` is lower than the local `template-version`, the system SHALL warn and skip (do not downgrade).
- **GitHub tooling available but not authenticated**: Report "GitHub tooling: available but not authenticated" and skip worktree opt-in.
- **User declines worktree mode**: Leave WORKFLOW.md with commented-out `worktree:` section — no changes needed.
- If the project has no source code files (empty repository), init SHALL generate a minimal constitution with placeholder sections and inform the user to update it manually.
- If the codebase uses multiple languages or conflicting conventions, the constitution SHALL document the primary patterns and note the variations as exceptions.
- If `.specshift/CONSTITUTION.md` exists but `docs/specs/` is empty, init SHALL treat this as a partial first-run and skip constitution generation while proceeding to initial change creation.
- If the project has an extremely deep directory structure, the scan SHALL use reasonable depth limits to avoid performance issues.
- **Spec with no matching doc name**: If a spec directory uses a different naming convention than the capability doc filename, the system SHALL attempt to match by reading the doc's frontmatter `title` or first heading before reporting it as missing.
- **Multiple specs mapping to one doc**: If a documentation restructuring merged multiple specs into one doc, the system SHALL report this as INFO rather than flagging missing docs.
- **Empty capability doc**: If a capability doc exists but has no meaningful content (only frontmatter or a single heading), the system SHALL classify it as WARNING ("Capability doc for <name> appears empty").
- **README with custom sections**: The system SHALL only check the capabilities table and Key Design Decisions table within the README, not custom project-specific sections that may intentionally differ from specs.
- **Concurrent docs regeneration**: If `specshift finalize` is running concurrently, the verification report reflects the state at the time of each individual check.
## Assumptions

- GitHub tooling availability can be reliably detected at init time (gh CLI via `gh --version`, MCP tools via tool listing, API via token presence). <!-- ASSUMPTION: GitHub tooling detection -->
- GitHub tooling authentication status can be verified before attempting operations. <!-- ASSUMPTION: GitHub auth check -->
- `git --version` output contains a parseable version number (e.g., "git version 2.43.0"). <!-- ASSUMPTION: git version parseable -->
- The init command can reliably detect tech stack and conventions from static file analysis (file extensions, configuration files, package manifests) without executing any project code. <!-- ASSUMPTION: Static analysis sufficient -->
- Recovery mode's drift detection compares structural and naming patterns rather than performing deep semantic analysis of code behavior. <!-- ASSUMPTION: Structural comparison -->
- Capability docs in `docs/capabilities/` follow the naming convention `<capability-name>.md` matching the spec directory name in `docs/specs/`. <!-- ASSUMPTION: Naming convention -->
- The README capabilities table uses a parseable format (Markdown table or structured list) that allows the system to extract capability names. <!-- ASSUMPTION: README format -->
- Completed changes' design.md Decisions tables use a consistent Markdown table format with identifiable column headers. <!-- ASSUMPTION: Design decisions format -->
No further assumptions beyond those marked above.
