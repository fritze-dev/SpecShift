# Tests: Multi-Target Distribution

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) — plugin is Markdown/YAML artifacts; per CONSTITUTION `## Testing` |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### multi-target-distribution

#### Per-Target Plugin Manifest

- [ ] **Scenario: Manifests authored at repo root**
  - Setup: clean repository checkout on the branch
  - Action: list `.claude-plugin/`, `.codex-plugin/`, `src/.claude-plugin/`, `src/.codex-plugin/`
  - Verify: `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` exist at the repo root; `src/.claude-plugin/` and `src/.codex-plugin/` do NOT exist

- [ ] **Scenario: Codex manifest contains required Codex schema fields**
  - Setup: open `.codex-plugin/plugin.json`
  - Action: inspect top-level keys and `interface` block
  - Verify: top-level contains `name`, `version`, `description`, `skills`, `interface`; `interface` contains at least `displayName`, `shortDescription`, `category`

- [ ] **Scenario: Claude manifest schema preserved**
  - Setup: open `.claude-plugin/plugin.json`
  - Action: inspect keys
  - Verify: contains `name`, `description`, `version`, `author`, `repository`, `license`, `keywords`; does NOT contain a Codex `interface` block

#### Shared Skill Tree at Repository Root

- [ ] **Scenario: Skill compiled to repo root**
  - Setup: tree on this branch with compile run
  - Action: `ls ./skills/specshift/`
  - Verify: contains `SKILL.md`, `templates/`, `actions/`

- [ ] **Scenario: Both manifests reference the shared tree**
  - Setup: open `.claude-plugin/marketplace.json` and `.codex-plugin/plugin.json`
  - Action: `jq -r '.plugins[0].source' .claude-plugin/marketplace.json && jq -r '.skills' .codex-plugin/plugin.json`
  - Verify: marketplace `source` is `./`; manifest `skills` is `./skills/`

- [ ] **Scenario: Legacy skill location removed**
  - Setup: a checkout that previously had `.claude/skills/specshift/`
  - Action: `bash scripts/compile-skills.sh`
  - Verify: `.claude/skills/specshift/` no longer exists; `./skills/specshift/` is the only compiled skill tree

#### Codex Marketplace Entry

- [ ] **Scenario: Codex marketplace lives at repository root**
  - Setup: clean checkout
  - Action: `ls .agents/plugins/marketplace.json src/marketplace/`
  - Verify: marketplace at root exists; `src/marketplace/` does NOT exist; the marketplace's plugin entry references the Codex plugin manifest

- [ ] **Scenario: Codex marketplace version stamped**
  - Setup: edit `src/VERSION` to a new value (e.g. `9.9.9-test`); run compile
  - Action: `jq -r '.plugins[0].version' .agents/plugins/marketplace.json`
  - Verify: returns `9.9.9-test`; restore `src/VERSION` after the test

- [ ] **Scenario: Independent marketplace updates**
  - Setup: edit `.claude-plugin/marketplace.json` description (or unrelated metadata)
  - Action: `bash scripts/compile-skills.sh`
  - Verify: `.agents/plugins/marketplace.json` non-version fields semantically unchanged (`jq -S 'del(.plugins[].version)'` before/after compare-equal); only its own version field would change if `src/VERSION` changed

#### Bootstrap Single Source of Truth Pattern

- [ ] **Scenario: agents.md contains full bootstrap content**
  - Setup: open `src/templates/agents.md`
  - Action: search for sections
  - Verify: contains at minimum sections covering Workflow, Planning, Knowledge Management

- [ ] **Scenario: claude.md is the import stub template**
  - Setup: open `src/templates/claude.md`
  - Action: read file contents
  - Verify: contains an `@AGENTS.md` import line; does not duplicate normative rules from `agents.md`

- [ ] **Scenario: Updating a shared rule touches only agents.md**
  - Setup: pick a workflow rule string from `src/templates/agents.md`
  - Action: `grep -r "<rule string>" src/templates/`
  - Verify: returns one hit (in `src/templates/agents.md`); not present in `src/templates/claude.md`

- [ ] **Scenario: Fresh init generates both bootstrap files**
  - Setup: temporary fresh project directory with no `AGENTS.md` and no `CLAUDE.md`, plugin installed
  - Action: run `specshift init`
  - Verify: both files appear at the project root; `AGENTS.md` contains workflow/planning/knowledge-management sections; `CLAUDE.md` contains a single `@AGENTS.md` import line

