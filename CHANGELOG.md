# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [v0.2.5-beta] — 2026-04-27

### Codex Plugin Support (Multi-Target Distribution)

#### Added
- New plugin manifest source under `src/.codex-plugin/plugin.json` and compiled output at `.codex-plugin/plugin.json` — SpecShift now ships as both a Claude Code and an OpenAI Codex CLI plugin
- New Codex marketplace entry generated at `.agents/plugins/marketplace.json` from `src/marketplace/codex.json`
- New bootstrap-template `src/templates/agents.md` carrying the full agent-directives body (Workflow, Planning, Knowledge Management) — single source of truth for both targets
- Project-level `AGENTS.md` generated for this repo to model the new pattern
- New capability spec `docs/specs/multi-target-distribution.md` covering manifest parity, shared skill-tree layout, Codex marketplace, and bootstrap pattern

#### Changed
- **BREAKING (marketplace path):** `.claude-plugin/marketplace.json` source moved from `./.claude` to `./` — the compiled skill tree now lives at `./skills/specshift/` (Shopify-AI-Toolkit layout). Existing Claude Code installs run `claude plugin marketplace update specshift` to pick up the new layout.
- `src/templates/claude.md` reduced from full body to a single-line `@AGENTS.md` import stub (template-version 4 → 5). Claude Code's documented memory-import syntax loads AGENTS.md content into the session, so no content is duplicated between bootstrap files.
- `src/templates/workflow.md` `## Action: init` instruction updated: init now generates both AGENTS.md (full body) and CLAUDE.md (import stub) on fresh setup; on re-init it preserves existing files and warns about missing standard sections (template-version 8 → 9).
- `scripts/compile-skills.sh` migrated to multi-target output: emits both manifests at the repo root, the shared `./skills/specshift/` tree, and the Codex marketplace file; removes the legacy `.claude/skills/` location; stamps the same `version` (read from the Claude source manifest) into all generated files.
- `.specshift/CONSTITUTION.md` updated: release directory `.claude/skills/specshift/` → `./skills/specshift/`; plugin source layout convention documents both manifest source dirs and the new marketplace source path; agent instructions now point to AGENTS.md as the single source of truth.
- `README.md` restructured into per-target install sections (Claude Code + Codex), updated Project Structure and Architecture sections to reflect multi-target layout.

#### Specs
- `multi-target-distribution.md` v1: new capability — Per-Target Plugin Manifest, Shared Skill Tree at Repository Root, Codex Marketplace Entry, Bootstrap Single Source of Truth Pattern, Multi-Target Install Documentation
- `project-init.md` v6: replaced "CLAUDE.md Bootstrap" requirement with "Bootstrap Files Generation" requirement covering both AGENTS.md and CLAUDE.md generation; "Install Workflow" updated to add `agents.md` to the bootstrap-template exclusion list

### Codex Plugin Support — Hardening Pass

Second-pass extension on top of the first commit, aligning the implementation with the original goal: one agnostic skill body served to both Claude Code and Codex from a single compiled tree, hand-edited per-target manifests at the repo root, and a narrower bootstrap (fresh init now writes AGENTS.md only).

