# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## 2026-04-13 — Plugin Version Check

### Added
- `plugin-version` field in WORKFLOW.md frontmatter — stamped by `specshift init` from `plugin.json`, enables automatic detection of plugin updates
- Plugin Version Check (Step 3) in SKILL.md router — advisory warning when installed plugin version differs from project's `plugin-version`, with actionable suggestion to run `specshift init`
- Plugin Version Stamp requirement in `project-init.md` — init writes `plugin-version` on fresh install, re-init, and legacy upgrades

### Changed
- SKILL.md router restructured from 5 redundant steps to 5 clean steps: Load Configuration → Identify Action → Plugin Version Check → Change Context Detection → Dispatch
- WORKFLOW.md is now read exactly once in Step 1 (previously referenced across Steps 1, 2, and 4)
- Workflow template `template-version` bumped from 2 to 3

## 2026-04-13 — Fix Loop Tiered Re-entry

### Changed
- Fix Loop now classifies corrections into three tiers before applying fixes: **Tweak** (fix in place), **Design Pivot** (update design + re-implement), **Scope Change** (update specs + design + full re-implementation)
- Concrete detection signals added for tier classification (e.g., "correction touches files outside design.md", "completed task needs revert")
- Artifact staleness rule: Design Pivot and Scope Change corrections must update all stale change artifacts before re-implementing
- Step 3.4 in tasks template restructured for readability (sub-bullets per tier)
- Template versions bumped: `workflow.md` and `changes/tasks.md` from v1 to v2

### Added
- Tier 3 (Scope Change) Gherkin scenario in human-approval-gate spec
- "Tier escalation within fix loop" edge case — handling when a Tweak reveals a deeper problem
- "Ambiguous tier classification" edge case — defaults to higher tier to ensure artifact freshness

## 2026-04-13 — AOT Prompt Compilation

### Added
- AOT (Ahead-of-Time) skill compilation: requirements are pre-extracted from specs into focused action files during finalize, reducing runtime token usage by ~50%
- `scripts/compile-skills.sh`: standalone compiler script that builds the release directory from source
- `src/actions/`: per-action requirement manifests with clickable relative links to specs
- `.claude/` as plugin root: standard Claude Code plugin layout with auto-discovery + marketplace distribution
- Instruction/requirements separation: instructions stay project-specific in WORKFLOW.md (JIT), requirements are plugin-level in compiled files (AOT)

### Changed
- Router SKILL.md reads instruction from WORKFLOW.md + compiled requirements from `actions/<action>.md` instead of resolving spec links at runtime
- Marketplace source changed from `./src` to `./.claude`
- Plugin distribution now includes only SKILL.md, compiled actions, templates, and plugin.json — no specs or docs shipped to consumers

## 2026-04-13 — Fix CLAUDE.md re-init drift + agnostic finalize version-bump

### Fixed
- CLAUDE.md bootstrap template is now checked during re-init — missing standard sections (Workflow, Knowledge Management) are reported as WARNING instead of going undetected (#10)
- Template synchronization convention corrected: `src/templates/` is the authoritative plugin source, `.specshift/` is synced from it

### Changed
- Consumer finalize version-bump step is now constitution-driven instead of plugin-specific — follows the version-bump convention from the project's constitution, skips if none defined (#11)
- Constitution generation now detects version files (package.json, pyproject.toml, Cargo.toml, etc.) during codebase scan and auto-generates a matching version-bump convention

### Added
- File Ownership section added to CLAUDE.md documenting `src/` vs `.specshift/` vs `docs/` distinction

## [0.1.0-beta] - 2026-04-12

Initial beta release. Complete restructuring and rebrand based on [opsx-enhanced-flow](https://github.com/fritze-dev/opsx-enhanced-flow).
