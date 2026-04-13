---
order: 12
category: finalization
status: stable
version: 2
lastModified: 2026-04-13
---
## Purpose

Define the release workflow conventions for the plugin, including automatic patch version bumps, version synchronization between plugin files, manual minor/major release processes, consumer update guidance, skill immutability rules, end-to-end install/update checklists, changelog generation from completed changes, and AOT (Ahead-of-Time) skill compilation that builds a self-contained release directory at `.claude/skills/specshift/`.

## Requirements

### Requirement: Auto Patch Version Bump

The project constitution SHALL define a convention that instructs the post-apply workflow to automatically increment the patch version in `src/.claude-plugin/plugin.json` after a successful change completion. The convention SHALL also require syncing the `version` field in `.claude-plugin/marketplace.json` to match. The output SHALL display the new version.

**User Story:** As a plugin maintainer I want the patch version to auto-increment when a change is completed, so that consumers can detect updates without manual version bumps.

#### Scenario: Successful auto-bump after change completion

- **GIVEN** a plugin project with `src/.claude-plugin/plugin.json` containing version `1.0.3`
- **AND** `.claude-plugin/marketplace.json` containing version `1.0.3`
- **AND** the constitution defines the post-completion auto-bump convention
- **WHEN** the post-apply workflow runs for a completed change
- **THEN** the system SHALL increment the patch version to `1.0.4` in `plugin.json`
- **AND** SHALL update `marketplace.json` to version `1.0.4`
- **AND** SHALL display the new version

### Requirement: Version Sync Between Plugin Files

The `version` field in `.claude-plugin/marketplace.json` MUST always match the `version` field in `src/.claude-plugin/plugin.json`. The auto-bump convention SHALL update both files together. If they are found out of sync before bumping, the system SHALL sync them to the plugin.json version first, then apply the patch bump.

#### Scenario: Files already in sync

- **GIVEN** `plugin.json` version is `1.0.3` and `marketplace.json` version is `1.0.3`
- **WHEN** the auto-bump runs
- **THEN** both files SHALL be updated to `1.0.4`

#### Scenario: Files out of sync

- **GIVEN** `plugin.json` version is `1.0.3` and `marketplace.json` version is `1.0.0`
- **WHEN** the auto-bump runs
- **THEN** both files SHALL be bumped to `1.0.4` (based on plugin.json as source of truth)

### Requirement: Manual Minor and Major Release Process

For intentional minor or major version changes, the maintainer SHALL manually set the version in both `src/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, then push to `main`. The GitHub Actions release workflow SHALL automatically create the git tag and GitHub Release from the pushed version change. For cases where a tag and release are needed without a code change (e.g., retroactive tagging), the maintainer MAY manually create a git tag in the format `v<version>`, push the tag, and create a GitHub Release using available GitHub tooling.

**User Story:** As a maintainer I want a clear process for minor/major releases, so that I can publish breaking or feature-level changes with proper git tags.

#### Scenario: Manual minor release via push

- **GIVEN** a maintainer decides a set of changes warrants a minor version bump
- **WHEN** the maintainer updates `src/.claude-plugin/plugin.json` and `marketplace.json` to `1.1.0` and pushes to `main`
- **THEN** the GitHub Actions release workflow SHALL create tag `v1.1.0` and a corresponding GitHub Release

#### Scenario: Retroactive manual tagging

- **GIVEN** a maintainer needs to tag an existing commit without a version change push
- **WHEN** the maintainer manually creates and pushes a git tag `v1.1.0`
- **THEN** the maintainer MAY create a GitHub Release using available GitHub tooling

### Requirement: Consumer Update Process

The project documentation SHALL describe the complete consumer update process: refresh the marketplace listing, update the plugin, and restart Claude Code. This process SHALL be documented in the spec so that `specshift finalize` can generate user-facing documentation from it.

**User Story:** As a consumer of the plugin I want to know exactly how to update, so that I always have the latest version.

#### Scenario: Consumer updates to latest version

- **GIVEN** a new plugin version has been pushed by the maintainer
- **WHEN** a consumer wants to update
- **THEN** the consumer SHALL run `claude plugin marketplace update specshift`
- **AND** SHALL run `claude plugin update specshift@specshift`
- **AND** SHALL restart Claude Code to load the new version

#### Scenario: Update not detected

- **GIVEN** a consumer runs `claude plugin update` but no new version is detected
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

A GitHub Actions workflow SHALL automatically create a git tag and GitHub Release when the version in `src/.claude-plugin/plugin.json` changes on the `main` branch. The workflow SHALL extract the latest changelog entry from `CHANGELOG.md` and use it as the release body. The workflow SHALL be idempotent — if the tag already exists, it SHALL skip without error.

**User Story:** As a plugin maintainer I want GitHub Releases to be created automatically after pushing a version bump, so that releases stay in sync with changelog entries without manual steps.

#### Scenario: Release created after version bump push

- **GIVEN** a push to `main` that changes `src/.claude-plugin/plugin.json` version from `1.0.28` to `1.0.29`
- **AND** `CHANGELOG.md` contains an entry starting with `## 2026-03-26 — Feature Name`
- **WHEN** the GitHub Actions workflow triggers
- **THEN** the workflow SHALL create a git tag `v1.0.29`
- **AND** SHALL create a GitHub Release titled `v1.0.29`
- **AND** SHALL use the latest CHANGELOG.md entry as the release body

