---
status: active
branch: claude/review-workflow-artifacts-DawzG
capabilities:
  new: []
  modified: [three-layer-architecture, workflow-contract]
  removed: []
---
## Why

A review of the workflow artifacts found that 3 bugs and 2 DRY violations breach the Layer Separation requirement from `three-layer-architecture.md`. Consumer templates contain project-specific content, action requirements reference wrong specs, and identical rules are expressed in multiple layers — creating drift risk.

## What Changes

- **Remove compile step from consumer template** (`src/templates/workflow.md`): the `bash scripts/compile-skills.sh` step is SpecShift-specific and fails for every consumer project. Keep it only in `.specshift/WORKFLOW.md`.
- **Delegate version-bump in project WORKFLOW.md** (`.specshift/WORKFLOW.md`): replace hardcoded version-bump details with the same delegation phrasing as the consumer template ("if the constitution defines a version-bump convention, follow it; otherwise skip").
- **Remove preflight reference from init.md** (`src/actions/init.md`): the Preflight Quality Check requirement belongs to `propose`, not `init`. The spec explicitly says "when the user invokes specshift propose".
- **Remove auto-dispatch language from WORKFLOW.md** (both `src/templates/workflow.md` and `.specshift/WORKFLOW.md`): auto-dispatch between actions is a router concern (SKILL.md lines 72, 79). Workflow instructions should describe intra-action behavior, not inter-action chaining.
- **Remove design checkpoint convention from Constitution** (`.specshift/CONSTITUTION.md`): identical to WORKFLOW.md propose instruction line 40. The `## Context` section already enforces reading the constitution. Operational details belong in the workflow instruction, not as a constitution convention.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `three-layer-architecture`: Add explicit Layer Separation scenarios for the patterns discovered — constitution SHALL NOT duplicate workflow instruction details, consumer templates SHALL NOT contain project-specific steps.
- `workflow-contract`: Clarify that finalize instruction in consumer templates SHALL NOT contain project-specific compilation steps, and that auto-dispatch language belongs in the router dispatch section, not in action instructions.

### Removed Capabilities

None.

### Consolidation Check

1. Existing specs reviewed: three-layer-architecture, workflow-contract, project-init, quality-gates, artifact-pipeline, constitution-management
2. Overlap assessment: `three-layer-architecture` already has Layer Separation requirement but lacks scenarios for constitution-workflow duplication and consumer template purity. `workflow-contract` already defines Inline Action Definitions and Router Dispatch but doesn't explicitly restrict what action instructions may reference.
3. Merge assessment: Both modifications target different specs with distinct concerns (architecture layers vs workflow contract). No merge needed.

## Impact

- **Consumer template** (`src/templates/workflow.md`): finalize action loses compile step and auto-dispatch language. Template-version bumps 3→4.
- **Project instance** (`.specshift/WORKFLOW.md`): version-bump delegated, auto-dispatch language removed.
- **Constitution** (`.specshift/CONSTITUTION.md`): one convention removed.
- **Action reference** (`src/actions/init.md`): one requirement link removed.
- **Compiled artifacts** (`.claude/skills/specshift/`): regenerated via `compile-skills.sh`.

## Scope & Boundaries

**In scope:** Removing redundancies and misplaced content from existing artifacts. Adding clarifying scenarios to 2 existing specs.

**Out of scope:** Architectural changes to the three-layer model. Changes to SKILL.md dispatch logic (already correct). Changes to how auto_approve works (behavior unchanged).
