---
status: active
branch: aot-prompt-compilation
worktree: .claude/worktrees/aot-prompt-compilation
capabilities:
  new: []
  modified: [artifact-pipeline, workflow-contract]
  removed: []
---
## Why

The router's JIT requirement resolution loads entire spec files to extract individual requirement blocks, causing ~60% token overhead per action. Consumers cannot use the resolved requirements because `docs/specs/` is not part of the distribution (`source: "./src"`). Pre-compiling requirements into focused action files at finalize time eliminates this overhead and makes the plugin self-contained.

## What Changes

- **AOT compilation step in finalize**: After changelog/docs/version-bump, a compiler extracts requirement blocks from `docs/specs/` and bakes them into per-action markdown files under `src/skills/specshift/actions/`.
- **Router reads compiled files**: SKILL.md Step 4 reads `actions/<action>.md` for built-in actions instead of resolving requirement anchor links at runtime. Custom actions remain JIT (read from WORKFLOW.md directly).
- **Requirement links become compiler input**: The existing requirement link lists in SKILL.md (lines 46-93) are annotated as compiler input, no longer resolved at runtime.
- **Dev sync script**: A bash script (`scripts/compile-skills.sh`) enables quick local recompilation without running full finalize.
- **Compiled action file format**: Each file contains YAML frontmatter (compiled-at, version, sources), the action instruction from WORKFLOW.md, and pre-extracted requirement blocks.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `artifact-pipeline`: Add "AOT Skill Compilation" as a finalize sub-step. Define the compilation trigger, extraction algorithm, compiled file format, and staleness handling.
- `workflow-contract`: Router dispatch for built-in actions reads compiled action files instead of resolving spec anchor links. Custom actions remain JIT. Define the compiled action file contract and dev sync utility.

### Removed Capabilities

(none)

### Consolidation Check

1. **Existing specs reviewed**: artifact-pipeline, workflow-contract, release-workflow, three-layer-architecture, change-workspace, task-implementation, quality-gates, human-approval-gate, documentation, project-init, constitution-management, spec-format, test-generation, roadmap-tracking
2. **Overlap assessment**: Considered a new `aot-compilation` spec. The compilation mechanism is tightly coupled to two existing domains: (a) the finalize pipeline step belongs in `artifact-pipeline`, (b) the router dispatch change and compiled file contract belong in `workflow-contract`. Both specs will gain 2-3 requirements each, keeping them within healthy size (~350-400 lines). A standalone spec would have only 3-4 requirements and would cross-reference both existing specs heavily.
3. **Merge assessment**: N/A — no new capabilities proposed.

## Impact

- **Affected code**: `src/skills/specshift/SKILL.md` (router dispatch), `src/skills/specshift/actions/*.md` (new compiled files), `.specshift/WORKFLOW.md` (finalize instruction), `scripts/compile-skills.sh` (new), `.specshift/CONSTITUTION.md` (architecture rules update)
- **Performance**: ~60% token reduction per action at runtime; single file read instead of multi-file resolution
- **Distribution**: No change to consumer installation — compiled files are added to `src/`, which is already the distribution boundary

## Scope & Boundaries

- **In scope**: Compilation step in finalize, router dispatch change, compiled action file format, dev sync script, constitution/WORKFLOW.md updates
- **Out of scope**: Changing the markdown spec format itself; modifying Smart Templates; changing the `specshift <action>` UX; altering how custom actions work
