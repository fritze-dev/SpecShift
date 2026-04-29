---
title: "Artifact Pipeline"
capability: "artifact-pipeline"
description: "Six-stage artifact pipeline with dependency gating, artifact frontmatter, semantic heading discipline, consolidation checks, and incremental PR integration"
lastUpdated: "2026-04-29"
---

# Artifact Pipeline

The artifact pipeline guides every change through the canonical stages -- proposal, specs, design, preflight, tasks, and audit -- enforcing strict dependency order so that no stage is skipped and implementation is gated by complete planning. Stage names are the single source of truth; counts are not duplicated in prose. Discovery work (current state analysis, approaches, coverage assessment, decisions) lives as a fixed Discovery block inside `proposal.md`. Apply-phase test generation, driven by Constitution § Testing, replaces the standalone tests stage. Key artifacts include YAML frontmatter for machine-readable metadata. Every artifact is committed incrementally using `specshift(<change-name>): <artifact-id>` commit messages, with a draft pull request created automatically on the first commit.

## Purpose

Development teams working with AI assistants need a structured process that prevents jumping straight to code without adequate research, design, and quality review. Without enforced stages, critical thinking steps get skipped, decisions go undocumented, and implementation begins before requirements are fully understood. Without machine-readable metadata in artifacts, downstream actions must parse markdown sections to extract structured data like affected capabilities or the presence of design decisions.

## Rationale

The pipeline uses WORKFLOW.md for declarative orchestration and Smart Templates for self-describing artifact definitions, so that the workflow structure is transparent and modifiable without touching command code. Discovery is preserved as a fixed Discovery block inside `proposal.md` rather than a separate research stage — Plan-mode planning accelerates discovery but does not replace it. Test generation moves to the apply phase: when Constitution § Testing declares a framework, the apply phase generates automated test stubs as part of implementation tasks; when "None" or absent, scenario verification happens directly in `audit.md`. Audit remains the final stage as a persistent, PR-visible verification artifact. Templates use semantic heading text rather than positional identifiers, so adding, removing, or reordering sections does not silently rot cross-references in other specs. Propose serves as the single entry point for all pipeline traversal operations (workspace creation, checkpoint/resume, full lifecycle execution), eliminating the need for separate commands. The `auto_approve` configuration defaults to `true`, so pipeline traversal proceeds without user confirmation at checkpoints on success paths.

## Features

- **Six-Stage Pipeline** (`specshift propose`): Proposal, specs, design, preflight, tasks, and audit execute in strict dependency order. Each stage produces a verifiable artifact file. The stage list is the single source of truth — the count is derived, not hardcoded.
- **Discovery Inside Proposal**: Discovery work (Current State, External Research, Approaches, Coverage Assessment, Decisions) is captured as a fixed block inside `proposal.md` rather than a separate `research.md` artifact.
- **Apply-Phase Test Generation**: Tests are no longer a separate pipeline stage. Apply-phase test generation is driven by the project Constitution § Testing — automated tests when a framework is configured, direct scenario verification in audit otherwise.
- **Backward Compatibility for Legacy Changes**: Legacy change directories that contain `research.md` and/or `tests.md` from the previous pipeline retain their structure. Tooling that reads change artifacts (capability doc enrichment, audit cross-checks) handles both shapes without requiring migration.
- **Semantic Heading Structure in Pipeline Artifact Templates**: Smart Templates and the artifacts they produce use semantic heading text without leading numerical (`## 1. ...`) or alphabetic (`## A. ...`) prefixes. Cross-references in other specs use the section's heading text rather than a positional identifier.
- **Artifact Output Frontmatter**: Proposals include `status`, `branch`, and `capabilities` (new/modified/removed). Designs include `has_decisions` (boolean). Actions prefer frontmatter over markdown parsing.
- **Explicit Dependency Declarations**: Each Smart Template declares its dependencies via a `requires` field. Dependencies are enforced by verifying file existence.
- **Apply Gate**: Implementation is gated by the tasks artifact. Apply cannot begin until `tasks.md` exists and is non-empty.
- **Propose as Single Entry Point**: `specshift propose` handles workspace creation, progress display, checkpoint/resume, and full artifact generation.
- **WORKFLOW.md-Owned Workflow Rules**: Action instructions contain the post-apply workflow sequence; tasks template carries the standard-tasks directive.
- **Incremental Commits with Draft PR**: After each artifact, the system commits with `specshift(<change-name>): <artifact-id>` and pushes. On the first commit, a feature branch and draft PR are created.
- **Post-Implementation Commit Before Approval**: After apply's auto-verify passes, the system commits implementation changes with `specshift(<change-name>): implementation` and pushes before pausing for user approval.
- **Standard Tasks in Every Task List**: The tasks template includes universal post-implementation steps. Constitution extras from `## Standard Tasks` are appended. Post-merge items are scope-aware.
- **Capability Granularity Guidance**: The proposal template defines what constitutes a capability versus a feature detail, with merging heuristics.
- **Mandatory Consolidation Check**: Before finalizing proposal capabilities, overlap with existing specs and pair-wise overlap between new capabilities are verified.

