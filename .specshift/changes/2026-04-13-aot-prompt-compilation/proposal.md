---
status: active
branch: aot-prompt-compilation
worktree: .claude/worktrees/aot-prompt-compilation
capabilities:
  new: []
  modified: [release-workflow, workflow-contract]
  removed: []
---
## Why

The router's JIT requirement resolution loads entire spec files to extract individual requirement blocks, causing ~60% token overhead per action. Consumers cannot use the resolved requirements because `docs/specs/` is not part of the distribution (`source: "./src"`). Pre-compiling requirements into focused action files at finalize time eliminates this overhead and makes the plugin self-contained.

## What Changes

- **AOT compilation step in finalize**: After changelog/docs/version-bump, a compiler copies source files from `src/` and extracts requirement blocks from `docs/specs/` into a self-contained release directory at `.claude/skills/specshift/`.
- **Release directory**: `.claude/skills/specshift/` contains the router (SKILL.md, copied from `src/`), templates (copied from `src/templates/`), and compiled action files (`actions/*.md`). Claude Code auto-discovers the skill — no plugin installation needed.
- **Router reads compiled files**: SKILL.md Step 4 reads `actions/<action>.md` for built-in actions instead of resolving requirement anchor links at runtime. Custom actions remain JIT (read from WORKFLOW.md directly).
- **Requirement links become compiler input**: The existing requirement link lists in SKILL.md (lines 46-93) are annotated as compiler input, no longer resolved at runtime.
- **Dev sync script**: A bash script (`scripts/compile-skills.sh`) enables quick local rebuild of the release directory without running full finalize.
- **Compiled action file format**: Each file contains YAML frontmatter (compiled-at, version, sources), the action instruction from WORKFLOW.md, and pre-extracted requirement blocks.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `release-workflow`: Add "AOT Skill Compilation" (build step, extraction, validation, release directory), "Compiled Action File Contract" (format, git persistence), and "Dev Sync Script" (standalone build utility). Update marketplace source configuration for the new release directory path.
- `workflow-contract`: Router dispatch for built-in actions reads compiled action files instead of resolving spec anchor links. Custom actions remain JIT. Hard error on missing compiled files.

### Removed Capabilities

(none)

### Consolidation Check

1. **Existing specs reviewed**: artifact-pipeline, workflow-contract, release-workflow, three-layer-architecture, change-workspace, task-implementation, quality-gates, human-approval-gate, documentation, project-init, constitution-management, spec-format, test-generation, roadmap-tracking
2. **Overlap assessment**: Considered a new `aot-compilation` spec and placement in `artifact-pipeline`. The compilation mechanism, release artifact format, and build tooling are release concerns — they belong in `release-workflow` alongside version bumping, changelog generation, and distribution configuration. The router dispatch behavior change (reading compiled files) is a workflow concern — it stays in `workflow-contract`.
3. **Merge assessment**: N/A — no new capabilities proposed.

## Impact

- **Affected code**: `src/skills/specshift/SKILL.md` (router dispatch), `.claude/skills/specshift/` (new release directory), `.specshift/WORKFLOW.md` (finalize instruction), `scripts/compile-skills.sh` (new), `.specshift/CONSTITUTION.md` (architecture rules update), `.claude-plugin/marketplace.json` (source path update), `.gitignore` (whitelist `.claude/skills/`)
- **Performance**: ~60% token reduction per action at runtime; single file read instead of multi-file resolution
- **Distribution**: Release directory shifts from `src/` to `.claude/skills/specshift/`. Consumers get auto-discovered skills without plugin installation.

## Scope & Boundaries

- **In scope**: Compilation step in finalize, release directory at `.claude/skills/specshift/`, router dispatch change, compiled action file format, dev sync script, marketplace.json source update, constitution/WORKFLOW.md updates
- **Out of scope**: Changing the markdown spec format itself; modifying Smart Templates; changing the `specshift <action>` UX; altering how custom actions work