#### Changed
- **BREAKING (init bootstrap behavior):** `specshift init` no longer auto-generates `CLAUDE.md`. Fresh init writes only `AGENTS.md` (the agnostic single source of truth). Claude Code consumers who want the documented `@AGENTS.md` memory-import pattern create their own `CLAUDE.md` from the still-shipped `templates/claude.md` stub. Existing CLAUDE.md files are detected on re-init with WARNING-only standard-section checks; they are never modified.
- **BREAKING (manifest source location):** Plugin manifests are now hand-edited at the repo root (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`) instead of under `src/.claude-plugin/` and `src/.codex-plugin/`. The `src/` manifest directories are deleted. The compile script reads the version from `.claude-plugin/plugin.json` (the source of truth) and stamps it into the Codex manifest in place via `jq`, preserving all other Codex fields verbatim.
- Source skill body (SKILL.md, templates, action specs that compile into `./skills/specshift/`) is now agnostic: replaced `${CLAUDE_PLUGIN_ROOT}/...` with prose ("the plugin's `templates/` directory"), generalized "Claude Code Web" to "ephemeral / stateless agent sessions" where it appeared as a User Story, "Claude Code plugin system" → "the host plugin system (Claude Code, Codex CLI)", and translation rule lists both product names. Codex has no equivalent of `${CLAUDE_PLUGIN_ROOT}` (verified against `developers.openai.com/codex/skills` and Shopify-AI-Toolkit), so the source is now tool-neutral and the same compiled artifact serves both targets without per-target rewrites.
- `.codex-plugin/plugin.json` enriched with `author`, `homepage`, `repository`, `license`, `keywords`, and Codex UI fields (`interface.longDescription`, `developerName`, `websiteURL`, `defaultPrompt[]`, `brandColor`, `screenshots[]`) for better Codex `/plugins` discoverability.
- `scripts/compile-skills.sh` simplified: drops manifest copy blocks (manifests are hand-edited at root); reads version from root `.claude-plugin/plugin.json`; stamps Codex manifest via `jq`; cross-checks emitted Codex version equals Claude source after stamping; emits one shared agnostic skill tree (no per-target rewrite functions).
- `src/templates/workflow.md` v9 → 10: `## Action: init` rewritten for fresh-init-AGENTS-only behavior; commented worktree `path_pattern` default → `.specshift/worktrees/{change}`. `.specshift/WORKFLOW.md` synced.

#### Specs
- `release-workflow.md` v3 → 4: Auto Patch Version Bump, Version Sync Between Plugin Files, Manual Minor and Major Release Process, Source and Release Directory Structure, Marketplace Source Configuration, Repository Layout Separation, AOT Skill Compilation, Compiled Action File Contract, Dev Sync Script — all rewritten for multi-target reality with manifests hand-edited at the repo root and `jq`-based version stamping
- `multi-target-distribution.md` v1 → 2: Per-Target Plugin Manifest revised for hand-edited root manifests with enrichment; Bootstrap SSOT revised for manual-copy `claude.md`; new **Agnostic Skill Body** requirement
- `project-init.md` v6 → 7: `${CLAUDE_PLUGIN_ROOT}` references replaced with prose; **Bootstrap Files Generation** requirement rewritten for fresh-init-AGENTS-only (Option A — CLAUDE.md is opt-in via the still-shipped `claude.md` stub)
- `change-workspace.md` v3 → 4: example worktree paths use `.specshift/worktrees/...` instead of `.claude/worktrees/...`
- `artifact-pipeline.md` v4 → 5: default `path_pattern` is now `.specshift/worktrees/{change}`
- `review-lifecycle.md`, `three-layer-architecture.md`, `documentation.md`: wording-only edits to align with agnostic-skill-body requirement

#### Migration Notes
- Existing Claude Code consumers run the same `claude plugin marketplace update specshift && claude plugin update specshift@specshift` flow — no path changes from the consumer perspective.
- Maintainer flow: edit version in `.claude-plugin/plugin.json` (was `src/.claude-plugin/plugin.json`); run `bash scripts/compile-skills.sh` to stamp Codex manifest and marketplace; push.
- Codex consumers running an existing install run `codex /plugins` and refresh/reinstall to pick up the enriched manifest.

## [v0.2.4-beta] — 2026-04-15

### Fix Review Action Friction Issues

#### Fixed
- Review dispatch now verifies clean working tree before requesting external review — uncommitted changes (e.g., from finalize compilation) are committed and pushed first (Closes #36)
- Merge is no longer offered while a requested review is pending — action reports "Review pending" and suggests re-running later (Closes #36)
- `auto_approve` no longer skips review dispatch when `request_review` is configured — reviews are dispatched and awaited normally when explicitly configured (Closes #40)
- Proposal `status: completed` is now set on the feature branch before squash merge, eliminating the extra post-merge commit on main (Closes #41)

#### Specs
- `review-lifecycle.md` v3: amended "Review Request Dispatch" (clean-tree prerequisite), amended "Merge Execution" (review-pending gate, status timing before merge)

## [v0.2.3-beta] — 2026-04-15

### Fix Version Drift Between CHANGELOG, Tags, and GitHub Releases

#### Fixed
- CHANGELOG.md reformatted with `## [version] — date` headers — all previously released versions now map to their corresponding git tags
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
