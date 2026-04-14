---
status: completed
branch: explicit-plan-scope
worktree: .claude/worktrees/explicit-plan-scope
capabilities:
  new: []
  modified: [project-init]
  removed: []
---
## Why

When using plan mode before `specshift propose`, scope decisions — goals, non-goals, out-of-scope items — are discussed but often remain implicit. Later, the design artifact treats these as settled without the user having explicitly committed to them. This creates misalignment: the user discovers scope assumptions in the design that they never consciously agreed to.

## What Changes

- **Add a "Planning" section to CLAUDE.md** with an instruction that plan mode discussions must conclude with an explicit scope summary (goals, non-goals, boundaries) that the user reviews and commits to before exiting plan mode.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None — this change adds an agent instruction to CLAUDE.md. No spec-level behavioral requirements are affected.

### Removed Capabilities

None.

### Consolidation Check

N/A — no new specs proposed. This change modifies CLAUDE.md (agent instructions), not specs.

## Impact

- **CLAUDE.md**: New section added
- **Downstream effect**: Proposal `## Scope & Boundaries` and design `## Non-Goals` will be better informed because scope was explicitly agreed during planning

## Scope & Boundaries

**In scope:**
- Adding a "Planning" section to CLAUDE.md with scope commitment rules

**Out of scope:**
- Modifying the proposal or design templates (they already have scope sections)
- Adding this to the plugin consumer template (project-specific instruction)
- Enforcing scope via tooling or automation (this is a behavioral instruction)
