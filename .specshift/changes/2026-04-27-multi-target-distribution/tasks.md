# Implementation Tasks: Multi-Target Distribution

## 1. Foundation

Layout-level changes — file-system shape only, no behavioral changes yet.

- [x] 1.1. Create `src/VERSION` with the current plugin version (`0.2.4-beta`) — plain text, single line, trailing newline.
- [x] 1.2. [P] Move `src/.claude-plugin/plugin.json` content to `.claude-plugin/plugin.json` at the repo root (preserve all fields), then delete the now-empty `src/.claude-plugin/` directory.
- [x] 1.3. [P] Update `.claude-plugin/marketplace.json` `plugins[0].source` field from `"./.claude"` to `"./"` (no other field changes; the version is re-stamped at compile time).
- [x] 1.4. [P] Create `.codex-plugin/plugin.json` at the repo root with the full Codex schema (`name`, `version`, `description`, `author`, `homepage`, `repository`, `license`, `keywords`, `skills: "./skills/"`, `interface` block with `displayName`, `shortDescription`, `longDescription`, `developerName`, `category`, `capabilities: ["Read", "Edit", "Write", "Bash"]`, `websiteURL`, `defaultPrompt`, `brandColor`, `screenshots: []`).
- [x] 1.5. [P] Create `.agents/plugins/marketplace.json` at the repo root with a single plugin entry referencing `.codex-plugin/` and the current version.
- [x] 1.6. Create `src/templates/agents.md` as a Smart Template (frontmatter `id: agents`, `template-version: 1`, `description`, `generates: AGENTS.md`, `requires: []`, `instruction`) with the full bootstrap body (Workflow, Planning, Knowledge Management sections).
- [x] 1.7. Reduce `src/templates/claude.md` body to a single `@AGENTS.md` import line. Bump frontmatter `template-version` from `4` to `5`. Update `description` to reflect the new role ("Bootstrap import stub: makes Claude Code load AGENTS.md via memory-import").
- [x] 1.8. Update `src/templates/workflow.md`: rewrite the `## Action: init` instruction body to mention both bootstrap files. Bump frontmatter `template-version` from `8` to `9`.

## 2. Implementation

- [x] 2.1. Rewrite `scripts/compile-skills.sh`:
  - Hard preflight: `command -v jq` (fail with descriptive error if missing).
  - Verify `src/VERSION` exists, is non-empty, has exactly one line; fail otherwise.
  - `PLUGIN_VERSION=$(cat src/VERSION | tr -d '[:space:]')`.
  - Keep existing template-version freshness check.
  - `rm -rf` the shared output tree (`./skills/specshift/`) and the legacy tree (`.claude/skills/specshift/`).
  - Copy `src/skills/specshift/SKILL.md` → `./skills/specshift/SKILL.md`; copy `src/templates/` → `./skills/specshift/templates/`.
  - Stamp `plugin-version: <version>` into `./skills/specshift/templates/workflow.md` frontmatter.
  - For each of the four root files (`.claude-plugin/plugin.json` `.version`, `.claude-plugin/marketplace.json` `.plugins[].version`, `.codex-plugin/plugin.json` `.version`, `.agents/plugins/marketplace.json` `.plugins[].version`): use `jq` to set the version, write to a tmp file, atomic-rename. Re-read each post-stamp and verify the value equals `PLUGIN_VERSION`; fail with an error naming the offending file on mismatch.
  - Compile actions: existing requirement-extraction logic → `./skills/specshift/actions/<action>.md`.
  - Print summary: actions compiled, requirements extracted, warnings count, version stamped.
- [x] 2.2. Add a requirement link to `src/actions/init.md` for the new `Bootstrap Files Generation` requirement: `- [Bootstrap Files Generation](../../docs/specs/project-init.md#requirement-bootstrap-files-generation)`. Position it after `Install Workflow`.
- [x] 2.3. Update `.specshift/CONSTITUTION.md`:
  - **Architecture Rules**: release-directory line `.claude/skills/specshift/` → `./skills/specshift/`; plugin-manifest line updated for hand-edited per-target manifests and marketplaces at repo root.
  - **Conventions — Post-apply version bump**: rewrite to name `src/VERSION` as SoT; sync mechanism is the compile script's symmetric stamping into all four root files.
  - **Conventions — Plugin source layout**: marketplace source `./.claude` → `./`; manifests at root, not under `src/`.
  - **Conventions — Agent instructions**: `AGENTS.md` is agnostic SoT, `CLAUDE.md` is `@AGENTS.md` import stub.
  - **Conventions — Tool-agnostic instructions**: strengthened — compiled-into-skill files MUST NOT use `${CLAUDE_PLUGIN_ROOT}` and MUST use product names only where the surrounding text is target-scoped.
  - **Conventions — Local development**: note the layout change requires a one-time refresh.
