---
title: "Architecture Documentation"
capability: "architecture-docs"
description: "Cross-cutting architecture overview synthesized from constitution, specs, and design decisions"
order: 16
lastUpdated: "2026-03-04"
---

# Architecture Documentation

The `/opsx:docs` command generates a cross-cutting architecture overview that brings together the project's structure, tech stack, key design decisions, and conventions into a single document.

## Why This Exists

Understanding a project's architecture requires reading multiple sources: the constitution for rules, the three-layer-architecture spec for structure, and individual design artifacts for decisions. This capability synthesizes all of these into one accessible document so that developers and contributors can understand the system without reading individual artifacts.

## Features

- System architecture section describing the three-layer model (Constitution, Schema, Skills)
- Tech stack section drawn from the project constitution
- Key design decisions aggregated from all archived design artifacts, deduplicated
- Conventions section from the constitution
- Fully regenerated on each run of `/opsx:docs`

## Behavior

### Generating the Architecture Overview

When you run `/opsx:docs`, the system reads the project constitution, the three-layer-architecture spec, and all design artifacts from archived changes. It synthesizes these into a single document with sections for system architecture, tech stack, key design decisions, and conventions.

### Design Decision Aggregation

The system scans all archived design files for decision tables and aggregates notable decisions into the architecture overview. Duplicate decisions are removed. If no archived changes have design artifacts, the key design decisions section is omitted.

### Regeneration

The architecture overview is fully regenerated on each run. There is no incremental update -- the document always reflects the current state of the constitution, specs, and archived designs.

## Known Limitations

- Does not support generating the overview without a constitution; the system warns and skips generation if the constitution is missing
- Does not include implementation-level architecture details; focuses on user-facing structure and decisions
- Does not support custom sections beyond the four defined (System Architecture, Tech Stack, Key Design Decisions, Conventions)

## Edge Cases

- If the constitution is not found, the system warns you and skips architecture overview generation entirely.
- If the three-layer-architecture spec is missing, the system generates a minimal system architecture section from the constitution's architecture rules only.
