---
has_decisions: true
---
# Technical Design: Multi-Target Distribution

## Context

SpecShift today ships only as a Claude Code plugin: `src/.claude-plugin/plugin.json` is the version source of truth, the compile script writes to `.claude/skills/specshift/`, and the bootstrap template generates `CLAUDE.md` only. OpenAI Codex CLI now exposes a comparable plugin model with skill-folder discovery, a `.codex-plugin/plugin.json` manifest, and a marketplace at `.agents/plugins/marketplace.json`. The Shopify-AI-Toolkit demonstrates a clean working precedent for serving multiple AI-coding-tool targets from one repo via side-by-side per-target manifest dirs and a shared `skills/` tree.

Three concerns drive this change:

1. **Reach**: SpecShift content is portable (SKILL.md frontmatter is Codex-compatible, prose is tool-agnostic). Adding Codex doubles addressable users with a packaging-only effort.
2. **Symmetry**: The current single-target layout has the Claude `plugin.json` carrying two unrelated responsibilities ("Claude per-target metadata" plus "version source of truth for the repo"). With Codex added, this asymmetry becomes a maintenance hazard — Codex's version comes from "somewhere else" rather than from a shared agnostic SoT.
3. **Single source of bootstrap content**: The current bootstrap pattern is `claude.md` only. Codex reads `AGENTS.md` natively. Duplicating bootstrap rules across two templates produces drift over time. The Claude Code documented `@AGENTS.md` import pattern lets us make `AGENTS.md` the SoT and keep `CLAUDE.md` as a one-line stub.

Stakeholders: maintainer (single audience), and consumers of either Claude Code or Codex (or both).

## Architecture & Components

The change is packaging-and-build-only. No runtime behavior changes for either target — both targets execute the same skill body the same way.

### Source layout (`src/`)

```
src/
├── VERSION                    # NEW: agnostic version SoT, plain text, single line
├── actions/                   # unchanged: compilation manifests
│   ├── apply.md
│   ├── finalize.md
│   ├── init.md
│   ├── propose.md
│   └── review.md
├── skills/specshift/SKILL.md  # unchanged
└── templates/
    ├── agents.md              # NEW: full bootstrap body (SoT)
    ├── claude.md              # CHANGED: collapsed to @AGENTS.md import stub
    ├── constitution.md        # unchanged
    ├── workflow.md            # unchanged (modulo init-action wording)
    └── changes/, docs/        # unchanged
```

`src/.claude-plugin/` is removed — manifests now live exclusively at the repo root.

### Repo-root layout (hand-edited per-target metadata + shared release artifact)

```
.claude-plugin/
├── plugin.json                # version stamped from src/VERSION
└── marketplace.json           # source: "./", plugins[].version stamped from src/VERSION
.codex-plugin/
└── plugin.json                # version stamped, interface block hand-edited
.agents/plugins/
└── marketplace.json           # plugins[].version stamped, source path hand-edited
skills/specshift/              # COMPILED OUTPUT — shared between both targets
├── SKILL.md
├── templates/
└── actions/
```

`.claude/` no longer carries the compiled tree. The compile script removes any pre-existing `.claude/skills/specshift/` to prevent stale artifacts.

### Compile script (`scripts/compile-skills.sh`)

Pseudocode of the rewritten flow:

```
1. Verify jq exists (hard preflight)
2. Verify src/VERSION exists, single line, non-empty
3. PLUGIN_VERSION = $(cat src/VERSION | tr -d '[:space:]')
4. Template-version freshness check (existing logic, unchanged)
5. rm -rf ./skills/specshift/ and legacy .claude/skills/specshift/
6. Copy src/skills/specshift/SKILL.md → ./skills/specshift/SKILL.md
7. Copy src/templates/ → ./skills/specshift/templates/
8. Stamp plugin-version into ./skills/specshift/templates/workflow.md
9. For each of (.claude-plugin/plugin.json, .claude-plugin/marketplace.json,
                 .codex-plugin/plugin.json, .agents/plugins/marketplace.json):
     Use jq to set version field (manifest: .version; marketplace: .plugins[].version)
     Re-read and verify stamped == PLUGIN_VERSION; fail on mismatch
10. Compile actions: extract requirement blocks per src/actions/*.md, write to
    ./skills/specshift/actions/<action>.md
11. Print summary: actions compiled, requirements extracted, warnings count
```

