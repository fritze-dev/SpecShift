---
title: "Roadmap Tracking"
capability: "roadmap-tracking"
description: "Planned improvements tracked as GitHub Issues with roadmap label"
order: 15
lastUpdated: "2026-03-02"
---

# Roadmap Tracking

Planned improvements and future features are tracked as GitHub Issues labeled `roadmap`. The README links to the filtered issue list for an always-current view of planned work.

## Features

- Track improvements as GitHub Issues with the `roadmap` label
- README contains a Roadmap section linking to the filtered issue view
- Roadmap stays current automatically without manual README updates
- Issues are actionable with enough context to start a change

## Behavior

### Creating Roadmap Issues

When you identify an improvement during development, review, or spec work that's outside the current change's scope, create a GitHub Issue with the `roadmap` label. Include a clear title, description, and enough context for someone to act on it independently.

### README Integration

The project README has a Roadmap section with a link to GitHub Issues filtered by the `roadmap` label. When new roadmap issues are created, they appear in the filtered list automatically.

### Completing Roadmap Items

When a roadmap issue is implemented through the spec-driven workflow and archived, the corresponding issue is closed. It disappears from the active roadmap view.

## Edge Cases

- If no roadmap issues exist, the README link shows an empty list that populates as issues are created.
- If an issue is created without the `roadmap` label, it won't appear in the filtered view. Periodic review of unlabeled issues is recommended.
- If the `roadmap` label doesn't exist in the repository, it needs to be created with the first roadmap issue.
- For large numbers of issues, GitHub milestones or project boards can be used for grouping, but the label and README link remain the primary entry point.
- Stale issues that have been open too long should be periodically reviewed and closed or updated.
