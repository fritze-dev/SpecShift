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

1. Read the `## Action: <action>` section from WORKFLOW.md body for the `### Instruction`.
2. For built-in actions (propose, apply, finalize, init): read the compiled requirements file at `actions/<action>.md` (relative to this skill). If the compiled file is missing, abort with: "Compiled requirements file missing. Run `bash scripts/compile-skills.sh` to generate it."
3. For custom actions: no compiled requirements — the instruction from WORKFLOW.md is self-contained.

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
