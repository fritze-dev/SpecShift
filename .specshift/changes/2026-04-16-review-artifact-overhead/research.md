# Research: Review Artifact Pipeline Overhead

## 1. Current State

### Pipeline Architecture
The 8-stage artifact pipeline (`research → proposal → specs → design → preflight → tests → tasks → audit`) is defined in `.specshift/WORKFLOW.md` frontmatter and driven by Smart Templates in `.specshift/templates/changes/`. Each template declares `requires: [<dependencies>]` in YAML frontmatter.

### Token Consumption Problem (Issue #15)
Three compounding factors cause excessive LLM token consumption:

1. **Quadratic context growth**: `SKILL.md:66` (propose dispatch) says "Read all change artifacts (if change exists)" — every pipeline stage re-reads ALL prior artifacts, not just its declared `requires` dependencies. With 8 stages, this creates 28 cumulative artifact reads.

2. **Finalize reads everything**: The finalize action scans all 80 historical change directories (2.8MB total in `.specshift/changes/`) to find enrichment data for capability docs and ADRs. Even with incremental mode, the initial scan reads all 80 proposal.md files.

3. **No `.claudeignore`**: No file exists. Claude indexes all 80 change directories at session start, adding ~2.8MB to the baseline context.

### Key Files Affected
| File | Role | Change Type |
|------|------|-------------|
| `src/skills/specshift/SKILL.md` | Router — context loading, auto-dispatch | Modify context-loading instructions |
| `src/templates/workflow.md` | Pipeline array, action instructions | Update pipeline, propose/apply/finalize instructions |
| `src/templates/changes/proposal.md` | Proposal template | Merge research sections, bump version |
| `src/templates/changes/research.md` | Research template | Delete |
| `src/templates/changes/tests.md` | Tests template | Delete |
| `src/templates/changes/design.md` | Design template | Refine Non-Goals instruction, bump version |
| `src/templates/changes/tasks.md` | Tasks template | Update requires, add test guidance, bump version |
| `src/templates/changes/audit.md` | Audit template | Update references to removed artifacts |
| `src/templates/docs/adr.md` | ADR template | Streamline format, bump version |
| `src/templates/docs/capability.md` | Capability doc template | Update enrichment source references |
| `.specshift/WORKFLOW.md` | Project-instance pipeline config | Mirror template changes |
| `.specshift/templates/changes/*` | Project-instance templates | Mirror template changes + deletions |
| `docs/specs/artifact-pipeline.md` | Pipeline spec | 8→6 stages |
| `docs/specs/quality-gates.md` | Quality gates spec | Update preflight references |
| `docs/specs/test-generation.md` | Test generation spec | Rewrite for apply-phase integration |
| `docs/specs/documentation.md` | Documentation spec | Update enrichment source, conditional ADRs |
| `.claudeignore` | Agent index exclusion | Create new |

### Existing Spec Coverage
- `artifact-pipeline` (order: 4): Defines 8-stage pipeline, post-artifact commits, WORKFLOW.md ownership — **primary target**
- `quality-gates` (order: 8): Preflight quality check, audit verification — **update references**
- `test-generation` (order: 12): Tests from Gherkin scenarios — **rewrite for apply-phase**
- `documentation` (order: 7): Capability docs, ADRs, README generation — **conditional ADR, scoped enrichment**
- `workflow-contract` (order: 5): WORKFLOW.md format, Smart Template format, router dispatch — **update context loading**

### Evidence from Real Artifacts
- **80 completed changes**, 2.8MB total in `.specshift/changes/`
- **Typical change** (fix-review-friction): 411 lines across 7 artifacts (research: 64, proposal: 62, design: 55, preflight: 56, tests: 51, tasks: 42, audit: 81)
- **All 21 tests.md files**: Manual-only mode (SpecShift has no test framework). Content is reformatted Gherkin scenarios from specs — no new information.
- **11 of 77 preflights** had WARNINGS or BLOCKED verdicts with genuine pre-implementation findings (constitution inconsistencies, assumption verification gaps, spec consolidation issues)
- **Design Non-Goals**: 3-4 of 5 items typically copy-pasted from Proposal Out-of-scope

## 2. External Research

N/A — all changes are internal to the SpecShift plugin architecture. No external dependencies.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: 6-stage pipeline (selected)** — merge Research→Proposal, eliminate Tests, keep Preflight | Preserves all quality gates with evidence-based value; Discovery stays as fixed block in Proposal; test generation moves to apply where it belongs | Still 6 stages (not 3 as issue suggested); requires template restructuring |
| B: 5-stage pipeline — also merge Preflight→Design | One fewer stage; simpler pipeline | Loses pre-implementation validation quality (11/77 preflights found real issues); merging validation into the same "design" mental frame reduces finding quality |
| C: 3-stage pipeline (as Issue suggests) | Maximum simplification; fewest context loads | Eliminates Specs (source of truth for traceability), Design (architecture decisions/ADRs), and Preflight (quality gate); too aggressive per user confirmation |
| D: Keep 8 stages, only fix context loading | No template restructuring risk; backward compatible | Doesn't address redundant artifacts (tests.md is reformatted specs, research→proposal overlap); misses opportunity to reduce stage count |

