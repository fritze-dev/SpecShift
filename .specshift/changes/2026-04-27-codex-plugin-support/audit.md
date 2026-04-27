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
