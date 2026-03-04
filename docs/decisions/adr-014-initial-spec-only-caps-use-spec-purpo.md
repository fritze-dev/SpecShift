# ADR-014: Initial-spec-only Capabilities Use Spec Purpose

## Status

Accepted (2026-03-04)

## Context

The `initial-spec` archive is a bootstrap change whose proposal "Why" describes the spec creation process, not the motivation for individual capabilities. Using this generic "Why" for each capability's "Why This Exists" section would be misleading.

## Decision

For capabilities whose only relevant archive is `initial-spec`, derive "Why This Exists" from the spec's `## Purpose` section instead of the bootstrap proposal.

## Rationale

The bootstrap proposal "Why" is about spec creation, not individual capabilities. The spec Purpose section accurately describes what each capability does and why.

## Alternatives Considered

- Use bootstrap proposal anyway (misleading context)

## Consequences

- Capabilities without post-bootstrap changes get meaningful "Why This Exists" content.
- As capabilities gain their own dedicated changes, the Purpose-derived text is replaced with the proposal's more specific motivation.