- [ ] **Scenario: Both templates are Smart Templates**
  - Setup: open `src/templates/agents.md` and `src/templates/claude.md`
  - Action: inspect YAML frontmatter
  - Verify: each declares `template-version`; `agents.md` declares `generates: AGENTS.md`; `claude.md` declares `generates: CLAUDE.md`

#### Agnostic Skill Body

- [ ] **Scenario: Source has no runtime-specific environment variables**
  - Setup: tree on this branch
  - Action: `grep -rn "\${CLAUDE_PLUGIN_ROOT}" src/skills/ src/templates/ src/actions/ docs/specs/`
  - Verify: 0 hits across all listed paths

- [ ] **Scenario: Compiled skill tree is the same for both targets**
  - Setup: post-compile tree
  - Action: `find . -path ./node_modules -prune -o -name 'SKILL.md' -print`
  - Verify: returns exactly two paths — `src/skills/specshift/SKILL.md` (source) and `./skills/specshift/SKILL.md` (compiled); no per-target variants

- [ ] **Scenario: Product names appear only where target-scoped**
  - Setup: post-compile tree
  - Action: `grep -rn "Claude Code" ./skills/specshift/`
  - Verify: each hit is in a paragraph that explicitly describes Claude-Code-specific behavior (e.g., `@AGENTS.md` import); none uses "Claude Code" as a stand-in for "the agent" generally

#### Multi-Target Install Documentation

- [ ] **Scenario: README contains both install sections**
  - Setup: open `README.md`
  - Action: search for install section headings
  - Verify: a Claude Code install section and a Codex install section exist at the same heading level

- [ ] **Scenario: Future target addition follows the same pattern**
  - Setup: README structure today
  - Action: review heading hierarchy of the install sections
  - Verify: structurally a third section at the same level could be added without restructuring

#### Version Source of Truth

- [ ] **Scenario: Version SoT is a plain-text file under src**
  - Setup: tree on this branch
  - Action: `cat src/VERSION; wc -l src/VERSION`
  - Verify: file contains exactly one line; the line is a SemVer string

- [ ] **Scenario: Finalize bump edits only the SoT**
  - Setup: dry-run finalize on a completed change
  - Action: observe which file the version-bump step modifies
  - Verify: only `src/VERSION` is modified by the bump itself; the four root manifest/marketplace files are subsequently updated by the compile run

- [ ] **Scenario: No manifest is the SoT**
  - Setup: read CONSTITUTION, README, and the multi-target-distribution spec
  - Action: search for "source of truth" / "SoT"
  - Verify: every mention names `src/VERSION`; no per-target manifest is named as the SoT

#### Symmetric Version Stamping with Cross-Check

- [ ] **Scenario: All four files stamped from one source**
  - Setup: edit `src/VERSION` to `9.9.9-test`; run `bash scripts/compile-skills.sh`
  - Action: `jq -r '.version // .plugins[0].version' .claude-plugin/plugin.json .claude-plugin/marketplace.json .codex-plugin/plugin.json .agents/plugins/marketplace.json`
  - Verify: returns `9.9.9-test` four times; restore `src/VERSION` after the test

- [ ] **Scenario: Post-stamp cross-check fails on drift**
  - Setup: run a clean compile so all files are at the SoT version; then hand-edit `.codex-plugin/plugin.json` `version` to a different value
  - Action: re-run `bash scripts/compile-skills.sh`
  - Verify: the script overwrites the manual edit and the cross-check passes; OR if the test simulates a stamp failure (e.g., remove jq from PATH or read-only file), the script exits non-zero with an error naming the offending file

- [ ] **Scenario: Workflow template version stamped from same source**
  - Setup: post-compile
  - Action: `head -3 ./skills/specshift/templates/workflow.md`
  - Verify: frontmatter `plugin-version` equals `cat src/VERSION`

### project-init

#### Bootstrap Files Generation

- [ ] **Scenario: Both bootstrap files generated on fresh init**
  - Setup: temporary project directory with neither file
  - Action: `specshift init`
  - Verify: both files appear; AGENTS.md has all standard sections; CLAUDE.md has the import line only

- [ ] **Scenario: Existing AGENTS.md preserved on re-init**
  - Setup: project with both files; modify AGENTS.md to add a project-specific section
  - Action: `specshift init`
  - Verify: AGENTS.md is byte-identical; init reports "AGENTS.md already exists — skipped (all standard sections present)"

- [ ] **Scenario: Existing CLAUDE.md preserved on re-init**
  - Setup: project with an existing CLAUDE.md (any content)
  - Action: `specshift init`
  - Verify: CLAUDE.md is byte-identical; if the import line is missing, init reports a WARNING

