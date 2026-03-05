# ADR-008: Convention in Constitution, Not Skill Modification

## Status

Accepted (2026-03-04)

## Context

The plugin's update mechanism requires a version bump in `plugin.json` for `/plugin update` to detect changes. This bump was a manual convention that was regularly forgotten, causing consumers to miss updates. Additionally, `marketplace.json` was out of sync (1.0.0 vs 1.0.3). A solution was needed to automate version bumps as part of the archive workflow.

The key architectural constraint was skill immutability: skills are generic shared plugin code that must not be modified for project-specific behavior (Issue #10). The archive skill (`/opsx:archive`) is shared across all consumer projects, so embedding version bump logic directly in it would violate this principle and create a project-specific fork.

Three approaches were investigated. Modifying the archive skill directly would provide hard enforcement but violate skill immutability. A separate `/opsx:release` skill would add a manual step that could still be forgotten -- the same problem as today. Using a constitution convention leverages the fact that the constitution is loaded into every AI prompt via config.yaml, so agents reading the constitution before executing archive would naturally follow the bump convention. This approach respects the three-layer architecture where project-specific behavior is defined in the constitution, not in skills.

The hybrid approach was selected: auto-bump patch in archive via constitution convention, with a manual process for minor/major releases documented in docs.

## Decision

Convention in constitution, not skill modification. Skills are shared across consumers; project-specific behavior in constitution (Issue #10).

## Rationale

Skills are shared across consumers; project-specific behavior in constitution (Issue #10).

## Alternatives Considered

- Modify archive skill directly (violates skill immutability)

## Consequences

### Positive

- Respects skill immutability -- skills remain generic and shared across all consumers
- Constitution is always loaded and authoritative, so agents will follow the convention reliably
- Version bumps cannot be forgotten since they are part of the archive workflow convention

### Negative

- Convention compliance depends on agent reading and following the constitution. There is no hard code enforcement. Mitigated by the constitution being read at the start of every skill execution.

## References

- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
- [Spec: constitution-management](../../openspec/specs/constitution-management/spec.md)
- [Spec: three-layer-architecture](../../openspec/specs/three-layer-architecture/spec.md)
