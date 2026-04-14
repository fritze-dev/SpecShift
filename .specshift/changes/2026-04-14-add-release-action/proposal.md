---
status: completed
branch: claude/automate-pr-review-merge-E3KOL
capabilities:
  new: []
  modified: [workflow-contract]
  removed: []
---
## Why

After `specshift finalize`, the PR is ready (code, docs, changelog, version) but review handling and merge happen manually. This adds a `release` action that automates the PR review-to-merge lifecycle — processing review comments, running self-review, and merging with user confirmation.

## What Changes

- Add `release` custom action to `src/templates/workflow.md` (consumer template) and `.specshift/WORKFLOW.md` (project instance)
- Add `release` configuration block to WORKFLOW.md frontmatter (`request_review: false | copilot | true`)
- Add conditional `finalize → release` auto-dispatch in router (`src/skills/specshift/SKILL.md`)
- Add `release` to default `actions` array in consumer template

## Capabilities

### New Capabilities

None — the `release` action is a custom action defined via WORKFLOW.md instruction text. Custom actions are self-contained and do not require dedicated specs.

### Modified Capabilities

- `workflow-contract`: Add `release` configuration block to WORKFLOW.md frontmatter specification and document the `finalize → release` auto-dispatch conditional in the router dispatch pattern.

### Removed Capabilities

None.

### Consolidation Check

Existing specs reviewed: artifact-pipeline, change-workspace, constitution-management, documentation, human-approval-gate, project-init, quality-gates, release-workflow, roadmap-tracking, spec-format, task-implementation, test-generation, three-layer-architecture, workflow-contract.

- `workflow-contract` covers WORKFLOW.md format, actions, custom actions, and auto-dispatch — the new `release` configuration and finalize→release dispatch fit naturally as modifications here.
- `release-workflow` covers versioning, compilation, and release processes — NOT the PR lifecycle. Distinct scope.
- No new specs needed. The `release` action's behavior is defined in its WORKFLOW.md instruction (custom action pattern). Only the frontmatter format and dispatch chain need spec-level requirements.

N/A for merge assessment — no new capabilities proposed.

## Impact

- **`src/templates/workflow.md`**: New frontmatter field (`release:`), new action in `actions` array, new `## Action: release` section. Template-version bumped 4 → 5.
- **`.specshift/WORKFLOW.md`**: Same additions, project-specific configuration (`request_review: copilot`).
- **`src/skills/specshift/SKILL.md`**: Conditional auto-dispatch from finalize to release in the finalize dispatch section.
- **`docs/specs/workflow-contract.md`**: New requirement for `release` configuration and updated auto-dispatch documentation.
- **Consumer projects**: `specshift init` will detect template-version bump and offer to merge the new `release` action. Backward-compatible — consumers without `release` in their actions array are unaffected by the router change.

## Scope & Boundaries

**In scope:**
- `release` custom action definition in WORKFLOW.md (consumer template + project instance)
- `release` frontmatter configuration block
- Router auto-dispatch from finalize to release (conditional on actions array)
- `workflow-contract` spec update
- Compilation via `scripts/compile-skills.sh`

**Out of scope:**
- New spec file for `release` action (custom actions are self-contained)
- Changes to CONSTITUTION.md (pre-merge standard tasks already cover the behavior)
- GitHub Actions or CI/CD integration
- Copilot agent profile or `.github/copilot-instructions.md` changes
- Formalizing the release action as a built-in action with compiled requirements (potential follow-up)
