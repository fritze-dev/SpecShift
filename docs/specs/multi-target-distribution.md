---
order: 16
category: distribution
status: stable
version: 3
lastModified: 2026-04-27
---

## Purpose

Defines how SpecShift packages and distributes the same workflow content to multiple AI-coding-tool targets (Claude Code, OpenAI Codex CLI) from a single source repository. Covers manifest parity with hand-edited per-target manifests at the repository root, shared skill-tree layout at the repository root, target-specific marketplace files, the agnostic skill body that works under both runtimes without per-target rewrites, and the bootstrap-file generation pattern that lets both tools read the same instructions without duplication.

## Requirements

### Requirement: Per-Target Plugin Manifest

The plugin SHALL ship one plugin manifest per supported target. Each manifest SHALL be hand-edited at the repository root: `.claude-plugin/plugin.json` for Claude Code and `.codex-plugin/plugin.json` for OpenAI Codex CLI. Manifests SHALL NOT live under `src/` — the repository root is the plugin root for both targets after the Shopify-flat layout migration, so manifests sit beside the Claude marketplace file (`.claude-plugin/marketplace.json`) at the root and are authored directly there. Each manifest SHALL contain at minimum the fields required by its target's documented schema. The Codex manifest SHALL include the fields `name`, `version`, `description`, `skills` (relative path to the shared skill tree), and `interface` (object with at least `displayName`, `shortDescription`, and `category`). The Codex manifest MAY also include agnostic metadata fields shared with the Claude manifest (`author`, `repository`, `license`, `keywords`) and Codex-UI-specific fields (`longDescription`, `developerName`, `websiteURL`, `defaultPrompt`, `brandColor`, `screenshots`). The Claude manifest SHALL retain its existing schema (`name`, `description`, `version`, `author`, `repository`, `license`, `keywords`).

The Claude manifest SHALL be the version source of truth. The compile script SHALL read the version from `.claude-plugin/plugin.json` and stamp the same value into `.codex-plugin/plugin.json` (preserving all other fields verbatim) and into `.agents/plugins/marketplace.json`, ensuring released artifacts always agree on the plugin version.

**User Story:** As a maintainer I want both manifests hand-edited side-by-side at the root and stamped from a single version source, so that I have direct control over per-target metadata and releases never disagree about which version they represent.

#### Scenario: Manifests authored at repo root

- **GIVEN** the repository
- **WHEN** the root layout is inspected
- **THEN** `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` SHALL exist at the repository root
- **AND** both SHALL be hand-edited (no `src/.claude-plugin/` or `src/.codex-plugin/` source counterparts)

#### Scenario: Codex manifest contains required Codex schema fields

- **GIVEN** the manifest `.codex-plugin/plugin.json`
- **WHEN** the file is inspected
- **THEN** it SHALL contain `name`, `version`, `description`, `skills`, and `interface`
- **AND** `interface` SHALL contain at least `displayName`, `shortDescription`, and `category`

#### Scenario: Claude manifest schema preserved

- **GIVEN** the migration to multi-target distribution
- **WHEN** the Claude manifest is inspected
- **THEN** it SHALL contain its established fields (`name`, `description`, `version`, `author`, `repository`, `license`, `keywords`)
- **AND** SHALL NOT contain a Codex `interface` block

#### Scenario: Version mismatch between manifests is corrected by compile script

- **GIVEN** `.claude-plugin/plugin.json` declares version `0.3.0` and `.codex-plugin/plugin.json` declares version `0.2.5`
- **WHEN** the compile script runs
- **THEN** the script SHALL stamp the Claude version onto `.codex-plugin/plugin.json`
- **AND** the resulting `.codex-plugin/plugin.json` SHALL contain `0.3.0`
- **AND** the same version SHALL be stamped into `.agents/plugins/marketplace.json`

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