The script SHALL exit non-zero on any cross-check failure. The flow is idempotent — re-running on a clean tree produces byte-identical output.

### `specshift init` action

The action's bootstrap-files step changes from "generate CLAUDE.md from `claude.md` template if missing" to "generate AGENTS.md from `agents.md` template AND CLAUDE.md from `claude.md` template, each independently if missing". The section-completeness check on re-init operates on AGENTS.md (which carries normative content); CLAUDE.md is checked only for the `@AGENTS.md` import line.

### `specshift finalize` action

The version-bump step changes from "edit `src/.claude-plugin/plugin.json` and sync `.claude-plugin/marketplace.json`" to "edit `src/VERSION` only". The subsequent compile run propagates the new version into all four root files.

### Specs touched

- **NEW** `docs/specs/multi-target-distribution.md` — 8 requirements (per-target manifests at root, shared skill tree at root, Codex marketplace entry, bootstrap SoT pattern, agnostic skill body, multi-target install docs, version SoT, symmetric stamping with cross-check)
- **MODIFIED** `docs/specs/project-init.md` — Bootstrap Files Generation requirement (replaces CLAUDE.md Bootstrap), Install Workflow updated for both files, tool-agnostic prose
- **MODIFIED** `docs/specs/release-workflow.md` — Auto-Patch-Bump, Version-Sync, Manual-Release, Source/Release-Directory-Structure, Marketplace-Source-Configuration, Repository-Layout-Separation, AOT-Skill-Compilation, Compiled-Action-File-Contract, Dev-Sync-Script, Automated-GitHub-Release-via-CI, Changelog-Version-Headers, Developer-Local-Marketplace, Consumer-Update-Process, End-to-End-Install-and-Update-Checklist all rewritten for the multi-target reality

### Project-level files (not consumer-facing)

- `.specshift/CONSTITUTION.md` — Architecture Rules (release dir, plugin-source layout); Conventions (version-bump SoT, marketplace source, agent-instructions)
- `.specshift/WORKFLOW.md` — synced from updated `src/templates/workflow.md`
- `AGENTS.md` (project) — takes the project's existing instructions content from `CLAUDE.md`
- `CLAUDE.md` (project) — collapsed to `@AGENTS.md` import stub
- `README.md` — Multi-target install section (Claude Code + Codex), project-structure tree update

## Goals & Success Metrics

- **G1 — Single-source bootstrap**: Updates to a workflow rule touch exactly one source file (`src/templates/agents.md`). PASS/FAIL: grep for the rule string in `src/templates/` returns one hit only.
- **G2 — Symmetric versions**: All four root manifest/marketplace files declare the same version after `bash scripts/compile-skills.sh`. PASS/FAIL: `jq -r` over the four version locations returns four equal values, all matching `cat src/VERSION`.
- **G3 — Agnostic SoT for version**: `src/VERSION` is the only file the maintainer edits to bump the version. PASS/FAIL: `git log --oneline -1 -- src/VERSION` shows the bump commit; the four root files were modified in the same commit by the compile script, not by hand.
- **G4 — Compile script cross-check enforces consistency**: An artificially mismatched root file fails the build. PASS/FAIL: jq-edit one root file's version to a different string, run compile, expect non-zero exit and an error naming that file.
- **G5 — One shared skill tree**: Exactly one `./skills/specshift/SKILL.md` exists; no per-target SKILL variants. PASS/FAIL: `find . -path ./node_modules -prune -o -name 'SKILL.md' -print` returns one hit (in `./skills/specshift/`) plus the source (`src/skills/specshift/SKILL.md`).
- **G6 — Tool-agnostic compiled skill body**: Compiled skill files contain no `${CLAUDE_PLUGIN_ROOT}` references and no hardcoded `.claude/worktrees/...` strings. PASS/FAIL: `grep -r '${CLAUDE_PLUGIN_ROOT}' ./skills/specshift/` returns 0 hits; same for `\.claude/worktrees`.
- **G7 — Fresh init writes both bootstrap files**: A re-init on a project with neither file results in both AGENTS.md and CLAUDE.md being generated. PASS/FAIL: scenario test in `tests.md`.
- **G8 — README has both install paths**: The README has a Claude Code install section and a Codex install section at the same heading level. PASS/FAIL: grep for the section headings.
- **G9 — Idempotent build**: A second consecutive `bash scripts/compile-skills.sh` produces no diff. PASS/FAIL: `git status --porcelain` is empty after the second run.

