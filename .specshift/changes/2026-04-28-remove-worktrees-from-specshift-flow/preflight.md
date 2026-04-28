# Pre-Flight Check: Remove Worktrees from SpecShift Workflow

**Verdict:** PASS

**Summary:** 0 blockers, 0 warnings.

## A. Traceability Matrix

Capabilities from the proposal frontmatter (`modified: [change-workspace, project-init, artifact-pipeline, review-lifecycle, workflow-contract]`) mapped to specs and the architecture components touched in the apply phase.

| Capability | Spec | Updated? | Architecture Component(s) |
|------------|------|----------|---------------------------|
| change-workspace | `docs/specs/change-workspace.md` | ✅ v4 → v5 | `src/skills/specshift/SKILL.md` (Change Context Detection), `src/actions/propose.md` (workspace creation), `.specshift/templates/changes/proposal.md` (frontmatter doc) |
| project-init | `docs/specs/project-init.md` | ✅ v6 → v7 | `src/actions/init.md` (env checks, worktree opt-in), `src/templates/workflow.md` (template content + version bump) |
| artifact-pipeline | `docs/specs/artifact-pipeline.md` | ✅ v5 → v6 | `src/actions/propose.md` (post-artifact commit), `src/templates/workflow.md` (frontmatter list), `.specshift/WORKFLOW.md` (live config) |
| review-lifecycle | `docs/specs/review-lifecycle.md` | ✅ v3 → v4 | `src/actions/review.md` (post-merge cleanup), `src/actions/finalize.md` (post-merge cleanup) |
| workflow-contract | `docs/specs/workflow-contract.md` | ✅ v9 → v10 | `src/skills/specshift/SKILL.md` (Load Configuration, Change Context Detection) |