- [ ] **Scenario: AGENTS.md generated alone when CLAUDE.md already exists**
  - Setup: project with existing CLAUDE.md but no AGENTS.md
  - Action: `specshift init`
  - Verify: AGENTS.md is generated; CLAUDE.md is unmodified; if the existing CLAUDE.md lacks an `@AGENTS.md` line, a WARNING is reported

- [ ] **Scenario: CLAUDE.md stub generated alone when AGENTS.md already exists**
  - Setup: project with existing AGENTS.md but no CLAUDE.md
  - Action: `specshift init`
  - Verify: CLAUDE.md (stub) is generated; AGENTS.md is unmodified

- [ ] **Scenario: AGENTS.md includes project-specific rules**
  - Setup: project with discoverable conventions (e.g., a notable build script)
  - Action: `specshift init` on fresh project
  - Verify: generated AGENTS.md contains project-specific agent rules beyond the standard sections; uncertain items marked `<!-- REVIEW -->`

- [ ] **Scenario: AGENTS.md missing standard section detected on re-init**
  - Setup: project with AGENTS.md missing the Planning section
  - Action: `specshift init`
  - Verify: AGENTS.md is unmodified; init reports a WARNING for the missing Planning section

### release-workflow

#### Auto Patch Version Bump

- [ ] **Scenario: Successful auto-bump after change completion**
  - Setup: a completed change ready for finalize; current `src/VERSION` is e.g. `1.0.3`
  - Action: trigger the post-apply auto-bump path
  - Verify: `src/VERSION` becomes `1.0.4`; the subsequent compile run stamps `1.0.4` into all four root files; the displayed version is `1.0.4`

#### Version Sync Between Plugin Files

- [ ] **Scenario: All four root files in sync after compile**
  - Setup: `src/VERSION` contains a known value
  - Action: `bash scripts/compile-skills.sh`; `jq -r` over the four version locations
  - Verify: all four equal `cat src/VERSION`

- [ ] **Scenario: Manifest version drifts from SoT**
  - Setup: hand-edit `.codex-plugin/plugin.json` `version` to a non-SoT value
  - Action: `bash scripts/compile-skills.sh`
  - Verify: post-compile, the file's version equals `cat src/VERSION`; cross-check passes

- [ ] **Scenario: Stamping failure caught by cross-check**
  - Setup: simulate a stamp failure (e.g., chmod 444 one of the four files before running)
  - Action: `bash scripts/compile-skills.sh`
  - Verify: script exits non-zero with an error naming the offending file; restore permissions after the test

#### Manual Minor and Major Release Process

- [ ] **Scenario: Manual minor release via push**
  - Setup: edit `src/VERSION` from `1.0.x` to `1.1.0`; run compile
  - Action: push to `main`
  - Verify: GitHub Actions release workflow creates tag `v1.1.0` and a corresponding GitHub Release

- [ ] **Scenario: Retroactive manual tagging**
  - Setup: any commit on `main`
  - Action: manually create and push `git tag v1.1.0`; create GitHub Release via gh CLI
  - Verify: tag and Release exist

#### Consumer Update Process

- [ ] **Scenario: Claude Code consumer updates to latest version**
  - Setup: a Claude Code install at version N; new version N+1 published
  - Action: `claude plugin marketplace update specshift && claude plugin update specshift@specshift && /reload-plugins` (or restart)
  - Verify: `claude plugin list` shows version N+1

- [ ] **Scenario: Codex consumer updates to latest version**
  - Setup: a Codex install at version N; new version N+1 published
  - Action: refresh and reinstall via `codex /plugins`
  - Verify: Codex reports the new version

- [ ] **Scenario: Update not detected on Claude Code**
  - Setup: Claude Code install where `plugin update` reports no new version
  - Action: run marketplace update first, then plugin update; if still not detected, uninstall + reinstall
  - Verify: new version is installed after the fallback

#### Skill Immutability Convention

- [ ] **Scenario: Project-specific behavior defined in constitution**
  - Setup: a project-specific behavior need (e.g., custom finalize step)
  - Action: review where the behavior is defined
  - Verify: defined as a convention in `.specshift/CONSTITUTION.md`; not added as a step in the skill file

#### End-to-End Install and Update Checklist

- [ ] **Scenario: Clean install flow on Claude Code**
  - Setup: clean project without the plugin
  - Action: marketplace add → install → init
  - Verify: each step succeeds; constitution and bootstrap files are generated

