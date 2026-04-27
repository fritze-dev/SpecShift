---
template-version: 1
---
# Project Constitution

## Tech Stack

- **Primary format:** Markdown (artifacts, specs, skills, documentation)
- **Configuration:** YAML (WORKFLOW.md frontmatter, Smart Template frontmatter)
- **Shell:** Bash (skill command execution)
- **Platform:** Claude Code plugin system

## Testing

- **Framework:** None (plugin is Markdown/YAML artifacts, no executable tests)
- **Validation:** Gherkin scenarios verified via audit.md during apply

## Architecture Rules

- **Three-layer architecture:** CONSTITUTION.md (global rules) → WORKFLOW.md + Smart Templates (artifact pipeline + inline actions) → Router (single workflow skill with 5 built-in actions (init, propose, apply, finalize, review) + consumer-defined custom actions)
- Layers are independently modifiable — WORKFLOW.md and Smart Templates do not embed router logic, the router depends on them via direct file reads
- **Router immutability:** The workflow skill (`skills/specshift/SKILL.md`) is generic plugin code shared across all consumers. They MUST NOT be modified for project-specific behavior. Project-specific workflows and conventions MUST be defined in this constitution.
- Plugin manifests live in `.claude-plugin/` (plugin.json, marketplace.json) and `.codex-plugin/` (plugin.json) at the repo root, both compiled from sources under `src/.claude-plugin/` and `src/.codex-plugin/`. The Codex marketplace entry lives at `.agents/plugins/marketplace.json`.
- Pipeline source of truth: `.specshift/WORKFLOW.md` (orchestration + actions) + `.specshift/templates/` (Smart Templates)
- Specs: `docs/specs/<capability>.md` (one file per capability, edited directly during specs stage)
- Changes: `.specshift/changes/YYYY-MM-DD-<feature>/` (date-prefixed at creation, contains planning artifacts + audit.md)
- **Release directory:** `./skills/specshift/` is the generated release artifact (SKILL.md, templates, compiled action files), shared by all distribution targets. It is committed to Git and MUST NOT be hand-edited — regenerate via `bash scripts/compile-skills.sh`.

## Code Style

- **YAML:** 2-space indentation, `|` for multiline strings
- **Review markers:** `<!-- REVIEW -->` — transient markers for items needing user confirmation. Skills that write REVIEW markers (bootstrap, docs) must auto-resolve them: iterate each marker, ask the user, document the decision, and remove the marker. No REVIEW markers should persist in final output.

## Constraints

- Specs use `## Purpose` + `## Requirements` — edited directly during the specs stage, no delta format

## Conventions

- **Commits:** Imperative present tense with category prefix (e.g., `Refactor: ...`, `Fix: ...`)
- **Post-apply version bump:** During the post-apply workflow, automatically increment the patch version in `src/.claude-plugin/plugin.json` (e.g., `1.0.3` → `1.0.4`) and sync the `version` field in `.claude-plugin/marketplace.json` to match. If versions are out of sync, use `src/.claude-plugin/plugin.json` as the source of truth — the compile script stamps this version into the Codex manifest (`.codex-plugin/plugin.json`) and the Codex marketplace (`.agents/plugins/marketplace.json`) automatically, so they do not need manual edits. Display the new version. A GitHub Action automatically creates a git tag and GitHub Release when the version change is pushed to `main`. For intentional minor/major releases, manually set the version in `src/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` and push — the Action handles tagging and release creation.
- **Plugin source layout:** Plugin source code lives in `src/` (skills, templates, plugin manifests under `src/.claude-plugin/` and `src/.codex-plugin/`, Codex marketplace template under `src/marketplace/codex.json`). The shared release directory at `./skills/specshift/` is built from `src/` via `bash scripts/compile-skills.sh` and contains the compiled skill, templates, and pre-extracted action files. Both target manifests (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`) and the Codex marketplace (`.agents/plugins/marketplace.json`) are compiled to the repo root. Project files (docs, CI, specs, changelog) stay at the repo root. The Claude `marketplace.json` uses `source: "./"`.
- **Template-version discipline:** When any file under `src/templates/` is modified, its `template-version` integer in the YAML frontmatter MUST be incremented. The compilation step (`bash scripts/compile-skills.sh`) enforces this by comparing modified templates against `main` — compilation fails if the version was not bumped. Consumer projects running `specshift init` rely on `template-version` to detect template updates and trigger merge prompts.
- **AOT compilation:** After editing specs, run `bash scripts/compile-skills.sh` to regenerate the release directory. The finalize action runs this automatically.
- **Local development:** Developers register the local repo as marketplace via `claude plugin marketplace add <local-path> --scope user`. Skill changes reload via `/reload-plugins`. Version changes require `claude plugin update specshift@specshift`.
- **README accuracy:** When plugin behavior changes (skills, WORKFLOW.md, templates, constitution, architecture), update the README to reflect the new state. The README is the primary user-facing documentation and must stay consistent with the implementation.
- **Workflow friction:** When workflow execution reveals friction, capture it as a GitHub Issue with the `friction` label. Include: what happened, expected behavior, and suggested fix.
- **Knowledge transparency:** Project knowledge (architecture decisions, conventions, design rationale, workflow patterns) MUST live in version-controlled artifacts — constitution for rules, specs for requirements, ADRs for decisions, GitHub Issues for friction/bugs. Internal auto-memory files are opaque and non-shareable; project knowledge MUST NOT be stored there.
- **No ADR references in specs:** Specs MUST NOT reference ADRs (e.g., "see ADR-019"). ADRs are generated after implementation — specs exist before ADRs do. Specs describe requirements; ADRs document the decisions that shaped them.
- **Template synchronization:** `src/templates/workflow.md` is the authoritative plugin source for workflow behavior. Changes to workflow actions, pipeline, and instruction text should be made in `src/templates/workflow.md` first, then synced to `.specshift/WORKFLOW.md`. The `worktree` config and skill reference phrasing may intentionally differ between plugin template and project instance (e.g., `enabled: true` in project, commented out in consumer).
- **Agent instructions:** Project-level agent instructions live in `AGENTS.md` (single source of truth, read by Codex natively and by Claude Code via the `@AGENTS.md` import in `CLAUDE.md`). `CLAUDE.md` is a minimal stub containing only the import directive plus optional Claude-specific overrides. Instructions use tool-agnostic language.
- **Tool-agnostic instructions:** Specs, skills, and templates MUST describe intent (e.g., "create a draft PR") rather than hardcoding specific CLI tools (e.g., `gh pr create`). The plugin runs across environments with different tooling — Claude Code Web (MCP tools), desktop (gh CLI), or API-only. Concrete tool names may appear in parenthetical examples (e.g., "available GitHub tooling (gh CLI, MCP tools, or API)") but MUST NOT be the sole instruction.
- **Review comment acknowledgment:** After pushing fixes that address PR review comments, reply to each comment explaining the action taken (fixed, declined with reason, or not applicable) and resolve threads where the fix is committed. This applies to both human and automated reviewer comments.

## Standard Tasks

<!-- Project-specific extras appended to the universal standard tasks in the schema template.
     These items are added after the universal steps (changelog, docs, version bump, push) in every tasks.md.
     Pre-merge tasks are executed during post-apply workflow.
     Post-merge tasks are reminders — executed manually after the PR is merged. -->

### Pre-Merge
- [ ] Update PR: mark ready for review, update body with change summary and issue references if applicable (e.g., `Closes #X`)
- [ ] Reply to and resolve all PR review comments (fixed/declined with reason/not applicable)

### Post-Merge
- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`) — applies when change modifies files under `src/` or `.claude/skills/`
