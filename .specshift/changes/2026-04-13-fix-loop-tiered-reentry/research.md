# Research: Fix Loop Tiered Re-entry

## 1. Current State

The `specshift apply` action uses a **Fix Loop** to handle review corrections. The fix loop is defined in two places:

**`src/templates/workflow.md` (apply instruction):**
```
Fix loop: after any fix, regenerate review.md before presenting to user.
Artifact freshness: update preflight/design if fix resolves flagged issues.
```

**`src/templates/changes/tasks.md` (QA Loop step 3.4):**
```
Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify.
Specs must match code before proceeding.
```

**`docs/specs/human-approval-gate.md` (Fix Loop requirement):**
The Fix Loop requirement describes two valid resolutions: (a) fix code to match spec, or (b) update spec/design to match implementation. It covers re-verification after fixes. It does NOT define a classification of correction severity or specify when artifacts must be discarded and rebuilt vs. patched in place.

**Key gap:** The Fix Loop provides no heuristic to distinguish "fix a typo" from "wrong approach entirely." When an approach change occurs (different files modified, different abstraction used), the agent lacks explicit guidance to escalate beyond patching. This leads to:
- Multiple revert/fix commits instead of a clean reimplementation
- Stale change artifacts (design.md, tasks.md, review.md) that describe the original approach after a pivot
- Artifact staleness: review.md may show PASS on metrics that no longer apply

**Evidence from issue #13:**
PR #12 required corrections to:
1. Wrong file edited (`.specshift/CONSTITUTION.md` instead of `src/templates/constitution.md`)
2. Plugin-specific logic in consumer templates
3. Unnecessary changes to project-only files

These were approach changes (different files, different scope), not typos. The agent entered patch mode and produced 5+ fix commits rather than updating design → discarding affected tasks → re-implementing.

## 2. External Research

No external dependencies. The fix is purely to workflow instructions and spec text.

The concept of "tiered escalation" for review corrections is well-established in engineering review processes (RFC/code review), with typical tiers: cosmetic fix → design change → requirements change. Applying this to specshift's artifact pipeline is a natural extension.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A. Clarify existing fix loop only** | Minimal change; addresses root cause (checklist compliance); no new mechanics | Doesn't add explicit tier vocabulary; leaves classification implicit |
| **B. Add tiered re-entry classification** | Explicit vocabulary (Tweak / Design Pivot / Scope Change); concrete detection signals; agents can self-classify; cleaner escalation path | Slightly more complex instruction text; tier boundary edge cases |
| **C. Separate "re-entry" action** | Clean separation; re-entry has its own UX | Over-engineered; the fix loop already covers this; unnecessary new action |

**Selected:** Approach B with elements of A — add tiered classification to the Fix Loop requirement in `human-approval-gate.md` and update the apply instruction in `workflow.md` and the Fix Loop step in the tasks template. This addresses both the root cause (missing explicit activation criteria) and the structural gap (no guidance on depth of re-entry).

## 4. Risks & Constraints

- **Low risk**: all changes are to spec text, workflow instructions, and template instructions — no executable code
- **Boundary ambiguity**: the line between Design Pivot and Scope Change may be fuzzy. Mitigation: provide concrete detection signals rather than subjective labels alone
- **Template sync**: `src/templates/workflow.md` is authoritative; must sync to `.specshift/WORKFLOW.md`. Same for `src/templates/changes/tasks.md` → `.specshift/templates/changes/tasks.md`
- **AOT compilation**: After editing specs, `bash scripts/compile-skills.sh` must be run to regenerate the compiled action files in `.claude/skills/specshift/actions/`

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Fix Loop in human-approval-gate spec + workflow apply instruction + tasks template step 3.4 |
| Behavior | Clear | Tiered classification: Tweak / Design Pivot / Scope Change with concrete detection signals |
| Data Model | Clear | No data model changes — text/markdown edits only |
| UX | Clear | Agent self-classifies correction tier; no new user-facing commands |
| Integration | Clear | Must recompile AOT action files after spec/template edits |
| Edge Cases | Clear | Tier boundary cases; fix loop with no re-entry needed |
| Constraints | Clear | Template sync direction: src → .specshift |
| Terminology | Clear | Tweak / Design Pivot / Scope Change aligned with issue #13 vocabulary |
| Non-Functional | Clear | No performance or scalability concerns |

## 6. Open Questions

All categories Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Approach B: tiered classification | Explicit vocabulary prevents ambiguity; concrete signals allow agent self-classification | Approach A (clarify only) — insufficient; Approach C (new action) — over-engineered |
| 2 | Three tiers: Tweak / Design Pivot / Scope Change | Matches issue #13 comment vocabulary; covers all real cases from PR #12 | Two tiers (fix vs. re-enter) — too coarse; four+ tiers — unnecessary complexity |
| 3 | Detection signals as explicit checklist | Reduces subjectivity; agent can check signals mechanically before choosing tier | Subjective judgment only — shown to fail (PR #12) |
| 4 | Single combined change to spec + workflow + template | All three are tightly coupled; separate changes would leave them inconsistent | Separate changes — unnecessary overhead |