#### Scenario: Tag already exists

- **GIVEN** a push to `main` with version `1.0.29` in `src/.claude-plugin/plugin.json`
- **AND** a git tag `v1.0.29` already exists
- **WHEN** the GitHub Actions workflow triggers
- **THEN** the workflow SHALL skip tag and release creation
- **AND** SHALL exit successfully (no error)

#### Scenario: No version change

- **GIVEN** a push to `main` that does not modify `src/.claude-plugin/plugin.json`
- **WHEN** the push is processed
- **THEN** the release workflow SHALL NOT trigger

#### Scenario: First release ever

- **GIVEN** a repository with no existing git tags
- **AND** a push to `main` with version `1.0.29` in `src/.claude-plugin/plugin.json`
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
- **AND** the developer changes the version in `src/.claude-plugin/plugin.json`
- **WHEN** the developer runs `/reload-plugins`
- **THEN** the old version SHALL still be reported by `claude plugin list`
- **AND** only after `claude plugin update specshift@specshift` SHALL the new version be active

### Requirement: Plugin Source Directory Structure

The plugin source code SHALL reside in a `src/` subdirectory at the repository root. The `src/` directory SHALL contain: `.claude-plugin/plugin.json` (plugin manifest), `skills/` (all skill definitions), and `templates/` (Smart Templates for consumer projects). Files not needed by consumers (documentation, CI workflows, workflow project files, changelogs) SHALL remain at the repository root, outside `src/`.

**User Story:** As a plugin consumer I want to download only the files needed to run the plugin, so that my local cache is clean and minimal.

#### Scenario: Consumer cache contains only plugin files

- **GIVEN** a marketplace with `source: "./src"` pointing to the plugin subdirectory
- **WHEN** a consumer installs the plugin
- **THEN** the consumer's plugin cache SHALL contain only the contents of `src/` (skills, templates, plugin.json)
- **AND** SHALL NOT contain docs, CI workflows, changelogs, or workflow project files

#### Scenario: Plugin root resolves to src directory

- **GIVEN** a plugin installed from a marketplace with `source: "./src"`
- **WHEN** a skill references `${CLAUDE_PLUGIN_ROOT}`
- **THEN** `CLAUDE_PLUGIN_ROOT` SHALL resolve to the `src/` directory
- **AND** `${CLAUDE_PLUGIN_ROOT}/templates/` SHALL contain the Smart Templates
- **AND** `${CLAUDE_PLUGIN_ROOT}/skills/` SHALL contain all skill definitions

### Requirement: Marketplace Source Configuration

