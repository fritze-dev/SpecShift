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

The router's JIT requirement resolution loads entire spec files to extract individual requirement blocks, causing ~50% token overhead per action. Consumers cannot use the resolved requirements because `docs/specs/` is not part of the distribution. Pre-compiling requirements into focused files at finalize time eliminates this overhead and makes the plugin self-contained.

## What Changes

- **AOT compilation step in finalize**: After changelog/docs/version-bump, a compiler extracts requirement blocks from `docs/specs/` and copies source files into a release directory at `.claude/`.
- **Plugin root at `.claude/`**: Standard Claude Code plugin layout — `.claude-plugin/plugin.json`, `skills/specshift/` (SKILL.md + actions + templates). Auto-discovered by Claude Code, marketplace `source: "./.claude"`.
- **Instruction/Requirements separation**: Instructions are project-specific (JIT, read from WORKFLOW.md at runtime). Requirements are plugin-level (AOT, pre-compiled in `actions/*.md`). Compiled files contain only requirements — no frontmatter, no instructions.
- **Requirement links in `src/actions/`**: One file per action with clickable relative links to specs. The compiler loops over these files to build the compiled output. SKILL.md is a pure runtime document — no spec references.
- **Dev sync script**: `scripts/compile-skills.sh` rebuilds the release directory without running full finalize.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `release-workflow`: Add "AOT Skill Compilation" (build step, extraction, validation), "Compiled Action File Contract" (requirements-only format), "Dev Sync Script" (standalone build utility). Update marketplace source to `./.claude`, update plugin structure requirements for the new layout.
- `workflow-contract`: Router reads instruction from WORKFLOW.md (JIT) + compiled requirements from `actions/<action>.md` (AOT). Requirement links moved from SKILL.md to `src/actions/`. Custom actions remain JIT.

### Removed Capabilities

(none)

### Consolidation Check

1. **Existing specs reviewed**: artifact-pipeline, workflow-contract, release-workflow, three-layer-architecture, change-workspace, task-implementation, quality-gates, human-approval-gate, documentation, project-init, constitution-management, spec-format, test-generation, roadmap-tracking
2. **Overlap assessment**: The compilation mechanism, release artifact format, and build tooling are release concerns — they belong in `release-workflow`. The router dispatch behavior change (reading instruction + compiled requirements) is a workflow concern — it stays in `workflow-contract`.
3. **Merge assessment**: N/A — no new capabilities proposed.

## Impact

- **Affected code**: `src/skills/specshift/SKILL.md` (router dispatch), `src/actions/` (new, compiler input), `.claude/` (release directory), `.specshift/WORKFLOW.md` (finalize instruction), `scripts/compile-skills.sh` (new), `.specshift/CONSTITUTION.md` (architecture rules), `.claude-plugin/marketplace.json` (source path), `.gitignore` (whitelists)
- **Performance**: ~50% token reduction per action at runtime
- **Distribution**: Plugin root shifts from `src/` to `.claude/`. Standard plugin layout with auto-discovery.

## Scope & Boundaries

- **In scope**: Compilation step in finalize, `.claude/` as plugin root, instruction/requirements separation, `src/actions/` as compiler input, dev sync script, marketplace/constitution/CLAUDE.md updates
- **Out of scope**: Changing the markdown spec format; modifying Smart Templates; changing the `specshift <action>` UX; altering how custom actions work
