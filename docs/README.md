# Documentation

## System Architecture

The opsx-enhanced plugin is structured as a three-layer architecture where each layer has distinct responsibilities and can be modified independently.

- **Constitution** (`openspec/constitution.md`) -- defines global project rules including tech stack, architecture rules, code style, constraints, and conventions. The constitution is read before every AI action via `config.yaml` workflow rules, serving as the single authoritative source for project-wide governance.
- **Schema** (`openspec/schemas/opsx-enhanced/`) -- defines a 6-stage artifact pipeline (research, proposal, specs, design, preflight, tasks) with templates, instructions, and dependency ordering. The schema is the single source of truth for pipeline structure and artifact generation. Universal workflow rules live here because they apply to all consumer projects.
- **Skills** (`skills/*/SKILL.md`) -- deliver all 13 commands as SKILL.md files within the Claude Code plugin system. Skills are categorized as workflow (6), governance (5), or documentation (2). Skills are generic shared code and must not be modified for project-specific behavior.

The layers interact through well-defined interfaces: skills depend on the schema via the OpenSpec CLI (not directly), and the constitution is injected into every prompt via `config.yaml`. Modifications to one layer do not require changes to another unless the interface contract between them changes.

## Tech Stack

- **Primary format:** Markdown (artifacts, specs, skills, documentation)
- **Configuration:** YAML (schema.yaml, config.yaml)
- **Shell:** Bash (skill command execution)
- **Core dependency:** OpenSpec CLI (`@fission-ai/openspec@^1.2.0`)
- **Runtime:** Node.js + npm (required for OpenSpec CLI)
- **Platform:** Claude Code plugin system
- **Package manager:** npm (global installs only -- no project-level package.json)

## Key Design Decisions

