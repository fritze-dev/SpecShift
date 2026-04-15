# Research: Fix Squash-Merge Commit Messages

## 1. Current State

**Affected specs:**
- `docs/specs/review-lifecycle.md` — "Merge Execution with Mandatory Confirmation" requirement (line 145). Says "merge the PR using available GitHub tooling" but does not specify merge method or commit message composition.
- `docs/specs/artifact-pipeline.md` — "Post-Artifact Commit and PR Integration" requirement (line 132) defines format `WIP: <change-name> — <artifact-id>`. "Post-Implementation Commit Before Approval" (line 164) uses `WIP: <change-name> — implementation`.

**Affected instructions:**
- `src/skills/specshift/SKILL.md` line 71: `WIP: <change-name> — <artifact-id>` in propose pipeline step 4.
- `src/templates/workflow.md` line 99 (review action step 8): "merge the PR using available GitHub tooling" — no commit message specification.
- `.specshift/WORKFLOW.md` line 98: same, plus project-specific worktree cleanup detail.

**Affected compiled outputs:**
- `.claude/skills/specshift/actions/review.md` — extracted from review-lifecycle spec
- `.claude/skills/specshift/actions/apply.md` — extracted from artifact-pipeline spec
- `.claude/skills/specshift/SKILL.md` — copied from source

**Root cause:** The `mcp__github__merge_pull_request` tool accepts optional `commit_title` (string) and `commit_message` (string) parameters. When these are omitted, GitHub composes the default squash message by concatenating all individual commit messages — which in SpecShift's case are all WIP pipeline commits.

**Evidence from git log:**
- PR #27 (`eb041eb`): Clean commit message — `commit_title`/`commit_message` were supplied manually during merge.
- PR #28 (`35541c2`): Raw WIP concatenation — merge parameters were omitted.

**No programmatic dependencies on "WIP:" prefix:** Searched `scripts/`, `.github/`, `CONSTITUTION.md` — no scripts, CI, or conventions parse or filter on the WIP prefix.

## 2. External Research

**GitHub squash merge behavior:** When merging via API with `merge_method: squash`, GitHub concatenates all commit messages into the commit body if `commit_message` is not provided. The `commit_title` defaults to the PR title with PR number appended.

**Conventional Commits (conventionalcommits.org):** Format `<type>(<scope>): <description>`. Widely adopted, machine-parseable, and tool-friendly (changelogs, semver detection). SpecShift's current convention (from constitution) uses "Imperative present tense with category prefix" which is compatible.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Fix squash message only (compose from proposal at merge time) | Minimal change, fixes the immediate issue | WIP commits remain opaque in PR commit lists |
| B: Fix squash message + redesign WIP format | Comprehensive fix, better readability at all stages | Touches more files (2 specs, 2 instructions, 1 skill) |
| C: Fix squash message + eliminate WIP commits (single squash at end) | Cleanest git history | Loses incremental push visibility, breaks draft PR flow |

**Recommendation:** Approach B — fix both problems. The WIP format change is low-risk (no programmatic dependencies) and improves the developer experience across the board.

## 4. Risks & Constraints

- **Template-version discipline**: Modifying `src/templates/workflow.md` requires bumping its `template-version` (currently 6 → 7). The compile script enforces this.
- **Backward compatibility**: Existing completed changes already have WIP commits in their history — no migration needed, the format change only affects future commits.
- **Compile step**: `finalize` runs `bash scripts/compile-skills.sh` which regenerates the release directory from specs. The new requirement text will be picked up automatically.
- **Self-validation**: This PR itself will be the first to use the new squash message composition during `specshift review`, serving as both fix and test.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Two changes: WIP format redesign + squash message composition |
| Behavior | Clear | New WIP format: `specshift(<change-name>): <artifact-id>`. Squash message: title from PR, body from proposal |
| Data Model | Clear | No data model — this is spec/instruction text changes |
| UX | Clear | Improves git log readability and PR commit list clarity |
| Integration | Clear | MCP tool `merge_pull_request` accepts `commit_title`, `commit_message`, `merge_method` |
| Edge Cases | Clear | Proposal missing sections → fall back to PR body → PR title only |
| Constraints | Clear | Template-version bump required; compile script enforces |
| Terminology | Clear | Dropping "WIP" prefix; using `specshift()` conventional commit scope |
| Non-Functional | Clear | No performance or security implications |

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | New WIP format: `specshift(<change-name>): <artifact-id>` | Conventional-commit-compatible, machine-parseable, identifies source system, removes "unfinished work" stigma | Keep `WIP:` prefix (rejected: cryptic, no convention compliance) |
| 2 | Squash commit title: `<PR title> (#<PR number>)` | Matches GitHub's standard squash title convention | Use change name (rejected: PR title is already set from change name and may have been edited) |
| 3 | Squash commit body: proposal Why + What Changes + issue refs | Rich context from structured artifacts already available at merge time | Use PR body only (rejected: PR body may be abbreviated or stale) |
| 4 | Explicit `merge_method: squash` in spec | Removes ambiguity about merge strategy | Leave merge method unspecified (rejected: was the root cause of inconsistency) |
