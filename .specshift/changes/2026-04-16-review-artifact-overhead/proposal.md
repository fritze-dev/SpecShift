<!--
---
status: review
branch: claude/merge-main-specshift-pr43-t5XZH
capabilities:
  new: []
  modified: [artifact-pipeline, quality-gates, test-generation, documentation, workflow-contract]
  removed: []
---
-->
## Why

The SpecShift artifact pipeline is not yet executable in bounded sub-agent contexts. Two compounding factors block this: (1) the router instructs every pipeline stage to "read all change artifacts", causing quadratic context growth across eight stages, and (2) the pipeline contains stages whose value is structural rather than artifact-producing (research duplicates proposal-stage discovery; tests reformat Gherkin scenarios already in specs). Reducing the pipeline to six stages, declaring per-stage `requires:` context contracts, and extending the proven review-self-check sub-agent pattern to apply, finalize, and propose-internal stages unlocks sub-agent execution while keeping the workflow target-agnostic across Claude Code and Codex.

## What Changes

- **Pipeline reduced from 8 to 6 stages**: `[proposal, specs, design, preflight, tasks, audit]`. Research merges into Proposal as a fixed Discovery block. Tests is eliminated — automated test generation moves to the apply phase, driven by Constitution § Testing.
- **Proposal template restructured**: Gains Discovery sections (Current State, Approaches, Coverage Assessment, Decisions) absorbed from research. `requires: []` (no upstream dependency). Discovery is always present, not optional. Template-version 3 → 4 (per the template-version-discipline rule and PR #60's prior bump).
- **Per-stage context contracts**: SKILL.md propose dispatch changes from "read all change artifacts" to per-stage `requires:`-based loading. Each Smart Template's frontmatter declares the precise read/write inputs/outputs, replacing implicit "read all". Apply dispatch reads only proposal (capabilities), design (architecture, metrics), tasks, and specs.
- **Sub-agent dispatch for pipeline stages**: Extend the proven review-self-check sub-agent pattern (introduced in PR #60) to apply, finalize, and propose-internal stage generation. SKILL.md describes the dispatch pattern in tool-agnostic terms: spawn a sub-agent whose prompt invokes the workflow skill on the relevant artifact context. Each stage executes inside the sub-agent boundary using its declared `requires:` contract.
- **Design Non-Goals instruction refined**: Non-Goals contain only technical capability-limitations that emerged during design, not copy-pasted Proposal Out-of-scope items. Design instruction references Proposal § Scope for change-level boundaries.
- **Tasks template updated**: `requires: [preflight]` (was `[tests]`). Gains apply-phase test guidance for projects with configured test frameworks. Conditional Validation Notes section when design is skipped. Template-version 5 → 6 (PR #60 already bumped to 5; semantic-heading discipline preserved).
- **Audit template updated**: References updated from preflight.md → design.md § Validation (when preflight absent), tests.md → specs (direct scenario verification).
- **Finalize scoped**: Auto-dispatch passes capability list from proposal frontmatter. Only affected capabilities regenerated. ADR generation conditional on `has_decisions: true` in design.md frontmatter.
- **ADR template streamlined**: Context minimum reduced from 4-6 to 2-6 sentences. Consequences section optional for straightforward decisions.
- **Capability doc template updated**: Enrichment source changed from `research.md` to `proposal.md § Discovery`.
- **quality-gates.md cleanup**: Replace positional task-step references (`tasks.md step 3.2`, `step 3.5`) with semantic anchors per PR #60's heading discipline.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `artifact-pipeline`: "Eight-Stage Pipeline" requirement rewritten as "Six-Stage Pipeline". Pipeline array, stage descriptions, dependency chain, and post-artifact commit logic updated. Research and tests templates removed from the pipeline definition.
- `quality-gates`: Preflight requirement updated for the case where design is skipped (preflight also skipped, tasks gets a Validation Notes section). Audit verification dimensions updated — references to tests.md and preflight.md adapted. Positional task-step references replaced with semantic anchors.
- `test-generation`: Rewritten from "separate pipeline stage producing tests.md" to "apply-phase test generation driven by Constitution § Testing". Manual test checklists removed. Automated test generation becomes part of implementation tasks.
- `documentation`: Capability doc enrichment source updated from `research.md + design.md` to `proposal.md § Discovery + design.md`. ADR generation made conditional on `has_decisions` frontmatter. ADR format streamlined. Finalize scoped to affected capabilities via proposal frontmatter.
- `workflow-contract`: Router context-loading instructions updated from "read all" to per-stage `requires:`-based loading. Per-stage read/write contracts added. Apply dispatch scoped. Finalize auto-dispatch passes capability list. Sub-agent dispatch pattern documented in tool-agnostic language for apply, finalize, and propose-internal stage generation.

### Removed Capabilities

(none — test-generation is modified, not removed)

### Consolidation Check

1. **Existing specs reviewed**: artifact-pipeline, quality-gates, test-generation, documentation, workflow-contract, change-workspace, constitution-management, human-approval-gate, project-init, release-workflow, review-lifecycle, roadmap-tracking, spec-format, task-implementation, three-layer-architecture
2. **Overlap assessment**: No new capabilities proposed. All changes modify existing specs. `artifact-pipeline` is the primary target (pipeline definition). `workflow-contract` covers router behavior including the new sub-agent dispatch pattern. `test-generation` covers test artifacts. `documentation` covers finalize/ADR/capability-doc generation. `quality-gates` covers preflight and audit.
3. **Merge assessment**: N/A — no new specs proposed.

## Impact

- **Templates modified**: 5 change templates (proposal v3→v4, design, tasks v5→v6, audit + research/tests deleted), 2 doc templates (adr, capability), 1 workflow template
- **Specs modified**: 5 specs (artifact-pipeline, quality-gates, test-generation, documentation, workflow-contract)
- **Router modified**: SKILL.md context-loading and sub-agent dispatch for propose, apply, finalize
- **Deleted templates**: `research.md`, `tests.md` (from `src/templates/changes/` and `.specshift/templates/changes/`)
- **Compilation**: `scripts/compile-skills.sh` must pass with all template-version bumps; `.specshift/WORKFLOW.md` mirrors `src/templates/workflow.md`

## Scope & Boundaries

**In scope:**
- Pipeline stage reduction (8→6) with template restructuring
- Per-stage context contracts in SKILL.md and template instructions
- Sub-agent dispatch for apply, finalize, and propose-internal stage generation (extends the PR #60 review-self-check pattern)
- Apply dispatch scoped (read only proposal+design+tasks+specs)
- Finalize scoping (capability list passthrough, conditional ADRs)
- ADR format streamlining
- Design Non-Goals instruction refinement
- Apply-phase test generation guidance via Constitution § Testing
- quality-gates.md positional-reference cleanup (PR #60 semantic-heading compliance)
- Backward compatibility for old changes containing `research.md`/`tests.md`

**Out of scope:**
- `.claudeignore` / `.codexignore` agent-index excludes — target-specific, asymmetric across Claude Code and Codex, would violate the agnostic-skill principle, and are speculative without a concrete sub-agent dispatch implementation
- Historical change migration — old changes keep their artifact structure unchanged
- Spec format changes — `docs/specs/` files keep their current `## Purpose` + `## Requirements` structure
- Constitution rewrites beyond the Testing-section acknowledgment driving apply-phase tests
- Named pipeline profiles (lite/full) — Design is already conditional, sufficient flexibility
- Plan-mode instruction changes in AGENTS.md / CLAUDE.md — separate enhancement, unrelated to pipeline architecture
