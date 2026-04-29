# Tests: Review Artifact Pipeline Overhead

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) — per Constitution § Testing |
| Test directory | (none) |
| File pattern | (none) |

> Note: this change itself eliminates the `tests` pipeline stage. Going forward, scenario verification happens directly in `audit.md` (per the modified `test-generation` spec). This tests.md artifact lists the NEW or MODIFIED Gherkin scenarios introduced by this change so they can be verified manually during apply/audit.

## Manual Test Plan

### artifact-pipeline

#### Six-Stage Pipeline

- [ ] **Scenario: Pipeline stages execute in dependency order**
  - Setup: a new change workspace with no artifacts generated
  - Action: the user progresses through the pipeline
  - Verify: the system enforces order proposal → specs → design → preflight → tasks → audit
- [ ] **Scenario: Skipping a stage is prevented**
  - Setup: a workspace with only proposal.md generated
  - Action: an agent attempts to generate design (skipping specs)
  - Verify: the attempt is rejected with a message that specs must be completed first
- [ ] **Scenario: All stages produce verifiable artifacts**
  - Setup: a completed pipeline run
  - Action: inspect the change workspace
  - Verify: it contains proposal.md, one or more docs/specs/<capability>.md files, design.md, preflight.md, tasks.md, audit.md (no research.md, no tests.md for new changes)
- [ ] **Scenario: Legacy change retains old artifacts**
  - Setup: a completed change directory created under the previous eight-stage pipeline containing both research.md and tests.md
  - Action: downstream tooling reads the change for enrichment
  - Verify: tooling accepts the legacy shape and uses research.md as the discovery source without requiring migration

### quality-gates

#### Pre-Implementation Side-Effect Cross-Check (renamed from Preflight Side-Effect Cross-Check)

- [ ] **Scenario: Cross-check uses design.md § Validation when preflight present**
  - Setup: a change with both design.md and preflight.md
  - Action: audit runs the pre-implementation side-effect cross-check
  - Verify: it reads from preflight.md as the primary source
- [ ] **Scenario: Cross-check falls back to tasks.md § Validation Notes when preflight absent**
  - Setup: a simple change where design (and therefore preflight) was skipped; tasks.md contains a Validation Notes section
  - Action: audit runs the pre-implementation side-effect cross-check
  - Verify: it reads from tasks.md § Validation Notes

#### Audit verification dimensions (Testing dimension reworded)

- [ ] **Scenario: Test coverage verified against specs (with framework)**
  - Setup: a change applied with apply-phase generated tests in the framework directory
  - Action: audit's testing dimension runs
  - Verify: each Gherkin scenario from the affected specs maps to either a generated test file or a verified-via-spec note; no reference to tests.md
- [ ] **Scenario: Scenario coverage verified against specs (no framework)**
  - Setup: a framework-less project (Constitution § Testing = None) with completed apply
  - Action: audit's testing dimension runs
  - Verify: every scenario in the affected specs is marked verified or flagged as missed; no tests.md reference

### test-generation

#### Apply-Phase Automated Test Generation

- [ ] **Scenario: Framework configured triggers automated test generation in apply**
  - Setup: Constitution § Testing declares a framework (e.g., Vitest in `tests/`)
  - Action: apply runs implementation tasks
  - Verify: automated test stubs are produced in the configured directory, mapped GIVEN→arrange / WHEN→act / THEN→assert, with traceability comments

#### Scenario Verification Without a Framework

- [ ] **Scenario: No framework configured — verification via audit**
  - Setup: Constitution § Testing = None (or absent)
  - Action: apply runs implementation, then audit runs
  - Verify: each Gherkin scenario from affected specs is verified directly in audit.md; no manual checklist or tests.md is produced

#### Backward Compatibility With Legacy tests.md

- [ ] **Scenario: Legacy change tests.md preserved**
  - Setup: a historical change directory containing tests.md
  - Action: downstream tooling reads the change
  - Verify: tooling tolerates the legacy file without rewriting it; new changes do not produce tests.md

