# ADR-019: Constitution Convention Only for Design Review Checkpoint

## Status

Accepted (2026-03-05)

## Context

The `/opsx:ff` command generated all 6 pipeline artifacts without pausing, which meant users could not review specs and design before the system proceeded to preflight and tasks. During real usage (issue #9), a user had to manually interrupt ff to discuss the approach. Three approaches were considered: constitution convention only, constitution plus skill modification, and schema-level checkpoint.

## Decision

Use a constitution convention only — no skill file changes.

## Rationale

Respects skill immutability; constitution is always loaded and authoritative. The constitution is injected via `config.yaml` into every prompt, so all agents follow the rule without code changes.

## Alternatives Considered

- Skill modification — violates the architecture rule that skills must not be modified for project-specific behavior
- Schema checkpoint — over-engineering; schema defines artifact order, not interaction pauses

## Consequences

- **Soft enforcement only** — The constitution convention relies on agent compliance, not hard code enforcement. Mitigated by: constitution is injected into every prompt via config.yaml, and agents are instructed to always read and follow it.
- **Spec text contradiction during transition** — Until the delta spec is archived, the baseline spec says "without pausing." Mitigated by: delta spec takes precedence during active change, and archiving resolves the contradiction.
