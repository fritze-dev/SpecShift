---
title: "Task Implementation"
capability: "task-implementation"
description: "Systematic task execution from checklists with progress tracking and pause-on-blocker behavior"
order: 11
lastUpdated: "2026-03-04"
---

# Task Implementation

Work through your task checklist systematically with `/opsx:apply`. The system reads each task, makes the required changes, marks it complete, and moves to the next -- pausing when it encounters anything unclear.

## Why This Exists

Implementing changes involves working through a structured task list where each item corresponds to a specific code change. This capability automates the sequential execution of those tasks so you can focus on review and guidance rather than manually coding each item.

## Features

- Sequential execution of pending tasks from the task checklist
- Automatic progress tracking with "N/M tasks complete" counts
- Pause-on-blocker behavior for ambiguous tasks or design issues
- Resume from where you left off in a partially completed list
- Context-aware implementation using all pipeline artifacts (proposal, specs, design, tasks)
- Recognizes `[P]` markers for parallelizable tasks (informational only)

## Behavior

### Working Through Tasks

Run `/opsx:apply` to start working through pending tasks. The system reads all context files first, then begins with the first uncompleted task. For each task, it reads the description, makes the required code changes, and marks the checkbox as complete. It then continues to the next task until all are done or a blocker is encountered.

If some tasks are already complete, the system skips them and picks up from the first pending task, showing how many are already done.

### Progress Tracking

Progress is displayed as "N/M tasks complete" at the start of a session, after each task completion, and in the final summary. When all tasks are complete, the system displays a completion message and suggests archiving the change.

### Pausing on Blockers

The system pauses and asks for your input when a task description is ambiguous or could be interpreted multiple ways, when implementation reveals a design issue or technical constraint that conflicts with the plan, or when any other blocker is encountered. It does not guess when requirements are unclear. When paused, it shows current progress and presents options for how to proceed.

### All Tasks Complete

If all tasks are already marked complete when you run `/opsx:apply`, the system reports this and suggests archiving the change.

## Edge Cases

- If the task file exists but contains no checkbox items, the system reports "0/0 tasks" and suggests it may need to be regenerated.
- If checkboxes do not follow the standard format exactly, the system ignores them in the count and notes the discrepancy.
- If you manually edit the task file between sessions (adding, removing, or reordering tasks), the system re-reads the file and computes progress from the current state.
- If the task file does not exist, the system reports the missing artifact and suggests running the artifact pipeline to generate it.
- If completed tasks appear after pending tasks (out of order), the system still counts correctly and works on pending tasks regardless of position.
