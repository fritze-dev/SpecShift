# Implementation Tasks: Codex Plugin Support (Multi-Target Distribution)

## 1. Foundation

- [x] 1.1. Create `src/.codex-plugin/plugin.json` with Codex schema (`name`, `version: "0.0.0"` placeholder, `description`, `skills: "./skills/"`, `interface` block with `displayName: "SpecShift"`, `shortDescription`, `category: "Productivity"`, `capabilities: ["Read"]`).
- [x] 1.2. Create `src/marketplace/codex.json` as the Codex marketplace template (JSON file referencing `./.codex-plugin/plugin.json` with placeholder version).
- [x] 1.3. Create `src/templates/agents.md` with frontmatter (`id: agents`, `template-version: 1`, `description: AGENTS.md bootstrap (full body)`, `generates: AGENTS.md`, `requires: []`, `instruction:` carried over from claude.md). Body: copy the full body of current `src/templates/claude.md` (Workflow / Planning / Knowledge Management sections including the workflow-routing rule from commit 3d3f89f).

## 2. Implementation

### 2.1. Reshape claude.md to import stub
- [x] 2.1.1. Replace `src/templates/claude.md` body with a single line: `@AGENTS.md`. Bump `template-version` from 4 to 5. Update `description` frontmatter to "CLAUDE.md import stub for Claude Code (delegates to AGENTS.md)". Keep `generates: CLAUDE.md`.

### 2.2. Update workflow.md init instruction
- [x] 2.2.1. Edit `src/templates/workflow.md` `## Action: init` instruction text to reference both `AGENTS.md` and `CLAUDE.md` generation. Bump `template-version` from 8 to 9.
- [x] 2.2.2. Sync changes into `.specshift/WORKFLOW.md` (preserve project-specific overrides: `worktree.enabled: true`, `request_review: copilot`).

### 2.3. Migrate compile-skills.sh to multi-target output
- [x] 2.3.1. Change `PLUGIN_ROOT=".claude"` to `PLUGIN_ROOT="."`. Verify `SKILL_DIR="$PLUGIN_ROOT/skills/specshift"` resolves to `./skills/specshift`.
- [x] 2.3.2. Update the cleanup block to remove both the new path (`rm -rf $SKILL_DIR`) and the legacy path (`rm -rf .claude/skills`) to ensure stale artifacts are gone.
- [x] 2.3.3. Update the manifest copy block: copy `src/.claude-plugin/plugin.json` → `.claude-plugin/plugin.json` at repo root.
- [x] 2.3.4. Add a second manifest copy block: copy `src/.codex-plugin/plugin.json` → `.codex-plugin/plugin.json` at repo root, then stamp `version` from the Claude source manifest.
- [x] 2.3.5. Add a marketplace copy block: copy `src/marketplace/codex.json` → `.agents/plugins/marketplace.json`, stamping the plugin version.
- [x] 2.3.6. Update the plugin-version stamping line to target `./skills/specshift/templates/workflow.md` (was `.claude/skills/specshift/templates/workflow.md`).
- [x] 2.3.7. Verify the template-version enforcement block still works (compares against `main`).

### 2.4. Update marketplace source path
- [x] 2.4.1. Edit `.claude-plugin/marketplace.json` to set `source: "./"` (was `./.claude`).

### 2.5. Update CONSTITUTION
- [x] 2.5.1. Edit `.specshift/CONSTITUTION.md` Architecture Rules: change `.claude/skills/specshift/` reference to `./skills/specshift/`.
- [x] 2.5.2. Edit `.specshift/CONSTITUTION.md` Conventions / Plugin source layout: change `source: "./.claude"` to `source: "./"`; mention both manifest source dirs (`src/.claude-plugin/`, `src/.codex-plugin/`).
- [x] 2.5.3. Bump `.specshift/CONSTITUTION.md` template-version (1 → 2) only if compile-script enforcement requires it; constitution.md is in `src/templates/` and follows template-version discipline. Update the source `src/templates/constitution.md` if the rule edits also apply to consumer constitution skeleton (likely not — the consumer skeleton is a placeholder). Verify which file needs the bump.

