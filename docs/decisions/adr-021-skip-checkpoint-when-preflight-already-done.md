# ADR-021: Skip Checkpoint When Preflight Already Done

## Status

Accepted (2026-03-05)

## Context

The design review checkpoint (ADR-019, ADR-020) introduces a pause after the design stage in the ff workflow. However, `/opsx:ff` can be used to resume a partially completed pipeline -- for example, if design and preflight are already done and only tasks remain. In resume scenarios, pausing for design review when the user has already reviewed and approved the design (evidenced by preflight completion) would be unnecessary friction.

Three scenarios were identified for resume behavior. First, a fresh run where no artifacts exist: the checkpoint fires after design as intended. Second, a resume where design is done but preflight is not: the checkpoint fires because the user may not have reviewed the design yet. Third, a resume where preflight already exists: the checkpoint is skipped because preflight existence implies the user previously reviewed and approved the design.

Research confirmed that the alternative of always checkpointing, regardless of existing artifacts, would create annoying interruptions in resume cases. Users who have already moved past design and through preflight have implicitly approved the design approach. Forcing them to re-approve adds friction without value.

This edge case handling ensures the checkpoint adds value (catching unreviewed designs) without adding unnecessary friction (interrupting resumed workflows where design was already reviewed).

## Decision

Skip checkpoint when preflight already done. Avoids unnecessary friction on resume; preflight existence implies prior design review.

## Rationale

Avoids unnecessary friction on resume; preflight existence implies prior design review.

## Alternatives Considered

- Always checkpoint (annoying for resume cases)

## Consequences

### Positive

- Resume workflows are not interrupted by redundant review checkpoints
- The checkpoint fires only when it provides value: when design has not been reviewed
- Consistent user experience whether starting fresh or resuming

### Negative

- No significant negative consequences identified.

## References

- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [ADR-019: Constitution Convention Only](adr-019-constitution-convention-only.md)
- [ADR-020: Checkpoint After Design Specifically](adr-020-checkpoint-after-design-specifically.md)
