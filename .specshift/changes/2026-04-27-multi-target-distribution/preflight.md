# Pre-Flight Check: Multi-Target Distribution

## A. Traceability Matrix

| Story (Spec) | Requirement | Scenarios | Components |
|--------------|-------------|-----------|------------|
| Maintainer wants both manifests hand-edited at root | Per-Target Plugin Manifest (multi-target-distribution) | Manifests authored at repo root; Codex schema fields; Claude schema preserved | `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json` |
| Maintainer wants one shared skill tree | Shared Skill Tree at Repository Root | Skill compiled to repo root; Both manifests reference shared tree; Legacy location removed | `./skills/specshift/`, `scripts/compile-skills.sh` |
| Codex user wants discovery via `/plugins` | Codex Marketplace Entry | Marketplace at repo root; Version stamped; Independent updates | `.agents/plugins/marketplace.json`, `scripts/compile-skills.sh` |
| Maintainer wants bootstrap rules authored once | Bootstrap Single Source of Truth Pattern | agents.md has full content; claude.md is import stub; Updating shared rule touches only agents.md; Fresh init generates both; Both templates are Smart Templates | `src/templates/agents.md`, `src/templates/claude.md`, init action |
| Maintainer wants agnostic compiled skill body | Agnostic Skill Body | No runtime-specific env vars in source; One compiled tree; Product names target-scoped | `src/skills/specshift/SKILL.md`, `src/templates/`, `docs/specs/`, `scripts/compile-skills.sh` |
| New user wants per-target install instructions | Multi-Target Install Documentation | README contains both sections; Future targets follow pattern | `README.md` |
| Maintainer wants one canonical version place | Version Source of Truth | SoT is plain-text file under src; Finalize bump edits only SoT; No manifest is the SoT | `src/VERSION`, `src/actions/finalize.md`, `.specshift/CONSTITUTION.md`, `README.md` |
| Maintainer wants released artifacts to agree | Symmetric Version Stamping with Cross-Check | All four files stamped from one source; Post-stamp cross-check; Workflow template version stamped | `scripts/compile-skills.sh`, `./skills/specshift/templates/workflow.md` |
| Developer wants both bootstrap files (project-init) | Bootstrap Files Generation | Both files on fresh init; Existing AGENTS preserved; Existing CLAUDE preserved; Generate one when other exists; Project-specific rules; Missing-section detection | init action skill; `src/templates/agents.md`; `src/templates/claude.md` |
| Maintainer wants auto-bump | Auto Patch Version Bump (release-workflow) | Successful auto-bump | `src/actions/finalize.md`, `.specshift/CONSTITUTION.md` |
| Versions must always agree | Version Sync Between Plugin Files | Four files in sync; Drift corrected; Stamping failure caught | `scripts/compile-skills.sh` |
| Maintainer wants single-edit minor releases | Manual Minor and Major Release Process | Manual minor via push; Retroactive tagging | `src/VERSION`, README, `.github/workflows/release.yml` |
| Consumer needs update process per target | Consumer Update Process | Claude update; Codex update; Update not detected fallback | README |
| Skill code is generic | Skill Immutability Convention | Project-specific behavior in constitution | `.specshift/CONSTITUTION.md` |
| End-to-end flow per target | End-to-End Install and Update Checklist | Claude install; Codex install; Update flow | spec scenarios (testable) |
| Local plugin updates | Post-Push Developer Plugin Update | Local marketplace update; Remote marketplace update | README |
| Output guides next steps | Completion Workflow Next Steps | Next steps shown after verification | `src/actions/finalize.md` |
| Changelog from completed changes | Generate Changelog from Completed Changes | Existing scenarios | `src/actions/finalize.md` (unchanged behavior) |
| Versioned changelog headers | Changelog Version Headers | Single change versioned header; release.yml extraction; Multi-change groups | `src/actions/finalize.md`, `.github/workflows/release.yml` |
| Language-aware changelog | Language-Aware Changelog Generation | German entries; Default English; Existing preserved | `src/actions/finalize.md` (unchanged) |
| Auto GitHub release | Automated GitHub Release via CI | Release after bump; Tag exists; No version change; First release | `.github/workflows/release.yml` |
| Consumer pinning | Consumer Version Pinning | Pin to version; No updates | README |
| Local marketplace per target | Developer Local Marketplace Workflow | Claude registers; Reload; Version updates | README |
| Source/release/manifest separation | Source and Release Directory Structure | Editable files; Manifests at root; Generated files | repo layout, CONSTITUTION |
| Manifest source paths | Marketplace Source Configuration | Claude points to root; Codex points to shared tree; Local developer marketplace | `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json` |
| Clean repo separation | Repository Layout Separation | Clean separation | repo layout |
| AOT compilation | AOT Skill Compilation | Finalize triggers; Count validation; Legacy location cleaned | `scripts/compile-skills.sh`, `src/actions/finalize.md` |
| Compiled action contract | Compiled Action File Contract | Compiled file contains only requirements; No links | `scripts/compile-skills.sh` |
| Dev script | Dev Sync Script | Builds release dir; Requires jq; Run outside repo root | `scripts/compile-skills.sh` |