The plugin SHALL ship a Codex-marketplace entry file at `.agents/plugins/marketplace.json` so that the plugin is discoverable when a Codex user runs `codex /plugins`. The marketplace file SHALL be generated by the compile script from `src/marketplace/codex.json` (the hand-edited Codex marketplace template) and SHALL reference the Codex manifest path. The compile script SHALL stamp the current plugin version (read from `.claude-plugin/plugin.json`) into the marketplace entry. The Codex marketplace SHALL be independent of the Claude marketplace (`.claude-plugin/marketplace.json`), and changes to one SHALL NOT require changes to the other.

**User Story:** As a Codex user I want to discover and install SpecShift through Codex's native plugin marketplace, so that I do not need to manually clone or configure the plugin.

#### Scenario: Codex marketplace file generated

- **GIVEN** the compile script and `src/marketplace/codex.json`
- **WHEN** compilation runs
- **THEN** `.agents/plugins/marketplace.json` SHALL be produced at the repository root
- **AND** SHALL reference the Codex plugin manifest at `.codex-plugin/plugin.json`

#### Scenario: Codex marketplace version stamped

- **GIVEN** `.claude-plugin/plugin.json` declares version `0.3.0`
- **WHEN** the compile script runs
- **THEN** `.agents/plugins/marketplace.json` SHALL declare the plugin version as `0.3.0`

#### Scenario: Independent marketplace updates

- **GIVEN** an update changes only the Claude marketplace metadata
- **WHEN** the compile script runs
- **THEN** `.agents/plugins/marketplace.json` SHALL be unaffected by the Claude marketplace change

### Requirement: Bootstrap Single Source of Truth Pattern

