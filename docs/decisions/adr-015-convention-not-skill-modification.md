# ADR-015: Convention in Constitution, Not Skill Modification

## Status

Accepted (2026-03-04)

## Context

The plugin's update mechanism requires a version bump in `plugin.json` for `/plugin update` to detect changes — currently done manually and regularly forgotten. The fix needed to be implemented without modifying skill files, since skills are shared across consumers.

Research confirmed that the archive skill reads the constitution before execution, making constitution conventions an effective mechanism for extending behavior. A hybrid approach was chosen: auto-bump patches in archive, manual process for minor/major releases.

## Decision

Post-archive auto-bump defined as a convention in the constitution, not as a skill modification.

## Rationale

Skills are shared across consumers; project-specific behavior belongs in the constitution. This respects the skill immutability rule.

## Alternatives Considered

- Modify archive skill directly (violates skill immutability)

## Consequences

- Convention compliance depends on the agent reading and following the constitution — mitigated by standard behavior of reading constitution before every skill execution.
- Skills remain generic and unmodified.
