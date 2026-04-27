---
status: review
branch: codex-plugin-support
capabilities:
  new: []
  modified: [release-workflow]
  removed: []
---
# Proposal: Codex Plugin Support

## Why

SpecShift users should be able to install and use the workflow in Codex, not only Claude Code. The project already has a generated plugin-release model, so Codex support should extend that model instead of adding a manually maintained duplicate.

## What Changes

- Add a Codex plugin manifest source at `src/.codex-plugin/plugin.json`.
- Extend `scripts/compile-skills.sh` to build both Claude and Codex release artifacts.
- Generate the Codex plugin at the repository root with `.codex-plugin/plugin.json`, `skills/specshift/SKILL.md`, templates, and compiled actions.
- Align Codex packaging with the Shopify AI Toolkit root plugin layout.
- Add Codex installation and update instructions to `README.md`.
- Update release workflow specs so the generated Codex release is part of the maintained contract.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `release-workflow`: extend release compilation, marketplace source configuration, and install/update documentation to include Codex.

### Removed Capabilities

None.

### Consolidation Check

1. Existing specs reviewed: `release-workflow`, `project-init`, `three-layer-architecture`, `workflow-contract`.
2. Overlap assessment: Codex packaging belongs in `release-workflow` because it changes how release artifacts and marketplace metadata are built and distributed.
3. Merge assessment: N/A - no new specs proposed.

## Impact

Affected files include the compiler script, plugin source manifests/templates, generated Claude and Codex release artifacts, repository marketplace metadata, README documentation, and release workflow specs.

## Scope & Boundaries

In scope: Codex plugin packaging, generated artifacts, marketplace metadata, docs, and validation.

Out of scope: changing the SpecShift pipeline semantics, adding non-Bash build dependencies, publishing to an official marketplace, or changing Claude Code installation behavior.
