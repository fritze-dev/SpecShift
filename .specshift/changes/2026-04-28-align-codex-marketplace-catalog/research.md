# Research: Align Codex Marketplace Catalog Documentation

## 1. Current State

### Repository state on this branch (`claude/optimize-codex-marketplace-uVtJK`)

Commit `71c000fc` (Tue 2026-04-28) introduced `.agents/plugins/marketplace.json` at the repo root with a Git-URL-based source:

```json
{
  "name": "specshift",
  "interface": { "displayName": "SpecShift" },
  "plugins": [{
    "name": "specshift",
    "description": "Spec-driven development workflow — every feature produces …",
    "source": { "source": "url", "url": "https://github.com/fritze-dev/SpecShift.git" },
    "policy": { "installation": "AVAILABLE", "authentication": "ON_INSTALL" },
    "category": "Coding"
  }]
}
```

The catalog file is the missing piece that lets `codex plugin marketplace add fritze-dev/SpecShift` succeed. The single-plugin auto-discovery assumption shipped in PR #46 (multi-target distribution, merged as `5fe9d66`) had been falsified — Codex does not auto-discover `.codex-plugin/plugin.json` for repos that lack a `.agents/plugins/marketplace.json` catalog at the root.

### Spec / Doc state still asserts the opposite

Despite the committed file, the following authoritative texts still claim "no separate Codex marketplace catalog file is shipped":

- `docs/specs/multi-target-distribution.md` Requirement "Codex Discovery via Marketplace Add" (lines 75–95): *"The plugin SHALL NOT ship a `.agents/plugins/marketplace.json` file"* + Scenario "No Codex marketplace catalog file shipped" + Edge Case "Codex auto-discovery semantics change" + Assumption "Codex single-plugin auto-discovery"
- `docs/specs/release-workflow.md` Requirement "Source and Release Directory Structure" (line 359): *"Codex consumers install via `codex plugin marketplace add github:owner/repo`, which auto-discovers `.codex-plugin/plugin.json` directly — no separate Codex marketplace catalog file is shipped."*
- `AGENTS.md` File Ownership block (line 33): same wording as release-workflow.md.
- `.specshift/CONSTITUTION.md` Architecture Rules (line 24): same wording.
- `README.md` Codex install section (lines 27–32): wrong command — `codex /plugins` is the in-session UI, not the install command. Issue #51 already documented this.

This is a direct contradiction between shipped reality and authoritative documents — anyone running `bash scripts/compile-skills.sh` succeeds (the script never read `.agents/`), but anyone reading the spec is misled.

### Compile script state

`scripts/compile-skills.sh` header comments (lines 6–9, 147) already mention four root files preemptively, but the code path stamps three. The four-file check was anticipated but not landed. We **do not** extend the script in this change — see Out of Scope.

## 2. External Research

### Codex plugin marketplace schema (`developers.openai.com/codex/plugins/build`)

Codex catalog files at `.agents/plugins/marketplace.json` declare:

- `name` — marketplace identifier
- `interface.displayName` — UI title
- `plugins[]` — array of plugin entries, each with:
  - `name` (string)
  - `description` (string)
  - `source` (object) — supports multiple forms:
    - `{ source: "local", path: "<relative-path>" }` — points to a plugin folder within the marketplace clone
    - `{ source: "url", url: "<git-url>.git" }` — points to a Git repository (Codex re-clones it during install)
  - `policy.installation` — values: `AVAILABLE`, `user-required`, etc.
  - `policy.authentication` — values: `ON_INSTALL`, `none`, etc.
  - `category` — UI category label

The committed schema (`source: url`, policy `AVAILABLE`/`ON_INSTALL`) was verified by the user as functional. PR #53's audit ratifies `AVAILABLE`/`ON_INSTALL` as the correct policy values (PR #52's `user-required`/`none` were corrected by PR #53).

### Parallel attempts (PR #52, PR #53)

