# Documentation

## Architecture

- [Architecture Overview](architecture-overview.md)

## Capabilities

| Capability | Description |
|---|---|
| [Project Setup](capabilities/project-setup.md) | One-time project initialization with CLI installation, schema setup, and validation |
| [Project Bootstrap](capabilities/project-bootstrap.md) | Scan your codebase to generate a constitution and initial change, or detect drift in recovery mode |
| [Artifact Pipeline](capabilities/artifact-pipeline.md) | Schema-driven 6-stage artifact pipeline with strict dependency gating |
| [Artifact Generation](capabilities/artifact-generation.md) | Step-by-step and fast-forward commands for generating pipeline artifacts |
| [Change Workspace](capabilities/change-workspace.md) | Create, structure, and archive change workspaces for the spec-driven workflow |
| [Constitution Management](capabilities/constitution-management.md) | Project constitution lifecycle: generation, global enforcement, updates, and deduplication |
| [Quality Gates](capabilities/quality-gates.md) | Pre-implementation preflight checks and post-implementation verification |
| [Interactive Discovery](capabilities/interactive-discovery.md) | Standalone research phase with targeted Q&A for complex features |
| [Roadmap Tracking](capabilities/roadmap-tracking.md) | Track planned improvements as GitHub Issues with a roadmap label and a single always-current view |
| [Human Approval Gate](capabilities/human-approval-gate.md) | Mandatory human approval with QA loop, success metrics, and fix-verify cycles before archiving |
| [Task Implementation](capabilities/task-implementation.md) | Systematic task execution with progress tracking and pause-on-blocker behavior |
| [Spec Sync](capabilities/spec-sync.md) | Intelligent agent-driven merging of delta specs into baselines with partial update support |
| [Three-Layer Architecture](capabilities/three-layer-architecture.md) | Constitution, Schema, and Skills — three independently modifiable layers that structure the plugin |
| [Spec Format](capabilities/spec-format.md) | Format rules for specifications including normative descriptions, User Stories, Gherkin scenarios, and delta operations |
| [User Docs](capabilities/user-docs.md) | Enriched user-facing capability documentation with archive-derived context sections |
| [Architecture Docs](capabilities/architecture-docs.md) | Cross-cutting architecture overview document from constitution, specs, and design decisions |
| [Decision Docs](capabilities/decision-docs.md) | Architecture Decision Records generated from archived design.md Decisions tables |
| [Release Workflow](capabilities/release-workflow.md) | Automatic patch version bumps on archive, version sync, manual release process, and consumer update guidance |

## Decisions

- [Architecture Decision Records](decisions/README.md)
