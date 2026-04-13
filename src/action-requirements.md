# Action Requirements Manifest

Compiler input for `scripts/compile-skills.sh`. Maps built-in actions to their spec requirements.
Each link is resolved by the compiler to extract the `### Requirement:` block from the target spec file.

## Action: propose — Requirements

- [Propose as Single Entry Point for Pipeline Traversal](docs/specs/artifact-pipeline.md#requirement-propose-as-single-entry-point-for-pipeline-traversal)
- [Eight-Stage Pipeline](docs/specs/artifact-pipeline.md#requirement-eight-stage-pipeline)
- [Artifact Dependencies](docs/specs/artifact-pipeline.md#requirement-artifact-dependencies)
- [Post-Artifact Commit and PR Integration](docs/specs/artifact-pipeline.md#requirement-post-artifact-commit-and-pr-integration)
- [Create Change Workspace](docs/specs/change-workspace.md#requirement-create-change-workspace)
- [Create Worktree-Based Workspace](docs/specs/change-workspace.md#requirement-create-worktree-based-workspace)
- [Lazy Worktree Cleanup at Change Creation](docs/specs/change-workspace.md#requirement-lazy-worktree-cleanup-at-change-creation)
- [Change Context Detection](docs/specs/change-workspace.md#requirement-change-context-detection)

## Action: apply — Requirements

- [Implement Tasks from Task List](docs/specs/task-implementation.md#requirement-implement-tasks-from-task-list)
- [Progress Tracking](docs/specs/task-implementation.md#requirement-progress-tracking)
- [Standard Tasks Exclusion from Apply Scope](docs/specs/task-implementation.md#requirement-standard-tasks-exclusion-from-apply-scope)
- [Spec Edits During Implementation](docs/specs/task-implementation.md#requirement-spec-edits-during-implementation)
- [Apply Gate](docs/specs/artifact-pipeline.md#requirement-apply-gate)
- [Post-Implementation Commit Before Approval](docs/specs/artifact-pipeline.md#requirement-post-implementation-commit-before-approval)
- [Post-Implementation Verification](docs/specs/quality-gates.md#requirement-post-implementation-verification)
- [QA Loop with Mandatory Approval](docs/specs/human-approval-gate.md#requirement-qa-loop-with-mandatory-approval)
- [Fix Loop](docs/specs/human-approval-gate.md#requirement-fix-loop)
- [Active vs Completed Change Detection](docs/specs/change-workspace.md#requirement-active-vs-completed-change-detection)

## Action: finalize — Requirements

- [Generate Changelog from Completed Changes](docs/specs/release-workflow.md#requirement-generate-changelog-from-completed-changes)
- [Completion Workflow Next Steps](docs/specs/release-workflow.md#requirement-completion-workflow-next-steps)
- [Auto Patch Version Bump](docs/specs/release-workflow.md#requirement-auto-patch-version-bump)
- [Version Sync Between Plugin Files](docs/specs/release-workflow.md#requirement-version-sync-between-plugin-files)
- [Generate Enriched Capability Documentation](docs/specs/documentation.md#requirement-generate-enriched-capability-documentation)
- [Incremental Capability Documentation Generation](docs/specs/documentation.md#requirement-incremental-capability-documentation-generation)
- [Generate Architecture Overview](docs/specs/documentation.md#requirement-generate-architecture-overview)
- [Generate Documentation Table of Contents](docs/specs/documentation.md#requirement-generate-documentation-table-of-contents)
- [ADR Generation from Change Decisions](docs/specs/documentation.md#requirement-adr-generation-from-change-decisions)
- [Post-Merge Worktree Cleanup](docs/specs/change-workspace.md#requirement-post-merge-worktree-cleanup)

## Action: init — Requirements

- [Install Workflow](docs/specs/project-init.md#requirement-install-workflow)
- [Template Merge on Re-Init](docs/specs/project-init.md#requirement-template-merge-on-re-init)
- [First-Run Codebase Scan](docs/specs/project-init.md#requirement-first-run-codebase-scan)
- [Constitution Generation](docs/specs/project-init.md#requirement-constitution-generation)
- [Documentation Drift Verification](docs/specs/project-init.md#requirement-documentation-drift-verification-health-check)
- [Recovery Mode](docs/specs/project-init.md#requirement-recovery-mode-spec-drift-detection)
- [Constitution Update](docs/specs/constitution-management.md#requirement-constitution-update)
- [Preflight Quality Check](docs/specs/quality-gates.md#requirement-preflight-quality-check)