- [ ] **Scenario: Clean install flow on Codex**
  - Setup: clean project without the plugin
  - Action: discover via `codex /plugins`, install → init
  - Verify: each step succeeds; constitution and bootstrap files are generated

- [ ] **Scenario: Update flow after new version**
  - Setup: install at version N; release N+1
  - Action: target-specific update commands; re-run init
  - Verify: version N+1 active; init runs idempotently

#### Post-Push Developer Plugin Update

- [ ] **Scenario: Developer with local marketplace updates after version bump**
  - Setup: maintainer has local marketplace registered
  - Action: bump `src/VERSION`, run compile, run plugin-update
  - Verify: local install reflects new version

- [ ] **Scenario: Developer with remote marketplace updates after push**
  - Setup: maintainer with remote marketplace
  - Action: push the bump, run marketplace-update + plugin-update
  - Verify: local install reflects new version

#### Completion Workflow Next Steps

- [ ] **Scenario: Next steps shown after verification**
  - Setup: completed change with PASS verification
  - Action: read finalize action's verification summary output
  - Verify: includes `specshift finalize` → `src/VERSION` bump → compile → push → update plugin

#### Generate Changelog from Completed Changes

- [ ] **Scenario: Changelog generated from single completed change**
  - Setup: a completed change with proposal + spec
  - Action: `specshift finalize`
  - Verify: CHANGELOG.md gains the corresponding entry

- [ ] **Scenario: Multiple completed changes ordered newest first**
  - Setup: three completed changes with different dates
  - Action: `specshift finalize`
  - Verify: newest entry first

- [ ] **Scenario: Existing changelog preserved**
  - Setup: CHANGELOG.md with manual entries
  - Action: `specshift finalize`
  - Verify: manual entries unmodified

- [ ] **Scenario: No completed changes to process**
  - Setup: no completed changes
  - Action: `specshift finalize`
  - Verify: agent reports nothing to do

- [ ] **Scenario: Change with only internal refactoring**
  - Setup: completed change with no user-visible changes
  - Action: `specshift finalize`
  - Verify: agent omits or files under "Internal improvements" without fabricating user-facing changes

#### Changelog Version Headers

- [ ] **Scenario: Single change produces versioned header**
  - Setup: completed change being finalized; `src/VERSION` contains `0.2.3-beta`
  - Action: `specshift finalize` runs the changelog step
  - Verify: entry uses header `## [v0.2.3-beta] — <date>`; change title appears as `### <Title>` sub-header

- [ ] **Scenario: release.yml extracts versioned block correctly**
  - Setup: CHANGELOG.md with `## [v0.2.3-beta] — <date>` as first entry
  - Action: run the release.yml sed extraction
  - Verify: captures the entire `## [v0.2.3-beta]` block including all `### ` sub-headers

- [ ] **Scenario: Multi-change version groups entries under one header**
  - Setup: two changes merged under same version
  - Action: `specshift finalize` consolidates
  - Verify: both appear under one `## [v<version>]` header with separate `### <Title>` sub-headers

#### Language-Aware Changelog Generation

- [ ] **Scenario: Changelog generated in configured language**
  - Setup: `docs_language: German` in WORKFLOW.md
  - Action: `specshift finalize`
  - Verify: German section headers; entry descriptions in German; ISO dates

- [ ] **Scenario: Default to English when field is missing**
  - Setup: no `docs_language` field
  - Action: `specshift finalize`
  - Verify: entries in English

- [ ] **Scenario: Existing entries preserved in previous language**
  - Setup: existing English entries; switch `docs_language` to French
  - Action: `specshift finalize`
  - Verify: English entries unchanged; new entries in French

#### Automated GitHub Release via CI

- [ ] **Scenario: Release created after version bump push**
  - Setup: push to `main` changing `src/VERSION` from `1.0.28` to `1.0.29`; CHANGELOG.md has `## [v1.0.29] — <date>` entry
  - Action: GitHub Actions workflow runs
  - Verify: tag `v1.0.29` created; GitHub Release `v1.0.29` created with the CHANGELOG entry as body

- [ ] **Scenario: Tag already exists**
  - Setup: push with `src/VERSION = 1.0.29`; tag `v1.0.29` already exists
  - Action: GitHub Actions workflow runs
  - Verify: workflow exits successfully without creating a duplicate tag

- [ ] **Scenario: No version change**
  - Setup: push to `main` that does not touch `src/VERSION`
  - Action: GitHub push processed
  - Verify: release workflow does NOT trigger

