---
title: "Change Workspace"
capability: "change-workspace"
description: "Workspace creation via propose, proposal-based context detection, and change lifecycle tracking"
lastUpdated: "2026-04-28"
---

# Change Workspace

Manages the full lifecycle of a change workspace -- from creation through completion -- so that every feature or improvement follows a structured, traceable path. Workspace creation is handled by `specshift propose`, and change context detection is handled by the router.

## Purpose

Without structured change workspaces, spec-driven development becomes disorganized -- artifacts scatter across the project, changes lack clear boundaries, and completed work has no consistent organizational pattern. Without structured metadata in proposals, commands must rely on fragile conventions to detect which change is active and whether it is complete.

## Rationale

Change names use kebab-case for consistent, URL-safe, filesystem-safe identifiers. Change directories use a date-prefixed naming scheme (YYYY-MM-DD-name) so they sort chronologically by default. Proposal frontmatter carries structured metadata (`status`, `branch`, `capabilities`) that enables the router to detect the active change and filter active vs completed changes without parsing markdown or relying on naming conventions. Workspace creation is part of propose because creating a workspace and starting artifact generation are a single workflow step. Change context detection lives in the router as shared logic, eliminating copy-pasted detection code across multiple skill files.

## Features

- **Workspace creation via propose** -- `specshift propose <name>` creates the workspace directory and begins pipeline traversal
- **Proposal tracking frontmatter** -- proposals include `status`, `branch`, and `capabilities` (new/modified/removed) in YAML frontmatter
- **Automatic name derivation** -- provide a description instead of a kebab-case name and the system converts it
- **Change context detection** -- the router auto-detects the active change by matching proposal `branch` frontmatter against the current branch, falling back to a directory listing prompt
- **Date-prefixed naming** -- change directories use `YYYY-MM-DD-<name>` format, set at creation and never changed
- **Active vs completed detection** -- changes are distinguished by proposal `status` field (`active`/`completed`), with fallback to tasks.md checkbox parsing for legacy proposals

## Behavior

### Creating a Workspace (`specshift propose`)

When you run `specshift propose add-user-auth`, the system creates a workspace at `.specshift/changes/YYYY-MM-DD-add-user-auth/` and begins pipeline traversal. If you provide a description, the system derives a kebab-case name automatically. If the name is invalid, the system asks for a valid name. If a change with that name already exists, the system suggests continuing it.

### Proposal Tracking Frontmatter

When the proposal artifact is generated, it includes YAML frontmatter with `status: active`, `branch`, and `capabilities` (structured new/modified/removed lists). This frontmatter enables the router to detect changes, filter by status, and identify affected capabilities without parsing markdown. New proposals do not write a `worktree` frontmatter field.

### Change Context Detection (Router)

The router auto-detects the active change using a two-tier approach: (1) scan proposal frontmatter for a `branch` field matching the current branch; (2) if no match, list active changes and prompt. An explicit argument always overrides auto-detection.

### Active vs Completed Change Detection

Changes are identified as active or completed based on their proposal's `status` frontmatter field. `active` (or absent) means in progress; `completed` means done (set during verify completion). Commands that operate on active changes (propose, apply) filter to active; commands that operate on completed changes (finalize) filter to completed.

## Edge Cases

- If the name contains uppercase or special characters, the system asks for a valid kebab-case name.
- If a change with that name already exists, the system suggests continuing instead of creating a duplicate.
- If two proposals have the same `branch` value, the most recently modified one is used with a warning.
- If a branch is renamed after change creation, the proposal's `branch` field becomes stale and detection falls through to the directory listing prompt.
- **Legacy `worktree:` frontmatter on existing proposals**: proposals committed before this capability was simplified may still carry a `worktree:` field. New proposals do not write the field, and skills treat any existing value as read-only legacy data.
