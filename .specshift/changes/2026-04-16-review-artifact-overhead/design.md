<!--
---
has_decisions: true
---
-->
# Technical Design: Review Artifact Pipeline Overhead

## Context

The eight-stage artifact pipeline duplicates work (research overlaps with proposal-stage planning; tests reformat Gherkin scenarios already in specs) and the router instructs every stage to "read all change artifacts", which prevents bounded sub-agent execution. PR #60 introduced sub-agent dispatch for the review action's self-check; the same pattern is the model for closing the loop on the rest of the pipeline.

The change is self-referential — it modifies the pipeline that produced it. The first run uses the eight-stage pipeline; the new structure takes effect after merge. PR #46 (Multi-Target Distribution) means the compiled `./skills/specshift/` tree is shared between Claude Code and Codex, so all router and template language must be tool-agnostic.

## Architecture & Components

The change touches all three architectural layers (per CONSTITUTION § Architecture Rules).

### Layer 1 — Constitution
- No structural changes. The existing `## Testing` section already drives apply-phase test behavior; this change cites it explicitly in the new test-generation spec without altering the constitution's content.

### Layer 2 — WORKFLOW.md + Smart Templates
- `src/templates/workflow.md`
  - `pipeline:` array changes from `[research, proposal, specs, design, preflight, tests, tasks, audit]` to `[proposal, specs, design, preflight, tasks, audit]`.
  - `## Action: propose` instruction loses the design-checkpoint reference to research; gains explicit per-stage context-contract language.
  - `## Action: apply` instruction gains the apply-context-contract clause (read only proposal, design, tasks, affected specs).
  - `## Action: finalize` instruction gains the capability-list passthrough clause.
  - `template-version` bumped (current v13).
- `src/templates/changes/proposal.md`
  - Gains Discovery sections (Current State, External Research, Approaches, Coverage Assessment, Decisions) absorbed from research.md.
  - `requires: []` (was `[research]`).
  - `template-version` 3 → 4.
- `src/templates/changes/research.md` — **deleted**.
- `src/templates/changes/tests.md` — **deleted**.
- `src/templates/changes/design.md`
  - Instruction refined: Non-Goals contain only new technical capability-limitations; references Proposal § Scope for change-level boundaries.
  - `template-version` 1 → 2.
- `src/templates/changes/tasks.md`
  - `requires: [preflight]` (was `[tests]`).
  - Apply-phase test guidance section: when Constitution § Testing declares a framework, generate automated tests; when "None", verify Gherkin scenarios in audit.
  - `template-version` 5 → 6.
- `src/templates/changes/audit.md`
  - References updated: tests.md → "specs (direct scenario verification)".
  - `template-version` bumped.
- `src/templates/docs/adr.md`
  - Context length: 2-6 sentences (was 4-6).
  - Consequences section optional for straightforward decisions.
  - `template-version` bumped.
- `src/templates/docs/capability.md`
  - Enrichment-source language: `proposal.md § Discovery + design.md` (with backward-compat tolerance for legacy `research.md`).
  - `template-version` bumped.
- `.specshift/WORKFLOW.md` — mirrors `src/templates/workflow.md` (project override `review.request_review: copilot` preserved).
- `.specshift/templates/changes/*.md` — mirror `src/templates/changes/*.md` including the two deletions.
- `.specshift/templates/docs/*.md` — mirror `src/templates/docs/*.md`.

### Layer 3 — Router (SKILL.md)
- `src/skills/specshift/SKILL.md`
  - `### propose` dispatch: replace "Read all change artifacts (if change exists)" with "Read only the change artifacts named by the next stage's `requires:` chain".
  - `### apply` dispatch: read only proposal (capabilities), design (architecture, metrics), tasks, and the affected specs from `proposal.md` frontmatter `capabilities:` field.
  - `### finalize` dispatch: receive capability list from the dispatching action; read only proposal + design + audit + the listed specs.
  - New section `### Sub-Agent Dispatch`: documents the optional sub-agent dispatch pattern in tool-agnostic language. Applies to apply, finalize, and propose-internal stage generation. References the proven review-self-check pattern.

### Compilation
- `scripts/compile-skills.sh` requires no changes. Its existing template-version-bump enforcement validates that every modified template has incremented its `template-version` integer. Running the script regenerates `./skills/specshift/`.

## Goals & Success Metrics

Each metric is verified as PASS/FAIL during QA in audit.md.

| Metric | Threshold |
|---|---|
| `bash scripts/compile-skills.sh` exits 0 | PASS |
| All five modified specs have updated requirements (no stale references to research.md, tests.md, "Eight-Stage", `step 3.2`, `step 3.5`) | PASS |
| `.specshift/WORKFLOW.md` `pipeline:` array contains exactly `[proposal, specs, design, preflight, tasks, audit]` | PASS |
| `src/templates/changes/research.md` and `src/templates/changes/tests.md` deleted; `.specshift/templates/changes/research.md` and `.specshift/templates/changes/tests.md` deleted | PASS |
| Every modified template under `src/templates/` has incremented `template-version` | PASS |
| `src/skills/specshift/SKILL.md` no longer contains the literal string "Read all change artifacts" in the propose, apply, or finalize dispatch sections | PASS |
| `src/skills/specshift/SKILL.md` documents sub-agent dispatch for apply, finalize, and propose-internal stage generation in tool-agnostic language | PASS |
| `docs/specs/quality-gates.md` contains no positional task-step references (`step N.M`) | PASS |

## Non-Goals

