---
id: claude
template-version: 2
description: CLAUDE.md bootstrap template with standard agent directives
generates: CLAUDE.md
requires: []
instruction: |
  Generate CLAUDE.md with project-specific agent instructions.
  Always include the Workflow and Knowledge Management sections.
  Add project-specific rules discovered during codebase analysis.
  Use REVIEW markers for items needing user confirmation.
---
# Project Rules

## Workflow

All changes to this project MUST go through the spec-driven workflow. Before editing ANY file (source code, specs, skills, templates, docs, or configuration), invoke the specshift skill with the appropriate action (propose, apply, finalize, init). Never edit files directly — always use `specshift propose` to plan changes and `specshift apply` to implement them.

## Knowledge Management

Do not use auto-memory for project knowledge (architecture decisions, conventions, design rationale, workflow patterns). Instead:
- **Rules/conventions** → propose a CONSTITUTION.md update via specshift propose
- **Decisions with rationale** → these emerge naturally as design.md artifacts and ADRs during the change flow
- **Requirements** → propose spec updates via specshift propose
- **Friction/bugs** → file a GitHub Issue

Auto-memory is appropriate only for user preferences and session-specific feedback that do not belong in project artifacts.
