---
name: Optimize SpecShift Workflow and Context Management to Reduce LLM Token Consumption
branch: claude/optimize-token-consumption
issue: 15
---

# Proposal

## Summary
This change optimizes the SpecShift workflow to reduce LLM token consumption and context bloat. We are shortening the artifact pipeline, disabling automatic documentation regeneration during finalization, and ignoring historical change data.

## Changes

### 1. Workflow Compression
Modify `.specshift/WORKFLOW.md`:
- **Pipeline**: Update `pipeline: [research, proposal, specs, design, preflight, tests, tasks, review]` $\rightarrow$ `pipeline: [research, tasks, review]`.
- **Finalize Action**: Remove the "Docs" regeneration step from the sequential finalization process.

### 2. Context Boundary
Create/Update `.claudaignore`:
- Add `.specshift/changes/` to the ignore list.

## Rationale
- **Pipeline**: The previous 8-step pipeline caused quadratic token growth. By combining research and task generation into a leaner flow, we maintain the necessary planning quality while drastically reducing context overhead.
- **Finalize**: Automatic regeneration of large capability docs and ADRs is expensive and often unnecessary for every single change. This will become a manual or targeted process.
- **Ignore**: Indexing all historical changes creates noise and consumes tokens for information that is irrelevant to the current task.

## Success Criteria
- Pipeline is reduced to 3 steps.
- `finalize` no longer triggers auto-docs regeneration.
- `.specshift/changes/` is listed in `.claudaignore`.
