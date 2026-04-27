---
has_decisions: true
---
# Technical Design: Codex Plugin Support (Multi-Target Distribution)

## Context

SpecShift's existing build pipeline is single-target: `scripts/compile-skills.sh` reads sources under `src/` and produces a Claude-Code-shaped release at `.claude/`. The Claude marketplace at `.claude-plugin/marketplace.json` then sources `./.claude` as the plugin root.

For multi-target distribution, the build must produce two manifest dirs and one shared skill tree, all at the repo root, while preserving the existing AOT compile guarantees: template-version enforcement against `main`, requirement-block extraction from `docs/specs/`, and `plugin-version` stamping into `templates/workflow.md`.

The bootstrap-file generation (`specshift init`) currently emits a single `CLAUDE.md` from `src/templates/claude.md`. The new behavior emits both `AGENTS.md` (full body) and `CLAUDE.md` (`@AGENTS.md` import stub) — content authored once in `agents.md`, never duplicated.

Stakeholders: existing Claude Code consumers (need a smooth marketplace re-pull, no breakage), prospective Codex CLI consumers (need a discoverable, installable plugin), and the maintainer (single source of truth for skill body and bootstrap rules; one compile step that emits everything).

## Architecture & Components

**Source layout (under `src/`):**

```
src/
├── .claude-plugin/plugin.json          (existing)
├── .codex-plugin/plugin.json           (NEW)
├── skills/specshift/SKILL.md           (existing)
├── actions/{init,propose,apply,
│           finalize,review}.md         (existing)
├── templates/
│   ├── agents.md                       (NEW — full bootstrap body)
│   ├── claude.md                       (RESHAPED — @AGENTS.md stub)
│   ├── workflow.md                     (existing — init instruction updated)
│   ├── constitution.md                 (existing)
│   ├── changes/                        (existing)
│   └── docs/                           (existing)
└── marketplace/
    └── codex.json                      (NEW — Codex marketplace template)
```

**Compiled output (at repo root, after `bash scripts/compile-skills.sh`):**

```
.claude-plugin/{plugin.json, marketplace.json}
.codex-plugin/plugin.json
.agents/plugins/marketplace.json
skills/specshift/{SKILL.md, templates/, actions/}
```

**Key components:**

1. **`scripts/compile-skills.sh`** — extended to:
   - Set `PLUGIN_ROOT="."` (was `.claude`), so `SKILL_DIR=./skills/specshift`.
   - After existing skill copy, write `.codex-plugin/plugin.json` from `src/.codex-plugin/plugin.json`, stamping `version` from the Claude source manifest.
   - Write `.agents/plugins/marketplace.json` from `src/marketplace/codex.json`, stamping plugin version and the path to `.codex-plugin/plugin.json`.
   - Remove any pre-existing `.claude/skills/` legacy tree to prevent stale artifacts.

2. **`src/.codex-plugin/plugin.json`** — new source manifest:
   ```json
   {
     "name": "specshift",
     "version": "0.0.0",
     "description": "Spec-driven development workflow ...",
     "skills": "./skills/",
     "interface": {
       "displayName": "SpecShift",
       "shortDescription": "Spec-driven workflow ...",
       "category": "Productivity",
       "capabilities": ["Read"]
     }
   }
   ```
   `version: "0.0.0"` is a placeholder; compile script overwrites with the Claude source version.

3. **`.claude-plugin/marketplace.json`** — `source` field changed from `./.claude` to `./`. Skill resolution path becomes `./skills/specshift/`.

4. **`src/templates/agents.md`** — new Smart Template carrying the full body of today's `claude.md`:
   - YAML frontmatter: `id: agents`, `template-version: 1`, `description: AGENTS.md bootstrap (full body)`, `generates: AGENTS.md`, `requires: []`, `instruction: ...`
   - Body: identical to current `src/templates/claude.md` body (Workflow / Planning / Knowledge Management sections, plus the workflow-routing rule from commit 3d3f89f). File-ownership content is project-specific and added during init's codebase scan, not part of the template body.

5. **`src/templates/claude.md`** — body collapsed; only frontmatter + 1–2 lines remain:
   - Frontmatter `template-version` bumps from 4 → 5.
   - Body becomes:
     ```
     @AGENTS.md
     ```
   - No Claude-specific section needed initially; structure leaves room for future Claude-only directives.

