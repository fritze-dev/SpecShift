# Research: Review Artifact Pipeline Overhead

## Current State

### Pipeline Architecture

The eight-stage artifact pipeline (`research → proposal → specs → design → preflight → tests → tasks → audit`) is defined in `.specshift/WORKFLOW.md` frontmatter and driven by Smart Templates in `.specshift/templates/changes/`. Each template declares `requires: [<dependencies>]` in YAML frontmatter, but the router does not read those declarations — it instructs every stage to "read all change artifacts".

The compiled router lives at `src/skills/specshift/SKILL.md` (source) and `skills/specshift/SKILL.md` (compiled, shared release). The pipeline definitions live in `src/templates/workflow.md` and `.specshift/WORKFLOW.md`. PR #46 (Multi-Target Distribution) introduced the `src/` source layout and the shared `./skills/specshift/` release tree consumed by both Claude Code and Codex.

### Sub-Agent Dispatch — Proven Precedent

PR #60 (Workflow/Spec-Hygiene Bundle) introduced sub-agent dispatch for the review self-check step. The review action's `### Instruction` documents the canonical pattern:

> spawn a subagent whose prompt invokes the `review` skill on the current HEAD — the subagent boundary provides context isolation.

This pattern works reliably and is the model the present change extends to apply, finalize, and propose-internal stage generation. The pattern's two requirements are: (1) the dispatching skill describes spawning intent in tool-agnostic language (no `Agent(...)` calls in templates), and (2) each stage's read inputs are declared explicitly via `requires:` so the sub-agent can load bounded context.

### Token Consumption Drivers

Three compounding factors consume context unnecessarily:

1. **Quadratic context growth**: `src/skills/specshift/SKILL.md` (propose dispatch) instructs "Read all change artifacts (if change exists)" — every pipeline stage re-reads ALL prior artifacts, not just its declared `requires` dependencies. With eight stages, this creates cumulative artifact reads even though `requires:` chains are already declared in the templates.

2. **Finalize scope**: The finalize action scans `.specshift/changes/` to find enrichment data for capability docs and ADRs. The directory now contains 85 historical changes / 4.1MB. Only the just-completed change is needed — capability list from proposal frontmatter would scope this naturally.

3. **Redundant artifact stages**: Research duplicates the discovery work that happens during proposal-stage planning. Tests reformats Gherkin scenarios already in specs. Both stages add context loads without adding new information.

### Multi-Target Consequence (post PR #46)

The compiled `./skills/specshift/` tree is shared between Claude Code and Codex. Any change to context-loading instructions, sub-agent dispatch language, or template restructuring affects both targets. Tool-specific paths and product names must remain in target-scoped paragraphs only — agnostic phrasing is required throughout SKILL.md and template instructions.

### PR #60 Compliance Requirements

PR #60 enforced semantic-heading discipline: positional references (`step 3.2`, `step 3.5`) and numeric headings (`## 1.`, `## 2.`) are disallowed. The current quality-gates.md still contains positional task-step references that this change must clean up while restructuring audit-template references.

### Key Files Affected

| File | Role | Change Type |
|------|------|-------------|
| `src/skills/specshift/SKILL.md` | Router — context loading, dispatch | Per-stage `requires:`-based loading; sub-agent dispatch pattern |
| `src/templates/workflow.md` | Pipeline array, action instructions | Update pipeline (8→6); update propose/apply/finalize instructions |
| `src/templates/changes/proposal.md` | Proposal template | Merge research sections; bump v3 → v4 |
| `src/templates/changes/research.md` | Research template | Delete |
| `src/templates/changes/tests.md` | Tests template | Delete |
| `src/templates/changes/design.md` | Design template | Refine Non-Goals instruction; bump version |
| `src/templates/changes/tasks.md` | Tasks template | Update `requires:`, add apply-phase test guidance, conditional Validation Notes; bump v5 → v6 |
| `src/templates/changes/audit.md` | Audit template | Update references for removed artifacts |
| `src/templates/docs/adr.md` | ADR template | Streamline format |
| `src/templates/docs/capability.md` | Capability doc template | Update enrichment source |
| `.specshift/WORKFLOW.md` | Project-instance pipeline config | Mirror template changes |
| `.specshift/templates/changes/*` | Project-instance templates | Mirror template changes + deletions |
| `docs/specs/artifact-pipeline.md` | Pipeline spec | Eight-Stage → Six-Stage Pipeline |
| `docs/specs/quality-gates.md` | Quality gates spec | Update preflight/audit references; replace positional refs with semantic anchors |
| `docs/specs/test-generation.md` | Test generation spec | Rewrite for apply-phase integration |
| `docs/specs/documentation.md` | Documentation spec | Update enrichment source; conditional ADRs; finalize scoping |
| `docs/specs/workflow-contract.md` | Workflow contract spec | Per-stage context contracts; sub-agent dispatch pattern |

