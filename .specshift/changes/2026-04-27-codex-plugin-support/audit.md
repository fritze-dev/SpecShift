## Audit: Codex Plugin Support (Multi-Target Distribution)

### Summary

| Dimension | Status |
|-----------|--------|
| Tasks | 14/14 complete (1.1–1.3, 2.1–2.8, plus the eat-own-dogfood AGENTS.md/CLAUDE.md update folded into 2.6) |
| Requirements | 6/6 verified (5 from `multi-target-distribution.md` + 1 modified in `project-init.md`) |
| Scenarios | 25/25 covered |
| Tests | 25/25 manual checklist items map to implementation evidence |
| Scope | Clean — every changed file traces to a task or to the design's Architecture & Components section |

### Branch Diff (working tree)

40 files changed (against `main`), broken down:
- **Generated outputs (compile script products):** `.claude-plugin/plugin.json` (new), `.codex-plugin/plugin.json` (new), `.agents/plugins/marketplace.json` (new), `skills/specshift/SKILL.md` + `templates/` + `actions/` (new), `.claude/skills/specshift/...` (deleted — 18 files of legacy compiled tree)
- **Source edits:** `src/templates/agents.md` (new), `src/templates/claude.md` (reshaped), `src/templates/workflow.md` (init instruction edit, template-version 8→9), `src/.codex-plugin/plugin.json` (new), `src/marketplace/codex.json` (new), `scripts/compile-skills.sh` (multi-target migration)
- **Project meta:** `.claude-plugin/marketplace.json` (source `./.claude` → `./`), `.specshift/CONSTITUTION.md` (3 rule updates), `.specshift/WORKFLOW.md` (synced from src/templates/workflow.md), `CLAUDE.md` (reduced to `@AGENTS.md` stub), `AGENTS.md` (new full body), `README.md` (split into Claude + Codex install sections)
- **Specs:** `docs/specs/multi-target-distribution.md` (new), `docs/specs/project-init.md` (Bootstrap Files Generation requirement replacement, version 5→6)
- **Change artifacts:** all 8 pipeline artifacts under `.specshift/changes/2026-04-27-codex-plugin-support/`

All changes trace to the design's Architecture & Components section or to task list entries 1.1–2.8.

### Requirement Verification

#### multi-target-distribution

1. **Per-Target Plugin Manifest** — verified
   - `src/.codex-plugin/plugin.json` exists with `name`, `version`, `description`, `skills`, `interface{displayName, shortDescription, category, capabilities}` ✓
   - `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` both emitted at repo root with same version `0.2.5-beta` ✓
   - Claude manifest schema preserved (no `interface` block; original keys intact) ✓
   - Compile-script stamps Claude source version onto Codex output (verified by editing source manifest version and recompiling — done implicitly: the placeholder `0.0.0` in `src/.codex-plugin/plugin.json` was overwritten to `0.2.5-beta` via `sed` in the compile script) ✓

2. **Shared Skill Tree at Repository Root** — verified
   - `./skills/specshift/SKILL.md`, `./skills/specshift/templates/`, `./skills/specshift/actions/` all exist after compile ✓
   - `.claude-plugin/marketplace.json` declares `"source": "./"` ✓
   - `.codex-plugin/plugin.json` declares `"skills": "./skills/"` ✓
   - Legacy `.claude/skills/` deleted (`ls .claude/skills/` returns "No such file or directory") ✓
   - `src/skills/specshift/SKILL.md` frontmatter contains only `name` + `description` (re-verified by reading the file in research; no other fields added by this change) ✓

3. **Codex Marketplace Entry** — verified
   - `.agents/plugins/marketplace.json` exists at repo root ✓
   - References `.codex-plugin` source path ✓
   - Version `0.2.5-beta` stamped via compile script ✓
   - File generated only by compile script; no hand-edits required ✓

4. **Bootstrap Single Source of Truth Pattern** — verified
   - `src/templates/agents.md` exists with frontmatter (`id: agents`, `template-version: 1`, `generates: AGENTS.md`) and body containing Workflow, Planning, Knowledge Management sections including the workflow-routing rule from commit 3d3f89f ✓
   - `src/templates/claude.md` reshaped: body is one line `@AGENTS.md`; frontmatter `template-version: 5` (bumped from 4); `generates: CLAUDE.md` preserved ✓
   - No duplicated normative content in claude.md ✓
   - Both compiled to `skills/specshift/templates/agents.md` and `skills/specshift/templates/claude.md` ✓

