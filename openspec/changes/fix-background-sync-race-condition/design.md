# Technical Design: Fix Background Sync Race Condition

## Context

The archive skill's step 4 delegates spec sync to a subagent via the Agent/Task tool. The current subagent prompt is:

```
"Use Skill tool to invoke opsx:sync for change '<name>'. Delta spec analysis: <include the analyzed delta spec summary>"
```

This prompt lacks context about why sync must complete before archive proceeds. The LLM has no signal that this is a blocking prerequisite, so it may schedule the agent in the background or issue parallel tool calls. Additionally, there is no validation of the agent result — step 5 (mv to archive) starts unconditionally after the agent call.

## Architecture & Components

**Single file affected:** `src/skills/archive/SKILL.md` — step 4

Two changes within step 4:

1. **Subagent prompt** (line 59): Rewrite to convey blocking intent. The prompt must explain that sync writes to `openspec/specs/` and that these changes must be committed as part of the archive — therefore sync must complete and return its result before the workflow continues.

2. **Result validation** (new, between current lines 60-61): After the agent returns, inspect the result. The sync skill's output format is documented — it reports "Specs Synced: <name>" with a list of applied changes on success. Validate that the result contains a success indicator before proceeding to step 5.

**No other files change.** The sync skill itself, the spec-sync spec, and the workflow config remain untouched.

## Goals & Success Metrics

* **Prompt clarity**: The subagent prompt explicitly states that sync is a blocking prerequisite and must return its result before archive proceeds — PASS/FAIL by inspection of the prompt text.
* **Validation gate**: The archive skill contains an explicit validation step that checks the sync agent result for success before proceeding to step 5 — PASS/FAIL by inspection of the skill text.
* **Failure path**: If the sync result does not confirm success (failure or ambiguous), the archive skill stops and reports the issue — PASS/FAIL by inspection.

## Non-Goals

- Changing the sync skill's behavior or output format
- Switching from Agent/Task tool to Skill tool
- Adding programmatic validation (file diffing, git status checks) — the validation is on the agent result text
- Auditing other subagent invocations across skills

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Rewrite subagent prompt to include blocking context | The LLM needs to understand *why* sync must complete first — not just *what* to do. Explaining that sync writes files needed for the archive commit gives the LLM enough context to prioritize sequential execution. | Add "do NOT use run_in_background" (treats symptom, not cause — LLM could still parallelize tool calls) |
| Validate agent result text for success indicator | The sync skill already has a documented output format ("Specs Synced: <name>"). Checking for this in the result is lightweight and doesn't require file system inspection. | Check git status for uncommitted changes (heavier, couples archive to git state); trust the agent (current behavior, caused the bug) |

## Risks & Trade-offs

- **[LLM may still ignore prompt context]** → Mitigation: The validation gate is the safety net. Even if the LLM mishandles scheduling, the archive cannot proceed without a validated success result. The two fixes are defense-in-depth.
- **[Sync output format may change]** → Mitigation: The validation should check for a reasonable success signal, not an exact string match. If the result is ambiguous, fail safe by blocking archive.

## Open Questions

No open questions.

## Assumptions

- The sync skill's output format ("Specs Synced: <name>" on success) is stable and can be used as a validation signal. <!-- ASSUMPTION: Sync output format stability -->
