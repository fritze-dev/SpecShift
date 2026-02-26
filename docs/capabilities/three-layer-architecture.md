---
title: "Three-Layer Architecture"
capability: "three-layer-architecture"
description: "Constitution, Schema, and Skills layers with distinct responsibilities and independent modifiability"
order: 1
lastUpdated: "2026-03-02"
---

# Three-Layer Architecture

The plugin is structured into three independent layers: the Constitution defines project-wide rules, the Schema defines the artifact pipeline, and Skills deliver the commands. Each layer can be modified without affecting the others.

## Features

- A single constitution file governs all AI behavior across the project
- A declarative schema defines the 6-stage artifact pipeline without embedding skill logic
- All 13 commands are delivered as SKILL.md files within the Claude Code plugin system
- Each layer is independently modifiable without requiring changes to the others

## Behavior

### Constitution Layer

The constitution at `openspec/constitution.md` is read before any AI-driven skill runs. It contains sections for Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. All AI actions respect these rules automatically.

### Schema Layer

The `opsx-enhanced` schema declares 6 artifacts (research, proposal, specs, design, preflight, tasks) with dependency ordering. Each artifact has a template, instruction, and dependency list. The apply phase is gated by the tasks artifact.

### Skills Layer

All 13 commands live as `skills/*/SKILL.md` files. They are categorized as workflow (6), governance (5), or documentation (2). The `/opsx:init` command is user-only; all others are model-invocable.

### Layer Independence

You can update the schema without changing skills, update the constitution without touching the schema, or refine a skill without modifying constitution or schema. Changes to one layer only affect others when the interface contract between them changes.

## Edge Cases

- If the constitution is missing or empty, skills report an error rather than proceeding without rules.
- If the schema contains invalid YAML, the OpenSpec CLI rejects it with a validation error before any artifact generation.
- If a skill directory exists but has no SKILL.md file, Claude Code does not register that command.
- If a new skill is added without updating the constitution's documentation, the system still functions but documentation becomes stale (detected by `/opsx:verify`).
