# Research: Remove Worktree Handling from SpecShift Workflow

## 1. Current State

Worktree handling is a pervasive, first-class concept across the SpecShift workflow. A repo-wide search returned **866 references** spanning skill, actions, templates, project-instance config, specs, capability docs, and historical changes.

**Workflow config surface (`worktree.*` keys):**
- `worktree.enabled` (boolean) — gate for the entire feature
- `worktree.path_pattern` (string, default `.specshift/worktrees/{change}`)
- `worktree.auto_cleanup` (boolean)
- `worktree.stale_days` (integer, default 14)

**Where it lives:**

| Area | File(s) | Purpose |
|------|---------|---------|
| Plugin source | `src/templates/workflow.md` | Worktree config block (currently commented out as default-off) |
| Plugin source | `src/skills/specshift/SKILL.md` | Lists `worktree` config key, fallback worktree detection via `git rev-parse --git-dir` |
| Plugin source | `src/actions/propose.md` | Worktree creation, lazy stale cleanup, `worktree:` proposal frontmatter, `git worktree add/list/remove`, fetch-main-then-branch logic |
| Plugin source | `src/actions/finalize.md` | Post-merge worktree cleanup |
| Plugin source | `src/actions/review.md` | Post-merge worktree cleanup in merge step |
| Plugin source | `src/actions/init.md` | Initial workspace setup with worktree option |
| Project instance | `.specshift/WORKFLOW.md` | `worktree.enabled: true`, `auto_cleanup: true` (override of template default) |
| Project doc | `AGENTS.md` (line 34) | Notes the `worktree.enabled: true` override as intentional |
| Compiled release | `skills/specshift/SKILL.md`, `skills/specshift/actions/*.md` | Generated copies; produced by `bash scripts/compile-skills.sh` |
| Specs | `docs/specs/change-workspace.md` (~96 refs) | Largest worktree footprint — workspace creation, stale-cleanup hierarchy, tier-based detection, post-merge cleanup, error handling |
| Specs | `docs/specs/project-init.md` (~26 refs) | Worktree config option during init |
| Specs | `docs/specs/artifact-pipeline.md` (~15 refs) | Artifact pipeline execution within worktree context |
| Specs | `docs/specs/review-lifecycle.md` (~2 refs) | Worktree cleanup in merge workflow |
| Specs | `docs/specs/workflow-contract.md` (~3 refs) | Workflow config contract surface |
| Capability docs | `docs/capabilities/change-workspace.md`, `docs/capabilities/artifact-pipeline.md` | Public documentation of worktree isolation |
| CHANGELOG | `CHANGELOG.md` | History of worktree path migration |
| Historical artifacts | `.specshift/changes/2026-03-30-worktree-based-change-lifecycle/`, `2026-04-09-worktree-fetch-main/`, `2026-04-11-fix-stale-worktree-detection/`, `2026-03-30-fix-squash-merge-cleanup/` | Past changes that designed/fixed the feature |

**Compile pipeline:** `bash scripts/compile-skills.sh` flows `src/` → `skills/specshift/` (SKILL.md, templates, actions). The script does not appear to special-case worktree handling — it just copies files. Removing worktree text from `src/` and re-running compile is sufficient to clean the release directory.

## 2. External Research

Both target hosts already provide native worktree affordances:

- **Claude Code**: subagents and the `Agent` tool support `isolation: "worktree"` to run an agent in a dedicated worktree. Users can opt in per-task without help from SpecShift.
- **Codex CLI**: provides its own worktree-style isolation flow.
- **Plain Git**: `git worktree add/list/remove` is always available to power users.

There is no host or third-party dependency that requires SpecShift to own the worktree lifecycle.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A. Remove worktree handling end-to-end** (chosen) | Single config surface gone, propose/finalize/review actions shrink, change-workspace spec shrinks dramatically, simpler mental model. Aligns with Niko's framing: SpecShift owns file-based change workspaces, host owns isolation. | One-shot scope: many files touched in a single change. Existing `proposal.md` files keep their legacy `worktree:` frontmatter — must be handled as read-only data. |
| **B. Keep config keys, gut the implementation** | Smaller diff. | Confusing dead config; users would still set `worktree.enabled: true` and silently get nothing. Worse than A. |
| **C. Move worktree handling into a separate optional skill** | Preserves the feature for power users who want SpecShift-managed worktrees. | Extra skill surface, splits the workflow, contradicts the "host owns isolation" principle. Out of scope per the issue. |

