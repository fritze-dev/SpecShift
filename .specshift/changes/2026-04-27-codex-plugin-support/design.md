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

## Open Questions

No open questions — all design decisions have been made based on verified Shopify and Codex documentation.

## Assumptions

- The Codex CLI plugin manifest schema (`name`, `version`, `description`, `skills`, `interface` block with `displayName`, `shortDescription`, `category`) is stable as documented at `developers.openai.com/codex/plugins/build`. <!-- ASSUMPTION: Codex manifest schema -->
- The Codex marketplace file location (`.agents/plugins/marketplace.json`) is correct per current Codex documentation; the format is a JSON file referencing plugin manifests. <!-- ASSUMPTION: Codex marketplace location -->
- Claude Code's `@AGENTS.md` import directive in CLAUDE.md loads the referenced file at session start, per `code.claude.com/docs/de/memory#agents-md`. <!-- ASSUMPTION: Claude AGENTS.md import behavior -->
- The compile script runs from the repository root, so relative paths in the output (`./skills/specshift/`, `.codex-plugin/plugin.json`) resolve correctly when consumers install. <!-- ASSUMPTION: Compile cwd is repo root -->
- Existing Claude Code consumers can run `claude plugin marketplace update specshift` without losing local plugin state; this is the documented update flow. <!-- ASSUMPTION: Claude marketplace update preserves state -->
