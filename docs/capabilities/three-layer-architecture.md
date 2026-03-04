---
title: "Three-Layer Architecture"
capability: "three-layer-architecture"
description: "Constitution, Schema, and Skills layers with distinct responsibilities and independent modification"
order: 13
lastUpdated: "2026-03-04"
---

# Three-Layer Architecture

The plugin is structured into three independent layers: the Constitution (project rules), the Schema (pipeline definition), and the Skills (commands). Each layer has its own responsibility, and you can modify one without affecting the others.

## Why This Exists

A clear separation of concerns ensures that project-wide rules, pipeline structure, and individual commands can evolve independently. You can change global coding standards without touching the pipeline, add new pipeline stages without rewriting commands, or refine a command without altering project rules.

## Features

- Constitution layer: a single file that governs all project-wide rules (tech stack, architecture, code style, constraints, conventions)
- Schema layer: a declarative definition of the 6-stage artifact pipeline (research, proposal, specs, design, preflight, tasks)
- Skills layer: 13 commands delivered as individually discoverable skill files
- Independent modification of each layer without requiring changes to the others
- Skills categorized as workflow (6), governance (5), or documentation (2)

## Behavior

### Constitution

The constitution is a single file that defines global project rules. It includes sections for tech stack, architecture rules, code style, constraints, and conventions. Every command reads the constitution before performing any work, ensuring consistent behavior across the entire system.

### Schema

The schema declares the artifact pipeline as a structured definition. It specifies exactly 6 stages -- research, proposal, specs, design, preflight, and tasks -- each with a template, instructions, and dependency list. The implementation phase is gated: tasks must be complete before coding begins. You can inspect the schema to understand the pipeline without reading any command code.

### Skills

All 13 commands are delivered as skill files within the Claude Code plugin system. The `init` command is user-only (one-time setup); all other commands can be invoked by both users and the AI agent. Skills depend on the schema through the OpenSpec CLI, not directly -- so schema changes do not require skill changes.

### Layer Independence

Modifications to one layer do not require changes to another layer. Adding a new code style rule to the constitution does not affect the schema. Adding a new pipeline stage to the schema does not require rewriting skills. Refining a skill's instructions does not alter the constitution or schema.

## Edge Cases

- If the constitution is missing or empty, commands report an error rather than proceeding without rules.
- If the schema contains invalid YAML, the system rejects it with a validation error before any artifact generation begins.
- If a skill directory exists but contains no skill file, the plugin system does not register that command.
- If a new skill is added without updating the constitution's documentation, the system still functions but the stale documentation is detected by verification.
