---
title: "Decision Documentation"
capability: "decision-docs"
description: "Architecture Decision Records generated from archived design decisions"
lastUpdated: "2026-03-05"
---

# Decision Documentation

The `/opsx:docs` command generates Architecture Decision Records (ADRs) from the Decisions tables found in archived design.md files. Each architectural decision becomes a formal, searchable record with context, rationale, alternatives, and consequences.

## Purpose

Design decisions made during spec-driven development are captured in design.md files, but once a change is archived, that context becomes buried. Without ADRs, new team members and future contributors must excavate archived changes to understand why the system was built a certain way. ADRs preserve decision context in a standard, discoverable format.

## Rationale

ADRs are fully regenerated on each run rather than incrementally updated. This avoids stale records and ensures consistency with the current archive state. Numbering is global and sequential across all archives (sorted by date), providing a stable chronological order. The Context section requires at least 4-6 sentences to prevent thin records that fail to capture the full reasoning behind a decision.

## Features

- One ADR file per decision at `docs/decisions/adr-NNN-<slug>.md`
- Sequential numbering across all archives, sorted chronologically
- Rich Context section including problem motivation, investigation, and constraints (4-6 sentences minimum)
- Decision and Rationale from the design Decisions table
- Alternatives Considered expanded into bullets
- Consequences split into Positive and Negative subsections
- References linking to related spec files and other ADRs
- ADR content generated in configured `docs_language` (file names stay English)
- Fully regenerated on each `/opsx:docs` run

## Behavior

### ADR Generation

When you run `/opsx:docs`, the system reads all archived design.md files and processes each Decisions table. Each row becomes one ADR file. Archives are processed in chronological order (by date prefix), and decisions within each archive follow table row order. If `docs_language` is configured, ADR headings and content are generated in the target language while file names (`adr-NNN-<slug>.md`) remain in English.

### Context Enrichment

The ADR Context section draws from the design.md Context section and is enriched with findings from research.md when available. The context covers what motivated the decision, what was investigated, and what constraints shaped the choice.

### Consequences

Each ADR splits consequences into Positive (benefits derived from the rationale and context) and Negative (drawbacks and trade-offs derived from the design Risks and Trade-offs section). If no negative consequences can be identified for a specific decision, the section states "No significant negative consequences identified."

### References

Each ADR includes links to the relevant spec file and related ADRs. For cross-cutting decisions not tied to a specific capability, the References section links to the constitution or the most relevant architectural spec.

### Stale File Cleanup

If `docs/decisions/README.md` exists from a previous run, the system deletes it. ADR discovery is handled by inline links in the `docs/README.md` Key Design Decisions table.

## Known Limitations

- ADRs are fully regenerated on each run — manual edits to ADR files will be overwritten
- Context enrichment depends on the archive having a research.md with useful content

## Edge Cases

- If no archives have design.md files, ADR generation is skipped entirely and no `docs/decisions/` directory is created.
- If a Decisions table is empty, that archive's design.md is skipped for ADR generation.
- If the Decisions table uses a different column format (3-column or 4-column), the system handles both.
- If a decision is cross-cutting and not tied to a specific capability spec, the References section links to the constitution or the most relevant architectural spec.
- If `docs_language` is set to an unrecognizable value, ADRs fall back to English.
