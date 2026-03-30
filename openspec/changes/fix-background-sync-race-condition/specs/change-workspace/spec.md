## MODIFIED Requirements

### Requirement: Archive Completed Change

The system SHALL move a completed change workspace to `openspec/changes/archive/` with a date-prefixed directory name in the format `YYYY-MM-DD-<change-name>` when the user invokes `/opsx:archive`. Before archiving, the system SHALL automatically sync delta specs to baseline specs if unsynced delta specs exist, showing a summary of applied changes. The system SHALL NOT prompt the user to choose between syncing and archiving. When sync is delegated to a subagent, the subagent prompt SHALL convey that sync is a blocking prerequisite for archive and that the result MUST be returned before the workflow continues. After the sync agent returns, the archive skill SHALL validate the sync result — confirming success or failure — before proceeding to the archive step. The system SHALL NOT proceed to archive without a validated sync result. If the archive target directory already exists, the system SHALL fail with an error and suggest a resolution.

**User Story:** As a developer I want completed changes archived with a date prefix and automatic spec sync, so that the project history is preserved chronologically and baseline specs stay up to date without unnecessary prompts.

#### Scenario: Archive a completed change

- **GIVEN** a change named "add-user-auth" with all artifacts and tasks complete
- **AND** no delta specs exist in the change
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system moves `openspec/changes/add-user-auth/` to `openspec/changes/archive/2026-03-02-add-user-auth/`
- **AND** displays a summary including change name, schema, and archive location

#### Scenario: Auto-sync before archiving

- **GIVEN** a change named "add-user-auth" with delta specs in `openspec/changes/add-user-auth/specs/`
- **AND** the delta specs have not been synced to baseline
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system SHALL invoke sync via a subagent whose prompt conveys that sync is a blocking prerequisite
- **AND** SHALL wait for the sync agent to return its result
- **AND** SHALL validate the result confirms successful sync
- **AND** SHALL display a summary of applied changes (additions, modifications, removals)
- **AND** SHALL proceed to archive only after validation passes

#### Scenario: Sync agent result validation prevents premature archive

- **GIVEN** a change with delta specs that require syncing
- **WHEN** the sync subagent is invoked during archive
- **AND** the agent returns a result
- **THEN** the archive skill SHALL inspect the result for confirmation of successful sync
- **AND** SHALL NOT proceed to the archive step (mv to archive directory) until validation passes

#### Scenario: Sync agent reports failure

- **GIVEN** a change with delta specs that require syncing
- **WHEN** the sync subagent returns a result indicating failure
- **THEN** the archive skill SHALL report the error to the user
- **AND** SHALL NOT proceed to archive

#### Scenario: Archive with incomplete artifacts

- **GIVEN** a change with some artifacts not marked as done
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system SHALL display a warning listing the incomplete artifacts
- **AND** SHALL ask the user to confirm before proceeding
- **AND** SHALL archive if the user confirms

#### Scenario: Archive target already exists

- **GIVEN** a change named "add-user-auth"
- **AND** an archive already exists at `openspec/changes/archive/2026-03-02-add-user-auth/`
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system SHALL fail with an error
- **AND** SHALL suggest renaming the existing archive or using a different date

#### Scenario: Archive with incomplete tasks

- **GIVEN** a change with a tasks.md containing 3 of 7 checkboxes marked complete
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system SHALL display a warning showing "3/7 tasks complete"
- **AND** SHALL ask the user to confirm before proceeding

## Edge Cases

- **Sync agent result is ambiguous:** If the sync agent result does not clearly indicate success or failure, the archive skill SHALL treat it as a failure and report the ambiguity to the user.

## Assumptions

No new assumptions.
