---
title: "Interactive Discovery"
capability: "interactive-discovery"
description: "Standalone research with targeted Q&A for complex features using /opsx:discover"
order: 11
lastUpdated: "2026-03-02"
---

# Interactive Discovery

Run `/opsx:discover` for a dedicated research phase with targeted questions. It generates only research.md and pauses for your answers before proceeding.

## Features

- Standalone research that generates only research.md without advancing the pipeline
- Coverage assessment rating each category as Clear, Partial, or Missing
- Targeted questions only for Partial/Missing categories, limited to 5
- Stale-spec detection comparing baseline specs against current codebase

## Behavior

### Research and Coverage Assessment

Discovery reads the constitution, change directory, and existing baseline specs, then generates research.md with findings. Each category (Scope, Behavior, Data Model, UX, Integration, Edge Cases, Constraints, Terminology, Non-Functional) is rated as Clear, Partial, or Missing.

### Targeted Questions

Questions are generated only for Partial or Missing categories, limited to a maximum of 5, prioritized by Impact times Uncertainty. If all categories are Clear, no questions are asked and the system suggests running `/opsx:ff`.

### Recording Decisions

After you answer questions, the system records each decision with rationale in the Decisions section of research.md and stops. No further artifacts are generated.

### Stale-Spec Detection

If existing baseline specs reference code that has changed (e.g., renamed functions), the system notes these stale-spec risks in the coverage assessment.

## Edge Cases

- If you answer some questions but not all, decisions are recorded for answered ones and unanswered ones are marked as "Deferred."
- If answers contradict each other, the system flags the contradiction and asks for clarification.
- If research.md already exists, it is overwritten with fresh research (with a warning).
- If no baseline specs exist (bootstrap scenario), stale-spec analysis is skipped.
- If no active change exists, the system suggests running `/opsx:new` first.
- If the change has all artifacts complete, discovery still allows re-running research but warns about invalidating downstream artifacts.
