---
status: active
branch: codex-plugin-support
worktree: .claude/worktrees/codex-plugin-support
capabilities:
  new: [multi-target-distribution]
  modified: [project-init, release-workflow]
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
- **Cursor / Gemini / other targets** — Shopify ships those too; SpecShift stops at Claude + Codex for Phase 1.
- **Single-file consolidation** (eliminating CLAUDE.md entirely) — keeps Claude Code's documented memory pattern, avoids breaking existing installs that expect CLAUDE.md.
- **Environment detection in init** — both files always written; CLAUDE.md is a trivial stub that cannot drift.
- **Marketplace publishing automation** — manual `gh release` flow continues.

## Scope Extension (2026-04-27 — second pass)

After PR #45 review, gaps versus PR #44 surfaced. Rather than open a follow-up change, the scope is extended in place. The five items below align the implementation with the spirit of the original proposal (one shared skill body, two manifests, no Claude-only artifacts) and remove drift introduced during the first pass.

### Why (Extension)

The first-pass implementation produced one shared compiled skill tree, but the source content (SKILL.md, templates, action specs) still hard-codes Claude-Code-specific tokens (`${CLAUDE_PLUGIN_ROOT}`, `Claude Code Web`, `.claude/worktrees`). Codex skill bodies reach the model as instruction text and there is no Codex equivalent of `${CLAUDE_PLUGIN_ROOT}` (verified: `developers.openai.com/codex/skills` and `Shopify-AI-Toolkit` both use bare relative paths). The Codex-side skill therefore reads literal Claude tokens that the model cannot resolve. The agnostic baseline is to make the source itself tool-neutral so the same compiled artifact serves both targets without a per-target rewrite pass.

Separately, plugin manifests live under `src/.claude-plugin/` and `src/.codex-plugin/` because of legacy single-target layout where `.claude-plugin/plugin.json` was generated *into* the compiled `.claude/` tree. After the Shopify-flat migration, both manifests are emitted at the repo root and the `src/` indirection no longer carries weight — `marketplace.json` is already hand-edited at the root, plugin manifests should follow.

Finally, the `release-workflow` spec was not updated to reference the multi-target layout; `src/actions/finalize.md` still links only to single-target requirements; the Codex manifest is missing the metadata fields the Codex `/plugins` UI uses for discoverability.

### What Changes (Extension)

