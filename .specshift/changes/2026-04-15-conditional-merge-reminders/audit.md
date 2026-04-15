## Audit: Conditional Post-Merge Reminders

### Summary

| Dimension | Status |
|-----------|--------|
| Tasks | 5/14 complete (4 implementation + 1 QA; 9 standard/QA remaining) |
| Requirements | 3/3 verified |
| Scenarios | 5/5 covered |
| Tests | 5/5 covered (manual test plan) |
| Scope | Clean — all changed files trace to tasks |

### Findings

#### CRITICAL

(none)

#### WARNING

(none)

#### SUGGESTION

(none)

### Requirement Verification

1. **Standard Tasks Exclusion from Apply Scope** (task-implementation.md) — post-merge conditional filtering documented with scenarios ✓
2. **Standard Tasks Directive in Task Generation** (artifact-pipeline.md) — scope-aware filtering mentioned ✓
3. **Template instruction** — tasks.md instruction updated to evaluate proposal scope ✓

### Scenario Coverage

1. **Conditional post-merge item excluded by scope** — Instruction says "Only include items whose scope matches the change" + "omit section 5 entirely" when no items relevant ✓
2. **Conditional post-merge item included by scope** — Instruction says evaluate relevance, include matching items, strip scope hints ✓
3. **Post-merge items without scope hints always included** — Instruction says "Items without a scope hint are always included" ✓
4. **Ambiguous scope** — Instruction says "When ambiguous, err on the side of inclusion" ✓
5. **All post-merge items filtered out** — Instruction says "or no items are relevant to the change scope, omit section 5 entirely" ✓

### Diff-Task Mapping

| Task | Files Changed |
|------|--------------|
| 1.1 (tasks template) | `src/templates/changes/tasks.md`, `.claude/skills/specshift/templates/changes/tasks.md` |
| 2.1 (constitution) | `.specshift/CONSTITUTION.md` |
| 2.2 (consumer template) | `src/templates/constitution.md`, `.claude/skills/specshift/templates/constitution.md` |
| 2.3 (compilation) | `.claude/skills/specshift/` (regenerated) |

### Scope Control

All changed files trace to implementation tasks. No untraced files.

### Verdict

**PASS**
