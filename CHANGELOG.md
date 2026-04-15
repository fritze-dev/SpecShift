# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [v0.2.3-beta] — 2026-04-15

### Fix Version Drift Between CHANGELOG, Tags, and GitHub Releases

#### Fixed
- CHANGELOG.md reformatted with `## [version] — date` headers — all 13 entries now map to their corresponding git tags
- Two orphan entries (#34 Conditional Post-Merge Reminders, #35 Fix Squash-Merge Commit Messages) consolidated under v0.2.2-beta where they belong
- v0.2.2-beta GitHub release notes updated to include all three changes
- `release.yml` sed pipeline now strips redundant version header and promotes headings for GitHub release notes (Closes #38)

#### Specs
- `release-workflow.md` v3: new "Changelog Version Headers" requirement — entries must use `## [version] — date` format

## [v0.2.2-beta] — 2026-04-15

### Enforce Plan-Mode Workflow Routing

#### Fixed
- Plan-mode instructions now require plans to route implementation through the specshift workflow skill (starting with `specshift propose`) — plans that describe direct file edits are flagged as non-conforming

#### Changed
- Consumer CLAUDE.md template (`src/templates/claude.md`) updated with workflow-routing rule (template-version 3 → 4)

#### Specs
- `project-init.md`: CLAUDE.md Bootstrap requirement expanded to include workflow routing as a standard Planning directive

### Fix Squash-Merge Commit Messages

#### Changed
- Squash merge commit messages now composed from proposal content (title from PR, body from Why + What Changes sections) instead of concatenating WIP pipeline commits
- Pipeline commit format changed from `WIP: <change-name> — <artifact-id>` to `specshift(<change-name>): <artifact-id>` (conventional-commit-style)
- Implementation commit format changed from `WIP: <change-name> — implementation` to `specshift(<change-name>): implementation`
- Draft PR body now uses proposal's Why section instead of `WIP: <change-name>`
- Explicit squash merge method prescribed in review-lifecycle spec

#### Specs
- `review-lifecycle.md` v2: extended Merge Execution requirement with squash commit message composition, added scenario and edge case
- `artifact-pipeline.md` v4: updated Post-Artifact Commit and Post-Implementation Commit requirements with new commit format

#### Templates
- `workflow.md` template-version 6 → 7: review action step 8 updated with commit message composition

### Conditional Post-Merge Reminders

#### Changed
- Tasks template instruction now evaluates post-merge item relevance against the proposal scope before including them in generated tasks.md — items with scope hints that don't match the change are filtered out
- Constitution post-merge items can include a natural-language scope hint (e.g., "applies when change modifies files under src/") to describe when they are relevant
- Items without scope hints are always included for backward compatibility

#### Specs
- `task-implementation.md` v3: added conditional post-merge filtering to Standard Tasks Exclusion requirement, new scenarios for scope-based inclusion/exclusion, new edge case for ambiguous scope
- `artifact-pipeline.md` v4: Standard Tasks Directive updated to mention scope-aware filtering for post-merge items

## [v0.2.1-beta] — 2026-04-15

### Pre-Merge Summary Comment

#### Added
- New "Pre-Merge Summary Comment" requirement in `review-lifecycle.md` — review action posts a PR comment summarizing threads resolved, fixes applied, self-check result, and review cycles before merge confirmation
- Graceful failure: if posting fails, action logs warning and continues to merge confirmation
- Re-entrant idempotency: uses `<!-- specshift:review-summary -->` HTML marker to detect and update existing summary instead of duplicating
- New edge case (permissions denied) and assumption (PR issue comment read-write capability) in review-lifecycle spec

#### Changed
- Review action workflow instructions converted from numbered steps (1-8) to descriptive phase labels (Draft transition, Review dispatch, Comment processing, etc.) — eliminates fragile renumbering and makes back-references clearer
- Old step 7 split into **CI gate** (failure handling) and **Pre-merge summary** + **Merge confirmation** phases
- Consumer workflow template version bumped from 6 to 7

#### Specs
- `review-lifecycle.md` v2: added Pre-Merge Summary Comment requirement (4 scenarios), 1 edge case, 1 assumption

## [v0.2.0-beta] — 2026-04-14

### Add Review Action

#### Added
- New `review` built-in action for automated PR review-to-merge lifecycle — re-entrant state machine that processes review comments, runs self-check, and merges with mandatory user confirmation
- New spec `review-lifecycle.md` with 6 requirements (PR state assessment, draft-to-ready transition, review request dispatch, comment processing, safety limits, merge confirmation)
- `review` configuration block in WORKFLOW.md frontmatter (`request_review: false | copilot | true`) for configurable reviewer assignment
- Conditional `finalize → review` auto-dispatch in router when `auto_approve: true` and `review` is in the actions array
- `review` added to default consumer template actions array (5 built-in actions total)
- Proposal status lifecycle: `active → review → completed` (review = PR under review, completed = merged)

#### Changed
- Implementation verification artifact renamed from `review.md` to `audit.md` to avoid naming collision with the review action
- Pipeline updated: `[research, proposal, specs, design, preflight, tests, tasks, audit]`
- Consumer workflow template version bumped from 4 to 6
- Plugin version bumped from 0.1.8-beta to 0.2.0-beta (breaking: action surface change)

#### Specs
- New: `review-lifecycle.md` v1 — 6 requirements, 19 scenarios
- `workflow-contract.md` v9: added Review Action Configuration requirement, updated "4 built-in" → "5 built-in", renamed review artifact to audit
- `three-layer-architecture.md`, `release-workflow.md`, `artifact-pipeline.md`, `quality-gates.md`, `human-approval-gate.md`, `task-implementation.md`, `documentation.md`: updated for review/audit naming

## [v0.1.9-beta] — 2026-04-14

### Explicit Plan-Mode Scope Commitment

#### Added
- `## Planning` section in CLAUDE.md and consumer template — plan mode discussions must conclude with an explicit scope summary (in-scope, out-of-scope, non-goals) confirmed by the user before proceeding to `specshift propose`

#### Changed
- Consumer CLAUDE.md template (`src/templates/claude.md`) now includes Planning section (template-version 2 → 3)

#### Specs
- `project-init.md` v5: CLAUDE.md Bootstrap requirement updated to include Planning as a standard section

## [v0.1.8-beta] — 2026-04-14

### Fix SpecShift Skill Flow Triggering

#### Fixed
- Skill description in `src/skills/specshift/SKILL.md` now includes TRIGGER/DO NOT TRIGGER conditions — the AI proactively invokes the specshift skill when implementation is requested instead of editing files directly
- CLAUDE.md workflow enforcement strengthened: "Before editing ANY file" replaces the previous text that excluded source code from the workflow gate

#### Changed
- Consumer CLAUDE.md template (`src/templates/claude.md`) synced with project CLAUDE.md enforcement text (template-version 1 → 2)

#### Specs
- `three-layer-architecture.md` v6: added Proactive Skill Invocation requirement

## [v0.1.7-beta] — 2026-04-14

### Review Comment Acknowledgment

#### Added
- "Review comment acknowledgment" convention in `.specshift/CONSTITUTION.md` — after pushing fixes for PR review comments, reply to each comment and resolve committed threads
- Pre-Merge standard task checkbox for review comment response

#### Fixed
- Template path in `src/skills/specshift/SKILL.md` propose instruction: `<templates_dir>/<id>.md` → `<templates_dir>/changes/<id>.md` to match actual directory structure

## [v0.1.6-beta] — 2026-04-14

### Review Workflow Artifacts

#### Changed
- Consumer workflow template (`src/templates/workflow.md`) finalize action reduced to 3 steps — removed project-specific compile step that fails for all consumer projects
- Action instructions in WORKFLOW.md now describe intra-action behavior only — auto-dispatch language removed (router handles cross-action chaining in SKILL.md)
- Project WORKFLOW.md version-bump step delegates to constitution convention instead of hardcoding file paths
- Workflow template-version bumped from 3 to 4

#### Removed
- Design review checkpoint convention from `.specshift/CONSTITUTION.md` — operational detail already lives in WORKFLOW.md propose instruction (Layer Separation)
- Preflight Quality Check reference from `src/actions/init.md` — belongs to propose, not init

#### Specs
- `three-layer-architecture.md` v5: added Layer Separation scenarios for constitution-workflow duplication and consumer template purity
- `workflow-contract.md` v8: added scenario clarifying that action instructions describe intra-action behavior only

## [v0.1.5-beta] — 2026-04-14

### Template-Version Enforcement in Compilation

#### Added
- Template-version validation in `scripts/compile-skills.sh` — compilation now fails if a template under `src/templates/` was modified (vs `main`) without bumping its `template-version` field
- "Template-version discipline" convention in `.specshift/CONSTITUTION.md` documenting the enforcement rule

#### Changed
- Finalize instruction in `.specshift/WORKFLOW.md` updated to mention template-version enforcement during compilation

#### Fixed
- Template-version bumps are no longer reliant on manual memory — the compilation step centrally enforces the requirement (Closes #17)

## [v0.1.4-beta] — 2026-04-13

### Plugin Version Check

#### Added
- `plugin-version` field in WORKFLOW.md frontmatter — stamped by `specshift init` from `plugin.json`, enables automatic detection of plugin updates
- Plugin Version Check (Step 3) in SKILL.md router — advisory warning when installed plugin version differs from project's `plugin-version`, with actionable suggestion to run `specshift init`
- Plugin Version Stamp requirement in `project-init.md` — init writes `plugin-version` on fresh install, re-init, and legacy upgrades

#### Changed
- SKILL.md router restructured from 5 redundant steps to 5 clean steps: Load Configuration → Identify Action → Plugin Version Check → Change Context Detection → Dispatch
- WORKFLOW.md is now read exactly once in Step 1 (previously referenced across Steps 1, 2, and 4)
- Workflow template `template-version` bumped from 2 to 3

## [v0.1.3-beta] — 2026-04-13

### Fix Loop Tiered Re-entry

#### Changed
- Fix Loop now classifies corrections into three tiers before applying fixes: **Tweak** (fix in place), **Design Pivot** (update design + re-implement), **Scope Change** (update specs + design + full re-implementation)
- Concrete detection signals added for tier classification (e.g., "correction touches files outside design.md", "completed task needs revert")
- Artifact staleness rule: Design Pivot and Scope Change corrections must update all stale change artifacts before re-implementing
- Step 3.4 in tasks template restructured for readability (sub-bullets per tier)
- Template versions bumped: `workflow.md` and `changes/tasks.md` from v1 to v2

#### Added
- Tier 3 (Scope Change) Gherkin scenario in human-approval-gate spec
- "Tier escalation within fix loop" edge case — handling when a Tweak reveals a deeper problem
- "Ambiguous tier classification" edge case — defaults to higher tier to ensure artifact freshness

## [v0.1.2-beta] — 2026-04-13

### AOT Prompt Compilation

#### Added
- AOT (Ahead-of-Time) skill compilation: requirements are pre-extracted from specs into focused action files during finalize, reducing runtime token usage by ~50%
- `scripts/compile-skills.sh`: standalone compiler script that builds the release directory from source
- `src/actions/`: per-action requirement manifests with clickable relative links to specs
- `.claude/` as plugin root: standard Claude Code plugin layout with auto-discovery + marketplace distribution
- Instruction/requirements separation: instructions stay project-specific in WORKFLOW.md (JIT), requirements are plugin-level in compiled files (AOT)

#### Changed
- Router SKILL.md reads instruction from WORKFLOW.md + compiled requirements from `actions/<action>.md` instead of resolving spec links at runtime
- Marketplace source changed from `./src` to `./.claude`
- Plugin distribution now includes only SKILL.md, compiled actions, templates, and plugin.json — no specs or docs shipped to consumers

## [v0.1.1-beta] — 2026-04-13

### Fix CLAUDE.md re-init drift + agnostic finalize version-bump

#### Fixed
- CLAUDE.md bootstrap template is now checked during re-init — missing standard sections (Workflow, Knowledge Management) are reported as WARNING instead of going undetected (#10)
- Template synchronization convention corrected: `src/templates/` is the authoritative plugin source, `.specshift/` is synced from it

#### Changed
- Consumer finalize version-bump step is now constitution-driven instead of plugin-specific — follows the version-bump convention from the project's constitution, skips if none defined (#11)
- Constitution generation now detects version files (package.json, pyproject.toml, Cargo.toml, etc.) during codebase scan and auto-generates a matching version-bump convention

#### Added
- File Ownership section added to CLAUDE.md documenting `src/` vs `.specshift/` vs `docs/` distinction

## [v0.1.0-beta] — 2026-04-12

Initial beta release. Complete restructuring and rebrand based on [opsx-enhanced-flow](https://github.com/fritze-dev/opsx-enhanced-flow).
