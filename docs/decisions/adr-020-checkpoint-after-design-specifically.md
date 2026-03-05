# ADR-020: Checkpoint After Design Specifically

## Status

Accepted (2026-03-05)

## Context

With the decision to add a design review checkpoint as a constitution convention (ADR-019), the question was where in the 6-stage pipeline to place the pause. The pipeline stages are: research, proposal, specs, design, preflight, tasks. Three points were considered.

Pausing after specs (stage 3) was too early: at that point, the approach and architecture decisions have not yet been made. The design stage is where these decisions are finalized, and reviewing before design is complete means reviewing incomplete information. Pausing after preflight (stage 5) was too late: by that point, the system has already invested in quality gates and gap analysis, making it expensive to change direction based on feedback.

Design (stage 4) is the natural review point because it finalizes the approach, architecture decisions, and trade-offs. Feedback at this stage is cheap: no quality gates have been run, no tasks have been generated, and the implementation direction can still be adjusted without wasting work. The `/opsx:continue` skill already pauses after every artifact, providing natural checkpoints. But `/opsx:ff` skips all pauses, so the design checkpoint specifically targets the ff workflow.

Research confirmed that in practice, users naturally wanted to review after design during the fix-workflow-friction change, where they ran verify-fix-verify-approve cycles. The checkpoint formalizes this observed behavior.

## Decision

Checkpoint after design specifically. Design finalizes approach/architecture -- last point where feedback is cheap before quality gates.

## Rationale

Design finalizes approach/architecture -- last point where feedback is cheap before quality gates.

## Alternatives Considered

- After specs (too early, design not done)
- After preflight (too late, already invested in quality review)

## Consequences

### Positive

- Users can review and adjust the approach before quality gates and task generation consume resources
- Feedback at the design stage is cheap to incorporate since no downstream artifacts exist yet
- Formalizes the natural review point that was already observed in practice

### Negative

- Spec text contradiction during transition: until the delta spec is archived, the baseline spec says "without pausing." Mitigated by delta spec taking precedence during active changes.

## References

- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [ADR-019: Constitution Convention Only](adr-019-constitution-convention-only.md)