6. **`src/templates/workflow.md`** — `## Action: init` instruction text updated to reference both AGENTS.md and CLAUDE.md generation. `template-version` bumps from 8 → 9.

7. **`.specshift/WORKFLOW.md`** — synced from updated `src/templates/workflow.md` (per template-synchronization convention in CONSTITUTION.md). The `worktree.enabled: true` and `request_review: copilot` overrides remain.

8. **`README.md`** — Install section split into two subsections: "Claude Code" (existing flow) and "Codex CLI" (new). Both at heading level `###`.

9. **`.specshift/CONSTITUTION.md`** — three rule updates:
   - Architecture Rules: "Release directory: `.claude/skills/specshift/`" → "Release directory: `./skills/specshift/`".
   - Conventions / Plugin source layout: marketplace source `./.claude` → `./`; mention both manifest source dirs (`src/.claude-plugin/`, `src/.codex-plugin/`).
   - File Ownership (in CLAUDE.md / AGENTS.md): `.claude/skills/specshift/` reference → `./skills/specshift/`.

## Goals & Success Metrics

* `bash scripts/compile-skills.sh` exits 0 with no warnings.
* `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `skills/specshift/SKILL.md`, and `.agents/plugins/marketplace.json` all exist after compile, all stamped with the same version string.
* `skills/specshift/templates/agents.md` and `skills/specshift/templates/claude.md` both exist after compile.
* `.claude/skills/` (legacy path) does NOT exist after compile.
* `claude plugin marketplace update specshift && claude plugin update specshift@specshift` resolves the new layout without manual intervention.
* In a fresh consumer project, `specshift init` produces both `AGENTS.md` (full body, the three standard sections — Workflow, Planning, Knowledge Management — plus any project-specific sections from the codebase scan) and `CLAUDE.md` (≤ 5 lines, contains `@AGENTS.md`).
* `grep -c "@AGENTS.md" CLAUDE.md` returns `1` in the generated CLAUDE.md.
* `wc -l < CLAUDE.md` returns ≤ 10 in the generated CLAUDE.md.

## Non-Goals

- **Codex hooks installation.** Out of scope; Codex hooks live in user `~/.codex/config.toml` and cannot be auto-installed by a plugin.
- **Codex custom prompts** (`~/.codex/prompts/`) — upstream-deprecated; Skill is the only entry point.
- **MCP server registration** (`.mcp.json`) — SpecShift uses no MCP tools.
- **Branding assets** (`interface.logo`, `composerIcon`, `brandColor`, logo SVG) — Codex listing works without them; deferred.
- **Cursor / Gemini / other targets** — Phase 1 stops at Claude + Codex.
- **CLAUDE.md elimination** — keep CLAUDE.md as a stub for Claude Code's documented memory pattern.
- **Environment detection in init** — both files always written; CLAUDE.md is too small to drift.
- **Action / artifact-template changes** — research/proposal/specs/design/preflight/tests/tasks/audit templates remain as-is (already tool-agnostic).

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Shopify-flat layout (`skills/` at repo root, both manifest dirs side-by-side) | Matches the only verified working multi-target reference (Shopify-AI-Toolkit); maximum symmetry; one shared skill tree | (a) Additive sibling — `.codex-plugin/` next to existing `.claude/skills/` — semantically odd manifest path; (b) Two release dirs `.claude/` + `.codex/` — disk duplication, two outputs to keep in sync |
| `agents.md` as bootstrap single source of truth, `claude.md` as `@AGENTS.md` import stub | Eliminates content duplication; matches Claude Code's documented AGENTS.md import pattern (`code.claude.com/docs/de/memory#agents-md`); CLAUDE.md becomes too small to drift | (a) Two parallel templates with identical bodies — duplicate maintenance, code-rot risk; (b) Eliminate CLAUDE.md, only AGENTS.md — Claude Code does not natively read AGENTS.md; (c) Env-detection in init — extra logic for no benefit since stub generation is trivial |
| Init writes both files unconditionally on fresh setup | No detection logic needed; CLAUDE.md is a 1-line stub; both tools (Claude Code via import, Codex natively) get the same workflow rules | Detect `$CODEX_HOME` / `~/.codex/` — adds branching, fragile detection signals |
| Claude source manifest is the version source of truth; Codex manifest version is stamped at compile time | Single version field to bump; impossible to ship inconsistent versions | (a) Both manifests author version independently — drift risk; (b) Separate version file (`VERSION`) — extra indirection |
| Codex marketplace source under `src/marketplace/codex.json`, compiled to `.agents/plugins/marketplace.json` | Mirrors the Claude marketplace pattern (source `.claude-plugin/marketplace.json` is hand-maintained, but Codex marketplace is generated to allow version stamping) | Hand-maintain `.agents/plugins/marketplace.json` directly — version drift risk |
| Migrate `.claude-plugin/marketplace.json` source from `./.claude` to `./` rather than dual-publishing | Simplest; existing consumers run a single marketplace-update command and pick up the new layout | Keep `./.claude` source and copy/symlink to maintain backward compatibility — transient backward-compat that adds complexity for no real benefit |
| Use the existing template-version discipline for `agents.md` (start at 1) and the bumped `claude.md` (4 → 5) | Consistent with current convention; compile script enforces version bump on diff against `main` | Skip versioning for `claude.md` since body shrinks dramatically — would silently break diff-based enforcement |
| Constitution updated as part of this change (release directory path + marketplace source path) | These rules currently reference paths that this change retires; leaving them stale would create new drift | Defer constitution update to a follow-up — leaves CONSTITUTION inconsistent with implementation |

