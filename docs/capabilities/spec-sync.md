---
title: "Spec Sync"
capability: "spec-sync"
description: "Agent-driven delta spec merging into baseline specs with /opsx:sync"
order: 12
lastUpdated: "2026-03-02"
---

# Spec Sync

Run `/opsx:sync` to merge delta specs from a change into the baseline specs. This is an explicit workflow step after approval and before archive.

## Features

- Agent-driven intelligent merging (not mechanical find-and-replace)
- Supports partial updates: add a scenario without copying the entire requirement
- Strips delta operation prefixes and enforces clean baseline format
- Creates new baseline specs when a capability doesn't exist yet

## Behavior

### Agent-Driven Merging

The AI agent reads both the delta spec and the current baseline, understands the semantic intent of each operation (ADDED, MODIFIED, REMOVED, RENAMED), and produces a coherent merged result. This is context-aware merging, not programmatic string manipulation.

### Delta Operations

ADDED requirements are appended to the baseline. MODIFIED requirements replace the corresponding baseline requirement. REMOVED requirements are deleted from the baseline. If no baseline exists, a new one is created with Purpose and Requirements sections.

### Partial Updates

You can add a single scenario to an existing requirement without copying the entire requirement block. The agent locates the requirement and appends the scenario while preserving everything else.

### Baseline Format

After sync, baselines always have `## Purpose` followed by `## Requirements` with no delta operation prefixes. Requirements follow the strict ordering: header, normative description, optional User Story, scenarios.

## Edge Cases

- If two changes modify the same requirement differently, the agent flags the conflict and asks you to resolve it.
- Empty delta sections are ignored.
- MODIFIED operations on a non-existent baseline are treated as errors.
- If a requirement is renamed, the agent warns about potential stale references in other specs.
- Sync is an explicit workflow step; archive retains a safety-net prompt for unsynced delta specs as a fallback.
