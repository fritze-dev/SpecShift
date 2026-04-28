---
order: 3
category: change-workflow
status: stable
version: 5
lastModified: 2026-04-28
---
## Purpose

Manages the change lifecycle including workspace creation (now part of `specshift propose`), date-prefixed workspace structure, change-context detection (now handled by the router), and active/completed change detection based on proposal status.

## Requirements

### Requirement: Create Change Workspace

The system SHALL create a change workspace when the user invokes `specshift propose <change-name>`. The workspace directory SHALL use a creation-date prefix in the format `YYYY-MM-DD-<change-name>`, set at creation time and never changed. The workspace SHALL be created by running `mkdir -p .specshift/changes/YYYY-MM-DD-<name>` in the current working tree. The change name MUST be in kebab-case format. If the user provides a description instead of a name, the system SHALL derive a kebab-case name from the description. The system SHALL NOT proceed without a valid change name.

When the proposal artifact (`proposal.md`) is created for a change, the propose action SHALL include YAML frontmatter with tracking fields:
- `status: active` — change lifecycle (`active` → `review` when audit passes, `review` → `completed` after PR merge)
- `branch: <branch-name>` — git branch association
- `capabilities` — structured list of affected capabilities:
  ```yaml
  capabilities:
    new: [capability-one]
    modified: [quality-gates, spec-format]
    removed: []
  ```
  This machine-readable field mirrors the Capabilities section in the proposal body and eliminates the need for skills to parse markdown sections.

These fields enable automated change context detection, active/completed filtering, and capability lookup without relying on naming conventions or markdown parsing. New proposals MUST NOT write a `worktree` frontmatter field; existing proposals that already carry one are treated as legacy/read-only data.

**User Story:** As a developer I want to create a new change workspace with a date-prefixed directory, so that changes are chronologically ordered from creation and I can immediately begin the spec-driven workflow.

#### Scenario: Create workspace with date prefix

- **GIVEN** no change named "add-user-auth" exists
- **AND** today's date is 2026-04-01
- **WHEN** the user invokes `specshift propose add-user-auth`
- **THEN** the system creates the workspace at `.specshift/changes/2026-04-01-add-user-auth/`
- **AND** reads WORKFLOW.md to determine the artifact pipeline and displays the artifact status

#### Scenario: Derive name from description

- **WHEN** the user invokes `specshift propose` and provides the description "add user authentication"
- **AND** today's date is 2026-04-01
- **THEN** the system derives the kebab-case name `add-user-auth`
- **AND** creates the workspace at `.specshift/changes/2026-04-01-add-user-auth/`

#### Scenario: Proposal created with tracking frontmatter

- **GIVEN** a new change `add-user-auth` created on branch `add-user-auth`
- **AND** the proposal lists `user-auth` as a new capability and `quality-gates` as modified
- **WHEN** the proposal artifact is generated
- **THEN** `proposal.md` SHALL include YAML frontmatter with `status: active`, `branch: add-user-auth`, and `capabilities: { new: [user-auth], modified: [quality-gates], removed: [] }`
- **AND** SHALL NOT include a `worktree` frontmatter field

#### Scenario: Reject invalid name format

- **GIVEN** the user provides a name containing uppercase letters or special characters (e.g., "Add_User Auth")
- **WHEN** the system attempts to create the workspace
- **THEN** the system SHALL ask the user for a valid kebab-case name
- **AND** SHALL NOT create the workspace until a valid name is provided

#### Scenario: Change name already exists

- **GIVEN** a change directory matching `*-add-user-auth` already exists under `.specshift/changes/`
- **WHEN** the user invokes `specshift propose add-user-auth`
- **THEN** the system SHALL NOT create a duplicate workspace
- **AND** SHALL suggest continuing the existing change instead

### Requirement: Workspace Structure

The created workspace SHALL contain the artifacts defined by the pipeline in WORKFLOW.md. The artifact pipeline sequence SHALL be determined by the `pipeline` array in `.specshift/WORKFLOW.md` frontmatter (e.g., research, proposal, specs, design, preflight, tasks). Each artifact SHALL have a defined dependency chain that gates progression from one stage to the next.

**User Story:** As a developer I want the workspace to be pre-structured according to the workflow pipeline, so that I know exactly which artifacts need to be produced and in what order.

#### Scenario: Workspace contains pipeline-defined structure

- **GIVEN** the user creates a new change
- **WHEN** the workspace is created
- **THEN** the directory `.specshift/changes/YYYY-MM-DD-<name>/` SHALL exist
- **AND** reading WORKFLOW.md and checking file existence SHALL report all pipeline artifacts as pending

#### Scenario: Artifact dependency gating

- **GIVEN** a workspace created with the standard pipeline
- **WHEN** the user checks artifact status before creating any artifacts
- **THEN** only the first artifact in the pipeline (research) SHALL have status "ready"
- **AND** downstream artifacts (proposal, specs, design, preflight, tasks) SHALL be blocked by unmet dependencies

### Requirement: Change Context Detection

