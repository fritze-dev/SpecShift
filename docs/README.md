# Documentation

## System Architecture

SpecShift uses a three-layer architecture where each layer has distinct responsibilities and can be modified independently:

1. **Constitution Layer** (`.specshift/CONSTITUTION.md`): Global project rules — Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. All AI actions read the constitution before performing any work.
2. **Schema Layer** (`.specshift/WORKFLOW.md` + `.specshift/templates/`): Declarative pipeline orchestration via YAML frontmatter and Smart Templates. Defines the 8-stage artifact pipeline (research, proposal, specs, design, preflight, tests, tasks, audit), action instructions, and artifact generation rules.
3. **Router + Actions Layer** (`.claude/skills/specshift/`): A single router SKILL.md dispatches to 5 built-in actions (init, propose, apply, finalize, review) plus consumer-defined custom actions. Built-in actions read compiled requirements from AOT-extracted action files.

## Tech Stack

- **Primary format**: Markdown (artifacts, specs, skills, documentation)
- **Configuration**: YAML (WORKFLOW.md frontmatter, Smart Template frontmatter)
- **Shell**: Bash (skill command execution)
- **Platform**: Claude Code plugin system

## Key Design Decisions

| Decision | Rationale | ADR |
|----------|-----------|-----|
| Restructure as SpecShift with `.specshift/`, `docs/`, `CLAUDE.md` pillars | Clean project root, flat spec files, no symlinks | [ADR-M001](decisions/adr-M001-specshift-v1-architecture.md) |
| Three-tier fix loop classification (Tweak / Design Pivot / Scope Change) | Agents need mechanically checkable criteria; subjective judgment failed in PR #12 | [ADR-001](decisions/adr-001-tiered-re-entry-classification-for-fix-loop.md) |
| Detection signals as observable facts for tier classification | Reduces subjectivity; agents can check signals mechanically before choosing tier | [ADR-001](decisions/adr-001-tiered-re-entry-classification-for-fix-loop.md) |
| Update apply instruction rather than adding a new action | Fix loop is part of apply; a new action would fragment UX | [ADR-001](decisions/adr-001-tiered-re-entry-classification-for-fix-loop.md) |
| Changelog version headers with orphan consolidation | Enables version-to-entry mapping; orphan entries belong under the release that includes them | [ADR-002](decisions/adr-002-changelog-version-header-format.md) |

### Notable Trade-offs

- **Tiered fix loop classification**: Tier boundary ambiguity remains possible in edge cases — mitigated by defaulting to the higher tier, which errs toward clean artifacts at the cost of occasionally over-classifying a Tweak as a Design Pivot.
- **SpecShift restructure**: All historical ADRs and changes deleted from working tree (preserved in git history). Consumers must reinstall under the new plugin name.
- **Changelog reformatting**: Large diff in blame history (purely cosmetic). release.yml sed pipeline has additional transformation steps for heading promotion.

## Conventions

- **Commits**: Imperative present tense with category prefix (e.g., `Fix: ...`, `Refactor: ...`)
- **Post-apply version bump**: Auto-increment patch version in `src/.claude-plugin/plugin.json`, sync to `.claude-plugin/marketplace.json`
- **Plugin source layout**: Source in `src/`, release in `.claude/skills/specshift/` (built via `bash scripts/compile-skills.sh`)
- **AOT compilation**: After editing specs, run `bash scripts/compile-skills.sh` to regenerate the release directory
- **Template synchronization**: `src/templates/` is authoritative; `.specshift/` is synced from it
- **Tool-agnostic instructions**: Describe intent, not specific CLI tools
- **Knowledge transparency**: Project knowledge lives in version-controlled artifacts, not opaque memory files
- **Review comment acknowledgment**: Reply to each PR review comment after fixing, resolve committed threads

## Capabilities

### Setup

| Capability | Description |
|---|---|
| [Project Init](capabilities/project-init.md) | One-command project setup with template merge and health checks |

### Change Workflow

| Capability | Description |
|---|---|
| [Change Workspace](capabilities/change-workspace.md) | Workspace creation, worktree isolation, and change lifecycle |
| [Artifact Pipeline](capabilities/artifact-pipeline.md) | 8-stage pipeline with dependency gating and PR integration |

### Development

| Capability | Description |
|---|---|
| [Constitution Management](capabilities/constitution-management.md) | Constitution lifecycle, codebase observation, and global context |
| [Quality Gates](capabilities/quality-gates.md) | Preflight checks, audit.md verification, and docs drift detection |
| [Task Implementation](capabilities/task-implementation.md) | Sequential task execution with progress tracking |
| [Test Generation](capabilities/test-generation.md) | Automated test stubs and manual test plans from Gherkin scenarios |
| [Human Approval Gate](capabilities/human-approval-gate.md) | QA loop with tiered fix-verify cycles and mandatory approval |

### Finalization

| Capability | Description |
|---|---|
| [Review Lifecycle](capabilities/review-lifecycle.md) | Re-entrant PR review-to-merge state machine with comment processing, summary posting, and mandatory merge confirmation |
| [Release Workflow](capabilities/release-workflow.md) | Version management, automated releases, and plugin distribution |

### Documentation

| Capability | Description |
|---|---|
| [Documentation](capabilities/documentation.md) | Capability docs, ADRs, and README from specs and changes |

### Reference

| Capability | Description |
|---|---|
| [Workflow Contract](capabilities/workflow-contract.md) | WORKFLOW.md pipeline, Smart Templates, and action dispatch |
| [Three-Layer Architecture](capabilities/three-layer-architecture.md) | Constitution, Schema, and Router layers |
| [Spec Format](capabilities/spec-format.md) | Spec format rules, Gherkin scenarios, and frontmatter metadata |
| [Roadmap Tracking](capabilities/roadmap-tracking.md) | GitHub Issues with roadmap label for planned improvements |
