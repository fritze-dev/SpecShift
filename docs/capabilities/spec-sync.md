---
title: "Spec Sync"
capability: "spec-sync"
description: "Agent-driven merging of delta specs into baseline specs with intelligent partial updates"
order: 12
lastUpdated: "2026-03-04"
---

# Spec Sync

Merge completed change specs into the project's baseline specs with `/opsx:sync`. The system intelligently combines new, modified, and removed requirements while keeping baseline specs clean and consistent.

## Why This Exists

When a change is completed, its delta specs describe what was added, modified, or removed. These deltas need to be merged into the project's baseline specs so that baselines always reflect the current state of the system. This capability provides context-aware merging that produces coherent, well-structured baseline specs even when changes are complex.

## Features

- Merge new requirements into existing baselines without duplicating content
- Replace modified requirements with their updated versions
- Remove deprecated requirements cleanly
- Create new baseline specs from scratch when a capability is introduced for the first time
- Add individual scenarios or edge cases to existing requirements without copying the entire requirement
- Strip delta operation markers (ADDED, MODIFIED, REMOVED) from baselines automatically
- Enforce consistent baseline format: Purpose section followed by Requirements section

## Behavior

### Merging Changes

Run `/opsx:sync` after a change is approved. The system reads each delta spec and its corresponding baseline, understands the intent of each operation, and produces a merged result. New requirements are appended, modified requirements are replaced in full, and removed requirements are deleted.

### Partial Updates

You can add a single scenario to an existing requirement without copying the entire requirement into your delta. The system locates the requirement in the baseline and appends the new scenario without disturbing existing content. Similarly, you can add edge cases or refine descriptions, and the system integrates the changes naturally.

### Baseline Format

After syncing, baselines always follow a clean format: a Purpose section describing the capability, followed by a Requirements section with all current requirements. Delta operation prefixes like "ADDED" or "MODIFIED" are stripped. Each requirement maintains the standard ordering: header, description, optional user story, and scenarios.

### New Capabilities

If a baseline does not yet exist for a capability, the system creates it from the delta content with the proper format.

## Edge Cases

- If two changes modify the same requirement differently, the system flags the conflict and asks you to resolve it rather than silently overwriting.
- If a delta section is empty (e.g., "MODIFIED Requirements" with no content), the system ignores it.
- If a delta has MODIFIED operations but no baseline exists for the capability, the system reports an error.
- If a requirement is renamed, the system warns about potential stale references in other documents.
- If the baseline has changed since the delta was authored (due to a concurrent change), the system detects this and prompts for re-review.
