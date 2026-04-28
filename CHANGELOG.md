# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [v0.2.7-beta] — 2026-04-28

### Remove Worktrees from SpecShift Workflow

SpecShift no longer owns a worktree lifecycle. Worktree isolation is a host/tool concern — Claude Code, the Codex CLI, and plain `git worktree` already provide it. Carrying our own creation, lazy stale cleanup, post-merge cleanup, and change-context fallback added significant surface area without giving users anything they could not get from their host. Removing it tightens SpecShift's scope to "file-based change workspaces under `.specshift/changes/`" and shrinks the propose / finalize / review actions and the change-workspace spec correspondingly. Closes #47. Released the same day as `v0.2.6-beta` and built on top of it — the `multi-target-distribution.md` v5 spec from `v0.2.6-beta` is amended here to drop the orphan `Worktree-path references` sub-rule.

#### Removed
- `worktree:` config block in `.specshift/WORKFLOW.md` and `src/templates/workflow.md` (was: `enabled`, `path_pattern`, `auto_cleanup`, `stale_days`)
- `Create Worktree-Based Workspace`, `Lazy Worktree Cleanup at Change Creation`, and `Post-Merge Worktree Cleanup` requirements from `docs/specs/change-workspace.md`
- `GitHub Merge Strategy Configuration` requirement and worktree opt-in / git-2.5+ / `.gitignore /.claude/` env-checks from `docs/specs/project-init.md` (the rebase-merge config was tied exclusively to worktree opt-in; the review action squash-merges)
- Worktree-convention fallback (former step 3) from the router's Change Context Detection in `src/skills/specshift/SKILL.md` — detection is now a 2-tier sequence: proposal frontmatter `branch:` lookup → directory listing prompt
- Worktree-related links from `src/actions/{propose,finalize,review}.md` (action manifests no longer pull deleted requirements)
- `Worktree-path references` sub-rule from the `Agnostic Skill Body` requirement in `docs/specs/multi-target-distribution.md` (referenced a config key that no longer exists)
- `worktree:` field documentation from the proposal-tracking frontmatter in both `src/templates/changes/proposal.md` and `.specshift/templates/changes/proposal.md`
- `worktree.enabled: true` reference from `AGENTS.md`'s `**.specshift/**` File Ownership note

