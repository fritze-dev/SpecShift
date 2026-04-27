---
order: 16
category: distribution
status: stable
version: 1
lastModified: 2026-04-27
---

## Purpose

Defines how SpecShift packages and distributes the same workflow content to multiple AI-coding-tool targets (Claude Code, OpenAI Codex CLI) from a single source repository. Covers manifest parity, shared skill-tree layout at the repository root, target-specific marketplace files, and the bootstrap-file generation pattern that allows both tools to read the same instructions without duplication.

## Requirements

### Requirement: Per-Target Plugin Manifest

The plugin SHALL ship one plugin manifest per supported target. Each manifest SHALL be authored as source under `src/<target>-plugin/plugin.json` and copied to the repository root at `<target>-plugin/plugin.json` during compilation. The current supported targets SHALL be Claude Code (`.claude-plugin/plugin.json`) and OpenAI Codex CLI (`.codex-plugin/plugin.json`). Each manifest SHALL contain at minimum the fields required by its target's documented schema. The Codex manifest SHALL include the fields `name`, `version`, `description`, `skills` (relative path to the shared skill tree), and `interface` (object with at least `displayName`, `shortDescription`, and `category`). The Claude manifest SHALL retain its existing schema (`name`, `description`, `version`, `author`, `repository`, `license`, `keywords`).

The compile script SHALL stamp the same `version` value (read from the Claude source manifest, which is treated as the version source of truth) into both manifests, ensuring released artifacts always agree on the plugin version.

**User Story:** As a maintainer I want both manifests stamped from a single version source, so that releases never disagree about which version they represent.

#### Scenario: Both manifests emitted at repo root

- **GIVEN** sources at `src/.claude-plugin/plugin.json` and `src/.codex-plugin/plugin.json`
- **WHEN** the compile script runs
- **THEN** the script SHALL emit `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` at the repository root
- **AND** both files SHALL contain the same `version` value

#### Scenario: Codex manifest contains required Codex schema fields

- **GIVEN** the source `src/.codex-plugin/plugin.json`
- **WHEN** the file is inspected
- **THEN** it SHALL contain `name`, `version`, `description`, `skills`, and `interface`
- **AND** `interface` SHALL contain at least `displayName`, `shortDescription`, and `category`

#### Scenario: Claude manifest schema preserved

- **GIVEN** the migration to multi-target distribution
- **WHEN** the Claude manifest is inspected after compilation
- **THEN** it SHALL contain the same fields as before the migration (`name`, `description`, `version`, `author`, `repository`, `license`, `keywords`)
- **AND** SHALL NOT contain a Codex `interface` block

#### Scenario: Version mismatch in sources is rejected

- **GIVEN** `src/.claude-plugin/plugin.json` declares version `0.3.0` and `src/.codex-plugin/plugin.json` declares version `0.2.5`
- **WHEN** the compile script runs
- **THEN** the script SHALL stamp the Claude version onto the Codex manifest output
- **AND** the emitted `.codex-plugin/plugin.json` SHALL contain `0.3.0`

### Requirement: Shared Skill Tree at Repository Root

The compiled skill artifacts SHALL live at `./skills/<skill-name>/` at the repository root, accessible to all target manifests via a shared relative path. The compile script SHALL copy SKILL.md, the `templates/` directory, and the compiled `actions/` directory into this single shared location. Both target manifests SHALL reference this same location — the Claude marketplace via `source: "./"` resolving the skill relative to the repo root, and the Codex manifest via its `skills` field set to `"./skills/"`. The plugin SHALL NOT maintain a separate copy of the skill tree per target.

The compile script SHALL remove any pre-existing skill output at the legacy location (`.claude/skills/<skill-name>/`) during compilation to prevent stale artifacts from being shipped.

**User Story:** As a maintainer I want one skill tree shared by all targets, so that adding a new target requires only a manifest, not a duplicated skill body.

#### Scenario: Skill compiled to repo root

- **GIVEN** sources under `src/skills/specshift/`, `src/templates/`, and `src/actions/`
- **WHEN** the compile script runs
- **THEN** the compiled skill SHALL exist at `./skills/specshift/SKILL.md`, `./skills/specshift/templates/`, and `./skills/specshift/actions/`

#### Scenario: Both manifests reference the shared tree

