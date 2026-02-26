---
name: preflight
description: Standalone pre-flight quality check for specs and design artifacts. Use after manual changes to specs or design to validate consistency.
disable-model-invocation: false
---

# /opsx:preflight — Pre-Flight Quality Check

> Standalone quality review — use after manual changes to specs or design.

**Input**: Optionally specify a change name. If omitted, infer from context or auto-select if only one active change exists.

## Instructions

### Prerequisite: Verify Setup

Run `openspec schema which opsx-enhanced --json`. If it fails, tell the user to run `/opsx:init` first and stop.

### Step 1: Select Change

If no change name provided:
- Infer from conversation context
- Auto-select if only one active change exists
- If ambiguous, run `openspec list --json` and ask the user to select

### Step 2: Read Context

1. Read `openspec/constitution.md` for project rules and conventions.
2. Read all artifacts in the current change directory (`openspec/changes/<change-name>/`).
3. Read existing specs at `openspec/specs/` for cross-spec consistency.

### Step 3: Get Preflight Instructions

```bash
openspec instructions preflight --change "<name>" --json
```

This returns the schema instruction, template, context, and output path. Use the `instruction` field for content guidance and the `template` field for structure.

### Step 4: Execute Pre-Flight

Create `preflight.md` following the instruction and template from the CLI output. Read all dependency artifacts listed in the response.

The pre-flight covers:
- **A. Traceability Matrix** — Every story mapped to scenarios and components
- **B. Gap Analysis** — Missing edge cases, error handling, empty states
- **C. Side-Effect Analysis** — Impact on existing systems, regression risks
- **D. Constitution Check** — Consistency with project rules
- **E. Duplication & Consistency** — Overlaps and contradictions across specs
- **F. Assumption Audit** — All `<!-- ASSUMPTION -->` markers rated

### Step 5: Verdict

Summarize findings. Clearly state blockers if any.
The user must review and resolve issues before proceeding to task creation.

---

## Output On Completion

```
## Pre-Flight Complete

**Change**: <change-name>
**Output**: preflight.md

### Findings
- Blockers: N
- Warnings: N
- Info: N

### Assumptions Audited
- Acceptable Risk: N
- Needs Clarification: N
- Blocking: N

Verdict: PASS / PASS WITH WARNINGS / BLOCKED
```

## Guardrails

- Always read all change artifacts before running the check
- Use `openspec instructions` CLI for schema-specific guidance — do not hardcode instruction content
- If required artifacts (spec.md, design.md) are missing, abort with a clear message
- Do not auto-fix issues — report findings for the user to resolve
- Do not proceed to task creation — preflight is a review gate, not a generator
