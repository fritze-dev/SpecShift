---
has_decisions: true
---
# Technical Design: Add Release Action

## Context

The workflow currently ends at `specshift finalize` (changelog, docs, version, compile). After finalize, the PR is ready but review handling and merge are manual. This change adds a `release` custom action that automates the PR review-to-merge lifecycle. The action must be re-entrant across Claude Code Web sessions (ephemeral) and work with various review sources (Copilot, human, other agents).

Key constraint: Claude Code Web sessions are ephemeral. `subscribe_pr_activity` only works within the current session. If the session ends while waiting for a review, state must be recoverable from GitHub.

## Architecture & Components

**Files affected:**

1. **`src/templates/workflow.md`** — Consumer workflow template
   - Add `release` config block to frontmatter
   - Add `release` to default `actions` array
   - Add `## Action: release` section with tool-agnostic instruction
   - Bump `template-version: 4 → 5`

2. **`.specshift/WORKFLOW.md`** — Project workflow instance
   - Add `release` config block (`request_review: copilot`)
   - Add `release` to `actions` array
   - Add `## Action: release` section with project-specific instruction

3. **`src/skills/specshift/SKILL.md`** — Router
   - Add conditional `finalize → release` auto-dispatch in the `### finalize` dispatch section
   - Condition: `auto_approve: true` AND `release` is in the `actions` array

**Interaction pattern:**

```
Router (SKILL.md)
  └── finalize dispatch completes
      └── checks: auto_approve? release in actions?
          └── yes → dispatches specshift release
              └── Custom Action execution:
                  reads ## Action: release instruction from WORKFLOW.md
                  reads release config from frontmatter
                  reads PR state from GitHub (MCP tools / gh CLI / API)
                  processes comments, runs /review, asks user to merge
```

The release action follows the existing Custom Action dispatch path (SKILL.md lines 96-101). No new dispatch path is created.

## Goals & Success Metrics

* `specshift release` correctly identifies PR state (draft, reviews, comments, checks) on each invocation — PASS/FAIL via manual test on an existing PR
* Auto-dispatch chain works: `finalize → release` when `auto_approve: true` and `release` in actions — PASS/FAIL
* Backward-compatible: consumers without `release` in actions array see no behavior change after finalize — PASS/FAIL
* `bash scripts/compile-skills.sh` succeeds after all changes — PASS/FAIL
* Consumer template has `template-version: 5` and includes release action — PASS/FAIL

## Non-Goals

- Formalizing release as a built-in action with compiled requirements (follow-up)
- Creating a new spec file for the release action (custom actions are self-contained)
- GitHub Actions or CI/CD integration for release
- Automated merge without user confirmation
- Automatic re-review request after implementing fixes
- Formal triage levels for review comments

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Custom action, not built-in | Follows three-layer architecture: project-specific behavior in WORKFLOW.md, not in shared router code. No compiled requirements needed. | Built-in action with `src/actions/release.md` — would require spec-level requirement compilation |
| Re-entrant state machine reading PR state from GitHub | Handles session ephemerality — every invocation reads current state, no session-local state needed | Session-only subscribe_pr_activity (fragile), polling loop (wasteful), GitHub Actions (removed previously) |
| `request_review` config in frontmatter | Separates configuration (what reviewer) from behavior (how to process reviews). Tool-agnostic values. | Hardcoded in instruction text, environment variable |
| Default `request_review: false` | Respects projects without external reviewers or Copilot. Action still processes any manually-posted reviews. | Default to copilot (not all repos have Copilot), default to true (not all repos have reviewers configured) |
| Always require user confirmation for merge | Merge is irreversible, affects shared state. `auto_approve` controls dispatch, not the merge. | Auto-merge when approved + checks pass |

## Risks & Trade-offs

- **[Session timeout during review wait]** → Action reports status and exits gracefully. User re-runs `specshift release` in new session. No state lost because PR state lives on GitHub.
- **[Review tool unavailable]** → Warning logged, action continues. Reviews posted manually are still processed.
- **[Infinite review loop with AI reviewer]** → Safety limit of 3 cycles. No automatic re-review request. Loop is reactive only.
- **[Consumer template version bump]** → `specshift init` will prompt consumers to merge template updates. The `release` action and config are additive — no breaking changes.

## Migration Plan

Not applicable — this is a new additive feature. No existing behavior changes for consumers who do not add `release` to their actions array. The auto-dispatch from finalize is conditional on `release` being in the actions array.

## Open Questions

No open questions.

## Assumptions

- MCP tools for PR operations (pull_request_read, merge_pull_request, request_copilot_review) are available in Claude Code Web environments. <!-- ASSUMPTION: MCP tool availability -->
- The built-in Claude `/review` skill is available and can be invoked during the release action for self-review. <!-- ASSUMPTION: Built-in review skill availability -->
- `subscribe_pr_activity` works within Claude Code Web sessions for real-time event delivery (known to be session-bound). <!-- ASSUMPTION: PR activity subscription is session-bound -->
