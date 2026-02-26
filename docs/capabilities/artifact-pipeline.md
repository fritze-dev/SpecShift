---
title: "Artifact Pipeline"
capability: "artifact-pipeline"
description: "6-stage pipeline (research through tasks) with strict dependency gating"
order: 4
lastUpdated: "2026-03-02"
---

# Artifact Pipeline

Every change follows a structured 6-stage pipeline: research, proposal, specs, design, preflight, and tasks. Each stage must complete before the next can begin, and implementation is gated by task completion.

## Features

- Structured pipeline guides you from research through to implementation tasks
- Strict dependency ordering prevents skipping critical thinking steps
- Every stage produces a verifiable artifact file
- Implementation cannot start until the full planning cycle is done

## Behavior

### Pipeline Stages

The stages execute in order: research (no dependencies), proposal (requires research), specs (requires proposal), design (requires specs), preflight (requires design), and tasks (requires preflight). You cannot skip a stage.

### Dependency Enforcement

Each artifact declares its dependencies in the schema. The OpenSpec CLI checks completion status before allowing generation. An artifact is considered complete when its file exists and is non-empty.

### Apply Gate

Implementation (the apply phase) only begins after tasks.md exists and is non-empty. As you work through tasks, each completed item is marked with `- [x]` in tasks.md.

## Edge Cases

- An empty file (0 bytes) does not satisfy dependency checks.
- If you manually delete an artifact mid-pipeline, the system detects the gap and requires regeneration.
- If the schema is modified while a change is in progress, the new schema applies to new changes only.
- If tasks.md contains no checkbox items (documentation-only change), the apply phase is still gated by tasks.md existence but reports no tasks to execute.
- If the proposal lists multiple capabilities, the specs stage is not complete until all capability specs are generated.
