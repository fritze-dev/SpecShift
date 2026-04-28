---
title: "Release Workflow"
capability: "release-workflow"
description: "Agnostic version source of truth, symmetric per-target stamping, automated GitHub releases, multi-target plugin distribution (Codex via marketplace catalog), changelog generation, and per-target consumer update guidance."
lastUpdated: "2026-04-28"
---
# Release Workflow

The release workflow handles version management for the multi-target plugin: a single agnostic version source of truth at `src/VERSION`, automatic patch bumps during the post-apply workflow, symmetric stamping into the three root manifest/marketplace files (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`) with post-stamp cross-check enforced both at compile time and in CI before tag creation, automated GitHub Releases via CI triggered by `src/VERSION` changes, plugin distribution via the shared compiled skill tree at `./skills/specshift/`, consumer version pinning, developer local marketplace workflow per target, changelog generation via `specshift finalize`, and documented processes for manual releases and consumer updates on both Claude Code and Codex CLI.

## Purpose

Without an agnostic version source of truth, per-target manifests carry dual responsibility ("target metadata" plus "repo version SoT"), and one target's version inevitably becomes the canonical source while the others are stamped from it — asymmetric, fragile, and prone to silent drift when one of the marketplace files is hand-edited and forgotten. Without an automated release workflow, version bumps are a manual step that is regularly forgotten, causing consumers to miss updates even after changes are pushed. Without a structured process for changelogs and per-target update flows, consumers on either Claude Code or Codex have no clear path to keep up with releases.

## Rationale

`src/VERSION` is the single agnostic source of truth — plain text, single line, SemVer — chosen over embedding in a per-target manifest because it decouples versioning from per-target metadata and makes the bump UX a single small edit. The compile script reads `src/VERSION` and stamps the value into all three root manifest/marketplace files via `jq` (preserving all non-version keys and values semantically; JSON formatting may be normalized), then re-reads each file and verifies the stamped value matches; any mismatch fails the build with an error naming the offending file. This eliminates a class of bug — silent drift on the unchecked manifest — that previously affected the Claude marketplace's version field. The auto-bump is implemented as a constitution convention rather than a skill modification, respecting the principle that skills are shared plugin code and must not contain project-specific behavior. Patch bumps cover the vast majority of changes; minor and major releases are rare enough that a documented manual process suffices. The changelog command identifies completed changes by reading proposal frontmatter `status: completed` (falling back to tasks.md checkbox parsing for legacy changes) and reads the proposal's frontmatter `capabilities` field to identify affected capabilities. It also reads `.specshift/WORKFLOW.md` for a `docs_language` setting, allowing teams to generate release notes in their preferred language while keeping dates in ISO format and product names in English.

## Features

- **Agnostic version source of truth** at `src/VERSION` -- single small edit to bump the plugin version
- **Symmetric version stamping** -- the compile script stamps `src/VERSION` into all three root manifest/marketplace files via `jq` and cross-checks each post-stamp; any drift fails the build
- **Automatic patch version bump** -- the patch version in `src/VERSION` increments automatically after each completed change during the post-apply workflow
- **Automated GitHub Releases** -- a GitHub Action creates git tags and releases automatically when `src/VERSION` changes on `main`
- **Plugin source separation** -- plugin source lives in `src/`; per-target manifests/marketplaces hand-edited at the repo root; the shared compiled skill tree at `./skills/specshift/` consumed by both targets
- **Consumer version pinning** -- consumers can pin to a specific version using a tag reference when adding the marketplace
- **Developer local marketplace per target** -- developers register the local repo as marketplace source for live plugin development on either target
- **Manual minor/major releases** -- documented process: edit `src/VERSION`, run `bash scripts/compile-skills.sh`, push; the Action handles tagging
- **Per-target consumer update guidance** -- clear update commands for Claude Code (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`) and Codex (`codex plugin marketplace upgrade specshift`)
- **Changelog generation** -- `specshift finalize` produces release notes from completed changes in Keep a Changelog format
- **Language-aware changelog** -- changelog entries can be generated in the language configured in `docs_language`
- **Post-apply next steps** -- apply output includes guidance for the complete post-apply workflow

## Behavior

### Version Source of Truth

The plugin version is stored in `src/VERSION` -- plain text, single line, SemVer (e.g., `0.2.5-beta`). This is the only file the maintainer edits to bump the version. No per-target manifest is the source of truth; each manifest's `version` field is a stamped copy.

### Symmetric Version Stamping with Cross-Check

