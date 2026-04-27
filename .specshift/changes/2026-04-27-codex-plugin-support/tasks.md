# Implementation Tasks: Codex Plugin Support (Multi-Target Distribution)

## 1. Foundation

- [ ] 1.1. Create `src/.codex-plugin/plugin.json` with Codex schema (`name`, `version: "0.0.0"` placeholder, `description`, `skills: "./skills/"`, `interface` block with `displayName: "SpecShift"`, `shortDescription`, `category: "Productivity"`, `capabilities: ["Read"]`).
- [ ] 1.2. Create `src/marketplace/codex.json` as the Codex marketplace template (JSON file referencing `./.codex-plugin/plugin.json` with placeholder version).
- [ ] 1.3. Create `src/templates/agents.md` with frontmatter (`id: agents`, `template-version: 1`, `description: AGENTS.md bootstrap (full body)`, `generates: AGENTS.md`, `requires: []`, `instruction:` carried over from claude.md). Body: copy the full body of current `src/templates/claude.md` (Workflow / Planning / Knowledge Management / File Ownership sections including the workflow-routing rule from commit 3d3f89f).

## 2. Implementation

### 2.1. Reshape claude.md to import stub
- [ ] 2.1.1. Replace `src/templates/claude.md` body with a single line: `@AGENTS.md`. Bump `template-version` from 4 to 5. Update `description` frontmatter to "CLAUDE.md import stub for Claude Code (delegates to AGENTS.md)". Keep `generates: CLAUDE.md`.

### 2.2. Update workflow.md init instruction
- [ ] 2.2.1. Edit `src/templates/workflow.md` `## Action: init` instruction text to reference both `AGENTS.md` and `CLAUDE.md` generation. Bump `template-version` from 8 to 9.
- [ ] 2.2.2. Sync changes into `.specshift/WORKFLOW.md` (preserve project-specific overrides: `worktree.enabled: true`, `request_review: copilot`).

### 2.3. Migrate compile-skills.sh to multi-target output
- [ ] 2.3.1. Change `PLUGIN_ROOT=".claude"` to `PLUGIN_ROOT="."`. Verify `SKILL_DIR="$PLUGIN_ROOT/skills/specshift"` resolves to `./skills/specshift`.
- [ ] 2.3.2. Update the cleanup block to remove both the new path (`rm -rf $SKILL_DIR`) and the legacy path (`rm -rf .claude/skills`) to ensure stale artifacts are gone.
- [ ] 2.3.3. Update the manifest copy block: copy `src/.claude-plugin/plugin.json` → `.claude-plugin/plugin.json` at repo root.
- [ ] 2.3.4. Add a second manifest copy block: copy `src/.codex-plugin/plugin.json` → `.codex-plugin/plugin.json` at repo root, then stamp `version` from the Claude source manifest.
- [ ] 2.3.5. Add a marketplace copy block: copy `src/marketplace/codex.json` → `.agents/plugins/marketplace.json`, stamping the plugin version.
- [ ] 2.3.6. Update the plugin-version stamping line to target `./skills/specshift/templates/workflow.md` (was `.claude/skills/specshift/templates/workflow.md`).
- [ ] 2.3.7. Verify the template-version enforcement block still works (compares against `main`).

### 2.4. Update marketplace source path
- [ ] 2.4.1. Edit `.claude-plugin/marketplace.json` to set `source: "./"` (was `./.claude`).

### 2.5. Update CONSTITUTION
- [ ] 2.5.1. Edit `.specshift/CONSTITUTION.md` Architecture Rules: change `.claude/skills/specshift/` reference to `./skills/specshift/`.
- [ ] 2.5.2. Edit `.specshift/CONSTITUTION.md` Conventions / Plugin source layout: change `source: "./.claude"` to `source: "./"`; mention both manifest source dirs (`src/.claude-plugin/`, `src/.codex-plugin/`).
- [ ] 2.5.3. Bump `.specshift/CONSTITUTION.md` template-version (1 → 2) only if compile-script enforcement requires it; constitution.md is in `src/templates/` and follows template-version discipline. Update the source `src/templates/constitution.md` if the rule edits also apply to consumer constitution skeleton (likely not — the consumer skeleton is a placeholder). Verify which file needs the bump.

### 2.6. Update File Ownership references in agents.md
- [ ] 2.6.1. In the freshly created `src/templates/agents.md`, update the `## File Ownership` section so that `.claude/skills/specshift/` is replaced with `./skills/specshift/` (matching the new release directory).

### 2.7. Update README
- [ ] 2.7.1. In `README.md`, restructure the install section into two subsections at the same heading level: "Claude Code" (existing `claude plugin marketplace add fritze-dev/specshift` flow) and "Codex" (new `codex /plugins` discovery + the marketplace path).
- [ ] 2.7.2. Update any references in README to `.claude/skills/specshift/` to point to `./skills/specshift/`.

### 2.8. First compile + repo-level cleanup
- [ ] 2.8.1. Run `bash scripts/compile-skills.sh`. Confirm exit 0, zero warnings.
- [ ] 2.8.2. Verify the output: `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`, `./skills/specshift/SKILL.md`, `./skills/specshift/templates/agents.md`, `./skills/specshift/templates/claude.md` all exist.
- [ ] 2.8.3. Verify the legacy directory `.claude/skills/` is gone.
- [ ] 2.8.4. Stage the deletion of the old `.claude/skills/` tree and the addition of the new `./skills/`, both manifest dirs, and `.agents/`.

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
  - [ ] `bash scripts/compile-skills.sh` exits 0 with no warnings.
  - [ ] `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `skills/specshift/SKILL.md`, `.agents/plugins/marketplace.json` all exist post-compile, all stamped with the same version string.
  - [ ] `skills/specshift/templates/agents.md` and `skills/specshift/templates/claude.md` both exist post-compile.
  - [ ] `.claude/skills/` legacy path does NOT exist post-compile.
  - [ ] `claude plugin marketplace update specshift && claude plugin update specshift@specshift` resolves without manual intervention (verified locally if a Claude Code install is available; otherwise mark verified-by-config-inspection).
  - [ ] In a fresh consumer test project, `specshift init` produces `AGENTS.md` (full body, all four standard sections) and `CLAUDE.md` (≤ 5 lines, contains `@AGENTS.md`).
  - [ ] `grep -c "@AGENTS.md" CLAUDE.md` returns `1` in the generated CLAUDE.md.
  - [ ] `wc -l < CLAUDE.md` returns ≤ 10 in the generated CLAUDE.md.
- [ ] 3.2. Auto-Verify: generate audit.md using the audit template.
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: Classify each correction before fixing. Update all stale artifacts before re-implementing. Specs must match code before proceeding.
  - **Tweak**: wrong value/typo → fix in place
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks + re-implement
  - **Scope Change**: wrong requirements → update specs + design + re-implement fully
- [ ] 3.5. Final Verify: regenerate audit.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable
- [ ] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`) — applies when change modifies files under `src/` or `./skills/`
