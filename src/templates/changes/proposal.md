---
id: proposal
template-version: 4
description: Problem statement, proposed solution, expected impact, and Discovery
generates: proposal.md
requires: []
instruction: |
  Create the proposal document that establishes WHY this change is needed and
  records the Discovery work that informs it.

  Sections:
  - **Why**: 1-2 sentences on the problem or opportunity. What problem does this solve? Why now?
  - **What Changes**: Bullet list of changes. Be specific about new capabilities, modifications, or removals. Mark breaking changes with **BREAKING**.
  - **Capabilities**: Identify which specs will be created or modified:
    - **New Capabilities**: List capabilities being introduced. Each becomes a new `docs/specs/<name>.md`. Use kebab-case names (e.g., `user-auth`, `data-export`).
    - **Modified Capabilities**: List existing capabilities whose REQUIREMENTS are changing. Only include if spec-level behavior changes (not just implementation details). Each edits the existing spec file in place. Check `docs/specs/` for existing spec names. Leave empty if no requirement changes.
  - **Impact**: Affected code, APIs, dependencies, or systems.
  - **Scope & Boundaries**: Explicitly state what is and isn't part of this change.
  - **Discovery**: Always present (not optional). Captures the research that motivates the proposal. Subsections:
    - **Current State**: Affected code, modules, architecture, relevant patterns
    - **External Research**: API docs, libraries, patterns, reference implementations (if applicable)
    - **Approaches**: Possible solutions with trade-offs (table: Approach / Pro / Contra)
    - **Coverage Assessment**: Rate each category as Clear/Partial/Missing — Scope, Behavior, Data Model, UX, Integration, Edge Cases, Constraints, Terminology, Non-Functional. Only ask the user clarifying questions for Partial/Missing categories (max 5, prioritized by Impact × Uncertainty). If everything is Clear, state that and move on.
    - **Decisions**: Record decisions with rationale and alternatives considered after the user responds (table: # / Decision / Rationale / Alternatives Considered). If no clarifying questions were needed, state "No discovery decisions required."

  Capability Granularity Rules:
  - A "capability" is a cohesive domain of behavior that a user or system
    exercises independently (e.g., "data-export", "user-auth"). It typically
    has 3-8 requirements and maps to one testable surface area.
  - A "feature detail" is a single behavior, option, or edge case WITHIN a
    capability. Feature details belong as requirements inside an existing
    spec — NOT as separate specs.
  - Rule of thumb: if two proposed capabilities share the same actor, trigger,
    or data model, they are likely one capability. Merge them.
  - Target: ~250-350 lines per spec. If a proposed capability would produce
    fewer than ~100 lines (1-2 requirements), it should be folded into a
    related existing capability.

  IMPORTANT: The Capabilities section is critical. It creates the contract between
  proposal and specs phases. Each capability listed here will need a corresponding
  spec file.

  Consolidation Check (MANDATORY before finalizing Capabilities):
  1. List all existing specs in docs/specs/ and read their ## Purpose sections.
  2. For each proposed new capability, check: does an existing spec already cover
     this domain? If yes → use Modified Capabilities instead of creating a new spec.
  3. For each pair of proposed new capabilities, check: do they share an actor,
     trigger, or data model? If yes → merge them into one capability.
  4. Verify each proposed capability will have 3+ distinct requirements.
     Single-requirement "capabilities" should be folded into a related spec.

  Discovery context loading:
  - Always read: docs/specs/*.md (source of truth),
    docs/README.md (architecture overview and Key Design Decisions index)
  - When relevant: docs/decisions/adr-*.md — use the Key Design
    Decisions table in docs/README.md as index; deep-dive into
    specific ADRs only when the proposed change touches an area
    with a prior decision
  - Do not read: docs/capabilities/*.md (derived from specs, redundant)

  Keep Why/What/Impact/Scope concise (1-2 pages). Discovery may be longer
  when the change is non-trivial. Focus on the "why" not the "how" —
  implementation details belong in design.md.
---
<!-- Proposal tracking frontmatter — set by skills at generation time.
     status: active | review | completed (active→review when audit passes, review→completed after merge)
     branch: git branch name for this change
     capabilities: machine-readable mirror of the Capabilities section below
---
status: active
branch: [branch-name]
capabilities:
  new: []
  modified: []
  removed: []
---
-->
## Why

<!-- Explain the motivation for this change. What problem does this solve? Why now? -->

## What Changes

<!-- Describe what will change. Be specific about new capabilities, modifications, or removals. -->

## Capabilities

### New Capabilities
<!-- Capabilities being introduced. Replace <name> with kebab-case identifier (e.g., user-auth, data-export, api-rate-limiting). Each creates docs/specs/<name>.md -->
- `<name>`: <brief description of what this capability covers>

### Modified Capabilities
<!-- Existing capabilities whose REQUIREMENTS are changing (not just implementation).
     Only list here if spec-level behavior changes.
     Use existing spec names from docs/specs/. Leave empty if no requirement changes. -->
- `<existing-name>`: <what requirement is changing>

### Removed Capabilities
<!-- Capabilities being entirely removed. Include reason and migration path.
     Leave empty if no capabilities are removed. -->
- `<existing-name>`: <reason for removal, migration path>

### Consolidation Check
<!-- MANDATORY: Show your work before finalizing the Capabilities lists above.
     1. Existing specs reviewed: [list spec names from docs/specs/ that you checked]
     2. Overlap assessment: [for each new capability, state which existing spec was closest and why this is distinct OR why you chose Modified instead]
     3. Merge assessment: [for any pair of new capabilities, state whether they share actor/trigger/data and whether they were merged]
     If no new capabilities: write "N/A — no new specs proposed." -->

## Impact

<!-- Affected code, APIs, dependencies, systems -->

## Scope & Boundaries

<!-- What is part of this change, what is not? -->

## Discovery

<!-- Always present. Captures the research that motivates the proposal. -->

### Current State
<!-- Affected code, modules, architecture, relevant patterns -->

### External Research
<!-- API docs, libraries, patterns, reference implementations (if applicable) -->

### Approaches
<!-- Possible solutions with trade-offs -->

| Approach | Pro | Contra |
|----------|-----|--------|

### Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear / Partial / Missing | |
| Behavior | Clear / Partial / Missing | |
| Data Model | Clear / Partial / Missing | |
| UX | Clear / Partial / Missing | |
| Integration | Clear / Partial / Missing | |
| Edge Cases | Clear / Partial / Missing | |
| Constraints | Clear / Partial / Missing | |
| Terminology | Clear / Partial / Missing | |
| Non-Functional | Clear / Partial / Missing | |

### Decisions
<!-- Filled after user feedback for Partial/Missing categories.
     If everything was Clear, state "No discovery decisions required." -->

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