## 4. Risks & Constraints

- **In-flight changes:** Any active proposal that was created with `worktree.enabled: true` already has a `worktree: <path>` frontmatter field. New code MUST treat that field as legacy/read-only and never write it. No migration tooling is in scope.
- **Change Context Detection regression:** Today the router has a fallback that derives change name from branch when inside a worktree. Removing this fallback is fine for new changes (proposal frontmatter `branch:` lookup is the primary path), but historically-created proposals without a `branch:` field would lose the worktree-name fallback. Acceptable: those are legacy artifacts only kept for history; the primary lookup still works.
- **`.specshift/WORKFLOW.md` template-version bump:** removing the `worktree:` config block from the project's WORKFLOW.md is a content change but not a template-source change (the source `src/templates/workflow.md` already has the block commented out). The project-instance file is hand-maintained — no template-version increment is needed for the project copy.
- **`src/templates/workflow.md` template-version:** the commented worktree block must be removed from the template source as well. Per CONSTITUTION.md "Template-version discipline", that triggers a `template-version` increment.
- **Compiled release tree (`skills/specshift/`):** must be regenerated via `bash scripts/compile-skills.sh` so the shipped skill stops mentioning worktrees. This happens during `specshift finalize`.
- **Spec linkage in compiled actions:** `src/actions/*.md` files link into `docs/specs/*.md` content. After spec edits, re-running compile-skills.sh propagates the cleaned text into `skills/specshift/actions/`.
- **Historical changes are out of scope:** the 4 worktree-themed past changes under `.specshift/changes/` stay untouched as historical record — they describe how the feature was built; removing them would falsify the project history.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Issue #47 in/out of scope is explicit; comment from Niko sharpens spec/artifact cleanup. |
| Behavior | Clear | New behavior: SpecShift never creates, detects, or cleans up worktrees. Branch handling stays. |
| Data Model | Clear | `worktree:` proposal frontmatter is dropped from new artifacts; existing artifacts keep it as legacy. Config keys removed. |
| UX | Clear | Users opting into host-level worktrees still get them; SpecShift no longer surfaces a `worktree:` config or cleanup prompts. |
| Integration | Clear | Compile pipeline propagates changes; no new external integrations. |
| Edge Cases | Clear | Legacy proposals keep their frontmatter; legacy worktrees on disk are not cleaned up by SpecShift (user can run `git worktree remove` manually). |
| Constraints | Clear | Template-version discipline applies to `src/templates/workflow.md` only. Compiled release tree must be regenerated. |
| Terminology | Clear | "Change workspace" stays defined as a directory under `.specshift/changes/`. The phrase "git worktree" is removed as an implementation detail. |
| Non-Functional | Clear | No performance, security, or scaling implications. Pure simplification. |

All categories Clear — no clarification questions needed.

## 6. Open Questions

None. Scope and behavior are fully specified by Issue #47 + Niko's comment.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Approach A — remove worktree handling end-to-end. | Single config surface gone, simplest mental model, aligns with "host owns isolation". | B (gut implementation, keep config) and C (separate optional skill) — both rejected by the issue's "out of scope" list. |
| 2 | Treat existing `proposal.md` `worktree:` frontmatter as legacy/read-only. | Avoids migration tooling (out of scope per issue) while keeping historical artifacts intact. | Strip the field on read — rejected, mutates committed history. |
| 3 | Keep historical change directories under `.specshift/changes/` untouched. | Those changes record how the feature was built; deleting them would falsify project history. | Delete or annotate them — rejected, no benefit. |
| 4 | Remove the worktree-name fallback in Change Context Detection. | Proposal frontmatter `branch:` lookup is the primary path and works for all changes created since worktree adoption. Historical changes without frontmatter are legacy-only. | Keep the fallback — rejected, would require keeping `git rev-parse --git-dir /worktrees/` detection in the router. |
| 5 | Re-run `bash scripts/compile-skills.sh` during finalize to propagate spec/template cleanup into `skills/specshift/`. | Standard finalize behavior; no new step. | Regenerate manually before finalize — rejected, redundant. |
