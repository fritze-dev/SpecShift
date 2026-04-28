# Implementation Tasks: Remove Worktrees from SpecShift Workflow

## 1. Foundation

- [ ] 1.1. Confirm working tree is clean and on branch `claude/remove-worktrees-specshift-SACUg`.
- [ ] 1.2. Re-grep `git grep -in "worktree" -- src/ .specshift/WORKFLOW.md AGENTS.md .specshift/templates/changes/proposal.md` to baseline the hits to be removed.

## 2. Implementation

### 2.1. Skill source

- [ ] 2.1.1. `src/skills/specshift/SKILL.md` — remove `worktree` from the documented WORKFLOW.md frontmatter field list under "Load Configuration".
- [ ] 2.1.2. `src/skills/specshift/SKILL.md` — drop the worktree-convention fallback (current step 3) from the "Change Context Detection" sequence so it reads: (1) proposal frontmatter `branch:` lookup, (2) directory-listing fallback prompt. Update wording in the dispatch routing for `apply`/`finalize`/`review` if it references the removed step.

### 2.2. Action manifests (link cleanup)

These files are link manifests consumed by `bash scripts/compile-skills.sh`. Remove links that point at requirements deleted from the specs in the prior commit (`specshift(...): specs`). Do NOT add new requirement links unless the underlying spec actually contains them.

- [ ] 2.2.1. [P] `src/actions/propose.md` — remove the `Create Worktree-Based Workspace` and `Lazy Worktree Cleanup at Change Creation` link lines.
- [ ] 2.2.2. [P] `src/actions/finalize.md` — remove any link line pointing at `Post-Merge Worktree Cleanup` (or similar) in `change-workspace.md`.
- [ ] 2.2.3. [P] `src/actions/review.md` — remove any link line pointing at `Post-Merge Worktree Cleanup`.
- [ ] 2.2.4. [P] `src/actions/init.md` — remove the link line pointing at `GitHub Merge Strategy Configuration` (deleted from `project-init.md`); leave the rest of the manifest intact.

### 2.3. WORKFLOW.md template + project instance

- [ ] 2.3.1. `src/templates/workflow.md` — delete the commented-out `worktree:` block (lines 11-15 in the current file) and bump `template-version` (current `9` → `10`) per CONSTITUTION's "Template-version discipline".
- [ ] 2.3.2. `src/templates/workflow.md` — sanity-check that the `## Action: propose` instruction body (and any other action body) no longer mentions worktree ("Lazy worktree cleanup", "with worktree if enabled", etc.). Trim those sentences if present.
- [ ] 2.3.3. `.specshift/WORKFLOW.md` — delete the live `worktree:` block (`enabled: true`, `path_pattern: ...`, `auto_cleanup: true`, `stale_days: 14`).
- [ ] 2.3.4. `.specshift/WORKFLOW.md` — sanity-check the same body-section worktree mentions are gone.

### 2.4. Project docs and templates

- [ ] 2.4.1. `AGENTS.md` — remove the `worktree.enabled: true` clause from the `**.specshift/**` File Ownership entry. Adjust surrounding sentence so the remaining intentional override (`review.request_review: copilot`) still reads correctly.
- [ ] 2.4.2. `.specshift/templates/changes/proposal.md` — remove the `worktree:` line from the documented proposal-tracking frontmatter.

### 2.5. Verify removal scope

- [ ] 2.5.1. `git grep -in "worktree" -- src/` SHALL return 0 hits.
- [ ] 2.5.2. `git grep -in "worktree" -- .specshift/WORKFLOW.md AGENTS.md .specshift/templates/changes/proposal.md` SHALL return 0 hits.
- [ ] 2.5.3. `git grep -in "worktree" -- docs/specs/` SHALL return only the legacy/read-only doc lines in `change-workspace.md` (3 hits, intentional).
- [ ] 2.5.4. Historical change directories under `.specshift/changes/2026-03-30-worktree-*` and similar are NOT modified (verified via `git status`).

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check — verify each Success Metric from `design.md`:
  - `git grep -i worktree -- src/ .specshift/WORKFLOW.md AGENTS.md .specshift/templates/changes/proposal.md` → 0 hits.
  - `git grep -i worktree -- docs/specs/` → only the 3 intentional legacy-doc hits in `change-workspace.md`.
  - All 5 affected specs ≥3 requirements (counted: 4 / 11 / 13 / 7 / 5).
  - Existing `proposal.md` files in `.specshift/changes/*/` keep their legacy `worktree:` frontmatter unchanged.
- [ ] 3.2. Auto-Verify — generate `audit.md` using the audit template.
- [ ] 3.3. User Testing — **stop here.** Ask the user for manual approval (`auto_approve: true` in WORKFLOW.md skips this gate when audit verdict is PASS).
- [ ] 3.4. Fix Loop — classify each correction (Tweak / Design Pivot / Scope Change), update stale artifacts before re-implementing.
- [ ] 3.5. Final Verify — regenerate `audit.md` after fixes. Skip if 3.4 not entered.
- [ ] 3.6. Approval — finish only on explicit "Approved".

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (changelog + docs + version bump + recompile `skills/specshift/`).
- [ ] 4.2. Bump `src/VERSION` per CONSTITUTION (patch increment) — handled by finalize.
- [ ] 4.3. Commit and push to remote.
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and `Closes #47` reference.
- [ ] 4.5. Reply to and resolve all PR review comments (fixed / declined with reason / not applicable).

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`) — applies because this change modifies files under `src/` and `skills/specshift/`.
