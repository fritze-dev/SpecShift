---
status: review
branch: codex-plugin-clean
capabilities:
  new: [multi-target-distribution]
  modified: [project-init, release-workflow]
  removed: []
---

## Why

SpecShift today only ships as a Claude Code plugin. OpenAI Codex CLI now has a comparable plugin model (`.codex-plugin/plugin.json`, skill folders, marketplace via `codex /plugins`), and the Shopify-AI-Toolkit demonstrates that one repo can serve multiple AI-coding-tool targets cleanly via side-by-side manifest dirs and a shared `skills/` tree. The SKILL.md frontmatter is already Codex-compatible and the workflow content is tool-agnostic, so the remaining work is packaging — and, on the way, removing two pieces of asymmetry that the existing single-target layout has accumulated: the version source of truth living inside the Claude per-target manifest, and the bootstrap template generating only `CLAUDE.md`.

## What Changes

- **Add Codex plugin manifest** at `.codex-plugin/plugin.json` (hand-edited at the repo root) with Codex-specific schema (`name`, `version`, `description`, `skills`, `interface` block including `displayName`, `shortDescription`, `longDescription`, `developerName`, `category`, `capabilities`, `defaultPrompt`, `brandColor`).
- **Migrate to Shopify-flat layout (BREAKING for marketplace consumers):** Compiled skill tree moves from `.claude/skills/specshift/` to `./skills/specshift/` at the repo root. Both manifests reference this shared tree.
- **Update Claude marketplace source:** `.claude-plugin/marketplace.json` `source` field changes from `./.claude` to `./` so Claude Code resolves `./skills/specshift/` correctly. Existing installs run `claude plugin marketplace update specshift` to pick up the new layout.
- **Add Codex marketplace entry** at `.agents/plugins/marketplace.json` (hand-edited at the repo root) so the plugin is discoverable via `codex /plugins`.
- **Move plugin manifests out of `src/` to the repo root.** `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json` are hand-edited per-target metadata and live exclusively at the root. The `src/.claude-plugin/` indirection is removed.
- **Restructure bootstrap templates as Single Source of Truth:**
  - New `src/templates/agents.md` carries the **full bootstrap content** (workflow rules, plan-mode regulation, routing rule, knowledge management, file ownership). Generates `AGENTS.md`.
  - Existing `src/templates/claude.md` is reduced to a **`@AGENTS.md` import stub**. Generates `CLAUDE.md`.
- **Modify `specshift init`** to write **both** `AGENTS.md` (full body) and `CLAUDE.md` (import stub) on every fresh project setup — no environment detection. Codex reads `AGENTS.md` natively; Claude Code reads `CLAUDE.md` and expands the `@AGENTS.md` import. Existing files are never overwritten on re-init.
- **Introduce `src/VERSION` as the single version source of truth.** Plain-text file, one line, SemVer. The compile script reads it and stamps the version into all four root manifest/marketplace files.
- **Extend `scripts/compile-skills.sh`** to: (1) read the version from `src/VERSION` (not a manifest), (2) stamp all four root files (`{.claude-plugin,.codex-plugin}/plugin.json`, `.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json`) symmetrically via `jq` while preserving all non-version fields and values (JSON formatting may be normalized by `jq`), (3) cross-check that each emitted version equals the SoT post-stamp (fail the build on drift), (4) emit one shared agnostic skill tree to `./skills/specshift/`.
- **Update `specshift finalize` version-bump step** to edit `src/VERSION` only — manifest version fields are stamped at compile time.
- **Update CONSTITUTION** rules in `.specshift/CONSTITUTION.md`: release-directory location, plugin-source layout (manifests at root), version-bump convention (`src/VERSION` as SoT), agent-instructions convention (`AGENTS.md` as SoT, `CLAUDE.md` as import stub).
- **Update README** with two install sections (Claude Code + Codex) and the new layout description.

## Capabilities

### New Capabilities
- `multi-target-distribution`: How SpecShift packages and ships to multiple AI-coding-tool targets (Claude Code, Codex) from a single repository. Covers manifest layout (hand-edited at root, per-target), shared skill tree at the repo root, target-specific marketplace files, the `src/VERSION` version source of truth, and compile-time version-stamping with cross-check.

### Modified Capabilities
- `project-init`: The init action gains a requirement that it generates both `AGENTS.md` (full content) and `CLAUDE.md` (import stub via `@AGENTS.md`) instead of only `CLAUDE.md`. Existing init requirements (codebase scan, constitution generation, drift verification, etc.) remain unchanged.
- `release-workflow`: The Auto-Patch-Bump and Version-Sync requirements change to point at `src/VERSION` as the source of truth and at the compile-script's symmetric stamping into all four root manifests/marketplaces. Source/release-directory and AOT-compilation requirements are updated for the new multi-target layout.

### Removed Capabilities
*(none)*

### Consolidation Check

1. **Existing specs reviewed:** artifact-pipeline, change-workspace, constitution-management, documentation, human-approval-gate, project-init, quality-gates, release-workflow, review-lifecycle, roadmap-tracking, spec-format, task-implementation, test-generation, three-layer-architecture, workflow-contract.

