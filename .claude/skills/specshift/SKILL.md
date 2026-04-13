---
name: specshift
description: Central workflow command. Use with action argument: init (setup project), propose (create change + artifacts), apply (implement + verify), finalize (changelog + docs + version). Example: specshift propose
---

# Workflow

Central orchestration for the spec-driven workflow. The first argument determines the action: `init`, `propose`, `apply`, or `finalize`.

**Input**: `specshift <action> [arguments]`

## Step 1: Identify Action

Parse the first argument to determine which action to run. Read the `actions` array from WORKFLOW.md frontmatter to determine valid actions. If WORKFLOW.md is missing, fall back to built-in actions: `init`, `propose`, `apply`, `finalize`.

If no action provided or unrecognized: list available actions from the array and ask the user to choose.

## Step 2: Load WORKFLOW.md

Read `.specshift/WORKFLOW.md`. Extract from YAML frontmatter:
- `templates_dir`, `pipeline`, `actions` (array of action names), `worktree`, `auto_approve`

Read from markdown body:
- `## Context` section — follow its instructions (typically: read CONSTITUTION.md)
- `## Action: <name>` sections — each contains `### Instruction` (procedural guidance for the action)

If WORKFLOW.md is missing and action is not `init`, tell the user to run the specshift skill with `init` first and stop.

## Step 3: Change Context Detection

**Skip for `init`** — init operates at project level, not change level.

For `propose`, `apply`, `finalize`:
1. Get current branch: `git rev-parse --abbrev-ref HEAD`
2. **Proposal frontmatter lookup**: Scan `.specshift/changes/*/proposal.md` for a proposal whose YAML frontmatter `branch` field matches the current branch. If found, auto-select that change.
3. **Fallback — worktree convention**: If no matching proposal, check if inside a worktree (`git rev-parse --git-dir` contains `/worktrees/`), derive change name from branch, search for `.specshift/changes/*-<branch-name>/`.
4. If detected: announce "Detected change context: using change '<name>'"
5. If not detected and action is `apply` or `finalize`: list active changes and ask the user to select.
6. If not detected and action is `propose`: the user may be starting a new change — proceed to propose dispatch which handles workspace creation.

## Step 4: Load Action Context

For built-in actions (propose, apply, finalize, init): read the compiled action file at `actions/<action>.md` (relative to this skill). This file contains the pre-extracted instruction and requirements. If the compiled file is missing, abort with: "Compiled action file missing. Run `bash scripts/compile-skills.sh` to generate it."

For custom actions: read the `## Action: <name>` instruction from WORKFLOW.md directly.

The sections below define which spec requirements belong to each built-in action. They are used by the AOT compiler (`scripts/compile-skills.sh`) to generate compiled action files — they are NOT resolved at runtime.

### Action: propose — Requirements

