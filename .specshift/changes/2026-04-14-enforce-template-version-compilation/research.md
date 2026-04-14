# Research: Enforce Template-Version in Compilation Step

## 1. Current State

**Template-version field**: Every Smart Template under `src/templates/` contains a `template-version` integer in YAML frontmatter. This field enables `specshift init` to detect local template customizations and trigger merge prompts during plugin updates.

**Compilation step** (`scripts/compile-skills.sh`): Currently performs 4 steps:
1. Preflight (check source files exist)
2. Copy source files to `.claude/skills/specshift/`
3. Stamp `plugin-version` into compiled workflow template
4. Extract and compile requirement blocks from specs into action files

There is **no validation** that template-version was bumped when template content changed.

**Prior incident**: PR #16 (`fix-loop-tiered-reentry`) modified `src/templates/workflow.md` and `src/templates/changes/tasks.md` without bumping their `template-version`. The review.md passed, and the issue was only caught during manual human review.

**Prior failed fix**: PR #18 put enforcement into `src/templates/workflow.md` (the distributed plugin template). Closed because this is a plugin maintainer concern, not a consumer concern.

**Original design assumption** (`2026-04-08-spec-frontmatter-tracking/design.md`):
> "Plugin maintainers will remember to bump template-version when changing template content."

This assumption was invalidated — the review flow did not catch the missing bump.

## 2. External Research

N/A — this is internal tooling. No external dependencies.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Git-diff check in compile script | Central enforcement, fails fast before build, no spec changes needed | Requires `main` branch for comparison; no-op when run on main itself |
| B: Content hash comparison | Branch-independent, compares actual content | Complex to implement in bash, requires storing hashes somewhere |
| C: Pre-commit hook | Catches issues before commit | Not part of the specshift workflow, easily bypassed with --no-verify |

**Recommendation**: Approach A. The compilation step already runs during finalize and is the natural place for this check. Git-diff against `main` is simple, reliable, and handles the primary case (feature branch → main).

## 4. Risks & Constraints

- **On `main` branch**: `git diff main` shows no changes, so the check is a no-op. This is correct — on main, everything is already merged and presumably version-bumped.
- **No `main` branch**: First-time setup or unusual git states. The script should skip the check gracefully.
- **New template files**: Not in `main` yet, so git diff shows entire file as added. The `+template-version:` line naturally appears. No special handling needed.
- **Deleted templates**: Should be skipped (file no longer exists).

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Three files: compile script, CONSTITUTION.md, WORKFLOW.md |
| Behavior | Clear | Diff-based check, fail on unbumped version |
| Data Model | Clear | template-version integer in YAML frontmatter |
| UX | Clear | Error message names the file and tells user what to do |
| Integration | Clear | Fits into existing compile script preflight section |
| Edge Cases | Clear | main branch missing, new files, deleted files, on-main execution |
| Constraints | Clear | Bash-only, no external runtimes |
| Terminology | Clear | template-version, compilation, enforcement |
| Non-Functional | Clear | Minimal perf impact (one git diff per modified template) |

## 6. Open Questions

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use git-diff against main for comparison | Simple, reliable, handles the primary feature-branch case | Content hashing (too complex), pre-commit hooks (not part of workflow) |
| 2 | Place enforcement in compile script, not in specs | Issue #17 comment clarifies: this is a local maintainer concern, not consumer-facing | Adding a spec requirement (wrong scope per issue feedback) |
| 3 | Add CONSTITUTION.md convention for documentation | Makes the rule discoverable and explicit | Only enforce silently via script (undiscoverable) |
