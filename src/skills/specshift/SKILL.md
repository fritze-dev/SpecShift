---
name: specshift
description: |
  Central workflow command. Use with action argument: init (setup project), propose (create change + artifacts), apply (implement + verify), finalize (changelog + docs + version), review (PR review + merge). Example: specshift propose
  TRIGGER when: user asks to implement, build, code, or apply changes; user exits plan mode and wants to start coding; a change proposal or tasks.md exists and implementation is requested; user says 'make it', 'build this', 'implement', 'apply', 'start coding', or similar implementation intent.
  DO NOT TRIGGER when: user is asking questions, reading files, exploring code, running read-only commands, or discussing design without requesting implementation.
---

# Workflow

Central orchestration for the spec-driven workflow. The first argument determines the action: `init`, `propose`, `apply`, `finalize`, or `review`.

**Input**: `specshift <action> [arguments]`

## Load Configuration

Read `.specshift/WORKFLOW.md` once. Extract from YAML frontmatter:
- `templates_dir`, `pipeline`, `actions` (array of action names), `auto_approve`, `plugin-version`, `review`

Read from markdown body:
- `## Context` section — follow its instructions (typically: read CONSTITUTION.md)
- `## Action: <name>` sections — each contains `### Instruction` (procedural guidance for the action)

If WORKFLOW.md is missing: note it and fall back to built-in defaults (`actions: [init, propose, apply, finalize, review]`).

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

For `propose`, `apply`, `finalize`, `review`:
1. Get current branch: `git rev-parse --abbrev-ref HEAD`
2. **Proposal frontmatter lookup**: Scan `.specshift/changes/*/proposal.md` for a proposal whose YAML frontmatter `branch` field matches the current branch. If found, auto-select that change.
3. If detected: announce "Detected change context: using change '<name>'"
4. If not detected and action is `apply`: list changes with `status: active` and ask the user to select.
4b. If not detected and action is `finalize` or `review`: list changes with `status: review` and ask the user to select.
5. If not detected and action is `propose`: the user may be starting a new change — proceed to propose dispatch which handles workspace creation.

## Dispatch

For built-in actions: read the compiled requirements file at `actions/<action>.md` (relative to this skill). Use the `### Instruction` from the `## Action: <name>` section (already loaded during Load Configuration) as primary directive, bounded by the compiled requirements.

### `propose` — Pipeline Traversal

1. Read only the change artifacts named by the next stage's `requires:` chain (from the Smart Template frontmatter at `<templates_dir>/changes/<id>.md`). Do not pre-load the entire change directory.
2. Execute the action using the `### Instruction` (from Load Configuration) as your primary directive, bounded by the strict requirements extracted in `actions/propose.md`.
3. For each step in `pipeline` array: read Smart Template at `<templates_dir>/changes/<id>.md`, check artifact status, generate if ready. When generating an artifact, honor that template's `requires:` field as the read-context contract — read those artifacts and the specs the stage explicitly needs, nothing more.
4. **After each artifact**, commit and push:
   - Stage the change artifacts and specs
   - Commit with message `specshift(<change-name>): <artifact-id>`
   - Push to remote
   - On first push (no PR exists): Create a draft PR titled `<Change Name>` with body from the proposal's Why section (or `<change-name>` if proposal not yet generated) using available GitHub tooling (gh CLI, MCP tools, or API)
   - Skip PR creation if no GitHub tooling is available. Continue on push failure.
5. Follow the checkpoint behavior, workspace creation, and pipeline gates defined in the requirements.
6. **Auto-dispatch to apply**: If `auto_approve` is `true` (from Load Configuration) and propose completed successfully (all pipeline artifacts generated, no BLOCKED preflight), automatically dispatch the next stage by running `specshift apply` using the same change context. Do NOT pause — proceed directly.

### `apply` — Implementation

1. Read proposal.md (for capabilities and scope), design.md (for architecture and success metrics), tasks.md, and the affected specs identified by `proposal.md` frontmatter `capabilities:` (`new`, `modified`, `removed`). Do NOT read preflight, audit, or unrelated change artifacts during apply.
2. Execute the action using the `### Instruction` (from Load Configuration) as your primary directive, bounded by the strict requirements extracted in `actions/apply.md`. Use the change directory and artifact paths for context.
3. Implement tasks, generate audit.md, run the QA loop
4. **Auto-dispatch to finalize**: If `auto_approve` is `true` and audit.md verdict is PASS (no CRITICAL, no WARNING), automatically dispatch the next stage by running `specshift finalize` using the same change context. Pass the affected capability list (from proposal frontmatter `capabilities:`) to finalize so it can scope its work. Do NOT pause for user approval — proceed directly.

