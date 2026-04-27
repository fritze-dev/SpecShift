---
order: 12
category: finalization
status: stable
version: 4
lastModified: 2026-04-27
---
## Purpose

Define the release workflow conventions for the plugin, including automatic patch version bumps, version synchronization between the Claude and Codex plugin manifests and the Claude marketplace, manual minor/major release processes, consumer update guidance for both Claude Code and Codex, skill immutability rules, end-to-end install/update checklists, changelog generation from completed changes, and AOT (Ahead-of-Time) skill compilation that builds the shared release artifact at `./skills/specshift/` plus the per-target manifests at the repository root (`.claude-plugin/`, `.codex-plugin/`, `.agents/plugins/`).

## Requirements

### Requirement: Auto Patch Version Bump

The project constitution SHALL define a convention that instructs the post-apply workflow to automatically increment the patch version in `.claude-plugin/plugin.json` (the Claude manifest at the repository root, treated as the version source of truth) after a successful change completion. The convention SHALL require the compile script to stamp the bumped Claude version into `.codex-plugin/plugin.json` and into `.agents/plugins/marketplace.json` so that all per-target manifests agree. The `version` field in the hand-edited `.claude-plugin/marketplace.json` SHALL be synced to match. The output SHALL display the new version.

**User Story:** As a plugin maintainer I want the patch version to auto-increment when a change is completed and propagate to every per-target manifest, so that consumers on either Claude Code or Codex detect updates without manual version bumps.

#### Scenario: Successful auto-bump after change completion

- **GIVEN** a plugin project with `.claude-plugin/plugin.json` containing version `1.0.3`
- **AND** `.codex-plugin/plugin.json`, `.claude-plugin/marketplace.json`, and `.agents/plugins/marketplace.json` all containing version `1.0.3`
- **AND** the constitution defines the post-completion auto-bump convention
- **WHEN** the post-apply workflow runs for a completed change
- **THEN** the system SHALL increment the patch version to `1.0.4` in `.claude-plugin/plugin.json`
- **AND** SHALL update `.claude-plugin/marketplace.json` to `1.0.4` and re-run the compile script
- **AND** the compile script SHALL stamp `1.0.4` into `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json`
- **AND** SHALL display the new version

### Requirement: Version Sync Between Plugin Files

The `version` field in `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, and `.agents/plugins/marketplace.json` MUST always match the `version` field in `.claude-plugin/plugin.json`. The Claude plugin manifest is the version source of truth. The auto-bump convention SHALL update the Claude manifest and Claude marketplace together; the compile script SHALL stamp the same version into the Codex manifest and the Codex marketplace whenever it runs. If any of the four files are found out of sync before a bump, the system SHALL realign them to the Claude manifest version first, then apply the patch bump.

#### Scenario: Files already in sync

- **GIVEN** all four versioned plugin files (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`) are at `1.0.3`
- **WHEN** the auto-bump runs
- **THEN** all four files SHALL be updated to `1.0.4`

#### Scenario: Files out of sync

- **GIVEN** the Claude manifest is at `1.0.3` and any of the Claude marketplace, Codex manifest, or Codex marketplace is at `1.0.0`
- **WHEN** the auto-bump runs
- **THEN** all four files SHALL be bumped to `1.0.4` (based on the Claude manifest as the source of truth)

### Requirement: Manual Minor and Major Release Process

For intentional minor or major version changes, the maintainer SHALL manually set the version in `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, then run `bash scripts/compile-skills.sh` so that the Codex manifest and Codex marketplace are stamped to the same version, then push to `main`. The GitHub Actions release workflow SHALL automatically create the git tag and GitHub Release from the pushed version change. For cases where a tag and release are needed without a code change (e.g., retroactive tagging), the maintainer MAY manually create a git tag in the format `v<version>`, push the tag, and create a GitHub Release using available GitHub tooling.

**User Story:** As a maintainer I want a clear process for minor/major releases that publishes the same version across Claude and Codex artifacts in one push, so that I can ship breaking or feature-level changes without worrying about per-target drift.

#### Scenario: Manual minor release via push

- **GIVEN** a maintainer decides a set of changes warrants a minor version bump
- **WHEN** the maintainer updates `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to `1.1.0`, runs `bash scripts/compile-skills.sh`, and pushes to `main`
- **THEN** the GitHub Actions release workflow SHALL create tag `v1.1.0` and a corresponding GitHub Release
- **AND** the pushed commit SHALL contain matching `1.1.0` versions in `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json`

