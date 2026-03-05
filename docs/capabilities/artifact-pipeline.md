---
title: "Artifact Pipeline"
capability: "artifact-pipeline"
description: "Schema-driven 6-stage artifact pipeline with dependency gating"
lastUpdated: "2026-03-05"
---

# Artifact Pipeline

The artifact pipeline defines a strict 6-stage progression from research through to implementation tasks. Each stage produces a verifiable artifact, and no stage can be skipped -- the system enforces dependency order so that every decision is documented before implementation begins.

## Purpose

Without a structured pipeline, critical thinking steps get skipped -- developers jump straight to code without researching alternatives, writing specs, or checking for gaps. The pipeline enforces a deliberate progression that catches problems early, when they are cheapest to fix, rather than during implementation or after release.

## Rationale

Artifact completion is determined by file existence and non-empty content rather than content quality assessment. This keeps the gating mechanism simple and predictable. The config.yaml is deliberately minimal (just a schema reference and constitution pointer) so that workflow rules live at their authoritative source: the schema for universal rules and the constitution for project-specific rules.

## Features

- Six stages in strict order: research, proposal, specs, design, preflight, tasks
- Dependency gating prevents skipping stages
- Each stage produces a verifiable artifact file
- Implementation (apply phase) is gated by task completion
- Schema-declared dependencies enforced by the OpenSpec CLI
- Minimal config.yaml bootstrap -- workflow rules owned by schema and constitution

## Behavior

### Pipeline Progression

The six stages execute in strict dependency order: research has no dependencies, proposal requires research, specs requires proposal, design requires specs, preflight requires design, and tasks requires preflight. You progress through the pipeline using `/opsx:continue` (one stage at a time) or `/opsx:ff` (all remaining stages).

### Dependency Enforcement

Before generating any artifact, the system checks that all prerequisite artifacts are complete. An artifact is considered complete when its file exists and is non-empty. If you try to generate specs before the proposal is done, the system rejects the attempt and tells you what needs to be completed first.

### Apply Gate

The implementation phase (`/opsx:apply`) cannot begin until tasks.md exists and is non-empty. Once the apply phase starts, it works through the task checklist, marking items complete as implementation proceeds.

### Multi-Capability Specs

If your proposal lists multiple capabilities, the specs stage is not considered complete until a spec file has been generated for each capability listed in the proposal.

## Known Limitations

- Artifact completion is based on file existence, not content quality -- an artifact with minimal content still satisfies the dependency check
- If the schema is modified while a change is in progress, the change continues with the schema version active when it was created

## Edge Cases

- If an artifact file exists but is empty (0 bytes), the system treats it as incomplete.
- If you manually delete an artifact file mid-pipeline, the system detects the gap and requires regeneration before proceeding.
- If tasks.md contains no checkbox items (e.g., documentation-only change), the apply phase is still gated by tasks.md existence but reports that there are no implementation tasks.