The router SHALL detect the active change using proposal frontmatter and pass the resolved context to the dispatched action. The detection sequence SHALL be:

1. **Proposal frontmatter lookup**: Scan `.specshift/changes/*/proposal.md` for a proposal whose `branch` field matches the current branch (`git rev-parse --abbrev-ref HEAD`). If found, auto-select that change.
2. **Fallback — directory listing**: If no proposal has a matching `branch` field, list active changes and prompt the user.

If a match is found, the router SHALL auto-select the change and announce: "Detected change context: using change '<name>'". An explicit argument always overrides auto-detection.

**User Story:** As a developer I want the router to automatically know which change I'm working on using structured metadata, so that detection is reliable regardless of naming conventions.

#### Scenario: Auto-detect change via proposal branch field

- **GIVEN** the user is on branch `add-user-auth`
- **AND** `.specshift/changes/2026-04-01-add-user-auth/proposal.md` has frontmatter `branch: add-user-auth`
- **WHEN** any command is invoked via the router without an explicit change name
- **THEN** the router SHALL auto-select "2026-04-01-add-user-auth"
- **AND** announce "Detected change context: using change 'add-user-auth'"

#### Scenario: Fall through to directory listing when no branch match

- **GIVEN** no proposal has a `branch` field matching the current branch
- **WHEN** any command is invoked via the router without an explicit change name
- **THEN** the router SHALL list active changes and prompt the user

#### Scenario: Explicit argument overrides auto-detection

- **GIVEN** the user is on branch `add-user-auth`
- **WHEN** a skill is invoked with explicit argument `other-change`
- **THEN** the router SHALL use "other-change" regardless of proposal frontmatter

### Requirement: Active vs Completed Change Detection

The router SHALL distinguish change phases using the proposal's `status` frontmatter field. The lifecycle has three states:
- **`active`** — change is being developed (propose, apply phases). Set at change creation.
- **`review`** — implementation verified, PR under review. Set when audit.md passes (same step that flips spec `draft → stable`).
- **`completed`** — PR merged, change finished. Set by the review action after successful merge.

A change is considered **active** if its `proposal.md` has `status: active` or has no `status` field (legacy/early pipeline). A change is considered **in review** if its `proposal.md` has `status: review`. A change is considered **completed** if its `proposal.md` has `status: completed`.

**Fallback** (for proposals without frontmatter): A change is active if its `tasks.md` contains at least one unchecked item (`- [ ]`) or if `tasks.md` does not exist. A change is completed if its `tasks.md` exists and all items are checked (`- [x]`).

Actions that operate on active changes (propose, apply) SHALL filter to active changes. Actions that operate on changes in review (finalize, review) SHALL filter to changes with `status: review` or `status: completed`. The review action SHALL also accept `status: review` changes (its primary input).

**User Story:** As a developer I want the system to distinguish active from completed changes using structured metadata, so that detection is instant and does not require parsing task checkboxes.

#### Scenario: Active change detected via proposal status

- **GIVEN** a change at `.specshift/changes/2026-04-01-add-auth/` with `proposal.md` containing `status: active`
- **WHEN** `specshift apply` lists available changes
- **THEN** the change is shown as available for implementation

#### Scenario: Completed change detected via proposal status

- **GIVEN** a change at `.specshift/changes/2026-04-01-add-auth/` with `proposal.md` containing `status: completed`
- **WHEN** `specshift finalize` lists available changes
- **THEN** the change is included in changelog generation

#### Scenario: Change without proposal frontmatter falls back to tasks.md

- **GIVEN** a change at `.specshift/changes/2026-03-01-legacy/` with `proposal.md` without YAML frontmatter
- **AND** `tasks.md` contains unchecked items
- **WHEN** `specshift apply` lists available changes
- **THEN** the change is shown as active (fallback to tasks.md parsing)

#### Scenario: Change without tasks.md is active

- **GIVEN** a change at `.specshift/changes/2026-04-01-add-auth/` with research.md and proposal.md (`status: active`) but no tasks.md
- **WHEN** `specshift propose` lists available changes
- **THEN** the change is shown as available for artifact generation

## Edge Cases

- **Date collision**: If two changes are created on the same day with the same name (e.g., after deleting and recreating), the system SHALL detect the existing directory and suggest continuing instead.
- **Proposal without frontmatter (legacy)**: The router SHALL fall back to tasks.md-based detection for active/completed status.
- **Multiple proposals match same branch**: If two change directories have proposals with the same `branch` value, skills SHALL use the most recently modified one and warn about the conflict.
- **Branch renamed after change creation**: The `branch` field in proposal.md reflects the branch at creation time. If the branch is renamed, the field becomes stale — change context detection falls through to the directory listing prompt.
- **Legacy `worktree:` frontmatter on existing proposals**: Proposals committed before this capability was simplified may still carry a `worktree: <path>` field. New proposals MUST NOT write the field, and skills SHALL ignore it on read.

## Assumptions

- The system clock provides the correct date for the YYYY-MM-DD prefix. <!-- ASSUMPTION: System clock accuracy -->

No further assumptions beyond those marked above.
