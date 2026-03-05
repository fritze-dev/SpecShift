---
title: "Task Implementation"
capability: "task-implementation"
description: "Systematic implementation of task checklists with progress tracking"
lastUpdated: "2026-03-05"
---

# Task Implementation

The `/opsx:apply` command works through the task checklist in tasks.md, implementing each item sequentially, marking tasks complete as it goes, and pausing when it encounters blockers or ambiguities.

## Why This Exists

Manually implementing each task from a spec-driven plan is time-consuming and error-prone. Without systematic task execution, developers lose track of progress, skip items, or implement tasks out of the intended order. This capability lets you focus on review and guidance while the AI handles the methodical work of implementing each task.

## Design Rationale

Tasks are implemented sequentially rather than in parallel to maintain a clear, reviewable progression. The system pauses on ambiguity rather than guessing, because incorrect assumptions during implementation are far more expensive to fix than a brief pause for clarification. Progress tracking uses simple checkbox counting from tasks.md, keeping the mechanism transparent and auditable.

## Features

- Works through pending tasks in tasks.md sequentially
- Reads all context files (proposal, specs, design, tasks) before starting
- Marks each task `- [x]` immediately after completing it
- Pauses and asks for clarification on ambiguous tasks
- Pauses when implementation reveals design issues
- Resumes from where it left off on subsequent runs
- Displays progress as "N/M tasks complete" at each step
- Recognizes `[P]` markers as informational parallel-task indicators

## Behavior

### Starting Implementation

When you run `/opsx:apply`, the system reads all context files and checks the current state of tasks.md. It displays the current progress (e.g., "2/7 tasks complete") and begins working from the first pending task.

### Working Through Tasks

For each task, the system reads the description, makes the required code changes, and marks the checkbox as complete. It then reports the updated progress and announces which task it will work on next.

### Pausing on Problems

The system pauses in two situations: when a task description is ambiguous or could be interpreted multiple ways, and when implementation reveals that the design approach will not work due to a technical constraint. In both cases, it presents the issue, asks specific questions, and waits for your input before continuing.

### Resuming Partial Work

If you run `/opsx:apply` on a partially completed task list, the system skips already-completed tasks and resumes from the first pending one. It reports how many tasks were already done and which task it is starting from.

### Progress Reporting

Progress is displayed at session start, after each task completion, and when pausing. When all tasks are complete, the system shows a final summary listing all tasks completed during the session and suggests archiving the change.

## Edge Cases

- If tasks.md exists but contains no checkbox items, the system reports "0/0 tasks" and suggests the file may need to be regenerated.
- If tasks.md contains malformed checkboxes (not exactly `- [ ]` or `- [x]`), the system ignores them in the count and notes the discrepancy.
- If you manually edit tasks.md between sessions (adding, removing, or reordering tasks), the system re-reads the file and computes progress from the current state.
- If completed tasks appear after pending tasks (out of order), the system still counts correctly and works on pending tasks regardless of position.