- **GIVEN** the compiled output
- **WHEN** the manifests are inspected
- **THEN** `.claude-plugin/marketplace.json` SHALL declare `source: "./"`
- **AND** `.codex-plugin/plugin.json` SHALL declare `skills: "./skills/"`
- **AND** both targets SHALL resolve to the same physical SKILL.md file

#### Scenario: Legacy skill location removed

- **GIVEN** a previous build at `.claude/skills/specshift/`
- **WHEN** the compile script runs after migration
- **THEN** the legacy directory SHALL be removed
- **AND** only the new location at `./skills/specshift/` SHALL contain the compiled skill

#### Scenario: Skill frontmatter portable across targets

- **GIVEN** the source `src/skills/specshift/SKILL.md`
- **WHEN** the frontmatter is inspected
- **THEN** it SHALL contain only target-portable fields (`name`, `description`)
- **AND** SHALL NOT contain target-specific fields like `allowed-tools`

### Requirement: Codex Marketplace Entry

The plugin SHALL ship a Codex-marketplace entry file at `.agents/plugins/marketplace.json` so that the plugin is discoverable when a Codex user runs `codex /plugins`. The marketplace file SHALL be generated by the compile script from a source template and SHALL reference the Codex manifest path. The compile script SHALL stamp the current plugin version into the marketplace entry. The Codex marketplace SHALL be independent of the Claude marketplace (`.claude-plugin/marketplace.json`), and changes to one SHALL NOT require changes to the other.

**User Story:** As a Codex user I want to discover and install SpecShift through Codex's native plugin marketplace, so that I do not need to manually clone or configure the plugin.

#### Scenario: Codex marketplace file generated

- **GIVEN** the compile script
- **WHEN** compilation runs
- **THEN** `.agents/plugins/marketplace.json` SHALL be produced at the repository root
- **AND** SHALL reference the Codex plugin manifest at `.codex-plugin/plugin.json`

#### Scenario: Codex marketplace version stamped

- **GIVEN** `src/.claude-plugin/plugin.json` declares version `0.3.0`
- **WHEN** the compile script runs
- **THEN** `.agents/plugins/marketplace.json` SHALL declare the plugin version as `0.3.0`

#### Scenario: Independent marketplace updates

- **GIVEN** an update changes only the Claude marketplace metadata
- **WHEN** the compile script runs
- **THEN** `.agents/plugins/marketplace.json` SHALL be unaffected by the Claude marketplace change

### Requirement: Bootstrap Single Source of Truth Pattern