The `.claude-plugin/marketplace.json` at the repository root SHALL use a `source` field pointing to the release directory. When AOT compilation is configured, the source SHALL be `./.claude/skills/specshift` (the compiled release directory). When AOT is not configured, the source SHALL be `./src` (the plugin source directory). This relative path SHALL resolve correctly for both local filesystem marketplaces (`claude plugin marketplace add <local-path>`) and GitHub-based marketplaces (`claude plugin marketplace add owner/repo`). The `plugin.json` manifest SHALL reside inside `src/.claude-plugin/plugin.json`, separate from the marketplace-level `.claude-plugin/marketplace.json` at the repo root.

**User Story:** As a plugin developer I want the marketplace to work with both local paths and GitHub, so that I can develop locally and distribute to consumers without config changes.

#### Scenario: Local marketplace resolves release directory

- **GIVEN** a developer registers the local repo as marketplace via `claude plugin marketplace add /path/to/repo`
- **AND** `marketplace.json` has `source: "./.claude/skills/specshift"`
- **WHEN** Claude Code reads the marketplace configuration
- **THEN** the plugin SHALL load from `/path/to/repo/.claude/skills/specshift/`
- **AND** the developer's local file changes SHALL be reflected after `claude plugin update`

#### Scenario: GitHub marketplace resolves release directory

- **GIVEN** a consumer adds the marketplace via `claude plugin marketplace add owner/repo`
- **WHEN** Claude Code clones the repository and reads `marketplace.json` with `source: "./.claude/skills/specshift"`
- **THEN** the plugin SHALL load from the cloned repository's `.claude/skills/specshift/` directory

#### Scenario: Version in src plugin.json drives update detection

- **GIVEN** a marketplace with `source: "./.claude/skills/specshift"`
- **WHEN** the version in `src/.claude-plugin/plugin.json` changes and the release directory is recompiled
- **THEN** `claude plugin update` SHALL detect the new version
- **AND** SHALL update the cached plugin from `.claude/skills/specshift/`

### Requirement: Repository Layout Separation

