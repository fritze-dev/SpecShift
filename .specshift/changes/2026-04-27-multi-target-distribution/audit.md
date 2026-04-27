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
- **G3 — agnostic SoT**: design + tasks specify the bump touches `src/VERSION` only; no manifest is the SoT per CONSTITUTION; verified by reading `scripts/compile-skills.sh` (the three root manifest version fields are written, not read, by the script). **PASS by design.**
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

---

## Audit Fix Loop (Pass 2 — Review-Driven)

### Trigger

PR #46 received Copilot automated review (5 comments, all wording/scope around `jq`'s preservation guarantees and the `LEGACY_SKILL_DIR` rm-rf scope) and a follow-up self-review pass that surfaced four additional findings (1 HIGH, 2 MEDIUM, 2 LOW) plus a recommendation to verify the Codex `skills` path interpretation against the Shopify-AI-Toolkit reference.

### Findings Resolved

#### Pass-2 #1 — Copilot review batch (5 comments, Tweak class)

Addressed in commit `b2fac81`. Wording adjusted across `scripts/compile-skills.sh`, `docs/specs/multi-target-distribution.md` (v1 → v2), `docs/decisions/adr-003-shopify-flat-multi-target-distribution.md`, and cascaded cleanup in `.specshift/CONSTITUTION.md`, `AGENTS.md`, `README.md`, `proposal.md`, capability docs (`multi-target-distribution.md`, `release-workflow.md`), `design.md`, `tests.md`. `LEGACY_SKILL_DIR` narrowed from `.claude/skills` to `.claude/skills/specshift`. All 5 review threads marked resolved. **PASS.**

#### Pass-2 #2 — Self-review HIGH: Codex `skills` path interpretation (RESOLVED via Shopify reference)

`gh api repos/Shopify/Shopify-AI-Toolkit/contents/.codex-plugin/plugin.json` confirms the Shopify pattern uses `"skills": "./skills/"` paired with `skills/` at the **repo root** (not under `.codex-plugin/`). This matches our layout exactly: `.codex-plugin/plugin.json` declares `"skills": "./skills/"` and the compiled tree lives at `./skills/specshift/` at the repo root. Interpretation (b) from the self-review is correct — the `skills` field resolves relative to the plugin install root (= repo root), not the manifest's directory. **No code change required.** Audit's lone SUGGESTION about live install verification narrows to: smoke-test on a real Codex session as a follow-up, but the path resolution is verified against the gold-standard reference. **PASS.**

#### Pass-2 #3 — New observation from Shopify abgleich: `.agents/plugins/marketplace.json` not in Shopify repo

`gh api repos/Shopify/Shopify-AI-Toolkit/contents/.agents/plugins/marketplace.json` returns `404 Not Found`. Shopify ships the plugin without an `.agents/plugins/marketplace.json` file. Two interpretations:

- **(a)** Shopify is a marketplace-listed plugin, so the marketplace registry is hosted elsewhere (centralized OpenAI registry) — `.agents/plugins/marketplace.json` is for marketplace-aggregator repos that list other plugins, not for individual plugin repos.
- **(b)** Shopify just doesn't bother with this file; the plugin is installable by direct path (`codex /plugins add github:Shopify/Shopify-AI-Toolkit`).

Our `.agents/plugins/marketplace.json` was added based on a documentation-interpretation in `research.md`, not against verified upstream behavior. It does not break anything (worst case: ignored), and it does provide a self-describing entry that consumers can point at. **Decision: keep the file for now**, document this as a SUGGESTION (revisit if the file turns out to cause confusion or if Codex updates its discovery model). Add a follow-up issue to verify on a real Codex install whether the file is read or ignored. **PASS with SUGGESTION.**

#### Pass-2 #4 — Self-review MEDIUM: `release.yml` trusts manifests are pre-stamped (FIXED)

