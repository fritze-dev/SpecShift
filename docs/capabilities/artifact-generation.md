---
title: "Artifact Generation"
capability: "artifact-generation"
description: "Step-by-step and fast-forward commands for generating pipeline artifacts"
order: 4
lastUpdated: "2026-03-05"
---

# Artifact Generation

Generate pipeline artifacts one at a time with `/opsx:continue` or all at once with `/opsx:ff`. Both commands wrap the OpenSpec CLI, so updating the schema automatically updates generation behavior.

## Why This Exists

The artifact pipeline needs user-facing commands to advance through its stages. `/opsx:continue` gives you control to review each artifact before moving on, while `/opsx:ff` lets you generate everything in one command with a mandatory review checkpoint after design — ensuring you review the approach before the system proceeds to quality checks and task creation.

## Features

- Step-by-step generation with `/opsx:continue` — advance one artifact at a time for review between stages
- Fast-forward generation with `/opsx:ff` — generate all remaining artifacts with a review checkpoint after design
- Automatic dependency ordering — stages are never skipped or generated out of order
- Progress reporting after each generation step
- Thin CLI wrappers — schema updates automatically change generation behavior without skill changes

## Behavior

### Step-by-Step Generation

When you run `/opsx:continue`, the system determines which artifact is next in the pipeline, generates exactly that one artifact, then reports what was generated and what the next step is. If all artifacts are already complete, it suggests proceeding to `/opsx:apply`.

The system respects dependency gating. If a required predecessor is missing (e.g., manually deleted), it generates that artifact rather than skipping ahead.

### Fast-Forward Generation

When you run `/opsx:ff`, the system generates artifacts in two phases. First, it generates all planning artifacts (research through design) in dependency order. Then it pauses at a mandatory review checkpoint, presenting what was generated and asking you to confirm alignment before continuing. After you confirm, it generates the execution artifacts (preflight and tasks). If all artifacts are already complete, it suggests `/opsx:apply`.

Fast-forward never generates stages in parallel — it follows strict dependency order.

### Review Checkpoint

After generating the design artifact (or detecting it is already complete), `/opsx:ff` pauses and presents a review summary. You review the specs and design, then confirm alignment to continue. If you provide feedback, the affected artifacts are regenerated before proceeding. If you resume `/opsx:ff` on a change where preflight is already complete, the checkpoint is skipped.

### Resuming with Partial Progress

If some artifacts are already complete, both commands skip completed stages and generate only what remains. If you manually edit an artifact file after generation, subsequent commands treat it as complete and move to the next stage.

## Edge Cases

- If the OpenSpec CLI returns an error during generation (e.g., schema not found), the error is reported and generation halts rather than producing a malformed artifact.
- If `/opsx:continue` is run when no active change exists, you are instructed to create a change first via `/opsx:new`.
- If `/opsx:ff` encounters an error mid-pipeline (e.g., fails on the design artifact), it stops, reports the error and the last successfully generated artifact, and does not attempt subsequent stages.
- If you provide feedback at the review checkpoint indicating misalignment, the affected artifacts are regenerated before the checkpoint is re-presented.
- If multiple capabilities are listed in the proposal, the specs stage generates one spec file per capability before marking the stage as complete.
