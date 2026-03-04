---
title: "Artifact Pipeline"
capability: "artifact-pipeline"
description: "Schema-driven 6-stage artifact pipeline with strict dependency gating"
order: 3
lastUpdated: "2026-03-04"
---

# Artifact Pipeline

The artifact pipeline guides every change through six structured stages — from research through to implementation tasks — ensuring no critical thinking step is skipped and every decision is documented.

## Why This Exists

The first workflow runs revealed that rules governing the pipeline were scattered across config.yaml, constitution, and schema with heavy redundancy. Fixing this established clean rule ownership: the schema owns universal workflow rules, the constitution owns project-specific rules, and config.yaml is just a bootstrap pointer.

## Background

Research into OpenSpec config.yaml confirmed that per-artifact `rules` provide targeted enforcement alongside global `context`. The schema's `instruction` fields are the correct location for rules that apply to all projects using the schema, such as the Definition of Done and post-apply workflow sequence.

## Features

- Six-stage pipeline: research, proposal, specs, design, preflight, tasks — in strict dependency order
- Automatic dependency gating prevents skipping stages
- Apply phase gated by task completion — implementation cannot start until all planning stages are done
- Config.yaml serves as minimal bootstrap (schema reference + constitution pointer)
- Schema owns universal workflow rules (DoD, post-apply sequence)

## Behavior

### Pipeline Stages

The pipeline enforces strict ordering: research first, then proposal, then specs, then design, then preflight, then tasks. Each stage produces a verifiable artifact file. No stage can be skipped — each must complete before the next can begin. An artifact is considered complete when its corresponding file exists and is non-empty.

### Dependency Gating

Before generating an artifact, the system checks that all required preceding artifacts are complete. If you try to generate specs before proposal is done, the system rejects the attempt and tells you what needs to be completed first.

### Apply Gate

Implementation (the apply phase) only begins after tasks.md exists and is non-empty. The apply phase tracks progress against the task checklist, marking items complete as implementation proceeds.

### Config Bootstrap

The `config.yaml` contains only a schema reference and a constitution pointer. All workflow rules live in the schema (for universal rules) or the constitution (for project-specific rules).

### Schema-Owned Workflow Rules

The schema's artifact instructions contain workflow rules that apply to all projects. The tasks instruction includes the Definition of Done rule, and the apply instruction includes the post-apply workflow sequence (`/opsx:verify` → `/opsx:archive` → `/opsx:changelog` → `/opsx:docs` → commit).

## Known Limitations

- Config.yaml does not contain workflow rules — if you need project-specific artifact rules, define them in the constitution.
- Reduced defense-in-depth: rules live in one authoritative place instead of being duplicated across layers.
- If an artifact file exists but is empty (0 bytes), it is treated as incomplete.

## Edge Cases

- If a project has no constitution, the config.yaml context pointer is harmless — the system notes the missing file and proceeds.
- Existing projects with workflow rules in config.yaml context continue to work — the rules are additive to schema instructions.
- If you manually delete an artifact file mid-pipeline, the system detects the gap and requires regeneration before proceeding.
- If the schema is modified to add a new artifact stage while a change is in progress, the new schema applies to new changes only — in-progress changes continue with the schema version active when they were created.
- If tasks.md contains no checkbox items (e.g., documentation-only change), the apply phase is still gated by tasks.md existence but reports that there are no implementation tasks.
- If multiple spec files are required (one per capability), the specs stage is not complete until all capability specs listed in the proposal have been generated.