- [ ] **Scenario: First release ever**
  - Setup: repository with no tags; push with `src/VERSION = 1.0.29`
  - Action: workflow runs
  - Verify: tag `v1.0.29` and Release `v1.0.29` created

#### Consumer Version Pinning

- [ ] **Scenario: Consumer pins to specific version**
  - Setup: GitHub Release `v1.0.29` with corresponding tag
  - Action: `claude plugin marketplace add fritze-dev/specshift#v1.0.29`
  - Verify: marketplace resolves to `v1.0.29`; installed plugin is `1.0.29`

- [ ] **Scenario: Consumer on pinned version does not receive updates**
  - Setup: pinned `#v1.0.29`; new version `1.0.30` released
  - Action: marketplace update
  - Verify: marketplace stays at `v1.0.29`; plugin remains `1.0.29`

#### Developer Local Marketplace Workflow

- [ ] **Scenario: Claude Code developer registers local marketplace**
  - Setup: maintainer with `/path/to/specshift`
  - Action: `claude plugin marketplace add /path/to/specshift --scope user && claude plugin install specshift@specshift`
  - Verify: install loads from local FS; `claude plugin list` shows current local version

- [ ] **Scenario: Skill changes reload immediately**
  - Setup: developer with local marketplace registered
  - Action: edit a SKILL.md, run `/reload-plugins`
  - Verify: modified skill is active

- [ ] **Scenario: Version changes require explicit update**
  - Setup: developer with local marketplace registered
  - Action: change `src/VERSION`, recompile, `/reload-plugins`
  - Verify: old version still reported until plugin-update command runs; after update, new version active

#### Source and Release Directory Structure

- [ ] **Scenario: Source directory contains editable files**
  - Setup: tree
  - Action: `ls src/`
  - Verify: `src/skills/specshift/SKILL.md`, `src/templates/`, `src/actions/`, and `src/VERSION` exist; no per-target manifest under `src/`

- [ ] **Scenario: Manifests and marketplaces hand-edited at the root**
  - Setup: tree
  - Action: `ls .claude-plugin/ .codex-plugin/ .agents/plugins/`
  - Verify: all four root files exist; no `src/.claude-plugin/`, no `src/.codex-plugin/`

- [ ] **Scenario: Shared release directory contains generated files**
  - Setup: post-compile
  - Action: `ls ./skills/specshift/`
  - Verify: contains `SKILL.md`, `templates/`, `actions/`

#### Marketplace Source Configuration

- [ ] **Scenario: Claude marketplace points to repo root**
  - Setup: `.claude-plugin/marketplace.json` with `source: "./"`
  - Action: install via Claude Code from this marketplace
  - Verify: cache contains `./skills/specshift/` and `.claude-plugin/plugin.json`; does NOT contain `docs/specs/`, `src/`, CI workflows, or changelog

- [ ] **Scenario: Codex manifest points to shared skill tree**
  - Setup: `.codex-plugin/plugin.json` with `skills: "./skills/"`
  - Action: install via Codex
  - Verify: cache contains the shared skill tree

- [ ] **Scenario: Local developer marketplace**
  - Setup: developer with local marketplace registered
  - Action: edit `src/`, recompile, run plugin-update
  - Verify: plugin install reflects rebuilt release

#### Repository Layout Separation

- [ ] **Scenario: Clean separation**
  - Setup: post-finalize tree
  - Action: walk the directory structure
  - Verify: `src/` only source files (incl. `VERSION`); `./skills/specshift/` only generated; manifests at root; project files at root; no project files inside `src/` or `./skills/`

#### AOT Skill Compilation

- [ ] **Scenario: Finalize triggers AOT compilation**
  - Setup: completed change with audit verdict PASS
  - Action: `specshift finalize`
  - Verify: source files copied to `./skills/specshift/`; `src/VERSION` value stamped into all four root files and into the workflow template's `plugin-version` field; compiled action files generated under `./skills/specshift/actions/`; each compiled file contains only requirement blocks

- [ ] **Scenario: Count validation detects missing requirements**
  - Setup: edit `src/actions/propose.md` to include a link to a non-existent spec
  - Action: `bash scripts/compile-skills.sh`
  - Verify: warning naming the unresolvable link; compilation continues for remaining actions; restore `src/actions/propose.md` after the test

- [ ] **Scenario: Legacy skill location cleaned**
  - Setup: a checkout that previously had `.claude/skills/specshift/`
  - Action: `bash scripts/compile-skills.sh`
  - Verify: `.claude/skills/specshift/` no longer exists