### Additional Optimizations (orthogonal to pipeline count)
| Optimization | Pro | Contra |
|-------------|-----|--------|
| `.claudeignore` for historical changes | Immediate ~2.8MB index reduction; zero risk | Active change must be read explicitly by path |
| SKILL.md requires-based loading | Each stage reads only declared dependencies; sub-agent ready | Requires precise per-stage context contracts |
| Finalize scoped to affected capabilities | ~90% less change-directory scanning | Requires auto-dispatch to pass capability list |
| ADR generation conditional on `has_decisions` | Skips most finalize ADR work | Minor instruction change |
| Design Non-Goals → only technical delta | Better capability docs (no change-level scope as "Known Limitations") | Instruction refinement in design template |
| Precise per-stage read/write contracts | Enables future sub-agent execution per stage | More detailed template instructions |

## 4. Risks & Constraints

- **Template restructuring**: Merging research into proposal changes the template structure. Existing changes with separate `research.md` need backward compatibility in finalize enrichment.
- **Checkpoint/resume for in-progress changes**: Changes started with the old 8-stage pipeline need graceful handling. The router should treat `research.md` existence as "proposal stage in progress" for legacy changes.
- **Compilation validation**: `scripts/compile-skills.sh` enforces template-version bumps. All modified templates need version increments.
- **Self-referential change**: This change modifies the pipeline that will be used to implement it. The first run still uses the old pipeline; changes take effect after merge.
- **Preflight depends on design**: When design is conditional (skipped for simple changes), preflight is also skipped. Tasks gets a minimal Validation Notes section instead.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 6-stage pipeline, context isolation, finalize optimization, ADR streamlining |
| Behavior | Clear | Each stage's read/write contract defined; pipeline traversal, apply, finalize flows mapped |
| Data Model | Clear | WORKFLOW.md pipeline array change; template frontmatter updates; .claudeignore creation |
| UX | Clear | No user-facing command changes; same `specshift propose/apply/finalize` flow |
| Integration | Clear | Compilation enforces template versions; finalize auto-dispatch passes capabilities |
| Edge Cases | Clear | Backward compat for old changes; design-skipped validation; framework vs no-framework testing |
| Constraints | Clear | Self-referential change; template-version discipline; router immutability |
| Terminology | Clear | "Discovery" (merged research section), "Validation" (in tasks when no design), "context contract" (per-stage read/write) |
| Non-Functional | Clear | ~60-70% token reduction estimated; no performance regression |

## 6. Open Questions

All categories are Clear — no open questions. All decisions were made during the detailed planning discussion with the user.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | 6-stage pipeline `[proposal, specs, design, preflight, tasks, audit]` | Preserves Specs (source of truth), Design (ADR source), and Preflight (evidence-based quality value) while eliminating redundant stages | 5 stages (loses preflight quality), 3 stages (too aggressive, loses specs), 8 stages (doesn't reduce overhead) |
| 2 | Research merged into Proposal as fixed Discovery block | Discovery (Approaches, Coverage Assessment, Decisions) always present — preserves historical value. Plan Mode accelerates but doesn't replace it | Keep research separate (redundant context load, no perspective change) |
| 3 | Tests eliminated, test generation moves to apply phase | Manual checklists were never used (just reformatted Gherkin). Automated tests are code — belong in implementation. Constitution § Testing drives framework behavior | Merge into tasks (makes tasks too long), keep as separate stage (overhead for reformatted content) |
| 4 | Preflight kept as separate stage | 11/77 preflights found real issues: constitution inconsistencies, assumption gaps, consolidation problems. Separate validation frame produces findings design alone misses | Merge into design (loses "fresh validator" effect, evidence showed separate step catches more) |
| 5 | Design Non-Goals: only new technical capability-limitations | 3-4 of 5 Non-Goals are copy-paste from Proposal Out-of-scope. Separating change-boundaries (Proposal) from capability-limitations (Design) improves downstream Known Limitations in capability docs | Keep full duplication (redundant, pollutes capability docs with change-level scope) |
| 6 | Per-stage context contracts (sub-agent ready) | SKILL.md "read all" causes quadratic growth. Each stage declares exactly what to read — enables focused sub-agent execution | Keep "read all" (simpler but wasteful) |
| 7 | `.claudeignore` for `.specshift/changes/` | 2.8MB of 80 historical changes indexed unnecessarily. Workflow reads active change explicitly by path | No ignore (continues indexing everything) |
| 8 | Finalize scoped to affected capabilities + conditional ADRs | Auto-dispatch passes capability list; ADR generation gated on `has_decisions`. Eliminates scanning 80 directories | Full scan every time (current behavior, wasteful) |
| 9 | ADR format streamlining | Context 2-6 sentences (was 4-6 minimum). Optional consequences for simple decisions | Keep verbose format (unnecessary for straightforward decisions) |