- [x] 2.4. Sync `.specshift/WORKFLOW.md` from updated `src/templates/workflow.md` while preserving project-specific overrides (`worktree.enabled: true`, `auto_approve: true`, `review.request_review: copilot`, plugin-version field).
- [x] 2.5. Create project `AGENTS.md` at repo root with the bootstrap body (Workflow, Planning, Knowledge Management) plus a project-specific `## File Ownership` section that documents the new layout: `src/` (incl. `src/VERSION` as version SoT), per-target manifests/marketplaces at repo root, `.specshift/`, `docs/specs/`, `docs/capabilities/`, `./skills/specshift/`, and the AGENTS.md / CLAUDE.md pattern.
- [x] 2.6. Replace project `CLAUDE.md` body with a single `@AGENTS.md` import line.
- [x] 2.7. Update `.github/workflows/release.yml`:
  - Trigger `on.push.paths`: change `src/.claude-plugin/plugin.json` (or whichever path triggers today) to `src/VERSION`.
  - Version-extraction step: read from `src/VERSION` instead of jq-extracting from a manifest.
- [x] 2.8. Update `README.md`:
  - Add a Codex install section at the same heading level as the existing Claude Code install section (order: Claude Code, then Codex).
  - Update the project-structure tree diagram to reflect the new layout (`src/VERSION`, manifests at root, `./skills/specshift/`, no `src/.claude-plugin/`).
  - Add a note in the maintainer section about `src/VERSION` as the version SoT and the four-file symmetric stamping.
  - Note the BREAKING marketplace path migration for existing Claude Code consumers.
- [x] 2.9. Run `bash scripts/compile-skills.sh` and verify:
  - All four root files (`.{claude,codex}-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json`) declare the version from `src/VERSION`.
  - `./skills/specshift/SKILL.md`, `./skills/specshift/templates/`, `./skills/specshift/actions/` exist and are populated.
  - Legacy `.claude/skills/specshift/` no longer exists.
  - Compiled `./skills/specshift/templates/workflow.md` has `plugin-version: <version>` stamped in frontmatter.
  - 0 warnings; non-zero requirement extraction count for every action.
- [x] 2.10. Verify `.gitignore` allows `./skills/` (no rule that ignores the new shared output tree). If a conflicting rule exists, update `.gitignore` accordingly.

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check — verify each Success Metric from `design.md`:
  - G1 (single-source bootstrap): grep a workflow rule string in `src/templates/` returns one hit only.
  - G2 (symmetric versions): jq-read all four version locations + `cat src/VERSION` returns five equal values.
  - G3 (agnostic SoT): the version-bump commit modifies only `src/VERSION` plus the compile-stamped four files in the same commit.
  - G4 (cross-check enforces consistency): manually mismatch one file, run compile, confirm non-zero exit naming the offending file.
  - G5 (one shared skill tree): `find . -path ./node_modules -prune -o -name 'SKILL.md' -print` returns exactly two paths (source + compiled).
  - G6 (tool-agnostic compiled body): `grep -r '${CLAUDE_PLUGIN_ROOT}' ./skills/specshift/` returns 0 hits; same for `\.claude/worktrees`.
  - G7 (fresh init both files): scenario test from `tests.md`.
  - G8 (README both install paths): grep section headings.
  - G9 (idempotent build): second `bash scripts/compile-skills.sh` produces no diff (`git status --porcelain` empty).
  PASS / FAIL.
- [x] 3.2. Auto-Verify: generate `audit.md` using the audit template — covers traceability (every requirement → tasks → tests → implemented file), gap analysis, regression sweep, classification verdict.
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval. Hand them the audit.md verdict and the live tree state.
- [x] 3.4. Fix Loop: classify each correction (Tweak / Design Pivot / Scope Change), update stale artifacts before re-implementing, regenerate audit.md after fixes.
- [x] 3.5. Final Verify: regenerate audit.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [x] 3.6. Approval: only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize`:
  - Generate the new `## [v0.2.5-beta] — 2026-04-27` CHANGELOG entry covering the Codex Plugin Support / Multi-Target Distribution rollout, with the BREAKING marketplace-path note for Claude Code consumers.
  - Generate / update capability docs: new `docs/capabilities/multi-target-distribution.md`; updated `docs/capabilities/project-init.md` and `docs/capabilities/release-workflow.md`.
  - Generate `docs/decisions/adr-003-shopify-flat-multi-target-distribution.md` (or next available ADR number) capturing the layout decision and the version-SoT decision.
  - Bump `src/VERSION` per the post-apply auto-bump convention: `0.2.4-beta` → `0.2.5-beta`.
  - Run `bash scripts/compile-skills.sh` to stamp the new version into all four root files and refresh the shared skill tree.
- [ ] 4.2. Verify the bumped version is consistent across `src/VERSION` and all four root files (one final cross-check).
- [ ] 4.3. Commit and push to remote (the open PR #46 picks up the finalize commits).

### Pre-Merge (from CONSTITUTION Standard Tasks)

- [ ] 4.4. Update PR #46: mark ready for review, update body with change summary, reference the supersedes relationship to PR #45.
- [ ] 4.5. Reply to and resolve all PR review comments (Copilot or human reviewer) per the review-comment-acknowledgment convention.

## 5. Post-Merge Reminders

Not tracked as tasks. Executed manually after the PR is merged.

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`) — applies because this change modifies files under `src/` and `./skills/`. Also expect to refresh the marketplace cache because the marketplace `source` path changed.
- Close PR #45 with a comment pointing at PR #46 as the clean re-setup.