#### Compiled Action File Contract

- [ ] **Scenario: Compiled file contains only requirements**
  - Setup: post-compile
  - Action: open `./skills/specshift/actions/propose.md`
  - Verify: starts with `# Requirements`; one `### Requirement:` block per linked requirement; no frontmatter, no instruction text

- [ ] **Scenario: Compiled file with no requirement links**
  - Setup: a built-in action source file with no links (synthetic test if not naturally present)
  - Action: compile
  - Verify: compiled file contains only the `# Requirements` heading

#### Dev Sync Script

- [ ] **Scenario: Dev script builds complete release directory**
  - Setup: clean working tree
  - Action: `bash scripts/compile-skills.sh`
  - Verify: source files copied to `./skills/specshift/`; `src/VERSION` value stamped into all four root files; compiled action files written; summary printed

- [ ] **Scenario: Dev script requires jq**
  - Setup: shell where `jq` is not on PATH
  - Action: `bash scripts/compile-skills.sh`
  - Verify: script fails with descriptive "jq is required" error

- [ ] **Scenario: Dev script run outside repo root**
  - Setup: directory without `src/skills/specshift/SKILL.md`
  - Action: `bash scripts/compile-skills.sh`
  - Verify: script detects missing source and exits with an error message

## Edge Case Tests

These tests cover the spec's `## Edge Cases` sections in the three updated specs.

- [ ] **Edge: Codex manifest schema change**
  - Setup: add an unknown field to `.codex-plugin/plugin.json`
  - Action: `bash scripts/compile-skills.sh`
  - Verify: the unknown field is preserved verbatim post-compile (only `version` is stamped)

- [ ] **Edge: Existing Claude install with old marketplace source**
  - Setup: a Claude Code install whose marketplace cache predates the migration
  - Action: `claude plugin marketplace update specshift`
  - Verify: refresh succeeds; new skill tree at `./skills/specshift/` resolves

- [ ] **Edge: Branding assets absent**
  - Setup: `.codex-plugin/plugin.json` without `interface.logo`, `composerIcon`, `brandColor`, `screenshots`
  - Action: install via Codex
  - Verify: install succeeds; listing displays without branding

- [ ] **Edge: Mixed-target consumer project**
  - Setup: project that uses both Claude Code and Codex
  - Action: `specshift init` once
  - Verify: both bootstrap files present; both tools load the same instructions (Codex via `AGENTS.md`, Claude Code via `CLAUDE.md` import expansion)

- [ ] **Edge: Per-target manifest field drift**
  - Setup: edit `description` in `.claude-plugin/plugin.json` to a value different from `.codex-plugin/plugin.json`
  - Action: `bash scripts/compile-skills.sh`
  - Verify: descriptions remain divergent (compile script only enforces `version`); maintainer review is responsible for parity

- [ ] **Edge: `src/VERSION` malformed or missing**
  - Setup: temporarily delete `src/VERSION` (or replace with empty / multiline)
  - Action: `bash scripts/compile-skills.sh`
  - Verify: script fails with a descriptive error before stamping any file; restore the file after the test

- [ ] **Edge: Manual edit to a manifest version field**
  - Setup: hand-edit `.codex-plugin/plugin.json` `version` to a different value
  - Action: `bash scripts/compile-skills.sh`
  - Verify: manual edit is overwritten by SoT value; cross-check passes

- [ ] **Edge: `./skills/` gitignore conflict**
  - Setup: tree's `.gitignore`
  - Action: `git status` after compile
  - Verify: `./skills/` files are tracked (not ignored); if a future maintainer adds `./skills/*` to `.gitignore`, the compile output would silently disappear from the repo — this is the documented constraint

- [ ] **Edge: Bootstrap template missing from plugin**
  - Setup: simulate a plugin install missing `agents.md` or `claude.md` template
  - Action: `specshift init`
  - Verify: corresponding bootstrap-file generation is skipped with a WARNING; init does not block

- [ ] **Edge: Bootstrap files manually edited after init**
  - Setup: project with hand-edited AGENTS.md (added project-specific section)
  - Action: re-run `specshift init`
  - Verify: AGENTS.md unmodified; CLAUDE.md unmodified

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios (specs) | 53 |
| Automated tests | 0 (manual-only mode per CONSTITUTION) |
| Manual test items (scenarios) | 53 |
| Edge case tests | 10 |
| Preserved (@manual) | 0 (no prior tests file in this change) |
| Warnings | 0 |
