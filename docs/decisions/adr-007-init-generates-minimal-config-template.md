# ADR-007: Init Generates Minimal Config Template

## Status

Accepted (2026-03-02)

## Context

The init skill previously copied the plugin's own config.yaml to consumer projects. This leaked project-specific rules (9 global workflow rules) into consumer environments, creating confusion and maintenance issues.

## Decision

Init generates a minimal config template (schema reference + constitution pointer) instead of copying the plugin's own config.

## Rationale

Prevents project-specific rules from leaking into consumer projects. Init should provide a clean starting point.

## Alternatives Considered

- Copy full project config (leaks project-specific content)

## Consequences

- Consumer projects get a clean bootstrap without project-specific rules.
- The init skill generates config from a hardcoded template, not from the plugin's config.yaml.
