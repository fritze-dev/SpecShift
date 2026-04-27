## Audit: Multi-Target Distribution

### Summary

| Dimension | Status |
|-----------|--------|
| Tasks | 17 / 17 in-apply tasks complete (sections 1.x and 2.x); section 3 (QA) executes here; section 4 (Standard Tasks) deferred to finalize |
| Requirements | 27 / 27 verified (8 in `multi-target-distribution`, 7 in `project-init` modified, 12 in `release-workflow` modified — see Coverage below) |
| Scenarios | 53 / 53 covered by manual test plan in `tests.md` (auto-execution N/A — Markdown plugin, manual mode per CONSTITUTION) |
| Tests | Manual test plan complete; verifiable Success Metrics (G1, G2, G5, G6, G8, G9) executed in this session — all PASS; design-verified metrics (G3, G4, G7) marked PASS via inspection |
| Scope | Clean — all changed files trace to the proposal's Impact section, the design's Architecture & Components, or the tasks list |

### Branch Diff Snapshot

22 modified / 7 added / 7 deleted (excl. compile-output churn under `./skills/specshift/`):

- **Added** (project files): `src/VERSION`, `src/templates/agents.md`, `AGENTS.md`, `.claude-plugin/plugin.json` (moved from `src/`), `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`, `./skills/specshift/` (entire compiled tree)
- **Modified** (project files): `.claude-plugin/marketplace.json` (`source: "./"`), `.github/workflows/release.yml` (trigger + version-extract), `.specshift/CONSTITUTION.md`, `.specshift/WORKFLOW.md`, `CLAUDE.md` (collapsed to stub), `README.md`, `docs/specs/artifact-pipeline.md`, `docs/specs/change-workspace.md`, `docs/specs/multi-target-distribution.md` (new), `docs/specs/project-init.md`, `docs/specs/release-workflow.md`, `scripts/compile-skills.sh` (rewritten), `src/actions/init.md`, `src/templates/claude.md` (collapsed to import-stub), `src/templates/workflow.md`
- **Deleted**: `src/.claude-plugin/plugin.json` (moved to root), the entire `.claude/skills/specshift/` legacy compiled tree (replaced by `./skills/specshift/`)
- **Plus** the standard six change-artifact files under `.specshift/changes/2026-04-27-multi-target-distribution/`

### Requirement Verification

#### `multi-target-distribution` (NEW, 8 requirements)

| # | Requirement | Implementing Artifact(s) |
|---|-------------|--------------------------|
| 1 | Per-Target Plugin Manifest | `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json` (both at root, hand-edited); `src/.claude-plugin/` deleted |
| 2 | Shared Skill Tree at Repository Root | `./skills/specshift/{SKILL.md,templates,actions}` exists; `.claude/skills/specshift/` removed by compile script |
| 3 | Codex Marketplace Entry | `.agents/plugins/marketplace.json` (hand-edited at root); compile script `stamp_version` covers `.plugins[].version` |
| 4 | Bootstrap Single Source of Truth Pattern | `src/templates/agents.md` (full body); `src/templates/claude.md` collapsed to `@AGENTS.md` import; both Smart Templates with `template-version` and `generates` frontmatter |
| 5 | Agnostic Skill Body | `grep -rn '${CLAUDE_PLUGIN_ROOT}' skills/specshift/` returns 0 hits; `grep -rn '\.claude/worktrees' skills/specshift/` returns 0 hits; one shared compiled tree (no per-target variants) |
| 6 | Multi-Target Install Documentation | `README.md` has `### Claude Code` and `### OpenAI Codex CLI` sections at the same heading level |
| 7 | Version Source of Truth | `src/VERSION` exists, single line `0.2.4-beta`; CONSTITUTION + AGENTS.md File Ownership both name `src/VERSION` as the SoT |
| 8 | Symmetric Version Stamping with Cross-Check | `scripts/compile-skills.sh` `stamp_version` function: jq-edit + post-stamp re-read + non-zero exit on mismatch; verified by inspection of the function body and by the live build (4 root files all at `0.2.4-beta` after compile) |

#### `project-init` (modified — Bootstrap Files Generation requirement)

| # | Requirement | Implementing Artifact(s) |
|---|-------------|--------------------------|
| 9 | Install Workflow (updated) | spec text now references both `agents.md` and `claude.md` bootstrap templates (item 4 of the requirement); init scenarios mention both files |
| 10 | Bootstrap Files Generation (new requirement, replaces CLAUDE.md Bootstrap) | `src/actions/init.md` now links the requirement; `src/templates/workflow.md` init Action body details the both-files behavior; project AGENTS.md + CLAUDE.md instantiate the pattern |
| 11–15 | Existing requirements (Template Merge on Re-Init, Recovery Mode, etc.) | Tool-agnostic prose updates only; behavior unchanged |

#### `release-workflow` (modified — version SoT + multi-target stamping)