#### Changed
- **BREAKING (consumer config):** Consumers who set `worktree.enabled: true` in their project's `.specshift/WORKFLOW.md` will silently get the file-based workspace flow. The config key is no longer read by any action. Existing on-disk worktrees are not auto-cleaned by SpecShift anymore — users may run `git worktree remove <path>` manually. Hosts (Claude Code's Agent isolation, Codex CLI, `git worktree`) continue to provide worktree affordances independently of SpecShift
- Action review (post-merge cleanup): switching to the repository's default branch is now a required prerequisite before deleting the local feature branch (deleting the currently checked-out branch fails); applies to `src/templates/workflow.md`, `.specshift/WORKFLOW.md`, `docs/specs/review-lifecycle.md`, and the compiled `skills/specshift/templates/workflow.md`
- Spec consistency: `Change Context Detection` directory-listing fallback in `docs/specs/change-workspace.md` and `docs/specs/workflow-contract.md` now describes action-dependent listing (`propose` / `apply` → `status: active`; `finalize` / `review` → `status: review`), aligned with `src/skills/specshift/SKILL.md`
- `src/templates/workflow.md` `template-version` 9 → 11; `src/templates/changes/proposal.md` 2 → 3 (per CONSTITUTION's "Template-version discipline")
- Compile script (`bash scripts/compile-skills.sh`) regenerates `./skills/specshift/` so the shipped skill tree stops mentioning worktrees

#### Specs
- Modified: `change-workspace.md` v5 (4 requirements; was 7), `project-init.md` v7 (12 requirements; was 13), `artifact-pipeline.md` v6 (14 requirements; worktree-config scenarios trimmed in-place — count unchanged), `review-lifecycle.md` v4 (purpose paragraph trimmed; merge sequence requires switching to default branch before local-branch deletion), `workflow-contract.md` v10 (frontmatter list trimmed; Router Dispatch Pattern documented as 2-tier with action-dependent listing), `multi-target-distribution.md` v5 (Agnostic Skill Body sub-rules renumbered — the "Worktree-path references" sub-rule that referenced `worktree.path_pattern` is dropped on top of `0.2.6-beta`'s Codex Marketplace Catalog rework)

#### Migration
- For consumers actively using worktree mode: remove the `worktree:` block from your `.specshift/WORKFLOW.md` (silently ignored otherwise) and clean up any on-disk worktrees with `git worktree remove`
- Existing in-flight proposals carrying a `worktree: <path>` frontmatter field are treated as legacy/read-only — SpecShift no longer writes the field on new proposals and ignores it on read. No migration tooling is needed
- Historical change directories under `.specshift/changes/2026-03-30-worktree-based-change-lifecycle/`, `2026-04-09-worktree-fetch-main/`, `2026-04-11-fix-stale-worktree-detection/`, and `2026-03-30-fix-squash-merge-cleanup/` are intentionally untouched as historical record

## [v0.2.6-beta] — 2026-04-28

### Codex Marketplace Catalog

The `0.2.5-beta` Codex install path relied on a documented auto-discovery assumption (`codex plugin marketplace add owner/repo` reads `.codex-plugin/plugin.json` directly without a catalog file). This assumption was falsified against a live Codex install — Codex actually expects a marketplace catalog at `.agents/plugins/marketplace.json`. The catalog file was committed in `71c000fc`; this release pulls the spec, AGENTS.md, CONSTITUTION.md, README.md, ADR-003, and capability doc into alignment with the shipped reality.

#### Added
- `docs/specs/multi-target-distribution.md` v5: new Requirement "Codex Marketplace Catalog Schema" documenting the Git-URL source form, `policy.installation: "AVAILABLE"`, `policy.authentication: "ON_INSTALL"`, and `category` field (two scenarios verifiable via `jq`)
- `README.md` Multi-Target Distribution tree: added `.agents/plugins/marketplace.json` entry alongside the existing per-target manifest dirs

#### Changed
- `docs/specs/multi-target-distribution.md` v5: Requirement "Codex Discovery via Marketplace Add" renamed to "Codex Discovery via Marketplace Catalog" — clause inverted from "SHALL NOT ship" to "SHALL ship `.agents/plugins/marketplace.json` at the repository root"; "No Codex marketplace catalog file shipped" Scenario replaced with "Codex marketplace catalog file shipped at root"; Edge Case "Codex auto-discovery semantics change" rewritten as "Codex catalog schema change"; Assumption "Codex single-plugin auto-discovery" rewritten as "Codex catalog-mediated install" recording the falsification
- `docs/specs/release-workflow.md` v6: Requirement "Source and Release Directory Structure" — "no separate Codex marketplace catalog file is shipped" sentence replaced with the four-file description (three version-bearing + one catalog without `version` field). Requirement "Developer Local Marketplace Workflow" scoped to Claude Code only (SpecShift is developed against Claude Code; Codex local-development setup is out of scope — Codex is a distribution target, covered by consumer install/update requirements)
- `AGENTS.md` File Ownership: file list expanded from three to four; sentence rewritten to describe verified two-step Codex install path
- `.specshift/CONSTITUTION.md` Architecture Rules: same content update, scoped to constitution's terser style
- `README.md` Installation → OpenAI Codex CLI: replaced the prior `codex /plugins`-only placeholder with the documented Codex install flow per `developers.openai.com/codex/plugins/build` — `codex plugin marketplace add fritze-dev/SpecShift` followed by enabling SpecShift from the in-session `/plugins` directory, plus an Update subsection (`codex plugin marketplace upgrade specshift`). Reconciled `docs/specs/multi-target-distribution.md`'s "Multi-Target Install Documentation" scenario and `docs/specs/release-workflow.md`'s "Consumer Update Process" / "End-to-End Install Checklist" / "Developer Local Marketplace Workflow" requirements with the same canonical commands; regenerated `docs/capabilities/release-workflow.md`
- `docs/decisions/adr-003-shopify-flat-multi-target-distribution.md`: amended with Decision 6 — record the falsification of the auto-discovery assumption and the choice of Git-URL source over `local`-path source; updated rejected-alternative paragraph forwards to Decision 6

#### Specs
- Modified: `multi-target-distribution.md` v4 → v5 (Codex Discovery via Marketplace Catalog clause inversion + scenario replacement; new Codex Marketplace Catalog Schema requirement; Edge Case + Assumption rewrites; Purpose paragraph updated to mention four root files)
- Modified: `release-workflow.md` v5 → v6 (Source and Release Directory Structure paragraph rewritten for the four-file layout)

#### Notes
- `.agents/plugins/marketplace.json` is hand-edited; it has no `version` field and is not version-stamped by `bash scripts/compile-skills.sh`. The script remains unchanged in this release — `verify_catalog_shape()` defense-in-depth, `.github/workflows/release.yml` cross-check loop extension for the catalog, and the compile-script header comments at lines 6–9 and 147 (which preemptively say "four root files" while the code path stamps three) are bundled into Issue #56 (build-time verification of the Codex catalog) for a separate change.
- Issue #51's live-Codex-smoke-test acceptance criterion is not met in this release; a separate verification step on a clean Codex install is needed to fully close it.
- Issue #55 tracks a follow-up trim of Codex-specific reference info from `.specshift/CONSTITUTION.md` (only pipeline guardrails should remain there).

## [v0.2.5-beta] — 2026-04-27

### Multi-Target Distribution (Claude Code + Codex CLI)

SpecShift now ships from a single repository to two AI-coding-tool targets — Claude Code and OpenAI Codex CLI — via a Shopify-flat layout, with one shared agnostic skill tree at `./skills/specshift/` consumed by both targets through their respective root manifests. Bootstrap content lives once in `AGENTS.md` (read by Codex natively, by Claude Code via the `@AGENTS.md` import expanded from `CLAUDE.md`). The plugin version is now sourced from a single agnostic file at `src/VERSION` and stamped into the three root manifest/marketplace files at compile time, with a post-stamp cross-check that fails the build on drift.

#### Added
- Codex CLI plugin support: `.codex-plugin/plugin.json` (hand-edited at repo root, full Codex schema including `skills`, `interface`, `category`, `capabilities`, `defaultPrompt`, `brandColor`). Codex consumers install via `codex plugin marketplace add github:fritze-dev/specshift`, which auto-discovers the manifest — no separate Codex marketplace catalog file is shipped (per the documented Codex single-plugin auto-discovery path)
- Agnostic version source of truth: `src/VERSION` (plain text, single line, SemVer) — the only file the maintainer edits to bump the plugin version
- Symmetric version stamping with cross-check across `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json` (compile script reads `src/VERSION`, jq-stamps each, re-reads and verifies; any mismatch fails the build). Same cross-check is also enforced in CI via `release.yml` before tag creation
- Bootstrap single source of truth: `src/templates/agents.md` carries the full body; `src/templates/claude.md` is reduced to a one-line `@AGENTS.md` import stub. `specshift init` generates both `AGENTS.md` and `CLAUDE.md` on fresh init
- New spec `docs/specs/multi-target-distribution.md` with 8 requirements (per-target manifests, shared skill tree, Codex marketplace entry, bootstrap SoT pattern, agnostic skill body, multi-target install docs, version SoT, symmetric stamping)

#### Changed
- **BREAKING (marketplace path):** `.claude-plugin/marketplace.json` `source` field changed from `./.claude` to `./`. The compiled skill tree moved from `.claude/skills/specshift/` to `./skills/specshift/`. Existing Claude Code installs run `claude plugin marketplace update specshift && claude plugin update specshift@specshift` once after upgrading
- Plugin manifests moved from `src/.claude-plugin/` to the repo root (`.claude-plugin/plugin.json`); `src/.claude-plugin/` deleted. Per-target manifests are now hand-edited at the root and carry per-target metadata only — their `version` is stamped from `src/VERSION`
- Compile script (`scripts/compile-skills.sh`) rewritten: reads `src/VERSION`, validates it as a SemVer 2.0 string, stamps the three root manifest/marketplace files via `jq` with post-stamp cross-check, emits one shared agnostic skill tree at `./skills/specshift/`, removes legacy `.claude/skills/specshift/` and `.claude/.claude-plugin/`. `jq` is now a hard preflight requirement
- Release CI (`.github/workflows/release.yml`): added a manifest-version cross-check step that runs before tag creation, ensuring the three root files match `src/VERSION` and failing the workflow on drift (catches the foot-gun where a maintainer edits `src/VERSION` without recompiling)
- `specshift finalize` version-bump step now edits only `src/VERSION` — manifest version fields are stamped at compile time
- `specshift init` now generates both `AGENTS.md` (full body) and `CLAUDE.md` (one-line `@AGENTS.md` import stub) instead of just `CLAUDE.md` on fresh init
- `.github/workflows/release.yml` now triggers on `src/VERSION` changes and reads the version from `src/VERSION` instead of from a manifest
- Worktree default path pattern: `.claude/worktrees/{change}` → `.specshift/worktrees/{change}` (tool-agnostic; specs and project WORKFLOW.md updated)
- `README.md` restructured with per-target install sections (Claude Code + Codex), updated project-structure tree, new Multi-Target Distribution section
- `.specshift/CONSTITUTION.md` Architecture Rules and Conventions updated for the new layout, version SoT, and agent-instructions SoT

#### Specs
- New: `multi-target-distribution.md` v1
- Modified: `project-init.md` v6 (Bootstrap Files Generation requirement replaces CLAUDE.md Bootstrap; tool-agnostic prose for plugin paths)
- Modified: `release-workflow.md` v4 (Auto-Patch-Bump, Version-Sync, Manual-Release, Source/Release-Directory-Structure, Marketplace-Source-Configuration, Repository-Layout-Separation, AOT-Skill-Compilation, Compiled-Action-File-Contract, Dev-Sync-Script, Automated-GitHub-Release-via-CI, Changelog-Version-Headers, Developer-Local-Marketplace, Consumer-Update-Process, End-to-End-Install-and-Update-Checklist all rewritten for the multi-target reality)
- Modified: `artifact-pipeline.md` v5, `change-workspace.md` v4 (worktree path-pattern agnostic update)

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
