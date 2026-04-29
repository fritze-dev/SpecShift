# ADR-004: Six-stage pipeline + sub-agent dispatch optionality

**Status:** Accepted (2026-04-29)

## Context

The eight-stage artifact pipeline duplicated work between research (discovery) and proposal-stage planning, and the tests stage reformatted Gherkin scenarios already present in specs without adding information. The router (`SKILL.md`) instructed every stage to "read all change artifacts", which prevented bounded sub-agent execution and produced quadratic context growth across stages. PR #60 (v0.2.8-beta) introduced sub-agent dispatch for the review action's self-check step and validated the pattern across both Claude Code and Codex; the same pattern was the natural model for closing the loop on the rest of the pipeline.

## Decision

1. **Six-stage pipeline `[proposal, specs, design, preflight, tasks, audit]`.** Research is absorbed into proposal as a fixed Discovery block (Current State, External Research, Approaches, Coverage Assessment, Decisions). Tests is eliminated — apply-phase test generation, driven by Constitution § Testing, replaces the standalone tests.md artifact.

2. **Per-stage `requires:` chains as the single source of truth for stage context.** Smart Templates already declared `requires:`; the router now honors them instead of reading every prior artifact. Apply reads only proposal+design+tasks+affected specs. Finalize reads only proposal+design+audit+listed-capability specs (capability list is passed in via auto-dispatch from apply).

3. **Sub-agent dispatch documented as optional (`MAY`), not enforced.** A new `## Sub-Agent Dispatch` section in `SKILL.md` documents the pattern in tool-agnostic intent for apply, finalize, and propose-internal stage generation. The router can still execute inline when sub-agent overhead would exceed the isolation benefit (e.g., trivial changes); hosts that lack a sub-agent primitive can execute the same instructions inline and remain conformant.

4. **Preflight retained as a separate stage.** Audit of historical preflights showed 11 of 77 with WARNINGS or BLOCKED verdicts identifying genuine pre-implementation findings (constitution inconsistencies, assumption gaps, consolidation problems). Merging preflight into design loses the "fresh validator" effect that produced those findings. When design is skipped for simple changes, preflight is also skipped and tasks gains a Validation Notes section instead.

5. **Design Non-Goals refined to capability-limitations only.** Historical Non-Goals were 3-4 of 5 copy-pasted from Proposal Out-of-scope. Design Non-Goals now capture only NEW technical capability-limitations that emerged during design; change-level scope lives in Proposal § Scope, which the design instruction references directly.

6. **ADR generation conditional on `design.md` `has_decisions: true`.** Most changes do not introduce architecturally significant decisions; gating ADR generation on the frontmatter flag eliminates spurious ADR work during finalize. ADR template streamlined: Context 2-6 sentences with anti-padding guidance (was 4-6); Consequences section optional for straightforward decisions.

7. **`.claudeignore`/`.codexignore` declined as out of scope.** Target-specific ignore syntax in an agnostic skill would violate the agnostic-skill principle. Codex has no documented `.codexignore` equivalent, so adding only `.claudeignore` would be asymmetric. Per-stage context contracts and sub-agent dispatch produce the bulk of the token-budget benefit without target-specific files.

## Alternatives Considered

- **Five-stage pipeline (also merge preflight into design):** Loses the evidence-based pre-implementation validation; merging into the design "frame" reduces finding quality.
- **Three-stage pipeline (proposal, design, audit):** Aggressive simplification eliminates Specs (the source of truth for traceability) and Preflight; rejected as too aggressive against the user's intent.
- **Mandatory sub-agent dispatch:** Couples the agnostic skill to a host capability that not every conforming host has; rejected in favor of optional dispatch with tool-agnostic intent.
- **Custom dispatch hooks per host:** Violates the agnostic-skill principle (the router carries host-specific behavior); rejected.
- **Auto-migration of legacy `research.md`/`tests.md`:** Risky and offers no value; rejected in favor of tolerance — finalize enrichment accepts both shapes (proposal § Discovery or legacy `research.md`).

## Consequences

The non-obvious consequence is the multi-target sub-agent-parity assumption. The dispatch pattern requires that both Claude Code and Codex provide a sub-agent primitive whose contract matches the review-self-check use case. The PR #60 review-self-check pattern validated this for the review path; extending it to apply, finalize, and propose-internal stage generation assumes the same parity holds for those entry points. If a future host lacks the primitive, the optional `MAY` framing keeps the change conformant — the host executes the dispatch instructions inline.

Workflow shape change (8 → 6 stages) is the obvious consequence and is documented in the changelog and capability docs.
