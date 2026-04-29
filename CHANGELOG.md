# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [v0.2.9-beta] — 2026-04-29

### Review Artifact Pipeline Overhead

Restructures the artifact pipeline from 8 stages to 6 (`[proposal, specs, design, preflight, tasks, audit]`): research is absorbed into proposal as a fixed Discovery block, and tests is eliminated as a separate stage — apply-phase test generation is now driven by the project Constitution § Testing. The router (`SKILL.md`) replaces "read all change artifacts" with per-stage `requires:`-based context contracts, and a new `## Sub-Agent Dispatch` section documents the optional sub-agent dispatch pattern (extending the proven review-self-check model from v0.2.8) to apply, finalize, and propose-internal stage generation. Finalize is scoped: capability-list passthrough from proposal frontmatter; ADR generation gated on `design.md` `has_decisions: true`. ADR template is streamlined (Context 2-6 sentences with anti-padding guidance, Consequences optional). `.claudeignore`/`.codexignore` were declined as out-of-scope (target-specific, asymmetric across Claude Code and Codex). Backward compatibility is preserved: legacy change directories with `research.md`/`tests.md` retain their structure and are tolerated by enrichment tooling. Closes #15.

#### Added
- `docs/specs/workflow-contract.md` v10 → v11: NEW Requirements "Per-Stage Context Contract" (each pipeline stage loads only its `requires:` chain; apply reads only proposal/design/tasks/affected specs; finalize reads only proposal/design/audit/listed-capability-specs) and "Sub-Agent Dispatch for Pipeline Stages" (router MAY spawn a sub-agent that invokes the workflow skill on bounded artifact context for apply, finalize, and propose-internal stage generation; described tool-agnostically; references the review-self-check pattern as proven precedent)
- `src/skills/specshift/SKILL.md`: NEW top-level `## Sub-Agent Dispatch` section documenting the optional dispatch pattern in tool-agnostic intent, applicable to apply, finalize, and propose-internal stage generation
- `docs/decisions/adr-004-six-stage-pipeline-and-sub-agent-dispatch.md`: NEW ADR consolidating the seven decisions from `design.md` (six-stage pipeline shape, research-into-proposal merge, tests elimination, preflight retention, design Non-Goals refinement, sub-agent dispatch optionality, `.claudeignore` decline)