## Risks & Trade-offs

- **Existing Claude consumers must run `claude plugin marketplace update specshift`** to pick up the new marketplace source path. → **Mitigation:** README's update section already documents this command; release notes call it out explicitly.
- **Codex CLI plugin schema may evolve** before next version cuts (young API). → **Mitigation:** verify against `developers.openai.com/codex` at release time; capture the assumption in the spec; treat any breakage as a follow-up change.
- **Compile script churn risk** — moving the output path is a substantial edit; risk of leaving artifacts in `.claude/skills/`. → **Mitigation:** explicitly `rm -rf .claude/skills` at the start of compile during the migration window; update CONSTITUTION rule about release directory; verify after first compile that the legacy path is gone.
- **Bootstrap regression for existing Claude users** — if the new `claude.md` stub overwrites a user's customized CLAUDE.md, they lose content. → **Mitigation:** init's existing "skip if exists" behavior already protects this; reaffirmed in the new requirement; documented in the migration scenario.
- **`@AGENTS.md` import requires a Claude Code version that supports it** — older Claude Code may not expand the import. → **Mitigation:** documented in the spec's assumptions; acceptable given current Claude Code state; if an older version is detected, the workflow rules just go unloaded and the user must update.
- **GitHub Action that auto-tags on version push** is unaffected by manifest-path changes (it watches `src/.claude-plugin/plugin.json`). → No mitigation needed; verify after merge.

## Migration Plan

1. **Pre-flight verification** — run `bash scripts/compile-skills.sh` on the change branch and inspect the output tree before merge.
2. **Local test (Claude side)** — register the worktree as a marketplace, run `specshift init` in a throwaway test project, confirm both bootstrap files generate, confirm `claude plugin update` resolves the new layout.
3. **Local test (Codex side)** — if a Codex CLI is installed, run `codex /plugins` against the local marketplace to confirm the plugin lists; install in a test project, run the skill, confirm dispatch works. If Codex CLI is not available locally, document this gap in the audit and treat the Codex install as best-effort verified by manifest schema only.
4. **Merge via standard finalize/review flow.**
5. **Post-merge**: existing consumers who installed via the old layout need to run:
   ```
   claude plugin marketplace update specshift
   claude plugin update specshift@specshift
   ```
   This is the same update flow they already use for any update.
6. **Rollback strategy**: if a critical issue is found in the first 24 hours after merge, revert the merge commit. The Codex consumers (if any) lose access; Claude consumers stay on the previous version after one more `marketplace update`.

## Design Extension (2026-04-27 — second pass)

### Context (Extension)

After PR-#45 self-review, three architectural drifts surfaced in the first-pass implementation:

