# Research: Fix CLAUDE.md re-init drift + finalize version-bump conditionality

## 1. Current State

**Issue #10 — CLAUDE.md not checked on re-init:**
- `docs/specs/project-init.md` defines three init modes: Fresh, Update, Re-sync
- Template Merge on Re-Init (line 86) covers Smart Templates, WORKFLOW.md, CONSTITUTION.md — but NOT CLAUDE.md
- CLAUDE.md Bootstrap requirement (lines 271-293) says: "If CLAUDE.md already exists, init SHALL skip generation"
- Edge case (line 424): "User edits to CLAUDE.md are authoritative"
- CONSTITUTION.md uses section-level merge (compare headings, offer missing sections) — a ready pattern to reuse
- The bootstrap template at `src/templates/claude.md` already has `template-version: 1`

**Issue #11 — finalize version-bump assumes plugin project:**
- `docs/specs/release-workflow.md` has no `## Edge Cases` section (the spec itself has none)
- The capability doc `docs/capabilities/release-workflow.md:137-143` already documents: "If `src/.claude-plugin/plugin.json` does not exist, version bump is silently skipped"
- `.specshift/WORKFLOW.md` finalize instruction (line 76) lists version-bump unconditionally
- `.specshift/CONSTITUTION.md` convention (line 40) doesn't mention the consumer-project skip
- `src/templates/workflow.md` finalize (line 76) has the same unconditional text

**Additional finding — template sync direction wrong:**
- CONSTITUTION.md line 48 says changes flow `.specshift/WORKFLOW.md` → `src/templates/workflow.md`
- Correct direction: `src/templates/` is the authoritative plugin source, `.specshift/` is the project instance synced from it

## 2. External Research

N/A — both issues are internal workflow friction, no external dependencies.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **#10 Option A: Section-level WARNING** | Consistent with user-authoritative CLAUDE.md; non-destructive; reuses CONSTITUTION.md pattern | Doesn't auto-fix — user must act on WARNING |
| **#10 Option B: Full template merge** | Auto-propagates template updates | Conflicts with "user edits are authoritative" design; more complex |
| **#11: Conditionalize in instruction** | Simple text change; spec already has the edge case in capability doc | Requires spec update to add Edge Cases section |

**Selected:** #10 Option A + #11 conditionalize.

## 4. Risks & Constraints

- Low risk: all changes are to spec text, workflow instructions, and conventions — no executable code
- CLAUDE.md changes must go through `specshift propose` per project rules
- Template sync convention needs correction (wrong direction) — bundling this fix reduces future confusion

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Two friction issues + one convention correction |
| Behavior | Clear | Both issues have well-defined expected behavior in issue descriptions |
| Data Model | Clear | No data model changes — text/markdown edits only |
| UX | Clear | WARNINGs on re-init, silent skip on finalize |
| Integration | Clear | No integration points affected |
| Edge Cases | Clear | Both issues ARE edge case fixes |
| Constraints | Clear | User-authoritative CLAUDE.md constraint drives Option A |
| Terminology | Clear | Standard project terminology |
| Non-Functional | Clear | No performance or scalability concerns |

## 6. Open Questions

All categories Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Option A for #10 (section-level WARNING) | Respects user-authoritative CLAUDE.md design; reuses CONSTITUTION.md pattern | Option B (full merge) rejected — conflicts with spec edge case line 424 |
| 2 | Single combined change | Both are small friction fixes; precedent from prior friction batches | Separate changes — unnecessary overhead |
| 3 | Fix template sync direction | Convention currently wrong; bundling prevents future confusion | Separate issue — too small to warrant its own change |
| 4 | Add CLAUDE.md File Ownership section | Prevents edit-direction confusion in future sessions | Skip — risk of repeated friction |