#### Scenario: Retroactive manual tagging

- **GIVEN** a maintainer needs to tag an existing commit without a version change push
- **WHEN** the maintainer manually creates and pushes a git tag `v1.1.0`
- **THEN** the maintainer MAY create a GitHub Release using available GitHub tooling

### Requirement: Consumer Update Process

The project documentation SHALL describe the complete consumer update process for each supported target. This process SHALL be documented in the spec so that `specshift finalize` can generate user-facing documentation from it.

**User Story:** As a consumer of the plugin (on Claude Code or Codex CLI) I want to know exactly how to update for my runtime, so that I always have the latest version.

#### Scenario: Claude Code consumer updates to latest version

- **GIVEN** a new plugin version has been pushed by the maintainer
- **WHEN** a Claude Code consumer wants to update
- **THEN** the consumer SHALL run `claude plugin marketplace update specshift`
- **AND** SHALL run `claude plugin update specshift@specshift`
- **AND** SHALL restart Claude Code to load the new version

#### Scenario: Codex consumer updates to latest version

- **GIVEN** a new plugin version has been pushed by the maintainer
- **WHEN** a Codex consumer wants to update
- **THEN** the consumer SHALL open the Codex `/plugins` UI and refresh or reinstall SpecShift
- **AND** SHALL restart the Codex session to load the new version

#### Scenario: Update not detected

- **GIVEN** a Claude Code consumer runs `claude plugin update` but no new version is detected
- **WHEN** the consumer investigates
- **THEN** the consumer SHALL first run `claude plugin marketplace update specshift` to refresh the listing
- **AND** SHALL retry the update
- **AND** if still not detected, SHALL uninstall and reinstall the plugin as fallback

### Requirement: Skill Immutability Convention

The constitution SHALL define a rule that skills in `skills/` are generic plugin code shared across all consumers and MUST NOT be modified for project-specific behavior. Project-specific workflows and conventions MUST be defined in the constitution.

#### Scenario: Project-specific behavior defined in constitution

- **GIVEN** a need for project-specific post-completion behavior (e.g., version bumps)
- **WHEN** a developer plans the implementation
- **THEN** the behavior SHALL be defined as a convention in `.specshift/CONSTITUTION.md`
- **AND** SHALL NOT be added as a step in the skill file

### Requirement: End-to-End Install and Update Checklist

The project spec SHALL document the complete happy path for plugin installation and updates as testable scenarios: marketplace add -> install -> init -> bootstrap, and marketplace update -> plugin update -> verify. This ensures the full flow is exercised and regressions are caught.

**User Story:** As a maintainer I want a testable checklist for the full install/update flow, so that I can verify the entire pipeline works end-to-end.

#### Scenario: Clean install flow

- **GIVEN** a clean project without the plugin installed
- **WHEN** the maintainer tests the install flow
- **THEN** `claude plugin marketplace add fritze-dev/specshift` SHALL succeed
- **AND** `claude plugin install specshift@specshift` SHALL succeed
- **AND** `specshift init` SHALL install the schema and create config files
- **AND** `specshift init` SHALL generate constitution and initial specs

#### Scenario: Update flow after new version

- **GIVEN** a project with the plugin installed at version N
- **AND** a new version N+1 has been pushed
- **WHEN** the maintainer tests the update flow
- **THEN** `claude plugin marketplace update specshift` SHALL refresh the listing
- **AND** `claude plugin update specshift@specshift` SHALL detect and install version N+1
- **AND** `specshift init` SHALL run idempotently without errors

### Requirement: Post-Push Developer Plugin Update

After pushing a version bump to the remote, the developer's local plugin installation SHALL be updated to match the new version. For developers using the local marketplace (directory-based source), running `claude plugin update specshift@specshift` SHALL detect the local version change and update the cached plugin. For developers using the GitHub marketplace, the existing marketplace update + plugin update flow applies.

**User Story:** As a plugin developer I want my local plugin to update after I push a new version, so that I'm always developing against the latest version.

#### Scenario: Developer with local marketplace updates after version bump

- **GIVEN** a version bump has been applied locally (via auto-bump or manual)
- **WHEN** the developer runs `claude plugin update specshift@specshift`
- **THEN** the local plugin installation SHALL reflect the new version

