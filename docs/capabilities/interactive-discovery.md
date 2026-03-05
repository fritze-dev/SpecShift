---
title: "Interactive Discovery"
capability: "interactive-discovery"
description: "Standalone interactive research with targeted Q&A for complex features"
lastUpdated: "2026-03-05"
---

# Interactive Discovery

The `/opsx:discover` command runs a standalone interactive research session with targeted questions for complex features. It generates only the research.md artifact, then pauses for your answers before stopping.

## Why This Exists

Complex features have ambiguities that generic research cannot resolve. Without an interactive discovery phase, these ambiguities surface late -- during specs, design, or even implementation -- when they are expensive to address. Discovery catches unknowns early by assessing coverage across key categories and asking targeted questions only where gaps exist.

## Design Rationale

Questions are limited to a maximum of 5, prioritized by Impact multiplied by Uncertainty. This prevents question fatigue while ensuring the most important unknowns are addressed first. Discovery operates independently from the pipeline -- it only generates research.md and then stops, letting you decide when to continue with the rest of the pipeline.

## Features

- Reads the constitution, change directory, and existing baseline specs for context
- Generates research.md with a coverage assessment rating each category as Clear, Partial, or Missing
- Asks targeted clarification questions only for Partial or Missing categories (maximum 5)
- Prioritizes questions by Impact multiplied by Uncertainty
- Records decisions with rationale after you provide answers
- Detects stale-spec risks by comparing baseline specs against the current codebase
- Skips questions entirely when all categories are Clear

## Behavior

### Running Discovery

When you run `/opsx:discover`, the system reads your project context and generates research.md with coverage ratings across categories like Scope, Behavior, Data Model, UX, Integration, Edge Cases, Constraints, Terminology, and Non-Functional. For each Partial or Missing category, it formulates targeted questions.

### Answering Questions

After presenting questions, the system pauses and waits for your answers. Once you respond, it records each decision in the Decisions section of research.md with the decision text, rationale, and alternatives considered. The system then stops -- it does not generate further artifacts.

### All Categories Clear

For straightforward changes (e.g., fixing a typo), all categories may be rated Clear. In this case, the system states that no questions are needed, saves research.md, and suggests running `/opsx:ff` to generate remaining artifacts.

### Stale-Spec Detection

If the system finds that baseline specs reference code elements (like function names) that have changed in the codebase, it notes the stale-spec risk in the coverage assessment.

## Edge Cases

- If you answer some questions but not all, the system records decisions for answered questions and marks unanswered ones as "Deferred -- no answer provided."
- If your answers contradict each other, the system flags the contradiction and asks for clarification before recording.
- If research.md already exists, the system warns you that existing research will be replaced before overwriting.
- If no baseline specs exist (e.g., bootstrap scenario), the system proceeds without stale-spec analysis.
- If you run discover on a completed change, the system allows it but warns that re-running research may invalidate downstream artifacts.
- If no active change exists, the system tells you to create one with `/opsx:new` first.