### 2.6. Update File Ownership in this project's CLAUDE.md/AGENTS.md
- [x] 2.6.1. Update the project-level `CLAUDE.md` File Ownership section (line ~52) so that `.claude/skills/specshift/` is replaced with `./skills/specshift/` to reflect the new release directory.

### 2.7. Update README
- [x] 2.7.1. In `README.md`, restructure the install section into two subsections at the same heading level: "Claude Code" (existing `claude plugin marketplace add fritze-dev/specshift` flow) and "Codex" (new `codex /plugins` discovery + the marketplace path).
- [x] 2.7.2. Update any references in README to `.claude/skills/specshift/` to point to `./skills/specshift/`.

### 2.8. First compile + repo-level cleanup
- [x] 2.8.1. Run `bash scripts/compile-skills.sh`. Confirm exit 0, zero warnings.
- [x] 2.8.2. Verify the output: `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`, `./skills/specshift/SKILL.md`, `./skills/specshift/templates/agents.md`, `./skills/specshift/templates/claude.md` all exist.
- [x] 2.8.3. Verify the legacy directory `.claude/skills/` is gone.
- [x] 2.8.4. Stage the deletion of the old `.claude/skills/` tree and the addition of the new `./skills/`, both manifest dirs, and `.agents/`.

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
  - [x] `bash scripts/compile-skills.sh` exits 0 with no warnings.
  - [x] `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `skills/specshift/SKILL.md`, `.agents/plugins/marketplace.json` all exist post-compile, all stamped with the same version string.
  - [x] `skills/specshift/templates/agents.md` and `skills/specshift/templates/claude.md` both exist post-compile.
  - [x] `.claude/skills/` legacy path does NOT exist post-compile.
  - [x] `claude plugin marketplace update specshift && claude plugin update specshift@specshift` resolves without manual intervention (verified locally if a Claude Code install is available; otherwise mark verified-by-config-inspection).
  - [x] In a fresh consumer test project, `specshift init` produces `AGENTS.md` (full body with Workflow, Planning, Knowledge Management sections plus any project-specific scan output) and `CLAUDE.md` (≤ 5 lines, contains `@AGENTS.md`).
  - [x] `grep -c "@AGENTS.md" CLAUDE.md` returns `1` in the generated CLAUDE.md.
  - [x] `wc -l < CLAUDE.md` returns ≤ 10 in the generated CLAUDE.md.
- [x] 3.2. Auto-Verify: generate audit.md using the audit template.
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: Classify each correction before fixing. Update all stale artifacts before re-implementing. Specs must match code before proceeding.
  - **Tweak**: wrong value/typo → fix in place
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks + re-implement
  - **Scope Change**: wrong requirements → update specs + design + re-implement fully
- [x] 3.5. Final Verify: regenerate audit.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [x] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [x] 4.2. Bump version
- [x] 4.3. Commit and push to remote
- [x] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable
- [x] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`) — applies when change modifies files under `src/` or `./skills/`

---

## Scope Extension Tasks (2026-04-27 — second pass)

The change is reopened to fold five extension items into the existing implementation. Tasks below are net-new on top of the completed first-pass tasks.

### E1. Source agnostic-pass

