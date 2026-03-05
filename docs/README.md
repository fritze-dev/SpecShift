# Documentation

## System Architecture

The opsx-enhanced plugin uses a three-layer architecture that separates concerns across Constitution, Schema, and Skills:

- **Constitution Layer** — A single `constitution.md` file at `openspec/constitution.md` defines global project rules: Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. All AI actions read the constitution before performing any work, enforced via `config.yaml` workflow rules. The constitution is the single authoritative source for project-wide rules that apply across all skills and artifacts.

- **Schema Layer** — The `opsx-enhanced` schema at `openspec/schemas/opsx-enhanced/` defines a 6-stage artifact pipeline (research → proposal → specs → design → preflight → tasks). Each artifact has a template, instruction, and dependency list. The schema is the single source of truth for pipeline structure and artifact generation instructions.

- **Skills Layer** — All 13 commands are delivered as `skills/*/SKILL.md` files within the Claude Code plugin system. Skills are categorized as workflow (new, continue, ff, apply, verify, archive), governance (init, bootstrap, discover, preflight, sync), or documentation (changelog, docs). All skills are model-invocable.

The three layers are independently modifiable — the schema does not embed skill logic, skills depend on the schema via the OpenSpec CLI, and the constitution does not contain schema-specific artifact definitions.

## Tech Stack

- **Primary format:** Markdown (artifacts, specs, skills, documentation)
- **Configuration:** YAML (schema.yaml, config.yaml)
- **Shell:** Bash (skill command execution)
- **Core dependency:** OpenSpec CLI (`@fission-ai/openspec@^1.2.0`)
- **Runtime:** Node.js + npm (required for OpenSpec CLI)
- **Platform:** Claude Code plugin system
- **Package manager:** npm (global installs only — no project-level package.json)

## Key Design Decisions

