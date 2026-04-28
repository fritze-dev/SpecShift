---
title: "Review Lifecycle"
capability: "review-lifecycle"
description: "Re-entrant PR review-to-merge state machine with comment processing, self-review, summary posting, and mandatory merge confirmation"
lastUpdated: "2026-04-28"
---

# Review Lifecycle

The review action automates the PR review-to-merge lifecycle: reading PR state, managing the draft-to-ready transition, processing review comments, running self-review cycles, posting a pre-merge summary, and merging with mandatory user confirmation.

## Purpose

Without automated review lifecycle management, developers must manually mark PRs ready, respond to review comments, verify fixes don't introduce regressions, and track what was done before merging. In ephemeral or web-based sessions, partial progress is lost when a session ends. The review lifecycle provides a re-entrant state machine that derives all state from the PR on GitHub, so any session can pick up where a previous one left off.

## Rationale

The review action is designed as a re-entrant state machine rather than a session-bound pipeline. All state is derived from GitHub (PR status, review decisions, comment threads, CI checks) and local change artifacts (proposal.md), so no session-local storage is needed. A safety limit of 3 review-fix cycles per invocation prevents infinite loops with AI reviewers. The merge confirmation is mandatory regardless of `auto_approve` because merging is an irreversible action that should always require explicit human approval. The pre-merge summary comment provides an audit trail visible on the PR itself, using an HTML marker for idempotent updates across sessions.

## Features

- **Re-entrant PR state assessment** -- reads PR state on each invocation (draft status, reviews, comments, CI checks) using available GitHub tooling; no session-local state stored
- **Draft-to-ready transition** -- marks draft PRs ready for review and updates the PR body with a change summary and issue references
- **Clean-tree check before review dispatch** -- verifies the working tree is clean before requesting external review; commits and pushes any uncommitted changes (e.g., from finalize compilation)
- **Configurable review dispatch** -- requests reviews based on `review.request_review` setting (false, copilot, or true for default reviewers); graceful degradation on failure
- **Automated comment processing** -- reads each unresolved thread, implements actionable fixes, replies explaining the action taken, and resolves threads; defers out-of-scope changes to the user
- **Self-review after fixes** -- runs the built-in review skill as a self-check after processing comments to catch regressions
- **Review cycle safety limit** -- max 3 review-fix cycles per invocation; pauses and reports remaining unresolved threads after the limit
- **Pre-merge summary comment** -- posts a PR comment summarizing threads resolved, fixes applied, self-check result, and review cycles completed; uses an HTML marker for idempotent updates on re-entrant runs
- **Review-pending gate** -- blocks merge offer while a requested review has no decision yet; reports pending status and suggests re-running later
- **Mandatory merge confirmation** -- always requires explicit user confirmation before merging, regardless of `auto_approve` setting
- **Post-merge branch deletion** -- deletes the local and remote feature branch after successful merge

## Behavior

### PR State Assessment (`specshift review`)

On each invocation, the action reads the PR's current state from GitHub and reports it before proceeding. If no PR exists, it suggests running `specshift finalize` first. The action detects which phase to enter based on the assessed state (draft, awaiting review, comments pending, ready to merge).

### Comment Processing and Self-Review

For each unresolved review thread, the action reads the comment, determines if the feedback is actionable, implements the fix if so, replies to the thread, and resolves it. After all fixes are committed and pushed, the built-in review skill runs as a self-check. If the self-check finds issues, they are fixed before proceeding. If a reviewer posts new comments after fixes, the cycle repeats (up to 3 times).

### Pre-Merge Summary

Before asking for merge confirmation, the action posts a summary comment on the PR. The summary includes thread counts, a fix list, self-check results, and review cycles completed. If a summary already exists (detected by `<!-- specshift:review-summary -->` marker), it is updated rather than duplicated. If posting fails, the action logs a warning and continues.

### Merge with Mandatory Confirmation

When no unresolved threads remain, CI checks pass, and no requested review is pending without a decision, the action asks the user for explicit merge confirmation. If a requested review has not been submitted yet, the action reports "Review pending — waiting for reviewer decision" and suggests re-running later. After confirmation, the action sets the proposal status to `completed` on the feature branch (committing and pushing so the status change is included in the squash merge), then merges the PR and deletes the local and remote feature branch.

## Known Limitations

- Safety limit of 3 review-fix cycles per invocation -- after 3 cycles, remaining threads must be resolved manually or by re-invoking the action
- Merge confirmation is always required, even with `auto_approve: true` -- this is by design for safety

## Edge Cases

- **PR closed (not merged)**: the action reports the state and stops without attempting to reopen
- **Branch behind base (merge conflicts)**: the action reports the conflict and suggests updating the branch
- **Summary comment permissions denied**: the action logs a warning and proceeds to merge confirmation without the summary
- **Reviewer requests changes without inline comments**: the action reports the review status and asks the user how to proceed