- [x] E1.1. `docs/specs/project-init.md` — replace every `${CLAUDE_PLUGIN_ROOT}/templates/...` reference with prose ("the plugin's `templates/` directory" or "the plugin's `templates/<file>`"). Bump spec version to 7.
- [x] E1.2. `docs/specs/release-workflow.md` — rewrite Source-and-Release-Directory-Structure / Marketplace-Source-Configuration / Repository-Layout-Separation / AOT-Skill-Compilation / Compiled-Action-File-Contract / Dev-Sync-Script / Auto-Patch-Version-Bump / Version-Sync-Between-Plugin-Files / Manual-Release-Process / Consumer-Update-Process for multi-target reality and root-manifest layout. Bump version to 4.
- [x] E1.3. `docs/specs/multi-target-distribution.md` — rewrite Per-Target-Plugin-Manifest for hand-edited root manifests with enrichment; Bootstrap-SSOT updated (third pass: fresh init generates both AGENTS.md and the CLAUDE.md `@AGENTS.md` import stub); add new Agnostic-Skill-Body requirement; add agnostic-asset-resolution assumption. Bump version to 3.
- [x] E1.4. `docs/specs/review-lifecycle.md` — User Story phrasing: "Claude Code Web" → "ephemeral / stateless agent sessions".
- [x] E1.5. `docs/specs/three-layer-architecture.md` — "Claude Code plugin system" → "the host plugin system (Claude Code, Codex CLI)".
- [x] E1.6. `docs/specs/documentation.md` — translation rule lists both product names: "Product names (Claude Code, Codex)".
- [x] E1.7. `src/skills/specshift/SKILL.md` — verify no Claude-specific tokens; agnostic phrasing for any plugin-asset references.
- [x] E1.8. `src/templates/workflow.md` — `## Action: init` instruction: fresh init generates both `AGENTS.md` (full body) and `CLAUDE.md` (one-line `@AGENTS.md` import stub); existing files never overwritten on re-init; standard-sections checks remain passive WARNING-only. Bump template-version to 11 (third-pass reversal of the second-pass narrowing).
- [x] E1.9. `src/templates/agents.md` — verify body still works as agnostic SoT; no edits expected unless wording drifts.
- [x] E1.10. `src/actions/finalize.md` — add requirement links: Source-and-Release-Directory-Structure, Marketplace-Source-Configuration, AOT-Skill-Compilation, Compiled-Action-File-Contract, Dev-Sync-Script (already partially linked; verify final list).

### E2. Manifests at repo root

- [x] E2.1. Move `src/.claude-plugin/plugin.json` → ensure `.claude-plugin/plugin.json` at root carries the canonical hand-edited content (it already does post first-pass; verify and remove the `src/` copy).
- [x] E2.2. Move `src/.codex-plugin/plugin.json` → enrich `.codex-plugin/plugin.json` at root with agnostic + UI fields (E3 below); remove the `src/` copy.
- [x] E2.3. Delete `src/.claude-plugin/` and `src/.codex-plugin/` directories.

### E3. Codex manifest enrichment

- [x] E3.1. Add to `.codex-plugin/plugin.json`: `author` ({name, url}), `homepage`, `repository`, `license`, `keywords`.
- [x] E3.2. Add to `.codex-plugin/plugin.json` `interface`: `longDescription`, `developerName`, `websiteURL`, `defaultPrompt[]`, `brandColor`, `screenshots[]`.
- [x] E3.3. Verify the enriched manifest passes `jq -e .` and matches the schema described in `design.md` Architecture (Extension).

### E4. Compile script simplification

- [x] E4.1. Remove `cp src/.claude-plugin/plugin.json` block — manifest stays hand-edited at root.
- [x] E4.2. Remove `src/.codex-plugin/plugin.json` source path; read `.codex-plugin/plugin.json` directly at root and stamp `.version` via `jq`.
- [x] E4.3. Read version from root `.claude-plugin/plugin.json` (was `src/.claude-plugin/plugin.json`).
- [x] E4.4. Add post-stamp validation: emitted Codex manifest version must equal Claude manifest version.
- [x] E4.5. Re-run `bash -n scripts/compile-skills.sh` to confirm syntax, then full run to confirm idempotency.

### E5. Project-level alignment

