---
title: "Release Workflow"
capability: "release-workflow"
description: "Multi-target version management, automated releases, plugin distribution to Claude Code and Codex, changelog generation, and consumer update process."
lastUpdated: "2026-04-27"
---
# Release Workflow

The release workflow handles version management for the plugin across both supported targets, including automatic patch bumps during the post-apply workflow, automated GitHub Releases via CI, plugin source distribution from the `src/` subdirectory, hand-edited per-target manifests at the repo root with `jq`-based version stamping, consumer version pinning, developer local marketplace workflow, changelog generation via `specshift finalize`, and documented processes for manual releases and consumer updates on Claude Code and Codex CLI.

## Purpose

Without an automated release workflow, version bumps are a manual step that is regularly forgotten, causing consumers to miss updates even after changes are pushed. With multi-target distribution, version drift between the Claude and Codex manifests would mean releasing inconsistent versions across runtimes; without a single source of truth, manifests can disagree on which release they represent. There is also no structured process for generating changelogs or guiding consumers on either target through updates.

## Rationale

The auto-bump is implemented as a constitution convention rather than a skill modification, respecting the principle that skills are shared plugin code and must not contain project-specific behavior. Patch bumps cover the vast majority of changes; minor and major releases are rare enough that a documented manual process suffices. The Claude manifest at `.claude-plugin/plugin.json` is the single version source of truth — the compile script reads its version and stamps it into the Codex manifest in place via `jq` (preserving every other Codex field) and into the Codex marketplace, so per-target versions cannot disagree across a release. Per-target manifests are hand-edited at the repo root to keep target-specific metadata (display name, capabilities, branding, default prompts) where the host CLI expects it. The changelog command identifies completed changes by reading proposal frontmatter `status: completed` (falling back to tasks.md checkbox parsing for legacy changes without frontmatter) and reads the proposal's frontmatter `capabilities` field to identify affected capabilities (falling back to parsing the Capabilities section). It also reads `.specshift/WORKFLOW.md` for a `docs_language` setting, allowing teams to generate release notes in their preferred language while keeping dates in ISO format and product names in English.

## Features

- **Automatic patch version bump** — the patch version increments automatically after each completed change during the post-apply workflow
- **Per-target version synchronization** — `.claude-plugin/plugin.json` (source of truth), `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, and `.agents/plugins/marketplace.json` stay in sync via the compile script's `jq`-based stamping
- **Automated GitHub Releases** — a GitHub Action creates git tags and releases automatically when a version bump is pushed to `main`
- **Multi-target plugin distribution** — one shared agnostic skill tree at `./skills/specshift/` is served to both Claude Code (via `.claude-plugin/marketplace.json` `source: "./"`) and Codex CLI (via `.codex-plugin/plugin.json` `skills: "./skills/"`)
- **Hand-edited per-target manifests** — `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` live at the repo root and carry target-specific metadata; only the `version` field is enforced by the compile script
- **Consumer version pinning** — Claude Code consumers can pin to a specific version using a tag reference when adding the marketplace
- **Developer local marketplace** — developers register the local repo as marketplace source for live plugin development
- **Manual minor/major releases** — documented process for intentional version changes; the Action handles tagging automatically
- **Per-target consumer update guidance** — clear steps for consumers on Claude Code and on Codex CLI to get the latest plugin version
- **Changelog generation** — `specshift finalize` produces release notes from completed changes in Keep a Changelog format, using proposal frontmatter for change detection
- **Language-aware changelog** — changelog entries can be generated in the language configured in `docs_language`
- **Post-apply next steps** — apply output includes guidance for the complete post-apply workflow

## Behavior

### Automatic Patch Bump

During the post-apply workflow, the patch version in `.claude-plugin/plugin.json` (the source of truth, hand-edited at the repo root) is incremented automatically (for example, `1.0.3` becomes `1.0.4`). The `version` field in `.claude-plugin/marketplace.json` is synced to match. Running `bash scripts/compile-skills.sh` then stamps the same version into `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json` in place via `jq`, preserving every other field verbatim. The new version is displayed in the summary.

### Automated GitHub Releases

When a version bump is pushed to `main`, a GitHub Action automatically creates a git tag (`v<version>`) and a GitHub Release. The release body contains the latest changelog entry from `CHANGELOG.md`. If the tag already exists, the Action skips silently (idempotent).

### Plugin Source and Manifest Layout

Plugin source code (skills, templates, action specs) lives in the `src/` subdirectory. Plugin manifests and marketplace files all live hand-edited at the repo root: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, and `.agents/plugins/marketplace.json`.

Consumer plugin caches contain only the compiled release artifacts — documentation, CI workflows, project spec files, and changelogs are not downloaded.

### Consumer Version Pinning

Consumers can pin to a specific plugin version by adding the marketplace with a tag reference (for example, `claude plugin marketplace add fritze-dev/specshift#v1.0.30`). Pinned marketplaces do not receive updates when new versions are released.

### Developer Local Marketplace

Developers register the local repository path as a marketplace source for live plugin development. Skill changes reload via `/reload-plugins`. Version changes require an explicit `claude plugin update`. After editing source files, running `bash scripts/compile-skills.sh` regenerates the shared `./skills/specshift/` tree and re-stamps Codex manifest/marketplace versions.

### Version Synchronization