#### Changed
- **`docs/specs/artifact-pipeline.md` v7 → v8:** Requirement "Pipeline Stages and Dependencies" now declares the six-stage list `[proposal, specs, design, preflight, tasks, audit]` with research absorbed into proposal § Discovery and apply-phase test generation replacing the tests stage. NEW backward-compat note + scenario covers legacy change directories with `research.md`/`tests.md`.
- **`docs/specs/quality-gates.md` v3 → v4:** Preflight `requires: [design]` clause grammar polish; audit Testing dimension reworded to reference "specs (direct scenario verification)" plus apply-phase tests; fallback-source guidance added for absent preflight (`design.md § Validation` → `tasks.md § Validation Notes`); four test-coverage scenarios rewritten as scenario-verification-against-specs; "Preflight Side-Effect Cross-Check" generalized to "Pre-Implementation Side-Effect Cross-Check" with absent-preflight fallback; positional refs `tasks.md step 3.2` / `step 3.5` replaced with semantic anchors (`tasks.md § Standard Tasks (Post-Implementation)`, "post-implementation QA loop").
- **`docs/specs/test-generation.md` v1 → v2:** Full rewrite. Replaces "Tests stage producing tests.md" with apply-phase test generation. NEW Requirements: Framework Configuration via Constitution, Apply-Phase Automated Test Generation, Scenario Verification Without a Framework, Manual Edit Preservation for Generated Tests, Backward Compatibility With Legacy tests.md.
- **`docs/specs/documentation.md` v2 → v3:** Capability-doc enrichment source updated from `proposal.md + research.md + design.md + preflight.md` to `proposal.md (incl. § Discovery) + design.md + preflight.md` with backward-compat tolerance for legacy `research.md`. ADR generation gated on `design.md` `has_decisions: true`. ADR Context 2-6 sentences with anti-padding; Consequences optional for straightforward decisions. NEW "Auto-dispatch from apply" sub-section: when auto_approve dispatches finalize, the dispatching action passes the capability list from `proposal.md` frontmatter (union of new/modified/removed); finalize regenerates only those capabilities.
- **`docs/specs/workflow-contract.md` v11:** Step 5 of "Router Dispatch Pattern" cross-references the new Per-Stage Context Contract and Sub-Agent Dispatch requirements. Two stale scenario references fixed (Smart-Template example using `research.md`; pipeline-array example listing `research`).
- **`docs/specs/project-init.md`:** Two scenario examples ("Unchanged template updated silently", "User-customized template preserved") use `proposal.md` instead of `research.md` as the illustrative template name (research.md no longer exists in the standard layout).
- **`docs/specs/change-workspace.md`:** Active-change detection example dropped `research.md` (only `proposal.md (status: active) but no tasks.md` per the new pipeline).
- **`src/templates/workflow.md` template-version 13 → 14:** `pipeline:` array shortened to six stages. `## Action: propose` instruction adds per-stage context-contract language. `## Action: apply` adds the apply contract (read only proposal+design+tasks+affected specs). `## Action: finalize` adds the capability-list passthrough.
- **`src/templates/changes/proposal.md` template-version 3 → 4:** Absorbs Discovery sections (Current State, External Research, Approaches, Coverage Assessment, Decisions) from the deleted research template; `requires: []`.
- **`src/templates/changes/design.md` template-version 1 → 2:** Non-Goals instruction refined to capability-limitations only (references Proposal § Scope for change-level boundaries).
- **`src/templates/changes/tasks.md` template-version 5 → 6:** `requires: [preflight]`; apply-phase test guidance added (framework configured → automated tests; "None" → audit-driven scenario verification); Conditional Validation Notes guidance for design-skipped changes.
- **`src/templates/changes/audit.md` template-version 3 → 4:** preflight references → "design.md § Validation when preflight present, else tasks.md § Validation Notes"; tests references → "specs (direct scenario verification)".
- **`src/templates/docs/adr.md` template-version 1 → 2:** Context 2-6 sentences with anti-padding guidance; Consequences section optional for straightforward decisions.
- **`src/templates/docs/capability.md` template-version 2 → 3:** Enrichment source updated to `proposal.md § Discovery + design.md` with legacy `research.md` fallback.
- **`.specshift/WORKFLOW.md` template-version 13 → 14:** Mirror update; documented overrides preserved (`review.request_review: copilot`, `Compile` step in finalize).
- **`.specshift/templates/changes/{proposal,design,tasks,audit}.md`** and **`.specshift/templates/docs/{adr,capability}.md`:** Re-synced from `src/templates/`.
- **`src/actions/propose.md`:** Link to renamed `artifact-pipeline.md` requirement updated `Pipeline Stages and Dependencies` → `Six-Stage Pipeline` so the compile-skills.sh requirement extraction continues to resolve.
- **`src/skills/specshift/SKILL.md`:** Propose dispatch replaces "Read all change artifacts" with "Read only the change artifacts named by the next stage's `requires:` chain"; apply dispatch reads only proposal+design+tasks+affected specs; finalize dispatch reads only proposal+design+audit+listed specs.
- Compile script (`bash scripts/compile-skills.sh`) regenerates `./skills/specshift/` (5 actions / 43 requirements, 0 warnings) and stamps `0.2.9-beta` into the three root manifest/marketplace files.

#### Removed
- `src/templates/changes/research.md` (research stage absorbed into proposal § Discovery)
- `src/templates/changes/tests.md` (tests stage replaced by apply-phase test generation)
- `.specshift/templates/changes/research.md` (project-mirror deletion)
- `.specshift/templates/changes/tests.md` (project-mirror deletion)

## [v0.2.8-beta] — 2026-04-28

### Workflow/Spec-Hygiene Bundle (semantic headings + self-check enforcement)

Bundles two `friction`-labeled issues into one cosmetic-but-spec-deep change. (1) Templates and spec cross-references that used positional structural identifiers (`## 1. Foundation`, `## A. Traceability Matrix`, "section 4 of tasks.md", "8-stage pipeline") are converted to semantic identifiers (`## Foundation`, "Standard Tasks section", "the artifact pipeline"). The `pipeline:` YAML array stays the single source of truth for stage IDs; nothing else hardcodes a count. (2) The `## Action: review` Self-check step — previously one of eleven bullets without observable enforcement — is sharpened: invocation form spelled out, a `<!-- specshift:self-check -->` PR-comment marker (HEAD-anchored, analogous to `<!-- specshift:review-summary -->`) records the result, and the Pre-merge summary refuses to post when no marker exists for the current HEAD. Closes #59 and #58. Released the same day as `v0.2.7-beta`.