| Decision | Rationale | ADR |
|----------|-----------|-----|
| 15 capabilities (not one per skill) | Groups related behavior logically -- e.g., continue+ff under artifact-generation | [ADR-001](decisions/adr-001-15-capabilities-not-one-per-skill.md) |
| Use /opsx:sync for baseline creation, not programmatic archive merge | Programmatic merge has format limitations (missing Purpose, header matching issues) | [ADR-002](decisions/adr-002-use-opsxsync-for-baseline-creation-not-programmatic.md) |
| Empty tasks.md (QA loop only) | No code to implement -- this is a documentation bootstrap | [ADR-003](decisions/adr-003-empty-tasksmd-qa-loop-only.md) |
| Schema owns workflow rules | DoD and post-apply sequence apply to ALL projects using opsx-enhanced -- they belong in the shared schema | [ADR-004](decisions/adr-004-schema-owns-workflow-rules.md) |
| Config as bootstrap-only | With rules in schema and project rules in constitution, config just needs to point to the constitution | [ADR-005](decisions/adr-005-config-as-bootstrap-only.md) |
| Remove constitution redundancies | 12 rules duplicated schema instructions/templates; single source of truth prevents drift | [ADR-006](decisions/adr-006-remove-constitution-redundancies.md) |
| Init generates minimal config template | Prevents project-specific rules from leaking into consumer projects | [ADR-007](decisions/adr-007-init-generates-minimal-config-template.md) |
| Convention in constitution, not skill modification | Skills are shared across consumers; project-specific behavior belongs in the constitution | [ADR-008](decisions/adr-008-convention-in-constitution-not-skill-modifica.md) |
| Patch-only auto-bump | 95%+ of changes are patches; minor/major are rare and intentional | [ADR-009](decisions/adr-009-patch-only-auto-bump.md) |
| Sync marketplace.json in same convention | One operation, no drift between plugin.json and marketplace.json versions | [ADR-010](decisions/adr-010-sync-marketplacejson-in-same-convention.md) |
| Docs page for minor/major releases | Rare enough for a manual process; avoids over-engineering a dedicated skill | [ADR-011](decisions/adr-011-docs-page-for-minormajor.md) |
| Split docs-generation into focused capabilities | Each concern (user-docs, architecture-docs, decision-docs) is independently spec'd and testable | [ADR-012](decisions/adr-012-split-docs-generation-into-focused-capabili.md) |
| All doc types in /opsx:docs, no new skills | Single entry point avoids skill proliferation | [ADR-013](decisions/adr-013-all-doc-types-in-opsxdocs-no-new-skills.md) |
| Direct glob per capability instead of pre-built index | Simpler approach with no separate index-building step; archives are few | [ADR-014](decisions/adr-014-direct-glob-per-capability-instead-of-pre-b.md) |
| ADRs fully regenerated each run | Deterministic output, no state to track, numbering always consistent | [ADR-015](decisions/adr-015-adrs-fully-regenerated-each-run.md) |
| Research context integrated into ADR Context section | One place for "why did we decide this?"; avoids a separate research log | [ADR-016](decisions/adr-016-research-context-integrated-into-adr-contex.md) |
| "Why This Exists" uses newest archive's proposal | Most current motivation; older proposals may be superseded | [ADR-017](decisions/adr-017-why-this-exists-uses-newest-archives-propos.md) |
| Initial-spec-only capabilities use spec Purpose | Bootstrap proposal "Why" is about spec creation, not individual capabilities | [ADR-018](decisions/adr-018-initial-spec-only-capabilities-use-spec-pur.md) |
| Constitution convention only (design review checkpoint) | Respects skill immutability; constitution is always loaded and authoritative | [ADR-019](decisions/adr-019-constitution-convention-only.md) |
| Checkpoint after design specifically | Design finalizes approach/architecture -- last point where feedback is cheap before quality gates | [ADR-020](decisions/adr-020-checkpoint-after-design-specifically.md) |
| Skip checkpoint when preflight already done | Avoids unnecessary friction on resume; preflight existence implies prior design review | [ADR-021](decisions/adr-021-skip-checkpoint-when-preflight-already-done.md) |
| Update constitution before spec | Constitution establishes the governance rule; spec formalizes the behavioral change | [ADR-022](decisions/adr-022-update-constitution-before-spec.md) |
| SKILL.md references templates via Read at runtime | Consistent with pipeline artifact templates; format changes don't require prompt edits | [ADR-023](decisions/adr-023-skillmd-references-templates-via-read-at-ru.md) |
| Consolidated README replaces 3 separate files | Eliminates navigation hops; architecture overview IS the entry point | [ADR-024](decisions/adr-024-consolidated-readme-replaces-3-separate-fil.md) |
| Cleanup step in SKILL.md deletes stale files | Automated migration from old 3-file to new 1-file structure; manual deletion is fragile | [ADR-025](decisions/adr-025-cleanup-step-in-skillmd-deletes-stale-files.md) |
| ADR generation runs before README generation | README needs ADR file paths for inline links; reversing order would require a two-pass approach | [ADR-026](decisions/adr-026-adr-generation-runs-before-readme-generatio.md) |
| Ordering and grouping via order and category YAML frontmatter | Project-specific, deterministic, set during spec creation; SKILL.md stays project-independent | [ADR-027](decisions/adr-027-ordering-grouping-via-order-and-category-ya.md) |
| README shortening is a separate implementation task | README is hand-written; changes are independent of auto-generated docs; allows separate review | [ADR-028](decisions/adr-028-readme-shortening-is-a-separate-implementat.md) |

### Notable Trade-offs

