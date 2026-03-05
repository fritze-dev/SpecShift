---
title: "Change Workspace"
capability: "change-workspace"
description: "Create, manage, and archive change workspaces"
lastUpdated: "2026-03-05"
---

# Change Workspace

This capability manages the change lifecycle: creating new workspaces with `/opsx:new`, maintaining schema-defined workspace structure, and archiving completed changes with `/opsx:archive`.

## Purpose

Without structured change workspaces, spec-driven development becomes disorganized -- artifacts scatter across the project, changes lack clear boundaries, and completed work has no consistent archival pattern. This capability ensures every change has a dedicated workspace with a defined structure, and completed changes are preserved chronologically for future reference.

## Rationale

Change names use kebab-case to ensure consistent, URL-safe, filesystem-safe identifiers. Archives use a date-prefixed directory naming scheme (YYYY-MM-DD-name) so they sort chronologically in the filesystem. The archive step prompts for spec sync before moving files to prevent baseline specs from going stale.

## Features

- Creates scaffolded change workspaces with `/opsx:new <change-name>`
- Derives kebab-case names from descriptions when you provide a phrase instead of a slug
- Enforces schema-defined workspace structure with artifact dependency chains
- Archives completed changes to a date-prefixed directory with `/opsx:archive`
- Prompts for delta spec sync before archiving to keep baselines current
- Warns about incomplete artifacts or tasks before archiving

## Behavior

### Creating a Workspace

When you run `/opsx:new add-user-auth`, the system creates a workspace at `openspec/changes/add-user-auth/` with the schema-defined structure. It displays the artifact status and the first artifact template. If you provide a description like "add user authentication" instead of a name, the system derives `add-user-auth` automatically. If the name is invalid (contains uppercase or special characters), the system asks for a valid kebab-case name. If a change with that name already exists, the system suggests continuing the existing change instead.

### Workspace Structure

The created workspace includes an `.openspec.yaml` manifest recording the schema used and creation metadata. The artifact pipeline sequence is determined by the schema -- for the opsx-enhanced schema, the stages are: research, proposal, specs, design, preflight, and tasks. Only the first stage (research) is ready initially; downstream stages are blocked by unmet dependencies.

### Archiving a Change

When you run `/opsx:archive`, the system moves the workspace to `openspec/changes/archive/` with a date prefix (e.g., `2026-03-02-add-user-auth/`). Before archiving, if unsynced delta specs exist, the system shows a summary and offers options: "Sync now" or "Archive without syncing." If artifacts or tasks are incomplete, the system displays a warning with details and asks you to confirm.

## Edge Cases

- If no active changes exist when archiving, the system informs you and suggests creating a new change.
- If multiple active changes exist and you do not specify which to archive, the system lists them and asks you to select one.
- If the archive target directory already exists, the system fails with an error and suggests renaming the existing archive or using a different date.
- If the move operation fails (e.g., disk full), the workspace stays in its original location and the system reports the error.
- An empty workspace (no artifacts created) can still be archived if you confirm the warning.
