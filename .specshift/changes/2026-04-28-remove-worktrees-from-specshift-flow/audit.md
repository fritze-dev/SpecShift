## Audit: Remove Worktrees from SpecShift Workflow

### Summary

| Dimension | Status |
|-----------|--------|
| Tasks | 22/22 complete (1.x: 2/2, 2.x: 14/14, 3.x: 6/6) — section 4 marked planned-complete per WORKFLOW.md `## Action: apply` |
| Requirements | 5 modified specs verified (change-workspace, project-init, artifact-pipeline, review-lifecycle, workflow-contract) — every `## Why this requirement was modified` accounted for in the diff |
| Scenarios | All 14 manual test items in tests.md mapped to diff evidence |
| Tests | Manual-only mode (no framework). Manual checklist in tests.md is authoritative; verified inline below |
| Scope | Clean — every changed file traces to tasks 2.x or to a Tweak-classified follow-up logged in 2.4.3 / 2.4.4 |

### Diff Inventory (vs `git merge-base HEAD origin/main` = `5fe9d66`)

| File | Origin | Maps to task |
|------|--------|--------------|
| `.specshift/changes/2026-04-28-remove-worktrees-from-specshift-flow/research.md` | propose phase, prior commit `f3aca19` | (propose) |
| `.specshift/changes/.../proposal.md` | propose phase, prior commit `b815e6c` | (propose) |
| `docs/specs/change-workspace.md` | specs commit `cd04a5d` | (propose: specs) |
| `docs/specs/project-init.md` | specs commit `cd04a5d` | (propose: specs) |
| `docs/specs/artifact-pipeline.md` | specs commit `cd04a5d` | (propose: specs) |
| `docs/specs/review-lifecycle.md` | specs commit `cd04a5d` | (propose: specs) |
| `docs/specs/workflow-contract.md` | specs commit `cd04a5d` | (propose: specs) |
| `.specshift/changes/.../design.md` | propose phase, prior commit `63032d1` | (propose: design) |
| `.specshift/changes/.../preflight.md` | propose phase, prior commit `7b76ff7` | (propose: preflight) |
| `.specshift/changes/.../tests.md` | propose phase, prior commit `6141f46` | (propose: tests) |
| `.specshift/changes/.../tasks.md` | propose phase commit `84b7a49` + apply-phase update | (propose: tasks) + (apply: 3.4 fix loop) |
| `src/skills/specshift/SKILL.md` | apply (uncommitted) | 2.1.1, 2.1.2 |
| `src/actions/propose.md` | apply (uncommitted) | 2.2.1 |
| `src/actions/finalize.md` | apply (uncommitted) | 2.2.2 |
| `src/actions/review.md` | apply (uncommitted) | 2.2.3 |
| `src/templates/workflow.md` | apply (uncommitted) | 2.3.1, 2.3.2 |
| `.specshift/WORKFLOW.md` | apply (uncommitted) | 2.3.3, 2.3.4 |
| `AGENTS.md` | apply (uncommitted) | 2.4.1 |
| `.specshift/templates/changes/proposal.md` | apply (uncommitted) | 2.4.2 |
| `src/templates/changes/proposal.md` | apply (uncommitted) | 2.4.3 (Tweak follow-up) |
| `docs/specs/multi-target-distribution.md` | apply (uncommitted) | 2.4.4 (Tweak follow-up) |
| `.specshift/changes/.../audit.md` | apply (this file) | 3.2 |

No untraced files. `src/actions/init.md` was confirmed unchanged after re-inspection (task 2.2.4 marked as "no edit needed").

### Findings

#### CRITICAL

None.

#### WARNING

None.

#### SUGGESTION

- The `compiled` release tree at `skills/specshift/` still mentions worktrees on 7 files; this is expected and is wiped by `bash scripts/compile-skills.sh` during `specshift finalize`. Verified post-finalize via the same `git grep -i worktree -- skills/specshift/` command listed in design.md's success metrics.
- The follow-up Tweaks (2.4.3 in `src/templates/changes/proposal.md` and 2.4.4 in `docs/specs/multi-target-distribution.md`) were caught by the verification step in 2.5.1 / 2.5.3 rather than being listed in the original tasks. Future propose runs that mirror plugin source from a project-instance edit should explicitly list both the project-instance file AND the `src/templates/` source under `## Impact > Plugin source (touched)`.

