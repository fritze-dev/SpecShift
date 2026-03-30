# Research: Fix Background Sync Race Condition

## 1. Current State

The archive skill ([SKILL.md:59](src/skills/archive/SKILL.md#L59)) invokes sync via the Agent/Task tool:

```
Automatically invoke sync using Task tool (subagent_type: "general-purpose", prompt: "Use Skill tool to invoke opsx:sync for change '<name>'. ...")
```

**The race condition**: The Agent tool supports `run_in_background: true`. Nothing in the skill explicitly prohibits background execution. An LLM executing the archive skill can launch the sync agent in the background and immediately proceed to step 5 (move directory to archive). The sync agent writes to `openspec/specs/` after the archive commit is already made, leaving uncommitted spec changes.

**Affected files:**
- `src/skills/archive/SKILL.md` — step 4 (auto-sync delta specs), line 59
- `openspec/specs/change-workspace/spec.md` — "Auto-sync before archiving" scenario (line 80-85)
- `openspec/specs/spec-sync/spec.md` — assumption about sequential execution (line 94)

**Current spec language** (change-workspace spec, line 85):
> "SHALL proceed to archive after sync completes"

This correctly states the intent, but the skill implementation does not enforce it because it delegates sync to a subagent without explicitly requiring foreground execution.

**spec-sync assumption** (line 94):
> "Only one sync operation runs at a time; there is no concurrent merge protection beyond sequential execution."

This assumption is violated when sync runs as a background agent.

## 2. External Research

N/A — this is an internal workflow issue.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A. Use Skill tool directly** — Replace the Agent/Task tool invocation with a direct `Skill tool` call to `opsx:sync` | Simplest fix. No subagent overhead. Synchronous by design — Skill tool cannot run in background. | Sync runs in the main context window, consuming tokens. |
| **B. Add explicit foreground constraint** — Keep the Agent/Task tool but add "do NOT use run_in_background" to the instruction | Preserves context isolation (sync in subagent). | Still relies on LLM following the instruction. Agent tool default is foreground, so this just makes the implicit explicit. |
| **C. Restructure archive to commit after sync** — Add an explicit "wait for sync, then commit" sequence | Addresses the symptom (uncommitted changes). | Doesn't fix the root cause — sync could still race with the mv/archive step. |

**Recommended**: Approach A (use Skill tool directly). It eliminates the race condition structurally — the Skill tool is synchronous and cannot run in background. The sync operation is fast enough that context window impact is negligible.

## 4. Risks & Constraints

- **Low risk**: The change is confined to a single instruction line in the archive skill and a spec clarification.
- **No breaking changes**: The behavior (sync before archive) is already the intent — we're just enforcing the ordering.
- **Skill immutability rule**: The constitution states skills are generic plugin code. This fix modifies the archive skill's invocation mechanism, which is valid — it's a bug fix, not project-specific behavior.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Single line change in archive skill + spec clarification |
| Behavior | Clear | Sync must complete before archive proceeds |
| Data Model | Clear | No data model changes |
| UX | Clear | No user-facing changes — sync already runs automatically |
| Integration | Clear | Skill tool replaces Agent tool for sync invocation |
| Edge Cases | Clear | Sync failure already blocks archive (line 60) |
| Constraints | Clear | Skill immutability allows bug fixes |
| Terminology | Clear | No new terms |
| Non-Functional | Clear | Sync is fast; no performance concern |

All categories Clear — no open questions needed.

## 6. Open Questions

None — all categories are Clear.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Keep Agent/Task tool but fix via subagent prompt and result validation | Preserves context isolation (sync in subagent). Fix at the instruction level: explicit "do NOT use run_in_background" in the prompt, and/or validate that sync actually completed before proceeding to archive. Side effects should be fixed where they originate, not by switching invocation mechanism. | Switch to Skill tool (structural but loses context isolation); restructure commit ordering (doesn't fix root cause) |