#### Added
- `docs/specs/artifact-pipeline.md` v6 → v7: NEW Requirement "Semantic Heading Structure in Pipeline Artifact Templates" with three scenarios (Tasks template uses semantic headings, Cross-reference uses semantic name, Reordering does not break cross-references)
- `docs/specs/review-lifecycle.md` v4 → v6: NEW Requirement "Self-Check Mandatory After Comment Processing" with six scenarios (Self-check invoked after fix commit, Self-check after fixes catches regression, Pre-merge summary refuses without self-check marker, Stale self-check marker forces re-invocation, Self-check invoked before review decision is invalid, Custom-prompted subagent does not satisfy self-check). The last two scenarios (and the requirement's Timing-precondition + Invocation-form sharpening) were added during the review action's User-Testing gate when the original wording allowed two ambiguities the gate itself surfaced.
- `src/actions/review.md`: link to the new Self-Check Mandatory requirement (compile picks 9/9 review requirements after the addition)

#### Changed
- **`docs/specs/artifact-pipeline.md` v7:** Requirement "Eight-Stage Pipeline" renamed to "Pipeline Stages and Dependencies"; stage list declared as the single source of truth, count no longer encoded in the requirement title or body. Standard Tasks Directive scenarios updated to name the section ("Standard Tasks section") instead of the positional identifier ("section 4"). Edge Case "Custom section numbering" removed (obsolete with semantic headings). Purpose paragraph drops the "8-stage" prefix.
- **`docs/specs/three-layer-architecture.md` v6 → v7:** Schema Layer Requirement and its scenario both reference the Pipeline Stages and Dependencies requirement in `artifact-pipeline.md` rather than restating "7-stage" / "exactly 8 artifact IDs". Resolves the existing drift between Lines 30 and 37 (which said different things).
- **`docs/specs/review-lifecycle.md` v6:** Existing "Review Comment Processing" Requirement's advisory wording ("then run the built-in review skill for self-check…") replaced with normative reference to the new Self-Check Mandatory requirement. Pre-Merge Summary Comment Requirement now opens with the marker-presence gate. Edge Case "Self-review finds no issues" rephrased to use marker-PASS terminology. Assumption "Built-in review availability" relabeled "self-check after fixes". Self-Check Mandatory After Comment Processing requirement carries an explicit Timing precondition (self-check SHALL run only AFTER the external review decision is known and any review comments have been processed) and a sharpened Invocation form (canonical: spawn a subagent whose prompt invokes the `review` skill on the current HEAD; inline Skill-tool invocation from the main conversation MAY be used only as a fallback when subagent spawning is unavailable; custom-prompted general-purpose subagents running a hand-written checklist do NOT satisfy the requirement).
- **`src/templates/changes/tasks.md` template-version 4 → 5:** Removed `## N.` numeric prefixes from all five top-level sections (Foundation, Implementation, QA Loop & Human Approval, Standard Tasks (Post-Implementation), Post-Merge Reminders). Instruction-block self-references on "sections 1–3", "section 4", "section 5" replaced with named sections ("Foundation through QA Loop", "Standard Tasks", "Post-Merge Reminders"). Instruction text updated to require semantic heading text in generated `tasks.md`.
- **`src/templates/changes/research.md` template-version 1 → 2:** Removed `## N.` prefixes from all seven top-level sections (Current State, External Research, Approaches, Risks & Constraints, Coverage Assessment, Open Questions, Decisions).
- **`src/templates/changes/preflight.md` template-version 1 → 2:** Removed `## A.` … `## G.` letter prefixes from the seven dimensions (Traceability Matrix, Gap Analysis, Side-Effect Analysis, Constitution Check, Duplication & Consistency, Assumption Audit, Review Marker Audit).
- **`src/templates/changes/audit.md` template-version 2 → 3:** Instruction-block now lists the eight audit dimensions by name (Task Completion, Task-Diff Mapping, Requirement Verification, Scenario Coverage, Design Adherence, Scope Control, Preflight Side-Effects, Test Coverage) instead of numbering them.
- **`src/templates/workflow.md` template-version 11 → 13:** `## Action: finalize` `### Instruction` numbered list (`1. Changelog ... 2. Docs ... 3. Version-bump`) rewritten as semantic bullets (`- **Changelog**: ...`, `- **Docs**: ...`, `- **Version-bump**: ...`). `## Action: review` Self-check bullet sharpened with explicit Timing precondition (only AFTER the external review decision is known) and Invocation form (canonical: spawn a subagent whose prompt invokes the `review` skill on the current HEAD; custom-prompted general-purpose subagents running a hand-written checklist do NOT satisfy this step; inline Skill-tool invocation MAY be used only as a fallback when subagent spawning is unavailable). The resulting `<!-- specshift:self-check -->` PR-comment marker (top of comment body, HEAD-commit SHA + PASS/FIX summary). Pre-merge summary bullet now refuses to post if no marker exists for the current HEAD; explicit stop-and-report path for missing or stale markers. Bumped twice in this release (11 → 12 in the initial implementation; 12 → 13 when the User-Testing gate surfaced the timing + invocation-form ambiguities).
- **`.specshift/WORKFLOW.md` template-version 9 → 11:** Mirror update for the `## Action: finalize` bullets and `## Action: review` Self-check + Pre-merge gate sharpening; project-specific `Compile` bullet preserved. Bumped twice (9 → 10 initial; 10 → 11 with the same User-Testing tightening as `src/templates/workflow.md`).
- **`.specshift/templates/changes/{tasks,research,preflight,audit}.md`:** Re-synced from `src/templates/changes/` (project mirror).
- **`README.md`:** "**8-stage pipeline**" → "**artifact pipeline**" (count no longer hardcoded; stages are listed semantically in `artifact-pipeline.md`).
- **`src/actions/propose.md`:** Link rewritten from "Eight-Stage Pipeline" to "Pipeline Stages and Dependencies" so the compile-skills.sh requirement extraction continues to find the renamed requirement.
- Compile script (`bash scripts/compile-skills.sh`) regenerates `./skills/specshift/` so the shipped skill tree carries the new templates and the +1 review requirement (43/43 extracted, 0 warnings).

#### Specs
- Modified: `artifact-pipeline.md` v7 (Pipeline Stages and Dependencies renamed; Standard Tasks Directive scenarios named; Edge Case "Custom section numbering" removed; NEW Semantic Heading Structure requirement with 3 scenarios)
- Modified: `three-layer-architecture.md` v7 (Schema Layer references Pipeline Stages and Dependencies normatively; existing "7-stage" vs "exactly 8" drift resolved)
- Modified: `review-lifecycle.md` v6 (NEW Self-Check Mandatory After Comment Processing requirement with 6 scenarios; existing Review Comment Processing wording made normative-reference; Pre-Merge Summary Comment gate added; Edge Case + Assumption rephrased; User-Testing gate surfaced two ambiguities — added Timing precondition and tightened Invocation form, plus two scenarios "Self-check invoked before review decision is invalid" and "Custom-prompted subagent does not satisfy self-check")

#### Migration
- Consumers running `specshift init` after this change SHALL see one batched merge prompt covering five bumped templates (`workflow.md` 11→13, `tasks.md` 4→5, `research.md` 1→2, `preflight.md` 1→2, `audit.md` 2→3). No content-loss migration is needed; the bumps are cosmetic-but-structural. (`workflow.md` jumped two versions in the same release because the User-Testing gate surfaced spec ambiguities that warranted a second sharpening pass within the same change.)
- Consumers with custom templates that re-introduced numeric prefixes (`## 1. ...`) MAY keep them locally; the new `Semantic Heading Structure` requirement enforces lazy migration ("SHALL be removed when the template is next modified"), not retroactively.
- Existing in-flight changes (proposals already started before this merge) keep their old artifact bodies — only NEW changes get semantic headings.
- Historical artifacts under `.specshift/changes/2026-*-*/` are intentionally untouched. CHANGELOG references to past `step 3` / `step 7` / `step 8` (Lines 16, 149, 174 in this file) are historical and remain.
- Self-check marker is opt-in by virtue of being the new normative gate — first PR to use the new marker is THIS PR (review action validates itself).

#### Notes
- Issue #57 (HTML-comment bug in spec/design/preflight templates) intentionally NOT bundled — the side-effect investigation is non-trivial and was explicitly scoped to a separate change. Issues #56 (build-time catalog verification), #55 (CONSTITUTION trim), #49 (release.yml sed pipeline), #48 (CHANGELOG breaking-note placement) remain open as independent follow-ups.

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
- **Generic ignore-unknown-fields rule** (`docs/specs/change-workspace.md > Create Change Workspace`): replaces the prior `worktree`-specific legacy-handling text. Skills SHALL ignore unknown frontmatter fields when reading proposals — historical proposals may carry fields that are no longer part of the current contract. Effect: this PR's spec corpus contains zero references to the removed `worktree` field; migration is documented in this CHANGELOG entry only.
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