### `finalize` — Post-Approval

1. Receive the affected capability list from the dispatching action (apply) — the list comes from `proposal.md` frontmatter `capabilities:`. Read only proposal.md, design.md, audit.md, and the spec files for the listed capabilities. Do NOT scan all historical changes or read every spec.
2. Execute the action using the `### Instruction` (from Load Configuration) bounded by the strict requirements in `actions/finalize.md`. ADR generation is conditional on design.md frontmatter `has_decisions: true`. Capability-doc regeneration is restricted to the capabilities passed in.
3. **Auto-dispatch to review**: If `auto_approve` is `true` and finalize completed successfully, and `review` is listed in the `actions` array (from Load Configuration), automatically dispatch by running `specshift review` using the same change context. If `review` is not in the `actions` array, stop after finalize.

### `review` — PR Review-to-Merge Lifecycle

1. Read change artifacts for context (proposal, audit.md, PR state via available GitHub tooling)
2. Execute the action using the `### Instruction` (from Load Configuration) as your primary directive, bounded by the strict requirements extracted in `actions/review.md`. Read the `review` configuration from WORKFLOW.md frontmatter for `request_review` settings.

### `init` — Project Setup

1. If WORKFLOW.md missing: this IS the fresh install — proceed with default init behavior
2. Execute the action using the `### Instruction` (from Load Configuration) bounded by the strict requirements in `actions/init.md`.

### Custom Action — Direct Execution

For any action not listed above (propose, apply, finalize, init, review):
1. Read all change artifacts for context (all files in change directory)
2. Use the `## Action: <name>` instruction (already loaded during Load Configuration)
3. If the `## Action: <name>` section was not found during Load Configuration: report the error and stop
4. Execute the instruction directly with change directory context
5. No spec requirements are loaded (custom actions are self-contained via their instruction)

## Sub-Agent Dispatch

The router MAY use sub-agent dispatch to execute pipeline stages with bounded context. This is OPTIONAL — the router is also free to execute inline when sub-agent overhead would exceed the isolation benefit (e.g., trivial changes). When dispatched, each stage runs inside a sub-agent boundary that provides context isolation.

The pattern (described in tool-agnostic terms — concrete spawning syntax depends on the host):

1. The router prepares a sub-agent prompt that:
   - Names the target action (e.g., `apply`, `finalize`) or pipeline stage (e.g., `proposal`, `design`).
   - Identifies the change directory.
   - Declares the read-context contract via the stage's `requires:` field (Smart Template frontmatter) and the action's documented context contract (apply: proposal + design + tasks + affected specs; finalize: proposal + design + audit + listed-capability specs; propose-internal stage generation: the next stage's `requires:` chain).
   - Declares the write contract via the stage's `generates:` field.
   - Instructs the sub-agent to invoke the workflow skill on that bounded context.
2. The router SHALL NOT pre-load artifact bodies into the sub-agent prompt — the sub-agent reads only what its declared contract names.
3. The sub-agent executes the action and returns a completion report. The router records the result and, where appropriate, auto-dispatches the next stage.

This pattern applies to:
- **`apply`** — implementation with the apply context contract.
- **`finalize`** — capability-scoped finalization receiving the capability list from apply.
- **propose-internal stage generation** — each pipeline stage executes inside its own sub-agent boundary, honoring the stage's `requires:`/`generates:` contract.

The proven model is the `review` action's self-check: a sub-agent prompt that invokes the `review` skill on the current HEAD, with the boundary providing context isolation. Pipeline-stage dispatch follows the same shape.

The router MAY use sub-agent dispatch but is not required to. Templates and instructions describe intent; they do not enforce a specific execution mode. Hosts that lack a sub-agent primitive can execute the same instructions inline and remain conformant.

## Guardrails

- WORKFLOW.md is loaded once during Load Configuration — do not re-read it in later steps
- Change Context Detection runs ONCE, shared across all actions
- Plugin version check is advisory — never block an action due to version mismatch
- Implementation agents receive bounded context — NOT the full conversation history
- If WORKFLOW.md is missing and action is not `init`: stop and suggest running the specshift skill with `init`
- For `propose`: do NOT create artifacts yet if the user hasn't confirmed what they want to build
- For `apply`: delete audit.md at start of implementation to prevent stale audits