## Non-Goals

- **Cursor / Gemini / other targets** — addressed only by manifest addition; out of scope for this change.
- **Codex hooks setup** — Codex hooks are user-config-only, not plugin-installable. Workflow-routing enforcement remains text-only via AGENTS.md.
- **Codex custom prompts** (`~/.codex/prompts/`) — upstream-deprecated.
- **MCP servers** (`.mcp.json`) — SpecShift uses no MCP tools.
- **Single-file consolidation** (eliminating CLAUDE.md entirely) — keeps Claude Code's documented memory pattern; CLAUDE.md is a trivial stub and cannot drift.
- **Environment detection in init** — both files always written; no detection logic.
- **Marketplace publishing automation** — manual `gh release` flow continues.
- **Branding assets** (logo, screenshots) — Codex listing works without; deferred to a follow-up change.
- **Live-install verification on a real Codex installation** — manual test path documented in README; automation deferred.

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Adopt Shopify-flat layout: shared `./skills/` tree at repo root, manifests side-by-side at root | Matches verified working precedent; eliminates duplication; cleanest symmetry | Additive sibling (`.codex-plugin/` next to unchanged `.claude/`); two release dirs (`.claude/` + `.codex/` parallel) |
| Single bootstrap template `agents.md` (full content) + `claude.md` reduced to `@AGENTS.md` import stub | Eliminates content duplication; uses Claude Code's documented AGENTS.md interop pattern | Two parallel templates with identical bodies; AGENTS.md only |
| No env-detection in init — always write both AGENTS.md and CLAUDE.md | CLAUDE.md becomes a trivially-small import stub that cannot drift; both tools work out of the box | Detect Claude vs Codex environment, ask user when ambiguous; AGENTS-only narrowing |
| Plugin manifests and marketplace files are hand-edited at the repo root (no `src/` indirection) | Manifests carry per-target metadata that has no source/output relationship; the `src/` layer added rendering overhead with zero gain after Shopify-flat migration | Keep `src/.claude-plugin/`, `src/.codex-plugin/`, render into root at compile time |
| Version source of truth is `src/VERSION` (plain text, single line, SemVer) | Decouples versioning from per-target metadata; symmetric stamping into all four root files; classic convention; trivially-readable without jq | Keep version in Claude manifest; embed in language-native manifest; derive from git tags; root-level `./VERSION` |
| Compile script stamps version into all four root files and cross-checks each post-stamp | Eliminates silent drift; previously the Claude marketplace version was hand-edited and unchecked | Stamp only the manifests; trust hand-edits on marketplaces |
| Workflow-routing rule lives only in agents.md | Single source; CLAUDE.md inherits via the `@`-import | Duplicate rule in both templates |
| Codex hook setup out of scope (text-only enforcement via AGENTS.md) | Codex hooks live in user config.toml, not plugin-installable; plain-text rule already proven sufficient on Claude side | Ship copy-paste config.toml snippet in README |
| `jq` is a hard preflight requirement of the compile script | Symmetric in-place version stamping that preserves field order and formatting requires jq; previously soft-warned, now enforced | Use `sed`/`awk` and risk reformatting JSON |
| `.agents/plugins/marketplace.json` `source` field hand-edited (not auto-derived) | Codex marketplace `source` semantics may evolve; keeping it hand-edited preserves maintainer control without script complexity | Auto-set to `./.codex-plugin` |

## Risks & Trade-offs