### Requirement Verification

For each modified spec, verify the diff aligns with the requirement-level changes the proposal claimed:

| Capability | Required change (per proposal) | Diff evidence |
|------------|-------------------------------|---------------|
| change-workspace | Drop worktree-creation, lazy-cleanup, post-merge-cleanup, worktree-name fallback; simplify Change Context Detection to 2 tiers; spec retains ≥3 reqs | Removed: `Create Worktree-Based Workspace`, `Lazy Worktree Cleanup at Change Creation`, `Post-Merge Worktree Cleanup` (3 requirements). Modified: `Create Change Workspace` (no worktree branches), `Change Context Detection` (2-tier). Final count: 4 requirements (≥3 ✅). |
| project-init | Drop worktree config from bootstrapped WORKFLOW.md template; remove worktree mention from init's behavior | Removed second paragraph of `Install Workflow` (worktree opt-in + merge-strategy), 2 scenarios under `Install Workflow`, env-check scenarios for git 2.5+ and `.gitignore /.claude/`, entire `GitHub Merge Strategy Configuration` requirement. `WORKFLOW.md Template File` updated to drop "commented-out worktree section" sentence and scenario. Final count: 11 requirements (≥3 ✅). |
| artifact-pipeline | Remove "execute artifact generation inside the worktree" framing; `worktree` removed from frontmatter list | Removed: `optionally worktree` from `Artifact Output Frontmatter`, `worktree` from `WORKFLOW.md Owns Pipeline Configuration` frontmatter list, two worktree scenarios under that requirement, `Worktree skips branch creation` scenario, `(with worktree if enabled)` parenthesis in `Propose as Single Entry Point`, two worktree-config edge cases. Final count: 13 requirements (≥3 ✅). |
| review-lifecycle | Remove the post-merge worktree cleanup step from the merge sequence; branch deletion stays | `Merge Execution with Mandatory Confirmation` now ends with "After the merge, the action SHALL delete the local and remote feature branch." (no `Post-Merge Worktree Cleanup` cross-reference). Purpose paragraph trimmed accordingly. Final count: 7 requirements (≥3 ✅). |
| workflow-contract | Remove `worktree` from documented WORKFLOW.md frontmatter keys | `WORKFLOW.md Pipeline Orchestration` frontmatter list no longer includes `worktree`. `Router Dispatch Pattern` Load-Configuration step lists current keys; Change-Context-Detection step describes 2-tier behavior. Final count: 5 requirements (≥3 ✅). |
| multi-target-distribution (Tweak) | Drop the `Worktree-path references` rule that referenced `worktree.path_pattern` | Sub-rule removed from the `Agnostic Skill Body` requirement; remaining points renumbered 1→1, 2→2, 4→3. Spec version bumped 4 → 5. |

### Scenario Coverage (manual checklist from tests.md)

All 14 manual test items in tests.md were verified at the source level:

| # | Scenario | Source artifact verifying it | PASS? |
|---|----------|-----------------------------|-------|
| 1 | Workspace created without worktree side-effects | `src/actions/propose.md` (link to `Create Change Workspace`); workflow body trimmed; no `Create Worktree-Based Workspace` link | ✅ |
| 2 | Existing proposal with legacy `worktree:` frontmatter still loads | `change-workspace.md` edge case explicit; SKILL.md Change Context Detection scans `branch:` field only | ✅ |
| 3 | Auto-detect via proposal `branch:` field | SKILL.md step 2 unchanged | ✅ |
| 4 | Fall through to directory listing when no `branch:` match | SKILL.md step 4/4b/5 (renumbered after dropping former step 3) | ✅ |
| 5 | Init no longer prompts for worktree opt-in | `project-init.md` `Install Workflow` second paragraph removed; `WORKFLOW.md Template File` no longer references commented-out worktree section | ✅ |
| 6 | Init env summary trimmed to GitHub tooling | `project-init.md` `Environment Checks During Init` rewritten to GitHub-tooling-only | ✅ |
| 7 | Branch handling on a fresh propose | `artifact-pipeline.md` `Post-Artifact Commit and PR Integration` text now reads "if already on `<change-name>` branch" without "(e.g., in a worktree)" parenthesis | ✅ |
| 8 | Frontmatter no longer documents `worktree:` | `.specshift/WORKFLOW.md` and `src/templates/workflow.md` show no `worktree:` key | ✅ |
| 9 | Post-merge cleanup deletes branch only | `review-lifecycle.md` `Merge Execution with Mandatory Confirmation` ends with branch deletion; SKILL.md / WORKFLOW body section in lockstep | ✅ |
| 10 | Load Configuration extracts current frontmatter set | SKILL.md Load Configuration line lists current keys without `worktree` | ✅ |
| 11 | Change Context Detection two-tier behavior | SKILL.md and `change-workspace.md` Change Context Detection both describe 2-tier flow | ✅ |
| 12 | Edge: legacy `worktree:` frontmatter not stripped | No code path now writes a `worktree:` field; new proposals MUST NOT write it (per change-workspace.md). Read paths ignore unknown fields. | ✅ |
| 13 | Edge: compile gate detects template-version bump | `src/templates/workflow.md` template-version bumped 9 → 10; `src/templates/changes/proposal.md` 2 → 3 (per follow-up Tweak). Compile script enforcement is preserved (will run during finalize). | ✅ (deferred to finalize for execution) |
| 14 | Edge: `git grep -i worktree` post-apply returns 0 hits in `src/`, project files | Verified: `src/` 0 hits, `.specshift/WORKFLOW.md AGENTS.md .specshift/templates/changes/proposal.md` 0 hits | ✅ |