- **Tool-agnostic source content.** Replace tool-specific tokens in compiled-into-skill files with prose or neutral phrasing:
  - `${CLAUDE_PLUGIN_ROOT}/templates/...` → "the plugin's `templates/` directory" (prose; resolved by the model at runtime against either runtime's plugin install location).
  - `Claude Code Web` → "ephemeral agent sessions" or "stateless agent sessions" (User Story phrasing in `review-lifecycle.md`).
  - `.claude/worktrees` (in spec scenarios that compile into the skill) → `.specshift/worktrees` or generic placeholder. Project-instance `.specshift/WORKFLOW.md` `path_pattern` is project config and remains as configured.
  - `CLAUDE.md` references in compiled-into-skill files: where they refer to the bootstrap memory file pattern that AGENTS.md now satisfies, generalize to "AGENTS.md / CLAUDE.md"; where they refer specifically to Claude Code's own memory file, leave as-is.
- **Compiler emits one agnostic skill tree.** The compiled skill tree under `./skills/specshift/` is the same artifact that both manifests reference. No per-target rewrite passes (no `write_codex_skill`, no `rewrite_codex_file`). If a residual Claude-only token slips through, it shows up in source review, not as a runtime divergence between targets.
- **Plugin manifests at repo root.** Move `src/.claude-plugin/plugin.json` → `.claude-plugin/plugin.json` and `src/.codex-plugin/plugin.json` → `.codex-plugin/plugin.json`. Both become hand-edited authoritative sources at the root, side-by-side with `.claude-plugin/marketplace.json`. Compile script reduces to: read Claude manifest version → stamp into Codex manifest → stamp into `.agents/plugins/marketplace.json` → validate consistency. No `cp` of manifests.
- **Codex manifest enriched with agnostic + UI fields.** `.codex-plugin/plugin.json` gains the same agnostic metadata the Claude manifest carries (`author`, `repository`, `license`, `keywords`) plus Codex-UI-specific fields (`longDescription`, `developerName`, `websiteURL`, `defaultPrompt[]`, `brandColor`, `screenshots[]`). `interface.capabilities` widened from `["Read", "Edit", "Write", "Bash"]` is already correct; agnostic fields stay in sync via review.
- **`release-workflow` spec multi-target alignment.** Update `docs/specs/release-workflow.md` so its requirements (Auto Patch Version Bump, Version Sync Between Plugin Files, Manual Minor and Major Release Process, Source and Release Directory Structure, Marketplace Source Configuration, AOT Skill Compilation, Compiled Action File Contract, Repository Layout Separation, Dev Sync Script) describe the multi-target reality instead of `.claude/skills/specshift/`-only language. Add Codex-relevant requirement links to `src/actions/finalize.md`. Regenerate `docs/capabilities/release-workflow.md` after spec edits.
- **Bootstrap fresh-init narrowed to AGENTS.md only.** First-pass behavior unconditionally generated both `AGENTS.md` and `CLAUDE.md`. New behavior: on a fresh project (neither file exists), generate only `AGENTS.md` (the agnostic single source of truth). Do not generate `CLAUDE.md` automatically — Claude Code consumers who want the documented memory-import pattern create `CLAUDE.md` themselves (the `claude.md` Smart Template stays in the plugin so users have a one-line stub to copy). On re-init, existing files are checked for standard sections and otherwise left untouched; the missing partner file is **not** auto-generated. This makes init's footprint minimal and avoids forcing a stub onto Codex-only or agnostic projects. The existing "AGENTS only exists" / "CLAUDE only exists" / "Both exist" scenarios are revised accordingly.

### Capabilities (Extension)

- **Modified**: `release-workflow` (multi-target alignment), `project-init` (agnostic phrasing of plugin-root references + bootstrap narrowed to AGENTS.md on fresh init, CLAUDE.md no longer auto-generated).

### Impact (Extension)

- **Sources changed**: `src/skills/specshift/SKILL.md` (if any tool-specific tokens), `src/templates/workflow.md`, `src/actions/finalize.md` (new requirement links), `docs/specs/project-init.md`, `docs/specs/release-workflow.md`, `docs/specs/multi-target-distribution.md`, `docs/specs/review-lifecycle.md` (User Story wording), `docs/specs/three-layer-architecture.md` (plugin-host wording), `docs/specs/documentation.md` (translation rule mentions both products).
- **Manifests moved**: `src/.claude-plugin/`, `src/.codex-plugin/` deleted; `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json` hand-edited at root.
- **Compile script simplified**: removes manifest copy block; adds version stamp + consistency check; drops the `src/` indirection and any per-target rewrite logic.
- **Constitution updated**: Plugin source layout convention reflects manifest-at-root; release directory wording stays.
- **README, AGENTS.md, capability docs**: align references to new manifest locations and agnostic descriptions.

### Out of Scope (Extension)

- **Per-target rewrite passes in the compiler.** Decided against. Source agnostic-ization is the right place to handle target neutrality.
- **HTML-escape fix for nested `<!-- ASSUMPTION -->` / `<!-- REVIEW -->` markers** in templates — no rendering issues observed; not worth the template-version churn.
- **Bootstrap-template approach change.** PR-45's pattern (`agents.md` shared, `claude.md` as `@AGENTS.md` import stub) stays; not reverted to PR-44's `src/codex/templates/agents.md` structure.
- **Deletion of `multi-target-distribution.md` in favor of folding everything into `release-workflow.md`** — keep both, with `multi-target-distribution.md` describing the layout invariants and `release-workflow.md` describing the lifecycle mechanics.
- **Version bump.** This is a scope extension within the running change; version stays `0.2.5-beta` until finalize.

## Scope Reversal (2026-04-27 — third pass)

The second pass narrowed fresh init to write only `AGENTS.md` (Option A — CLAUDE.md is opt-in via the still-shipped `claude.md` stub). On reflection of ADR-003's rationale, that narrowing was rejected before the PR merged. The reversal restores the symmetric behavior described in the original proposal (lines 23–24 above).

### Why (Reversal)

The narrowing was maintainer-zentriert ("narrower bootstrap"), not user-centered:

1. **Stille Nicht-Funktion**: A user running `specshift init` under Claude Code without `CLAUDE.md` does not get an active `@AGENTS.md` memory-import — Claude Code reads no rules, silently. The fix (copy a one-line stub) is trivial, but the failure mode is invisible.
2. **Asymmetry**: one file always, the other never — no coherent mental model.
3. **Zero-Cost Symmetry**: a one-line `CLAUDE.md` containing `@AGENTS.md` in a Codex-only project costs nothing — Codex does not read it. If the user later adds Claude Code, the memory-import pattern works without touch-up.
4. **SSOT preserved**: the stub is a *pointer*, not a content duplicate. Normative rules live only in `AGENTS.md`. ADR-003's core decision ("no runtime detection") stays untouched.

### What Changes (Reversal)

- **`specshift init` fresh-init behavior** (in `src/templates/workflow.md` `## Action: init`): on a project with no `AGENTS.md` and no `CLAUDE.md`, generate **both** files — `AGENTS.md` from `templates/agents.md` (full body) and `CLAUDE.md` from `templates/claude.md` (one-line `@AGENTS.md` stub). On re-init, existing files are never overwritten; standard-sections checks remain passive WARNING-only (the user decides in dialog with the agent whether to run a follow-up `specshift propose` to add missing sections).
- **`docs/specs/project-init.md`** §5 "Bootstrap Files Generation" rewritten to specify both files on fresh init; v7 → v8.
- **`docs/specs/multi-target-distribution.md`** §4 "Bootstrap Single Source of Truth Pattern" updated to describe both-file generation while preserving SSOT through the stub-as-pointer model; v2 → v3.
- **`src/templates/workflow.md`** init-Action instruction updated; template-version 10 → 11. `.specshift/WORKFLOW.md` synced.
- **README, project AGENTS.md, .specshift/CONSTITUTION.md, CHANGELOG.md (Hardening Pass entry)** updated to remove "init does not auto-generate CLAUDE.md" wording and document the symmetric behavior.

### Capabilities (Reversal)

- **Modified**: `project-init` (Bootstrap Files Generation), `multi-target-distribution` (Bootstrap SSOT Pattern). No new or removed capabilities.

### Out of Scope (Reversal)

- **Runtime detection** (Claude Code vs Codex via env vars) — remains rejected by ADR-003.
- **Auto-merge or confirmed-merge of existing bootstrap files** on re-init — re-init stays passive (WARNING-only). User edits remain authoritative.
- **Routing-pflicht in the WARNING output** ("run `specshift propose` now") — WARNING is a passive signal; the user decides next steps in dialog with the agent.
- **Version bump.** Reversal lands within the same `codex-plugin-support` change, in PR #45, before merge — version stays `0.2.5-beta`. No `0.2.6-beta`, no separate ADR.

## Codex Marketplace Consolidation (2026-04-27 — fourth pass)

The second pass moved plugin manifests from `src/.claude-plugin/` and `src/.codex-plugin/` to the repo root (hand-edited), but **the Codex marketplace template at `src/marketplace/codex.json` was not migrated** — it stayed as a templated file that the compile script rendered into `.agents/plugins/marketplace.json`. That asymmetry is the same friction class as the manifest-at-root migration: hand-editing the source template *and* knowing about the rendered output creates dual-edit risk where a single hand-edit at the root would suffice.

### Why (Marketplace Consolidation)

The diff between `src/marketplace/codex.json` and the rendered `.agents/plugins/marketplace.json` is exactly **one line**: the `version` field (`"0.0.0"` placeholder → stamped value). Every other field (name, owner, metadata, plugins[].name/source/description) is authored verbatim. The compile script's whole job for the marketplace is therefore identical to what it already does for the Codex *manifest*: read Claude version → `jq`-stamp `.plugins[].version` in place → cross-check.

Consolidating is cheaper than maintaining the indirection: the marketplace file is 13 lines of JSON, lives at a fixed path Codex CLI dictates, and gains nothing from a `src/` template layer.

### What Changes (Marketplace Consolidation)

- **Delete `src/marketplace/codex.json`** (and the now-empty `src/marketplace/` directory).
- **`.agents/plugins/marketplace.json`** becomes the hand-edited source of truth at the repo root, alongside `.claude-plugin/marketplace.json`. All metadata (name, owner, plugins[].source, description) authored directly there.
- **`scripts/compile-skills.sh`** simplified: drop the `cp + jq` rendering block; replace with an in-place `jq` version-stamp on the existing root file (mirror the existing Codex-manifest-stamping logic). Drop `CODEX_MARKETPLACE_SRC` and `CODEX_MARKETPLACE_DIR` variables; cleanup block no longer rms the marketplace directory.
- **`docs/specs/release-workflow.md`** §"Source and Release Directory Structure", §"AOT Skill Compilation": rewrite the marketplace handling description; `version` 4 → 5.
- **`docs/specs/multi-target-distribution.md`** §"Codex Marketplace Entry": revise to describe hand-edited at root + `jq`-stamping; rewrite the "marketplace generated" scenario into "marketplace lives at repository root"; `version` 3 → 4.
- **`docs/capabilities/multi-target-distribution.md`, `docs/capabilities/release-workflow.md`**: align prose.
- **`AGENTS.md`** File-Ownership block: remove `src/marketplace/codex.json` from the `src/` list; merge `.agents/plugins/marketplace.json` into the per-target manifests/marketplaces block as hand-edited.
- **`.specshift/CONSTITUTION.md`** Plugin source layout convention + the related Architecture Rules entry: align with hand-edited-at-root.
- **`CHANGELOG.md`** 0.2.5-beta entries: Codex marketplace Added line + Hardening Pass BREAKING entry rewritten to reflect that marketplace files are hand-edited at root too.

### Capabilities (Marketplace Consolidation)

- **Modified**: `multi-target-distribution` (Codex Marketplace Entry), `release-workflow` (Source and Release Directory Structure, AOT Skill Compilation).

### Out of Scope (Marketplace Consolidation)

- **Manifest-field-parity automation across Claude and Codex** — same as before, manual review concern.
- **Cursor or Gemini marketplace files** — separate roadmap.
- **Version bump.** Lands in PR #45, version stays `0.2.5-beta`.
