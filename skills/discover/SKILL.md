---
name: discover
description: Interactive research with Q&A for complex features. Generates only research.md with targeted clarification questions, then pauses for user answers.
disable-model-invocation: false
---

# /opsx:discover — Discovery & Research

> Interactive research with Q&A — use instead of `/opsx:ff` for complex features.

**Input**: Optionally specify a change name. If omitted, infer from context or auto-select if only one active change exists.

## Instructions

### Prerequisite: Verify Setup

Run `openspec schema which opsx-enhanced --json`. If it fails, tell the user to run `/opsx:setup` first and stop.

### Step 1: Select Change

If no change name provided:
- Infer from conversation context
- Auto-select if only one active change exists
- If ambiguous, run `openspec list --json` and ask the user to select

### Step 2: Read Context

1. Read `openspec/constitution.md` for project rules and conventions.
2. Read the current change directory (`openspec/changes/<change-name>/`).
3. Check if `openspec/specs/` reflects the current codebase. If code was changed outside the spec process (hotfixes, dependency updates), note this as stale-spec risk in the research.

### Step 3: Get Research Instructions

```bash
openspec instructions research --change "<name>" --json
```

This returns the schema instruction, template, context, and output path. Use the `instruction` field for content guidance and the `template` field for structure.

### Step 4: Generate Research

Create `research.md` following the instruction and template from the CLI output. Read any dependency files listed in the response for context.

### Step 5: Pause for Q&A

Present findings and open questions to the user. Wait for answers.
- Only ask questions for **Partial** or **Missing** coverage categories.
- Max 5 questions, prioritized by Impact x Uncertainty.
- If everything is Clear — state that and skip questions.

### Step 6: Record Decisions

After user feedback, fill the Decisions section with rationale and alternatives considered.

Save `research.md` and stop. The user can then run `/opsx:ff` for remaining artifacts.

---

## Output On Completion

```
## Discovery Complete

**Change**: <change-name>
**Output**: research.md

### Coverage Assessment
- Clear: N categories
- Partial: N categories (questions asked)
- Missing: N categories (questions asked)

### Decisions Recorded
- [Decision summary]

Next: Run `/opsx:ff` to generate remaining artifacts.
```

## Guardrails

- Always read constitution before generating research
- Use `openspec instructions` CLI for schema-specific guidance — do not hardcode instruction content
- If no active change exists, tell the user to run `/opsx:new` first
- Do not proceed past research — stop after saving research.md
- Do not generate proposal, specs, design, or other artifacts
