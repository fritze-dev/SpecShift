# ADR-002: Use /opsx:sync for Baseline Creation

## Status

Accepted (2026-03-02)

## Context

During the initial project specification bootstrap, baseline specs needed to be created from delta specs produced by the change pipeline. The OpenSpec CLI provides a programmatic `openspec archive` command for merging delta specs into baselines, but this had known limitations: it expects a strict `## Purpose` + `## Requirements` format and has header matching issues that can cause format inconsistencies. A previous attempt to use direct `openspec archive` had already failed.

The alternative was agent-driven spec sync via `/opsx:sync`, which uses the built-in `openspec-sync-specs` skill template. This approach leverages the AI agent to intelligently merge delta operations (ADDED, MODIFIED, REMOVED) into baseline specs, handling format nuances that programmatic merge cannot. The trade-off was between automation reliability and manual intervention: programmatic merge is faster but fragile, while agent-driven sync is more robust but requires an agent session.

Research confirmed that the OpenSpec CLI's programmatic archive merge has format limitations, particularly around missing Purpose sections and header matching issues. The agent-driven sync path was the recommended approach for reliable baseline creation.

## Decision

Use `/opsx:sync` for baseline creation, not programmatic archive merge.

## Rationale

Programmatic merge has format limitations (missing Purpose, header matching issues).

## Alternatives Considered

- Direct `openspec archive` (failed in previous attempt)

## Consequences

### Positive

- Reliable baseline creation that correctly strips delta operation prefixes and maintains spec format
- Agent-driven sync handles format nuances that programmatic merge cannot
- Produces clean baselines without manual fixups

### Negative

- Requires an agent session for sync, making the process slightly slower than a purely programmatic approach

## References

- [Spec: spec-sync](../../openspec/specs/spec-sync/spec.md)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