All 5 capabilities have an updated spec. Each spec retains ≥3 requirements (CONSTITUTION's consolidation floor): change-workspace 4, project-init 12, artifact-pipeline 14, review-lifecycle 7, workflow-contract 5.

## B. Gap Analysis

| Dimension | Finding |
|-----------|---------|
| Edge cases | Legacy `proposal.md` files with `worktree:` frontmatter handled (read-only treatment documented in change-workspace.md edge cases). |
| Error handling | `bash scripts/compile-skills.sh` template-version compile gate covered (decision documented; tasks.md will include the bump). |
| Offline / no GitHub tooling | Init's environment-check requirement still covers it; the simplification only removes the worktree branch of that check. |
| Empty states | N/A — this is a removal, not a feature addition. No new flows to validate. |

No gaps requiring resolution.

## C. Side-Effect Analysis

| System | Risk | Status |
|--------|------|--------|
| Consumers with `worktree.enabled: true` in their WORKFLOW.md | Silently lose the feature. | Documented as breaking-change in CHANGELOG (planned during finalize). |
| Existing on-disk worktrees on consumer machines | No longer auto-cleaned by SpecShift. | Manual `git worktree remove <path>` documented in changelog/migration plan. |
| In-flight proposals carrying `worktree: <path>` frontmatter | Field is now legacy/read-only. | Router's `branch:` lookup is unaffected; documented in change-workspace.md edge case. |
| Compiled release tree (`skills/specshift/`) | Could retain stale worktree text if compile is skipped. | Finalize re-runs `bash scripts/compile-skills.sh`; `git grep` check in audit. |
| Historical `.specshift/changes/2026-03-30-worktree-based-change-lifecycle/` and related dirs | Could appear "orphaned" without context. | Out-of-scope per proposal — they remain as historical record. |
| Rebase-merge GitHub repo config (already set on this repo) | Was tied to the worktree opt-in flow. | No regression — the review action squash-merges. The repo config stays as-is; SpecShift simply no longer attempts to set it. |

No regressions identified.

## D. Constitution Check

| Constitution rule | Compliance |
|-------------------|------------|
| **Three-layer architecture** | Change stays within layers (CONSTITUTION → WORKFLOW.md + Smart Templates → Router). No layer-crossing. |
| **Router immutability** | `src/skills/specshift/SKILL.md` is generic plugin code. Edits remove a generic feature (worktree handling), not project-specific behavior — compliant. |
| **Pipeline source of truth** | `.specshift/WORKFLOW.md` + `.specshift/templates/` remain the source of truth. Worktree config block removed; pipeline structure unchanged. |
| **Specs are direct-edited** | All 5 spec edits use `## Purpose` + `## Requirements`, no delta format. |
| **Release directory** | `skills/specshift/` regenerated via `bash scripts/compile-skills.sh` during finalize. Not hand-edited. |
| **Template-version discipline** | `src/templates/workflow.md` will bump `template-version` (planned in tasks). The compile gate enforces this. |
| **Knowledge transparency** | All decisions live in this change's design.md and the affected specs — no auto-memory usage. |
| **No ADR references in specs** | Specs do not reference ADRs. Compliant. |
| **Tool-agnostic instructions** | The simplified Change Context Detection and init env checks describe intent (`branch:` lookup, GitHub tooling availability) rather than tool-specific commands. Compliant. |
| **Template synchronization** | `src/templates/workflow.md` and `.specshift/WORKFLOW.md` will be updated together; the `worktree.enabled: true` divergence noted in CONSTITUTION's "Template synchronization" rule disappears (no `worktree` block in either after this change). |

No constitution updates required for this change.

## E. Duplication & Consistency

| Check | Result |
|-------|--------|
| Spec overlap with other specs | None. The 5 modified specs cover distinct capabilities; the worktree material was localized to each. |
| Spec ↔ proposal alignment | The proposal's `What Changes` list maps 1:1 to the apply tasks. |
| Spec ↔ design alignment | Design's "Affected layers" table maps 1:1 to the proposal's "Plugin source / Project instance / Specs / Compiled release tree" sections. |
| Internal contradictions across specs | None. After edits: `change-workspace.md` documents the simplified Change Context Detection (2-tier), and `workflow-contract.md`'s Router Dispatch Pattern matches it (`scan branch frontmatter → directory listing prompt`). |
| Cross-spec references | `review-lifecycle.md` previously referenced "Post-Merge Worktree Cleanup requirement in change-workspace.md"; that reference was removed in lockstep with deleting the corresponding requirement in change-workspace.md. No dangling references. |

Consistent.

## F. Assumption Audit

| # | Assumption | Source | Rating |
|---|-----------|--------|--------|
| 1 | `bash scripts/compile-skills.sh` does not contain worktree-specific handling and only needs to re-copy files. | design.md | Acceptable Risk — research.md confirmed via inspection that the script doesn't special-case worktrees. |
| 2 | The cached plugin directory used by the running specshift skill is read-only at runtime; updates to `src/` only affect downstream consumers after compile + re-install. | design.md | Acceptable Risk — standard Claude Code plugin architecture. |
| 3 | The system clock provides the correct date for the YYYY-MM-DD prefix. | change-workspace.md (pre-existing) | Acceptable Risk — unchanged by this change. |
| 4 | GitHub tooling availability and authentication can be reliably detected at init time. | project-init.md (pre-existing) | Acceptable Risk — unchanged by this change. |
| 5 | The init command can detect tech stack from static file analysis. | project-init.md (pre-existing) | Acceptable Risk — unchanged by this change. |

All assumptions have visible text before the HTML tag (verified). 0 Blocking, 0 Needs Clarification.

## G. Review Marker Audit

```
$ grep -rn "<!-- REVIEW" .specshift/changes/2026-04-28-remove-worktrees-from-specshift-flow/ docs/specs/{change-workspace,project-init,artifact-pipeline,review-lifecycle,workflow-contract}.md
docs/specs/project-init.md:253:- **AND** uncertain items SHALL be marked with `<!-- REVIEW -->` for user resolution
```

The single hit is descriptive prose inside a Gherkin scenario explaining how the init command uses REVIEW markers as a feature — it is not an unresolved marker. **0 unresolved REVIEW markers** in change artifacts or affected specs.

## H. Draft Spec Validation

All 5 affected specs are `status: stable` (not draft). No draft-spec ownership conflicts. Skip.
