# Pre-Flight Check: Plugin Version Check

## A. Traceability Matrix

- [x] Plugin Version Stamp (project-init.md) → Scenario: fresh install, re-init, legacy → `src/templates/workflow.md`, `src/actions/init.md`
- [x] WORKFLOW.md Pipeline Orchestration (workflow-contract.md) → `plugin-version` field added to frontmatter list → `src/templates/workflow.md`
- [x] Router Dispatch Pattern (workflow-contract.md) → Restructured steps 1-5, version check scenarios → `src/skills/specshift/SKILL.md`

## B. Gap Analysis

No gaps identified. All scenarios from specs map to concrete file changes:
- Template field addition: covered
- Router restructuring: covered
- Version check logic (match, mismatch, missing): all three branches covered
- Init stamping (fresh, re-init, legacy): all three modes covered
- Edge cases (unreadable plugin.json, downgrade): covered in spec

## C. Side-Effect Analysis

- **Template-version bump (2→3)**: Triggers template merge detection for all consumers on next `specshift init`. Consumers with unmodified WORKFLOW.md get silent update. Consumers with customizations get merge prompt. This is expected and intentional — the existing merge logic handles it correctly.
- **SKILL.md step renumbering**: Consumers do not reference step numbers directly. SKILL.md is plugin code (router immutability rule) — consumers don't modify it. No regression risk.
- **WORKFLOW.md frontmatter field addition**: `plugin-version` is a new optional field. Existing WORKFLOW.md files without it continue to work (version check shows note, not error).

## D. Constitution Check

No constitution update needed. No new patterns, tech stack changes, or architectural rules introduced. The three-layer architecture is preserved (CONSTITUTION → WORKFLOW.md → Router).

## E. Duplication & Consistency

- `plugin-version` field is documented in both `workflow-contract.md` (frontmatter definition) and `project-init.md` (stamping behavior). No contradiction — they describe different aspects (schema vs behavior).
- Router Dispatch Pattern steps in `workflow-contract.md` must match SKILL.md implementation. Spec already updated; implementation will follow.

## F. Assumption Audit

No assumptions introduced. All changes use existing patterns (YAML frontmatter, JSON file read, string comparison).

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any artifact.

---

**Verdict: PASS**