1. **Tool-specific tokens leak into the shared skill tree.** The compiled action files (`./skills/specshift/actions/*.md`) and templates carry `${CLAUDE_PLUGIN_ROOT}`, `Claude Code Web`, and `.claude/worktrees` — strings that only resolve under Claude Code. Codex skill bodies are model instruction text and have no equivalent of `${CLAUDE_PLUGIN_ROOT}` (verified against `developers.openai.com/codex/skills` and Shopify-AI-Toolkit). The first pass therefore ships a Claude-flavored skill body that Codex cannot resolve.

2. **Plugin manifests live in `src/` for legacy reasons that no longer apply.** Pre-Shopify-flat, `.claude-plugin/plugin.json` was generated *into* the compiled `.claude/` tree, so the source of truth had to live elsewhere — `src/.claude-plugin/`. Post-migration, both manifests live at the repository root as final artifacts. `src/.claude-plugin/` and `src/.codex-plugin/` are pure indirection: edit `src/...` → run compile → see at root. `marketplace.json` is already hand-edited at the root; manifests should follow.

3. **`release-workflow.md` spec describes a single-target world.** Pre-existing requirements still reference `.claude/skills/specshift/`, `${CLAUDE_PLUGIN_ROOT}`, `source: "./.claude"`, and a single plugin.json copy. `src/actions/finalize.md` carries no Codex-aware requirement links, so the compiled finalize action under `./skills/specshift/actions/finalize.md` ships without multi-target context.

These are all wording or structural issues, not behavioral. The extension fixes them in the running change rather than deferring to a follow-up.

### Architecture (Extension)

**Source layout after extension** (deltas vs. first-pass):

```
src/
├── .claude-plugin/                 (REMOVED — manifest moves to repo root)
├── .codex-plugin/                  (REMOVED — manifest moves to repo root)
├── skills/specshift/SKILL.md       (existing — verified agnostic)
├── actions/                        (existing; finalize.md gets new links)
├── templates/                      (existing; agnostic-pass over compiled-into-skill files)
└── marketplace/codex.json          (existing)

.claude-plugin/
├── plugin.json                     (NEW location — moved from src/)
└── marketplace.json                (existing — hand-edited at root)

.codex-plugin/
└── plugin.json                     (NEW location — moved from src/, enriched)

./skills/specshift/                 (compiled, agnostic, served to both targets)
.agents/plugins/marketplace.json    (compiled)
```

**Compile script (`scripts/compile-skills.sh`) deltas**:

- Drop `cp src/.claude-plugin/plugin.json .claude-plugin/plugin.json` — manifest is hand-edited at root.
- Drop `src/.codex-plugin/` source path; read `.codex-plugin/plugin.json` directly at root, stamp version in place via `jq`.
- Read version from `.claude-plugin/plugin.json` at root (was `src/.claude-plugin/plugin.json`).
- Drop any per-target rewrite functions — single shared compile output.
- Add validation: emitted Codex manifest version must equal Claude manifest version after stamping.

**Codex manifest schema after enrichment** (`.codex-plugin/plugin.json`):

```json
{
  "name": "specshift",
  "version": "0.2.5-beta",
  "description": "...",
  "author": { "name": "fritze.dev", "url": "https://github.com/fritze-dev" },
  "homepage": "https://github.com/fritze-dev/specshift",
  "repository": "https://github.com/fritze-dev/specshift",
  "license": "MIT",
  "keywords": ["spec-driven", "documentation", "workflow", "bdd", "gherkin", "codex"],
  "skills": "./skills/",
  "interface": {
    "displayName": "SpecShift",
    "shortDescription": "...",
    "longDescription": "...",
    "developerName": "fritze.dev",
    "category": "Coding",
    "capabilities": ["Read", "Edit", "Write", "Bash"],
    "websiteURL": "https://github.com/fritze-dev/specshift",
    "defaultPrompt": [
      "Initialize SpecShift in this repository.",
      "Use SpecShift to propose a new change.",
      "Apply the active SpecShift change."
    ],
    "brandColor": "#2563EB",
    "screenshots": []
  }
}
```

**Bootstrap behavior change (Option A)**: `specshift init` no longer auto-generates `CLAUDE.md`. Fresh init writes only `AGENTS.md`. The `claude.md` Smart Template stays in the plugin payload so users can copy it manually. Existing `CLAUDE.md` files are inspected with WARNING-only standard-sections checks but never modified.

**Spec deltas**:

