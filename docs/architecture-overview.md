# Architecture Overview

## System Architecture

The opsx-enhanced plugin uses a **three-layer architecture** that separates concerns and allows each layer to be modified independently.

### Constitution (Global Rules)

The constitution (`openspec/constitution.md`) defines project-wide rules that govern all AI behavior. It includes Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. Every skill reads the constitution before performing any work, ensuring consistency across all actions.

### Schema (Artifact Pipeline)

The schema (`openspec/schemas/opsx-enhanced/`) defines a 6-stage artifact pipeline: research, proposal, specs, design, preflight, and tasks. Each artifact has a template, instruction, and dependency list. The schema is the single source of truth for pipeline structure and artifact generation rules. An apply phase gates implementation behind task completion.

### Skills (User Commands)

All 13 commands are delivered as `skills/*/SKILL.md` files within the Claude Code plugin system:

- **Workflow** (6): new, continue, ff, apply, verify, archive
- **Governance** (5): init, bootstrap, discover, preflight, sync
- **Documentation** (2): changelog, docs

Skills depend on the schema via the OpenSpec CLI — they do not embed pipeline logic directly. All skills are model-invocable except `init`, which is user-only (one-time setup).

### Layer Separation

The three layers are independently modifiable. The schema does not embed skill logic; skills depend on the schema via CLI. The constitution does not contain schema-specific artifact definitions. Modifications to one layer do not require changes to another layer unless the interface contract between them changes.

## Tech Stack

- **Primary format:** Markdown (artifacts, specs, skills, documentation)
- **Configuration:** YAML (schema.yaml, config.yaml)
- **Shell:** Bash (skill command execution)
- **Core dependency:** OpenSpec CLI (`@fission-ai/openspec@^1.2.0`)
- **Runtime:** Node.js + npm (required for OpenSpec CLI)
- **Platform:** Claude Code plugin system
- **Package manager:** npm (global installs only — no project-level package.json)

## Key Design Decisions

| Decision | Rationale | Source |
|----------|-----------|--------|
| 15 capabilities grouped logically (not one per skill) | Groups related behavior — e.g., continue+ff under artifact-generation | initial-spec |
| Agent-driven `/opsx:sync` for baseline creation | Programmatic merge has format limitations (missing Purpose, header matching issues) | initial-spec |
| Schema owns universal workflow rules (DoD, post-apply sequence) | These apply to ALL projects using opsx-enhanced — they belong in the shared schema | fix-workflow-friction |
| Config.yaml as bootstrap-only (schema ref + constitution pointer) | With rules in schema and project rules in constitution, config just needs to point | fix-workflow-friction |
| Constitution free of schema redundancies | Single source of truth prevents drift and reduces maintenance burden | fix-workflow-friction |
| Init generates minimal config template (not a copy) | Prevents project-specific rules from leaking into consumer projects | fix-workflow-friction |
| `docs-generation` split into `user-docs`, `architecture-docs`, `decision-docs` | Each concern is independently spec'd and testable; changelog fits under `release-workflow` | doc-ecosystem |
| All doc types in `/opsx:docs`, no new skills | Single entry point, avoids skill proliferation | doc-ecosystem |
| ADRs fully regenerated each run | Deterministic, no state to track, numbering always consistent | doc-ecosystem |
| Research context integrated into ADR Context section | One place for "why did we decide this?" — avoids separate research log | doc-ecosystem |
| Convention in constitution for auto-bump, not skill modification | Skills are shared across consumers; project-specific behavior in constitution | release-workflow |
| Patch-only auto-bump on archive | 95%+ of changes are patches; minor/major are rare and intentional | release-workflow |
| Constitution convention only for design review checkpoint | Respects skill immutability; constitution is always loaded and authoritative | design-review-checkpoint |
| Checkpoint after design specifically | Design finalizes approach/architecture — last point where feedback is cheap before quality gates | design-review-checkpoint |
| Skip checkpoint when preflight already done | Avoids unnecessary friction on resume; preflight existence implies prior design review | design-review-checkpoint |
| Update constitution before spec | Constitution establishes the governance rule; spec formalizes the behavioral change | design-review-checkpoint |

## Conventions

- **Commits:** Imperative present tense with category prefix (e.g., `Refactor: ...`, `Fix: ...`)
- **Post-archive version bump:** After `/opsx:archive`, automatically increment patch version in `plugin.json` and sync `marketplace.json`. Display the new version in the archive summary with next steps.
- **README accuracy:** When plugin behavior changes, update the README to reflect the new state.
- **Workflow friction:** When workflow execution reveals friction, capture it as a GitHub Issue with the `friction` label. Include: what happened, expected behavior, and suggested fix.
- **Design review checkpoint:** After creating specs + design artifacts, always pause for user alignment before proceeding to preflight/tasks. The design phase is the mandatory review checkpoint in every OpenSpec workflow.
