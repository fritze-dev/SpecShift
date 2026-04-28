# Implementation Tasks: Remove Worktrees from SpecShift Workflow

## 1. Foundation

- [x] 1.1. Confirm working tree is clean and on branch `claude/remove-worktrees-specshift-SACUg`.
- [x] 1.2. Re-grep `git grep -in "worktree" -- src/ .specshift/WORKFLOW.md AGENTS.md .specshift/templates/changes/proposal.md` to baseline the hits to be removed.

## 2. Implementation

### 2.1. Skill source

- [x] 2.1.1. `src/skills/specshift/SKILL.md` — remove `worktree` from the documented WORKFLOW.md frontmatter field list under "Load Configuration".
- [x] 2.1.2. `src/skills/specshift/SKILL.md` — drop the worktree-convention fallback (current step 3) from the "Change Context Detection" sequence so it reads: (1) proposal frontmatter `branch:` lookup, (2) directory-listing fallback prompt. Update wording in the dispatch routing for `apply`/`finalize`/`review` if it references the removed step.

### 2.2. Action manifests (link cleanup)

These files are link manifests consumed by `bash scripts/compile-skills.sh`. Remove links that point at requirements deleted from the specs in the prior commit (`specshift(...): specs`). Do NOT add new requirement links unless the underlying spec actually contains them.

- [x] 2.2.1. [P] `src/actions/propose.md` — remove the `Create Worktree-Based Workspace` and `Lazy Worktree Cleanup at Change Creation` link lines.
- [x] 2.2.2. [P] `src/actions/finalize.md` — remove the `Post-Merge Worktree Cleanup` link line.
- [x] 2.2.3. [P] `src/actions/review.md` — remove the `Post-Merge Worktree Cleanup` link line.
- [x] 2.2.4. [P] `src/actions/init.md` — verified no worktree-related links present (the removed `GitHub Merge Strategy Configuration` requirement was not linked from this manifest). No edit needed.

### 2.3. WORKFLOW.md template + project instance

- [x] 2.3.1. `src/templates/workflow.md` — delete the commented-out `worktree:` block (lines 11-15 in the current file) and bump `template-version` (current `9` → `10`) per CONSTITUTION's "Template-version discipline".
- [x] 2.3.2. `src/templates/workflow.md` — `## Action: propose` and `## Action: review` instruction bodies trimmed (Lazy worktree cleanup paragraph dropped, "with worktree if enabled" removed, post-merge cleanup line replaced with "delete the local and remote feature branch").
- [x] 2.3.3. `.specshift/WORKFLOW.md` — delete the live `worktree:` block (`enabled: true`, `path_pattern: ...`, `auto_cleanup: true`, `stale_days: 14`).
- [x] 2.3.4. `.specshift/WORKFLOW.md` — body sections trimmed in lockstep with the source template.

### 2.4. Project docs and templates

- [x] 2.4.1. `AGENTS.md` — remove the `worktree.enabled: true` clause from the `**.specshift/**` File Ownership entry; the surrounding sentence still reads correctly with the remaining `review.request_review: copilot` override.
- [x] 2.4.2. `.specshift/templates/changes/proposal.md` — remove the `worktree:` line from the documented proposal-tracking frontmatter.
- [x] 2.4.3. **Tweak (added during apply):** `src/templates/changes/proposal.md` — same edit as 2.4.2 in the plugin source (project instance is synced FROM `src/templates/`); bumped `template-version` 2 → 3 per CONSTITUTION's "Template-version discipline".
- [x] 2.4.4. **Tweak (added during apply):** `docs/specs/multi-target-distribution.md` — removed the now-orphan "Worktree-path references" sub-rule (point 3 of the "Agnostic Skill Body" requirement) which referenced `worktree.path_pattern`; renumbered subsequent points; bumped spec `version` 4 → 5.

### 2.5. Verify removal scope

- [x] 2.5.1. `git grep -in "worktree" -- src/` returns 0 hits.
- [x] 2.5.2. `git grep -in "worktree" -- .specshift/WORKFLOW.md AGENTS.md .specshift/templates/changes/proposal.md` returns 0 hits.
- [x] 2.5.3. `git grep -in "worktree" -- docs/specs/` returns only the 3 intentional legacy/read-only doc lines in `change-workspace.md`.
- [x] 2.5.4. Historical change directories under `.specshift/changes/2026-03-30-worktree-*` and similar are NOT modified (verified via `git status`).

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check — every Success Metric from `design.md` verified PASS:
  - `git grep -i worktree -- src/ .specshift/WORKFLOW.md AGENTS.md .specshift/templates/changes/proposal.md` → 0 hits ✅
  - `git grep -i worktree -- docs/specs/` → 3 intentional legacy-doc hits in `change-workspace.md` ✅
  - All 5 affected specs ≥3 requirements (4 / 11 / 13 / 7 / 5) ✅
  - Existing `proposal.md` files in `.specshift/changes/*/` keep their legacy `worktree:` frontmatter unchanged (untouched) ✅
- [x] 3.2. Auto-Verify — `audit.md` generated.
- [x] 3.3. User Testing — `auto_approve: true` and audit verdict PASS → gate skipped per WORKFLOW.md `## Action: apply` instruction.
- [x] 3.4. Fix Loop — entered for two **Tweak**-classified findings during initial verification (see 2.4.3 and 2.4.4). No design pivot or scope change. Affected artifacts (tasks.md) updated in lockstep.
- [x] 3.5. Final Verify — `audit.md` regenerated after the Tweak fixes; verdict remains PASS.
- [x] 3.6. Approval — `auto_approve: true` and audit verdict PASS → gate skipped per WORKFLOW.md `## Action: apply` instruction.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Run `specshift finalize` (changelog + docs + version bump + recompile `skills/specshift/`).
- [x] 4.2. Bump `src/VERSION` per CONSTITUTION (patch increment) — handled by finalize.
- [x] 4.3. Commit and push to remote.
- [x] 4.4. Update PR: mark ready for review, update body with change summary and `Closes #47` reference.
- [x] 4.5. Reply to and resolve all PR review comments (fixed / declined with reason / not applicable).

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`) — applies because this change modifies files under `src/` and `skills/specshift/`.
