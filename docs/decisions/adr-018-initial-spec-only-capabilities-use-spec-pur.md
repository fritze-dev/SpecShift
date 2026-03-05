# ADR-018: Initial-Spec-Only Capabilities Use Spec Purpose

## Status

Accepted (2026-03-04)

## Context

Nine of the 18 capabilities in the plugin were created during the initial-spec bootstrap and have never been touched by a subsequent archive. These capabilities have no dedicated proposal explaining their individual motivation -- the initial-spec proposal's "Why" section is about the bootstrapping process itself ("create baseline specs so future development can use the spec-driven workflow"), not about why each individual capability exists.

Using the bootstrap proposal's "Why" section for these capabilities would produce misleading documentation: every initial-spec-only capability would say it exists "to create baseline specs," which is about the bootstrapping process, not about the capability's actual purpose.

Research showed that each baseline spec has a `## Purpose` section that concisely describes what the capability does and why it matters. For capabilities that were part of the initial architecture (documented, not created, during the bootstrap), the spec Purpose provides the most accurate and specific motivation. For example, the quality-gates spec Purpose explains why quality verification matters, which is far more useful than saying it was created as part of the bootstrap.

This creates a two-tier approach: capabilities with post-bootstrap archives use the proposal "Why" (ADR-017), while initial-spec-only capabilities fall back to the spec Purpose.

## Decision

Initial-spec-only capabilities use spec Purpose. Bootstrap proposal "Why" is about spec creation, not individual capabilities.

## Rationale

Bootstrap proposal "Why" is about spec creation, not individual capabilities.

## Alternatives Considered

- Use bootstrap proposal anyway (misleading)

## Consequences

### Positive

- Each capability's "Why This Exists" section accurately describes its individual purpose
- Avoids misleading content that would attribute all capabilities to the bootstrap process
- Leverages well-written spec Purpose sections that already exist

### Negative

- Initial-spec-only capability docs are noticeably less rich than those with dedicated archives, since they lack proposal motivation, research context, and design trade-offs.

## References

- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [ADR-017: "Why This Exists" Uses Newest Archive's Proposal](adr-017-why-this-exists-uses-newest-archives-propos.md)