- [x] E5.1. Update `.specshift/CONSTITUTION.md` Conventions / Plugin source layout: manifests live hand-edited at the repo root (not in `src/`); compile script stamps Codex version from Claude source. Bump constitution `template-version` only if `src/templates/constitution.md` (the consumer placeholder) gets edited too — it does not, so this stays at 1 and only the project's CONSTITUTION.md edits.
- [x] E5.2. Update `.specshift/WORKFLOW.md` from edited `src/templates/workflow.md` (template-version sync).
- [x] E5.3. Update root `AGENTS.md` and `CLAUDE.md` (the project's own bootstrap files) — both already exist; ensure rules align with extended scope (no behavioral change needed beyond verifying the agnostic File-Ownership entries describe `.codex-plugin/`, `src/marketplace/codex.json`, etc.).
- [x] E5.4. Update `README.md`: any `src/.claude-plugin/` or `src/.codex-plugin/` references → root-manifest references; document that fresh init generates both `AGENTS.md` (full body) and `CLAUDE.md` (one-line `@AGENTS.md` import stub).

### E6. Compile + Audit + Finalize

- [x] E6.1. Run `bash scripts/compile-skills.sh`. Confirm exit 0, zero warnings, version stamped consistently. — clean, 45/45 requirements, version 0.2.5-beta stamped across Codex manifest + marketplace.
- [x] E6.2. Verify `grep -rn "\${CLAUDE_PLUGIN_ROOT}" ./skills/specshift/` returns zero matches. — verified: 0 hits for `${CLAUDE_PLUGIN_ROOT}`, `Claude Code Web`, `.claude/worktrees`.
- [x] E6.3. Regenerate `audit.md` by re-auditing the extended scope. — extension audit appended.
- [ ] E6.4. Fix loop (skipped: no audit findings).
- [ ] E6.5. Run `specshift finalize` for changelog entry, capability-doc updates, and recompile.
- [ ] E6.6. Commit + push extension. Update PR body with extension summary.

## Third Pass — Bootstrap Symmetry Restoration

Reversal of the second-pass AGENTS-only narrowing. Fresh init generates both `AGENTS.md` (full body) and `CLAUDE.md` (one-line `@AGENTS.md` import stub). See proposal §"Scope Reversal (2026-04-27 — third pass)".

### T1. Specs and Templates

- [x] T1.1. `src/templates/workflow.md` — `## Action: init` rewritten: fresh init generates both bootstrap files; existing files never overwritten; standard-sections checks remain passive WARNING-only. Bump `template-version` 10 → 11.
- [x] T1.2. `.specshift/WORKFLOW.md` — synced from updated `src/templates/workflow.md`.
- [x] T1.3. `docs/specs/project-init.md` — Purpose updated to describe both-file generation; "Install Workflow" §1 updated; **Bootstrap Files Generation** requirement rewritten with new generation matrix and scenarios; Edge Cases updated. Bump `version` 7 → 8.
- [x] T1.4. `docs/specs/multi-target-distribution.md` — **Bootstrap Single Source of Truth Pattern** rewritten: fresh init generates both AGENTS.md and the CLAUDE.md `@AGENTS.md` import stub (the stub is a pointer, not a duplicate, so SSOT is preserved); new "Fresh init generates both bootstrap files" scenario; Edge Cases updated. Bump `version` 2 → 3.

### T2. Project-level alignment

- [x] T2.1. Update project-level `AGENTS.md` File-Ownership block (line 40) to reflect both-file generation.
- [x] T2.2. Update `.specshift/CONSTITUTION.md` Conventions ("Agent instructions") to reflect both-file generation.
- [x] T2.3. Update `README.md` (Quick Start comment, Project Structure tree, Architecture paragraph) to reflect both-file generation.
- [x] T2.4. Update `CHANGELOG.md` 0.2.5-beta "Codex Plugin Support — Hardening Pass" entry: remove the "BREAKING (init bootstrap behavior)" item; rewrite the lead-in paragraph and `src/templates/workflow.md` line; update spec version bumps (`multi-target-distribution.md` 1 → 3, `project-init.md` 6 → 8, `src/templates/workflow.md` 9 → 11).

### T3. Change-artifact updates

- [x] T3.1. Append "Scope Reversal (third pass)" section to proposal.md and remove the rejected narrowing item from "Out of Scope (Extension)".
- [x] T3.2. Update design.md stale references: Bootstrap-behavior block, spec-delta lines, decision row, risk-mitigation, migration step.
- [x] T3.3. Update tasks.md stale wordings (E1.3, E1.8, E5.4) and append this Third Pass section.

### T4. Compile + Audit + Commit

- [x] T4.1. Run `bash scripts/compile-skills.sh`. Confirm exit 0, version stamped consistently, template-version validation passes for `workflow.md` v11. — clean: 45/45 requirements, 0 warnings, version 0.2.5-beta stamped consistently, template-version validation passed.
- [x] T4.2. Read-through verification: spec text + workflow.md init instruction match the both-file fresh-init behavior; re-init scenarios (AGENTS-exists, CLAUDE-exists, both-exist) leave existing files untouched with passive WARNING-only standard-sections checks.
- [x] T4.3. Regenerate `audit.md` with the third-pass scope. Verdict: **PASS**, 0 CRITICAL, 0 WARNING, 1 SUGGESTION (live consumer install verification deferred — carried over from first/second pass).
- [x] T4.4. Commit on `codex-plugin-support` branch with conventional message and push so PR #45 picks up the third-pass commit. — `20f9024` `bootstrap symmetry restoration` + `67d1769` `remove legacy .claude/.claude-plugin/plugin.json` + `e1a2ce3` `regenerate capability docs` pushed.

## Fourth Pass — Codex Marketplace Consolidation

The second pass moved plugin manifests from `src/` to the repo root, but the Codex marketplace template at `src/marketplace/codex.json` was missed. Fourth pass: delete the template, make `.agents/plugins/marketplace.json` the hand-edited source of truth at the repo root, and have the compile script `jq`-stamp version in place (analogous to Codex manifest handling). See `proposal.md` §"Codex Marketplace Consolidation (2026-04-27 — fourth pass)".

### M1. Compile script + source deletion

- [x] M1.1. `scripts/compile-skills.sh` — drop `CODEX_MARKETPLACE_SRC` and `CODEX_MARKETPLACE_DIR` vars; remove the `rm -rf "$CODEX_MARKETPLACE_DIR"` cleanup line; replace the "Emit Codex marketplace entry" block with an in-place `jq` version-stamp on `.agents/plugins/marketplace.json` (mirror of the existing Codex-manifest stamping); update header comment + summary line.
- [x] M1.2. `git rm src/marketplace/codex.json`. The empty `src/marketplace/` directory is auto-removed by git.

### M2. Specs and capability docs

- [x] M2.1. `docs/specs/release-workflow.md` — §"Source and Release Directory Structure" (Source dir Codex template line removed, manifests/marketplace at root grouped, Codex marketplace entry described as hand-edited); §"AOT Skill Compilation" (steps merged: stamp manifest + marketplace combined into one step, "Emit Codex marketplace" step removed); scenario "Source directory contains editable files" tightened (`src/marketplace/` excluded). Bump `version` 4 → 5.
- [x] M2.2. `docs/specs/multi-target-distribution.md` — §"Codex Marketplace Entry" rewritten to describe hand-edited-at-root + `jq` version-stamp; "Codex marketplace file generated" scenario rewritten as "Codex marketplace lives at repository root". Bump `version` 3 → 4.
- [x] M2.3. `docs/capabilities/multi-target-distribution.md` § Compilation prose updated.
- [x] M2.4. `docs/capabilities/release-workflow.md` § Plugin Source and Manifest Layout + § Version Synchronization prose updated.

### M3. Project-level alignment

- [x] M3.1. `AGENTS.md` File-Ownership block — remove `src/marketplace/codex.json` from `src/` list; consolidate `.agents/plugins/marketplace.json` into the hand-edited per-target manifests/marketplaces line; remove the now-obsolete generated-Codex-marketplace bullet.
- [x] M3.2. `.specshift/CONSTITUTION.md` Architecture Rules + Conventions Plugin source layout — align with hand-edited-at-root for both manifests and marketplaces.
- [x] M3.3. `CHANGELOG.md` 0.2.5-beta — first-pass "Added" line for the Codex marketplace + Hardening Pass BREAKING entry both reflect hand-edited-at-root + spec version-bump notations.

### M4. Compile + Audit + Commit

- [x] M4.1. Run `bash scripts/compile-skills.sh`. Confirm exit 0, version 0.2.5-beta stamped on Codex manifest AND `.agents/plugins/marketplace.json`, no template-version validation failure. — clean: 45/45 requirements, 0 warnings, both Codex outputs already at 0.2.5-beta (no-op stamps), cross-check passed.
- [x] M4.2. Read-through verification: `.agents/plugins/marketplace.json` content unchanged (name, owner, metadata, plugins[].name/source/description identical to pre-consolidation state; version `0.2.5-beta` preserved).
- [x] M4.3. Append Fourth-Pass audit section to `audit.md`. Verdict: **PASS**, 0 CRITICAL, 0 WARNING, 0 SUGGESTION.
- [ ] M4.4. Commit on `codex-plugin-support` and push so PR #45 picks up the fourth-pass commit.
