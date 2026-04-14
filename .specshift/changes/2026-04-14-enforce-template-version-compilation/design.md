<!--
---
has_decisions: true
---
-->
# Technical Design: Enforce Template-Version in Compilation

## Context

The compilation script (`scripts/compile-skills.sh`) builds the release directory from source files. It currently has no validation that `template-version` fields in `src/templates/` are bumped when template content changes. This design adds a git-diff-based enforcement step.

Three files are affected — all local project files, no distributed plugin or spec changes.

## Architecture & Components

**`scripts/compile-skills.sh`** — New "Template-version enforcement" section inserted between the existing Preflight and Copy sections. Uses `git diff <base_ref> --name-only -- src/templates/` to find modified templates, then checks each file's diff for a `+template-version:` line indicating the version was bumped.

**`.specshift/CONSTITUTION.md`** — New convention entry under `## Conventions` documenting the template-version discipline rule.

**`.specshift/WORKFLOW.md`** — Updated finalize `### Instruction` to mention that compilation enforces template-version freshness.

## Goals & Success Metrics

* Compilation fails when a template under `src/templates/` is modified (vs main) without bumping `template-version` — PASS/FAIL
* Compilation succeeds when all modified templates have bumped versions — PASS/FAIL
* Compilation succeeds when no templates are modified — PASS/FAIL
* Compilation skips check gracefully when no `main` branch exists — PASS/FAIL

## Non-Goals

- Content-hash-based validation (overkill for this use case)
- Pre-commit hooks or CI-level checks
- Changes to distributed templates or consumer-facing specs
- Enforcement for `docs/specs/` version fields (different concern)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Insert validation between Preflight and Copy sections | Fail fast before any build work happens | After copy (wastes work), at end (late feedback) |
| Use `git diff main` for comparison | Simple, handles the primary feature-branch case, correct no-op on main | `origin/main` only (fails without remote), content hashing (complex) |
| Fallback to `origin/main` when local `main` absent | Supports detached HEAD or shallow clones | Require main (too strict), skip silently (defeats purpose) |
| Skip check when no base ref available | Graceful degradation for initial setup | Hard fail (blocks first-time compilation) |
| Check for `^\+template-version: ` in diff output | Detects whether the version line was actually changed in the diff | Parse YAML and compare integers (over-engineered for bash) |
| No bypass flag | Issue says "centrally enforce" — escape hatches undermine enforcement | `--skip-tv-check` env var (too easy to abuse) |

## Risks & Trade-offs

- **No-op on main branch**: `git diff main` shows nothing when already on main. This is correct behavior — on main, everything is merged. Risk: none.
- **Shallow clones**: If main is not fetched in a shallow clone, the check may skip. Mitigation: fallback to `origin/main`. Low risk in practice.
- **False positive on version-only changes**: If someone bumps template-version without changing content, the check passes. This is harmless.

## Open Questions

No open questions.

## Assumptions

- The `main` branch (or `origin/main`) represents the stable baseline for comparison. <!-- ASSUMPTION: main branch as baseline -->
- Template files always have `template-version:` as a top-level YAML frontmatter key (no indentation). <!-- ASSUMPTION: consistent frontmatter format -->
