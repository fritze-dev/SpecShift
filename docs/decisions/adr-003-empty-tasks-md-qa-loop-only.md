# ADR-003: Empty tasks.md (QA Loop Only)

## Status

Accepted (2026-03-02)

## Context

The initial project specification was a documentation-only bootstrap with no code changes to implement. The 6-stage artifact pipeline requires a tasks.md artifact as part of the change flow, and the pipeline gate for the apply phase checks tasks completion. Without a tasks.md, the pipeline gate would block the change from proceeding.

The question was whether to skip tasks.md entirely or to provide a minimal version. Skipping it entirely would break the pipeline gate, since the apply phase is gated by tasks completion. The bootstrap had no implementation tasks -- all 15 specs were being documented, not coded -- so the only meaningful QA activity was the verification loop to ensure spec quality and coherence with actual skill behavior.

Research confirmed that the schema defines a strict 6-artifact pipeline (research, proposal, specs, design, preflight, tasks) and the apply phase requires all artifacts to be present. An empty tasks.md containing only the QA loop section satisfied the pipeline gate while accurately reflecting the scope of work.

## Decision

Empty tasks.md (QA loop only).

## Rationale

No code to implement -- this is a documentation bootstrap.

## Alternatives Considered

- Skip tasks entirely (breaks pipeline gate)

## Consequences

### Positive

- Pipeline gate is satisfied, allowing the change to proceed through apply and archive
- Accurately reflects the scope of work: no implementation, only QA verification
- Sets a precedent for documentation-only changes

### Negative

- No significant negative consequences identified.

## References

- [Spec: task-implementation](../../openspec/specs/task-implementation/spec.md)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