The `version` fields in `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, and `.agents/plugins/marketplace.json` always match `.claude-plugin/plugin.json`. The compile script enforces this on every run: it reads the Claude version and stamps it via `jq` into both the Codex manifest and the Codex marketplace in place (preserving every other field verbatim), then verifies that the emitted Codex versions equal the Claude source after stamping. If any are out of sync beforehand, they are realigned to the Claude version automatically.

### Manual Minor and Major Releases

For intentional minor or major version changes, you manually set the version in `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, run `bash scripts/compile-skills.sh` to stamp the Codex manifest and marketplace, then push to `main`. The GitHub Action automatically creates the git tag and release. For retroactive tagging without a version change, you can manually create and push a tag.

### Consumer Update Process

When a new plugin version is available, Claude Code consumers run `claude plugin marketplace update specshift` to refresh the listing, then `claude plugin update specshift@specshift` to install the update, and restart Claude Code to load the new version. Codex consumers open the Codex `/plugins` UI, refresh or reinstall SpecShift, and restart the Codex session.

### Update Not Detected

If `claude plugin update` does not detect a new version, first refresh the marketplace listing with `claude plugin marketplace update specshift` and retry. As a last resort, uninstall and reinstall the plugin.

### Skill Immutability

Skills in `skills/` are generic plugin code shared across all consumers and are not modified for project-specific behavior. Project-specific workflows and conventions are defined in the constitution.

### Project-Specific Behavior in Constitution

When project-specific post-apply behavior is needed (such as version bumps), it is defined as a convention in `.specshift/CONSTITUTION.md`, not added as a step in the skill file.

### End-to-End Install Flow

For Claude Code: `claude plugin marketplace add fritze-dev/specshift` followed by `claude plugin install specshift` followed by `specshift init`. For Codex: `codex /plugins`, browse for SpecShift and install, then run `specshift init` in the target repository.

### End-to-End Update Flow

For Claude Code: `claude plugin marketplace update specshift` followed by `claude plugin update specshift@specshift`. For Codex: `codex /plugins`, refresh or reinstall SpecShift. Running `specshift init` again is safe (idempotent) and ensures schema updates are picked up.

### Post-Push Developer Plugin Update

For developers using the Claude local marketplace, running `claude plugin update specshift@specshift` detects the local version change and updates the cached plugin. For developers using the GitHub marketplace, the existing `marketplace update` + `plugin update` flow applies. Codex local-development setups update through the Codex `/plugins` UI's refresh.

### Post-Apply Workflow Next Steps

After a completed change, the post-apply workflow includes next steps: verify, changelog, docs, version bump (compile re-stamps Codex outputs), and commit.

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

Each changelog entry uses a version-anchored header in the format `## [v<version>] — <date>`, where `<version>` is the plugin version from `.claude-plugin/plugin.json` at the time of finalization and `<date>` is the release date in ISO format. Individual changes within a version use `### <Title>` sub-headers. When multiple changes are included in a single version (for example, due to multiple merges between releases), all changes are grouped under one `## [v<version>]` header with separate `### <Title>` sub-headers for each change. This format ensures compatibility with the `release.yml` extraction pattern, which captures the first `## ` block as the release body. Date-only headers without version numbers are not used, as they prevent mapping changelog entries to specific releases.

### Changelog in Configured Language

When `.specshift/WORKFLOW.md` contains a `docs_language` setting (for example, `German`), `specshift finalize` generates section headers and entry descriptions in that language. Dates remain in ISO format and product names (Claude Code, Codex) stay in English.

### Default Language

When the `docs_language` field is missing or set to `English`, changelog entries are generated in English.

### Language Change Mid-Project

If the documentation language is changed after entries have already been generated, existing entries are preserved in their original language and new entries use the new language.

## Known Limitations

- Does not support automatic minor or major version bumps — these require a manual process (but the Action handles tagging automatically after push).
- Does not enforce non-version manifest field parity across targets — only the `version` field is enforced; agnostic metadata fields (`author`, `repository`, `license`, `keywords`) are reviewed manually.
- Consumer migration from the old flat layout to the new `src/`-plus-root-manifests layout requires a `marketplace update` + `plugin update` — there is no automatic migration.

## Future Enhancements

- CI parity check for non-version manifest fields across targets.
- A `specshift status` skill for checking the current project and plugin state.
- Sparse checkout via `git-subdir` for even more efficient consumer downloads.

## Edge Cases

- If `.claude-plugin/plugin.json` does not exist (consumer projects without plugin manifests), the version bump step is silently skipped.
- If `CHANGELOG.md` is missing when the release Action runs, the release is created with a minimal body instead of failing.
- If a consumer adds the marketplace before the multi-target restructuring, the old cache is replaced on the next `plugin update` (Claude) or refresh (Codex).
- If the version field contains a non-semver value, the system warns and skips the bump rather than producing an invalid version.
- If the change directory contains changes with only internal refactoring, the changelog agent either omits the entry or uses a minimal note to avoid fabricating user-facing changes.
- If `jq` is missing on a developer machine, the compile script fails preflight with an instructive message naming the missing dependency.
- If the Codex manifest at the root carries a different version than the Claude manifest, the compile script restamps Codex `.version` to the Claude source and verifies equality post-stamp, preventing inconsistent releases.
