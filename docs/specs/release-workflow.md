---
order: 12
category: finalization
status: stable
version: 6
lastModified: 2026-04-28
---
## Purpose

Define the release-workflow conventions for the multi-target plugin, including the agnostic version source of truth, symmetric version stamping into all per-target manifests and marketplaces, manual minor/major release processes, consumer update guidance for both targets, skill immutability rules, end-to-end install/update checklists, changelog generation from completed changes, and AOT (Ahead-of-Time) skill compilation that builds a self-contained shared skill tree at `./skills/specshift/` consumed by Claude Code and Codex via their respective root manifests.

## Requirements

### Requirement: Auto Patch Version Bump

The project constitution SHALL define a convention that instructs the post-apply workflow to automatically increment the patch version in `src/VERSION` after a successful change completion. `src/VERSION` is the single agnostic version source of truth — manifest and marketplace files at the repository root carry the version only as a stamped copy. The output SHALL display the new version. The subsequent compile run SHALL propagate the new version into the three root files (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`).

**User Story:** As a plugin maintainer I want the patch version to auto-increment when a change is completed, so that consumers can detect updates without manual version bumps.

#### Scenario: Successful auto-bump after change completion

- **GIVEN** a plugin project with `src/VERSION` containing `1.0.3`
- **AND** the constitution defines the post-completion auto-bump convention
- **WHEN** the post-apply workflow runs for a completed change
- **THEN** the system SHALL update `src/VERSION` to `1.0.4`
- **AND** the subsequent compile run SHALL stamp `1.0.4` into all three root manifest/marketplace files
- **AND** the output SHALL display the new version

### Requirement: Version Sync Between Plugin Files

The `version` field in every per-target manifest and marketplace file at the repository root MUST equal the value in `src/VERSION`. The compile script SHALL enforce this by reading `src/VERSION` and stamping the value into `.claude-plugin/plugin.json` (`.version`), `.claude-plugin/marketplace.json` (`.plugins[].version`), and `.codex-plugin/plugin.json` (`.version`). After stamping, the script SHALL re-read each file and verify the stamped version equals the SoT; any mismatch SHALL fail the build with an error naming the offending file. The CI release workflow SHALL run the same cross-check before tag creation, ensuring that pushed manifests carry the version their `src/VERSION` declares (catches the foot-gun where a maintainer pushes a `src/VERSION` bump without recompiling). Hand-edits to a manifest's `version` field SHALL be considered transient — the next compile run overwrites them with the SoT value.

#### Scenario: All three root files in sync after compile

- **GIVEN** `src/VERSION` contains `1.0.3`
- **WHEN** the compile script runs
- **THEN** all three root manifest/marketplace files SHALL declare version `1.0.3`

#### Scenario: Manifest version drifts from SoT

- **GIVEN** `src/VERSION` contains `1.0.3` and `.codex-plugin/plugin.json` declares version `1.0.0`
- **WHEN** the compile script runs
- **THEN** the system SHALL stamp `.codex-plugin/plugin.json` to version `1.0.3`
- **AND** the post-stamp cross-check SHALL pass

#### Scenario: Stamping failure caught by cross-check

- **GIVEN** `src/VERSION` contains `1.0.3`
- **AND** the in-place jq stamp on one of the three files fails silently
- **WHEN** the cross-check step runs
- **THEN** the script SHALL detect the mismatch
- **AND** SHALL exit non-zero with an error naming the offending file

#### Scenario: CI release workflow catches missing recompile

- **GIVEN** the maintainer edits `src/VERSION` from `1.0.3` to `1.0.4` and pushes to `main` without running `bash scripts/compile-skills.sh` first
- **AND** the three root manifest/marketplace files therefore still declare `1.0.3`
- **WHEN** the GitHub Actions release workflow runs
- **THEN** the cross-check step SHALL fail naming each offending file with the actual vs expected version
- **AND** the tag creation SHALL be skipped

### Requirement: Manual Minor and Major Release Process

For intentional minor or major version changes, the maintainer SHALL manually edit `src/VERSION` to the new SemVer string and run the compile script (which stamps every per-target file at the repo root from the new SoT), then push to `main`. The GitHub Actions release workflow SHALL automatically create the git tag and GitHub Release from the pushed version change. For cases where a tag and release are needed without a code change (e.g., retroactive tagging), the maintainer MAY manually create a git tag in the format `v<version>`, push the tag, and create a GitHub Release using available GitHub tooling.

**User Story:** As a maintainer I want a clear process for minor/major releases, so that I can publish breaking or feature-level changes with proper git tags via a single edit.

#### Scenario: Manual minor release via push

- **GIVEN** a maintainer decides a set of changes warrants a minor version bump
- **WHEN** the maintainer edits `src/VERSION` to `1.1.0`, runs the compile script, and pushes to `main`
- **THEN** all three root manifest/marketplace files SHALL contain version `1.1.0`
- **AND** the GitHub Actions release workflow SHALL create tag `v1.1.0` and a corresponding GitHub Release

#### Scenario: Retroactive manual tagging

- **GIVEN** a maintainer needs to tag an existing commit without a version change push
- **WHEN** the maintainer manually creates and pushes a git tag `v1.1.0`
- **THEN** the maintainer MAY create a GitHub Release using available GitHub tooling

### Requirement: Consumer Update Process

The project documentation SHALL describe the complete consumer update process for each supported target. Claude Code consumers refresh the marketplace listing, update the plugin, and restart Claude Code. Codex consumers run `codex plugin marketplace upgrade specshift` to refresh the marketplace catalog and pick up the latest plugin version (the documented Codex CLI marketplace upgrade command from `developers.openai.com/codex/plugins/build`; no separate `plugin update` CLI command is documented — the marketplace upgrade is the mechanism). This process SHALL be documented in the spec so that `specshift finalize` can generate user-facing documentation from it.

**User Story:** As a consumer of the plugin I want to know exactly how to update on my AI tool of choice, so that I always have the latest version.

#### Scenario: Claude Code consumer updates to latest version

- **GIVEN** a new plugin version has been pushed by the maintainer
- **WHEN** a Claude Code consumer wants to update
- **THEN** the consumer SHALL run `claude plugin marketplace update specshift`
- **AND** SHALL run `claude plugin update specshift@specshift`
- **AND** SHALL restart Claude Code to load the new version

#### Scenario: Codex consumer updates to latest version

- **GIVEN** a new plugin version has been pushed by the maintainer
- **WHEN** a Codex consumer wants to update
- **THEN** the consumer SHALL run `codex plugin marketplace upgrade specshift`
- **AND** the local SpecShift install SHALL reflect the latest plugin version after the next Codex session

#### Scenario: Update not detected on Claude Code

- **GIVEN** a Claude Code consumer runs `claude plugin update` but no new version is detected
- **WHEN** the consumer investigates
- **THEN** the consumer SHALL first run `claude plugin marketplace update specshift` to refresh the listing
- **AND** SHALL retry the update
- **AND** if still not detected, SHALL uninstall and reinstall the plugin as fallback

### Requirement: Skill Immutability Convention

The constitution SHALL define a rule that skills in the compiled skill tree (`./skills/`) are generic plugin code shared across all consumers and MUST NOT be modified for project-specific behavior. Project-specific workflows and conventions MUST be defined in the constitution.

#### Scenario: Project-specific behavior defined in constitution

- **GIVEN** a need for project-specific post-completion behavior (e.g., version bumps)
- **WHEN** a developer plans the implementation
- **THEN** the behavior SHALL be defined as a convention in `.specshift/CONSTITUTION.md`
- **AND** SHALL NOT be added as a step in the skill file

### Requirement: End-to-End Install and Update Checklist

The project spec SHALL document the complete happy path for plugin installation and updates as testable scenarios for each supported target: marketplace add → install → init → bootstrap, and marketplace update → plugin update → verify. This ensures the full flow is exercised and regressions are caught.

**User Story:** As a maintainer I want a testable checklist for the full install/update flow, so that I can verify the entire pipeline works end-to-end on every target.

#### Scenario: Clean install flow on Claude Code

- **GIVEN** a clean project without the plugin installed
- **WHEN** the maintainer tests the install flow
- **THEN** `claude plugin marketplace add fritze-dev/specshift` SHALL succeed
- **AND** `claude plugin install specshift@specshift` SHALL succeed
- **AND** `specshift init` SHALL install the schema and create config files
- **AND** `specshift init` SHALL generate constitution and bootstrap files

#### Scenario: Clean install flow on Codex

- **GIVEN** a clean project without the plugin installed
- **WHEN** the maintainer tests the install flow on Codex
- **THEN** `codex plugin marketplace add fritze-dev/SpecShift` SHALL succeed
- **AND** SpecShift SHALL be installable or enableable from the in-session `/plugins` directory
- **AND** `specshift init` SHALL install the schema and create config files
- **AND** `specshift init` SHALL generate constitution and bootstrap files

#### Scenario: Update flow after new version

- **GIVEN** a project with the plugin installed at version N
- **AND** a new version N+1 has been pushed
- **WHEN** the maintainer tests the update flow
- **THEN** the consumer's update commands for the relevant target SHALL refresh and apply version N+1
- **AND** `specshift init` SHALL run idempotently without errors

### Requirement: Post-Push Developer Plugin Update

After pushing a version bump to the remote, the developer's local plugin installation SHALL be updated to match the new version. For developers using a local marketplace (directory-based source), running the target-specific plugin-update command SHALL detect the local version change and update the cached plugin. For developers using a remote marketplace (GitHub for Claude, the Codex marketplace flow for Codex), the existing marketplace-update + plugin-update flow applies.

**User Story:** As a plugin developer I want my local plugin to update after I push a new version, so that I'm always developing against the latest version.

#### Scenario: Developer with local marketplace updates after version bump

- **GIVEN** a version bump has been applied locally (via auto-bump or manual)
- **AND** the compile script has stamped the new version into the three root files
- **WHEN** the developer runs the relevant plugin-update command for their target
- **THEN** the local plugin installation SHALL reflect the new version

#### Scenario: Developer with remote marketplace updates after push

- **GIVEN** a version bump has been pushed to remote
- **WHEN** the developer runs the relevant marketplace-update + plugin-update commands for their target
- **THEN** the local plugin installation SHALL reflect the new version

### Requirement: Completion Workflow Next Steps

The post-apply workflow output SHALL include a "Next steps" section guiding the user through the complete post-completion workflow: generate changelog, generate docs, version bump (`src/VERSION`), compile, push, and update the local plugin. This is defined via the constitution convention.

#### Scenario: Next steps shown after verification

- **GIVEN** a successful verification of a completed change
- **WHEN** the verification summary is displayed
- **THEN** the output SHALL include next steps: `specshift finalize` → `src/VERSION` bump → compile → push → update plugin

### Requirement: Generate Changelog from Completed Changes
The `specshift finalize` command SHALL generate release notes from completed changes located in `.specshift/changes/`. The agent SHALL scan all change directories and identify completed changes by reading proposal frontmatter `status: completed` (falling back to tasks.md checkbox parsing if frontmatter is absent). For each completed change not yet in the changelog, the agent SHALL identify affected capabilities by reading the proposal's frontmatter `capabilities` field (falling back to parsing the Capabilities section if frontmatter is absent). The agent SHALL read `proposal.md` for motivation and the current specs at `docs/specs/<capability>.md` for user stories and scenario titles. The generated changelog SHALL follow the Keep a Changelog format with sections for Added, Changed, Deprecated, Removed, Fixed, and Security as applicable. Entries SHALL be ordered newest first. The changelog SHALL be written to `CHANGELOG.md` in the project root. If `CHANGELOG.md` already exists, the agent SHALL update it by adding new entries for changes not yet represented, preserving existing manually written entries.

**User Story:** As a user of the project I want a changelog that tells me what changed and when, so that I can understand the impact of updates without reading spec files or commit logs.

#### Scenario: Changelog generated from single completed change
- **GIVEN** a completed change at `.specshift/changes/2025-01-15-user-auth/` containing a proposal describing a new authentication feature
- **AND** the proposal lists capability `user-auth` as new
- **AND** `docs/specs/user-auth.md` contains user stories and scenarios
- **WHEN** the developer runs `specshift finalize`
- **THEN** the agent creates or updates `CHANGELOG.md` with an entry dated 2025-01-15 describing the new authentication feature using user stories from the spec

#### Scenario: Multiple completed changes ordered newest first
- **GIVEN** three completed changes dated 2025-01-10, 2025-02-05, and 2025-03-20
- **WHEN** the developer runs `specshift finalize`
- **THEN** the changelog lists the 2025-03-20 entry first, followed by 2025-02-05, then 2025-01-10

#### Scenario: Existing changelog preserved
- **GIVEN** a `CHANGELOG.md` that already contains manually written entries for versions 1.0 and 1.1
- **AND** a new completed change that has not been represented in the changelog
- **WHEN** the developer runs `specshift finalize`
- **THEN** the agent adds the new entry at the top of the changelog without modifying or removing the existing 1.0 and 1.1 entries

#### Scenario: No completed changes to process
- **GIVEN** no completed changes exist under `.specshift/changes/`
- **WHEN** the developer runs `specshift finalize`
- **THEN** the agent informs the user that no completed changes were found and no changelog entries were generated

#### Scenario: Change with only internal refactoring
- **GIVEN** a completed change whose proposal and specs describe purely internal refactoring with no user-visible changes
- **WHEN** the agent processes the change
- **THEN** the agent either omits the entry entirely or includes it under a minimal note (e.g., "Internal improvements") rather than fabricating user-facing changes

### Requirement: Changelog Version Headers

Each changelog entry generated by `specshift finalize` SHALL use a version-anchored header in the format `## [v<version>] — <date>` where `<version>` is the plugin version read from `src/VERSION` at the time of finalization, and `<date>` is the release date in ISO format (`YYYY-MM-DD`). Individual changes within a version SHALL use `### <Title>` sub-headers. When a single version includes multiple changes (e.g., due to multiple merges between releases), all changes SHALL be grouped under one `## [v<version>]` header with separate `### <Title>` sub-headers for each change. The version header format SHALL be compatible with the `release.yml` sed extraction pattern, which captures the first `## ` block — a version-anchored header ensures the extracted block contains all changes for that release. Date-only headers (e.g., `## 2026-04-15 — Title`) without version numbers SHALL NOT be used, as they prevent mapping entries to releases.

**User Story:** As a consumer I want each changelog entry tied to a version number, so that I can see exactly what changed in the version I'm upgrading to.

#### Scenario: Single change produces versioned header

- **GIVEN** a completed change being finalized
- **AND** `src/VERSION` contains `0.2.3-beta`
- **WHEN** `specshift finalize` generates the changelog entry
- **THEN** the entry SHALL use the header `## [v0.2.3-beta] — 2026-04-15`
- **AND** the change title SHALL appear as a `### <Title>` sub-header

#### Scenario: release.yml extracts versioned block correctly

- **GIVEN** a CHANGELOG.md with `## [v0.2.3-beta] — 2026-04-15` as the first entry
- **WHEN** the `release.yml` sed extraction runs
- **THEN** it SHALL capture the entire `## [v0.2.3-beta]` block including all `### ` sub-headers and content up to the next `## ` header

#### Scenario: Multi-change version groups entries under one header

- **GIVEN** two changes were merged under the same version (e.g., due to missing version bumps)
- **AND** a subsequent finalize consolidates them
- **WHEN** the changelog is generated
- **THEN** both changes SHALL appear under a single `## [v<version>]` header with separate `### <Title>` sub-headers
- **AND** the release date SHALL be the date of the version tag, not the individual merge dates

### Requirement: Language-Aware Changelog Generation
The `specshift finalize` command SHALL determine the documentation language before generating entries. The agent SHALL read `.specshift/WORKFLOW.md` and extract the `docs_language` field. If the field is missing or set to "English", the agent SHALL generate changelog entries in English (default behavior). If a non-English language is configured, the agent SHALL translate section headers (e.g., `### Added` → `### Hinzugefügt` for German) and entry descriptions to the target language. Dates SHALL remain in ISO format (`YYYY-MM-DD`). Product names (Claude Code, Codex), commands (specshift commands), and file paths SHALL remain in English.

**User Story:** As a non-English-speaking team I want changelog entries in my language, so that release notes are immediately understandable.

#### Scenario: Changelog generated in configured language
- **GIVEN** `.specshift/WORKFLOW.md` contains `docs_language: German`
- **AND** a new completed change exists that is not yet in the changelog
- **WHEN** the developer runs `specshift finalize`
- **THEN** the new entry SHALL have German section headers (e.g., `### Hinzugefügt`, `### Geändert`, `### Behoben`)
- **AND** entry descriptions SHALL be in German
- **AND** dates SHALL remain in ISO format

#### Scenario: Default to English when field is missing
- **GIVEN** `.specshift/WORKFLOW.md` does not contain a `docs_language` field
- **WHEN** the developer runs `specshift finalize`
- **THEN** all entries SHALL be generated in English (unchanged behavior)

#### Scenario: Existing entries preserved in previous language
- **GIVEN** existing changelog entries were generated in English
- **AND** `docs_language` has been changed to "French"
- **WHEN** the developer runs `specshift finalize`
- **THEN** existing English entries SHALL be preserved unchanged
- **AND** new entries SHALL be generated in French

### Requirement: Automated GitHub Release via CI

A GitHub Actions workflow SHALL automatically create a git tag and GitHub Release when `src/VERSION` changes on the `main` branch. The workflow SHALL extract the latest changelog entry from `CHANGELOG.md` and use it as the release body. The workflow SHALL be idempotent — if the tag already exists, it SHALL skip without error.

**User Story:** As a plugin maintainer I want GitHub Releases to be created automatically after pushing a version bump, so that releases stay in sync with changelog entries without manual steps.

#### Scenario: Release created after version bump push

- **GIVEN** a push to `main` that changes `src/VERSION` from `1.0.28` to `1.0.29`
- **AND** `CHANGELOG.md` contains an entry starting with `## [v1.0.29] — 2026-03-26`
- **WHEN** the GitHub Actions workflow triggers
- **THEN** the workflow SHALL create a git tag `v1.0.29`
- **AND** SHALL create a GitHub Release titled `v1.0.29`
- **AND** SHALL use the latest CHANGELOG.md entry as the release body

#### Scenario: Tag already exists

- **GIVEN** a push to `main` with version `1.0.29` in `src/VERSION`
- **AND** a git tag `v1.0.29` already exists
- **WHEN** the GitHub Actions workflow triggers
- **THEN** the workflow SHALL skip tag and release creation
- **AND** SHALL exit successfully (no error)

#### Scenario: No version change

- **GIVEN** a push to `main` that does not modify `src/VERSION`
- **WHEN** the push is processed
- **THEN** the release workflow SHALL NOT trigger

#### Scenario: First release ever

- **GIVEN** a repository with no existing git tags
- **AND** a push to `main` with version `1.0.29` in `src/VERSION`
- **WHEN** the GitHub Actions workflow triggers
- **THEN** the workflow SHALL create tag `v1.0.29` and a corresponding GitHub Release

### Requirement: Consumer Version Pinning

The project documentation SHALL describe how consumers can pin to a specific plugin version by specifying a git tag reference when adding the marketplace. The pinning mechanism uses the `#ref` suffix on the marketplace add command, which is a built-in feature of the host plugin system.

**User Story:** As a plugin consumer I want to pin my installation to a specific version, so that unexpected updates don't break my workflow.

#### Scenario: Consumer pins to specific version

- **GIVEN** a GitHub Release `v1.0.29` exists with a corresponding git tag
- **WHEN** a consumer runs `claude plugin marketplace add fritze-dev/specshift#v1.0.29`
- **THEN** the marketplace SHALL resolve to the commit tagged `v1.0.29`
- **AND** the installed plugin SHALL be version `1.0.29`

#### Scenario: Consumer on pinned version does not receive updates

- **GIVEN** a consumer installed the marketplace with `#v1.0.29`
- **AND** a new version `1.0.30` has been released
- **WHEN** the consumer runs `claude plugin marketplace update`
- **THEN** the marketplace SHALL remain at the `v1.0.29` tag
- **AND** the plugin version SHALL remain `1.0.29`

### Requirement: Developer Local Marketplace Workflow

The project documentation SHALL describe the local marketplace setup for plugin developers. Developers SHALL register the local repository path as a marketplace source via `claude plugin marketplace add <local-path> --scope user`. This enables Claude Code to load the development version of the plugin without requiring CLI-only flags. SpecShift is developed against Claude Code; Codex local-development setup is out of scope for this spec — Codex is a distribution target only and is covered by the consumer install requirements in `docs/specs/multi-target-distribution.md` and the consumer install / update requirements elsewhere in this spec.

**User Story:** As a plugin developer using Claude Code I want to load my local plugin changes without CLI flags, so that I can iterate on skills and test them in any project.

#### Scenario: Claude Code developer registers local marketplace

- **GIVEN** a developer with the plugin source at `/home/user/projekte/specshift`
- **WHEN** the developer runs `claude plugin marketplace add /home/user/projekte/specshift --scope user`
- **AND** runs `claude plugin install specshift@specshift`
- **THEN** the installed plugin SHALL load from the local filesystem
- **AND** `claude plugin list` SHALL show the current local version

#### Scenario: Skill changes reload immediately

- **GIVEN** a developer with the local marketplace registered
- **AND** the developer modifies a SKILL.md file
- **WHEN** the developer reloads plugins
- **THEN** the modified skill SHALL be active in the current session

#### Scenario: Version changes require explicit update

- **GIVEN** a developer with the local marketplace registered
- **AND** the developer changes `src/VERSION` and re-runs the compile script
- **WHEN** the developer reloads plugins
- **THEN** the old version SHALL still be reported until the host's plugin-update command runs
- **AND** only after the host's plugin-update command SHALL the new version be active

### Requirement: Source and Release Directory Structure

The repository SHALL maintain a clear separation between hand-edited source content and generated output:

**Source directory (`src/`)**: Contains hand-edited plugin source files: `src/VERSION` (agnostic version source of truth), `src/skills/specshift/SKILL.md` (router with requirement link mappings), `src/templates/` (Smart Templates), and `src/actions/*.md` (compilation manifests with requirement links). Developers edit files in `src/` to change plugin behavior.

**Per-target manifests and marketplace catalogs (repository root)**: Hand-edited at the root, not under `src/`. The four files are `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, and `.agents/plugins/marketplace.json` (the Codex marketplace catalog). The `version` field in the three plugin/marketplace files (Claude plugin, Claude marketplace, Codex plugin) is stamped by the compile script from `src/VERSION`. The Codex marketplace catalog has no `version` field on its plugin entries — it carries pure metadata (name, displayName, source URL, policy, category) and is reviewed manually for parity. Codex consumers register the catalog via `codex plugin marketplace add fritze-dev/SpecShift` (per `developers.openai.com/codex/plugins/build`) and then install or enable SpecShift from the in-session `/plugins` directory. Codex resolves the plugin via the catalog's declared Git-URL source. Updates use `codex plugin marketplace upgrade specshift`. References elsewhere in this spec to installing or updating SpecShift via `codex /plugins` alone are legacy wording that this requirement supersedes.

**Shared release directory (`./skills/`)**: Generated, self-contained release artifact built by the AOT compiler (`scripts/compile-skills.sh`). Contains `./skills/specshift/SKILL.md` (copied from `src/`), `./skills/specshift/templates/` (copied from `src/`), and `./skills/specshift/actions/` (compiled from specs + WORKFLOW.md). The release directory SHALL be committed to Git. Both targets discover the skill from this single shared tree via their respective manifests' skill-path field.

Files not needed by consumers — documentation, CI workflows, specs, changelog, project workflow configuration — SHALL remain at the repository root, outside `src/` and `./skills/`.

**User Story:** As a plugin developer I want a clear separation between source files I edit, per-target manifests at the root, and one shared release artifact that both Claude Code and Codex consume, so that I can iterate on source files and rebuild the release without mixing concerns.

#### Scenario: Source directory contains editable files

- **GIVEN** the repository
- **WHEN** the directory is inspected
- **THEN** `src/skills/specshift/SKILL.md` SHALL contain the router with requirement link mappings
- **AND** `src/templates/` SHALL contain the authoritative Smart Templates
- **AND** `src/VERSION` SHALL contain the agnostic version source of truth (single line, SemVer)
- **AND** `src/` SHALL NOT contain any per-target manifest

#### Scenario: Manifests and marketplaces hand-edited at the root

- **GIVEN** the repository
- **WHEN** the root layout is inspected
- **THEN** `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, and `.codex-plugin/plugin.json` SHALL exist
- **AND** each SHALL be hand-edited (no `src/.claude-plugin/` or `src/.codex-plugin/` source counterparts)

#### Scenario: Shared release directory contains generated files

- **GIVEN** the repository after running `bash scripts/compile-skills.sh`
- **WHEN** `./skills/specshift/` is inspected
- **THEN** it SHALL contain `SKILL.md` (copy of `src/skills/specshift/SKILL.md`)
- **AND** `templates/` (copy of `src/templates/`)
- **AND** `actions/` with compiled action files for each built-in action

### Requirement: Marketplace Source Configuration

The Claude marketplace at `.claude-plugin/marketplace.json` SHALL declare `source: "./"` so that Claude Code resolves the plugin root to the repository root and discovers the skill at `./skills/specshift/`. The Codex manifest at `.codex-plugin/plugin.json` SHALL declare `skills: "./skills/"` so that Codex resolves the same shared skill tree. Neither manifest SHALL point to `src/` directly — consumers receive the compiled release artifact, not the raw source. These paths SHALL resolve correctly for both local-filesystem marketplaces and remote (GitHub / Codex) marketplaces.

**User Story:** As a plugin consumer I want both targets' marketplace metadata to point at the same compiled skill, so that I get a self-contained, deduplicated install regardless of which AI tool I use.

#### Scenario: Claude marketplace points to repo root

- **GIVEN** `.claude-plugin/marketplace.json` with `source: "./"`
- **WHEN** a Claude Code consumer installs the plugin
- **THEN** the consumer's plugin cache SHALL contain `./skills/specshift/` (SKILL.md, templates, compiled actions) and `.claude-plugin/plugin.json`
- **AND** SHALL NOT contain `docs/specs/`, `src/`, CI workflows, or changelog

#### Scenario: Codex manifest points to shared skill tree

- **GIVEN** `.codex-plugin/plugin.json` with `skills: "./skills/"`
- **WHEN** a Codex consumer installs the plugin
- **THEN** the consumer's plugin cache SHALL contain the shared skill tree at `./skills/specshift/`

#### Scenario: Local developer marketplace

- **GIVEN** a developer registers the local repo via the host's marketplace-add command
- **WHEN** the developer edits `src/` files and runs `bash scripts/compile-skills.sh`
- **THEN** the host's plugin-update command SHALL pick up the rebuilt release directory

### Requirement: Repository Layout Separation

The repository SHALL maintain a clear separation between plugin source (`src/`), per-target manifests at the root (`.claude-plugin/`, `.codex-plugin/`), the shared release artifact (`./skills/specshift/`), and project management files (other repo-root files). The repo root SHALL also contain: `.specshift/` (project workflow), `docs/`, `scripts/`, `.github/`, `AGENTS.md`, `CLAUDE.md`, `README.md`, and `CHANGELOG.md`. Project-specific files SHALL NOT exist inside `src/` or `./skills/specshift/`.

#### Scenario: Clean separation

- **GIVEN** the repository after a complete `specshift finalize` cycle
- **WHEN** the file layout is inspected
- **THEN** `src/` SHALL contain only plugin source files (SKILL.md, templates, action manifests, `VERSION`)
- **AND** `./skills/specshift/` SHALL contain only the generated release (copied source + compiled actions)
- **AND** the per-target manifests/marketplaces SHALL exist hand-edited at the root
- **AND** the repo root SHALL contain project files (AGENTS.md, CLAUDE.md, docs/, .specshift/, CHANGELOG.md)
- **AND** no project files SHALL exist inside `src/` or `./skills/specshift/`

### Requirement: AOT Skill Compilation

The `specshift finalize` action SHALL include an AOT (Ahead-of-Time) skill compilation step after changelog generation, documentation updates, and version bump. The compilation step SHALL:

1. **Read version**: Read the version string from `src/VERSION`. If the file is missing, empty, or contains more than one line, fail with a descriptive error.
2. **Copy source files into the shared skill tree**: Copy `src/skills/specshift/SKILL.md` → `./skills/specshift/SKILL.md` and `src/templates/` → `./skills/specshift/templates/`.
3. **Stamp version into the compiled workflow template**: Write the version into the `plugin-version` frontmatter field of `./skills/specshift/templates/workflow.md`.
4. **Stamp version into the three root manifest/marketplace files**: For each of `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, and `.codex-plugin/plugin.json`, use `jq` to set the version field while preserving non-version keys and values semantically (JSON formatting may be normalized). After stamping, re-read each file and verify the stamped version equals `src/VERSION`. Fail the build on any mismatch with an error naming the offending file.
5. **Parse requirement links and assemble compiled action files**: For each file in `src/actions/*.md`, parse markdown anchor links in the format `[Requirement Name](../../docs/specs/<spec>.md#requirement-<slug>)`. For each link, resolve the relative path to the target spec file and extract the `### Requirement: <Name>` block — including the normative description, optional user story, and all `#### Scenario:` blocks — up to the next `### ` or `## ` heading. Write a markdown file to `./skills/specshift/actions/<action>.md` containing `# Requirements` followed by the concatenated extracted requirement blocks. No frontmatter, no instruction text — compiled files contain only requirements.
6. **Validate output**: Each compiled file SHALL be non-empty. The compiler SHALL verify that the number of extracted requirement blocks matches the number of links in the source action file. A count mismatch SHALL produce a warning naming the specific missing requirements. Unresolvable requirement links SHALL be skipped with a warning.

The compilation scope SHALL be limited to the 5 built-in actions (propose, apply, finalize, init, review). Custom actions defined in WORKFLOW.md SHALL NOT be compiled — they use JIT resolution at runtime, reading their instruction text directly from the `## Action: <name>` section in the consumer's local WORKFLOW.md. Rationale: built-in actions have spec-backed requirements that benefit from pre-extraction; custom actions are self-contained instructions without spec requirement links.

At runtime, the router reads **instructions** from the project's `.specshift/WORKFLOW.md` (JIT, project-specific) and **requirements** from the compiled action files (AOT, plugin-level). This separation ensures projects can customize action behavior via their WORKFLOW.md while the requirements remain consistent across all consumers.

The shared skill tree at `./skills/specshift/` SHALL be committed to Git so that consumers and new team members can use the workflow without running a build step. The script SHALL also remove any pre-existing skill output at the legacy location (`.claude/skills/specshift/`) during compilation. `src/` remains the authoritative source for hand-edited files.

**User Story:** As a plugin maintainer I want requirements pre-compiled into focused action files during finalize and the same shared tree served to both targets, so that runtime token usage is minimized and adding a new target requires no per-target rewrite of the skill body.

#### Scenario: Finalize triggers AOT compilation

- **GIVEN** a completed change with audit.md verdict PASS
- **WHEN** `specshift finalize` executes the compilation step
- **THEN** it SHALL copy source files to the shared skill tree at `./skills/specshift/`
- **AND** SHALL stamp the version from `src/VERSION` into all three root manifest/marketplace files and the workflow template's `plugin-version` field
- **AND** SHALL generate compiled requirements files for each built-in action at `./skills/specshift/actions/<action>.md`
- **AND** each compiled file SHALL contain only the extracted requirement blocks

#### Scenario: Count validation detects missing requirements

- **GIVEN** `src/actions/propose.md` lists 8 requirement links
- **AND** one link references a spec file that does not exist
- **WHEN** the compilation step processes the propose action
- **THEN** it SHALL extract 7 requirement blocks
- **AND** SHALL produce a warning naming the unresolvable link
- **AND** SHALL continue compilation for remaining actions

#### Scenario: Legacy skill location cleaned

- **GIVEN** a previous build at `.claude/skills/specshift/`
- **WHEN** the compile script runs
- **THEN** the legacy directory SHALL be removed
- **AND** only the new shared tree at `./skills/specshift/` SHALL contain the compiled skill

### Requirement: Compiled Action File Contract

Each built-in action (propose, apply, finalize, init, review) SHALL have a corresponding source file at `src/actions/<action>.md` containing requirement links, and a compiled output file at `./skills/specshift/actions/<action>.md` containing the extracted requirement blocks. The compiled file SHALL contain:

- `# Requirements` heading
- Concatenated requirement blocks, each as `### Requirement: <Name>` with normative description, optional user story, and Gherkin scenarios

Compiled action files contain **requirements only** — no frontmatter, no instruction text. Instructions are project-specific and read from `.specshift/WORKFLOW.md` at runtime. The `src/actions/*.md` files serve as the compilation manifest — they define which requirements belong to which action via clickable relative links to spec files.

**User Story:** As a plugin consumer I want pre-compiled requirement files shipped with the plugin, so that the router loads focused context from a single file instead of resolving links against spec files I don't have.

#### Scenario: Compiled file contains only requirements

- **GIVEN** a compiled action file `./skills/specshift/actions/propose.md`
- **WHEN** its content is inspected
- **THEN** it SHALL begin with `# Requirements`
- **AND** SHALL contain one `### Requirement:` block per linked requirement from `src/actions/propose.md`
- **AND** SHALL NOT contain frontmatter, instruction text, or metadata

#### Scenario: Compiled file with no requirement links

- **GIVEN** a built-in action source file `src/actions/<action>.md` with no requirement links
- **WHEN** the compilation step generates the action file
- **THEN** the compiled file SHALL contain only the `# Requirements` heading with no blocks

### Requirement: Dev Sync Script

The project SHALL provide a standalone bash script at `scripts/compile-skills.sh` that performs the same AOT compilation as the finalize step. The script SHALL be runnable from the repository root. The script SHALL loop over each `src/actions/*.md` file, extract requirement links, resolve them against `docs/specs/`, and write the compiled output. The script SHALL use `bash` and `jq` (the latter for in-place per-target manifest version stamping). The finalize instruction SHALL delegate to this same script, ensuring a single compilation implementation.

**User Story:** As a plugin developer I want a quick script to rebuild the release directory after editing specs, so that I can test changes locally without running the full finalize pipeline.

#### Scenario: Dev script builds complete release directory

- **GIVEN** the developer runs `bash scripts/compile-skills.sh` from the repository root
- **WHEN** the script completes
- **THEN** it SHALL have copied source files to the shared skill tree at `./skills/specshift/`
- **AND** SHALL have stamped the version from `src/VERSION` into all three root manifest/marketplace files
- **AND** SHALL have written compiled requirements files to `./skills/specshift/actions/`
- **AND** SHALL print a summary of actions compiled and requirements extracted

#### Scenario: Dev script requires jq

- **GIVEN** a developer machine without `jq` installed
- **WHEN** the developer runs `bash scripts/compile-skills.sh`
- **THEN** the script SHALL fail with a descriptive error indicating that `jq` is required

#### Scenario: Dev script run outside repo root

- **GIVEN** the developer runs the script from a directory without `src/skills/specshift/SKILL.md`
- **WHEN** the script starts
- **THEN** it SHALL detect the missing source and exit with an error message

## Edge Cases

- **AOT compilation with no requirement links**: If a source action file has no links, the compiled file SHALL contain only the `# Requirements` heading.
- **Stale compiled files**: If specs are edited without recompilation, the compiled action files contain outdated requirements. Finalize always recompiles; developers can run the dev sync script manually.
- **`./skills/` gitignore conflict**: The `.gitignore` MUST allow `./skills/` (whitelist if necessary) so that the shared release directory is committed to Git.
- **`src/VERSION` malformed**: A missing, empty, or multi-line `src/VERSION` SHALL fail the compile run with a descriptive error before any stamping occurs.
- **Manual edit to a manifest version field**: A maintainer who edits a `version` field directly in a root manifest SHALL find the next compile run overwrites that edit with the value from `src/VERSION`. The supported workflow is to edit `src/VERSION` and recompile.

## Assumptions

- Spec files maintain the current consistent heading format (`### Requirement: <Name>` followed by content until next `### ` or `## `). <!-- ASSUMPTION: Consistent spec heading format -->
- The `scripts/` directory is an acceptable location for developer utilities in this project. <!-- ASSUMPTION: Scripts directory convention -->
- Compiled action files are kept in sync with specs via the finalize compilation step and/or the dev sync script. Stale compiled files are a developer responsibility between finalize runs. <!-- ASSUMPTION: Compiled file freshness -->
- `jq` is available on every maintainer's build machine (used by the compile script for in-place per-target manifest editing). <!-- ASSUMPTION: jq build dependency -->
