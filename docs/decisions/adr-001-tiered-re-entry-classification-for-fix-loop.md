# ADR-001: Tiered Re-entry Classification for Fix Loop

## Status

Accepted (2026-04-13)

## Context

The `specshift apply` Fix Loop handles review corrections during the QA cycle. Prior to this decision, the Fix Loop provided no classification of correction severity — a typo fix and an approach change both received the same treatment: patch in place and regenerate review.md. This led to problems visible in PR #12, where a reviewer pointed out that the wrong files were edited and the wrong abstraction was used. The agent entered "patch mode," producing 5+ fix commits rather than updating the design and re-implementing. The result was artifact drift: design.md, tasks.md, and review.md continued describing the original wrong approach even after the implementation had changed.

Three approaches were evaluated: (A) clarifying the existing fix loop instruction without adding new vocabulary, (B) adding a tiered re-entry classification with concrete detection signals, and (C) creating a separate `specshift reenter` action. Approach A was insufficient because it left classification implicit — agents still lacked criteria to distinguish typos from approach changes. Approach C was over-engineered: the fix loop already covers re-entry, and a new action would fragment the UX. The core constraint was that agents need mechanically checkable criteria, not subjective judgment — pure judgment was shown to fail in PR #12.

## Decision

1. **Update the apply instruction rather than adding a new action** — the fix loop is part of apply; a new action would fragment the UX and break the existing checklist flow.
2. **Three tiers: Tweak, Design Pivot, Scope Change** — two tiers (fix vs. re-enter) proved too coarse in practice (PR #12 involved a Design Pivot, not a full Scope Change). Three tiers allow precision without complexity.
3. **Detection signals as observable facts** — agents can check signals mechanically (reverted tasks, invalidated metrics, reversed decisions, out-of-scope files) before choosing a tier. Pure subjective judgment was shown to fail in PR #12.
4. **Update tasks template step 3.4 description** — the step is already in the checklist; enhancing its description makes the tier vocabulary visible at implementation time rather than requiring agents to look up the spec.

## Alternatives Considered

- **New `specshift reenter` action**: Over-engineered; the fix loop already covers this use case, and a separate action would break the existing checklist flow.
- **Two tiers (fix/re-enter)**: Too coarse — cannot distinguish a Design Pivot from a Scope Change.
- **Four or more tiers**: Unnecessary complexity for the observed problem space.
- **Judgment-only classification**: Shown to fail in practice (PR #12).
- **Leave template unchanged**: Misses the direct user-facing instruction location where agents read the step description.

## Consequences

### Positive

- Agents have explicit, mechanically checkable criteria for classifying corrections
- Artifact drift is prevented by the staleness rule — stale design.md, tasks.md, and review.md must be updated before re-implementing
- The three-tier vocabulary provides a shared language for developers and agents to discuss correction depth
- Consumers benefit from the updated template guidance on next plugin update

### Negative

- Tier boundary ambiguity remains possible in edge cases — mitigated by the "ambiguous defaults to higher tier" rule, which errs toward clean artifacts at the cost of occasionally over-classifying
- The instruction text for step 3.4 and the apply instruction is now denser, which could overwhelm agents processing simple tweaks

## References

- [Change: fix-loop-tiered-reentry](../../.specshift/changes/2026-04-13-fix-loop-tiered-reentry/)
- [Spec: human-approval-gate](../../docs/specs/human-approval-gate.md)
- [GitHub Issue #13](https://github.com/fritze-dev/SpecShift/issues/13)
