# ADR-003: Empty tasks.md (QA Loop Only)

## Status

Accepted (2026-03-02)

## Context

The initial bootstrap is a documentation-only change with no code to implement. The artifact pipeline requires tasks.md to exist before the apply phase can begin. The question was whether to skip tasks entirely or include a tasks.md with only the QA loop.

## Decision

Empty tasks.md with QA loop only — no implementation tasks.

## Rationale

No code to implement — this is a documentation bootstrap. Skipping tasks entirely would break the pipeline gate.

## Alternatives Considered

- Skip tasks entirely (breaks pipeline gate)

## Consequences

- The pipeline gate is satisfied while accurately reflecting that there is no code to implement.
- The QA loop (verify + approval) still runs to validate the spec quality.
