---
order: 16
category: distribution
status: stable
version: 5
lastModified: 2026-04-28
---

## Purpose

Defines how SpecShift packages and distributes the same workflow content to multiple AI-coding-tool targets (Claude Code, OpenAI Codex CLI) from a single source repository. Covers per-target manifests hand-edited at the repository root (Claude plugin manifest, Claude marketplace catalog, Codex plugin manifest, Codex marketplace catalog), the shared skill tree at the repository root, the agnostic skill body that works under both runtimes without per-target rewrites, the bootstrap-file generation pattern that lets both tools read the same instructions without duplication, and the version source of truth that drives symmetric version stamping across the three version-bearing per-target manifests (the Codex marketplace catalog has no version field).

## Requirements

### Requirement: Per-Target Plugin Manifest

The plugin SHALL ship one plugin manifest per supported target. Each manifest SHALL be hand-edited at the repository root: `.claude-plugin/plugin.json` for Claude Code and `.codex-plugin/plugin.json` for OpenAI Codex CLI. Manifests SHALL NOT live under `src/` — the repository root is the plugin root for both targets after the Shopify-flat layout migration, so manifests sit beside the marketplace files at the root and are authored directly there. Each manifest SHALL contain at minimum the fields required by its target's documented schema.

The Codex manifest SHALL include the fields `name`, `version`, `description`, `skills` (relative path to the shared skill tree), and `interface` (object with at least `displayName`, `shortDescription`, and `category`). The Codex manifest MAY also include agnostic metadata fields shared with the Claude manifest (`author`, `repository`, `license`, `keywords`) and Codex-UI-specific fields (`longDescription`, `developerName`, `websiteURL`, `defaultPrompt`, `brandColor`, `screenshots`). The Claude manifest SHALL retain its established schema (`name`, `description`, `version`, `author`, `repository`, `license`, `keywords`).

Per-target manifests SHALL NOT carry the role of "version source of truth for the repository". The `version` field in every manifest is stamped by the compile script from a single agnostic source (see "Version Source of Truth" requirement); manifests carry per-target metadata only.

**User Story:** As a maintainer I want both manifests hand-edited side-by-side at the root, so that I have direct control over per-target metadata without rendering or template indirection.

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

### Requirement: Codex Discovery via Marketplace Catalog

Codex consumers SHALL register the plugin via `codex plugin marketplace add fritze-dev/SpecShift` (the documented `owner/repo` shorthand from the official Codex CLI plugin docs at `developers.openai.com/codex/plugins/build`; no `github:` prefix, repository path matches the canonical case of the GitHub repo). After the marketplace is registered, the consumer installs or enables the plugin from the in-session plugin directory accessed via `/plugins`. The plugin SHALL ship a marketplace catalog file at `.agents/plugins/marketplace.json` at the repository root: when Codex resolves the marketplace add target, it reads the catalog and follows the declared plugin source to install the plugin. The earlier assumption that Codex auto-discovers `.codex-plugin/plugin.json` for single-plugin repositories without a catalog file was falsified against a live Codex install — the catalog is now the supported and verified path. Documentation for Codex install SHALL show this `marketplace add` + in-session install flow and SHALL NOT instruct users to rely on undocumented `plugin install <name>` CLI invocations or pre-marketplace `/plugins` discovery.

The catalog SHALL be hand-edited at the repository root. It SHALL NOT carry a `version` field on its plugin entries — the version source of truth at `src/VERSION` is propagated only to the three plugin manifest files that declare their own version (see "Symmetric Version Stamping with Cross-Check" requirement). The catalog's metadata is non-version-stamped and is reviewed manually like the rest of the per-target hand-edited fields.

**User Story:** As a Codex user I want to install SpecShift directly from its GitHub repository via the documented `marketplace add` + `/plugins`-UI flow, so that the install path is symmetric with Claude Code's `claude plugin marketplace add fritze-dev/specshift` and reliably succeeds without depending on undocumented auto-discovery or undocumented CLI install commands.

#### Scenario: Codex install resolves the plugin via the catalog

- **GIVEN** a Codex user runs `codex plugin marketplace add fritze-dev/SpecShift`
- **WHEN** Codex resolves the repository
- **THEN** Codex SHALL read `.agents/plugins/marketplace.json` at the repository root
- **AND** SHALL follow the declared `plugins[0].source` to fetch the plugin
- **AND** the consumer SHALL be able to enable or install SpecShift from the `/plugins` directory in the next Codex session

