---
status: active
branch: codex-plugin-support
worktree: .claude/worktrees/codex-plugin-support
capabilities:
  new: [multi-target-distribution]
  modified: [project-init]
  removed: []
---

## Why

SpecShift today only ships as a Claude Code plugin. OpenAI Codex CLI now has a comparable plugin model with skill-folder discovery, plugin manifests, and a marketplace. With the Shopify-AI-Toolkit demonstrating that one repo can serve multiple AI-coding-tool targets cleanly via side-by-side manifest dirs and a shared `skills/` tree, the path to doubling SpecShift's reach is short — the SKILL.md frontmatter is already Codex-compatible, and the workflow content is tool-agnostic. The remaining work is packaging.

## What Changes

- **Add Codex plugin manifest** at `src/.codex-plugin/plugin.json` (source) and `.codex-plugin/plugin.json` (compiled output at repo root) with Codex-specific schema (`name`, `version`, `description`, `skills`, `interface`).
- **Migrate compile output to Shopify-flat layout (BREAKING for marketplace consumers):** Compiled skill tree moves from `.claude/skills/specshift/` to `./skills/specshift/` at the repo root. Both manifests reference this shared tree.
- **Update Claude marketplace source:** `.claude-plugin/marketplace.json` `source` field changes from `./.claude` to `./` so Claude Code resolves `./skills/specshift/` correctly. Existing installs run `claude plugin marketplace update specshift` to pick up the new layout.
- **Add Codex marketplace entry** at `.agents/plugins/marketplace.json` so the plugin is discoverable via `codex /plugins`.
- **Restructure bootstrap templates as Single Source of Truth:**
  - New `src/templates/agents.md` carries the **full bootstrap content** (workflow rules, plan-mode regulation, routing rule, knowledge management, file ownership). Generates `AGENTS.md`.
  - Existing `src/templates/claude.md` is reduced to a **`@AGENTS.md` import stub** with optional Claude-specific section. Generates `CLAUDE.md`.
