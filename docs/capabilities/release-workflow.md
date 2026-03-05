---
title: "Release Workflow"
capability: "release-workflow"
description: "Version management, changelog generation, and consumer update guidance"
lastUpdated: "2026-03-05"
---

# Release Workflow

This capability defines the release workflow conventions: automatic patch version bumps on archive, version synchronization between plugin files, manual minor/major release processes, consumer update guidance, and changelog generation from archived changes.

## Why This Exists

Without automated version management, patch versions would need to be bumped manually after every archive, leading to forgotten bumps and version confusion. Without a changelog, users would need to read spec files or commit logs to understand what changed. This capability ensures versions stay current automatically and changes are communicated clearly.

## Design Rationale

Patch bumps are automatic on archive because every completed change warrants at least a patch version increment. Minor and major releases are manual because they represent intentional decisions about feature scope or breaking changes that require human judgment. The changelog follows the Keep a Changelog format because it is widely recognized and structures entries by change type.

## Features

- Automatic patch version bump in plugin.json and marketplace.json after `/opsx:archive`
- Version synchronization between plugin.json (source of truth) and marketplace.json
- Manual minor/major release process with git tags and optional GitHub Releases
- Consumer update guidance: marketplace refresh, plugin update, restart
- `/opsx:changelog` generates release notes from archived changes in Keep a Changelog format
- Post-archive next steps include changelog generation, push, and local plugin update
- Skill immutability convention: project-specific behavior lives in the constitution, not in skills

## Behavior

### Automatic Patch Bump

When you archive a change via `/opsx:archive`, the system automatically increments the patch version in plugin.json and syncs it to marketplace.json. The archive summary displays the new version. If the two files are out of sync before bumping, plugin.json is used as the source of truth.

### Manual Minor/Major Releases

For intentional minor or major version changes, you manually set the version in both plugin.json and marketplace.json, create a git tag (e.g., `v1.1.0`), push the tag, and optionally create a GitHub Release.

### Consumer Updates

To update the plugin, consumers run the marketplace update command to refresh the listing, then the plugin update command, then restart Claude Code. If an update is not detected, refreshing the marketplace listing first usually resolves it.

### Changelog Generation

When you run `/opsx:changelog`, the system reads archived changes from `openspec/changes/archive/`, examines each archive's proposal, delta specs, and design artifacts, and produces changelog entries in Keep a Changelog format (Added, Changed, Deprecated, Removed, Fixed, Security). Entries are ordered newest first. If CHANGELOG.md already exists, new entries are added at the top while preserving existing content.

### Post-Archive Flow

After a successful archive, the system shows next steps: generate the changelog with `/opsx:changelog`, push to remote, and update the local plugin installation.

## Known Limitations

- Patch bumps are automatic only -- minor and major releases require manual version setting
- Changelog generation relies on archive artifacts; purely internal refactoring may result in minimal entries

## Edge Cases

- If the archive directory is empty or does not exist when running `/opsx:changelog`, the system informs you that no archived changes were found.
- If an archived change is purely internal refactoring with no user-visible changes, the changelog either omits the entry or includes a minimal "Internal improvements" note.
- If CHANGELOG.md contains manually written entries, the system preserves them when adding new entries.