The repository SHALL maintain a clear separation between plugin source files (in `src/`) and project management files (at repo root). The repository root SHALL contain: `.claude-plugin/marketplace.json`, `.specshift/` (project's own workflow configuration), `docs/`, `.github/`, `.devcontainer/`, `CLAUDE.md`, `README.md`, and `CHANGELOG.md`. The `src/` directory SHALL NOT contain project-specific files such as CLAUDE.md, README.md, or workflow project configuration.

#### Scenario: CLAUDE.md is project-level only

- **GIVEN** the repository with `src/` plugin subdirectory
- **WHEN** the file layout is inspected
- **THEN** `CLAUDE.md` SHALL exist at the repository root
- **AND** SHALL NOT exist inside `src/`

#### Scenario: Workflow project files separate from plugin

- **GIVEN** the repository with `src/` plugin subdirectory
- **WHEN** the file layout is inspected
- **THEN** `.specshift/WORKFLOW.md`, `.specshift/CONSTITUTION.md`, `docs/specs/`, and `.specshift/changes/` SHALL exist at the repository root
- **AND** SHALL NOT exist inside `src/`

#### Scenario: Release directory is separate from source

- **GIVEN** the repository with `src/` plugin source and `.claude/skills/specshift/` release directory
- **WHEN** the file layout is inspected
- **THEN** `src/` SHALL contain the authoritative source files (SKILL.md, templates, plugin.json)
- **AND** `.claude/skills/specshift/` SHALL contain the generated release artifact (copied SKILL.md, copied templates, compiled action files)
- **AND** both SHALL be committed to Git

### Requirement: AOT Skill Compilation

The `specshift finalize` action SHALL include an AOT (Ahead-of-Time) skill compilation step after changelog generation, documentation updates, and version bump. The compilation step SHALL:

1. **Copy source files**: Copy `src/skills/specshift/SKILL.md` → `.claude/skills/specshift/SKILL.md` and `src/templates/` → `.claude/skills/specshift/templates/`, creating the self-contained release directory.
2. **Parse requirement links**: Read the built-in action requirement link sections from `src/skills/specshift/SKILL.md` (annotated with `<!-- AOT-COMPILER-INPUT -->`). Each section lists markdown anchor links in the format `[Requirement Name](docs/specs/<spec>.md#requirement-<slug>)`.
3. **Extract requirement blocks**: For each link, read the target spec file and extract the `### Requirement: <Name>` block — including the normative description, optional user story, and all `#### Scenario:` blocks — up to the next `### ` or `## ` heading.
4. **Read action instruction**: For each built-in action, read the `### Instruction` content from the corresponding `## Action: <name>` section in `.specshift/WORKFLOW.md`.
5. **Assemble compiled action file**: Write a markdown file to `.claude/skills/specshift/actions/<action>.md` containing YAML frontmatter (`compiled-at` timestamp, `specshift-version` from plugin.json, `sources` list of spec files used) followed by `## Instruction` (from WORKFLOW.md) and `## Requirements` (concatenated extracted blocks).
6. **Validate output**: Each compiled file SHALL be non-empty. The compiler SHALL verify that the number of extracted requirement blocks matches the number of links parsed from SKILL.md for each action. A count mismatch SHALL produce a warning naming the specific missing requirements. Unresolvable requirement links SHALL be skipped with a warning.

The `.claude/skills/specshift/` directory is the release artifact — it contains the router, compiled action files, and templates as a self-contained unit. It SHALL be committed to Git so that consumers and new team members can use the workflow without running a build step. The `.gitignore` SHALL whitelist this directory (e.g., `!/.claude/skills/`). `src/` remains the authoritative source for hand-edited files.

**User Story:** As a plugin maintainer I want requirements pre-compiled into focused action files during finalize, so that runtime token usage is minimized and consumers do not need access to the framework's internal spec files.

#### Scenario: Finalize triggers AOT compilation

- **GIVEN** a completed change with review.md verdict PASS
- **WHEN** `specshift finalize` executes the compilation step
- **THEN** it SHALL copy `src/skills/specshift/SKILL.md` to `.claude/skills/specshift/SKILL.md`
- **AND** SHALL copy `src/templates/` to `.claude/skills/specshift/templates/`
- **AND** SHALL generate compiled action files for each built-in action (propose, apply, finalize, init) at `.claude/skills/specshift/actions/<action>.md`
- **AND** each compiled file SHALL contain the action instruction and all referenced requirement blocks

#### Scenario: Compiled file includes provenance frontmatter

- **GIVEN** the compilation step runs with plugin version `0.2.0-beta`
- **WHEN** a compiled action file is written
- **THEN** it SHALL include YAML frontmatter with `compiled-at` (ISO 8601 timestamp), `specshift-version: 0.2.0-beta`, and `sources` (list of spec file paths that contributed requirement blocks)

#### Scenario: Count validation detects missing requirements

- **GIVEN** SKILL.md lists 8 requirement links for the propose action
- **AND** one link references a spec file that does not exist
- **WHEN** the compilation step processes the propose action
- **THEN** it SHALL extract 7 requirement blocks
- **AND** SHALL produce a warning naming the unresolvable link
- **AND** SHALL continue compilation for remaining actions

### Requirement: Compiled Action File Contract

Each built-in action (propose, apply, finalize, init) SHALL have a corresponding compiled action file at `.claude/skills/specshift/actions/<action>.md`. The compiled file SHALL use markdown-with-YAML-frontmatter format containing:

**YAML frontmatter**:
- `compiled-at` (ISO 8601 timestamp of compilation)
- `specshift-version` (version string from `src/.claude-plugin/plugin.json`)
- `sources` (array of spec file paths that contributed requirement blocks)

**Markdown body**:
- `## Instruction` — the action's procedural instruction text, extracted from `.specshift/WORKFLOW.md` `## Action: <name> ### Instruction`
- `## Requirements` — concatenated requirement blocks, each as `### Requirement: <Name>` with description, optional user story, and Gherkin scenarios

Compiled action files are generated artifacts produced by the AOT compiler. They SHALL NOT be hand-edited. The requirement link lists in SKILL.md (annotated with `<!-- AOT-COMPILER-INPUT -->`) serve as the compilation manifest — they define which requirements belong to which action.

**User Story:** As a plugin consumer I want pre-compiled action files shipped with the plugin, so that the router loads focused context from a single file instead of resolving links against spec files I don't have.

#### Scenario: Compiled action file contains instruction and requirements

- **GIVEN** a compiled action file `.claude/skills/specshift/actions/propose.md`
- **WHEN** its content is inspected
- **THEN** it SHALL contain YAML frontmatter with `compiled-at`, `specshift-version`, and `sources`
- **AND** SHALL contain `## Instruction` with the propose action's instruction text
- **AND** SHALL contain `## Requirements` with one `### Requirement:` block per linked requirement

#### Scenario: Compiled file with no requirement links

- **GIVEN** a built-in action with no requirement links in SKILL.md
- **WHEN** the compilation step generates the action file
- **THEN** the compiled file SHALL contain only the `## Instruction` section
- **AND** SHALL omit the `## Requirements` section

### Requirement: Dev Sync Script

The project SHALL provide a standalone bash script at `scripts/compile-skills.sh` that performs the same AOT compilation as the finalize step. The script SHALL be runnable from the repository root without requiring the full finalize pipeline. The script SHALL use only bash and standard POSIX utilities (awk, sed, grep) — no external runtime dependencies. The finalize instruction SHALL delegate to this same script, ensuring a single compilation implementation.

**User Story:** As a plugin developer I want a quick script to rebuild the release directory after editing specs, so that I can test changes locally without running the full finalize pipeline.

#### Scenario: Dev script builds complete release directory

- **GIVEN** the developer runs `bash scripts/compile-skills.sh` from the repository root
- **WHEN** the script completes
- **THEN** it SHALL have copied source files to `.claude/skills/specshift/`
- **AND** SHALL have written 4 compiled action files (propose.md, apply.md, finalize.md, init.md) to `.claude/skills/specshift/actions/`
- **AND** SHALL print a summary of actions compiled and requirements extracted

#### Scenario: Dev script uses no external runtimes

- **GIVEN** a developer machine with bash but without Node.js or Python installed
- **WHEN** the developer runs `bash scripts/compile-skills.sh`
- **THEN** the script SHALL complete successfully using only bash and POSIX utilities

#### Scenario: Dev script run outside repo root

- **GIVEN** the developer runs the script from a directory without `src/skills/specshift/SKILL.md`
- **WHEN** the script starts
- **THEN** it SHALL detect the missing source and exit with an error message

## Edge Cases

- **AOT compilation with no requirement links**: If a built-in action has no requirement links in SKILL.md, the compiled file SHALL contain only the instruction section.
- **AOT compilation when WORKFLOW.md instruction is missing**: If the `## Action: <name>` section does not exist in WORKFLOW.md, the compilation SHALL skip that action and log a warning.
- **Stale compiled files**: If specs are edited without recompilation, the compiled action files contain outdated requirements. Finalize always recompiles; developers can run the dev sync script manually.
- **`.claude/` gitignore conflict**: The `.gitignore` typically ignores `.claude/*`. The release directory MUST be whitelisted via `!/.claude/skills/`.

## Assumptions

- Spec files maintain the current consistent heading format (`### Requirement: <Name>` followed by content until next `### ` or `## `). <!-- ASSUMPTION: Consistent spec heading format -->
- The `scripts/` directory is an acceptable location for developer utilities in this project. <!-- ASSUMPTION: Scripts directory convention -->
- Compiled action files are kept in sync with specs via the finalize compilation step and/or the dev sync script. Stale compiled files are a developer responsibility between finalize runs. <!-- ASSUMPTION: Compiled file freshness -->