- **Modify `specshift init`** to write **both** `AGENTS.md` (full body) and `CLAUDE.md` (import stub) on every project setup — no environment detection. Codex reads AGENTS.md natively; Claude Code reads CLAUDE.md and expands the `@AGENTS.md` import.
- **Extend `scripts/compile-skills.sh`** to: (1) emit both manifests at repo root (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`), (2) write the shared skill tree to `./skills/specshift/`, (3) stamp `plugin-version` into both manifests, (4) write the Codex marketplace file `.agents/plugins/marketplace.json`.
- **Update CONSTITUTION** rules in `.specshift/CONSTITUTION.md`: release-directory location reference changes from `.claude/skills/specshift/` to `./skills/specshift/`; plugin-source-layout convention updates marketplace source path; new convention entry for Codex manifest source location.
- **Update README** with two install sections: existing Claude Code path + new `codex /plugins` path.

## Capabilities

### New Capabilities
- `multi-target-distribution`: How SpecShift packages and ships to multiple AI-coding-tool targets (Claude Code, Codex) from a single repository. Covers manifest parity, shared skill-tree layout, target-specific marketplace files, and compile-time guarantees that both targets receive equivalent artifacts.

### Modified Capabilities
- `project-init`: The init action gains a requirement that it generates both `AGENTS.md` (full content) and `CLAUDE.md` (import stub via `@AGENTS.md`) instead of only `CLAUDE.md`. Existing init requirements (codebase scan, constitution generation, drift verification, etc.) remain unchanged.

### Removed Capabilities
*(none)*

### Consolidation Check

1. **Existing specs reviewed:** artifact-pipeline, change-workspace, constitution-management, documentation, human-approval-gate, project-init, quality-gates, release-workflow, review-lifecycle, roadmap-tracking, spec-format, task-implementation, test-generation, three-layer-architecture, workflow-contract.

2. **Overlap assessment for `multi-target-distribution`:**
   - Closest existing spec: `release-workflow` (covers post-merge changelog, version bump, GitHub releases). Distinct because release-workflow is about *what happens after merge* whereas multi-target-distribution is about *how the plugin is laid out and packaged for consumption*. Different actor (maintainer vs end-user), different trigger (merge vs install).
   - Closest secondary: `three-layer-architecture` (covers CONSTITUTION → WORKFLOW → Templates → Router layering). Distinct because layering is about internal logical structure; distribution is about external packaging targets.
   - Neither absorbs the new requirements (Codex manifest schema, shared skill-tree layout, marketplace file format, compile-time multi-target output, both-bootstrap-file generation), so a new spec is justified.

3. **Merge assessment:** Only one new capability proposed. No pair to evaluate.

4. **Requirements count:** `multi-target-distribution` will define ~5 requirements (Manifest Parity, Shared Skill Tree at Repo Root, Both-Files Bootstrap Generation, Codex Marketplace Entry, README Multi-Target Install). All 3+ check ✓.

## Impact

- **Source files (`src/`):** new `src/.codex-plugin/plugin.json`, new `src/templates/agents.md`; modified `src/templates/claude.md` (body collapsed to import stub), `src/templates/workflow.md` (init instruction adds AGENTS.md generation).
- **Build script (`scripts/compile-skills.sh`):** path migration `.claude/skills/` → `./skills/`; second manifest copy block; Codex marketplace file write.
- **Repo layout:** `.codex-plugin/`, `.agents/plugins/`, `./skills/specshift/` directories appear at root (compiled). Existing `.claude/skills/specshift/` directory is removed (replaced by `./skills/specshift/`).
- **Marketplace (`.claude-plugin/marketplace.json`):** `source` changes `./.claude` → `./`. Claude Code consumers run a marketplace update to refetch.
- **Specs (`docs/specs/`):** new `multi-target-distribution.md`; modified `project-init.md` (template-version bump).
- **Constitution (`.specshift/CONSTITUTION.md`):** Architecture Rules and Conventions sections updated for new release location and marketplace source path.
- **README:** Codex install section added.
- **Project's WORKFLOW.md (`.specshift/WORKFLOW.md`):** synced from updated `src/templates/workflow.md` per template-synchronization convention.
- **External APIs / dependencies:** none added or removed.

## Scope & Boundaries

**In scope:**
- Codex plugin manifest source + compiled output
- Compile-script multi-target migration
- Shared skill-tree layout at repo root
- Bootstrap-template restructure (single-source-of-truth in agents.md, stub in claude.md)
- Codex marketplace entry
- README multi-target install instructions
- Constitution updates for new layout
- Spec updates: new multi-target-distribution + modified project-init

**Out of scope (explicit non-goals):**
- **Codex hooks setup** — Codex hooks live in user `~/.codex/config.toml`, not plugin-installable. Workflow-routing enforcement remains text-only via AGENTS.md (same as today on Claude side).
- **Codex custom prompts** (`~/.codex/prompts/`) — upstream-deprecated; skill is the only entry point.
- **MCP servers (`.mcp.json`)** — SpecShift currently uses no MCP tools.
- **Branding assets** (`interface.logo`, `composerIcon`, `brandColor`) — Codex listing works without them; deferred to a follow-up change for polish.
- **Cursor / Gemini / other targets** — Shopify ships those too; SpecShift stops at Claude + Codex for Phase 1.
- **Single-file consolidation** (eliminating CLAUDE.md entirely) — keeps Claude Code's documented memory pattern, avoids breaking existing installs that expect CLAUDE.md.
- **Environment detection in init** — both files always written; CLAUDE.md is a trivial stub that cannot drift.
- **Changes to non-bootstrap templates** (research/proposal/specs/design/preflight/tests/tasks/audit) — these are tool-agnostic and need no edits.
- **Changes to action files** (`src/actions/*.md`) — already tool-agnostic.
- **Marketplace publishing automation** — manual `gh release` flow continues.
