# Pre-Flight Check: Add Release Action

## A. Traceability Matrix

- [x] Release Action Configuration requirement → Scenario: request_review false → `src/templates/workflow.md` frontmatter, `.specshift/WORKFLOW.md` frontmatter
- [x] Release Action Configuration requirement → Scenario: request_review copilot → `src/templates/workflow.md` frontmatter, `.specshift/WORKFLOW.md` frontmatter
- [x] Release Action Configuration requirement → Scenario: request_review true → `src/templates/workflow.md` frontmatter
- [x] Release Action Configuration requirement → Scenario: always requires user confirmation → `## Action: release` instruction text
- [x] Release Action Configuration requirement → Scenario: re-entrant across sessions → `## Action: release` instruction text
- [x] Router auto-dispatch scenario → Scenario: finalize→release when auto_approve true → `src/skills/specshift/SKILL.md` finalize dispatch
- [x] Router skip scenario → Scenario: no release in actions → `src/skills/specshift/SKILL.md` finalize dispatch (conditional check)

## B. Gap Analysis

No gaps identified:
- Error handling: review tool unavailability covered by fallback (warning + continue)
- Session death: re-entrant design handles this via GitHub state reading
- Empty state: no PR for branch → error message pointing to finalize
- Safety limit: max 3 review cycles → pause

## C. Side-Effect Analysis

- **Consumer template version bump** (4 → 5): `specshift init` will prompt consumers to merge template updates. This is expected and non-breaking — the `release` additions are additive.
- **Router SKILL.md change**: Adding conditional auto-dispatch from finalize. Guarded by `release` in `actions` array check — consumers without `release` see no change. No regression to existing finalize behavior.
- **Compilation**: `scripts/compile-skills.sh` will copy updated SKILL.md and template. Template-version validation will require version bump (already planned: 4→5).

## D. Constitution Check

No constitution changes needed. Existing pre-merge standard tasks ("Update PR: mark ready for review" and "Reply to and resolve all PR review comments") already describe the behavior the release action automates. The release action operationalizes these tasks.

## E. Duplication & Consistency

- `workflow-contract.md` already documents custom actions and auto-dispatch. The new requirement extends these concepts consistently.
- `release-workflow.md` covers versioning and compilation, NOT PR lifecycle. No overlap.
- The `release` frontmatter config follows the same pattern as `worktree` config (optional object in frontmatter).
- No contradictions with existing specs.

## F. Assumption Audit

| Assumption | Source | Rating | Notes |
|------------|--------|--------|-------|
| MCP tools for PR operations available in Claude Code Web | design.md | Acceptable Risk | Claude Code Web environments provide GitHub MCP tools. Desktop/CLI environments may use gh CLI instead. Action uses tool-agnostic language. |
| Built-in Claude `/review` skill available | design.md | Acceptable Risk | Standard Claude Code capability. If unavailable, the self-review step is skipped — not blocking. |
| `subscribe_pr_activity` is session-bound | design.md | Acceptable Risk | Known behavior. Re-entrant design mitigates this — manual re-trigger always works. |

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any artifacts for this change.
No `<!-- REVIEW -->` markers found in the modified spec (`docs/specs/workflow-contract.md`).

## Verdict

**PASS** — All traceability links verified, no gaps, no blocking assumptions, no review markers.
