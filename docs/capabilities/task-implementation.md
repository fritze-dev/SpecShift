---
title: "Task Implementation"
capability: "task-implementation"
description: "Working through task checklists with /opsx:apply and progress tracking"
order: 8
lastUpdated: "2026-03-02"
---

# Task Implementation

Run `/opsx:apply` to work through the task checklist in tasks.md. The system implements each task, marks it complete, and tracks progress.

## Features

- Systematically works through pending tasks in order
- Marks each task complete immediately after finishing it
- Tracks and displays progress as "N/M tasks complete"
- Pauses on ambiguous tasks, design issues, or blockers instead of guessing

## Behavior

### Sequential Implementation

The system reads all context files (proposal, specs, design, tasks), then works through each pending `- [ ]` checkbox in order. After completing a task, it changes the checkbox to `- [x]` and moves to the next.

### Resuming Progress

If some tasks are already complete, the system skips them and starts from the first pending task, showing how many were already done.

### Pausing on Issues

The system pauses and asks for guidance when a task is ambiguous, when implementation reveals a design issue, or when a blocker is encountered. It presents specific questions or options rather than guessing.

### Progress Display

Progress is shown at session start, after each task, and in the final summary. When all tasks are done, the system suggests archiving.

## Edge Cases

- If tasks.md has no checkbox items, the system reports "0/0 tasks" and suggests regeneration.
- If checkboxes don't follow the exact `- [ ]` / `- [x]` format, they are ignored in the count.
- If tasks are manually edited between sessions, the system re-reads and computes from current state.
- If tasks.md doesn't exist, the system suggests running the artifact pipeline first.
- Tasks marked with `[P]` are informational (parallelizable) but don't change counting logic.
