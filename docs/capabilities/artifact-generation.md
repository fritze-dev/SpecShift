---
title: "Artifact Generation"
capability: "artifact-generation"
description: "Step-by-step and fast-forward commands for generating pipeline artifacts, with smart checkpoints at critical transitions."
lastUpdated: "2026-03-23"
---

# Artifact Generation

The `/opsx:continue` and `/opsx:ff` commands generate the six pipeline artifacts (research, proposal, specs, design, preflight, tasks) that drive every change through the OpenSpec workflow.

## Purpose

Without dedicated generation commands, you would need to manually create each pipeline artifact, figure out the correct order, and remember which ones are already done. Artifact generation provides two approaches -- incremental and fast-forward -- so you can choose the level of control that fits the complexity of your change.

## Rationale

Two commands serve complementary use cases: `/opsx:continue` generates artifacts incrementally, while `/opsx:ff` generates all remaining artifacts in sequence for straightforward changes. Both commands are thin wrappers around the OpenSpec CLI rather than embedding pipeline logic directly, so updating the schema automatically updates generation behavior. A checkpoint model classifies each pipeline transition as either routine (auto-continue without pausing) or critical (mandatory pause for your input). Routine transitions -- such as research to proposal, or specs to design -- proceed automatically because no user decision is needed. Critical transitions pause at two points: after the design artifact for approach review, and after a preflight that returns warnings for explicit acknowledgment. This reduces friction at obvious steps while ensuring you always review the moments that matter most.

## Features

- **Step-by-step generation** with `/opsx:continue` -- advances the pipeline, auto-continuing through routine transitions and pausing at critical checkpoints
- **Fast-forward generation** with `/opsx:ff` -- generates all remaining artifacts in dependency order with pauses at critical checkpoints
- **Dependency gating** -- always respects the pipeline order (research, proposal, specs, design, preflight, tasks)
- **Design review checkpoint** -- both commands pause after the design artifact for user alignment before continuing
- **Preflight warnings checkpoint** -- `/opsx:ff` pauses when preflight returns warnings, requiring your explicit acknowledgment before generating tasks
- **Thin CLI wrappers** -- both skills query the OpenSpec CLI for status and instructions rather than duplicating logic

## Behavior

`/opsx:continue` and `/opsx:ff` cover different parts of the same pipeline. Use `/opsx:continue` when you want to review each artifact before moving on. Use `/opsx:ff` when you trust the pipeline to handle the full sequence, with pauses at critical checkpoints.

### Step-by-Step Generation (/opsx:continue)

When you run `/opsx:continue`, the system checks which artifacts already exist and generates the next one in the pipeline. At routine transitions (research to proposal, proposal to specs, specs to design, preflight to tasks), it auto-continues to the next artifact without pausing. At critical checkpoints -- after design generation and after preflight with warnings -- it pauses and waits for your input. After generation, it reports what was created and what comes next. If all artifacts are already complete, it tells you the pipeline is finished and suggests proceeding to `/opsx:apply`.

### Dependency Gating (/opsx:continue)

The pipeline enforces strict ordering. If an earlier artifact is missing (for example, the proposal was deleted), `/opsx:continue` generates that artifact first rather than skipping ahead.

### Pipeline Complete (/opsx:continue)

When all six artifacts have been generated, running `/opsx:continue` informs you that nothing remains and suggests running `/opsx:apply` to begin implementation.

### Fast-Forward from Any State (/opsx:ff)

Running `/opsx:ff` identifies all pending artifacts and generates them sequentially. If only research is complete, it generates the remaining five. If research, proposal, and specs are done, it generates design, preflight, and tasks.

### Fast-Forward Respects Dependency Order (/opsx:ff)

Even when generating multiple artifacts, `/opsx:ff` follows strict pipeline order and does not attempt parallel generation.

### Design Review Checkpoint

After generating or encountering the design artifact, both `/opsx:continue` and `/opsx:ff` pause for user alignment before proceeding to preflight. This checkpoint gives you the opportunity to review the approach and architecture decisions while feedback is still inexpensive.

### Preflight Warnings Checkpoint (/opsx:ff)

When preflight returns a verdict of PASS WITH WARNINGS during a fast-forward run, the system pauses and presents the warnings to you. It requires your explicit acknowledgment before generating the tasks artifact. If you want to address a warning, the system pauses the fast-forward and allows you to fix the issue before continuing.

### Checkpoint Skipped on Resume (/opsx:ff)

If you resume `/opsx:ff` on a workspace where preflight already exists, the design review checkpoint is skipped -- preflight existence implies prior design review.

### Pipeline Already Complete (/opsx:ff)

If all artifacts are done, `/opsx:ff` reports that nothing remains and suggests `/opsx:apply`.

### Skill Delivery

Both `/opsx:continue` and `/opsx:ff` are delivered as skill files that wrap the OpenSpec CLI. They query the CLI for current status and next artifact instructions rather than hardcoding artifact names or pipeline logic. Both are model-invocable.

## Edge Cases

- If the OpenSpec CLI returns an error during generation (for example, schema not found), the skill reports the error and halts rather than producing a malformed artifact.
- If `/opsx:continue` is run when no active change exists, the system instructs you to create one first via `/opsx:new`.
- If `/opsx:ff` encounters an error mid-pipeline, it stops, reports the error and the last successfully generated artifact, and does not attempt subsequent stages.
- If you modify an artifact file manually after generation, subsequent `/opsx:continue` calls treat it as complete and move to the next stage.
- If multiple capabilities are listed in the proposal, the specs stage generates one spec file per capability before marking the stage as complete.
- If you provide feedback at the design review checkpoint indicating misalignment, the agent incorporates the feedback by regenerating affected artifacts before proceeding.
- If preflight returns PASS WITH WARNINGS during a fast-forward and you reject or want to address a warning, the system pauses and allows you to fix the issue before regenerating preflight and continuing.
