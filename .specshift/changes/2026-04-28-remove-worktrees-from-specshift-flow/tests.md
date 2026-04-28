# Tests: Remove Worktrees from SpecShift Workflow

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

CONSTITUTION's `## Testing` section declares the project as Markdown/YAML artifacts with no executable tests; Gherkin scenarios are verified via `audit.md` during the apply phase. This tests.md captures the manual checklist focused on the behavioral diff introduced by this change — not every scenario in every modified spec.

## Manual Test Plan

### change-workspace

#### Create Change Workspace

- [ ] **Scenario: Workspace created without worktree side-effects**
  - Setup: clean working tree on `main`; no `.specshift/worktrees/` activity expected.
  - Action: invoke `specshift propose <new-name>` and let the propose pipeline run.
  - Verify: `.specshift/changes/YYYY-MM-DD-<new-name>/` exists; **no** `.specshift/worktrees/` entry was created; the freshly generated `proposal.md` frontmatter contains `status: active`, `branch: ...`, `capabilities: ...`, and **no** `worktree` key.

- [ ] **Scenario: Existing proposal with legacy `worktree:` frontmatter still loads**
  - Setup: a historical change directory (e.g., `2026-03-30-worktree-based-change-lifecycle/`) whose `proposal.md` frontmatter still carries `worktree: <path>`.
  - Action: invoke any specshift action on its branch (or pass it explicitly).
  - Verify: the router auto-detects via `branch:` lookup; the legacy `worktree:` field is ignored on read; no error or warning about the field.

#### Change Context Detection

- [ ] **Scenario: Auto-detect via proposal `branch:` field**
  - Setup: on a branch matching some proposal's `branch:` field.
  - Action: invoke `specshift propose` (or any action).
  - Verify: announcement "Detected change context: using change '<name>'"; correct change selected.

- [ ] **Scenario: Fall through to directory listing when no `branch:` match**
  - Setup: on a branch with no matching proposal frontmatter.
  - Action: invoke an action without an explicit change argument.
  - Verify: router prompts with the active-changes list (no attempt to derive name from branch via worktree-convention fallback).

### project-init

#### Install Workflow

- [ ] **Scenario: Init no longer prompts for worktree opt-in**
  - Setup: a fresh project directory (no `.specshift/`).
  - Action: invoke `specshift init`.
  - Verify: prompt sequence does NOT include "enable worktree-based change isolation" or rebase-merge-strategy questions; the generated `.specshift/WORKFLOW.md` does NOT contain a `worktree:` block (commented or live).

- [ ] **Scenario: Init env summary trimmed to GitHub tooling**
  - Setup: any environment.
  - Action: invoke `specshift init`.
  - Verify: env summary reports GitHub tooling availability/auth; does NOT report git version or `.gitignore /.claude/` checks.

### artifact-pipeline

#### Post-Artifact Commit and PR Integration

- [ ] **Scenario: Branch handling on a fresh propose**
  - Setup: invoke propose on `main` with no existing feature branch for the change.
  - Action: let propose generate the first artifact.
  - Verify: `git checkout -b <change-name>` runs; commit + push + draft PR succeed; behavior identical regardless of whether the user happens to be in any host-managed worktree.

#### WORKFLOW.md Owns Pipeline Configuration

- [ ] **Scenario: Frontmatter no longer documents `worktree:`**
  - Setup: read the project's `.specshift/WORKFLOW.md`.
  - Action: inspect frontmatter.
  - Verify: contains `templates_dir`, `pipeline`, `actions`, `auto_approve`, `review`; does NOT contain `worktree:`.

### review-lifecycle

#### Merge Execution with Mandatory Confirmation

- [ ] **Scenario: Post-merge cleanup deletes branch only**
  - Setup: a PR ready to merge with passing CI on a feature branch (no host-managed worktree involvement).
  - Action: confirm merge in `specshift review`.
  - Verify: PR squash-merges with composed commit message; the local + remote feature branch are deleted; **no** worktree-removal step is attempted; user is not prompted about worktree cleanup.

### workflow-contract

#### Router Dispatch Pattern

- [ ] **Scenario: Load Configuration extracts current frontmatter set**
  - Setup: a project's `.specshift/WORKFLOW.md` with the current schema.
  - Action: any action invocation.
  - Verify: router reads `templates_dir`, `pipeline`, `actions`, `auto_approve`, `plugin-version`; does NOT attempt to read `worktree`.

- [ ] **Scenario: Change Context Detection two-tier behavior**
  - Setup: any session.
  - Action: any action that triggers detection.
  - Verify: detection scans `.specshift/changes/*/proposal.md` for `branch:` match → on miss, lists active changes for user selection. No `git rev-parse --git-dir /worktrees/` lookup.

## Edge Cases

- [ ] **Edge: Existing proposal with legacy `worktree:` frontmatter is left untouched on commit/push.**
  - Setup: open an existing change directory with legacy `worktree:` frontmatter and trigger a normal propose-pipeline action that touches its proposal (e.g., status flip during review).
  - Verify: only the intended frontmatter field changes; `worktree:` is not stripped, not rewritten, not warned about.

- [ ] **Edge: Compile gate detects template-version bump on `src/templates/workflow.md`.**
  - Setup: after editing `src/templates/workflow.md` to remove the commented `worktree:` block.
  - Action: run `bash scripts/compile-skills.sh`.
  - Verify: the script exits 0; the compiled `skills/specshift/templates/workflow.md` reflects the new content. If the `template-version` was forgotten, the script must fail with an explicit message.

- [ ] **Edge: `git grep -i worktree` post-apply returns 0 hits in `src/`.**
  - Setup: after the apply phase commits.
  - Action: `git grep -i worktree -- src/ .specshift/WORKFLOW.md AGENTS.md .specshift/templates/changes/proposal.md`.
  - Verify: 0 results.

- [ ] **Edge: `git grep -i worktree` post-finalize returns 0 hits in `skills/specshift/`.**
  - Setup: after `specshift finalize` completes (compile re-run).
  - Action: `git grep -i worktree -- skills/specshift/`.
  - Verify: 0 results.

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 10 (capability) + 4 (edge) = 14 |
| Automated tests | 0 |
| Manual test items | 14 |
| Preserved (@manual) | 0 |
| Edge case tests | 4 |
| Warnings | 0 |