2. **Overlap assessment for `multi-target-distribution`:**
   - Closest existing spec: `release-workflow` (covers post-merge changelog, version bump, GitHub releases). Distinct because release-workflow is about *what happens after merge*; multi-target-distribution is about *how the plugin is laid out and packaged for consumption*. Different actor (maintainer vs end-user), different trigger (merge vs install).
   - Closest secondary: `three-layer-architecture` (covers CONSTITUTION → WORKFLOW → Templates → Router layering). Distinct because layering is about internal logical structure; distribution is about external packaging targets.
   - Neither absorbs the new requirements (Codex manifest schema, hand-edited-at-root manifests, shared skill-tree layout, marketplace file format, compile-time multi-target output, both-bootstrap-file generation, `src/VERSION` SoT), so a new spec is justified.

3. **Merge assessment:** Only one new capability proposed. No pair to evaluate.

4. **Requirements count:** `multi-target-distribution` will define ~7 requirements (Manifest Layout at Repo Root, Shared Skill Tree at Repo Root, Both-Files Bootstrap Generation, Codex Marketplace Entry, Agnostic Skill Body, Version Source of Truth, Symmetric Version Stamping with Cross-Check). All 3+ check ✓.

## Impact

- **Source files (`src/`):** new `src/VERSION`; new `src/templates/agents.md`; modified `src/templates/claude.md` (body collapsed to import stub); modified `src/templates/workflow.md` (init instruction adds AGENTS.md generation); deletion of `src/.claude-plugin/` (manifests now live at root only).
- **Root manifests / marketplaces:** new `.codex-plugin/plugin.json`; new `.agents/plugins/marketplace.json`; modified `.claude-plugin/plugin.json` (no `version` field — read from `src/VERSION` and re-stamped at compile time); modified `.claude-plugin/marketplace.json` (`source` `./.claude` → `./`).
- **Build script (`scripts/compile-skills.sh`):** rewritten version-handling — read from `src/VERSION`, symmetric jq-stamping into all four root files, post-stamp cross-check; path migration `.claude/skills/` → `./skills/`; jq becomes a hard preflight requirement.
- **Repo layout:** `.codex-plugin/`, `.agents/plugins/`, `./skills/specshift/` directories appear at the root (compiled output for skills, hand-edited for manifests). Existing `.claude/skills/specshift/` directory is removed (replaced by `./skills/specshift/`).
- **Specs (`docs/specs/`):** new `multi-target-distribution.md`; modified `project-init.md` (Bootstrap Files Generation requirement); modified `release-workflow.md` (Auto-Patch-Bump, Version-Sync, Source/Release-Directory-Structure, AOT-Skill-Compilation requirements).
- **Constitution (`.specshift/CONSTITUTION.md`):** Architecture Rules and Conventions sections updated for new release location, manifest layout at root, `src/VERSION` as version SoT, and `AGENTS.md` as agent-instructions SoT.
- **Action specs (`src/actions/`):** modified `init.md` (writes both AGENTS.md and CLAUDE.md), `finalize.md` (version bump edits `src/VERSION` only).
- **README:** Multi-target install section (Claude Code + Codex paths) + project-structure update for the flat layout.
- **Project's WORKFLOW.md (`.specshift/WORKFLOW.md`):** synced from updated `src/templates/workflow.md` per template-synchronization convention.
- **Project's AGENTS.md / CLAUDE.md:** AGENTS.md takes the project's existing instructions content; CLAUDE.md becomes a one-line `@AGENTS.md` import stub.
- **External APIs / dependencies:** `jq` becomes a hard build requirement (already present on the maintainer's system; documented).

## Scope & Boundaries

**In scope:**
- Codex plugin manifest source + marketplace entry + compiled skill tree
- Compile-script multi-target migration with symmetric version stamping and cross-check
- Shared skill-tree layout at repo root (Shopify-flat)
- Manifest layout at repo root (no `src/` indirection for hand-edited per-target metadata)
- Bootstrap-template restructure (`agents.md` as SoT, `claude.md` as import stub)
- Both-bootstrap-files generation in `specshift init`
- `src/VERSION` as the single version source of truth
- `finalize` version-bump editing `src/VERSION` only
- README multi-target install instructions
- Constitution updates for the new layout and version-bump convention
- Spec updates: new `multi-target-distribution` + modified `project-init` + modified `release-workflow`
- Capability docs regenerated from the updated specs

**Out of scope (explicit non-goals):**
- **Codex hooks setup** — Codex hooks live in user `~/.codex/config.toml`, not plugin-installable. Workflow-routing enforcement remains text-only via AGENTS.md.
- **Codex custom prompts** (`~/.codex/prompts/`) — upstream-deprecated; the skill is the only entry point.
- **MCP servers (`.mcp.json`)** — SpecShift currently uses no MCP tools.
- **Cursor / Gemini / other targets** — Shopify ships those too; SpecShift stops at Claude + Codex for this change.
- **Single-file consolidation** (eliminating CLAUDE.md entirely) — keeps Claude Code's documented memory pattern.
- **Environment detection in init** — both files always written; CLAUDE.md is a trivial stub that cannot drift.
- **Marketplace publishing automation** — manual `gh release` flow continues.
- **Branding assets** (logo, screenshots) — Codex listing works without them; deferred to a follow-up change.
- **Live-install verification on a real Codex installation** — covered by the existing release-workflow tests on the Claude side and the manual `codex /plugins` install path documented in README; automation deferred.