- `docs/specs/multi-target-distribution.md` — manifests-at-root requirement, agnostic-skill-body requirement, bootstrap-pattern wording (claude.md no longer auto-generated), version bump 1 → 2.
- `docs/specs/release-workflow.md` — Auto Patch Version Bump / Version Sync / Manual Release / Source-and-Release-Directory-Structure / Marketplace Source Configuration / AOT Skill Compilation / Compiled Action File Contract / Repository Layout Separation / Dev Sync Script — all rewritten to describe the multi-target reality with manifests at repo root, shared `./skills/specshift/` tree, and `jq`-based version stamping. Version bump 3 → 4.
- `docs/specs/project-init.md` — `${CLAUDE_PLUGIN_ROOT}/templates/...` → "the plugin's `templates/` directory" prose; Bootstrap Files Generation requirement rewritten for fresh-init-AGENTS-only behavior; `Purpose` updated. Version bump 6 → 7.
- `docs/specs/review-lifecycle.md` — User Story phrasing generalized from "Claude Code Web" to "ephemeral / stateless agent sessions". (No version bump — wording-only in a non-template doc.)
- `docs/specs/three-layer-architecture.md` — "Claude Code plugin system" → "the host plugin system (Claude Code, Codex CLI)". (No version bump.)
- `docs/specs/documentation.md` — translation rule lists both product names. (No version bump.)

`src/actions/finalize.md` — add Codex-aware requirement links (Source and Release Directory Structure, Marketplace Source Configuration, AOT Skill Compilation, Compiled Action File Contract, Dev Sync Script) so the compiled `./skills/specshift/actions/finalize.md` carries the multi-target requirement set.

### Decisions (Extension)

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Make the source skill body agnostic; emit a single shared compiled tree for both targets | Codex has no `${CLAUDE_PLUGIN_ROOT}` equivalent (verified). Bare relative paths and prose work in both runtimes (Shopify and openai/skills both use this convention). One artifact = no per-target divergence at runtime, no rewrite passes to maintain. | (a) Compile-time per-target rewrite (PR-44 approach: `write_codex_skill`, `rewrite_codex_file`) — adds two emit paths and a substitution maintenance burden for every new tool-specific token. (b) Two skill trees emitted side-by-side — disk duplication, double-compile cost. |
| Move plugin manifests from `src/` to the repo root, hand-edited | Post-Shopify-flat, root *is* the plugin root for both targets. `marketplace.json` is already hand-edited at root; making `plugin.json` follow eliminates a dead `cp` step in the compiler and removes an indirection that confuses contributors. Compiler reduces to: read root manifest version → stamp Codex outputs. | Keep in `src/`, copy in compiler — preserves consistency with "everything under `src/` is hand-edited", but adds friction for no behavioral benefit. |
| Enrich `.codex-plugin/plugin.json` with `author`, `repository`, `license`, `keywords` (agnostic parity with Claude) plus Codex-UI-specific fields | Codex `/plugins` UI uses `longDescription`, `defaultPrompt`, `brandColor`, `screenshots` for discoverability. Agnostic fields keep manifests symmetric and let consumers see consistent metadata regardless of runtime. | Stay minimal — leaves Codex listing barren and harder to discover. |
| Align `release-workflow.md` to multi-target reality and link Codex-relevant requirements from `src/actions/finalize.md` | The spec is the source from which `finalize.md` is compiled; if it stays single-target, Codex consumers receive a finalize action that does not describe their world. | Keep `release-workflow.md` Claude-only and document multi-target only in `multi-target-distribution.md` — leaves spec-drift between the two specs and means `finalize.md` never reflects the multi-target reality. |
| Fresh init writes only AGENTS.md (Option A); CLAUDE.md is opt-in via the still-shipped `claude.md` template | Minimal footprint, no stub forced onto Codex-only or agnostic projects. CLAUDE.md is one line — users who want it know what to do. Existing CLAUDE.md files are still detected on re-init with WARNING-only standard-section checks. | (B) Fresh-init writes both — first-pass behavior; over-eager and creates a stub on every consumer. (C) Auto-detect environment and pick which file to write — env detection was already declared out of scope. |
| Stamp Codex manifest version via `jq` updates anchored on `.version` (instead of `cp` from a source manifest) | The Codex manifest at root is hand-edited and contains additional fields (UI metadata) that source-copy would clobber. `jq -r '.version' | jq '.version = $v'` is a precise, drift-free in-place edit. | (a) Source-copy from `src/.codex-plugin/plugin.json` — re-introduces the indirection we just removed. (b) `sed` global substitution — may match nested `version` fields in unrelated objects. |

