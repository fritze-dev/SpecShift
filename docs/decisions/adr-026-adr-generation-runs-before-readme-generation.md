# ADR-026: ADR Generation Runs BEFORE README Generation

## Status

Accepted (2026-03-05)

## Context

The consolidated docs README (ADR-024) includes inline links to ADR files in the Key Design Decisions table. This creates a data dependency: the README generation step needs to know which ADR files exist and their paths in order to create correct links. The question was the ordering of generation steps within the `/opsx:docs` skill.

Two orderings were considered. Generating ADRs first, then the README, means ADR file paths are known at README generation time. The README can directly reference the generated ADR files with correct links. Generating the README first would require a two-pass approach: generate a README with placeholder links, generate ADRs, then backfill the links -- adding complexity for no benefit.

Research confirmed that the ADR-first approach is simpler and produces correct output in a single pass. The step sequence in the enriched SKILL.md naturally places ADR generation (Step 5) before README/TOC generation (Step 6), maintaining a clean data flow where upstream steps produce artifacts that downstream steps reference.

This ordering constraint is specific to the consolidated README approach. In the previous 3-file structure, the ADR index was a separate file and did not need to reference ADR paths at generation time.

## Decision

ADR generation runs BEFORE README generation. README needs ADR file paths for inline links; reversing order would require a two-pass approach.

## Rationale

README needs ADR file paths for inline links; reversing order would require a two-pass approach.

## Alternatives Considered

- Generate README first, then backfill ADR links (rejected: adds complexity)

## Consequences

### Positive

- Single-pass generation produces correct output with valid ADR links
- Clean data flow: upstream steps produce artifacts referenced by downstream steps
- Simpler implementation than a two-pass approach

### Negative

- No significant negative consequences identified.

## References

- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [ADR-024: Consolidated README Replaces 3 Separate Files](adr-024-consolidated-readme-replaces-3-separate-files.md)