Edge case 4 (compile script post-finalize verification) is deferred to the finalize step but the underlying preconditions (template-version bumps) are already satisfied.

### Design Adherence

| Decision (from design.md) | Honoured? |
|---------------------------|-----------|
| Remove worktree handling end-to-end (lifecycle + config + spec material) | ✅ — no dead config keys remain. |
| Treat existing `worktree:` frontmatter as legacy/read-only | ✅ — no migration code; legacy fields explicitly documented. |
| Drop worktree-convention fallback from Change Context Detection | ✅ — SKILL.md and specs consistent. |
| Remove the GitHub Merge Strategy Configuration requirement | ✅ — requirement gone from `project-init.md`; not linked from `src/actions/init.md`. |
| Bump `src/templates/workflow.md` template-version | ✅ 9 → 10. |
| Re-run `bash scripts/compile-skills.sh` during finalize | Deferred to finalize step (planned). |

### Scope Control

Every changed file traces to a numbered task in `tasks.md` (sections 2.1–2.4 and the two Tweak entries 2.4.3 / 2.4.4). No files outside the documented impact surface were touched. Historical `.specshift/changes/2026-03-30-worktree-*` and `2026-04-09-worktree-fetch-main/` and `2026-04-11-fix-stale-worktree-detection/` directories remain unmodified per the proposal's Out-of-Scope list.

### Preflight Side-Effects

All side-effects identified in `preflight.md > C. Side-Effect Analysis` are addressed:

| Side effect | Status |
|-------------|--------|
| Consumers with `worktree.enabled: true` lose feature | Pending changelog entry (finalize). |
| Existing on-disk worktrees not auto-cleaned | Documented as Manual step in design.md migration plan. |
| In-flight proposals carry legacy `worktree:` frontmatter | Documented as legacy/read-only in `change-workspace.md` edge cases; no rewriting. |
| Compiled tree retains stale text until finalize | Pending `bash scripts/compile-skills.sh` (finalize). |
| Historical worktree-themed changes appear orphaned | Out of scope per proposal — left untouched. |
| Rebase-merge GitHub repo config | No regression (review action squash-merges). |

### Test Coverage

Project mode is **manual-only** (CONSTITUTION's `## Testing`: "Framework: None"). The 14-item checklist in `tests.md` was verified inline above (Scenario Coverage section). 0 automated tests; 0 `@manual` markers to preserve.

### Spec status flips

All 5 originally-affected specs were already at `status: stable`. No `draft → stable` flip needed. The Tweak-edit on `multi-target-distribution.md` also keeps `status: stable`. No spec carried a `change:` field tied to this change (specs were only edited, not introduced as drafts), so no field removal needed.

### Proposal status flip

Per audit instructions, on PASS verdict the proposal `status` flips `active → review`. This flip will be staged in the implementation commit alongside the apply edits.

### Verdict

**PASS**

No CRITICAL or WARNING findings. Two SUGGESTION items logged for future workflow improvement.
