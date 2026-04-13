---
status: active
branch: plugin-version-check
worktree: .claude/worktrees/plugin-version-check
capabilities:
  new: []
  modified: [workflow-contract, project-init]
  removed: []
---
## Why

When the specshift plugin is updated (new version, bumped template-versions), consumer projects are not notified. They would need to manually run `specshift init` to discover updates, but nothing tells them to do so. This creates silent drift between the installed plugin and the consumer's configuration.

## What Changes

- Add `plugin-version` field to WORKFLOW.md frontmatter — stamped by `init` from `plugin.json`
- Add version check step to SKILL.md router — compares `plugin-version` against current `plugin.json` before dispatching
- Restructure SKILL.md router steps so WORKFLOW.md is read exactly once (currently referenced in 3 steps)
- Bump workflow template `template-version` from 2 to 3

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `workflow-contract`: Add `plugin-version` as a recognized WORKFLOW.md frontmatter field. Update router dispatch pattern to reflect restructured steps (Load Configuration → Identify Action → Plugin Version Check → Change Context Detection → Dispatch).
- `project-init`: Add requirement for stamping `plugin-version` in WORKFLOW.md during init (fresh install and re-init).

### Removed Capabilities

(none)

### Consolidation Check

1. Existing specs reviewed: workflow-contract, project-init, artifact-pipeline, change-workspace, quality-gates, three-layer-architecture
2. Overlap assessment: `plugin-version` field belongs in `workflow-contract` (defines WORKFLOW.md frontmatter fields). Version stamping behavior belongs in `project-init` (defines init behavior). No new capability needed — both are modifications to existing specs.
3. Merge assessment: N/A — no new capabilities proposed.

## Impact

- `src/templates/workflow.md` — new frontmatter field, template-version bump
- `src/skills/specshift/SKILL.md` — restructured steps, new version check step
- `docs/specs/workflow-contract.md` — new frontmatter field documented
- `docs/specs/project-init.md` — new requirement for version stamping
- `src/actions/init.md` — new requirement link
- `.specshift/WORKFLOW.md` — project instance updated to match

## Scope & Boundaries

**In scope:**
- `plugin-version` field in WORKFLOW.md frontmatter
- Version check in SKILL.md router (advisory, non-blocking)
- Version stamping during `specshift init`
- SKILL.md step restructuring (consolidate WORKFLOW.md reads)

**Out of scope:**
- Automatic plugin update mechanism
- Semver comparison or compatibility matrix
- Breaking change detection between versions
