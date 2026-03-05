---
title: "Roadmap Tracking"
capability: "roadmap-tracking"
description: "Track planned improvements as GitHub Issues with a roadmap label"
lastUpdated: "2026-03-05"
---

# Roadmap Tracking

Planned improvements and future features are tracked as GitHub Issues with the `roadmap` label, providing a single always-current view via a filtered link in the project README.

## Why This Exists

Without a clear place to capture future ideas, improvements get lost in conversation history, scattered across documents, or forgotten entirely. Using the existing issue tracker with a dedicated label means the roadmap is always current, requires no manual sync, and integrates with the tools your team already uses.

## Design Rationale

The README links to a filtered GitHub Issues view rather than listing items inline. This means the roadmap is always in sync with the actual issue tracker -- when you create or close an issue, the roadmap updates automatically without requiring README edits.

## Features

- Planned improvements tracked as GitHub Issues with the `roadmap` label
- README contains a Roadmap section linking to the filtered issue view
- Roadmap stays current automatically -- no manual sync needed
- Each roadmap issue includes enough context to start a `/opsx:new` change
- Completed roadmap items closed when their change is archived
- Issues discovered during development can be captured without derailing current work

## Behavior

### Creating Roadmap Items

When you identify an improvement during development, review, or spec work, you create a GitHub Issue with the `roadmap` label. The issue describes the improvement with enough context for a developer to understand the intent and scope.

### Viewing the Roadmap

The README contains a Roadmap section with a link to the GitHub Issues filtered by the `roadmap` label. Clicking the link shows all open roadmap items, always reflecting the current state.

### Completing Roadmap Items

When a roadmap item is implemented through the spec-driven workflow and archived, the corresponding issue is closed. It no longer appears in the active roadmap view.

### Capturing Ideas During Work

If you notice an improvement while working on a current change, you create a roadmap issue to capture it for future prioritization without interrupting your current work.

## Edge Cases

- If no roadmap issues exist, the filtered view shows an empty list. The link remains valid and populates as issues are created.
- If an issue is created without the `roadmap` label, it does not appear in the roadmap view. Periodic review of unlabeled issues can catch missed labels.
- If the `roadmap` label does not exist in the repository, it needs to be created when the first roadmap issue is added.
- If the roadmap grows large, GitHub milestones or project boards can be used for grouping, but the label and README link remain the primary entry point.
