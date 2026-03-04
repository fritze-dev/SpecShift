---
title: "User Documentation"
capability: "user-docs"
description: "Enriched user-facing capability documentation generated from specs and archived artifacts"
order: 15
lastUpdated: "2026-03-04"
---

# User Documentation

The `/opsx:docs` command generates clear, user-facing documentation for every capability. Each doc explains what the capability does, why it exists, and what limitations apply -- drawing from both the current specs and the archived history of changes.

## Why This Exists

Previously, documentation was generated from baseline specs alone, leaving valuable context locked in archived artifacts. Users could not understand why capabilities existed, what alternatives were considered, or what limitations applied without digging through archives manually. This capability enriches documentation with archive-derived context so you get the full picture in one place.

## Background

The docs skill originally read only baseline specs to generate capability docs with four sections: overview, features, behavior, and edge cases. Five archived artifact types (proposal, research, design, preflight, tasks) and the constitution went unused for documentation. Research confirmed that proposals consistently contain motivation sections, design files contain non-goals and risks, and preflight files contain assumption audits -- all valuable for user-facing docs. The approach chosen consolidates all documentation generation into a single `/opsx:docs` command rather than creating separate skills.

## Features

- One documentation file per capability, generated from baseline specs
- Enriched sections drawn from archived artifacts: "Why This Exists," "Background," and "Known Limitations"
- Automatic archive lookup to find changes that touched each capability
- Normative spec language (SHALL, MUST) replaced with natural, user-facing language
- Gherkin scenarios converted into readable behavioral descriptions
- Implementation details and internal references excluded
- Table of contents linking all capability docs, architecture overview, and decision records
- Conciseness guards: "Why This Exists" limited to 3 sentences, "Background" to 3-5 sentences, "Known Limitations" to 5 bullets

## Behavior

### Generating Capability Docs

Run `/opsx:docs` to generate documentation for all capabilities. For each baseline spec, the system creates a documentation file that transforms formal requirements into natural explanations and converts scenarios into readable usage descriptions.

### Archive Enrichment

For each capability, the system looks up archived changes that touched it. When archives are found, it reads the proposal, research, design, and preflight artifacts to add context:

- **Why This Exists** comes from the newest archive's proposal. For capabilities whose only archive is the initial bootstrap, this section is derived from the spec's purpose instead.
- **Background** summarizes research findings, approaches investigated, and alternatives explored. This section is omitted if research data is trivial or missing.
- **Known Limitations** combines design non-goals (rewritten as "does not support X"), design risks relevant to users, and preflight assumptions rated as acceptable risks. This section is omitted if there are no relevant items.

### Fallback for Unenriched Capabilities

If no archived changes exist for a capability, the system generates a spec-only doc with overview, features, behavior, and edge cases sections -- no enriched sections.

### Table of Contents

The system creates or updates a documentation index with links to the architecture overview, a table of all capability documents ordered by their position, and a link to the decision records index.

## Known Limitations

- Does not support incremental generation; all docs are fully regenerated on each run
- Does not include implementation details or internal architecture references
- Does not generate documentation from task artifacts (implementation-internal, no user value)
- Research context is integrated into capability docs indirectly; there is no separate research log output

## Edge Cases

- If no baseline specs exist, the system informs you and suggests running `/opsx:sync` first.
- If a spec has no scenarios, the system still generates documentation from requirement descriptions, noting that usage examples are unavailable.
- Existing documentation files are overwritten with freshly generated content, since specs are the source of truth.
- If an archive lacks certain artifacts (e.g., no design.md or no research.md), the system skips enrichment from that artifact without error.
