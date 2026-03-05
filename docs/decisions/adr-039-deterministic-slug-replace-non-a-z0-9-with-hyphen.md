# ADR-039: Deterministic Slug — Replace Non-`[a-z0-9]` with Hyphen

## Status
Accepted (2026-03-05)

## Context
A full docs regeneration test revealed that ADR filenames were not deterministic across runs. The previous slug generation rule was underspecified — it did not define how to handle dots, parentheses, slashes, or other special characters, leading to inconsistent filenames when the same Decision text was processed multiple times. The fix-docs-skill-regressions change investigated two alternatives: keeping the current underspecified rule (accepts non-determinism) and adding special-case rules per character type (complex and still potentially ambiguous for edge cases). A uniform replacement rule — any character not in `[a-z0-9]` becomes a hyphen — handles all special characters identically, produces consistent results across runs, and requires no character-type-specific logic. The algorithm includes collapsing consecutive hyphens, trimming, and truncating to 50 characters to keep filenames readable.

## Decision
Deterministic slug algorithm: lowercase the string, replace any character not in `[a-z0-9]` with a hyphen, collapse consecutive hyphens, trim, and truncate to 50 characters.

## Rationale
Handles all special characters uniformly; no ambiguity about dots, parens, slashes; produces consistent results across runs.

## Alternatives Considered
- Keep current underspecified rule (accepts non-deterministic slugs, causes file renames on regeneration)
- Add special-case rules per character type (complex, still potentially ambiguous for unusual characters)

## Consequences

### Positive
- ADR filenames are fully deterministic — same input always produces the same slug
- Simple algorithm with no edge cases to maintain
- Consistent across all character sets and special characters

### Negative
- The new algorithm produces different filenames for some existing ADRs (e.g., `opsxsync` → `opsx-sync`), causing file renames in git history. All README links regenerate to match, so no broken links, but git shows churn.

## References
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [ADR-038: Manual ADRs Use adr-MNNN Naming](adr-038-manual-adrs-use-adr-mnnn-slug-md-naming-in-docs-de.md)