The plugin SHALL maintain a single bootstrap content source at `src/templates/agents.md` containing the full set of agent directives (workflow rules, plan-mode regulation, workflow-routing rule, knowledge-management rules). The plugin SHALL also maintain a small bootstrap stub at `src/templates/claude.md` containing only an `@AGENTS.md` import line and any Claude-Code-specific instructions that do not apply to other targets. Both templates SHALL be tracked as Smart Templates with `template-version` discipline. Updates to shared bootstrap content (rules that apply to all agents) SHALL be made only in `agents.md`. The `claude.md` stub SHALL NOT contain duplicated content from `agents.md`. Project-specific content (such as a File Ownership section reflecting the consumer project's directory layout) is added by the agent during `specshift init`'s codebase scan, not in the bootstrap template.

The compile script SHALL place both templates into the compiled `templates/` directory so that `specshift init` can read them at runtime.

**User Story:** As a maintainer I want bootstrap rules authored once, so that updates like the workflow-routing rule never need to be applied twice.

#### Scenario: agents.md contains full bootstrap content

- **GIVEN** the source `src/templates/agents.md`
- **WHEN** the file is inspected
- **THEN** it SHALL contain at minimum sections covering Workflow, Planning, and Knowledge Management rules

#### Scenario: claude.md is reduced to an import stub

- **GIVEN** the source `src/templates/claude.md`
- **WHEN** the file is inspected
- **THEN** it SHALL contain a line invoking the Claude Code import syntax `@AGENTS.md`
- **AND** SHALL NOT duplicate normative rules from `agents.md`

#### Scenario: Updating a shared rule touches only agents.md

- **GIVEN** a maintainer needs to update the workflow-routing rule
- **WHEN** the update is made
- **THEN** only `src/templates/agents.md` SHALL be modified
- **AND** the change SHALL apply to both Claude Code and Codex consumers via the `@AGENTS.md` import

#### Scenario: Both templates are Smart Templates

- **GIVEN** the sources `src/templates/agents.md` and `src/templates/claude.md`
- **WHEN** the frontmatter is inspected
- **THEN** each SHALL declare `template-version` and `generates`
- **AND** `agents.md` SHALL declare `generates: AGENTS.md`
- **AND** `claude.md` SHALL declare `generates: CLAUDE.md`

### Requirement: Multi-Target Install Documentation

The README SHALL document install instructions for every supported target. There SHALL be one install section per target, each labelled by target name. Each section SHALL contain the canonical install command for that target's marketplace and a one-line update command. The README SHALL NOT favor one target's instructions over the others' — both SHALL be presented at the same heading level and in the order Claude Code, then Codex.

**User Story:** As a new user I want to find install instructions for my AI tool of choice without comparing to other targets I do not use, so that onboarding is fast regardless of which environment I run.

#### Scenario: README contains both install sections

- **GIVEN** the project README after the migration
- **WHEN** it is inspected
- **THEN** it SHALL contain a Claude Code install section showing the marketplace add and update commands
- **AND** it SHALL contain a Codex install section showing the `codex /plugins` discovery flow
- **AND** both sections SHALL be at the same heading level

#### Scenario: Future target addition follows the same pattern

- **GIVEN** a future target (e.g., Cursor) is added
- **WHEN** README is updated
- **THEN** a third install section at the same heading level SHALL be added
- **AND** existing target sections SHALL be unchanged

## Edge Cases

- **Codex manifest schema change**: If the Codex CLI plugin schema evolves (e.g., new required fields in `interface`), the compile script SHALL not silently drop unknown fields from the source manifest — fields present in `src/.codex-plugin/plugin.json` SHALL be preserved verbatim except for `version`, which is stamped from the version source of truth.
- **Existing Claude install with old marketplace source**: When existing Claude Code consumers run `claude plugin marketplace update specshift` after the migration, the new marketplace.json with `source: "./"` SHALL be picked up and the new skill tree at `./skills/specshift/` SHALL resolve correctly.
- **Codex marketplace API path drift**: The exact filesystem location of the Codex marketplace file (`.agents/plugins/marketplace.json`) is governed by the Codex CLI documentation; if the upstream path changes, the compile script SHALL be updated to match.
- **Branding assets absent**: If `interface.logo`, `composerIcon`, or `brandColor` are not provided, the Codex listing SHALL still install correctly, displaying without branding rather than rejecting the manifest.
- **Mixed-target consumer project**: A consumer project that has both Claude Code and Codex installed SHALL receive both AGENTS.md and CLAUDE.md from `specshift init`. The CLAUDE.md import (`@AGENTS.md`) loads AGENTS.md content into Claude Code's context, while Codex reads AGENTS.md directly — both tools see the same workflow rules without conflict.
- **Skill compilation produces files for unsupported target**: The compile script SHALL only emit files for targets it knows about. Files for unknown targets SHALL NOT be created speculatively.

## Assumptions

- The Codex CLI's plugin manifest schema, marketplace location (`.agents/plugins/marketplace.json`), and skill discovery paths described in OpenAI's `developers.openai.com/codex` documentation are stable as of 2026-04-27. <!-- ASSUMPTION: Codex CLI plugin schema stable -->
- Claude Code's `@AGENTS.md` import syntax loads the referenced file into the session context at startup, as documented at `code.claude.com/docs/de/memory#agents-md`. <!-- ASSUMPTION: Claude Code AGENTS.md import behavior -->
- The Claude source plugin manifest at `src/.claude-plugin/plugin.json` is the authoritative version source of truth — Codex manifest version is derived from it during compilation, never authored independently. <!-- ASSUMPTION: Claude manifest as version source -->
- Consumer projects that install SpecShift via Codex have a writable home directory and access to `~/.codex/` for any user-level configuration; the plugin itself does not write there. <!-- ASSUMPTION: Codex user config writable -->
- The `.agents/plugins/marketplace.json` file format and discovery is consistent with the Codex `codex /plugins` command behavior; if Codex requires a different filename or location in a future release, the compile script will need updating. <!-- ASSUMPTION: Codex marketplace file convention -->