- Sub-agent dispatch is not mandatory. The router MAY spawn a sub-agent or MAY execute inline; templates and SKILL.md describe intent only and do not enforce a specific execution mode.
- Auto-migration of legacy change directories. Existing changes containing `research.md` or `tests.md` retain their structure; finalize tooling tolerates both shapes but does not rewrite legacy files.
- Named pipeline profiles (e.g., lite/full). The pipeline keeps strict non-skippable stages; flexibility for simpler changes can be considered as a separate change if needed.

## Decisions

| Decision | Rationale | Alternatives |
|---|---|---|
| Sub-agent dispatch documented as optional (`MAY`), not enforced | Allows the router to choose inline execution when overhead would exceed isolation benefit (e.g., trivial changes). Intent is tool-agnostic; enforcing dispatch would constrain hosts that lack a sub-agent primitive | Mandatory dispatch (couples skill to host capability); host-specific dispatch hooks (violates agnostic-skill principle) |
| `requires:` chains as the single source of truth for stage context | Smart Templates already declare `requires:`; the change makes the router actually honor them instead of duplicating the contract in SKILL.md prose | Duplicate the contract in SKILL.md (drift risk); add a separate `read:` field (redundant with `requires:`) |
| Apply phase reads only proposal + design + tasks + affected specs | Minimum sufficient context for implementation: the proposal provides the change scope (capabilities), design provides architecture and metrics, tasks list the work, specs are the contract. Research/preflight aren't needed during implementation | Apply reads everything (current — wasteful); apply reads only tasks (loses architectural context) |
| Finalize receives capability list via auto-dispatch | The dispatching action (apply) already knows which capabilities the change touched (from proposal frontmatter); passing the list eliminates a directory scan | Finalize parses proposal markdown each run (slower, fragile); finalize scans all 85 historical changes (current — wasteful) |
| Tests stage eliminated, test generation moves to apply phase | Manual checklists in tests.md are unused (25 historical changes — all manual-only). Automated test generation belongs in implementation tasks. Constitution § Testing is the single source of truth for framework behavior | Keep tests.md as a manual checklist (no value); merge tests into tasks (makes tasks too long) |
| Research merged into Proposal as fixed Discovery block | Research duplicates proposal-stage planning; keeping Discovery as a fixed block in proposal.md preserves the artifact's historical value while removing a stage | Keep research as a separate stage (redundant); drop discovery entirely (loses traceability) |
| Backward-compat: tolerate legacy research.md and tests.md | 84 historical changes contain these files; auto-migration is risky and offers no value. Tolerance in finalize enrichment is cheap | Migrate legacy files (high risk, no benefit); break legacy reads (loses historical value) |
| Drop `.claudeignore` / `.codexignore` from scope | Target-specific syntax in an agnostic skill violates the agnostic-skill principle. Token reduction comes from per-stage contracts and sub-agent isolation, not from session-index excludes | Add `.claudeignore` only (asymmetric across Claude Code and Codex); add both files (target-specific syntax in agnostic skill) |

## Risks & Trade-offs

- **Self-referential change runs against the old pipeline.** → Mitigation: the eight-stage pipeline still works during this very propose run; the new structure takes effect after merge. The audit phase explicitly verifies the post-merge invariants.
- **Drift between `src/templates/` and `.specshift/templates/`.** → Mitigation: `bash scripts/compile-skills.sh` enforces template-version-bump during compilation; the project's own templates are kept in sync manually with documented overrides.
- **Sub-agent prompt context bleeding.** → Mitigation: SKILL.md instructions describe what the sub-agent prompt MUST include (action, change id, `requires:` list, `generates:` declaration, skill reference) and explicitly state the router SHALL NOT pre-load artifact bodies.
- **Multi-target compatibility regression.** → Mitigation: all language stays in tool-agnostic intent. Codex-specific or Claude-Code-specific phrasing is reserved for target-scoped paragraphs only. The audit checks for hardcoded host syntax.
- **In-flight changes mid-pipeline at merge time.** → Mitigation: no in-flight changes currently exist (verified via `.specshift/changes/` — only the present change is active). The legacy-tolerance scenario in artifact-pipeline.md covers any future revisit.

## Migration Plan

Post-merge:
1. `bash scripts/compile-skills.sh` regenerates the shared `./skills/specshift/` release tree from the new `src/templates/` and `src/skills/`.
2. `src/VERSION` bumped per the post-apply convention; the per-target manifest version-stamping happens in the same compile step.
3. The GitHub Action that watches `src/VERSION` on `main` creates a new tag and Release.
4. Local consumers update via the host's plugin-update command (Claude) or `codex plugin marketplace upgrade specshift` (Codex).

No rollback complexity: the change is additive (sub-agent dispatch is `MAY`) and backward-compatible for legacy change directories.

## Open Questions

No open questions. The scope is locked, decisions are recorded, and the implementation path is unambiguous.

## Assumptions

- The compile script's existing template-version-bump enforcement is sufficient to catch missed bumps. <!-- ASSUMPTION: compile validation -->
- No in-flight changes are mid-pipeline at merge time. Verified at design time (only the present change is active). <!-- ASSUMPTION: no in-flight changes -->
- The Constitution § Testing section is the appropriate single source of truth for framework configuration; no new constitution field is required. <!-- ASSUMPTION: testing config source -->
- Sub-agent dispatch in apply/finalize is implementable by both Claude Code and Codex via their host primitives (the review-self-check pattern works on both). <!-- ASSUMPTION: multi-target dispatch parity -->