Coverage check: every requirement above maps to at least one scenario in the spec, and every spec scenario maps to at least one component touched by this change. **Status: complete.**

## B. Gap Analysis

- **Empty/missing `src/VERSION` at compile time** — covered by spec edge case ("`src/VERSION` malformed or missing") and the script's preflight read (fails with descriptive error). ✓
- **Manifest hand-edit drift on a non-version field** — accepted as maintainer-review concern (spec edge case "Per-target manifest field drift"). No automation. ✓
- **Codex marketplace upstream schema change** — covered by spec edge case ("Codex marketplace API path drift"); jq stamping preserves unknown fields verbatim. ✓
- **Existing Claude install with stale marketplace `source: "./.claude"`** — covered by spec edge case ("Existing Claude install with old marketplace source"); one-step refresh documented in README and CHANGELOG. ✓
- **Mixed-target consumer adding the second target later** — covered by spec scenarios "AGENTS.md generated alone when CLAUDE.md already exists" and inverse. ✓
- **`.gitignore` excluding `./skills/`** — covered by spec edge case for release-workflow ("`./skills/` gitignore conflict"). The maintainer's local repo already has `./skills/` un-ignored (verified via `git status` clean after compile run). ✓
- **CLAUDE.md stub accidentally edited** — covered by spec scenario "Existing CLAUDE.md preserved on re-init" + WARNING on missing import line. ✓
- **AGENTS.md missing standard section detected on re-init** — covered. ✓
- **`jq` missing on maintainer machine** — covered by spec scenario "Dev script requires jq". Hard preflight in script. ✓
- **Cross-check failure** — covered by spec scenario "Stamping failure caught by cross-check" + script post-stamp re-read. ✓

No missing edge cases identified at preflight.

## C. Side-Effect Analysis

- **Existing Claude Code consumers** — Marketplace `source` change `./.claude` → `./` requires one `claude plugin marketplace update` cycle. Documented in CHANGELOG (BREAKING — marketplace path) and README "Update" section. Single command, no data loss.
- **`.specshift/WORKFLOW.md` synced from updated `src/templates/workflow.md`** — Project-level WORKFLOW.md changes are intentional template-sync per CONSTITUTION convention. The synced fields are init-instruction body only; project-specific overrides (`worktree.enabled: true`, `auto_approve: true`, `review.request_review: copilot`) are preserved.
- **`.github/workflows/release.yml`** — Trigger file changes from `src/.claude-plugin/plugin.json` to `src/VERSION`. Verify the workflow's `on.push.paths` filter is updated; otherwise the workflow won't fire on the new SoT. **TASK FLAG: must update release.yml during apply.**
- **README "Quick Start" / "Project Structure"** — Tree diagram needs updating for the new layout; install commands gain a Codex section.
- **`CHANGELOG.md`** — One new `## [v0.2.5-beta] — 2026-04-27` entry summarizing the multi-target rollout.
- **Skill compilation output (`./skills/specshift/`)** — Replaces `.claude/skills/specshift/`. The `git rm` of the legacy tree is part of the compile-script behavior (`rm -rf` legacy path).
- **Local development plugin reload** — Maintainer must run the host's plugin-update command after the layout change to refresh their local install. Documented in CHANGELOG.

No regression risks to existing Claude-side functionality were identified — runtime behavior is unchanged; only packaging and bootstrap layout shift.

## D. Constitution Check

The change updates the following CONSTITUTION sections:

