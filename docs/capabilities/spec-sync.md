---
title: "Spec Sync"
capability: "spec-sync"
description: "Agent-driven merging of delta specs into baseline specs"
lastUpdated: "2026-03-05"
---

# Spec Sync

The `/opsx:sync` command merges delta specs from completed changes into their corresponding baseline specs. The merge is performed by the AI agent, which understands the semantic intent of each operation and produces coherent results.

## Why This Exists

Delta specs capture what changed, but baseline specs need to reflect the current state of all requirements. Without a sync step, baselines would go stale after every change, and new team members or future changes would work from outdated references. Manual merging is tedious and error-prone, especially when multiple changes touch the same capability.

## Design Rationale

Sync uses an agent-driven approach rather than programmatic string manipulation. This means the AI reads both the delta and the baseline, understands what the delta intends, and produces a coherent merged result. This is especially important for partial updates -- when a delta adds a single scenario to an existing requirement, a mechanical merge would not know where to place it, but the agent can locate the right requirement and append the scenario naturally.

## Features

- Merges delta specs into baseline specs using AI-driven semantic understanding
- Supports ADDED, MODIFIED, REMOVED, and RENAMED operations
- Creates new baseline specs from deltas when no baseline exists
- Supports intelligent partial updates (e.g., adding one scenario to an existing requirement)
- Strips delta operation prefixes to produce clean baseline format
- Preserves baseline content that the delta does not address

## Behavior

### Syncing Added Requirements

When a delta spec contains ADDED requirements, the agent reads the existing baseline and appends the new requirements under the Requirements section without duplicating existing content.

### Syncing Modified Requirements

When a delta contains MODIFIED requirements, the agent replaces the targeted requirement in the baseline with the updated content from the delta, preserving all other unmodified requirements.

### Syncing Removed Requirements

When a delta contains REMOVED requirements, the agent removes the targeted requirement from the baseline and confirms the removal.

### Creating New Baselines

If no baseline spec exists for a capability, the agent creates one with a Purpose section and Requirements section derived from the delta content.

### Partial Updates

You can add a single scenario or edge case to an existing requirement without copying the entire requirement into your delta. The agent locates the target requirement in the baseline and appends the new content without disturbing existing scenarios or descriptions.

### Baseline Format

After sync, all baselines conform to a clean format: a Purpose section followed by a Requirements section. Delta operation prefixes (ADDED, MODIFIED, etc.) are stripped. Requirements maintain strict ordering: header, normative description, optional User Story, and scenarios.

## Edge Cases

- If two changes modify the same requirement differently, the agent flags the conflict and asks you to resolve it.
- If a delta contains an empty section (e.g., MODIFIED with no content beneath it), the agent ignores it.
- If a delta has MODIFIED operations but no baseline exists, the agent reports this as an error.
- If a requirement is renamed, the agent warns about potential stale references in other specs.
- If a second sync detects the baseline has changed since the delta was authored, it prompts for re-review.