## Behavior

### Pipeline Stages Execute in Dependency Order (`specshift propose`)

When progressing through the pipeline, the system enforces the order: proposal, specs, design, preflight, tasks, audit. Attempting to skip a stage is rejected. A completed pipeline run produces `proposal.md`, one or more `docs/specs/<capability>.md` files, `design.md`, `preflight.md`, `tasks.md`, and `audit.md`.

### Discovery Lives Inside the Proposal

The proposal template's body includes Discovery sections — Current State, External Research, Approaches, Coverage Assessment, Decisions — populated during proposal generation. Plan-mode planning accelerates discovery; the Discovery block records the durable evidence and decisions.

### Test Generation Happens During Apply

When the project Constitution declares a test framework in `## Testing`, the apply phase generates automated test stubs in the configured test directory as part of implementation tasks (mapping GIVEN→arrange / WHEN→act / THEN→assert). When `## Testing` is absent or declares "None", the audit phase verifies each Gherkin scenario from the affected specs directly against the implementation. No standalone `tests.md` checklist is produced.

### Legacy Changes Retain Their Original Shape

Change directories created under the previous eight-stage pipeline keep their `research.md` and/or `tests.md` files. Capability-doc enrichment, audit cross-checks, and other tooling that reads change artifacts accept both the new shape (Discovery inside proposal.md) and the legacy shape.

### Auto-Approve Controls Pipeline Checkpoint Behavior

The `auto_approve` workflow configuration defaults to `true` in WORKFLOW.md frontmatter. When `true`, checkpoints are skipped on success paths. PASS WITH WARNINGS in preflight pauses for explicit acknowledgment regardless of `auto_approve`.

### Artifact Output Frontmatter

When the proposal is generated, it includes YAML frontmatter with `status: active`, `branch`, and `capabilities` (structured new/modified/removed lists). When the design is generated, it includes `has_decisions: true` if the Decisions section contains entries. Actions that scope finalize to affected capabilities read the proposal's `capabilities` frontmatter field.

### Dependency Checks Are Enforced via File Existence

Before generating any artifact, the system reads WORKFLOW.md and Smart Templates and checks that all required predecessors are complete. An artifact is considered complete when its file exists and is non-empty.

### Incremental Commits and Draft PR

After creating any artifact, the system commits and pushes. On the first artifact commit, the system creates a feature branch, commits, pushes, and creates a draft PR using available GitHub tooling. If no GitHub tooling is available, PR creation is skipped. The pipeline is never blocked by push or PR creation failures.

### Consolidation Check and Overlap Verification

The proposal template requires reviewing existing specs for domain overlap, checking pair-wise overlap between new capabilities, and verifying minimum requirement counts. The proposal includes a Consolidation Check section documenting this reasoning. During the specs phase, overlap with existing baseline specs is verified before creating spec files.

## Known Limitations

- PR body is initially minimal (proposal's Why section or change name) until the constitution standard task enriches it post-apply.
- Multi-PR or stacked-PR workflows are not supported.
- Automated migration of legacy `research.md`/`tests.md` artifacts is not supported — those changes retain their original structure.

## Edge Cases

- If an artifact file exists but is empty (0 bytes), the system treats it as incomplete.
- If a user manually deletes an artifact file mid-pipeline, the system detects the gap and requires regeneration.
- If `tasks.md` contains no checkbox items, the apply phase is still gated by `tasks.md` existence.
- If the feature branch already exists, the system reuses it rather than failing.
- If push succeeds but draft PR creation fails, the failure is noted but the pipeline is not blocked.
- Legacy change directories with `research.md` are read for Discovery enrichment if the proposal lacks a Discovery block.
- Legacy `tests.md` files are tolerated by audit cross-checks but no longer produced for new changes.