| Decision | Rationale | ADR |
|----------|-----------|-----|
| 15 capabilities (not one per skill) | Groups related behavior logically — e.g., continue+ff under artifact-generation | [ADR-001](decisions/adr-001-15-capabilities-not-one-per-skill.md) |
| Use `/opsx:sync` for baseline creation, not programmatic archive merge | Programmatic merge has format limitations (missing Purpose, header matching issues) | [ADR-002](decisions/adr-002-use-opsx-sync-for-baseline-creation-not-programmat.md) |
| Empty tasks.md (QA loop only) | No code to implement — this is a documentation bootstrap | [ADR-003](decisions/adr-003-empty-tasks-md-qa-loop-only.md) |
| Schema owns workflow rules | DoD and post-apply sequence apply to ALL projects using opsx-enhanced — they belong in the shared schema | [ADR-004](decisions/adr-004-schema-owns-workflow-rules.md) |
| Config as bootstrap-only | config.yaml's purpose is per-project customization; with rules in schema and project rules in constitution, config just needs to point to the constitution | [ADR-005](decisions/adr-005-config-as-bootstrap-only.md) |
| Remove constitution redundancies | 12 rules duplicated schema instructions/templates; single source of truth prevents drift | [ADR-006](decisions/adr-006-remove-constitution-redundancies.md) |
| Init generates minimal config template | Prevents project-specific rules from leaking into consumer projects | [ADR-007](decisions/adr-007-init-generates-minimal-config-template.md) |
| Convention in constitution, not skill modification | Skills are shared across consumers; project-specific behavior belongs in constitution | [ADR-008](decisions/adr-008-convention-in-constitution-not-skill-modification.md) |
| Patch-only auto-bump | 95%+ of changes are patches; minor/major are rare and intentional | [ADR-009](decisions/adr-009-patch-only-auto-bump.md) |
| Sync marketplace.json in same convention | One operation, no drift | [ADR-010](decisions/adr-010-sync-marketplace-json-in-same-convention.md) |
| Docs page for minor/major | Rare enough for manual process | [ADR-011](decisions/adr-011-docs-page-for-minor-major.md) |
| Split `docs-generation` into focused capabilities | Each concern is independently spec'd and testable; changelog fits better under release-workflow | [ADR-012](decisions/adr-012-split-docs-generation-into-focused-capabilities.md) |
| All doc types in `/opsx:docs`, no new skills | User preference, avoids skill proliferation, single entry point | [ADR-013](decisions/adr-013-all-doc-types-in-opsx-docs-no-new-skills.md) |
| Direct glob per capability instead of pre-built index | Simpler, no separate step needed, archives are few | [ADR-014](decisions/adr-014-direct-glob-per-capability-instead-of-pre-built-in.md) |
| ADRs fully regenerated each run | Deterministic, no state to track, numbering always consistent | [ADR-015](decisions/adr-015-adrs-fully-regenerated-each-run.md) |
| Research context integrated into ADR Context section | One place for "why did we decide this?", avoids separate research log | [ADR-016](decisions/adr-016-research-context-integrated-into-adr-context-secti.md) |
| "Why This Exists" uses newest archive's proposal | Most current motivation, older may be superseded | [ADR-017](decisions/adr-017-why-this-exists-uses-newest-archives-proposal.md) |
| Initial-spec-only capabilities use spec Purpose | Bootstrap proposal "Why" is about spec creation, not individual capabilities | [ADR-018](decisions/adr-018-initial-spec-only-capabilities-use-spec-purpose.md) |
| Constitution convention only | Respects skill immutability; constitution is always loaded and authoritative | [ADR-019](decisions/adr-019-constitution-convention-only.md) |
| Checkpoint after design specifically | Design finalizes approach/architecture — last point where feedback is cheap before quality gates | [ADR-020](decisions/adr-020-checkpoint-after-design-specifically.md) |
| Skip checkpoint when preflight already done | Avoids unnecessary friction on resume; preflight existence implies prior design review | [ADR-021](decisions/adr-021-skip-checkpoint-when-preflight-already-done.md) |
| Update constitution before spec | Constitution establishes the governance rule; spec formalizes the behavioral change | [ADR-022](decisions/adr-022-update-constitution-before-spec.md) |
| SKILL.md references templates via Read at runtime | Consistent with pipeline; format changes don't require prompt edits | [ADR-023](decisions/adr-023-skill-md-references-templates-via-read-at-runtime.md) |
| Consolidated README replaces 3 separate files | Eliminates navigation hops; architecture overview IS the entry point | [ADR-024](decisions/adr-024-consolidated-readme-replaces-3-separate-files.md) |
| Cleanup step in SKILL.md deletes stale files | Consumer projects need automated migration from old 3-file to new 1-file structure | [ADR-025](decisions/adr-025-cleanup-step-in-skill-md-deletes-stale-files.md) |
| ADR generation runs BEFORE README generation | README needs ADR file paths for inline links | [ADR-026](decisions/adr-026-adr-generation-runs-before-readme-generation.md) |
| Ordering + grouping via `order` and `category` YAML frontmatter | Project-specific, deterministic, set during spec creation | [ADR-027](decisions/adr-027-ordering-grouping-via-order-and-category-yaml-fron.md) |
| README shortening is a separate implementation task | README is hand-written; changes are independent of auto-generated docs | [ADR-028](decisions/adr-028-readme-shortening-is-a-separate-implementation-tas.md) |
| Unified "Purpose" heading for all docs | Standard, unambiguous term; eliminates enriched vs spec-only inconsistency | [ADR-029](decisions/adr-029-unified-purpose-heading-for-all-docs.md) |
| Unified "Rationale" heading for all docs | Standard ADR terminology; covers both research-based and assumption-based design reasoning | [ADR-030](decisions/adr-030-unified-rationale-heading-for-all-docs.md) |
| Separate "Future Enhancements" from "Known Limitations" | Limitations = current constraints; Enhancements = actionable future ideas | [ADR-031](decisions/adr-031-separate-future-enhancements-from-known-limitation.md) |
| "Read before write" guardrail in SKILL.md | Prevents quality regression by requiring agent to read existing doc before generating | [ADR-032](decisions/adr-032-read-before-write-guardrail-in-skill-md.md) |
| Manual doc fixes + deferred regeneration | Safer: preserves established quality, validates guardrails separately | [ADR-033](decisions/adr-033-manual-doc-fixes-deferred-regeneration.md) |
| Single `docs_language` field in config.yaml | Central, backward-compatible, read by all skills via existing config loading | [ADR-034](decisions/adr-034-single-docs-language-field-in-config-yaml.md) |
| Commented-out field in init template for discoverability | Users discover the feature without it being active by default | [ADR-035](decisions/adr-035-commented-out-field-in-init-template-for-discovera.md) |
| English enforcement via config `context` field | Context is passed to all skills automatically — single enforcement point | [ADR-036](decisions/adr-036-english-enforcement-via-config-context-field.md) |
| Translation at generation time, not in templates | Templates are structural guides; one set of templates for all languages | [ADR-037](decisions/adr-037-translation-at-generation-time-not-in-templates.md) |
| Manual ADRs use `adr-MNNN-slug.md` naming | No extra directory needed; M prefix unambiguously distinguishes from generated ADRs | [ADR-038](decisions/adr-038-manual-adrs-use-adr-mnnn-slug-md-naming-in-docs-de.md) |
| Deterministic slug: replace non-`[a-z0-9]` with hyphen | Handles all special chars uniformly; produces consistent results across runs | [ADR-039](decisions/adr-039-deterministic-slug-replace-non-a-z0-9-with-hyphen.md) |
| Fix both specs AND SKILL.md/templates | Specs define requirements; SKILL.md defines execution; both must agree to prevent drift | [ADR-040](decisions/adr-040-fix-both-specs-and-skill-md-templates.md) |
| Replace priority rule with section-completeness rule | Positive guidance ("include when data exists") prevents section dropping without removing conciseness guards | [ADR-041](decisions/adr-041-replace-priority-rule-with-section-comple.md) |
| Add enrichment reads only to Step 4, not all steps | Only Step 4 has the implicit dependency problem; step independence guardrail covers the general case | [ADR-042](decisions/adr-042-add-enrichment-reads-only-to-step-4-not-al.md) |
| Add step independence as a guardrail, not a structural change | Simpler than restructuring all steps; matches existing SKILL.md guardrails pattern | [ADR-043](decisions/adr-043-add-step-independence-as-a-guardrail-not-a.md) |
| Reinforce specs with step independence language | Keeps specs and skill aligned; prevents future drift between spec and implementation | [ADR-044](decisions/adr-044-reinforce-specs-with-step-independence-lang.md) |
| Init is model-invocable, not user-only | `disable-model-invocation: true` makes skills undiscoverable; bootstrap needs programmatic init | [ADR-M001](decisions/adr-M001-init-model-invocable.md) |

