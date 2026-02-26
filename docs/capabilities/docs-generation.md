---
title: "Docs & Changelog Generation"
capability: "docs-generation"
description: "User-facing documentation from specs (/opsx:docs) and release notes from archives (/opsx:changelog)"
order: 14
lastUpdated: "2026-03-02"
---

# Docs & Changelog Generation

Run `/opsx:docs` to generate user-facing documentation from baseline specs. Run `/opsx:changelog` to generate release notes from archived changes.

## Features

- Generate one documentation file per capability from baseline specs
- Transform normative language into natural, user-facing explanations
- Convert Gherkin scenarios into readable usage examples
- Generate Keep a Changelog formatted release notes from archived changes

## Behavior

### Documentation Generation

Running `/opsx:docs` reads each baseline spec in `openspec/specs/` and creates a documentation file at `docs/capabilities/<capability>.md`. Normative language (SHALL/MUST) is replaced with natural language. Gherkin scenarios become usage examples. Implementation details are omitted. User Stories inform the documentation's framing.

### Changelog Generation

Running `/opsx:changelog` reads archived changes in `openspec/changes/archive/` and produces entries in `CHANGELOG.md` following Keep a Changelog format (Added, Changed, Deprecated, Removed, Fixed, Security). Entries are ordered newest first. Existing manually written entries are preserved.

### Incremental Updates

If `CHANGELOG.md` already exists, new entries are added for archives not yet represented without duplicating existing entries. Documentation files are regenerated from specs on each run since specs are the source of truth.

## Edge Cases

- If no baseline specs exist, the agent suggests running `/opsx:sync` first.
- If a spec has no scenarios, documentation is generated from requirement descriptions only.
- Existing documentation files are overwritten with freshly generated content.
- If no archives exist, the changelog command informs you that no entries were generated.
- Malformed archive directories are skipped with a warning.
- Purely internal refactoring changes produce a minimal note rather than fabricated user-facing changes.