- **Architecture Rules** — Release directory line updated from `.claude/skills/specshift/` to `./skills/specshift/`. Plugin manifests line updated to "manifests live at the repo root in `.claude-plugin/`, `.codex-plugin/`, and `.agents/plugins/`".
- **Conventions — Post-apply version bump** — Source of truth changes from `src/.claude-plugin/plugin.json` to `src/VERSION`; sync mechanic changes to "compile script stamps four root files".
- **Conventions — Plugin source layout** — Marketplace source changes from `./.claude` to `./`; manifests are hand-edited at the root, not under `src/`.
- **Conventions — Agent instructions** — `AGENTS.md` is the agnostic SoT; `CLAUDE.md` is a one-line `@AGENTS.md` import stub.
- **Conventions — Tool-agnostic instructions** — Strengthened: "Compiled-into-skill files (specs that `src/actions/*.md` link into) MUST stay tool-agnostic — no `${CLAUDE_PLUGIN_ROOT}`, no Claude-specific product references except where the surrounding text is target-scoped."
- **Conventions — Local development** — Update note that the layout change requires existing maintainers to refresh their local marketplace.

These updates are part of the Apply tasks. No new architectural pattern is being introduced beyond what the multi-target-distribution spec already declares.

## E. Duplication & Consistency

- **Bootstrap rule duplication** — Was a risk before this change (claude.md was the only bootstrap template carrying workflow rules). After this change: the rule lives only in `src/templates/agents.md`; `claude.md` carries the import stub only. Single source of truth verified by G1 PASS criterion.
- **Version-field duplication** — Four root files all carry a `version` field. This is intentional duplication (each target's marketplace/manifest needs its own version). The compile script's symmetric-stamping requirement guarantees they always agree, and the post-stamp cross-check enforces that at build time.
- **Spec consistency** — `multi-target-distribution.md` (NEW) and `release-workflow.md` (MODIFIED) both reference the version SoT and the four-file stamping. Cross-checked: both name `src/VERSION` consistently and both name the same four files. No contradictions.
- **Spec consistency — bootstrap pattern** — `multi-target-distribution.md` "Bootstrap SSoT Pattern" requirement and `project-init.md` "Bootstrap Files Generation" requirement both describe the same agnostic-AGENTS.md + CLAUDE.md-stub flow. The boundaries are: multi-target-distribution describes the *plugin packaging* aspect (template structure, what compile script ships); project-init describes the *consumer init action* aspect (what gets generated where). No overlap, complementary specs.
- **AGENTS.md (project) ↔ src/templates/agents.md** — Project-level AGENTS.md is a one-time bootstrap output, not a kept-in-sync copy. The template carries the universal bootstrap content; the project's AGENTS.md is hand-edited with project-specific rules. No drift expectation; intentional divergence.

No duplication or contradiction issues found.

## F. Assumption Audit

Assumptions collected from `multi-target-distribution.md` and `design.md`:

| # | Assumption (visible text) | Tag | Rating |
|---|---------------------------|-----|--------|
| 1 | The Codex CLI's plugin manifest schema, marketplace location (`.agents/plugins/marketplace.json`), and skill discovery paths described in OpenAI's `developers.openai.com/codex` documentation are stable as of 2026-04-27. | Codex CLI plugin schema stable | Acceptable Risk — verified against live docs at research time; if upstream changes, jq-stamping preserves unknown fields, so impact is bounded |
| 2 | Claude Code's `@AGENTS.md` import syntax loads the referenced file into the session context at startup, as documented at `code.claude.com/docs/de/memory#agents-md`. | Claude Code AGENTS.md import behavior | Acceptable Risk — documented behavior, demonstrated by the project's own AGENTS.md import working in this very session |
| 3 | The `.agents/plugins/marketplace.json` file format and discovery is consistent with the Codex `codex /plugins` command behavior; if Codex requires a different filename or location in a future release, the compile script will need updating. | Codex marketplace file convention | Acceptable Risk — script update is one jq path; manageable |
| 4 | Both Claude Code and Codex resolve plugin-bundled assets referenced in skill prose (e.g., "the plugin's `templates/` directory") relative to the skill's installed location; neither runtime requires environment-variable interpolation in skill body text. | Agnostic asset resolution | Acceptable Risk — Shopify-AI-Toolkit pattern verified working with this assumption |
| 5 | `jq` is available on every maintainer's build machine. | jq build dependency | Acceptable Risk — already present on the maintainer's system; documented in spec edge case; hard preflight in script with descriptive error |

All assumptions: **Acceptable Risk**. No Needs Clarification, no Blocking.

## G. Review Marker Audit

`grep -rn "<!-- REVIEW" .specshift/changes/2026-04-27-multi-target-distribution/ docs/specs/multi-target-distribution.md docs/specs/project-init.md docs/specs/release-workflow.md`

Result: 0 hits. No remaining REVIEW markers. **Not Blocking.**

## Verdict

**PASS** — proceed to test generation and task creation.