### Existing Spec Coverage

- `artifact-pipeline`: defines the eight-stage pipeline, post-artifact commits, WORKFLOW.md ownership — **primary target**
- `quality-gates`: preflight quality check, audit verification — **update references; clean positional refs**
- `test-generation`: tests from Gherkin scenarios — **rewrite for apply-phase**
- `documentation`: capability docs, ADRs, README generation — **conditional ADR, scoped enrichment**
- `workflow-contract`: WORKFLOW.md format, Smart Template format, router dispatch — **per-stage context contracts, sub-agent dispatch**

### Evidence from Real Artifacts

- 85 completed changes, 4.1MB total in `.specshift/changes/`
- Typical change spans 7 artifacts with significant overlap between research and proposal
- 25 tests.md files exist across historical changes — all manual-only mode (SpecShift has no test framework). Content reformats Gherkin scenarios from specs without adding information
- A sample of preflights showed 11/77 with WARNINGS or BLOCKED verdicts identifying genuine pre-implementation findings (constitution inconsistencies, assumption verification gaps, spec consolidation issues) — preflight earns its keep
- Design Non-Goals are typically 3-4 of 5 items copy-pasted from Proposal Out-of-scope

## External Research

N/A — all changes are internal to the SpecShift plugin architecture. No external dependencies.

## Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: 6-stage pipeline + per-stage contracts + sub-agent dispatch (selected)** | Preserves all quality gates with evidence-based value; Discovery stays as fixed block in Proposal; test generation moves to apply where it belongs; sub-agent dispatch unlocks bounded execution | Substantial template restructuring; modifies five specs; self-referential change |
| B: 5-stage pipeline — also merge Preflight into Design | One fewer stage | Loses pre-implementation validation quality (11/77 preflights found real issues); merging validation into the same "design" mental frame reduces finding quality |
| C: 3-stage pipeline | Maximum simplification; fewest context loads | Eliminates Specs (source of truth), Design (architecture decisions/ADRs), and Preflight (quality gate); too aggressive |
| D: Keep 8 stages, only fix context loading | No template restructuring risk; backward compatible | Doesn't address redundant artifacts (tests.md is reformatted specs, research/proposal overlap); misses opportunity |
| E: Add `.claudeignore` for historical changes | Token reduction at session-index level; quick win | Target-specific (no Codex equivalent), asymmetric, speculative without sub-agent infrastructure — declined as out of scope |

### Additional Optimizations (orthogonal to pipeline count)

| Optimization | Pro | Contra |
|-------------|-----|--------|
| SKILL.md `requires:`-based loading | Each stage reads only declared dependencies; sub-agent ready | Requires precise per-stage context contracts |
| Sub-agent dispatch for apply/finalize/propose-internal stages | Bounded context per stage; proven pattern from PR #60 review self-check | New dispatch language in SKILL.md; each stage must declare context contract |
| Finalize scoped to affected capabilities | ~90% less change-directory scanning | Requires auto-dispatch to pass capability list |
| ADR generation conditional on `has_decisions` | Skips most finalize ADR work | Minor instruction change |
| Design Non-Goals → only technical delta | Better capability docs (no change-level scope as "Known Limitations") | Instruction refinement in design template |

## Risks & Constraints