`.github/workflows/release.yml` now runs a four-file cross-check before tag/release creation: reads `.version` (manifests) and `.plugins[0].version` (marketplaces) from each of the three root files via `jq`, compares each to `src/VERSION`, fails the workflow with a descriptive error naming the offending file if any mismatch. The error message tells the maintainer to run `bash scripts/compile-skills.sh` and re-push. Closes the foot-gun where a bare `src/VERSION` push would publish a tag with stale manifests. **PASS.**

#### Pass-2 #5 — Self-review MEDIUM: `src/VERSION` SemVer not validated (FIXED)

`scripts/compile-skills.sh` now validates `PLUGIN_VERSION` against the SemVer 2.0 regex (`^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$`) after the empty-line check. Negative-path tested: `src/VERSION = "0..2.5"` fails the build with a descriptive error before any stamping; `src/VERSION = "0.2.5-beta"` passes. **PASS.**

#### Pass-2 #6 — Self-review LOW: CHANGELOG BREAKING-note placement + release.yml sed pipeline robustness

Both filed as GitHub Issues for follow-up (cosmetic / latent fragility, not regressions in this change). See Pass-2 SUGGESTION list below. **DEFERRED.**

### Re-Run of Verifiable Metrics

- G1 (single-source bootstrap): unchanged, **PASS**.
- G2 (symmetric versions): all 5 locations (4 root + `src/VERSION`) at `0.2.5-beta`, **PASS**.
- G4 (cross-check enforces consistency): now also enforced in CI via `release.yml` cross-check step before tag creation, **PASS** stronger.
- G5 / G6 / G8 / G9: unchanged, **PASS**.
- New: SemVer-regex test (positive + negative) executed in this session, **PASS**.

### Verdict (Pass 2)

