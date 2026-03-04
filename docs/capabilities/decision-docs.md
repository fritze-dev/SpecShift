---
title: "Decision Records"
capability: "decision-docs"
description: "Architecture Decision Records (ADRs) generated from archived design decisions"
order: 17
lastUpdated: "2026-03-04"
---

# Decision Records

The `/opsx:docs` command generates formal Architecture Decision Records (ADRs) from the design decisions made across all archived changes. Each decision becomes a searchable record with context, rationale, alternatives considered, and consequences.

## Why This Exists

Design decisions are captured in individual design artifacts during each change, but once archived they become difficult to find and cross-reference. This capability transforms scattered decision tables into a structured, indexed collection of ADRs so that you can understand why architectural choices were made and what alternatives were considered.

## Features

- One ADR file per design decision, with sequential numbering across all archives
- Each ADR includes status, context, decision, rationale, alternatives considered, and consequences
- ADR context enriched with research findings where available
- Chronological numbering based on archive dates
- ADR index listing all records with number, title, date, and source change
- Fully regenerated on each run for consistent, deterministic numbering

## Behavior

### Generating ADRs

When you run `/opsx:docs`, the system scans all archived changes for design files containing decision tables. Each row in a decision table becomes one ADR file. The system reads the design context, research findings (where available), and risk assessments to produce a complete record for each decision.

### Numbering and Ordering

ADRs are numbered sequentially across all archives, sorted chronologically by archive date. Within each archive, decisions are numbered in the order they appear in the table. For example, if the first archive has 3 decisions and the second has 4, they are numbered ADR-001 through ADR-007.

### Research Enrichment

When an archived change includes research data alongside its design decisions, the system incorporates relevant findings and investigated approaches into the ADR's context section, providing richer background for each decision.

### ADR Index

The system generates an index file listing all ADRs in a table with their number, decision title, date, and the name of the change that produced them.

## Known Limitations

- Does not support incremental ADR generation; all records are fully regenerated each run, so numbering may shift if archives are added or removed
- Does not generate ADRs from archives that have no design artifacts
- Does not automatically link related ADRs; each record stands alone

## Edge Cases

- If no archived changes contain design files, the system skips ADR generation entirely and does not create the decisions directory.
- The system handles both 3-column and 4-column decision table formats.
- If a design file contains an empty decision table, the system skips that archive for ADR generation.