When `bash scripts/compile-skills.sh` runs, it reads `src/VERSION` once, validates it as a SemVer 2.0 string, and stamps the value into the three root files: `.claude-plugin/plugin.json` `.version`, `.claude-plugin/marketplace.json` `.plugins[].version`, and `.codex-plugin/plugin.json` `.version`. Each file is updated via `jq`, preserving all non-version keys and values semantically (JSON formatting may be normalized by `jq`). After stamping, the script re-reads each file and verifies the stamped value matches `src/VERSION`; any mismatch fails the build with an error naming the offending file. The same cross-check is also enforced in CI (`.github/workflows/release.yml`) before tag creation, catching the foot-gun where a maintainer pushes `src/VERSION` without recompiling. The compile script also stamps the version into the compiled workflow template's `plugin-version` frontmatter field.

### Automatic Patch Bump

During the post-apply workflow, the patch version in `src/VERSION` is incremented automatically (for example, `1.0.3` becomes `1.0.4`). The new version is displayed in the summary. The subsequent compile run propagates the new value into all three root manifest/marketplace files.

### Automated GitHub Releases

When `src/VERSION` changes on `main`, a GitHub Action automatically creates a git tag (`v<version>`) and a GitHub Release. The release body contains the latest changelog entry from `CHANGELOG.md`. If the tag already exists, the Action skips silently (idempotent).

### Source and Release Directory Structure

Plugin source code (skills, templates, action manifests, `VERSION`) lives in the `src/` subdirectory. Per-target plugin manifests and the Claude marketplace are hand-edited at the repository root (`.claude-plugin/`, `.codex-plugin/`). The shared compiled skill tree at `./skills/specshift/` is built from `src/` via `bash scripts/compile-skills.sh` and consumed by both Claude Code and Codex via their respective root manifests' skill-path field. Consumer plugin caches contain only what the marketplace/manifest references — documentation, CI workflows, project spec files, and changelogs are not downloaded.

### Marketplace Source Configuration

The Claude marketplace at `.claude-plugin/marketplace.json` declares `source: "./"` so Claude Code resolves the plugin root to the repo root and discovers the skill at `./skills/specshift/`. The Codex manifest at `.codex-plugin/plugin.json` declares `skills: "./skills/"` so Codex resolves the same shared skill tree. Both paths resolve correctly for local-filesystem and remote marketplaces.

### Consumer Version Pinning

Consumers can pin to a specific plugin version by adding the marketplace with a tag reference (for example, `claude plugin marketplace add fritze-dev/specshift#v1.0.30`). Pinned marketplaces do not receive updates when new versions are released.

### Developer Local Marketplace per Target

Claude Code developers register the local repository path via `claude plugin marketplace add /path/to/specshift --scope user` and install via `claude plugin install specshift@specshift`. Codex developers register the local marketplace via `codex plugin marketplace add ./<local-marketplace-root>` (the documented local-path form per `developers.openai.com/codex/plugins/build`) and enable SpecShift from the in-session `/plugins` directory. Skill changes reload via the host's plugin-reload command. Version changes require running the host's plugin-update command after editing `src/VERSION` and recompiling.

### Manual Minor and Major Releases

For intentional minor or major version changes, edit `src/VERSION` to the new SemVer string, run `bash scripts/compile-skills.sh` (which stamps the new value into all three root files), and push to `main`. The GitHub Action automatically creates the git tag and release. For retroactive tagging without a version change, manually create and push a tag.

### Consumer Update Process

#### Claude Code

When a new plugin version is available, Claude Code consumers run `claude plugin marketplace update specshift` to refresh the listing, then `claude plugin update specshift@specshift` to install the update, and restart Claude Code to load the new version.

#### Codex CLI

Codex consumers run `codex plugin marketplace upgrade specshift` to refresh the marketplace catalog and pick up the latest plugin version. The next Codex session loads the updated plugin from the in-session `/plugins` directory. No separate `plugin update` CLI command is needed — the marketplace upgrade is the documented mechanism.

### Update Not Detected (Claude Code)

If `claude plugin update` does not detect a new version, first refresh the marketplace listing with `claude plugin marketplace update specshift` and retry. As a last resort, uninstall and reinstall the plugin.

### Skill Immutability

Skills in the shared compiled tree (`./skills/`) are generic plugin code shared across all consumers and are not modified for project-specific behavior. Project-specific workflows and conventions are defined in the constitution.

### Project-Specific Behavior in Constitution

When project-specific post-apply behavior is needed (such as version bumps), it is defined as a convention in `.specshift/CONSTITUTION.md`, not added as a step in the skill file.

### End-to-End Install Flow per Target

Claude Code: `claude plugin marketplace add` followed by `claude plugin install` followed by `specshift init`. Codex: `codex plugin marketplace add fritze-dev/SpecShift` followed by enabling SpecShift from the in-session `/plugins` directory, then `specshift init`. In both cases, `specshift init` generates the constitution placeholder and both bootstrap files (`AGENTS.md` + `CLAUDE.md`).