### Notable Trade-offs

- **15 capabilities (ADR-001)**: 15 specs is a significant number to maintain, though each is self-contained and drift detection mitigates this.
- **Schema owns workflow rules (ADR-004)**: Reduced defense-in-depth — rules now live in one place instead of being duplicated across config, constitution, and schema.
- **Convention in constitution (ADR-008)**: Convention compliance depends on the agent reading and following the constitution, mitigated by constitution being read at the start of every skill execution.
- **Patch-only auto-bump (ADR-009)**: Version inflation from many small patches; no rollback mechanism for a bad version — consumer must wait for the next patch.
- **Docs page for minor/major (ADR-011)**: Users must remember the manual process for minor/major bumps.
- **Split docs-generation (ADR-012)**: Three specs to maintain instead of one, though each is simpler and more focused.
- **All doc types in /opsx:docs (ADR-013)**: The skill prompt is longer (~300 lines) due to handling multiple documentation types.
- **ADRs fully regenerated each run (ADR-015)**: All ADR files are rewritten on every run, even if nothing changed.
- **Research context in ADR Context (ADR-016)**: ADR Context sections are longer than minimal ADRs, though the added context improves usefulness.
- **"Why This Exists" uses newest archive (ADR-017)**: Historical motivation from earlier proposals is not surfaced, though it remains accessible in the archives.
- **Constitution convention only (ADR-019)**: Soft enforcement only — depends on agent compliance rather than hard code enforcement.
- **Consolidated README (ADR-024)**: Breaking external links to `docs/architecture-overview.md` and `docs/decisions/README.md` for anyone who bookmarked those paths.
- **Ordering via YAML frontmatter (ADR-027)**: Every baseline spec needs frontmatter added, increasing the per-spec maintenance surface.
- **Future Enhancements separation (ADR-031)**: Some items require judgment to classify as "limitation" vs. "enhancement."
- **Read-before-write guardrail (ADR-032)**: Guardrail is advisory, not programmatically enforced — agent compliance depends on instruction quality.
- **Manual doc fixes deferred (ADR-033)**: Current docs are manually curated — potential drift between SKILL.md instructions and actual doc content until regeneration occurs.
- **Single docs_language field (ADR-034)**: LLM translation quality varies by language; no runtime validation of the value.
- **Translation at generation time (ADR-037)**: Translation quality depends on LLM capability; less common languages may require manual review.
- **Deterministic slug algorithm (ADR-039)**: Produces different filenames for some existing ADRs, causing file renames in git history.
- **Fix both specs and templates (ADR-040)**: Template comments increase file size in the schema layer.
- **Section-completeness rule (ADR-041)**: Agent may still drop sections despite rule change if instruction is not followed precisely.
- **Step 4 enrichment only (ADR-042)**: Other steps are not restructured for full self-containment — if they develop similar subagent issues, a per-step restructure would be needed.
- **Step independence guardrail (ADR-043)**: Advisory guardrail, not programmatically enforced — depends on agent instruction compliance.
- **Init model-invocable (ADR-M001)**: The three-layer-architecture spec no longer distinguishes init from other skills in terms of invocability.