- **Template restructuring**: Merging research into proposal changes the template structure. Existing changes with separate `research.md` need backward compatibility in finalize enrichment.
- **Checkpoint/resume for in-progress changes**: Changes started with the old eight-stage pipeline need graceful handling. The router should treat `research.md` existence as "proposal stage in progress" for legacy changes (currently no in-flight changes — risk is theoretical but should be guarded).
- **Compilation validation**: `scripts/compile-skills.sh` enforces template-version bumps. All modified templates need version increments. Proposal v3 → v4, tasks v5 → v6 (PR #60 already bumped these to v3/v5).
- **Self-referential change**: This change modifies the pipeline that will be used to implement it. The first run still uses the old pipeline; changes take effect after merge.
- **Preflight depends on design**: When design is conditional (skipped for simple changes), preflight is also skipped. Tasks gets a Validation Notes section instead.
- **Multi-target agnostic discipline**: SKILL.md and template language must avoid Claude-Code-only or Codex-only assumptions. Sub-agent dispatch is described as intent ("spawn a sub-agent"), not as specific tool calls.
- **PR #60 semantic-heading rule**: All template restructures and new spec sections must use semantic headings. Positional references (`step 3.2`) are disallowed.

## Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Six-stage pipeline, per-stage context contracts, sub-agent dispatch, finalize scoping, ADR streamlining, quality-gates cleanup |
| Behavior | Clear | Each stage's read/write contract defined; pipeline traversal, apply, finalize flows mapped; sub-agent dispatch pattern explicit |
| Data Model | Clear | WORKFLOW.md pipeline array; template frontmatter `requires:` chains; proposal frontmatter `capabilities:` for finalize scoping |
| UX | Clear | No user-facing command changes; same `specshift propose/apply/finalize/review` flow |
| Integration | Clear | Compilation enforces template versions; finalize auto-dispatch passes capabilities; sub-agent dispatch applies to both Claude Code and Codex |
| Edge Cases | Clear | Backward compat for legacy changes; design-skipped validation; framework vs no-framework testing; no in-flight changes currently |
| Constraints | Clear | Self-referential change; template-version discipline; router immutability; agnostic-skill principle |
| Terminology | Clear | "Discovery" (merged research section), "Validation Notes" (in tasks when no design), "context contract" (per-stage `requires:`), "sub-agent dispatch" (PR #60 pattern) |
| Non-Functional | Clear | Token reduction is a consequence, not the primary goal; no performance regression; multi-target compatible |

## Open Questions

All categories are Clear — no open questions. Scope was confirmed in plan-mode discussion, with `.claudeignore` items dropped and sub-agent dispatch added.

## Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Six-stage pipeline `[proposal, specs, design, preflight, tasks, audit]` | Preserves Specs (source of truth), Design (ADR source), and Preflight (evidence-based quality value) while eliminating redundant stages | 5 stages (loses preflight quality), 3 stages (too aggressive, loses specs), 8 stages (doesn't reduce overhead) |
| 2 | Research merged into Proposal as fixed Discovery block | Discovery (Approaches, Coverage Assessment, Decisions) always present — preserves historical value. Plan Mode accelerates but does not replace it | Keep research separate (redundant context load, no perspective change) |
| 3 | Tests eliminated, test generation moves to apply phase | Manual checklists were never used (just reformatted Gherkin). Automated tests are code — belong in implementation. Constitution § Testing drives framework behavior | Merge into tasks (makes tasks too long), keep as separate stage (overhead for reformatted content) |
| 4 | Preflight kept as separate stage | 11/77 preflights found real issues: constitution inconsistencies, assumption gaps, consolidation problems. Separate validation frame produces findings design alone misses | Merge into design (loses "fresh validator" effect, evidence showed separate step catches more) |
| 5 | Design Non-Goals: only new technical capability-limitations | 3-4 of 5 Non-Goals are copy-paste from Proposal Out-of-scope. Separating change-boundaries (Proposal) from capability-limitations (Design) improves downstream Known Limitations in capability docs | Keep full duplication (redundant, pollutes capability docs with change-level scope) |
| 6 | Per-stage context contracts via `requires:` | SKILL.md "read all" causes quadratic growth. Each stage declares exactly what to read — enables focused sub-agent execution | Keep "read all" (simpler but wasteful); declare contracts only in templates without router enforcement (router still loads everything) |
| 7 | Sub-agent dispatch for apply, finalize, and propose-internal stages | PR #60's review-self-check sub-agent pattern is proven. Extending it to other stages closes the loop on bounded execution. Token reduction is a consequence, not the goal | Keep dispatch only at review (loses bounded context for the rest of the pipeline); build a custom sub-agent infrastructure (over-engineered when an existing pattern works) |
| 8 | Drop `.claudeignore` from scope | Target-specific (Codex has no equivalent), violates agnostic-skill principle, speculative without concrete sub-agent dispatch implementation | Add `.claudeignore` only (asymmetric); add `.claudeignore` and `.codexignore` (target-specific syntax in agnostic skill) |
| 9 | Finalize scoped to affected capabilities + conditional ADRs | Auto-dispatch passes capability list; ADR generation gated on `has_decisions`. Eliminates scanning 85 directories | Full scan every time (current behavior, wasteful) |
| 10 | ADR format streamlining | Context 2-6 sentences (was 4-6 minimum). Optional consequences for simple decisions | Keep verbose format (unnecessary for straightforward decisions) |
| 11 | quality-gates.md positional-reference cleanup | PR #60 enforces semantic headings; the spec still has `step 3.2`/`step 3.5` references. Cleaning these in the same change keeps the audit-template restructure coherent | Defer to a separate change (extra PR for trivially related cleanup) |
