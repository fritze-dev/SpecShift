---
name: Optimize SpecShift Workflow and Context Management to Reduce LLM Token Consumption
branch: claude/optimize-token-consumption
issue: 15
---

# Tasks

## Implementation

### 1. Workflow Modification
- [ ] Edit `.specshift/WORKFLOW.md`
    - Update `pipeline` to `[research, tasks, review]`
    - Remove "Docs" regeneration step from `finalize` action instruction

### 2. Context Configuration
- [ ] Create/Update `.claudaignore`
    - Add `.specshift/changes/`

## Verification
- [ ] Verify `pipeline` change in `.specshift/WORKFLOW.md`
- [ ] Verify `finalize` action modification in `.specshift/WORKFLOW.md`
- [ ] Verify `.claudaignore` exists and contains the correct path