## Conventions

- **Commits:** Imperative present tense with category prefix (e.g., `Refactor: ...`, `Fix: ...`)
- **Post-archive version bump:** After `/opsx:archive`, automatically increment the patch version in `.claude-plugin/plugin.json` and sync `.claude-plugin/marketplace.json`. For minor/major releases, manually set versions, create a git tag, and optionally create a GitHub Release.
- **README accuracy:** When plugin behavior changes, update the README to reflect the new state.
- **Workflow friction:** Capture friction as GitHub Issues with the `friction` label.
- **Design review checkpoint:** After creating specs + design, always pause for user alignment before proceeding to preflight/tasks.
- **No ADR references in specs:** Specs must not reference ADRs — specs exist before ADRs do.

## Capabilities

### Setup

| Capability | Description |
|---|---|
| [Project Setup](capabilities/project-setup.md) | One-time initialization with /opsx:init |
| [Project Bootstrap](capabilities/project-bootstrap.md) | Bootstrap or re-sync when code and specs have drifted |

### Change Workflow

| Capability | Description |
|---|---|
| [Change Workspace](capabilities/change-workspace.md) | Create, structure, and archive change workspaces |
| [Artifact Pipeline](capabilities/artifact-pipeline.md) | Six-stage pipeline with dependency gating |
| [Artifact Generation](capabilities/artifact-generation.md) | Step-by-step and fast-forward artifact creation |
| [Interactive Discovery](capabilities/interactive-discovery.md) | Standalone research with targeted Q&A |

### Development

| Capability | Description |
|---|---|
| [Constitution Management](capabilities/constitution-management.md) | Generate, update, and enforce project-wide rules |
| [Quality Gates](capabilities/quality-gates.md) | Pre-flight checks and post-implementation verification |
| [Task Implementation](capabilities/task-implementation.md) | Work through task checklists with progress tracking |
| [Human Approval Gate](capabilities/human-approval-gate.md) | Mandatory sign-off with fix-verify loop before archiving |

### Finalization

| Capability | Description |
|---|---|
| [Spec Sync](capabilities/spec-sync.md) | Merge delta specs into baseline specs |
| [Release Workflow](capabilities/release-workflow.md) | Version bumps, changelog, and consumer update process |

### Reference

| Capability | Description |
|---|---|
| [Three-Layer Architecture](capabilities/three-layer-architecture.md) | Constitution, Schema, and Skills separation model |
| [Spec Format](capabilities/spec-format.md) | Format rules for specs, scenarios, deltas, and baselines |
| [Roadmap Tracking](capabilities/roadmap-tracking.md) | Track improvements via GitHub Issues with roadmap label |

### Meta

| Capability | Description |
|---|---|
| [User Documentation](capabilities/user-docs.md) | Enriched capability docs from specs and archive data |
| [Architecture Documentation](capabilities/architecture-docs.md) | Consolidated README with architecture overview and ADR index |
| [Decision Documentation](capabilities/decision-docs.md) | Formal ADRs from archived design decisions |