#### Scenario: Developer with GitHub marketplace updates after push

- **GIVEN** a version bump has been pushed to remote
- **WHEN** the developer runs `claude plugin marketplace update specshift`
- **AND** runs `claude plugin update specshift@specshift`
- **THEN** the local plugin installation SHALL reflect the new version

### Requirement: Completion Workflow Next Steps

The post-apply workflow output SHALL include a "Next steps" section guiding the user through the complete post-completion workflow: generate changelog, generate docs, version bump, push, and update the local plugin. This is defined via the constitution convention.

#### Scenario: Next steps shown after verification

- **GIVEN** a successful verification of a completed change
- **WHEN** the verification summary is displayed
- **THEN** the output SHALL include next steps: `specshift finalize` → version bump → push → update plugin

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

Each changelog entry generated by `specshift finalize` SHALL use a version-anchored header in the format `## [v<version>] — <date>` where `<version>` is the plugin version from `.claude-plugin/plugin.json` at the time of finalization, and `<date>` is the release date in ISO format (`YYYY-MM-DD`). Individual changes within a version SHALL use `### <Title>` sub-headers. When a single version includes multiple changes (e.g., due to multiple merges between releases), all changes SHALL be grouped under one `## [v<version>]` header with separate `### <Title>` sub-headers for each change. The version header format SHALL be compatible with the `release.yml` sed extraction pattern, which captures the first `## ` block — a version-anchored header ensures the extracted block contains all changes for that release. Date-only headers (e.g., `## 2026-04-15 — Title`) without version numbers SHALL NOT be used, as they prevent mapping entries to releases.

**User Story:** As a consumer I want each changelog entry tied to a version number, so that I can see exactly what changed in the version I'm upgrading to.

#### Scenario: Single change produces versioned header

- **GIVEN** a completed change being finalized
- **AND** `.claude-plugin/plugin.json` contains version `0.2.3-beta`
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
The `specshift finalize` command SHALL determine the documentation language before generating entries. The agent SHALL read `.specshift/WORKFLOW.md` and extract the `docs_language` field. If the field is missing or set to "English", the agent SHALL generate changelog entries in English (default behavior). If a non-English language is configured, the agent SHALL translate section headers (e.g., `### Added` → `### Hinzugefügt` for German) and entry descriptions to the target language. Dates SHALL remain in ISO format (`YYYY-MM-DD`). Product names (Claude Code), commands (specshift commands), and file paths SHALL remain in English.

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

A GitHub Actions workflow SHALL automatically create a git tag and GitHub Release when the version in `.claude-plugin/plugin.json` changes on the `main` branch. The workflow SHALL extract the latest changelog entry from `CHANGELOG.md` and use it as the release body. The workflow SHALL be idempotent — if the tag already exists, it SHALL skip without error.

**User Story:** As a plugin maintainer I want GitHub Releases to be created automatically after pushing a version bump, so that releases stay in sync with changelog entries without manual steps.

#### Scenario: Release created after version bump push

- **GIVEN** a push to `main` that changes `.claude-plugin/plugin.json` version from `1.0.28` to `1.0.29`
- **AND** `CHANGELOG.md` contains an entry starting with `## 2026-03-26 — Feature Name`
- **WHEN** the GitHub Actions workflow triggers
- **THEN** the workflow SHALL create a git tag `v1.0.29`
- **AND** SHALL create a GitHub Release titled `v1.0.29`
- **AND** SHALL use the latest CHANGELOG.md entry as the release body

#### Scenario: Tag already exists

- **GIVEN** a push to `main` with version `1.0.29` in `.claude-plugin/plugin.json`
- **AND** a git tag `v1.0.29` already exists
- **WHEN** the GitHub Actions workflow triggers
- **THEN** the workflow SHALL skip tag and release creation
- **AND** SHALL exit successfully (no error)

#### Scenario: No version change

- **GIVEN** a push to `main` that does not modify `.claude-plugin/plugin.json`
- **WHEN** the push is processed
- **THEN** the release workflow SHALL NOT trigger

#### Scenario: First release ever

- **GIVEN** a repository with no existing git tags
- **AND** a push to `main` with version `1.0.29` in `.claude-plugin/plugin.json`
- **WHEN** the GitHub Actions workflow triggers
- **THEN** the workflow SHALL create tag `v1.0.29` and a corresponding GitHub Release