The plugin SHALL maintain a single bootstrap content source at `src/templates/agents.md` containing the full set of agent directives (workflow rules, plan-mode regulation, workflow-routing rule, knowledge-management rules). This file is the agnostic single source of truth: Codex CLI reads `AGENTS.md` natively at session start, and Claude Code reads `AGENTS.md` via the documented `@AGENTS.md` import directive in `CLAUDE.md`. The plugin SHALL also ship `src/templates/claude.md` as a Smart Template containing only the `@AGENTS.md` import line. On fresh init, `specshift init` SHALL generate both `AGENTS.md` (full body) and `CLAUDE.md` (one-line import stub) so that the documented Claude Code memory-import pattern is active without requiring the user to copy the stub manually. Single source of truth is preserved because the import stub is a pointer, not a content duplicate — normative rules live only in AGENTS.md. Both templates SHALL be tracked with `template-version` discipline. Updates to shared bootstrap content (rules that apply to all agents) SHALL be made only in `agents.md`. The `claude.md` stub SHALL NOT contain duplicated content from `agents.md`. Project-specific content (such as a File Ownership section reflecting the consumer project's directory layout) is added by the agent during `specshift init`'s codebase scan, not in the bootstrap template.

The compile script SHALL place both templates into the compiled `templates/` directory so that `specshift init` can read `agents.md` and `claude.md` at runtime to generate the bootstrap files.

**User Story:** As a maintainer I want bootstrap rules authored once, so that updates like the workflow-routing rule never need to be applied twice — and I want fresh init to set up both bootstrap files in one shot so consumers do not have to manually wire up Claude Code's documented memory-import pattern.

#### Scenario: agents.md contains full bootstrap content

- **GIVEN** the source `src/templates/agents.md`
- **WHEN** the file is inspected
- **THEN** it SHALL contain at minimum sections covering Workflow, Planning, and Knowledge Management rules

#### Scenario: claude.md is the import stub template

- **GIVEN** the source `src/templates/claude.md`
- **WHEN** the file is inspected
- **THEN** it SHALL contain a line invoking the Claude Code import syntax `@AGENTS.md`
- **AND** SHALL NOT duplicate normative rules from `agents.md`

#### Scenario: Updating a shared rule touches only agents.md

- **GIVEN** a maintainer needs to update the workflow-routing rule
- **WHEN** the update is made
- **THEN** only `src/templates/agents.md` SHALL be modified
- **AND** the change SHALL apply to both Claude Code and Codex consumers (Codex reads AGENTS.md natively; Claude Code reads it via the `@AGENTS.md` import expanded from the generated CLAUDE.md stub)

#### Scenario: Fresh init generates both bootstrap files

- **GIVEN** a project with no `AGENTS.md` and no `CLAUDE.md`
- **WHEN** the user runs `specshift init`
- **THEN** the system SHALL generate `AGENTS.md` (full body, from `templates/agents.md`)
- **AND** SHALL generate `CLAUDE.md` (one-line `@AGENTS.md` import stub, from `templates/claude.md`)
- **AND** Claude Code SHALL load CLAUDE.md and expand the `@AGENTS.md` import at next session start
- **AND** Codex SHALL load AGENTS.md natively at next session start

#### Scenario: Both templates are Smart Templates

- **GIVEN** the sources `src/templates/agents.md` and `src/templates/claude.md`
- **WHEN** the frontmatter is inspected
- **THEN** each SHALL declare `template-version` and `generates`
- **AND** `agents.md` SHALL declare `generates: AGENTS.md`
- **AND** `claude.md` SHALL declare `generates: CLAUDE.md`

### Requirement: Agnostic Skill Body

The shared skill body (`src/skills/specshift/SKILL.md`, `src/templates/`, `src/actions/*.md`, and the spec files those actions link into) SHALL be authored in tool-agnostic language so that the same compiled artifact works under both Claude Code and Codex without per-target rewrites. Specifically:

1. **Plugin-root references**: SKILL.md and templates SHALL refer to the plugin's bundled assets in prose ("the plugin's `templates/` directory", "the plugin's `templates/workflow.md`") rather than via runtime-specific environment variables (`${CLAUDE_PLUGIN_ROOT}`). Codex has no equivalent of `${CLAUDE_PLUGIN_ROOT}`, and the agent (in either runtime) resolves the path using the skill's known install location.
2. **Product-name references**: Where a sentence applies to all supported runtimes, the source SHALL use phrasing like "the agent" or "the AI coding assistant" rather than naming a specific product. Where a sentence applies to one specific runtime (e.g., describing Claude Code's `@AGENTS.md` memory-import behavior), the product name MAY appear, but the surrounding text SHALL make the per-target scope explicit.
3. **Worktree-path references**: Compiled-into-skill files (action specs, templates) SHALL avoid hardcoded `.claude/worktrees/...` strings. Worktree path patterns are configured per project in `.specshift/WORKFLOW.md` (`worktree.path_pattern`); spec scenarios SHALL refer to the configured pattern, not the legacy default.
4. **Bootstrap-file references**: Compiled-into-skill files referring to the bootstrap pattern SHALL mention `AGENTS.md` as the agnostic source of truth. References to `CLAUDE.md` are appropriate only when the text specifically describes Claude Code's documented memory-import pattern.

The compile script SHALL emit a single skill tree under `./skills/specshift/` that serves both targets unmodified — no per-target rewrite passes (no token substitution, no per-target SKILL.md variants).

**User Story:** As a plugin maintainer I want the skill body authored agnostically, so that the same compiled artifact works under Claude Code and Codex without forking content per target and so that adding a future agent runtime requires only a manifest, not a content rewrite.

#### Scenario: Source has no Claude-specific environment variables

- **GIVEN** all files compiled into the skill (SKILL.md, templates under `src/templates/`, action specs under `docs/specs/`)
- **WHEN** they are inspected
- **THEN** they SHALL NOT contain `${CLAUDE_PLUGIN_ROOT}`
- **AND** plugin-bundled-asset references SHALL use prose like "the plugin's `templates/` directory"

#### Scenario: Compiled skill tree is the same for both targets

- **GIVEN** a compiled `./skills/specshift/` tree
- **WHEN** the directory is inspected
- **THEN** it SHALL be exactly one tree, served to both Claude Code and Codex via their respective manifests
- **AND** no per-target variants of `SKILL.md`, action files, or templates SHALL exist

#### Scenario: Product names appear only where target-scoped

- **GIVEN** a compiled-into-skill file mentioning "Claude Code"
- **WHEN** the surrounding paragraph is inspected
- **THEN** it SHALL be describing a Claude-Code-specific behavior (e.g., the `@AGENTS.md` memory-import pattern)
- **AND** SHALL NOT use "Claude Code" as a stand-in for "the agent" generally

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

- **Codex manifest schema change**: If the Codex CLI plugin schema evolves (e.g., new required fields in `interface`), the compile script SHALL not silently drop unknown fields from the manifest — fields present in `.codex-plugin/plugin.json` SHALL be preserved verbatim except for `version`, which is stamped from the version source of truth.
- **Existing Claude install with old marketplace source**: When existing Claude Code consumers run `claude plugin marketplace update specshift` after the migration, the new marketplace.json with `source: "./"` SHALL be picked up and the new skill tree at `./skills/specshift/` SHALL resolve correctly.
- **Codex marketplace API path drift**: The exact filesystem location of the Codex marketplace file (`.agents/plugins/marketplace.json`) is governed by the Codex CLI documentation; if the upstream path changes, the compile script SHALL be updated to match.
- **Branding assets absent**: If `interface.logo`, `composerIcon`, `brandColor`, or `screenshots` are not provided, the Codex listing SHALL still install correctly, displaying without branding rather than rejecting the manifest.
- **Mixed-target consumer project**: A consumer project may use both Claude Code and Codex. AGENTS.md is the single agnostic source of truth — Codex reads it natively. Claude Code reads CLAUDE.md and expands the `@AGENTS.md` import. Both files are generated on fresh init so a project that adds the second target later requires no additional bootstrap setup.
- **Per-target manifest field drift**: Hand-edited per-target manifests carry agnostic metadata (`name`, `description`, `author`, `repository`, `license`, `keywords`) that SHALL be reviewed manually for parity. Only the `version` field is enforced by the compile script — drift in other fields is a maintainer-review concern, not a compile-time error.
- **Skill compilation produces files for unsupported target**: The compile script SHALL only emit files for targets it knows about. Files for unknown targets SHALL NOT be created speculatively.

## Assumptions

- The Codex CLI's plugin manifest schema, marketplace location (`.agents/plugins/marketplace.json`), and skill discovery paths described in OpenAI's `developers.openai.com/codex` documentation are stable as of 2026-04-27. <!-- ASSUMPTION: Codex CLI plugin schema stable -->
- Claude Code's `@AGENTS.md` import syntax loads the referenced file into the session context at startup, as documented at `code.claude.com/docs/de/memory#agents-md`. <!-- ASSUMPTION: Claude Code AGENTS.md import behavior -->
- The Claude plugin manifest at `.claude-plugin/plugin.json` is the authoritative version source of truth — Codex manifest version is stamped from it during compilation, never authored independently in `.codex-plugin/plugin.json`. <!-- ASSUMPTION: Claude manifest as version source -->
- Consumer projects that install SpecShift via Codex have a writable home directory and access to `~/.codex/` for any user-level configuration; the plugin itself does not write there. <!-- ASSUMPTION: Codex user config writable -->
- The `.agents/plugins/marketplace.json` file format and discovery is consistent with the Codex `codex /plugins` command behavior; if Codex requires a different filename or location in a future release, the compile script will need updating. <!-- ASSUMPTION: Codex marketplace file convention -->
- Both Claude Code and Codex resolve plugin-bundled assets referenced in skill prose (e.g., "the plugin's `templates/` directory") relative to the skill's installed location; neither runtime requires environment-variable interpolation in skill body text for asset paths to work. <!-- ASSUMPTION: Agnostic asset resolution -->
