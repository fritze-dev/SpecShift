---
title: "Release Workflow"
capability: "release-workflow"
description: "Version management with auto-bump on archive, changelog generation, and consumer update guidance"
order: 18
lastUpdated: "2026-03-04"
---

# Release Workflow

The release workflow handles version management, changelog generation, and update guidance. Patch versions are bumped automatically on each archive, version numbers stay in sync across plugin files, and changelogs are generated from archived changes.

## Why This Exists

Plugin consumers cannot detect updates unless the version number is bumped -- a manual step that was regularly forgotten. Additionally, version numbers across plugin files drifted out of sync, there was no documented release process, and no end-to-end verification of the install/update flow. This capability automates the most common case (patch bumps) and documents the rest.

## Background

Research into the Claude Code plugin system confirmed that the update command compares version fields to detect changes, meaning forgotten bumps silently block consumers from receiving updates. A hybrid approach was chosen: automatic patch bumps on archive (covering 95%+ of changes) combined with a documented manual process for the rare minor/major releases. The auto-bump is implemented as a constitution convention rather than a skill modification, preserving skill immutability.

## Features

- Automatic patch version bump after each successful archive
- Version synchronization between plugin files
- Documented manual process for minor and major releases with git tags
- Consumer update instructions (marketplace refresh, plugin update, restart)
- Changelog generation from archived changes in Keep a Changelog format
- Skill immutability convention: project-specific behavior lives in the constitution, not in skills
- End-to-end install and update checklists
- Post-archive next steps guidance
- Post-push developer plugin auto-update

## Behavior

### Automatic Patch Bump

After a successful archive, the patch version is automatically incremented in both plugin files (e.g., 1.0.3 becomes 1.0.4). The new version is displayed in the archive summary. If the version numbers are out of sync before bumping, they are aligned first, then the patch bump is applied.

### Manual Minor and Major Releases

For intentional minor or major version changes, you manually update the version in both plugin files, create a git tag (e.g., `v1.1.0`), push the tag, and optionally create a GitHub Release. This process is documented but not automated.

### Consumer Updates

To update to the latest plugin version, run `claude plugin marketplace update opsx-enhanced-flow` to refresh the listing, then `claude plugin update opsx@opsx-enhanced-flow` to install the update, and restart Claude Code. If an update is not detected, refresh the marketplace listing first and retry. As a last resort, uninstall and reinstall the plugin.

### Changelog Generation

Run `/opsx:changelog` to generate release notes from archived changes. The system reads each archived change, examines its proposal, delta specs, and design artifacts, and produces changelog entries summarizing what changed from your perspective. Entries follow the Keep a Changelog format (Added, Changed, Deprecated, Removed, Fixed, Security) and are ordered newest first. Existing manually written entries are preserved.

### Skill Immutability

Skills are generic plugin code shared across all consumers. They are not modified for project-specific behavior. Project-specific workflows and conventions are defined in the constitution instead.

### Post-Archive Next Steps

After a successful archive, the output includes next steps guiding you through the complete post-archive workflow: generate changelog, push, and update the local plugin.

## Known Limitations

- Does not support automatic git tagging; tags for minor and major releases are created manually
- Does not include a dedicated `/opsx:release` skill; the auto-bump convention covers the majority of cases
- Does not provide rollback for bad versions; consumers must wait for the next patch
- Version bump depends on the agent reading and following the constitution convention

## Edge Cases

- If plugin files have version numbers that are out of sync, they are aligned to the plugin.json version before the patch bump is applied.
- If the archive directory is empty or does not exist when running changelog generation, the system informs you that no archived changes were found.
- If an archived change describes only internal refactoring with no user-visible changes, the changelog either omits the entry or includes a minimal note.
- Existing changelog entries are preserved when new entries are added.
- The clean install flow (marketplace add, install, init, bootstrap) and update flow (marketplace update, plugin update, verify) serve as end-to-end checklists.
