---
title: "Constitution Management"
capability: "constitution-management"
description: "Constitution generation from codebase, automatic updates during design, and global context enforcement"
order: 13
lastUpdated: "2026-03-02"
---

# Constitution Management

The project constitution is auto-generated from your codebase during bootstrap, automatically updated when design introduces new technologies, and enforced across all AI actions.

## Features

- Constitution generated from observed codebase patterns, not generic defaults
- Uncertain conventions marked with `<!-- REVIEW -->` for your confirmation
- Automatic updates when design phases introduce new technologies or patterns
- Global enforcement: every AI action reads the constitution before proceeding

## Behavior

### Bootstrap Generation

During `/opsx:bootstrap`, the agent scans source files, configuration, and dependencies to infer the constitution. Every entry is traceable to an observed pattern. The constitution covers Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions.

### Global Context

The constitution is referenced through `config.yaml` workflow rules. Every skill invocation and artifact generation reads the constitution first, ensuring all AI output respects your project's conventions.

### Design-Phase Updates

When a design introduces a new technology (e.g., Redis) or architectural pattern not in the constitution, the agent adds it. Updates are additive by default: existing entries are not removed without your approval. Proposed replacements are marked with `<!-- REVIEW -->`. Constitution changes are documented in the design artifact.

## Edge Cases

- If the project has no source files, bootstrap generates a minimal constitution with placeholder sections marked `<!-- REVIEW -->`.
- If the codebase has conflicting conventions, both patterns are documented and marked `<!-- REVIEW -->`.
- If you manually edit the constitution, the agent treats your edits as authoritative.
- Sequential design phases preserve earlier additions and don't regress them.
- In a monorepo with mixed tech stacks, the agent documents all stacks and notes which directories each applies to.
