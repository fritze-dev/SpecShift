# Research: Plugin Version Check

## 1. Current State

**Plugin versioning:**
- Source of truth: `src/.claude-plugin/plugin.json` → `version: "0.1.3-beta"`
- Compiled copy: `.claude/.claude-plugin/plugin.json` (synced during finalize)
- Version bumped automatically during finalize per constitution convention

**Consumer WORKFLOW.md (`src/templates/workflow.md`):**
- Has `template-version: 2` in frontmatter for template merge detection
- No `plugin-version` field — no way to know which plugin version installed the project
- `specshift init` copies this template to `.specshift/WORKFLOW.md`

**SKILL.md router (5 steps):**
- Step 1: Identify Action — reads WORKFLOW.md `actions` array
- Step 2: Load WORKFLOW.md — reads full file again (frontmatter + body)
- Step 3: Change Context Detection
- Step 4: Load Action Context — reads WORKFLOW.md body sections again
- Step 5: Dispatch

WORKFLOW.md is referenced in Steps 1, 2, and 4 — read 3 times conceptually.

**Relevant specs:**
- `workflow-contract.md` — defines WORKFLOW.md frontmatter fields (no `plugin-version` yet), router dispatch pattern, Smart Template format
- `project-init.md` — defines init behavior, template merge via `template-version`, no plugin version stamping

**No version check exists anywhere** — no comparison of installed vs current plugin version.

## 2. External Research

Not applicable — this is internal plugin architecture.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: `plugin-version` in WORKFLOW.md + check in SKILL.md | Simple, one field, one comparison. Fits existing template merge pattern. | Requires WORKFLOW.md template-version bump (v2→v3). |
| B: Separate `.specshift/.plugin-version` file | No WORKFLOW.md change needed. | Extra file, extra read, doesn't follow existing patterns. |
| C: Check at `init` only (no runtime check) | Minimal changes. | Defeats the purpose — consumer only knows when they manually run init. |

**Selected: Approach A** — `plugin-version` in WORKFLOW.md frontmatter, checked in SKILL.md router.

Additionally, the SKILL.md router steps should be restructured so WORKFLOW.md is read exactly once (Step 1: Load Configuration), and the version check gets its own step.

## 4. Risks & Constraints

- **Template-version bump**: Changing `template-version` from 2 to 3 triggers the existing template merge logic on next `specshift init` for all consumers. Consumers with unmodified WORKFLOW.md get a silent update. Consumers with customizations get a merge prompt. This is expected and correct behavior.
- **No blocking**: The version check must be advisory-only. A blocking check would break in-progress changes after a plugin update.
- **`plugin.json` path**: The router needs to read `plugin.json` relative to the plugin root. Path is `../../.claude-plugin/plugin.json` relative to SKILL.md at `.claude/skills/specshift/SKILL.md`.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Add `plugin-version` field, check in router, stamp in init |
| Behavior | Clear | Advisory warning on mismatch, silent on match, note on missing |
| Data Model | Clear | Single string field in WORKFLOW.md frontmatter |
| UX | Clear | Non-blocking warning with actionable suggestion |
| Integration | Clear | Fits into existing template merge and router patterns |
| Edge Cases | Clear | Legacy installs, missing field, downgrade, unreadable plugin.json |
| Constraints | Clear | Advisory-only, no blocking |
| Terminology | Clear | `plugin-version` (not `installed-version` or `specshift-version`) |
| Non-Functional | Clear | Trivial overhead: one file read + string comparison |

## 6. Open Questions

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use `plugin-version` field in WORKFLOW.md frontmatter | Follows existing pattern (template-version), single source of config | Separate file (.plugin-version) |
| 2 | Restructure SKILL.md to read WORKFLOW.md once in Step 1 | Currently read 3 times across steps; consolidation is cleaner | Keep current structure, add sub-step |
| 3 | Advisory warning, not blocking | In-progress changes must not be interrupted | Blocking check with `--skip-version-check` |
| 4 | Bump template-version to 3 | New field = structural change, triggers proper merge detection | Keep at 2 (would bypass merge logic) |
