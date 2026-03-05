# ADR-038: Manual ADRs Use `adr-MNNN-slug.md` Naming in `docs/decisions/`

## Status
Accepted (2026-03-05)

## Context
A full docs regeneration test (delete all docs → `/opsx:docs` → `git diff`) revealed that manually written ADRs were lost during regeneration. ADR-034 (init-model-invocable) was hand-written during bootstrap recovery and stored in `docs/decisions/` alongside generated ADRs. Since it did not originate from any archived design.md Decisions table, the regeneration process deleted it. The fix-docs-skill-regressions change investigated several approaches: a separate `manual/` subdirectory (adds unnecessary directory complexity), a preservation rule for unmatched ADR filenames (fuzzy matching risks numbering conflicts), and a naming convention with a distinct prefix. The M prefix approach requires no new directories, is unambiguously distinguishable from generated `adr-NNN` files by a simple glob pattern, and keeps all ADRs in a single directory for unified discovery.

## Decision
Manual ADRs use the `adr-MNNN-slug.md` naming convention in the same `docs/decisions/` directory as generated ADRs.

## Rationale
No extra directory needed; M prefix unambiguously distinguishes from generated `adr-NNN`; single glob location for README discovery.

## Alternatives Considered
- Separate `manual/` subdirectory (unnecessary directory complexity, complicates README generation)
- Preservation rule for unmatched ADR filenames (fuzzy matching, numbering conflicts with generated ADRs)

## Consequences

### Positive
- Manual ADRs survive regeneration without any special handling beyond filename detection
- Single directory simplifies glob-based discovery in README generation
- M prefix is visually distinct and unambiguous in file listings

### Negative
- Slug change from the deterministic algorithm causes ADR file renames in git history, showing churn for existing ADRs even though content is unchanged.

## References
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [ADR-039: Deterministic Slug Algorithm](adr-039-deterministic-slug-replace-non-a-z0-9-with-hyphen.md)