- **PR #52** (`claude/add-codex-marketplace-SATku`) chose `source: { source: "local", path: "../../.codex-plugin" }` with policy `user-required`/`none`. It includes the full plumbing surface: spec language, ADR-003 Decision 6 amendment, README install section rewrite, scripts/compile-skills.sh `verify_catalog_shape()`, release.yml 4-file cross-check loop, CHANGELOG entry, version bump to 0.2.6-beta, capability-doc regeneration. The schema choice differs from this branch's — `local` path vs. Git URL.
- **PR #53** (`codex/pr52-fix-codex-payload`, against PR #52's branch) corrects PR #52 with `source.path: "./plugins/specshift"` and ratifies `AVAILABLE`/`ON_INSTALL` policy. It additionally generates a sub-payload under `plugins/specshift/` (replicated `.codex-plugin/plugin.json` + `skills/specshift/`). The sub-payload is necessary only for PR #53's `local`-path target — for our Git-URL source, Codex re-clones the repo and resolves the existing `.codex-plugin/` and `./skills/` directly at the root.
- **Issue #51** Acceptance Criterion (b) explicitly anticipates this branch's path: *"add `.agents/plugins/marketplace.json` with the correct Codex schema, restore the cross-check in `scripts/compile-skills.sh` and `.github/workflows/release.yml`, update spec to mandate the file, update ADR-003 to flip the rejected alternative to the accepted decision."* The cross-check restoration is consciously deferred (see Out of Scope); the spec/ADR/README work is in scope.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **Align spec/docs/README only** (chosen) | Closes the spec-vs-reality contradiction. Minimal scope. Documentation truth restored. | Compile script comments stay misleading (line 8 mentions four files, code uses three). Defense-in-depth not added. |
| Spec/docs + add `verify_catalog_shape()` | Full plumbing parity with PR #52. Schema-drift protection. | Out of scope per user — file is hand-edited and not on the build hot path. |
| Adopt PR #52 wholesale, switch its schema | Reuses PR #52's spec language and ADR amendment. | PR #52 has `local`-path schema baked in throughout — non-trivial to retrofit the Git-URL choice. The branch's committed file already works; replacing it would be churn. |
| Convert Claude marketplace to Git-URL too | Schema symmetry between targets. | Confirmed out-of-scope — Claude's `"./"` is canonical for in-repo marketplace+plugin and inherits `#ref`-pinning naturally. |

## 4. Risks & Constraints

- **Spec versioning discipline**: `docs/specs/multi-target-distribution.md` v4 → v5 and `release-workflow.md` v5 → v6 frontmatter bumps required. Smart Templates under `src/templates/` are not modified, so `template-version` discipline does not trigger.
- **Worktree directive conflict**: `worktree.enabled: true` in WORKFLOW.md says the propose flow should create a worktree, but the system's branch directive ("Develop on branch `claude/optimize-codex-marketplace-uVtJK`") overrides. Workspace is created in-tree; proposal frontmatter omits the `worktree` field.
- **Auto-PR creation**: WORKFLOW would create a draft PR on first push, but the session policy disallows PR creation without explicit user request. Skip PR creation in the propose pipeline; raise it as an explicit ask before review.
- **Plugin version skew**: project WORKFLOW.md `plugin-version: 0.2.1-beta`, current plugin v0.2.5-beta. Advisory only.
- **Live Codex smoke test**: Issue #51 acceptance includes a real-Codex-install verification. That happens outside this change; this work assumes the user-validated functional state.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Plan approved: spec/docs/README alignment, no compile/CI changes. |
| Behavior | Clear | No runtime behavior change — file already in place and working. |
| Data Model | Clear | Schema is the committed Git-URL form. |
| UX | Clear | README Codex install commands change to canonical two-step + Update subsection. |
| Integration | Clear | Codex `marketplace add fritze-dev/SpecShift` install path. |
| Edge Cases | Clear | Existing edge cases re-worded for the new world; no new edge cases. |
| Constraints | Clear | Routing through specshift workflow per AGENTS.md. Stay on `claude/optimize-codex-marketplace-uVtJK`. No PR auto-creation. |
| Terminology | Clear | "Codex marketplace catalog" (`.agents/plugins/marketplace.json`) vs. "Codex plugin manifest" (`.codex-plugin/plugin.json`) — already distinct in existing prose. |
| Non-Functional | Clear | Doc-only change, no perf/security/scaling impact. |

## 6. Open Questions

All categories Clear. No open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Keep Claude marketplace at `source: "./"`. | Canonical idiom for in-repo marketplace+plugin; inherits `#ref`-pinning natively; converting to Git URL would force redundant re-clone. | Convert to Git URL (rejected — see Approaches table). Support both forms (rejected — double maintenance). |
| 2 | Codex catalog uses `source: { source: "url", url: "<repo>.git" }`. | User-validated functional. Avoids PR #53's sub-payload replication (`plugins/specshift/`). Symmetric idiom to Claude's external-plugin pattern (`{ source: "github", repo: "..." }`). | `local` path (PR #52/#53 — rejected by user choice; needs sub-payload for #53's path). |
| 3 | Defer `verify_catalog_shape()` and CI cross-check extension. | File is hand-edited and not on build hot path; protection is nice-to-have, not gap-closing. Primary goal (Codex install works) already met. | Adopt PR #52's `verify_catalog_shape()` (deferred to follow-up issue if relevant). |
| 4 | Do not close PR #52, PR #53, Issue #51 in this change. | Per user direction — research-only inputs. Live-Codex smoke test (Issue #51) needs separate verification. | Close all three as superseded (deferred). |
| 5 | Skip auto-draft-PR creation during propose. | Session policy: no PR creation without explicit user request. Workflow's auto-PR step is conditional on tooling availability — treat policy as unavailability. | Create draft PR per WORKFLOW (rejected by policy). |
| 6 | Skip worktree creation; work in-tree on `claude/optimize-codex-marketplace-uVtJK`. | System directive pins this branch. Worktree mode would fork to a separate branch. | Create worktree per WORKFLOW (rejected by branch directive). |
