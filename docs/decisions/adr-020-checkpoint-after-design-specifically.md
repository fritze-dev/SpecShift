# ADR-020: Checkpoint After Design Specifically

## Status

Accepted (2026-03-05)

## Context

The design review checkpoint needed a specific trigger point in the artifact pipeline. The pipeline has 6 stages: research, proposal, specs, design, preflight, and tasks. The checkpoint needed to be placed where it provides the most value for user alignment.

## Decision

Checkpoint after design specifically.

## Rationale

Design finalizes approach/architecture — last point where feedback is cheap before quality gates. After design, the system proceeds to preflight (quality review) and tasks (implementation planning), which build on the design decisions.

## Alternatives Considered

- After specs — too early, design decisions not yet made
- After preflight — too late, already invested in quality review based on potentially misaligned design

## Consequences

- Users review approach and architecture at the optimal point — after all planning is done but before execution artifacts are generated.
- Feedback at this stage is cheap to incorporate, as only planning artifacts need regeneration.
