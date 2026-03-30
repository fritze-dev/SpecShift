## Why

The archive skill invokes spec sync via the Agent/Task tool without explicitly requiring foreground execution. The LLM can launch the sync agent in the background and proceed to the archive commit, causing spec changes in `openspec/specs/` to land after the commit — leaving uncommitted changes.

## What Changes

- Update the sync invocation in the archive skill (step 4) to explicitly prohibit background execution in the subagent prompt
- Add result validation after sync completes to confirm specs were actually written before proceeding to archive
- Update the `change-workspace` spec to codify the foreground execution requirement for auto-sync

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `change-workspace`: Add requirement that auto-sync during archive MUST run in the foreground (not as a background agent), and that the archive step MUST validate sync completion before proceeding.

### Consolidation Check

N/A — no new specs proposed. Reviewed `spec-sync` (covers sync mechanics, not archive invocation ordering) and `change-workspace` (covers archive behavior including auto-sync — correct target for this fix).

## Impact

- `src/skills/archive/SKILL.md` — step 4 subagent prompt and post-sync validation
- `openspec/specs/change-workspace/spec.md` — "Auto-sync before archiving" scenario

## Scope & Boundaries

**In scope:**
- Fix the archive skill's sync invocation to prevent background execution
- Add validation that sync completed before archive proceeds
- Update spec to reflect the foreground requirement

**Out of scope:**
- Changing the sync skill itself
- Switching from Agent/Task tool to Skill tool (context isolation is desirable)
- General audit of other background agent invocations across skills
