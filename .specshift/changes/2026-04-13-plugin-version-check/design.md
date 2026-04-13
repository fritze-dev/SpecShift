---
has_decisions: true
---
# Technical Design: Plugin Version Check

## Context

Consumer projects installed via `specshift init` have no way to know when the plugin has been updated. The SKILL.md router currently reads WORKFLOW.md across 3 separate steps (Steps 1, 2, and 4), creating redundancy. This change adds a `plugin-version` field to WORKFLOW.md, restructures the router to read WORKFLOW.md once, and adds a version check step.

Affected files:
- `src/templates/workflow.md` — add `plugin-version` field, bump `template-version`
- `src/skills/specshift/SKILL.md` — restructure steps, add version check
- `.specshift/WORKFLOW.md` — project instance gets updated fields
- `docs/specs/workflow-contract.md` — already updated with new requirements
- `docs/specs/project-init.md` — already updated with Plugin Version Stamp requirement
- `src/actions/init.md` — already updated with new requirement link

## Architecture & Components

### WORKFLOW.md Template (`src/templates/workflow.md`)

Add to YAML frontmatter:
```yaml
template-version: 3        # bumped from 2
plugin-version: ""          # empty placeholder, stamped by init
```

### SKILL.md Router (`src/skills/specshift/SKILL.md`)

Restructure from 5 steps to 5 steps with new responsibilities:

| Current | New |
|---------|-----|
| Step 1: Identify Action (reads WORKFLOW.md `actions`) | Step 1: Load Configuration (read WORKFLOW.md once — all frontmatter + all body sections) |
| Step 2: Load WORKFLOW.md (reads full file again) | Step 2: Identify Action (validate against already-loaded `actions` array) |
| Step 3: Change Context Detection | Step 3: Plugin Version Check (compare `plugin-version` vs `plugin.json`) |
| Step 4: Load Action Context (reads WORKFLOW.md body again) | Step 4: Change Context Detection (unchanged logic) |
| Step 5: Dispatch | Step 5: Dispatch (load compiled requirements + execute; instruction already loaded in Step 1) |

### Init Action

The compiled requirements at `.claude/skills/specshift/actions/init.md` will include the Plugin Version Stamp requirement after recompilation. Init reads `plugin.json` and writes `plugin-version` to WORKFLOW.md frontmatter.

### Project Instance (`.specshift/WORKFLOW.md`)

After implementation, this project's own WORKFLOW.md gets:
- `template-version: 3`
- `plugin-version: <current-version>` (whatever version is in `src/.claude-plugin/plugin.json`)

## Goals & Success Metrics

* SKILL.md reads WORKFLOW.md exactly once (Step 1) — no redundant reads in later steps
* Version mismatch produces advisory warning containing both installed and current versions
* Version match produces no output
* Missing `plugin-version` field produces a note (not a warning)
* `init` action skips version check
* `specshift init` stamps `plugin-version` from `plugin.json`
* Template `template-version` bumped to 3

## Non-Goals

* Semver comparison or compatibility matrix
* Automatic plugin update mechanism
* Breaking change detection between plugin versions
* Blocking version check (all checks are advisory)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Simple string equality for version comparison | Avoids semver parsing complexity; any difference is actionable | Semver range check (overkill for advisory notice) |
| `plugin-version: ""` as template placeholder | Init fills it; empty string signals "not yet stamped" | Omit field from template (harder to detect legacy vs unstamped) |
| Merge old Steps 1+2 into new Step 1 | WORKFLOW.md was read twice; frontmatter in Step 1, full file in Step 2 | Keep separate (wasteful, confusing) |
| Merge old Step 4 into new Step 5 | Instruction is already loaded in Step 1; no need for a separate load step | Keep Step 4 (redundant read) |

## Risks & Trade-offs

- [Template-version bump triggers merge logic] → Expected behavior for consumers with customized WORKFLOW.md. Unmodified consumers get silent update. This is the existing template merge pattern working as designed.
- [Version check on every action] → Trivial cost (one JSON file read + string comparison). Benefit: user is always informed.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