#### Scenario: Codex marketplace catalog file shipped at root

- **GIVEN** the repository
- **WHEN** the root layout is inspected
- **THEN** `.agents/plugins/marketplace.json` SHALL exist as a hand-edited file
- **AND** SHALL contain `name`, `interface.displayName`, and a single-entry `plugins[]` array
- **AND** the `plugins[]` entries SHALL NOT contain a `version` field

### Requirement: Codex Marketplace Catalog Schema

The Codex marketplace catalog at `.agents/plugins/marketplace.json` SHALL conform to the schema documented at https://developers.openai.com/codex/plugins/build. The plugin entry SHALL declare a Git-URL source that points back to this repository: `plugins[0].source` SHALL be `{ "source": "url", "url": "<repository-git-url>.git" }`. The plugin entry SHALL declare an installation policy of `{ "installation": "AVAILABLE", "authentication": "ON_INSTALL" }` and a `category` field (currently `"Coding"`). The Git-URL source form is preferred over a `local`-path source because Codex re-clones the URL during install, which resolves the existing `.codex-plugin/plugin.json` and `./skills/specshift/` at the repository root without requiring a generated sub-payload.

**User Story:** As a maintainer I want the catalog schema documented as a normative requirement, so that future edits do not silently regress to a form Codex cannot parse.

#### Scenario: Catalog declares a Git-URL source

- **GIVEN** the catalog at `.agents/plugins/marketplace.json`
- **WHEN** the file is inspected
- **THEN** `plugins[0].source.source` SHALL be `"url"`
- **AND** `plugins[0].source.url` SHALL be a string ending in `.git`

#### Scenario: Catalog declares the install policy

- **GIVEN** the catalog at `.agents/plugins/marketplace.json`
- **WHEN** the file is inspected
- **THEN** `plugins[0].policy.installation` SHALL be `"AVAILABLE"`
- **AND** `plugins[0].policy.authentication` SHALL be `"ON_INSTALL"`
- **AND** `plugins[0].category` SHALL be a non-empty string

### Requirement: Bootstrap Single Source of Truth Pattern

The plugin SHALL maintain a single bootstrap content source at `src/templates/agents.md` containing the full set of agent directives (workflow rules, plan-mode regulation, workflow-routing rule, knowledge-management rules). This file is the agnostic single source of truth: Codex CLI reads `AGENTS.md` natively at session start, and Claude Code reads `AGENTS.md` via the documented `@AGENTS.md` import directive in `CLAUDE.md`. The plugin SHALL also ship `src/templates/claude.md` as a Smart Template containing only the `@AGENTS.md` import line.