### Requirement: Consumer Version Pinning

The project documentation SHALL describe how consumers can pin to a specific plugin version by specifying a git tag reference when adding the marketplace. The pinning mechanism uses the `#ref` suffix on the marketplace add command, which is a built-in feature of the Claude Code plugin system.

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

The project documentation SHALL describe the local marketplace setup for plugin developers. Developers SHALL register the local repository path as a marketplace source using `claude plugin marketplace add <local-path>`. This enables the VS Code extension to load the development version of the plugin without requiring the CLI-only `--plugin-dir` flag.

**User Story:** As a plugin developer using VS Code I want to load my local plugin changes without CLI flags, so that I can iterate on skills and test them in any project.

#### Scenario: Developer registers local marketplace

- **GIVEN** a developer with the plugin source at `/home/user/projekte/specshift`
- **WHEN** the developer runs `claude plugin marketplace add /home/user/projekte/specshift --scope user`
- **AND** runs `claude plugin install specshift@specshift`
- **THEN** the installed plugin SHALL load from the local filesystem
- **AND** `claude plugin list` SHALL show the current local version

#### Scenario: Skill changes reload immediately

- **GIVEN** a developer with the local marketplace registered
- **AND** the developer modifies a SKILL.md file
- **WHEN** the developer runs `/reload-plugins`
- **THEN** the modified skill SHALL be active in the current session

#### Scenario: Version changes require explicit update

- **GIVEN** a developer with the local marketplace registered
- **AND** the developer changes the version in `.claude-plugin/plugin.json`
- **WHEN** the developer runs `/reload-plugins`
- **THEN** the old version SHALL still be reported by `claude plugin list`
- **AND** only after `claude plugin update specshift@specshift` SHALL the new version be active

### Requirement: Source and Release Directory Structure

The repository SHALL maintain hand-edited source files plus a generated release artifact:

**Source directory (`src/`)**: Contains hand-edited plugin source files: `src/skills/specshift/SKILL.md` (router with requirement link mappings), `src/templates/` (Smart Templates including the bootstrap pair `agents.md`/`claude.md`), `src/actions/` (compilation manifests with requirement links), and `src/marketplace/codex.json` (Codex marketplace template). Developers edit files in `src/` to change plugin behavior.

**Plugin manifests at the repository root**: The two plugin manifests are hand-edited at the root, side-by-side with the Claude marketplace file: `.claude-plugin/plugin.json` (Claude manifest, version source of truth), `.claude-plugin/marketplace.json` (Claude marketplace, hand-edited), and `.codex-plugin/plugin.json` (Codex manifest). The compile script SHALL NOT copy plugin manifests from `src/` — manifests live at the root because the root **is** the plugin root for both targets after the Shopify-flat layout migration. The compile script SHALL read the version from `.claude-plugin/plugin.json` and stamp it into `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json` so per-target versions stay in sync.

**Shared release directory (`./skills/specshift/`)**: Contains the self-contained, generated release artifact built by the AOT compiler (`scripts/compile-skills.sh`). It includes: `SKILL.md` (copied from `src/`), `templates/` (copied from `src/`), and `actions/` (compiled from specs + WORKFLOW.md). Both Claude Code (via `.claude-plugin/marketplace.json` `source: "./"`) and Codex (via `.codex-plugin/plugin.json` `skills: "./skills/"`) resolve to this same directory. The release directory SHALL be committed to Git.

**Codex marketplace entry (`.agents/plugins/marketplace.json`)**: Generated by the compile script from `src/marketplace/codex.json` so the plugin is discoverable via `codex /plugins`.

Files not needed by consumers — documentation, CI workflows, specs, changelog, project workflow configuration — SHALL remain at the repository root, outside both `src/` and `./skills/specshift/`.

**User Story:** As a plugin developer I want a clear separation between source files I edit, hand-edited per-target manifests at the root, and the shared release artifact, so that I can iterate on source files and rebuild the release without mixing concerns or duplicating manifest content.

#### Scenario: Source directory contains editable files

