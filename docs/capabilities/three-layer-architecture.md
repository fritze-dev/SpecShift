---
title: "Three-Layer Architecture"
capability: "three-layer-architecture"
description: "Constitution, Schema, and Skills layers with clear separation of concerns"
lastUpdated: "2026-03-05"
---

# Three-Layer Architecture

The opsx-enhanced plugin is structured as three independently modifiable layers: the Constitution (project rules), the Schema (pipeline structure), and Skills (commands). Each layer has distinct responsibilities and interaction patterns.

## Purpose

Without clear layer separation, changes to one part of the system cascade unpredictably into others. Updating a pipeline stage would require rewriting skill code, adding a project rule would mean editing the schema, and understanding the system would require reading everything at once. The three-layer architecture lets each concern be modified independently.

## Rationale

Skills depend on the schema via the OpenSpec CLI rather than embedding schema logic directly. This indirection means a schema change (e.g., adding a new artifact stage) does not require updating any skill files. The constitution is loaded via config.yaml workflow rules so that it applies automatically without skills needing to explicitly reference it.

## Features

- **Constitution layer**: Global project rules in constitution.md, read automatically by all AI actions
- **Schema layer**: Declarative 6-stage artifact pipeline with templates, instructions, and dependencies
- **Skills layer**: 13 commands delivered as SKILL.md files (6 workflow, 5 governance, 2 documentation)
- All layers independently modifiable without cascading changes
- All skills are model-invocable (including init, which bootstrap workflows invoke programmatically)

## Behavior

### Constitution Layer

The constitution at `openspec/constitution.md` defines project-wide rules: Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. Config.yaml ensures every AI action reads the constitution before doing any work.

### Schema Layer

The opsx-enhanced schema at `openspec/schemas/opsx-enhanced/` declares six artifact stages (research, proposal, specs, design, preflight, tasks) with templates, instructions, and dependency chains. The schema is the single source of truth for pipeline structure and artifact generation rules.

### Skills Layer

All 13 commands are delivered as `skills/*/SKILL.md` files within the Claude Code plugin system. Skills are categorized as:
- **Workflow** (6): new, continue, ff, apply, verify, archive
- **Governance** (5): init, bootstrap, discover, preflight, sync
- **Documentation** (2): changelog, docs

All skills are model-invocable, including init (bootstrap workflows invoke it programmatically; its idempotent design makes this safe).

### Layer Independence

You can update the schema (e.g., add a new artifact stage) without changing any skills, because skills depend on the CLI, not the schema directly. You can update the constitution (e.g., add a code style rule) without changing the schema. You can refine a skill's instructions without touching the constitution or schema.

## Edge Cases

- If the constitution is missing, skills report an error rather than proceeding without rules.
- If the schema is malformed YAML, the OpenSpec CLI rejects it with a validation error before any artifact generation begins.
- If a skill directory exists but contains no SKILL.md file, Claude Code does not register that command.
