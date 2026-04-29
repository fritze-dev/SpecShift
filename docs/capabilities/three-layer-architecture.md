---
title: "Three-Layer Architecture"
capability: "three-layer-architecture"
description: "Constitution, WORKFLOW.md + Smart Templates, and Router + Actions with independent modifiability"
lastUpdated: "2026-04-28"
---

# Three-Layer Architecture

The plugin organizes all behavior into three independent layers: Constitution, WORKFLOW.md + Smart Templates, and Router + Actions. Each layer has a clear responsibility, and changes to one layer do not require changes to another.

## Purpose

Projects using AI-driven workflows need a way to separate global rules, pipeline definitions, and command logic so they can evolve independently. Without this separation, every change risks unintended side effects across unrelated concerns. The three-layer architecture provides clear boundaries that allow each concern to be modified in isolation.

## Rationale

Separating concerns into Constitution (project rules), WORKFLOW.md + Smart Templates (pipeline structure and artifact definitions), and Router + Actions (command dispatch) ensures each layer has a single authoritative owner. WORKFLOW.md provides slim pipeline orchestration -- stage ordering, apply gate, inline action definitions -- while Smart Templates carry their own instructions and metadata in YAML frontmatter. The third layer consolidated from 11 separate skill files to a single router that dispatches to 5 built-in actions (init, propose, apply, finalize, review) plus consumer-defined custom actions, eliminating 90%+ of orchestration code duplication. Actions are defined inline in WORKFLOW.md, making the router a thin dispatcher that reads WORKFLOW.md dynamically at runtime. Custom actions leverage the same layer separation -- they are defined in WORKFLOW.md (Layer 2) and dispatched by the router (Layer 3) without requiring changes to either the router or the constitution.

## Features

- **Constitution Layer**: A single `CONSTITUTION.md` file at `.specshift/CONSTITUTION.md` defines all project-wide rules, including Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. Every AI action reads this file before performing work, enforced via WORKFLOW.md's `context` field.
- **WORKFLOW.md + Smart Templates Layer**: `.specshift/WORKFLOW.md` declares the artifact pipeline order (the canonical stage list lives in the artifact-pipeline capability — Schema Layer references it normatively rather than restating the count), inline action definitions (built-in and custom), apply gate, and project context. Smart Templates in `.specshift/templates/` carry per-artifact instructions, output paths, and dependencies in YAML frontmatter. Together they serve as the single source of truth for pipeline structure, action instructions, and artifact generation.
- **Router + Actions Layer**: All commands are delivered through a single router SKILL.md that dispatches to 5 built-in actions: `init` (project setup and health checks), `propose` (pipeline traversal), `apply` (task implementation with audit.md), `finalize` (changelog, docs, version bump), and `review` (PR review-to-merge lifecycle). The router additionally supports consumer-defined custom actions listed in the WORKFLOW.md `actions` array. The router is model-invocable.
- **Proactive Skill Invocation**: The router's skill description includes TRIGGER and DO NOT TRIGGER conditions that enable the AI to proactively invoke the specshift workflow when implementation intent is detected (e.g., "implement this", "build it", transitioning from plan mode to coding). Read-only activities like asking questions or exploring code do not trigger the skill. The project's CLAUDE.md reinforces this by instructing the AI to invoke the skill before editing any file.
- **Layer Separation**: Each layer is independently modifiable. WORKFLOW.md and Smart Templates do not embed router logic, and the constitution does not contain pipeline-specific definitions. The router depends on WORKFLOW.md and Smart Templates by reading them directly at runtime. Adding a custom action requires only WORKFLOW.md changes -- no router or constitution modifications.

## Behavior

### Constitution Is Read Before Any Action

The constitution file is loaded and its rules are applied before any AI-driven action executes. This is enforced through the `context` field in WORKFLOW.md, which points to `.specshift/CONSTITUTION.md`.

### WORKFLOW.md and Smart Templates Define the Pipeline and Actions

WORKFLOW.md declares the artifact pipeline in strict dependency order via its `pipeline` array — the canonical stage IDs (research, proposal, specs, design, preflight, tests, tasks, audit) are owned by the artifact-pipeline capability's Pipeline Stages and Dependencies requirement. WORKFLOW.md also defines inline actions (built-in and custom) with `## Action: <name>` body sections containing procedural instructions. Each Smart Template contains `id`, `generates`, `requires`, and `instruction` fields. The apply phase is gated by the tasks artifact.

### Router Dispatches to Built-in and Custom Actions

A single router SKILL.md handles all user-facing commands. It performs shared orchestration (intent recognition, change context detection, WORKFLOW.md loading) and dispatches to the appropriate action. For propose, it traverses the pipeline. For apply and finalize, it spawns a sub-agent with bounded context. For init, it executes without change context. For custom actions, it reads the instruction from WORKFLOW.md and executes it directly, with the agent deciding the execution mode.

### Adding Custom Actions Does Not Require Router Changes

A consumer adds a custom action by appending it to the `actions` array in WORKFLOW.md frontmatter and writing a `## Action: <name>` body section. The router validates against the `actions` array dynamically and dispatches via a generic fallback -- no modification to the router SKILL.md is needed.

### Layers Are Independently Modifiable

Updating a WORKFLOW.md action instruction does not require changes to the router, because the router reads WORKFLOW.md dynamically. Adding a new code style rule to the constitution does not require WORKFLOW.md changes. Refining the router's dispatch logic does not require changes to the constitution or WORKFLOW.md. Adding a custom action only touches WORKFLOW.md.

### Constitution Does Not Duplicate Workflow Instruction Details

Operational behavior details (e.g., checkpoint behavior, auto-dispatch rules) live exclusively in the WORKFLOW.md action instructions that govern them. The constitution defines project-wide governance rules (tech stack, code style, conventions) but does not restate action-level operational rules. This prevents drift between layers when a rule is updated in one place but not the other.

### Skill Triggers Proactively on Implementation Requests

When a user asks the AI to implement, build, or code something -- including after exiting plan mode -- the router's TRIGGER conditions cause the specshift skill to be invoked automatically. The AI does not need to wait for an explicit `/specshift` command. Conversely, asking questions, reading files, exploring code, or discussing design without requesting implementation does not trigger the skill.

### CLAUDE.md Enforces Workflow for All File Types

The project's CLAUDE.md instructs the AI to invoke the specshift skill before editing any file -- source code, specs, skills, templates, docs, or configuration. This prevents the AI from bypassing the workflow by editing files directly.

### Consumer Templates Do Not Contain Project-Specific Steps

The consumer workflow template distributed by the plugin (`src/templates/workflow.md`) contains only generic action instructions. Project-specific steps (e.g., compilation scripts, hardcoded version-bump paths) are added only to the project's `.specshift/WORKFLOW.md` instance as intentional overrides.

## Known Limitations

- The Claude Code plugin system discovers the router by scanning `skills/*/SKILL.md` files. This is based on observed behavior, not a documented guarantee.
- The WORKFLOW.md `context` field mechanism is assumed to reliably enforce constitution reading before action execution.

## Edge Cases

- If the constitution is missing or empty, the router reports an error rather than proceeding without rules.
- If WORKFLOW.md contains malformed YAML, the router reports a read error rather than proceeding with invalid data.
- If the router SKILL.md is missing, the plugin system does not register any commands.
- If a new action is added without updating documentation, the system still functions but documentation is stale.
