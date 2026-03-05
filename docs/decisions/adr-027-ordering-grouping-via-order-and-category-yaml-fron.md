# ADR-027: Ordering and Grouping via order and category YAML Frontmatter

## Status

Accepted (2026-03-05)

## Context

The consolidated docs README (ADR-024) groups capabilities by category with group headers and orders them within groups. The question was where to define the ordering and grouping metadata for each capability. Four approaches were considered.

Hardcoding a capability table in SKILL.md would make ordering deterministic but violate skill immutability -- the table would need updating every time capabilities are added or renamed, creating project-specific content in a shared skill file. Using a constitution section was rejected because ordering is data, not a governance rule. Letting the agent determine ordering at docs generation time was rejected because it would produce non-deterministic output -- different runs might order capabilities differently.

YAML frontmatter in baseline specs was the chosen approach. Each spec already has a `## Purpose` and `## Requirements` section. Adding `order` (integer) and `category` (string like "Structural", "Operational", "Supporting") to an optional YAML frontmatter block at the top of the spec provides deterministic, project-specific ordering that is set during spec creation, not at docs generation time. This follows the data flow principle: specs are the source of truth, archives capture snapshots, and docs read from specs.

Research confirmed that the spec template (`openspec/schemas/opsx-enhanced/templates/specs/spec.md`) could be extended with optional frontmatter without breaking existing specs. The SKILL.md stays project-independent because it reads frontmatter generically -- it does not need to know which categories or orderings exist.

## Decision

Ordering and grouping via `order` and `category` YAML frontmatter in baseline specs. Project-specific, deterministic, set during spec creation; SKILL.md stays project-independent; follows data flow.

## Rationale

Project-specific, deterministic, set during spec creation (not docs generation); SKILL.md stays project-independent; follows data flow (specs to archive to docs read).

## Alternatives Considered

- Hardcoded table in SKILL.md (rejected: violates skill immutability)
- Constitution section (rejected: data table, not a rule)
- Agent-determined at docs time (rejected: non-deterministic)

## Consequences

### Positive

- Deterministic ordering that is consistent across docs generation runs
- SKILL.md stays project-independent -- no hardcoded capability lists
- Follows the data flow principle: specs own their metadata, docs read it
- All 18 baseline specs get categorized and ordered

### Negative

- Every new spec must include frontmatter, adding a small overhead to spec creation. Mitigated by the spec template including frontmatter by default.

## References

- [Spec: spec-format](../../openspec/specs/spec-format/spec.md)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