- **[Marketplace migration breaks existing Claude installs]** → Mitigation: existing consumers run `claude plugin marketplace update specshift` once; documented in CHANGELOG and README. Single-step recovery.
- **[Codex marketplace API still maturing — schema drift possible]** → Mitigation: jq-stamping preserves all non-version fields verbatim; if the upstream schema gains new required fields, hand-edit them at the root and the compile script transparently preserves them.
- **[`src/VERSION` desync if a maintainer hand-edits a manifest version]** → Mitigation: the next compile run overwrites the manual edit, and the cross-check guarantees consistency. Also: project documentation (CONSTITUTION, specs, README) names `src/VERSION` as the only SoT.
- **[CLAUDE.md stub gets accidentally edited to add real content]** → Mitigation: the spec scenario for re-init explicitly checks the import line is present (WARNING if missing). The stub itself is one line; off-template edits are unusual.
- **[`./skills/` ignored by `.gitignore` template projects]** → Mitigation: documented in CONSTITUTION as a layout rule; the spec calls out the `.gitignore` whitelist requirement.
- **[Codex listing without branding looks unpolished]** → Accepted trade-off: manifest installs successfully; branding (logo, screenshots) deferred to a follow-up change.
- **[Spec re-write of release-workflow.md introduces drift with capability docs]** → Mitigation: capability docs are regenerated by `specshift finalize` from the updated specs; drift detection in `specshift init` flags any remaining gaps.

## Migration Plan

This is a maintainer-side migration; consumers run a one-step refresh.

**Maintainer migration (one-time, this PR):**

1. Create `src/VERSION` with current version (`0.2.5-beta`).
2. Move `.claude-plugin/plugin.json` content from `src/.claude-plugin/plugin.json` to root (already at root in this branch); delete `src/.claude-plugin/`.
3. Hand-edit `.claude-plugin/marketplace.json` to `source: "./"`.
4. Create `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json` at the root with the agreed schemas.
5. Add `src/templates/agents.md` (full bootstrap body) and reduce `src/templates/claude.md` to the `@AGENTS.md` import stub.
6. Rewrite `scripts/compile-skills.sh` per the pseudocode above (jq preflight, version SoT read, four-file symmetric stamping with cross-check, shared tree at `./skills/`).
7. Update `src/actions/init.md` and `src/actions/finalize.md` requirement links to point at the renamed/added requirements.
8. Update specs (`multi-target-distribution.md` new; `project-init.md`, `release-workflow.md` modified) — already done in the previous artifact.
9. Update project-level `AGENTS.md` and `CLAUDE.md` (project takes the new bootstrap pattern).
10. Update `.specshift/CONSTITUTION.md` and `.specshift/WORKFLOW.md`.
11. Run `bash scripts/compile-skills.sh` — emits the shared `./skills/specshift/`, stamps all four root files, validates.

**Consumer migration:**

- **Existing Claude Code consumers**: Run `claude plugin marketplace update specshift && claude plugin update specshift@specshift`. The new layout is transparent; their plugin cache is refreshed against the new marketplace `source`.
- **New Claude Code consumers**: Same install command as before (`claude plugin marketplace add fritze-dev/specshift`).
- **New Codex consumers**: `codex /plugins`, discover and install — first-time path.

**Rollback strategy:**

If a critical issue surfaces post-merge, revert the merge commit on `main`. The previous layout is fully restored; existing Claude consumers run the marketplace-update command again to re-pull. No data migration is involved.

## Open Questions

No open questions — all decisions are recorded in the Decisions table above.

## Assumptions

- The Codex CLI's plugin manifest schema, marketplace location (`.agents/plugins/marketplace.json`), and skill discovery paths described in OpenAI's `developers.openai.com/codex` documentation are stable as of 2026-04-27. <!-- ASSUMPTION: Codex CLI plugin schema stable -->
- Claude Code's `@AGENTS.md` import syntax loads the referenced file into the session context at startup, as documented at `code.claude.com/docs/de/memory#agents-md`. <!-- ASSUMPTION: Claude Code AGENTS.md import behavior -->
- `jq` is available on every maintainer's build machine (the compile script uses it for in-place per-target manifest version stamping; missing jq fails the build with a descriptive error). <!-- ASSUMPTION: jq build dependency -->
- Both Claude Code and Codex resolve plugin-bundled assets referenced in skill prose (e.g., "the plugin's `templates/` directory") relative to the skill's installed location; neither runtime requires environment-variable interpolation in skill body text. <!-- ASSUMPTION: Agnostic asset resolution -->
- The `.agents/plugins/marketplace.json` file format and discovery is consistent with the Codex `codex /plugins` command behavior; if Codex requires a different filename or location in a future release, the compile script will need updating. <!-- ASSUMPTION: Codex marketplace file convention -->
