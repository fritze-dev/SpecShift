---
status: review
branch: claude/enforce-specshift-workflow-0Syd7
capabilities:
  new: []
  modified: [project-init]
  removed: []
---
## Why

When using plan mode before `specshift propose`, the approved plan can describe direct file edits as the implementation method — bypassing the "All changes MUST go through the spec-driven workflow" rule in CLAUDE.md. The `## Planning` section requires explicit scope commitment but says nothing about routing implementation through the specshift skill.

## What Changes

- **Add a workflow-routing paragraph to CLAUDE.md's `## Planning` section** requiring plans to route implementation through the specshift workflow skill (starting with `specshift propose`). Plans that describe direct file edits without invoking specshift are non-conforming.
- **Update the consumer bootstrap template** (`src/templates/claude.md`) with the same paragraph and bump `template-version` from 3 to 4.
- **Update the project-init spec** (`docs/specs/project-init.md`) CLAUDE.md Bootstrap requirement to mention the workflow-routing directive as a standard directive.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-init`: The CLAUDE.md Bootstrap requirement is updated to include workflow-routing as a standard directive in the `## Planning` section description.

### Removed Capabilities

None.

### Consolidation Check

N/A — no new specs proposed. The only spec modification is a minor wording expansion to the CLAUDE.md Bootstrap requirement in `project-init`.

## Impact

- **CLAUDE.md**: One paragraph added to `## Planning` section
- **src/templates/claude.md**: Same paragraph added, template-version bumped (triggers compilation validation)
- **docs/specs/project-init.md**: Requirement wording expanded (line 274)
- **Consumer projects**: Will see a WARNING on next `specshift init` if their Planning section is outdated (by design)

## Scope & Boundaries

**In scope:**
- Adding workflow-routing rule to CLAUDE.md `## Planning` section
- Adding same rule to `src/templates/claude.md` with template-version bump
- Updating `docs/specs/project-init.md` CLAUDE.md Bootstrap requirement

**Out of scope:**
- No required plan format or template structure (plans stay flexible)
- No CONSTITUTION.md changes (agent instructions belong in CLAUDE.md)
- No automated enforcement or linting of plan content (behavioral instruction only)
- No changes to specshift propose/apply/finalize/review actions themselves
