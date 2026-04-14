# Research: Add Release Action

## 1. Current State

The workflow has 4 built-in actions: `init`, `propose`, `apply`, `finalize`. After `finalize` completes (changelog, docs, version bump, compile), the PR is ready but merge happens manually. There is no automation for the PR review-to-merge lifecycle.

**Relevant architecture:**
- **Three-layer architecture** (`CONSTITUTION.md` → `WORKFLOW.md` + Templates → Router): The router (`src/skills/specshift/SKILL.md`) dispatches built-in and custom actions. Custom actions are defined via `## Action: <name>` sections in WORKFLOW.md and dispatched via the "Custom Action — Direct Execution" path (SKILL.md lines 96-101).
- **Custom actions mechanism** (added 2026-04-10): Consumer-defined actions added to the `actions` array in WORKFLOW.md frontmatter with matching `## Action: <name>` body sections. No compiled requirements needed — instruction text is self-contained.
- **Auto-dispatch chain**: `propose → apply → finalize` when `auto_approve: true`. Each transition is conditional in the router's dispatch section.
- **Pre-merge standard tasks** (CONSTITUTION.md): "Update PR: mark ready for review" and "Reply to and resolve all PR review comments."
- **CI automation was removed** (2026-04-10-remove-automation-config): GitHub Actions trigger for finalize was explicitly removed as unnecessary complexity.

**Relevant files:**
- `.specshift/WORKFLOW.md` — pipeline config, actions array, auto_approve
- `src/templates/workflow.md` — consumer template (template-version: 4)
- `src/skills/specshift/SKILL.md` — router with auto-dispatch logic
- `.specshift/CONSTITUTION.md` — pre-merge standard tasks
- `docs/specs/workflow-contract.md` (v8) — WORKFLOW.md format spec
- `docs/specs/three-layer-architecture.md` (v6) — layer separation rules

**Spec staleness check:** Specs are current. `workflow-contract.md` (v8, modified 2026-04-14) covers custom actions and auto_approve. No stale-spec risks.

## 2. External Research

**Available GitHub MCP tools for PR lifecycle:**
- `request_copilot_review` — request Copilot to review a PR
- `get_copilot_job_status` — check Copilot review progress
- `subscribe_pr_activity` — listen to PR events in current session (Claude Code Web built-in)
- `merge_pull_request` — merge a PR (squash, merge, rebase)
- `enable_pr_auto_merge` — enable auto-merge when checks pass
- `pull_request_review_write` — submit a PR review
- `pull_request_read` — read PR details, reviews, comments

**Copilot integration** (set up 2026-04-11): `.github/copilot-instructions.md`, `copilot-setup-steps.yml`, `.github/skills/workflow/SKILL.md` (symlink). Copilot can discover and use the workflow skill.

**Claude Code Web PR Activity:** Built-in `subscribe_pr_activity` delivers review comments as `<github-webhook-activity>` events. Session-bound — dies when session ends. User can also manually trigger comment processing.

**Tool-agnostic convention** (established 2026-04-11): Specs and skills describe intent ("request external review using available GitHub tooling"), not specific tools. Parenthetical examples allowed.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| New custom action `release` in WORKFLOW.md | Follows existing custom action pattern; no router modification for action definition; re-entrant across sessions; opt-in per project | Requires router change for auto-dispatch from finalize |
| Extend `finalize` to include merge | Single action, no new concept | Mixes artifact concerns with PR lifecycle; harder to skip merge step; finalize is a built-in with compiled requirements |
| Session-only automation (subscribe + wait) | Simplest implementation | Fragile — session may die; not re-entrant; state lost on disconnect |
| External CI automation (GitHub Actions) | Runs independently of session | Was explicitly removed as unnecessary complexity; requires infrastructure; coupling to GitHub |

**Recommended: New custom action `release`** — aligns with architecture, re-entrant, configurable per consumer.

## 4. Risks & Constraints

- **Session ephemerality**: Claude Code Web sessions can end while waiting for external review. Mitigation: re-entrant action that reads PR state from GitHub on each invocation.
- **Router modification**: Adding `finalize → release` auto-dispatch requires SKILL.md change. Mitigated by conditional check on `actions` array (backward-compatible).
- **Infinite review loops**: AI reviewers may always find new issues. Mitigated by safety limit (max 3 cycles) and no automatic re-review request.
- **Tool availability**: MCP tools may not be available in all environments. Mitigated by tool-agnostic language and graceful fallback.
- **Breaking change risk**: Adding `release` to default consumer `actions` array changes behavior. Mitigated by the action being essentially a no-op when no PR exists or no reviews are pending.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | New custom action with auto-dispatch from finalize |
| Behavior | Clear | Re-entrant state machine: assess → ready → process comments → merge |
| Data Model | Clear | No new data model; reads PR state from GitHub, change artifacts from filesystem |
| UX | Clear | Configurable via WORKFLOW.md frontmatter; always requires user confirmation for merge |
| Integration | Clear | MCP tools, PR activity hooks, tool-agnostic fallback |
| Edge Cases | Clear | Covered in plan: no PR, already merged, session death, conflict, CI failure |
| Constraints | Clear | Router immutability for action definition (custom action); router modifiable for dispatch chain |
| Terminology | Clear | "release" = PR review-to-merge lifecycle action |
| Non-Functional | Clear | No performance concerns; re-entrancy handles reliability |

All categories Clear — no open questions needed.

## 6. Open Questions

All Clear — skipped.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Name the action `release` | "Merge" is too narrow (action also handles review, cleanup). "Release" encompasses the full PR-to-main lifecycle | `merge`, `ship`, `deliver` |
| 2 | Custom action (not built-in) | WORKFLOW.md-defined actions need no compiled requirements; follows existing custom action pattern; project-specific behavior stays in WORKFLOW.md | Extending finalize, new built-in action |
| 3 | Default for all consumers | Every project with PRs benefits from review comment processing; action is a no-op when no PR or reviews exist | Opt-in only, SpecShift-internal only |
| 4 | Configurable review assignment | `request_review: false` default respects projects without external reviewers; `copilot`/`true` opts into specific behavior | Hardcoded Copilot, no configuration |
| 5 | No formal triage levels | PR review comments at this stage are mostly tweaks; larger concerns should trigger new `specshift propose` | 2-level (implementable/declined), 3-level from apply |
| 6 | Always require user confirmation for merge | Merge is irreversible and affects shared state; `auto_approve` controls dispatch, not the merge itself | Auto-merge when checks pass, configurable |
| 7 | No automatic re-review request | `/review` (built-in) handles self-review; avoids infinite loops with AI reviewers; re-review happens reactively if reviewer posts new comments | Automatic re-request after each fix cycle |
