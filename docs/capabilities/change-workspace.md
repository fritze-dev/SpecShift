---
title: "Change Workspace"
capability: "change-workspace"
description: "Change lifecycle: creation with /opsx:new, workspace structure, and archiving with /opsx:archive"
order: 7
lastUpdated: "2026-03-02"
---

# Change Workspace

Use `/opsx:new` to create a change workspace, work through the pipeline, and `/opsx:archive` to finalize and archive the completed change.

## Features

- Create a scaffolded change workspace with a single command
- Workspace structure follows the active schema with dependency-gated artifacts
- Archive completed changes with date-prefixed directory names
- Safety prompt for unsynced delta specs before archiving

## Behavior

### Creating a Change

Run `/opsx:new <change-name>` with a kebab-case name. If you provide a description instead, the system derives a name. The workspace is created at `openspec/changes/<name>/` with an `.openspec.yaml` manifest recording the schema.

### Workspace Structure

The workspace contains artifacts defined by the active schema. Only the first artifact (research) is ready initially; downstream artifacts are blocked by unmet dependencies. You can check status with `openspec status --change "<name>"`.

### Archiving

Run `/opsx:archive` to move a completed change to `openspec/changes/archive/` with a `YYYY-MM-DD-<name>` prefix. If delta specs exist and haven't been synced, the system prompts you to sync first. If artifacts or tasks are incomplete, you get a warning and must confirm.

## Edge Cases

- If a change with the same name already exists, the system suggests continuing it instead of creating a duplicate.
- If the user provides an invalid name format, the system asks for a valid kebab-case name.
- If no active changes exist when archiving, the system suggests creating one.
- If multiple changes exist and none is specified, the system lists them and asks you to choose.
- If the archive target already exists, the system fails and suggests renaming or using a different date.
- The system creates `openspec/changes/archive/` if it doesn't exist.