### End-to-End Update Flow

The complete update path is: target-specific marketplace-update + plugin-update commands. Running `specshift init` again is safe (idempotent) and ensures schema updates are picked up.

### Post-Push Developer Plugin Update

For developers using a local marketplace, running the host's plugin-update command after a version bump in `src/VERSION` and a recompile detects the local change and updates the cached plugin. For developers using a remote marketplace, the existing marketplace-update + plugin-update flow applies.

### Post-Apply Workflow Next Steps

After a completed change, the post-apply workflow includes next steps: `specshift finalize` -> `src/VERSION` bump -> compile -> push -> update plugin.

### Changelog from Single Change

Running `specshift finalize` scans change directories, identifies completed changes by reading proposal frontmatter `status: completed` (falling back to tasks.md checkbox parsing for legacy proposals), reads the proposal's `capabilities` frontmatter to find affected specs, and produces changelog entries summarizing what changed from a user perspective. Entries use the Keep a Changelog format with sections like Added, Changed, and Fixed.

### Multiple Changes Ordered Newest First

When multiple completed changes exist, changelog entries are ordered with the newest first.

### Existing Changelog Preserved

If `CHANGELOG.md` already contains manually written entries, new entries are added at the top without modifying or removing existing content.

### No Completed Changes to Process

If no completed changes exist, `specshift finalize` informs you that no completed changes were found.

### Internal-Only Changes

If a completed change describes purely internal refactoring with no user-visible impact, it is either omitted or included under a minimal note rather than fabricating user-facing changes.

### Changelog Version Headers

Each changelog entry uses a version-anchored header in the format `## [v<version>] — <date>`, where `<version>` is the plugin version read from `src/VERSION` at the time of finalization and `<date>` is the release date in ISO format. Individual changes within a version use `### <Title>` sub-headers. When multiple changes are included in a single version (for example, due to multiple merges between releases), all changes are grouped under one `## [v<version>]` header with separate `### <Title>` sub-headers for each change. This format ensures compatibility with the `release.yml` extraction pattern, which captures the first `## ` block as the release body. Date-only headers without version numbers are not used, as they prevent mapping changelog entries to specific releases.

### Changelog in Configured Language

When `.specshift/WORKFLOW.md` contains a `docs_language` setting (for example, `German`), `specshift finalize` generates section headers and entry descriptions in that language. Dates remain in ISO format and product names (Claude Code, Codex) stay in English.

### Default Language

When the `docs_language` field is missing or set to `English`, changelog entries are generated in English.

### Language Change Mid-Project

If the documentation language is changed after entries have already been generated, existing entries are preserved in their original language and new entries use the new language.

## Known Limitations

- Per-target manifest non-version fields (description, keywords, author URL) are not enforced for parity across targets — drift is a maintainer-review concern, not a compile-time error.
- Does not support automatic minor or major version bumps — these require a manual process (but the Action handles tagging automatically after push).
- Consumer migration from the pre-multi-target layout (Claude marketplace `source: "./.claude"`, compiled skill at `.claude/skills/specshift/`) to the multi-target layout requires a `claude plugin marketplace update specshift && claude plugin update specshift@specshift` cycle once after upgrading. Documented in CHANGELOG.
- `jq` is a hard build requirement of the compile script — falling back to `sed`/`awk` would risk reformatting JSON.

## Future Enhancements

- A `specshift status` skill for checking the current project and plugin state.
- Live install smoke test in CI for both targets.
- Branding-asset support for the Codex listing (logo, brand color confirmation, screenshots).

## Edge Cases

- If `src/VERSION` is missing, empty, or contains more than one line, the compile script fails with a descriptive error before any stamping occurs.
- A maintainer who hand-edits a `version` field directly in a root manifest will find the next compile run overwrites that edit with the value from `src/VERSION`. The supported workflow is to edit `src/VERSION` and recompile.
- If `CHANGELOG.md` is missing when the release Action runs, the release is created with a minimal body instead of failing.
- If a consumer adds the marketplace before the multi-target migration, the old cache is replaced on the next marketplace-update + plugin-update cycle.
- If the version field contains a non-semver value, the system warns and skips the bump rather than producing an invalid version.
- If the change directory contains changes with only internal refactoring, the changelog agent either omits the entry or uses a minimal note to avoid fabricating user-facing changes.
- An additive Codex CLI plugin schema change (new optional `interface` fields) is preserved verbatim by the jq-stamping approach. A change to the Codex marketplace file location would require updating the compile script.
