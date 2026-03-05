# ADR-021: Skip Checkpoint When Preflight Already Done

## Status

Accepted (2026-03-05)

## Context

When a user resumes `/opsx:ff` on a change where some artifacts are already complete, the system needs to determine whether to present the review checkpoint. If preflight is already done, the user has already reviewed past the design phase in a previous session.

## Decision

Skip checkpoint when preflight already done.

## Rationale

Avoids unnecessary friction on resume; preflight existence implies prior design review. Presenting the checkpoint again would be redundant and slow down the workflow.

## Alternatives Considered

- Always checkpoint — annoying for resume cases where the user has already reviewed

## Consequences

- Resume workflows are faster — no redundant review prompts.
- Edge case: if a user's prior review was superficial, they won't be prompted again. This is acceptable because the preflight quality gate still catches issues.
