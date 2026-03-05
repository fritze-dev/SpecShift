---
title: "Artifact Generation"
capability: "artifact-generation"
description: "Step-by-step and fast-forward artifact generation commands"
lastUpdated: "2026-03-05"
---

# Artifact Generation

This capability provides two commands for generating pipeline artifacts: `/opsx:continue` for one stage at a time, and `/opsx:ff` for generating all remaining stages with a built-in review checkpoint.

## Why This Exists

Different situations call for different levels of control. Sometimes you want to review each artifact individually before moving on; other times you trust the pipeline and want to reach implementation quickly. Without both options, you would either be forced to babysit every step or lose the ability to review at critical points.

## Design Rationale

Both commands are delivered as thin SKILL.md wrappers around the OpenSpec CLI. This means updating the schema automatically updates generation behavior without changing skill files. The review checkpoint in `/opsx:ff` was placed after the design stage because that is the last point where the approach can be changed cheaply before quality checks and task creation commit to a direction.

## Features

- `/opsx:continue` generates the next pending artifact in the pipeline
- `/opsx:ff` generates all remaining artifacts with a mandatory review checkpoint after design
- Both commands respect dependency gating and generate in strict order
- Reports what was generated and what the next step is
- Handles partially completed pipelines by resuming from the current state
- Review checkpoint allows feedback and artifact regeneration before proceeding

## Behavior

### Step-by-Step Generation (/opsx:continue)

When you run `/opsx:continue`, the system determines which artifact is next, generates it, and reports what was created and what comes next. If all artifacts are already complete, it tells you the pipeline is finished and suggests `/opsx:apply`.

### Fast-Forward Generation (/opsx:ff)

When you run `/opsx:ff`, the system generates all remaining artifacts in two phases:

1. **Planning phase**: Generates artifacts up to and including design (research, proposal, specs, design as needed)
2. **Review checkpoint**: Pauses for you to review the specs and design and confirm alignment
3. **Execution phase**: After you confirm, generates preflight and tasks

If you provide feedback at the checkpoint indicating misalignment, the system incorporates your feedback by regenerating affected artifacts before re-presenting the checkpoint.

### Resuming a Partial Pipeline

Both commands handle partially completed pipelines gracefully. If research and proposal are already done, `/opsx:continue` generates specs next. If you resume `/opsx:ff` when preflight is already complete, the review checkpoint is skipped since you have already reviewed past the design phase.

### Multiple Capabilities

If the proposal lists multiple capabilities, the specs stage generates one spec file per capability before marking the stage as complete.

## Edge Cases

- If the OpenSpec CLI returns an error during generation (e.g., schema not found), the system reports the error and halts rather than producing a malformed artifact.
- If no active change exists when you run `/opsx:continue`, the system tells you to create one with `/opsx:new`.
- If `/opsx:ff` encounters an error mid-pipeline, it stops, reports the error and the last successfully generated artifact, and does not attempt subsequent stages.
- If you manually edit an artifact file after generation, subsequent `/opsx:continue` calls treat it as complete and move to the next stage.
