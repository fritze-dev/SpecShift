---
name: Optimize SpecShift Workflow and Context Management to Reduce LLM Token Consumption
branch: claude/optimize-token-consumption
issue: 15
---

# Research

## Current State
The current SpecShift workflow uses an 8-step pipeline (`[research, proposal, specs, design, preflight, tests, tasks, review]`). This leads to a quadratic increase in context size as the LLM re-reads all previous artifacts to generate the next one. Additionally, the `finalize` action automatically regenerates all capability docs and ADRs, which can be extremely token-heavy. Historical change directories (`.specshift/changes/`) are indexed by the agent, adding further noise and token overhead.

## Objectives
- **Shorten Pipeline**: Reduce the pipeline to a minimal viable set to limit context growth.
- **Disable Auto-Docs**: Remove automatic capability doc/ADR regeneration from `finalize`.
- **Ignore History**: Prevent the agent from indexing historical change directories.

## Proposed Changes

### 1. Workflow Optimization (`.specshift/WORKFLOW.md`)
- Change `pipeline` from `[research, proposal, specs, design, preflight, tests, tasks, review]` to `[research, tasks, review]`.
- In the `finalize` action instruction, remove step 2 ("Docs: regenerate affected capability docs, ADRs, README").

### 2. Context Management (`.claudaignore`)
- Create/Update `.claudaignore` to include `.specshift/changes/`. This ensures the agent only sees the current change's workspace.

## Expected Impact
- Significant reduction in token usage per change.
- Faster response times due to smaller context.
- Reduced cost and improved sustainability of the automated workflow.