- **GIVEN** the repository with `src/` plugin subdirectory
- **WHEN** the directory is inspected
- **THEN** `src/skills/specshift/SKILL.md` SHALL contain the router with requirement link mappings
- **AND** `src/templates/` SHALL contain the authoritative Smart Templates
- **AND** `src/actions/` SHALL contain the compilation manifests
- **AND** `src/marketplace/codex.json` SHALL contain the Codex marketplace template
- **AND** `src/.claude-plugin/` and `src/.codex-plugin/` directories SHALL NOT exist under `src/` (manifests live at the repository root)

#### Scenario: Plugin manifests live at the repository root

- **GIVEN** the repository after migration to root-level manifests
- **WHEN** the root layout is inspected
- **THEN** `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, and `.codex-plugin/plugin.json` SHALL exist at the root
- **AND** all three files SHALL be hand-edited (not generated by the compile script)

#### Scenario: Shared release directory contains generated files

- **GIVEN** the repository after running `bash scripts/compile-skills.sh`
- **WHEN** `./skills/specshift/` is inspected
- **THEN** it SHALL contain `SKILL.md` (copy of `src/skills/specshift/SKILL.md`)
- **AND** `templates/` (copy of `src/templates/`)
- **AND** `actions/` with compiled action files for each built-in action

#### Scenario: Plugin root resolves to repository root for both targets

- **GIVEN** a plugin installed from the marketplace on either Claude Code or Codex
- **WHEN** the runtime resolves the plugin's root path
- **THEN** the plugin root SHALL be the repository root (the directory containing `.claude-plugin/`, `.codex-plugin/`, and `skills/`)
- **AND** the skill body SHALL reference its own bundled files via prose like "the plugin's `templates/` directory" or relative paths like `templates/foo.md` rather than via runtime-specific environment variables, so the same SKILL.md works identically under both runtimes

### Requirement: Marketplace Source Configuration

The `.claude-plugin/marketplace.json` at the repository root SHALL use `source: "./"` (the repository root) to point Claude Code at the shared `./skills/specshift/` tree. The `.codex-plugin/plugin.json` SHALL declare `"skills": "./skills/"` so that Codex resolves to the same shared tree. Neither manifest SHALL point to `src/` directly — consumers receive the compiled release artifact, not the raw source. The marketplace path SHALL resolve correctly for local filesystem marketplaces and GitHub-based marketplaces. The plugin version is determined by the hand-edited `.claude-plugin/plugin.json` at the repository root and propagated to `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json` by the compile script.

**User Story:** As a plugin consumer I want both per-target marketplaces to deliver the same self-contained skill with pre-compiled requirements, so that I can use the workflow immediately without needing the framework's internal spec files regardless of which agent runtime I run.

#### Scenario: Claude marketplace points to repo root

- **GIVEN** `.claude-plugin/marketplace.json` with `source: "./"`
- **WHEN** a Claude Code consumer installs the plugin
- **THEN** the consumer's plugin cache SHALL contain the shared release tree (`skills/specshift/SKILL.md`, `templates/`, compiled `actions/`) plus `.claude-plugin/plugin.json`
- **AND** SHALL NOT contain `docs/specs/`, `src/`, CI workflows, or changelog

#### Scenario: Codex manifest points to shared skill tree

- **GIVEN** `.codex-plugin/plugin.json` with `skills: "./skills/"`
- **WHEN** a Codex consumer installs the plugin via `codex /plugins`
- **THEN** Codex SHALL resolve `./skills/specshift/SKILL.md` from the same compiled release tree the Claude marketplace serves

#### Scenario: Version detection via root manifest

- **GIVEN** the maintainer has set `.claude-plugin/plugin.json` to version `1.0.4` and run the compile script
- **WHEN** a Claude Code consumer runs `claude plugin update`
- **THEN** the system SHALL detect version `1.0.4` from `.claude-plugin/plugin.json` at the repository root
- **AND** the same `1.0.4` SHALL appear in `.codex-plugin/plugin.json` so a Codex consumer detects the same version

#### Scenario: Local developer marketplace

- **GIVEN** a developer registers the local repo via `claude plugin marketplace add /path/to/repo`
- **WHEN** the developer edits `src/` files and runs `bash scripts/compile-skills.sh`
- **THEN** `claude plugin update specshift@specshift` SHALL pick up the rebuilt shared release tree

### Requirement: Repository Layout Separation

The repository SHALL maintain a clear separation between hand-edited plugin sources (`src/`), per-target hand-edited manifests at the repository root (`.claude-plugin/`, `.codex-plugin/`), the generated release artifact (`./skills/specshift/`), the generated Codex marketplace file (`.agents/plugins/marketplace.json`), and project management files (rest of the repo root: `.specshift/`, `docs/`, `scripts/`, `.github/`, `AGENTS.md`, `CLAUDE.md` if present, `README.md`, `CHANGELOG.md`). Project-specific files SHALL NOT exist inside `src/` or `./skills/specshift/`.

#### Scenario: Layout separation

- **GIVEN** the repository after a complete `specshift finalize` cycle
- **WHEN** the file layout is inspected
- **THEN** `src/` SHALL contain only plugin source files (skills, templates, action manifests, Codex marketplace template)
- **AND** `.claude-plugin/` and `.codex-plugin/` SHALL contain only hand-edited per-target manifests (and the Claude marketplace file)
- **AND** `./skills/specshift/` SHALL contain only the generated release (copied source + compiled actions)
- **AND** `.agents/plugins/marketplace.json` SHALL contain only the generated Codex marketplace entry
- **AND** the rest of the repo root SHALL contain project files (AGENTS.md, docs/, .specshift/, CHANGELOG.md, etc.)
- **AND** no project files SHALL exist inside `src/` or `./skills/specshift/`

### Requirement: AOT Skill Compilation

The `specshift finalize` action SHALL include an AOT (Ahead-of-Time) skill compilation step after changelog generation, documentation updates, and version bump. The compilation step SHALL:

1. **Copy shared source files**: Copy `src/skills/specshift/SKILL.md` → `./skills/specshift/SKILL.md` and `src/templates/` → `./skills/specshift/templates/`. The same compiled files serve both Claude Code and Codex consumers — the compiler SHALL NOT emit per-target rewrites.
2. **Stamp per-target manifest versions**: Read the version from the hand-edited `.claude-plugin/plugin.json`. Stamp the same version into `.codex-plugin/plugin.json` (preserving all other fields verbatim) and into the generated `.agents/plugins/marketplace.json`. Manifests SHALL NOT be copied from `src/` — they live at the root and are hand-edited.
3. **Emit Codex marketplace entry**: Render `src/marketplace/codex.json` to `.agents/plugins/marketplace.json` with the stamped version.
4. **Parse requirement links**: For each file in `src/actions/*.md`, parse the markdown anchor links in the format `[Requirement Name](../../docs/specs/<spec>.md#requirement-<slug>)`.
5. **Extract requirement blocks**: For each link, resolve the relative path to the target spec file and extract the `### Requirement: <Name>` block — including the normative description, optional user story, and all `#### Scenario:` blocks — up to the next `### ` or `## ` heading.
6. **Assemble compiled requirements file**: Write a markdown file to `./skills/specshift/actions/<action>.md` containing `# Requirements` followed by the concatenated extracted requirement blocks. No frontmatter, no instruction text — compiled files contain only requirements.
7. **Validate output**: Each compiled file SHALL be non-empty. The compiler SHALL verify that the number of extracted requirement blocks matches the number of links in the source action file. A count mismatch SHALL produce a warning naming the specific missing requirements. Unresolvable requirement links SHALL be skipped with a warning. The compiler SHALL also verify that the version it stamped into Codex outputs equals the Claude source version — a mismatch SHALL fail compilation.

The compilation scope SHALL be limited to the 5 built-in actions (propose, apply, finalize, init, review). Custom actions defined in WORKFLOW.md SHALL NOT be compiled — they use JIT resolution at runtime, reading their instruction text directly from the `## Action: <name>` section in the consumer's local WORKFLOW.md. Rationale: built-in actions have spec-backed requirements that benefit from pre-extraction; custom actions are self-contained instructions without spec requirement links.

At runtime, the router reads **instructions** from the project's `.specshift/WORKFLOW.md` (JIT, project-specific) and **requirements** from the compiled action files (AOT, plugin-level). This separation ensures projects can customize action behavior via their WORKFLOW.md while the requirements remain consistent across all consumers.

The repository root is the plugin root for both targets (Claude marketplace `source: "./"`, Codex manifest `skills: "./skills/"`). The shared release tree (`./skills/specshift/`) and the generated Codex marketplace (`.agents/plugins/marketplace.json`) SHALL be committed to Git so that consumers and new team members can use the workflow without running a build step. `src/` remains the authoritative source for hand-edited skill, template, and Codex-marketplace files; `.claude-plugin/` and `.codex-plugin/` remain the authoritative locations for hand-edited per-target manifests.

**User Story:** As a plugin maintainer I want requirements pre-compiled into focused action files during finalize, plus per-target manifest versions stamped automatically, so that runtime token usage is minimized, releases never disagree across targets, and consumers do not need access to the framework's internal spec files.

#### Scenario: Finalize triggers AOT compilation

- **GIVEN** a completed change with audit.md verdict PASS
- **WHEN** `specshift finalize` executes the compilation step
- **THEN** it SHALL copy shared source files to `./skills/specshift/`
- **AND** SHALL stamp the Claude manifest version into `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json`
- **AND** SHALL generate compiled requirements files for each built-in action at `./skills/specshift/actions/<action>.md`
- **AND** each compiled file SHALL contain only the extracted requirement blocks

#### Scenario: Count validation detects missing requirements

- **GIVEN** `src/actions/propose.md` lists 8 requirement links
- **AND** one link references a spec file that does not exist
- **WHEN** the compilation step processes the propose action
- **THEN** it SHALL extract 7 requirement blocks
- **AND** SHALL produce a warning naming the unresolvable link
- **AND** SHALL continue compilation for remaining actions

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

The project SHALL provide a standalone bash script at `scripts/compile-skills.sh` that performs the same AOT compilation as the finalize step (shared skill tree copy, Codex manifest version stamping, Codex marketplace generation, requirement extraction, count validation). The script SHALL be runnable from the repository root without requiring the full finalize pipeline. The script SHALL loop over each `src/actions/*.md` file, extract requirement links, resolve them against `docs/specs/`, and write the compiled output. The script SHALL use bash, standard POSIX utilities, and `jq` (for safe JSON manipulation of manifest versions). The finalize instruction SHALL delegate to this same script, ensuring a single compilation implementation.

**User Story:** As a plugin developer I want a quick script to rebuild the shared release tree and per-target manifests after editing specs or bumping the Claude manifest version, so that I can test multi-target changes locally without running the full finalize pipeline.

#### Scenario: Dev script builds shared release tree and stamps per-target manifests

- **GIVEN** the developer runs `bash scripts/compile-skills.sh` from the repository root
- **WHEN** the script completes
- **THEN** it SHALL have copied shared source files to `./skills/specshift/`
- **AND** SHALL have stamped the Claude manifest version into `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json`
- **AND** SHALL have written compiled requirements files to `./skills/specshift/actions/`
- **AND** SHALL print a summary of actions compiled, requirements extracted, and per-target versions stamped

#### Scenario: Dev script run outside repo root

- **GIVEN** the developer runs the script from a directory without `src/skills/specshift/SKILL.md`
- **WHEN** the script starts
- **THEN** it SHALL detect the missing source and exit with an error message

#### Scenario: jq missing on dev machine

- **GIVEN** a developer machine without `jq` installed
- **WHEN** the developer runs `bash scripts/compile-skills.sh`
- **THEN** the script SHALL detect the missing dependency in preflight and exit with an instructive error message

## Edge Cases

- **AOT compilation with no requirement links**: If a source action file has no links, the compiled file SHALL contain only the `# Requirements` heading.
- **Stale compiled files**: If specs are edited without recompilation, the compiled action files contain outdated requirements. Finalize always recompiles; developers can run the dev sync script manually.
- **`./skills/` gitignore conflict**: The `.gitignore` MUST not exclude the shared release tree. If a project-level `.gitignore` rule would otherwise hide `./skills/`, the rule SHALL be amended to whitelist `./skills/specshift/`.
- **Manifest field drift between targets**: Fields shared across targets (e.g., `name`, `description`, `author`) SHALL be reviewed manually for parity since each manifest is hand-edited. Only the `version` field is enforced by the compile script.

## Assumptions

- Spec files maintain the current consistent heading format (`### Requirement: <Name>` followed by content until next `### ` or `## `). <!-- ASSUMPTION: Consistent spec heading format -->
- The `scripts/` directory is an acceptable location for developer utilities in this project. <!-- ASSUMPTION: Scripts directory convention -->
- Compiled action files are kept in sync with specs via the finalize compilation step and/or the dev sync script. Stale compiled files are a developer responsibility between finalize runs. <!-- ASSUMPTION: Compiled file freshness -->
