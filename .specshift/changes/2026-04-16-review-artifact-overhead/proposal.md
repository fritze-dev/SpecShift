<!--
---
status: active
branch: claude/review-artifact-overhead-FvUc3
capabilities:
  new: []
  modified: [artifact-pipeline, quality-gates, test-generation, documentation, workflow-contract]
  removed: []
---
-->
## Why

The SpecShift artifact pipeline causes excessive LLM token consumption — up to 7% of a 5-hour session budget within minutes (Issue #15). Three compounding factors: (1) the router loads all prior artifacts for every pipeline stage causing O(N²) context growth across 8 stages, (2) finalize scans all 80 historical change directories (2.8MB), and (3) no `.claudeignore` excludes historical changes from session indexing. Reducing stages from 8 to 6, enforcing per-stage context contracts, and isolating historical changes makes the workflow sustainable.

## What Changes

- **Pipeline reduced from 8 to 6 stages**: `[proposal, specs, design, preflight, tasks, audit]`. Research merged into Proposal as a fixed Discovery block. Tests eliminated — automated test generation moves to the apply phase driven by Constitution § Testing.
- **Proposal template restructured**: Gains Discovery sections (Current State, Approaches, Coverage Assessment, Decisions) from research template. `requires: []` (no dependency). Discovery is always present, not optional.
- **Design Non-Goals instruction refined**: Non-Goals now only contain technical capability-limitations that emerged during design, not copy-pasted Proposal Out-of-scope items. Design instruction references Proposal § Scope for change-level boundaries.
- **Tasks template updated**: `requires: [preflight]` (was `[tests]`). Gains apply-phase test guidance for projects with configured test frameworks. Conditional `## 0. Validation Notes` section when design is skipped.
- **Audit template updated**: References updated from preflight.md → design.md § Validation (when preflight absent), tests.md → specs (direct scenario verification).
- **SKILL.md context-loading rewritten**: Propose dispatch changes from "read all change artifacts" to per-stage requires-based loading. Apply dispatch reads only proposal (capabilities), design (architecture, metrics), tasks, and specs. Each stage specifies precise read/write contracts enabling future sub-agent execution.
- **Finalize scoped**: Auto-dispatch passes capability list from proposal frontmatter. Only affected capabilities regenerated. ADR generation conditional on `has_decisions: true` in design.md frontmatter.
- **ADR template streamlined**: Context minimum reduced from 4-6 to 2-6 sentences. Consequences section optional for straightforward decisions.
- **`.claudeignore` created**: Excludes `.specshift/changes/` from agent indexing (~2.8MB).
- **Capability doc template updated**: Enrichment source changed from `research.md` to `proposal.md § Discovery`.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `artifact-pipeline`: "Eight-Stage Pipeline" requirement rewritten as "Six-Stage Pipeline" with updated stage list and dependency chain. Pipeline array, stage descriptions, and artifact list all change. Post-artifact commit logic updated for new stage names. Research and tests templates removed from pipeline definition.
- `quality-gates`: Preflight requirement updated to reflect that when design is skipped, preflight is also skipped and tasks gets a minimal Validation Notes section. Audit verification dimensions updated — references to tests.md and preflight.md adapted for the new pipeline structure.
- `test-generation`: Rewritten from "separate pipeline stage producing tests.md" to "apply-phase test generation driven by Constitution § Testing". Manual test checklists removed. Automated test generation becomes part of implementation tasks.
- `documentation`: Capability doc enrichment source updated from `research.md + design.md` to `proposal.md § Discovery + design.md`. ADR generation made conditional on `has_decisions` frontmatter. ADR format streamlined (shorter context, optional consequences). Finalize scoped to affected capabilities via proposal frontmatter.
- `workflow-contract`: Router context-loading instructions updated from "read all" to per-stage requires-based loading. Per-stage read/write contracts added. Apply dispatch scoped. Finalize auto-dispatch passes capability list.

### Removed Capabilities

(none — test-generation is modified, not removed)

### Consolidation Check

1. **Existing specs reviewed**: artifact-pipeline, quality-gates, test-generation, documentation, workflow-contract, change-workspace, constitution-management, human-approval-gate, project-init, release-workflow, review-lifecycle, roadmap-tracking, spec-format, task-implementation, three-layer-architecture
2. **Overlap assessment**: No new capabilities proposed. All changes modify existing specs. `artifact-pipeline` is the primary target (pipeline definition). `workflow-contract` covers router behavior. `test-generation` covers test artifacts. `documentation` covers finalize/ADR/capability-doc generation. `quality-gates` covers preflight and audit.
3. **Merge assessment**: N/A — no new specs proposed.

## Impact

- **Templates modified**: 5 change templates (proposal, design, tasks, audit + research/tests deleted), 2 doc templates (adr, capability), 1 workflow template
- **Specs modified**: 5 specs (artifact-pipeline, quality-gates, test-generation, documentation, workflow-contract)
- **Router modified**: SKILL.md context-loading for propose, apply, finalize dispatches
- **New file**: `.claudeignore`
- **Deleted templates**: `research.md`, `tests.md` (from `src/templates/changes/` and `.specshift/templates/changes/`)
- **Compilation**: `scripts/compile-skills.sh` must pass with all template-version bumps

## Scope & Boundaries

**In scope:**
- Pipeline stage reduction (8→6) with template restructuring
- Per-stage context contracts in SKILL.md and template instructions
- `.claudeignore` for historical change isolation
- Finalize scoping (capability list passthrough, conditional ADRs)
- ADR format streamlining
- Design Non-Goals instruction refinement
- Apply-phase test generation guidance
- Backward compatibility for old changes with `research.md`/`tests.md`

**Out of scope:**
- Named pipeline profiles (lite/full) — Design is already conditional, sufficient flexibility
- Sub-agent execution infrastructure — contracts enable it, but actual sub-agent dispatching is a separate change
- Historical change migration — old changes keep their artifact structure unchanged
- Spec format changes — specs themselves (docs/specs/) keep their current structure
- Constitution changes beyond Testing section acknowledgment
- Plan Mode instruction changes in CLAUDE.md — may follow as a separate enhancement
