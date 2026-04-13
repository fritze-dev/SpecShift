---
name: specshift
description: Central workflow command. Use with action argument: init (setup project), propose (create change + artifacts), apply (implement + verify), finalize (changelog + docs + version). Example: specshift propose
---

# Workflow

Central orchestration for the spec-driven workflow. The first argument determines the action: `init`, `propose`, `apply`, or `finalize`.

**Input**: `specshift <action> [arguments]`

## Load Configuration

Read `.specshift/WORKFLOW.md` once. Extract from YAML frontmatter:
- `templates_dir`, `pipeline`, `actions` (array of action names), `worktree`, `auto_approve`, `plugin-version`

Read from markdown body:
- `## Context` section — follow its instructions (typically: read CONSTITUTION.md)
- `## Action: <name>` sections — each contains `### Instruction` (procedural guidance for the action)

If WORKFLOW.md is missing: note it and fall back to built-in defaults (`actions: [init, propose, apply, finalize]`).

## Identify Action

Parse the first argument to determine which action to run. Validate against the `actions` array loaded during Load Configuration.

If no action provided or unrecognized: list available actions from the array and ask the user to choose.

If WORKFLOW.md was missing during Load Configuration and action is not `init`: tell the user to run the specshift skill with `init` first and stop.

## Plugin Version Check

**Skip for `init`** — init is how versions get updated.

1. Read the `plugin-version` field from the compiled workflow template at `templates/workflow.md` (relative to this skill). This contains the current plugin version, injected at compile time.
2. Read the `plugin-version` field from the project's WORKFLOW.md frontmatter loaded during Load Configuration.
3. Compare:
   - If either `plugin-version` is missing or empty: display "**Note:** Run `specshift init` to enable plugin version tracking."
   - If both match: proceed silently.
   - If they differ: display "**Plugin update available:** project installed with v{project-version}, current plugin is v{template-version}. Run `specshift init` to update."
4. If the compiled template cannot be read: skip the check silently.
5. In all cases, **continue** with the dispatched action — the check is advisory, not blocking.

## Change Context Detection

**Skip for `init`** — init operates at project level, not change level.

For `propose`, `apply`, `finalize`:
1. Get current branch: `git rev-parse --abbrev-ref HEAD`
2. **Proposal frontmatter lookup**: Scan `.specshift/changes/*/proposal.md` for a proposal whose YAML frontmatter `branch` field matches the current branch. If found, auto-select that change.
3. **Fallback — worktree convention**: If no matching proposal, check if inside a worktree (`git rev-parse --git-dir` contains `/worktrees/`), derive change name from branch, search for `.specshift/changes/*-<branch-name>/`.
4. If detected: announce "Detected change context: using change '<name>'"
5. If not detected and action is `apply` or `finalize`: list active changes and ask the user to select.
6. If not detected and action is `propose`: the user may be starting a new change — proceed to propose dispatch which handles workspace creation.

## Dispatch

For built-in actions: read the compiled requirements file at `actions/<action>.md` (relative to this skill). Use the `### Instruction` from the `## Action: <name>` section (already loaded during Load Configuration) as primary directive, bounded by the compiled requirements.

### `propose` — Pipeline Traversal

1. Read all change artifacts (if change exists).
2. Execute the action using the `### Instruction` (from Load Configuration) as your primary directive, bounded by the strict requirements extracted in `actions/propose.md`.
3. For each step in `pipeline` array: read Smart Template at `<templates_dir>/<id>.md`, check artifact status, generate if ready
4. **After each artifact**, commit and push:
   - Stage the change artifacts and specs
   - Commit with message `WIP: <change-name> — <artifact-id>`
   - Push to remote
   - On first push (no PR exists): Create a draft PR titled `<Change Name>` with body `WIP: <change-name>` using available GitHub tooling (gh CLI, MCP tools, or API)
   - Skip PR creation if no GitHub tooling is available. Continue on push failure.
5. Follow the checkpoint behavior, workspace creation, and pipeline gates defined in the requirements.
6. **Auto-dispatch to apply**: If `auto_approve` is `true` (from Load Configuration) and propose completed successfully (all pipeline artifacts generated, no BLOCKED preflight), automatically dispatch the next stage by running `specshift apply` using the same change context. Do NOT pause — proceed directly.

### `apply` — Implementation

1. Read all change artifacts (research, proposal, design, tasks, specs)
2. Execute the action using the `### Instruction` (from Load Configuration) as your primary directive, bounded by the strict requirements extracted in `actions/apply.md`. Use the change directory and artifact paths for context.
3. Implement tasks, generate review.md, run the QA loop
4. **Auto-dispatch to finalize**: If `auto_approve` is `true` and review.md verdict is PASS (no CRITICAL, no WARNING), automatically dispatch the next stage by running `specshift finalize` using the same change context. Do NOT pause for user approval — proceed directly.

### `finalize` — Post-Approval

1. Read change artifacts for context (proposal, review.md)
2. Execute the action using the `### Instruction` (from Load Configuration) bounded by the strict requirements in `actions/finalize.md`.

### `init` — Project Setup

1. If WORKFLOW.md missing: this IS the fresh install — proceed with default init behavior
2. Execute the action using the `### Instruction` (from Load Configuration) bounded by the strict requirements in `actions/init.md`.

### Custom Action — Direct Execution

For any action not listed above (propose, apply, finalize, init):
1. Read all change artifacts for context (all files in change directory)
2. Use the `## Action: <name>` instruction (already loaded during Load Configuration)
3. If the `## Action: <name>` section was not found during Load Configuration: report the error and stop
4. Execute the instruction directly with change directory context
5. No spec requirements are loaded (custom actions are self-contained via their instruction)

## Guardrails

- WORKFLOW.md is loaded once during Load Configuration — do not re-read it in later steps
- Change Context Detection runs ONCE, shared across all actions
- Plugin version check is advisory — never block an action due to version mismatch
- Implementation agents receive bounded context — NOT the full conversation history
- If WORKFLOW.md is missing and action is not `init`: stop and suggest running the specshift skill with `init`
- For `propose`: do NOT create artifacts yet if the user hasn't confirmed what they want to build
- For `apply`: delete review.md at start of implementation to prevent stale reviews
