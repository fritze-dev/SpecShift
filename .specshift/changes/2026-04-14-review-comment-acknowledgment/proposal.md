<!--
status: active
branch: claude/add-user-authentication-e4jWD
capabilities:
  new: []
  modified: []
  removed: []
-->
## Why

During PR #22, review comments were addressed with code fixes but never replied to or resolved on GitHub until the user noticed (issue #23). There is no convention ensuring review feedback is acknowledged, creating a recurring gap.

## What Changes

- Add a **"Review comment acknowledgment"** convention to `## Conventions` in `.specshift/CONSTITUTION.md` requiring agents to reply to each PR review comment (fixed, declined with reason, or not applicable) and resolve committed threads
- Add a **Pre-Merge checkbox** to `## Standard Tasks` making review comment response an actionable checklist item
- Fix **template path instruction** in `src/skills/specshift/SKILL.md`: change `<templates_dir>/<id>.md` to `<templates_dir>/changes/<id>.md` to match actual directory structure

## Capabilities

### New Capabilities

None — this is a constitution convention, not a new capability.

### Modified Capabilities

None — no spec-level behavior changes. The constitution is edited directly per File Ownership rules.

### Removed Capabilities

None.

### Consolidation Check

N/A — no new specs proposed. Reviewed `docs/specs/constitution-management.md` which governs constitution structure/lifecycle but does not dictate individual convention content. This change adds content to an existing constitution section, not a new capability.

## Impact

- `.specshift/CONSTITUTION.md` — two additions (convention + checkbox)
- `src/skills/specshift/SKILL.md` — fix template path in propose pipeline traversal instruction

## Scope & Boundaries

**In scope:**
- Convention text for review comment acknowledgment
- Pre-Merge standard task checkbox
- Fix template path instruction in SKILL.md

**Out of scope:**
- Workflow action for automated review response
- Tooling or automation to enforce the convention
