# Pre-Flight Check: Enforce Plan-Mode Workflow Routing

## A. Traceability Matrix

- [x] CLAUDE.md Bootstrap requirement (project-init spec, line 274) → Scenario: CLAUDE.md generated on fresh init → `CLAUDE.md`, `src/templates/claude.md`

Only one requirement is modified, and the change is a wording expansion to include workflow routing. All scenarios remain valid — the existing scenario "CLAUDE.md generated on fresh init" already checks for a `## Planning` section; the content of that section is governed by the template, which we are updating.

## B. Gap Analysis

No gaps identified. The change is a single paragraph addition to two files plus a minor spec wording update. Edge cases:
- Trivial plans: preserved — the "one-line scope statement" ethos in the existing Planning section still applies. The new rule says plans must *route through specshift*, not mandate a specific format.
- Plans for non-implementation tasks (research, discussion): not affected — the rule applies to "implementation steps" specifically.

## C. Side-Effect Analysis

- **Consumer projects**: Will see a WARNING on `specshift init` re-run because `src/templates/claude.md` template-version increases. This is by design and informational.
- **Compilation**: `bash scripts/compile-skills.sh` will validate the template-version bump. No risk if version is bumped correctly (3 -> 4).
- **No regression risk**: No behavioral code changes, no template structure changes.

## D. Constitution Check

- "Agent instructions: Project-level agent instructions live in CLAUDE.md" — consistent. The new rule goes in CLAUDE.md.
- "Template-version discipline" — will be satisfied by bumping template-version from 3 to 4.
- "Template synchronization" — the consumer template and project CLAUDE.md will both contain the rule.
- No new patterns or technologies introduced.

## E. Duplication & Consistency

- The new paragraph does NOT duplicate the Workflow section's action list. It deliberately references "the specshift workflow skill" generically rather than enumerating actions.
- No contradictions with existing specs or constitution.

## F. Assumption Audit

No `<!-- ASSUMPTION -->` markers in specs or design for this change.

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any artifacts for this change.

---

**Verdict: PASS**

| Category | Findings | Blockers | Warnings |
|----------|----------|----------|----------|
| Traceability | 1 requirement traced | 0 | 0 |
| Gap Analysis | No gaps | 0 | 0 |
| Side Effects | Consumer WARNING expected | 0 | 0 |
| Constitution | Consistent | 0 | 0 |
| Duplication | No overlaps | 0 | 0 |
| Assumptions | None | 0 | 0 |
| Review Markers | None | 0 | 0 |
| **Total** | | **0** | **0** |