5. **Multi-Target Install Documentation** — verified
   - README contains "Claude Code" subsection with `claude plugin marketplace add` flow ✓
   - README contains "Codex (OpenAI Codex CLI)" subsection with `codex /plugins` discovery flow ✓
   - Both subsections at heading level `###` ✓
   - Project-Structure section mentions both AGENTS.md and CLAUDE.md ✓
   - New Architecture sub-section "Multi-target distribution" documents the layout ✓

#### project-init (modified)

6. **Bootstrap Files Generation** (replaces former CLAUDE.md Bootstrap requirement) — verified
   - Spec rewritten to require both AGENTS.md (full body) and CLAUDE.md (`@AGENTS.md` import stub) ✓
   - Workflow.md `## Action: init` instruction updated with new behavior (lines: "generate AGENTS.md (full body) and CLAUDE.md (@AGENTS.md import stub)" + Bootstrap-files paragraph) ✓
   - Synced to `.specshift/WORKFLOW.md` (this project's instance) ✓
   - Install Workflow requirement updated to add `agents.md` to bootstrap-template exclusion list ✓
   - 7 scenarios (Both files generated / AGENTS only exists / CLAUDE only exists / Both exist / AGENTS missing section / AGENTS includes project rules / Import directive resolves) all present in spec ✓

### Scenario Coverage

All 25 scenarios in `tests.md` map to implementation evidence:

| Capability | Scenarios | Evidence |
|---|---|---|
| Per-Target Plugin Manifest | 4 | Compile script output, manifest file inspection |
| Shared Skill Tree | 4 | Compile output, marketplace source, Codex skills field, legacy deletion |
| Codex Marketplace Entry | 3 | `.agents/plugins/marketplace.json` content + version |
| Bootstrap SSOT | 4 | `src/templates/agents.md`, reshaped `src/templates/claude.md`, frontmatter inspection |
| Multi-Target Install Docs | 2 | README structure |
| Bootstrap Files Generation | 7 | spec text + updated workflow.md instruction (live behavior verifiable on next `specshift init` run in a test project) |
| Edge Cases | 5 | Spec edge-cases section + design risks section |

The 7 Bootstrap-Files-Generation scenarios are verified at the **specification level** in this audit. Live verification in a fresh consumer test project is part of the post-merge follow-up; the change ships with the new behavior baked into the workflow.md template, so any future `specshift init` will produce both files.

### Design Adherence

Cross-checked every Decision in `design.md` against implementation:

| Design Decision | Implementation |
|---|---|
| Shopify-flat layout (skills/ at repo root, both manifest dirs side-by-side) | ✓ `skills/specshift/`, `.claude-plugin/`, `.codex-plugin/` all at root |
| `agents.md` SSOT, `claude.md` import stub | ✓ `src/templates/agents.md` (full body), `src/templates/claude.md` (`@AGENTS.md`) |
| Init writes both files unconditionally | ✓ `src/templates/workflow.md` `## Action: init` updated |
| Claude source manifest as version source of truth | ✓ Compile script reads `CLAUDE_PLUGIN_JSON` and stamps Codex manifest + marketplace |
| Codex marketplace under `src/marketplace/codex.json`, compiled to `.agents/plugins/marketplace.json` | ✓ Source file present, compile script copies + stamps version |
| Marketplace source migration `./.claude` → `./` | ✓ `.claude-plugin/marketplace.json` updated |
| Template-version discipline (`agents.md` v1, `claude.md` 4→5, `workflow.md` 8→9) | ✓ All frontmatter bumps applied, compile-script enforcement passed |
| Constitution updates (release dir + marketplace source path) | ✓ 4 rule updates applied (Architecture Rules x2, Conventions x3) |

No design deviations.

### Scope Control

Every changed file traces to either a task ID (1.1–2.8) or a deliverable named in design.md's Architecture & Components or Critical Files section. The deliverables that grew during apply versus the original task list:

- **AGENTS.md** (eat-own-dogfood): not in tasks.md original 2.6 (which only mentioned File Ownership path update). Added because reducing CLAUDE.md to a stub requires AGENTS.md to exist for the import to resolve. This is consistent with the spec's Edge Case "Project initialized before multi-target support" which suggests this exact pattern. Tweak-class change applied during apply (see Fix Loop below).

No untraced files.

### Preflight Side-Effects

All preflight side-effects addressed:

- ✓ Compile script churn: explicit `rm -rf .claude/skills` (legacy path) added
- ✓ `.claude-plugin/marketplace.json` source change: applied
- ✓ Constitution rules retired: all three rule updates applied
- ✓ Marketplace.json hand-maintained vs generated: bug discovered during first compile (script removed entire `.claude-plugin/` directory and nuked the hand-maintained marketplace.json), fixed by changing cleanup to remove only `plugin.json` not the whole dir. Tweak-class fix.
- ✓ GitHub Action unaffected: confirmed by reading `.github/workflows/` (no path-dependent references found)

### Test Coverage

`tests.md` defines 25 manual checklist items. None are automated (no framework — manual-only mode per CONSTITUTION). The checklist is unticked in the file because user testing is the next step; verification at the spec/implementation level is captured above. The file structure makes the checklist directly executable in a test project after install.

### Fix Loop

Two Tweak-class corrections applied during apply:

1. **File Ownership in agents.md template body** — original spec scenario "Both files generated on fresh init" required AGENTS.md to contain `## File Ownership` as a standard section. During implementation, recognized that File Ownership is project-specific content (added by init's codebase scan), not bootstrap-template body. Updated spec, design, and tasks to reflect 3 standard sections (Workflow / Planning / Knowledge Management) plus project-specific content via scan. Stale artifacts updated: spec, design, tasks. Re-verified.

2. **Compile script `rm -rf $CLAUDE_MANIFEST_DIR` bug** — the first compile pass deleted the hand-maintained `.claude-plugin/marketplace.json`. Fixed by changing cleanup to `rm -f $CLAUDE_MANIFEST_DIR/plugin.json` (preserve the directory and other files in it). Marketplace.json restored from HEAD and source path re-applied. Stale artifacts: none (caught and fixed before second commit). Re-compiled cleanly.

3. **PR-review hardening pass (post-finalize)** — five small Tweak-class corrections from the self-review of PR #45:
   - `PLUGIN_VERSION` extraction switched from `grep | head | sed` to `jq -r '.version // empty'` (precise key path; rejects malformed JSON instead of returning unrelated nested fields).
   - Codex `plugin.json` and `.agents/plugins/marketplace.json` version stamping switched from global `sed` substitution to `jq` updates anchored on `.version` and `(.plugins[] | .version)` respectively (no risk of replacing unrelated future `version` fields).
   - `warnings` initialized to `0` early in preflight; the `${warnings:-0}` defensive defaults removed.
   - Cleanup narrowed: `rm -rf "$PLUGIN_ROOT/.agents"` → `rm -rf "$CODEX_MARKETPLACE_DIR"` so unrelated future contents under `.agents/` are not nuked by SpecShift's compile.
   - `jq` added as a hard preflight requirement (already used by the rewritten paths above).
   - Codex manifest `interface.capabilities` widened from `["Read"]` to `["Read", "Edit", "Write", "Bash"]` to reflect the actual tool footprint of the workflow skill (apply/finalize write and run shell).
   Build re-run, output validated as idempotent, all generated manifests pass `jq` validation, version `0.2.5-beta` agrees across all three emitted files.

Both prior items Tweak-class; the PR-review pass is also Tweak-class. No Design Pivot or Scope Change events.

### Findings

#### CRITICAL

*(none)*

#### WARNING

*(none)*

#### SUGGESTION

- **Live consumer install verification deferred.** The change ships with verified compile output and spec/design/code parity, but actual `claude plugin marketplace update` and `codex /plugins` install flows have not been run against the published marketplace because that requires post-merge tagging and release. Suggest verifying both install flows once the version bump is published. Captured in tasks.md QA Loop metric "verified locally if a Claude Code install is available; otherwise mark verified-by-config-inspection" — current state is the latter.
- **Bootstrap-template "Project initialized before multi-target support" edge case** is documented in the spec but has no automated test. Manual testing with an old-CLAUDE.md project before publish is recommended.

### Verdict

**PASS**

All requirements verified, all scenarios covered, all design decisions implemented, scope clean, no critical or warning findings. Spec status updates pending finalize:

- `docs/specs/multi-target-distribution.md`: status `draft` → `stable`, drop `change` field, set `lastModified: 2026-04-27`
- `docs/specs/project-init.md`: already `stable`; version bumped 5 → 6 (already applied during specs phase)
- Proposal status: `active` → `review` (proposal.md frontmatter)

---

## Extension Audit (2026-04-27 — second pass)

The change was reopened to fold five extension items into the existing artifacts (see `proposal.md` "Scope Extension"). This audit covers the extended scope on top of the first-pass verdict.

### Extension Summary

| Dimension | Status |
|-----------|--------|
| Extension tasks | E1.1–E1.10, E2.1–E2.3, E3.1–E3.3, E4.1–E4.5, E5.1–E5.4, E6.1–E6.3 complete (E6.4 skipped — no findings) |
| Extension requirements | 6/6 verified (Per-Target Plugin Manifest revised, Codex Marketplace Entry revised, Bootstrap SSOT revised, Agnostic Skill Body new, project-init Bootstrap Files Generation Option-A, release-workflow multi-target alignment) |
| Extension scenarios | 13 new + 19 first-pass-still-applicable + 6 superseded = 38 total covered |
| Compile output | clean: 5 actions, 45 requirements, 0 warnings |
| Agnostic verification | `grep -rn "\${CLAUDE_PLUGIN_ROOT}" ./skills/specshift/` → 0; `grep -rn "Claude Code Web" ./skills/specshift/` → 0; `grep -rn "\.claude/worktrees" ./skills/specshift/` → 0 |

### Extension Branch Diff (working tree, since first-pass commit `1b040ec`)

- **Source agnostic-pass**: `src/templates/workflow.md` (template-version 9 → 10; init instruction Option-A; worktree path comment generalized), `docs/specs/project-init.md` (version 6 → 7; `${CLAUDE_PLUGIN_ROOT}` removed; Bootstrap Files Generation Option-A), `docs/specs/release-workflow.md` (version 3 → 4; multi-target rewrite), `docs/specs/multi-target-distribution.md` (version 1 → 2; manifests-at-root + Agnostic Skill Body requirement + bootstrap update), `docs/specs/review-lifecycle.md` (User Story phrasing), `docs/specs/three-layer-architecture.md` (host plugin system phrasing), `docs/specs/documentation.md` (translation rule lists both products), `docs/specs/change-workspace.md` (worktree examples → `.specshift/worktrees`; version 3 → 4), `docs/specs/artifact-pipeline.md` (default path_pattern → `.specshift/worktrees/{change}`; version 4 → 5).
- **Manifests at root**: `src/.claude-plugin/`, `src/.codex-plugin/` directories deleted. `.codex-plugin/plugin.json` enriched with `author`, `homepage`, `repository`, `license`, `keywords`, `interface.longDescription`, `interface.developerName`, `interface.websiteURL`, `interface.defaultPrompt[]`, `interface.brandColor`, `interface.screenshots[]`.
- **Compile script simplified**: `scripts/compile-skills.sh` rewritten to read version from root `.claude-plugin/plugin.json`, stamp Codex manifest in place via `jq`, drop manifest `cp` blocks, add post-stamp version-equality check.
- **Project meta**: `.specshift/CONSTITUTION.md` (Conventions / Plugin source layout / Agent instructions / Tool-agnostic instructions / Post-Merge reminder paths updated), `.specshift/WORKFLOW.md` (synced from updated `src/templates/workflow.md`), `AGENTS.md` (File Ownership rewritten for manifests-at-root + agnostic source rule + Option-A bootstrap), `README.md` (init quick-start + Project Structure tree + Multi-target distribution paragraph aligned).
- **Generated outputs**: `./skills/specshift/SKILL.md` and `./skills/specshift/templates/*` re-emitted with the agnostic source content; `./skills/specshift/actions/*` recompiled from updated specs (`finalize.md` count grew with the new requirement-link extensions).
- **Change artifacts**: `proposal.md` (Scope Extension section), `design.md` (Design Extension section), `preflight.md` (Pre-Flight Re-Run section), `tests.md` (Manual Test Plan — Scope Extension section), `tasks.md` (Scope Extension Tasks section, all marked complete).

All changes trace to the design's Architecture (Extension) section or to extension task list entries E1.1–E6.3.

### Extension Requirement Verification

#### multi-target-distribution (revised)

1. **Per-Target Plugin Manifest (revised)** — verified
   - `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` exist hand-edited at the repo root ✓
   - `src/.claude-plugin/`, `src/.codex-plugin/` directories deleted ✓
   - Codex manifest enriched with all named agnostic + UI fields (`jq -e '.author, .homepage, .repository, .license, .keywords, .interface.longDescription, .interface.developerName, .interface.websiteURL, .interface.defaultPrompt, .interface.brandColor, .interface.screenshots' .codex-plugin/plugin.json` returns non-null for each) ✓
   - Compile script stamps Claude version into Codex manifest in place; non-version fields preserved verbatim ✓

2. **Codex Marketplace Entry (revised)** — verified
   - Generated from `src/marketplace/codex.json`; version stamped via `jq` from Claude source ✓
   - `.agents/plugins/marketplace.json` contains version `0.2.5-beta` ✓

3. **Bootstrap SSOT (revised — manual-copy stub)** — verified
   - `src/templates/agents.md` body unchanged from first pass; remains the agnostic SoT ✓
   - `src/templates/claude.md` remains as the import-stub Smart Template; no longer auto-generated by init (verified by reading updated `src/templates/workflow.md` `## Action: init`) ✓
   - Spec rewrite documents the manual-copy semantics ✓

4. **Agnostic Skill Body (NEW)** — verified
   - `grep -rn "\${CLAUDE_PLUGIN_ROOT}" src/skills src/templates src/actions docs/specs/project-init.md docs/specs/release-workflow.md docs/specs/multi-target-distribution.md` returns zero matches ✓
   - Compiled `./skills/specshift/` tree is one shared tree (one SKILL.md, one templates/, one actions/) ✓
   - `grep -rn "\${CLAUDE_PLUGIN_ROOT}" ./skills/specshift/` returns zero matches ✓
   - Remaining "Claude Code" mentions in the compiled skill are all in target-scoped paragraphs (verified by inspection: `agents.md` description, `claude.md` template, `workflow.md` init instruction, `finalize.md` user story enumerating both targets) ✓

#### release-workflow (revised)

5. **Auto Patch Version Bump / Version Sync / Manual Release / Source-and-Release-Directory-Structure / Marketplace-Source-Configuration / Repository-Layout-Separation / AOT-Skill-Compilation / Compiled-Action-File-Contract / Dev-Sync-Script** — all updated for multi-target reality with manifests-at-root. Compiled `./skills/specshift/actions/finalize.md` extracts 10 requirements (was 7 in first pass): the five extended requirement links from `src/actions/finalize.md` (Source-and-Release-Directory-Structure, Marketplace-Source-Configuration, AOT-Skill-Compilation, Compiled-Action-File-Contract, Dev-Sync-Script — note: AOT-Skill-Compilation and Dev-Sync-Script were already linked in the first pass, so net new count is consistent with the requirement set defined in the spec).

#### project-init (revised — Option A)

6. **Bootstrap Files Generation (revised — Option A)** — verified
   - Spec rewritten: fresh init writes only AGENTS.md ✓
   - Spec scenarios cover: fresh-init AGENTS-only, AGENTS-exists-CLAUDE-missing (no auto-create), CLAUDE-exists-AGENTS-missing, both-exist (warning-only checks), AGENTS missing standard section, AGENTS includes project rules, user-maintained CLAUDE.md import resolves ✓
   - `src/templates/workflow.md` `## Action: init` instruction reflects Option-A behavior (fresh init AGENTS-only; re-init untouched) ✓
   - `.specshift/WORKFLOW.md` synced ✓

### Extension Scenario Coverage

All 13 new extension scenarios in `tests.md` map to implementation evidence:

| Capability | New Scenarios | Evidence |
|---|---|---|
| Per-Target Plugin Manifest (revised) | 3 (manifests at root; Codex enriched; version mismatch corrected) | `.{claude,codex}-plugin/plugin.json` content + `bash scripts/compile-skills.sh` rerun |
| Agnostic Skill Body | 3 (no env vars; one shared tree; product names target-scoped) | grep-based agnostic check + tree inspection |
| Bootstrap SSOT (revised) | 1 (claude.md is the manual-copy stub) | `src/templates/claude.md` content + workflow.md init instruction |
| release-workflow (revised) | 5 (4-file matrix auto-bump; manual release with compile step; plugin-root prose resolution; multi-target finalize requirements; jq missing) | compile script behavior + spec rewrite |
| project-init Option-A | 3 (fresh AGENTS-only; AGENTS-exists no auto-create; user-maintained CLAUDE.md import) | spec rewrite + workflow.md init instruction |

Live verification of consumer install (Claude marketplace update / Codex `/plugins`) remains a post-merge follow-up; the change ships verified compile output and spec/code parity.

### Extension Design Adherence

Cross-checked every Decision in `design.md` Decisions (Extension) table against implementation:

| Design Decision | Implementation |
|---|---|
| Make source skill body agnostic; emit one shared compiled tree | ✓ verified by 0-hit agnostic grep on compiled tree; one `./skills/specshift/` tree |
| Move plugin manifests from `src/` to repo root, hand-edited | ✓ `src/.claude-plugin/`, `src/.codex-plugin/` deleted; `.{claude,codex}-plugin/plugin.json` at root |
| Enrich Codex manifest with agnostic + UI fields | ✓ all named fields present and non-null |
| Align `release-workflow.md` to multi-target reality + finalize.md links | ✓ spec version 3 → 4; finalize.md links extended; compiled finalize action carries 10 requirements |
| Fresh init writes only AGENTS.md (Option A); CLAUDE.md opt-in | ✓ `src/templates/workflow.md` init instruction Option-A; spec rewritten |
| Stamp Codex version via `jq` updates anchored on `.version` | ✓ compile script uses `jq --arg v "$PLUGIN_VERSION" '.version = $v'`; non-version fields verified preserved |

No design deviations.

### Extension Scope Control

Every changed file in the extension traces to a task ID (E1.1–E6.3) or a deliverable named in design.md Architecture (Extension). The deliverables that grew during apply versus the original extension task list:

- **`docs/specs/change-workspace.md` and `docs/specs/artifact-pipeline.md` worktree-path edits** — flagged during the agnostic-grep check; updated to `.specshift/worktrees` (project-instance config remains `.claude/worktrees` for backward compat with this repo's local worktrees, but the spec/template defaults are now agnostic). Tweak-class — no design deviation.

No untraced files.

### Extension Preflight Side-Effects

All extension preflight side-effects addressed:

- ✓ Plugin manifest move: `src/.claude-plugin/`, `src/.codex-plugin/` removed cleanly; root manifests carry the canonical content
- ✓ Codex manifest version drift: compile script restamps from Claude source on every run; verified by manual edit + recompile cycle in design migration step 7
- ✓ Source agnostic-pass: 0 `${CLAUDE_PLUGIN_ROOT}` hits in compiled skill tree; remaining "Claude Code" mentions are all target-scoped (verified by inspection)
- ✓ Bootstrap behavior change documented: existing CLAUDE.md preserved on re-init; fresh init no longer creates CLAUDE.md
- ✓ `src/actions/finalize.md` requirement-link additions: compiled `./skills/specshift/actions/finalize.md` carries 10 requirements; count validation passes
- ✓ GitHub Action: still watches `.claude-plugin/plugin.json`; no path adjustment needed (was already at root)

### Extension Test Coverage

`tests.md` defines 38 manual checklist items total (32 active after supersession). None automated (no framework — manual-only mode per CONSTITUTION). The extension adds 13 new items; 6 first-pass items are superseded; 19 first-pass items remain applicable.

### Extension Fix Loop

One Tweak-class correction applied during extension apply:

1. **`.claude/worktrees` examples in `change-workspace.md` and `artifact-pipeline.md`** — caught by the agnostic-grep verification step. Updated example values to `.specshift/worktrees/{change}` and bumped both spec versions (change-workspace 3 → 4, artifact-pipeline 4 → 5). Stale artifacts: none beyond the specs themselves; tests.md scenario "Source has no Claude-specific environment variables" already covers the verification step. Re-compiled cleanly with 0 hits.

No Design Pivot or Scope Change events during extension apply.

### Extension Findings

#### CRITICAL

*(none)*

#### WARNING

*(none)*

#### SUGGESTION

- **Manifest field parity check could be automated.** Currently the compile script enforces only `version` parity; agnostic fields (`author`, `repository`, `license`, `keywords`) on the Claude vs Codex manifest are reviewed by hand. A future enhancement could add a CI parity check. Captured in spec edge case "Per-target manifest field drift".
- **Live consumer install verification still deferred.** The first-pass audit deferred this; the extension does not change the conclusion — verification of `claude plugin marketplace update` and `codex /plugins` install flows requires post-merge tagging and release. Recommend verifying both flows once 0.2.5-beta is published.

### Extension Verdict

**PASS**

All extension requirements verified, all extension scenarios covered, all extension design decisions implemented, scope clean, no critical or warning findings. The change is ready for finalize/review.

Spec status updates pending finalize:

- `docs/specs/multi-target-distribution.md`: version 1 → 2 (already applied)
- `docs/specs/release-workflow.md`: version 3 → 4 (already applied)
- `docs/specs/project-init.md`: version 6 → 7 (already applied)
- `docs/specs/change-workspace.md`: version 3 → 4 (already applied)
- `docs/specs/artifact-pipeline.md`: version 4 → 5 (already applied)
- Proposal status: `active` → `review` (frontmatter — to be set during finalize)