- **Schema owns workflow rules / Remove constitution redundancies / Config as bootstrap-only**: Reduced defense-in-depth -- rules now live in one place instead of being duplicated across layers. If the schema fails to inject a rule, there is no constitution backup. Accepted because schema enforcement plus skill guardrails are sufficient.
- **Convention in constitution, not skill modification**: Soft enforcement only -- conventions rely on agent compliance, not hard code enforcement. Mitigated by the constitution being injected into every prompt via config.yaml.
- **Patch-only auto-bump**: Version inflation -- many small patches accumulate over time. Acceptable trade-off versus forgotten bumps causing silent update failures for consumers.
- **Initial-spec-only capabilities use spec Purpose**: These capability docs are noticeably less rich than those with dedicated archives, since they lack proposal motivation, research context, and design trade-offs.
- **Consolidated README replaces 3 separate files**: External links to `docs/architecture-overview.md` and `docs/decisions/README.md` will break, though docs are internal to the repo.
- **"Why This Exists" uses newest archive's proposal**: Historical context from earlier proposals is not directly visible in capability docs, though it is preserved in the archives.

## Conventions

- **Commits:** Imperative present tense with category prefix (e.g., `Refactor: ...`, `Fix: ...`)
- **Post-archive version bump:** After `/opsx:archive` completes, automatically increment the patch version in `.claude-plugin/plugin.json` and sync `marketplace.json` to match. Display the new version in the archive summary with next steps.
- **README accuracy:** When plugin behavior changes, update the README to reflect the new state.
- **Workflow friction:** When workflow execution reveals friction, capture it as a GitHub Issue with the `friction` label. Include: what happened, expected behavior, and suggested fix.
- **Design review checkpoint:** After creating specs and design artifacts, always pause for user alignment before proceeding to preflight/tasks. The design phase is the mandatory review checkpoint in every OpenSpec workflow.

## Capabilities

### Setup

| Capability | Description |
|---|---|
| [Project Setup](capabilities/project-setup.md) | One-time project initialization via /opsx:init |
| [Project Bootstrap](capabilities/project-bootstrap.md) | Initial codebase scanning, constitution generation, and recovery mode |

### Change Workflow

| Capability | Description |
|---|---|
| [Change Workspace](capabilities/change-workspace.md) | Create, manage, and archive change workspaces |
| [Artifact Pipeline](capabilities/artifact-pipeline.md) | Schema-driven 6-stage artifact pipeline with dependency gating |
| [Artifact Generation](capabilities/artifact-generation.md) | Step-by-step and fast-forward artifact generation commands |
| [Interactive Discovery](capabilities/interactive-discovery.md) | Standalone interactive research with targeted Q&A for complex features |

### Development

| Capability | Description |
|---|---|
| [Constitution Management](capabilities/constitution-management.md) | Project constitution lifecycle including generation, updates, and enforcement |
| [Quality Gates](capabilities/quality-gates.md) | Pre-implementation preflight checks and post-implementation verification |
| [Task Implementation](capabilities/task-implementation.md) | Systematic implementation of task checklists with progress tracking |
| [Human Approval Gate](capabilities/human-approval-gate.md) | Mandatory human approval with QA loop, success metrics, and fix-verify cycles |

### Finalization

| Capability | Description |
|---|---|
| [Spec Sync](capabilities/spec-sync.md) | Agent-driven merging of delta specs into baseline specs |
| [Release Workflow](capabilities/release-workflow.md) | Version management, changelog generation, and consumer update guidance |

### Reference

| Capability | Description |
|---|---|
| [Three-Layer Architecture](capabilities/three-layer-architecture.md) | Constitution, Schema, and Skills layers with clear separation of concerns |
| [Spec Format](capabilities/spec-format.md) | Format rules for specifications including normative descriptions, scenarios, and delta operations |
| [Roadmap Tracking](capabilities/roadmap-tracking.md) | Track planned improvements as GitHub Issues with a roadmap label and a single always-current view |

### Meta

| Capability | Description |
|---|---|
| [User Documentation](capabilities/user-docs.md) | Enriched user-facing capability documentation generated from specs and archived artifacts |
| [Architecture Documentation](capabilities/architecture-docs.md) | Cross-cutting architecture overview synthesized from constitution, specs, and design decisions |
| [Decision Records](capabilities/decision-docs.md) | Architecture Decision Records (ADRs) generated from archived design decisions |
