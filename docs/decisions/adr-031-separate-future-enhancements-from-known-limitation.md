# ADR-031: Separate "Future Enhancements" from "Known Limitations"

## Status

Accepted (2026-03-05)

## Context

Before this change, capability docs had a single "Known Limitations" section that mixed two distinct concepts: current technical constraints (e.g., "Does not support incremental updates") and deferred future ideas (e.g., "Tracked in #12"). Readers looking for current limitations had to filter out future plans, and readers looking for the roadmap had to scan through constraint descriptions. Design Non-Goals were the primary source for both types of content, but they serve different audiences: limitations inform current users about what the system cannot do today, while enhancements inform planners about what the system could do tomorrow.

## Decision

Separate "Future Enhancements" into its own section, distinct from "Known Limitations."

## Rationale

Limitations describe current constraints while enhancements describe actionable future ideas. Conflating them confuses readers who have different needs. The separation also allows linking to GitHub Issues for tracked enhancements.

## Alternatives Considered

- Merge into a single "Known Limitations" section -- conflates current constraints with future plans
- Add future items to Edge Cases -- Edge Cases are for surprising behavior, not roadmap items

## Consequences

### Positive

- Clearer separation of "what the system cannot do now" vs "what it could do in the future"
- Future Enhancements can link to GitHub Issues for traceability
- Each section stays concise (max 5 bullets each)

### Negative

- No significant negative consequences identified. The additional section adds minimal length to docs.

## References

- [User Documentation spec](../../openspec/specs/user-docs/spec.md)
- [Capability doc template](../../openspec/schemas/opsx-enhanced/templates/docs/capability.md)