### documentation

#### Capability Doc Enrichment Source

- [ ] **Scenario: Enrichment uses proposal.md § Discovery + design.md**
  - Setup: a change with proposal.md (containing § Discovery), design.md, preflight.md (no research.md)
  - Action: finalize regenerates the affected capability doc
  - Verify: the capability doc is enriched from proposal.md § Discovery and design.md; no reference to research.md
- [ ] **Scenario: Legacy enrichment tolerated**
  - Setup: a legacy change with research.md (no § Discovery in proposal)
  - Action: finalize regenerates the capability doc
  - Verify: tooling falls back to research.md as the discovery source

#### ADR Generation Conditional on has_decisions

- [ ] **Scenario: design.md has_decisions: true triggers ADR generation**
  - Setup: a change whose design.md frontmatter declares has_decisions: true
  - Action: finalize runs
  - Verify: an ADR file is generated under docs/decisions/
- [ ] **Scenario: design.md has_decisions: false skips ADR**
  - Setup: a change whose design.md frontmatter declares has_decisions: false (or absent)
  - Action: finalize runs
  - Verify: no ADR is generated; capability doc still updates

#### ADR Format Streamlined

- [ ] **Scenario: ADR Context can be 2 sentences for straightforward decisions**
  - Setup: a design decision with a clear, simple rationale
  - Action: finalize generates the ADR
  - Verify: Context section has at least 2 sentences (was 4-6); validation does not flag the shorter form
- [ ] **Scenario: ADR Consequences section is optional**
  - Setup: a design decision whose consequences are obvious from Context
  - Action: finalize generates the ADR
  - Verify: ADR has no Consequences section; validation does not flag the omission

#### Auto-Dispatch Capability Scoping

- [ ] **Scenario: apply auto-dispatches finalize with capability list**
  - Setup: a change with proposal.md frontmatter `capabilities: { new: [foo], modified: [bar], removed: [] }`
  - Action: apply auto-dispatches finalize (auto_approve true)
  - Verify: finalize regenerates only foo and bar capability docs (plus any ADR if has_decisions); other 80+ historical capability docs are not touched

### workflow-contract

#### Per-Stage Context Contract

- [ ] **Scenario: Router loads only the requires: chain for the next stage**
  - Setup: pipeline traversal at the design stage
  - Action: router prepares context for design generation
  - Verify: router reads only proposal.md and the affected specs (design's requires: [specs] chain), not preflight/tasks/audit

#### Sub-Agent Dispatch for Pipeline Stages

- [ ] **Scenario: Router spawns sub-agent for apply phase**
  - Setup: a change ready for apply
  - Action: router elects to dispatch apply via sub-agent
  - Verify: sub-agent prompt includes action (apply), change id, apply contract reads (proposal, design, tasks, affected specs); sub-agent invokes the workflow skill on that bounded context
- [ ] **Scenario: Router spawns sub-agent for finalize phase with capability list**
  - Setup: apply auto-dispatches finalize with `capabilities: [foo, bar]`
  - Action: router prepares the finalize sub-agent prompt
  - Verify: prompt names finalize action, includes capability list, declares finalize contract reads (proposal, design, audit, listed specs)
- [ ] **Scenario: Router spawns sub-agent for propose-internal stage generation**
  - Setup: propose pipeline at the design stage
  - Action: router elects to generate design.md via sub-agent
  - Verify: sub-agent prompt includes design's requires: [proposal, specs] read inputs and generates: design.md write declaration

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios listed | 18 |
| Automated tests | 0 (manual-only mode per Constitution § Testing) |
| Manual test items | 18 |
| Preserved (@manual) | N/A |
| Edge case tests | covered inline (legacy-shape scenarios in artifact-pipeline, test-generation) |
| Warnings | 0 |