### Risks & Trade-offs (Extension)

- **Manifest field drift between Claude and Codex.** Both manifests now live at the root and are hand-edited. Agnostic fields like `author`, `repository`, `license`, `keywords` could drift between targets if a maintainer updates one without the other. **Mitigation:** the audit step verifies parity manually; the compile script enforces only `version` parity. A future enhancement could add a CI check.
- **Existing CLAUDE.md projects expect auto-generation.** A consumer that previously ran `specshift init` on a stale CLAUDE.md and expected it to be regenerated will now see a WARNING but no rewrite. **Mitigation:** documented in the migration scenario; consumers can manually delete CLAUDE.md to opt back in to a clean re-bootstrap (which still writes only AGENTS.md, leaving them to re-add CLAUDE.md if desired).
- **Source-of-truth ambiguity for the version field.** Two files now store the version (`.claude-plugin/plugin.json` is canonical, `.codex-plugin/plugin.json` derives). A maintainer who edits the Codex manifest version directly will see it stamped back to the Claude version on next compile. **Mitigation:** documented; the compile script reports the version it stamps; the constitution names `.claude-plugin/plugin.json` as the source of truth.
- **Tool-agnostic phrasing may obscure runtime-specific details.** Generalizing "Claude Code Web" to "ephemeral agent sessions" loses the specific product context for Claude consumers reading the spec. **Mitigation:** the User Story is illustrative, not normative; the requirement body uses concrete terms where needed.

### Migration Plan (Extension)

1. **Edit specs and source files** (no implementation yet) — proposal/spec/design/preflight/tests/tasks first, then code.
2. **Move plugin manifests from `src/` to root** — `git mv src/.claude-plugin/plugin.json .claude-plugin/plugin.json` (already at root from first pass — verify; remove the `src/` copy). Same for Codex.
3. **Enrich Codex manifest** — add agnostic + UI fields.
4. **Agnostic-pass over source skill body** — replace `${CLAUDE_PLUGIN_ROOT}`, `Claude Code Web`, `.claude/worktrees` (in compiled-into-skill files) with prose / configured patterns / agnostic terms.
5. **Update `src/actions/finalize.md`** — add Codex-aware requirement links.
6. **Update `src/templates/workflow.md` `## Action: init` instruction** — fresh-init AGENTS-only.
7. **Simplify `scripts/compile-skills.sh`** — drop manifest `cp`s, read version from root, stamp via `jq`, single shared output.
8. **Update CONSTITUTION.md, AGENTS.md (project-level), README.md** — reflect manifest-at-root and agnostic phrasing.
9. **Sync `.specshift/WORKFLOW.md`** from updated `src/templates/workflow.md`.
10. **Run compile, audit, fix-loop, finalize-chain.**

## Open Questions

No open questions — all design decisions have been made based on verified Shopify and Codex documentation.

## Assumptions

- The Codex CLI plugin manifest schema (`name`, `version`, `description`, `skills`, `interface` block with `displayName`, `shortDescription`, `category`) is stable as documented at `developers.openai.com/codex/plugins/build`. <!-- ASSUMPTION: Codex manifest schema -->
- The Codex marketplace file location (`.agents/plugins/marketplace.json`) is correct per current Codex documentation; the format is a JSON file referencing plugin manifests. <!-- ASSUMPTION: Codex marketplace location -->
- Claude Code's `@AGENTS.md` import directive in CLAUDE.md loads the referenced file at session start, per `code.claude.com/docs/de/memory#agents-md`. <!-- ASSUMPTION: Claude AGENTS.md import behavior -->
- The compile script runs from the repository root, so relative paths in the output (`./skills/specshift/`, `.codex-plugin/plugin.json`) resolve correctly when consumers install. <!-- ASSUMPTION: Compile cwd is repo root -->
- Existing Claude Code consumers can run `claude plugin marketplace update specshift` without losing local plugin state; this is the documented update flow. <!-- ASSUMPTION: Claude marketplace update preserves state -->