On fresh init, `specshift init` SHALL generate both `AGENTS.md` (full body) and `CLAUDE.md` (one-line import stub) so that the documented Claude Code memory-import pattern is active without requiring the user to copy the stub manually. Single source of truth is preserved because the import stub is a pointer, not a content duplicate — normative rules live only in AGENTS.md. Both templates SHALL be tracked with `template-version` discipline. Updates to shared bootstrap content SHALL be made only in `agents.md`. The `claude.md` stub SHALL NOT contain duplicated content from `agents.md`. Project-specific content (such as a File Ownership section reflecting the consumer project's directory layout) is added by the agent during `specshift init`'s codebase scan, not in the bootstrap template.

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
- **THEN** the system SHALL generate `AGENTS.md` (full body, from the `agents.md` template)
- **AND** SHALL generate `CLAUDE.md` (one-line `@AGENTS.md` import stub, from the `claude.md` template)
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

1. **Plugin-root references**: SKILL.md and templates SHALL refer to the plugin's bundled assets in prose ("the plugin's `templates/` directory", "the plugin's workflow template") rather than via runtime-specific environment variables. The agent (in either runtime) resolves the path using the skill's known install location.
2. **Product-name references**: Where a sentence applies to all supported runtimes, the source SHALL use phrasing like "the agent" or "the AI coding assistant" rather than naming a specific product. Where a sentence applies to one specific runtime (e.g., describing Claude Code's `@AGENTS.md` memory-import behavior), the product name MAY appear, but the surrounding text SHALL make the per-target scope explicit.
3. **Bootstrap-file references**: Compiled-into-skill files referring to the bootstrap pattern SHALL mention `AGENTS.md` as the agnostic source of truth. References to `CLAUDE.md` are appropriate only when the text specifically describes Claude Code's documented memory-import pattern.

The compile script SHALL emit a single skill tree under `./skills/specshift/` that serves both targets unmodified — no per-target rewrite passes (no token substitution, no per-target SKILL.md variants).

**User Story:** As a plugin maintainer I want the skill body authored agnostically, so that the same compiled artifact works under Claude Code and Codex without forking content per target and so that adding a future agent runtime requires only a manifest, not a content rewrite.

#### Scenario: Source has no runtime-specific environment variables

- **GIVEN** all files compiled into the skill (SKILL.md, templates, action specs)
- **WHEN** they are inspected
- **THEN** plugin-bundled-asset references SHALL use prose like "the plugin's `templates/` directory"
- **AND** SHALL NOT depend on runtime-specific environment-variable interpolation

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
- **AND** it SHALL contain a Codex install section showing the `codex plugin marketplace add fritze-dev/SpecShift` command followed by the in-session `/plugins`-UI install/enable step and a `codex plugin marketplace upgrade specshift` update command
- **AND** both sections SHALL be at the same heading level

#### Scenario: Future target addition follows the same pattern

- **GIVEN** a future target (e.g., Cursor) is added
- **WHEN** README is updated
- **THEN** a third install section at the same heading level SHALL be added
- **AND** existing target sections SHALL be unchanged

### Requirement: Version Source of Truth

The plugin SHALL store the canonical version in a single agnostic file at `src/VERSION`. The file SHALL be plain text, contain exactly one line with a SemVer version string (e.g., `0.2.5-beta`), and SHALL NOT contain any other content. The compile script SHALL validate the file's content against the SemVer 2.0 regex before stamping. No per-target manifest or marketplace file SHALL be the source of truth — every `version` field in `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, and `.codex-plugin/plugin.json` is a stamped copy of the SoT, written by the compile script.

The `specshift finalize` version-bump step SHALL edit only `src/VERSION`. Manifest version fields SHALL be updated indirectly via the subsequent compile run.

**User Story:** As a maintainer I want one canonical place for the plugin version, so that bumping the version is a single small edit and so that no per-target manifest carries dual responsibility ("Claude metadata" plus "repo version SoT").

#### Scenario: Version SoT is a plain-text file under src

- **GIVEN** the repository
- **WHEN** `src/VERSION` is inspected
- **THEN** it SHALL be a plain-text file containing exactly one line
- **AND** the line SHALL be a SemVer version string

#### Scenario: Finalize bump edits only the SoT

- **GIVEN** a completed change ready for finalize
- **WHEN** the finalize version-bump step runs
- **THEN** the only file modified by the bump SHALL be `src/VERSION`
- **AND** all three root manifest/marketplace `version` fields SHALL receive the new value during the subsequent compile run

#### Scenario: No manifest is the SoT

- **GIVEN** a maintainer searches for the version source of truth
- **WHEN** any per-target manifest or marketplace file is inspected
- **THEN** none of them SHALL be designated as the source of truth
- **AND** project documentation (CONSTITUTION, specs, README) SHALL name `src/VERSION` as the only source of truth

### Requirement: Symmetric Version Stamping with Cross-Check

The compile script SHALL read the version string from `src/VERSION` and stamp it into the three root manifest/marketplace files: `.claude-plugin/plugin.json` (`.version`), `.claude-plugin/marketplace.json` (`.plugins[].version`), and `.codex-plugin/plugin.json` (`.version`). The script SHALL use `jq` to update only the version field in each file, preserving all non-version keys and values semantically. JSON formatting (whitespace, indentation, key ordering) may be normalized by `jq`'s pretty-printer; consumers depend on the JSON's semantic content, not on byte-level formatting. After stamping, the script SHALL re-read each of the three files and verify that the stamped version equals the SoT. Any mismatch SHALL fail the build with an error naming the offending file.

The script SHALL also stamp the version into the compiled workflow template's `plugin-version` frontmatter field (existing behavior, retained).

**User Story:** As a maintainer I want released artifacts to always agree on the version, so that no consumer install can land in a state where Claude reports one version and Codex reports another.

#### Scenario: All three files stamped from one source

- **GIVEN** `src/VERSION` contains `0.3.0`
- **AND** the three root manifest/marketplace files declare arbitrary prior versions
- **WHEN** the compile script runs
- **THEN** all three files SHALL declare version `0.3.0`
- **AND** every other key/value pair in each file SHALL be semantically equal to its pre-stamp content (JSON formatting may be normalized by `jq`)

#### Scenario: Post-stamp cross-check fails on drift

- **GIVEN** the compile script reads `src/VERSION` as `0.3.0`
- **AND** the stamping operation on `.codex-plugin/plugin.json` silently fails
- **WHEN** the cross-check step runs
- **THEN** the script SHALL detect the mismatch
- **AND** SHALL exit non-zero with an error naming `.codex-plugin/plugin.json`

#### Scenario: Workflow template version stamped from same source

- **GIVEN** `src/VERSION` contains `0.3.0`
- **WHEN** the compile script runs
- **THEN** the compiled workflow template at `./skills/specshift/templates/workflow.md` SHALL contain `plugin-version: 0.3.0` in its frontmatter

## Edge Cases

- **Codex manifest schema change**: If the Codex CLI plugin schema evolves (e.g., new required fields in `interface`), the compile script SHALL not silently drop unknown fields from the manifest — fields present in `.codex-plugin/plugin.json` SHALL be preserved verbatim except for `version`, which is stamped from the version source of truth.
- **Existing Claude install with old marketplace source**: When existing Claude Code consumers run `claude plugin marketplace update specshift` after the migration, the new marketplace.json with `source: "./"` SHALL be picked up and the new skill tree at `./skills/specshift/` SHALL resolve correctly.
- **Codex catalog schema change**: The `codex plugin marketplace add owner/repo` install path resolves the plugin via the catalog at `.agents/plugins/marketplace.json`. If the Codex CLI changes the catalog schema (new required fields, renamed `source` forms, or different policy enums), the README install instructions, the catalog file, and the spec SHALL be updated together; the catalog field shape is hand-maintained and not enforced by the build script.
- **Branding assets absent**: If `interface.logo`, `composerIcon`, `brandColor`, or `screenshots` are not provided, the Codex listing SHALL still install correctly, displaying without branding rather than rejecting the manifest.
- **Mixed-target consumer project**: A consumer project may use both Claude Code and Codex. AGENTS.md is the single agnostic source of truth — Codex reads it natively. Claude Code reads CLAUDE.md and expands the `@AGENTS.md` import. Both files are generated on fresh init so a project that adds the second target later requires no additional bootstrap setup.
- **Per-target manifest field drift**: Hand-edited per-target manifests carry agnostic metadata (`name`, `description`, `author`, `repository`, `license`, `keywords`) that SHALL be reviewed manually for parity. Only the `version` field is enforced by the compile script — drift in other fields is a maintainer-review concern, not a compile-time error.
- **Skill compilation produces files for unsupported target**: The compile script SHALL only emit files for targets it knows about. Files for unknown targets SHALL NOT be created speculatively.
- **`src/VERSION` malformed or missing**: If `src/VERSION` is missing, empty, or contains more than one line, the compile script SHALL fail with a descriptive error before stamping any file.
- **Manual edit to a manifest version field**: If a maintainer hand-edits a `version` field directly in any of the three root files, the next compile run SHALL overwrite that edit with the value from `src/VERSION`. Maintainers are expected to bump `src/VERSION` instead.

## Assumptions

- The Codex CLI's plugin manifest schema (`.codex-plugin/plugin.json`) and skill discovery paths described in OpenAI's `developers.openai.com/codex` documentation are stable as of 2026-04-28. <!-- ASSUMPTION: Codex CLI plugin schema stable -->
- Claude Code's `@AGENTS.md` import syntax loads the referenced file into the session context at startup, as documented at `code.claude.com/docs/de/memory#agents-md`. <!-- ASSUMPTION: Claude Code AGENTS.md import behavior -->
- The `codex plugin marketplace add owner/repo` install path (per the official Codex CLI plugin docs at `developers.openai.com/codex/plugins/build`) resolves the plugin via the catalog at `.agents/plugins/marketplace.json` and follows the declared Git-URL source. The earlier auto-discovery assumption (read `.codex-plugin/plugin.json` directly from the repo without a catalog file) was falsified against a live Codex install; the catalog is now the verified path. <!-- ASSUMPTION: Codex catalog-mediated install -->
- Both Claude Code and Codex resolve plugin-bundled assets referenced in skill prose (e.g., "the plugin's `templates/` directory") relative to the skill's installed location; neither runtime requires environment-variable interpolation in skill body text for asset paths to work. <!-- ASSUMPTION: Agnostic asset resolution -->
- `jq` is available on every maintainer's build machine (used by the compile script for in-place manifest editing). <!-- ASSUMPTION: jq build dependency -->