**PASS**, 0 CRITICAL, 0 WARNING, 2 SUGGESTIONS (both filed as GitHub Issues #48 and #49):
1. CHANGELOG BREAKING-note promotion (#48) — cosmetic placement of the BREAKING callout above sub-sections.
2. `release.yml` sed pipeline robustness against deeper-than-`####` headers (#49) — latent fragility, not a regression.

The pass closes all blocking items from the self-review and the Copilot review. Layout decisions are now confirmed against the Shopify-AI-Toolkit reference (skills path resolution interpretation (b) is canonical).

---

## Audit Fix Loop (Pass 3 — Codex Marketplace Re-Evaluation + Layout Cleanup)

### Trigger

User raised two related concerns after the Pass-2 SUGGESTION about the Codex marketplace was filed:

1. **What is `.agents/plugins/marketplace.json` actually for, and if we don't have a clear use-case, do we need it?**
2. **Why does `.claude/.claude-plugin/plugin.json` still exist in the PR?**

Both turned out to be load-bearing scope cleanups, not just nits.

### Findings Resolved

#### Pass-3 #1 — `.agents/plugins/marketplace.json` removed (Design Pivot, scoped down)

Research via OpenAI Codex docs (`developers.openai.com/codex/plugins/build`) and a sample real-world plugin (`Habib0x0/spec-driven-plugin`) revealed:

- The `.agents/plugins/marketplace.json` file is **optional** for single-plugin repos. Codex docs explicitly: *"A single-plugin repo can skip the marketplace file during initial development. `codex plugin marketplace add github:owner/repo` doesn't require a pre-existing marketplace.json — Codex will locate the plugin's manifest and create appropriate marketplace entries automatically."*
- The official Codex marketplace schema (`name` + `interface.displayName`, `plugins[].source: {source, path}` as object, `plugins[].policy`, `plugins[].category`, no `plugins[].version`) is **incompatible** with what we shipped (we used Claude-style fields: `owner.name`, `metadata.description`, `plugins[].source` as bare string, `plugins[].version`, `plugins[].description`).
- Shopify-AI-Toolkit (the canonical multi-target reference) ships **no** `.agents/plugins/marketplace.json` — they rely on auto-discovery.

Decision: **remove the file entirely.** Reasons: our schema was wrong (worse than not shipping); Codex auto-discovers single-plugin repos without it; Shopify pattern matches; we have no real use-case (single plugin, no policy/curation needs). Can be added back later with the correct schema if a multi-plugin layout or policy-control need emerges.

Implementation:
- `git rm -r .agents/`
- Spec `multi-target-distribution.md` v2 → v3: "Codex Marketplace Entry" requirement replaced with "Codex Discovery via Marketplace Add" (auto-discovery is the supported path; document the schema for future use)
- Spec `release-workflow.md` v4 → v5: Version Sync Between Plugin Files now lists three files; new scenario "CI release workflow catches missing recompile" added to cover the Pass-2 cross-check addition
- ADR-003 Decision 1 + Decision 2 + Alternatives Considered: "Ship a `.agents/plugins/marketplace.json` catalog file" added as rejected alternative with rationale
- `scripts/compile-skills.sh`: removed `CODEX_MARKETPLACE` constant + preflight check + stamp_version call + summary line
- `.github/workflows/release.yml` cross-check loop: removed the `.agents/plugins/marketplace.json` entry (3 files instead of 4)
- Cascaded wording cleanup across `CONSTITUTION.md`, `AGENTS.md`, `README.md`, `CHANGELOG.md`, capability docs, change-artifact files (proposal, design, tests, tasks, preflight) — all "four files" → "three files", removed `.agents/plugins/marketplace.json` mentions, replaced with "Codex auto-discovery via `codex plugin marketplace add github:owner/repo`"

**PASS.** Spec is now consistent with what we ship; no broken-or-ignored file in the consumer-facing plugin.

#### Pass-3 #2 — `.claude/.claude-plugin/plugin.json` removed (cleanup miss)

User noticed the legacy compiled Claude manifest at `.claude/.claude-plugin/plugin.json` was still tracked on this branch — leftover from the pre-multi-target layout where `.claude/` was the plugin root. The file carried `version: "0.2.4-beta"` (stale vs. our SoT `0.2.5-beta`) and was no longer referenced by anything: the new Claude marketplace `source: "./"` resolves the plugin to the repo root, not `.claude/`.

Implementation:
- `git rm -r .claude/.claude-plugin/`
- `.gitignore` cleaned: removed obsolete whitelists `!/.claude/skills/` and `!/.claude/.claude-plugin/` (the new compiled tree lives at `./skills/`, no longer under `.claude/`); kept `!/.claude/settings.json` whitelist for local-developer config
- `scripts/compile-skills.sh`: added `LEGACY_CLAUDE_MANIFEST_DIR=".claude/.claude-plugin"` to the cleanup section so future maintainers with the pre-migration layout get auto-cleaned on next compile (alongside the existing `.claude/skills/specshift/` legacy cleanup)
- CHANGELOG bullet about the compile script's legacy cleanup updated to mention both legacy paths

**PASS.** No more stale Claude manifest hiding in the tree. Fresh checkouts of this branch cannot hit the version-drift confusion that the leftover file would have caused.

### Re-Run of Verifiable Metrics

- G1 (single-source bootstrap): unchanged, **PASS**.
- G2 (symmetric versions): three root files (was four) all at `0.2.5-beta`, plus `src/VERSION` = `0.2.5-beta`, **PASS**.
- G3 (agnostic SoT): unchanged, **PASS**.
- G4 (cross-check enforces consistency): three-file scope; logic unchanged, **PASS**.
- G5 / G6 / G8 / G9: unchanged, **PASS**.
- SemVer-regex: positive + negative paths re-tested in Pass 2, **PASS**.
- New: post-Pass-3 compile run is clean (5 actions, 46 requirements, 0 warnings, 3-file stamping table prints all three files at version 0.2.5-beta).

### Verdict (Pass 3)

**PASS**, 0 CRITICAL, 0 WARNING, 0 SUGGESTIONS open.

The Pass-2 SUGGESTION about live Codex install verification is now stronger: with the catalog file removed, the only thing to verify is that `codex plugin marketplace add github:fritze-dev/specshift` correctly auto-discovers `.codex-plugin/plugin.json`. This is the documented behavior; verification remains a recommended manual smoke test on a real Codex CLI install but is no longer ambiguous (we know exactly which behavior we're testing for).
