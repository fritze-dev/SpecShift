# Pre-Flight Check: AOT Prompt Compilation

## A. Traceability Matrix

- [x] AOT Skill Compilation → Scenario: Finalize triggers AOT compilation → `scripts/compile-skills.sh`, `.claude/skills/specshift/actions/`
- [x] AOT Skill Compilation → Scenario: Compiled file includes provenance frontmatter → `scripts/compile-skills.sh`
- [x] AOT Skill Compilation → Scenario: Count validation detects missing requirements → `scripts/compile-skills.sh`
- [x] Compiled Action File Contract → Scenario: Compiled action file contains instruction and requirements → `scripts/compile-skills.sh`, `.claude/skills/specshift/actions/`
- [x] Compiled Action File Contract → Scenario: Compiled file with no requirement links → `scripts/compile-skills.sh`
- [x] Dev Sync Script → Scenario: Dev script builds complete release directory → `scripts/compile-skills.sh`
- [x] Dev Sync Script → Scenario: Dev script uses no external runtimes → `scripts/compile-skills.sh`
- [x] Dev Sync Script → Scenario: Dev script run outside repo root → `scripts/compile-skills.sh`
- [x] Inline Action Definitions (modified) → Scenario: Router executes built-in action via compiled action file → `src/skills/specshift/SKILL.md`
- [x] Router Dispatch Pattern (modified) → Scenario: Router dispatches apply via compiled action file → `src/skills/specshift/SKILL.md`
- [x] Marketplace Source Configuration (modified) → Scenario: Local marketplace resolves release directory → `.claude-plugin/marketplace.json`
- [x] Repository Layout Separation (modified) → Scenario: Release directory is separate from source → `.claude/skills/specshift/`, `src/`

All stories map to scenarios and components. No orphans.

## B. Gap Analysis

- **Compilation idempotency**: Running the compiler twice produces identical output. Not explicitly tested but the algorithm is deterministic (same inputs → same outputs). Acceptable — no gap.
- **Plugin.json in release directory**: The marketplace needs `plugin.json` in the release directory for version detection. The compiler copies SKILL.md and templates but does NOT copy `src/.claude-plugin/plugin.json`. This needs addressing — the compiler must also copy `src/.claude-plugin/` to `.claude/skills/specshift/.claude-plugin/`.
- **Template sync with `.specshift/templates/`**: The compiler copies from `src/templates/`, but this project's local templates at `.specshift/templates/` may have project-specific overrides. The compiler correctly uses `src/templates/` (plugin source), not `.specshift/templates/` (project instance). No gap.

## C. Side-Effect Analysis

- **`.gitignore` change**: Adding `!/.claude/skills/` could expose other files in `.claude/skills/` that shouldn't be tracked. Low risk — only `specshift/` subdirectory is generated.
- **Marketplace source path change**: Existing consumers with `source: "./src"` will need to re-add the marketplace after update. This is a one-time migration. The README should document this.
- **Router SKILL.md changes**: The router no longer resolves links at runtime. If a consumer's worktree has an old SKILL.md cached, it won't find compiled files. Resolved by normal plugin update flow.

## D. Constitution Check

Constitution needs two updates:
1. Architecture Rules: Add `.claude/skills/specshift/` as official release directory
2. Conventions: Add `bash scripts/compile-skills.sh` as dev workflow step

## E. Duplication & Consistency

- No duplication between new requirements. AOT Skill Compilation (build process) is distinct from Compiled Action File Contract (output format) and Dev Sync Script (tooling).
- Router dispatch scenarios in `workflow-contract.md` align with compiled file contract in `release-workflow.md`.
- Marketplace source configuration updated consistently.

## F. Assumption Audit

| Assumption | Source | Rating |
|-----------|--------|--------|
| Consistent spec heading format | release-workflow.md, design.md | Acceptable Risk — specs follow this format since project inception; enforced by spec template |
| Scripts directory convention | release-workflow.md, design.md | Acceptable Risk — `scripts/` is a standard convention; no existing scripts to conflict with |
| Compiled file freshness | release-workflow.md | Acceptable Risk — finalize enforces recompilation; dev script available; stale files are a dev-only concern |
| Claude YAML frontmatter parsing | workflow-contract.md (existing) | Acceptable Risk — unchanged |
| Agent tool availability | workflow-contract.md (existing) | Acceptable Risk — unchanged |
| Sub-agent file access | workflow-contract.md (existing) | Acceptable Risk — unchanged |

No Blocking assumptions. No Needs Clarification.

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any changed files. PASS.
