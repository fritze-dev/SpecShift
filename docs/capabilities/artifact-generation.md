---
title: "Artifact Generation"
capability: "artifact-generation"
description: "Step-by-step (/opsx:continue) and fast-forward (/opsx:ff) artifact creation"
order: 5
lastUpdated: "2026-03-02"
---

# Artifact Generation

Use `/opsx:continue` to advance the pipeline one step at a time, or `/opsx:ff` to generate all remaining artifacts in one go. Both commands wrap the OpenSpec CLI.

## Features

- Advance the pipeline one artifact at a time with `/opsx:continue` for review between stages
- Generate all remaining artifacts at once with `/opsx:ff` when you trust the pipeline
- Both commands respect dependency gating and skip already-completed stages
- Delivered as thin SKILL.md wrappers around the OpenSpec CLI

## Behavior

### Step-by-Step with /opsx:continue

Running `/opsx:continue` generates exactly one artifact — the next one in the pipeline. After generation, it reports what was created and what comes next. If all artifacts are complete, it suggests `/opsx:apply`.

### Fast-Forward with /opsx:ff

Running `/opsx:ff` generates all remaining artifacts in dependency order without pausing. It skips already-completed stages and reports a summary of everything generated. If all artifacts are already complete, it suggests `/opsx:apply`.

### Dependency Respect

Both commands query the OpenSpec CLI for current status. If an artifact is missing mid-pipeline (e.g., manually deleted), the commands regenerate it before proceeding to later stages.

## Edge Cases

- If the OpenSpec CLI returns an error during generation, the skill reports it and halts.
- If no active change exists, the system tells you to create one with `/opsx:new`.
- If `/opsx:ff` encounters an error mid-pipeline, it stops and reports the last successfully generated artifact.
- If you manually edit an artifact after generation, subsequent calls treat it as complete and move on.
- If the proposal lists multiple capabilities, the specs stage generates one file per capability.