- [Propose as Single Entry Point for Pipeline Traversal](docs/specs/artifact-pipeline.md#requirement-propose-as-single-entry-point-for-pipeline-traversal)
- [Eight-Stage Pipeline](docs/specs/artifact-pipeline.md#requirement-eight-stage-pipeline)
- [Artifact Dependencies](docs/specs/artifact-pipeline.md#requirement-artifact-dependencies)
- [Post-Artifact Commit and PR Integration](docs/specs/artifact-pipeline.md#requirement-post-artifact-commit-and-pr-integration)
- [Create Change Workspace](docs/specs/change-workspace.md#requirement-create-change-workspace)
- [Create Worktree-Based Workspace](docs/specs/change-workspace.md#requirement-create-worktree-based-workspace)
- [Lazy Worktree Cleanup at Change Creation](docs/specs/change-workspace.md#requirement-lazy-worktree-cleanup-at-change-creation)
- [Change Context Detection](docs/specs/change-workspace.md#requirement-change-context-detection)

### Action: apply — Requirements

- [Implement Tasks from Task List](docs/specs/task-implementation.md#requirement-implement-tasks-from-task-list)
- [Progress Tracking](docs/specs/task-implementation.md#requirement-progress-tracking)
- [Standard Tasks Exclusion from Apply Scope](docs/specs/task-implementation.md#requirement-standard-tasks-exclusion-from-apply-scope)
- [Spec Edits During Implementation](docs/specs/task-implementation.md#requirement-spec-edits-during-implementation)
- [Apply Gate](docs/specs/artifact-pipeline.md#requirement-apply-gate)
- [Post-Implementation Commit Before Approval](docs/specs/artifact-pipeline.md#requirement-post-implementation-commit-before-approval)
- [Post-Implementation Verification](docs/specs/quality-gates.md#requirement-post-implementation-verification)
- [QA Loop with Mandatory Approval](docs/specs/human-approval-gate.md#requirement-qa-loop-with-mandatory-approval)
- [Fix Loop](docs/specs/human-approval-gate.md#requirement-fix-loop)
- [Active vs Completed Change Detection](docs/specs/change-workspace.md#requirement-active-vs-completed-change-detection)

### Action: finalize — Requirements

- [Generate Changelog from Completed Changes](docs/specs/release-workflow.md#requirement-generate-changelog-from-completed-changes)
- [Completion Workflow Next Steps](docs/specs/release-workflow.md#requirement-completion-workflow-next-steps)
- [Auto Patch Version Bump](docs/specs/release-workflow.md#requirement-auto-patch-version-bump)
- [Version Sync Between Plugin Files](docs/specs/release-workflow.md#requirement-version-sync-between-plugin-files)
- [Generate Enriched Capability Documentation](docs/specs/documentation.md#requirement-generate-enriched-capability-documentation)
- [Incremental Capability Documentation Generation](docs/specs/documentation.md#requirement-incremental-capability-documentation-generation)
- [Generate Architecture Overview](docs/specs/documentation.md#requirement-generate-architecture-overview)
- [Generate Documentation Table of Contents](docs/specs/documentation.md#requirement-generate-documentation-table-of-contents)
- [ADR Generation from Change Decisions](docs/specs/documentation.md#requirement-adr-generation-from-change-decisions)
- [Post-Merge Worktree Cleanup](docs/specs/change-workspace.md#requirement-post-merge-worktree-cleanup)

### Action: init — Requirements

- [Install Workflow](docs/specs/project-init.md#requirement-install-workflow)
- [Template Merge on Re-Init](docs/specs/project-init.md#requirement-template-merge-on-re-init)
- [First-Run Codebase Scan](docs/specs/project-init.md#requirement-first-run-codebase-scan)
- [Constitution Generation](docs/specs/project-init.md#requirement-constitution-generation)
- [Documentation Drift Verification](docs/specs/project-init.md#requirement-documentation-drift-verification-health-check)
- [Recovery Mode](docs/specs/project-init.md#requirement-recovery-mode-spec-drift-detection)
- [Constitution Update](docs/specs/constitution-management.md#requirement-constitution-update)
- [Preflight Quality Check](docs/specs/quality-gates.md#requirement-preflight-quality-check)

## Step 5: Dispatch

### `propose` — Pipeline Traversal

1. Read all change artifacts (if change exists) and the propose instruction from WORKFLOW.md
2. For each step in `pipeline` array: read Smart Template at `<templates_dir>/<id>.md`, check artifact status, generate if ready
3. **After each artifact**, commit and push:
   - Stage the change artifacts and specs
   - Commit with message `WIP: <change-name> — <artifact-id>`
   - Push to remote
   - On first push (no PR exists): Create a draft PR titled `<Change Name>` with body `WIP: <change-name>` using available GitHub tooling (gh CLI, MCP tools, or API)
   - Skip PR creation if no GitHub tooling is available. Continue on push failure.
4. Follow the instruction from `## Action: propose` for checkpoint behavior, workspace creation, and pipeline gates
5. **Auto-dispatch to apply**: If `auto_approve` is `true` in WORKFLOW.md frontmatter and propose completed successfully (all pipeline artifacts generated, no BLOCKED preflight), automatically dispatch the `apply` action using the same change context. Do NOT pause — proceed directly.

### `apply` — Implementation

1. Read all change artifacts (research, proposal, design, tasks, specs)
2. Execute the action using the compiled action context from `actions/apply.md` (instruction + pre-extracted requirements) and the change directory path and artifact paths
3. Implement tasks, generate review.md, run the QA loop
4. **Auto-dispatch to finalize**: If `auto_approve` is `true` and review.md verdict is PASS (no CRITICAL, no WARNING), automatically dispatch the `finalize` action using the same change context. Do NOT pause for user approval — proceed directly.

### `finalize` — Post-Approval

1. Read change artifacts for context (proposal, review.md)
2. Execute the action using the compiled action context from `actions/finalize.md`

### `init` — Project Setup

1. If WORKFLOW.md missing: this IS the fresh install — proceed with default init behavior
2. Execute the action using the compiled action context from `actions/init.md`

### Custom Action — Direct Execution

For any action not listed above (propose, apply, finalize, init):
1. Read all change artifacts for context (all files in change directory)
2. Read the `## Action: <name>` instruction from WORKFLOW.md
3. If the `## Action: <name>` section is missing: report the error and stop
4. Execute the instruction directly with change directory context
5. No spec requirements are loaded (custom actions are self-contained via their instruction)

## Guardrails

- Always read WORKFLOW.md before dispatching
- Change context detection runs ONCE, shared across all actions
- Implementation agents receive bounded context — NOT the full conversation history
- If WORKFLOW.md is missing and action is not `init`: stop and suggest running the specshift skill with `init`
- For `propose`: do NOT create artifacts yet if the user hasn't confirmed what they want to build
- For `apply`: delete review.md at start of implementation to prevent stale reviews