| # | Requirement | Implementing Artifact(s) |
|---|-------------|--------------------------|
| 16 | Auto Patch Version Bump | spec rewritten to point at `src/VERSION`; `.specshift/CONSTITUTION.md` Conventions updated to match |
| 17 | Version Sync Between Plugin Files | spec rewritten for four-file symmetric stamping; `scripts/compile-skills.sh` `stamp_version` implements |
| 18 | Manual Minor and Major Release Process | spec rewritten to "edit `src/VERSION` + recompile + push"; README "Multi-Target Distribution" section reflects |
| 19 | Source and Release Directory Structure | spec rewritten for `src/VERSION` SoT, manifests at root, shared `./skills/`; `.specshift/CONSTITUTION.md` Conventions match |
| 20 | Marketplace Source Configuration | spec rewritten for `./`/shared-tree paths; `.claude-plugin/marketplace.json` source updated |
| 21 | Repository Layout Separation | spec rewritten for new layout; physical layout matches |
| 22 | AOT Skill Compilation | spec rewritten for `src/VERSION` read + four-file stamping + shared tree at `./skills/`; compile script implements |
| 23 | Compiled Action File Contract | path updated `./skills/specshift/actions/`; compile output matches |
| 24 | Dev Sync Script | spec rewritten — `jq` is hard preflight; compile script enforces |
| 25 | Automated GitHub Release via CI | spec rewritten to trigger on `src/VERSION`; `.github/workflows/release.yml` updated |
| 26 | Changelog Version Headers | spec updated to read version from `src/VERSION`; finalize logic compatible |
| 27 | Other unchanged requirements (Skill Immutability, Consumer Update Process, etc.) | spec updates are wording-only (per-target generalization); behavior unchanged |

### Scenario Coverage

53 spec scenarios → 53 manual test items in `tests.md`. Manual mode per CONSTITUTION `## Testing` (no executable framework). Auto-verifiable subset (file-system shape, grep checks, version equality, idempotent build) all PASS in this session — see "Verifiable Metric Checks" below.

### Design Adherence

- **G1 — single-source bootstrap**: `grep -rl "All changes to this project MUST go through the spec-driven workflow" src/templates/` returns exactly `src/templates/agents.md`. **PASS.**
- **G2 — symmetric versions**: `jq -r '.version // .plugins[0].version' .{claude,codex}-plugin/{plugin,marketplace}.json .agents/plugins/marketplace.json; cat src/VERSION` sorted-uniq returns one value (`0.2.4-beta`). **PASS.**
- **G3 — agnostic SoT**: design + tasks specify the bump touches `src/VERSION` only; no manifest is the SoT per CONSTITUTION; verified by reading `scripts/compile-skills.sh` (the four root manifest version fields are written, not read, by the script). **PASS by design.**
- **G4 — cross-check enforces consistency**: `stamp_version` function in the script re-reads each file post-stamp and `exit 1` on mismatch. Verified by inspection of the function body. **PASS by design.**
- **G5 — one shared skill tree**: `find . -path ./node_modules -prune -o -name 'SKILL.md' -print` returns exactly two paths (`./src/skills/specshift/SKILL.md`, `./skills/specshift/SKILL.md`). **PASS.**
- **G6 — tool-agnostic compiled body**: `grep -rn '${CLAUDE_PLUGIN_ROOT}' skills/specshift/` returns 0 hits; `grep -rn '\.claude/worktrees' skills/specshift/` returns 0 hits (after spec edits in `artifact-pipeline.md` + `change-workspace.md`). **PASS.**
- **G7 — fresh init both files**: scenario test in `tests.md` (manual; not automatable in this session without a temp project). Implementation is in `src/templates/workflow.md` Action: init body and CONSTITUTION Conventions. **PASS by design.**
- **G8 — README both install paths**: `grep -nE '^### (Claude Code|OpenAI Codex CLI)$' README.md` returns two matching headings. **PASS.**
- **G9 — idempotent build**: ran `bash scripts/compile-skills.sh` twice consecutively; second run's diff vs. first run is empty (no working-tree change between runs). **PASS.**

### Scope Control

Every changed file traces to:
- The proposal's Impact section, OR
- The design's Architecture & Components, OR
- The tasks list (1.x foundation + 2.x implementation), OR
- A spec edit explicitly mandated by the agnostic-skill-body requirement (`docs/specs/artifact-pipeline.md`, `docs/specs/change-workspace.md` for the `.claude/worktrees → .specshift/worktrees` agnostic update — these are spec-level changes triggered by the new agnostic baseline and were noted in the design's Migration Plan via the "specs touched" subsection)

No untraced files. Scope clean.

### Preflight Side-Effect Coverage

- ✓ Existing Claude Code consumers — addressed via README's BREAKING note and CONSTITUTION's Local Development convention (one-time `marketplace update`)
- ✓ `.specshift/WORKFLOW.md` synced from updated `src/templates/workflow.md` — done; project-specific overrides preserved (`worktree.enabled: true`, `auto_approve: true`, `review.request_review: copilot`); worktree path migrated from `.claude/worktrees/` to `.specshift/worktrees/` consistently
- ✓ `.github/workflows/release.yml` trigger updated from `src/.claude-plugin/plugin.json` to `src/VERSION` — done
- ✓ `README.md` Quick Start / Project Structure / Architecture / Multi-Target Distribution sections updated — done
- ✓ Skill compilation legacy tree (`.claude/skills/specshift/`) removed by compile script — verified
- ✓ Local development plugin reload — documented in CONSTITUTION
- ✓ `CHANGELOG.md` entry — deferred to section 4 (`specshift finalize` step)

### Findings

#### CRITICAL
*(none)*

#### WARNING
*(none)*

#### SUGGESTION

- **Live install verification on real Codex installation deferred to a follow-up change** — the spec scenarios cover the install flow but execution against an actual `codex /plugins` install was not performed in this session. Recommended: open a tracking task to verify on the next maintainer-side Codex CLI session.

### Verdict

**PASS** — proceed to `specshift finalize` (auto-dispatched per `auto_approve: true`).
