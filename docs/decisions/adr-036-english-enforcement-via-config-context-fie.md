# ADR-036: English Enforcement via Config `context` Field

## Status

Accepted (2026-03-05)

## Context

While `docs_language` controls the language of generated documentation, certain workflow artifacts — commit messages, branch names, PR titles, and pipeline labels — must remain in English to ensure consistency across tooling and CI/CD systems. The team needed an enforcement mechanism that would prevent `docs_language` from bleeding into these non-documentation artifacts. Per-skill instructions were considered but rejected because they would require updating every skill individually, increasing the risk that a new or modified skill omits the constraint. A schema-level rule was also evaluated but dismissed because language is not a pipeline concern and does not belong in the validation schema. The config `context` field was identified as the ideal enforcement point: it is automatically passed to every skill invocation, so a single English-enforcement instruction propagates everywhere without per-skill duplication. This approach leverages existing infrastructure (the context-passing mechanism from ADR-005) and keeps the enforcement rule co-located with the config that introduces `docs_language`.

## Decision

Add an English-enforcement instruction to the config `context` field, ensuring that all non-documentation workflow artifacts (commit messages, branch names, PR titles) remain in English regardless of the `docs_language` setting.

## Rationale

The `context` field is passed to all skills automatically, providing a single enforcement point. This avoids per-skill duplication and ensures that even newly added skills inherit the constraint without explicit configuration.

## Alternatives Considered

- Per-skill instruction: requires updating every skill file and risks omission when new skills are added
- Schema-level rule: language is not a pipeline concern; embedding it in the schema conflates validation with content policy

## Consequences

### Positive

- Single enforcement point — one instruction covers all current and future skills
- Leverages existing context-passing infrastructure with no new mechanism required
- Clear separation: `docs_language` controls documentation, `context` enforces English for workflow artifacts

### Negative

- The `context` field becomes a catch-all for cross-cutting concerns, which could reduce clarity if too many unrelated instructions accumulate
- Enforcement relies on LLM compliance with the context instruction — there is no hard programmatic guarantee

## References

- ../../openspec/specs/project-setup/spec.md
- adr-005-config-as-bootstrap-only.md
