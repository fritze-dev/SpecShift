---
template-version: 1
---
# Project Constitution

## Tech Stack

- **Primary format:** Markdown (artifacts, specs, skills, documentation)
- **Configuration:** YAML (WORKFLOW.md frontmatter, Smart Template frontmatter), JSON (per-target plugin manifests and marketplaces)
- **Shell:** Bash (skill command execution, AOT compile script)
- **Build dependencies:** `jq` (in-place per-target manifest version stamping)
- **Targets:** Claude Code plugin system + OpenAI Codex CLI plugin system (multi-target distribution)

## Testing

- **Framework:** None (plugin is Markdown/YAML artifacts, no executable tests)
- **Validation:** Gherkin scenarios verified via audit.md during apply

## Architecture Rules

- **Three-layer architecture:** CONSTITUTION.md (global rules) → WORKFLOW.md + Smart Templates (artifact pipeline + inline actions) → Router (single workflow skill with 5 built-in actions (init, propose, apply, finalize, review) + consumer-defined custom actions)
- Layers are independently modifiable — WORKFLOW.md and Smart Templates do not embed router logic, the router depends on them via direct file reads
- **Router immutability:** The workflow skill (`skills/specshift/SKILL.md`) is generic plugin code shared across all consumers. It MUST NOT be modified for project-specific behavior. Project-specific workflows and conventions MUST be defined in this constitution.
- **Per-target manifests and marketplace catalogs at the repo root:** `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, and `.agents/plugins/marketplace.json` are hand-edited at the repository root. The first three carry per-target metadata plus a `version` field stamped from `src/VERSION` by the compile script. The Codex marketplace catalog `.agents/plugins/marketplace.json` carries pure metadata (`name`, `interface.displayName`, `plugins[].source` Git-URL, `plugins[].policy`, `plugins[].category`) without a `version` field — it is reviewed manually for parity. Codex consumers install via `codex plugin marketplace add owner/repo` (per `developers.openai.com/codex/plugins/build`) and then install or enable the plugin from the in-session `/plugins` directory; updates use `codex plugin marketplace upgrade <name>`. Codex resolves the plugin via the catalog's declared Git-URL source.
- Pipeline source of truth: `.specshift/WORKFLOW.md` (orchestration + actions) + `.specshift/templates/` (Smart Templates)
- Specs: `docs/specs/<capability>.md` (one file per capability, edited directly during specs stage)
- Changes: `.specshift/changes/YYYY-MM-DD-<feature>/` (date-prefixed at creation, contains planning artifacts + audit.md)
- **Release directory:** `./skills/specshift/` is the generated, shared release artifact (SKILL.md, templates, compiled action files) consumed by both Claude Code and Codex via their respective root manifests. It is committed to Git and MUST NOT be hand-edited — regenerate via `bash scripts/compile-skills.sh`.

## Code Style

- **YAML:** 2-space indentation, `|` for multiline strings
- **Review markers:** `<!-- REVIEW -->` — transient markers for items needing user confirmation. Skills that write REVIEW markers (bootstrap, docs) must auto-resolve them: iterate each marker, ask the user, document the decision, and remove the marker. No REVIEW markers should persist in final output.

## Constraints

- Specs use `## Purpose` + `## Requirements` — edited directly during the specs stage, no delta format

## Conventions

- **Commits:** Imperative present tense with category prefix (e.g., `Refactor: ...`, `Fix: ...`)
- **Post-apply version bump:** During the post-apply workflow, automatically increment the patch version in `src/VERSION` (e.g., `1.0.3` → `1.0.4`). `src/VERSION` is the single agnostic version source of truth — plain text, single line, SemVer. The compile script propagates the new value into the three root manifest/marketplace files (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`) via `jq`, preserving all non-version fields and values (JSON formatting may be normalized by `jq`), and cross-checks each post-stamp; any mismatch fails the build. Display the new version. A GitHub Action automatically creates a git tag and GitHub Release when `src/VERSION` changes on `main`. For intentional minor/major releases, manually edit `src/VERSION`, run `bash scripts/compile-skills.sh`, and push.
- **Plugin source layout:** Plugin source code lives in `src/` (`src/VERSION`, `src/skills/`, `src/templates/`, `src/actions/`). Per-target manifests and the Claude marketplace are hand-edited at the repository root (`.claude-plugin/`, `.codex-plugin/`), not under `src/`. The shared release directory at `./skills/specshift/` is built from `src/` via `bash scripts/compile-skills.sh` and contains the compiled skill, templates, and pre-extracted action files. Project files (docs, CI, specs, changelog) stay at the repo root. The Claude marketplace uses `source: "./"`; the Codex manifest declares `skills: "./skills/"`.
- **Template-version discipline:** When any file under `src/templates/` is modified, its `template-version` integer in the YAML frontmatter MUST be incremented. The compilation step (`bash scripts/compile-skills.sh`) enforces this by comparing modified templates against `main` — compilation fails if the version was not bumped. Consumer projects running `specshift init` rely on `template-version` to detect template updates and trigger merge prompts.
- **AOT compilation:** After editing specs, `src/VERSION`, or any per-target root manifest/marketplace, run `bash scripts/compile-skills.sh` to regenerate the shared release tree at `./skills/specshift/` and stamp `src/VERSION` into all three root manifest/marketplace files. The finalize action runs this automatically.
- **Local development:** Developers register the local repo as marketplace via the host's marketplace-add command (Claude: `claude plugin marketplace add <local-path> --scope user`; Codex: `codex plugin marketplace add ./<local-marketplace-root>` per the documented local-path form at `developers.openai.com/codex/plugins/build`, then install or enable from the in-session `/plugins` directory). Skill changes reload via the host's plugin-reload command. Version changes require running the host's plugin-update command (Claude) or `codex plugin marketplace upgrade specshift` (Codex). After the layout migration to multi-target distribution, existing local marketplaces also need a one-time `marketplace update` to pick up the new `source: "./"` and shared skill tree path.
- **README accuracy:** When plugin behavior changes (skills, WORKFLOW.md, templates, constitution, architecture), update the README to reflect the new state. The README is the primary user-facing documentation and must stay consistent with the implementation.
- **Workflow friction:** When workflow execution reveals friction, capture it as a GitHub Issue with the `friction` label. Include: what happened, expected behavior, and suggested fix.
- **Knowledge transparency:** Project knowledge (architecture decisions, conventions, design rationale, workflow patterns) MUST live in version-controlled artifacts — constitution for rules, specs for requirements, ADRs for decisions, GitHub Issues for friction/bugs. Internal auto-memory files are opaque and non-shareable; project knowledge MUST NOT be stored there.
- **No ADR references in specs:** Specs MUST NOT reference ADRs (e.g., "see ADR-019"). ADRs are generated after implementation — specs exist before ADRs do. Specs describe requirements; ADRs document the decisions that shaped them.
- **Template synchronization:** `src/templates/workflow.md` is the authoritative plugin source for workflow behavior. Changes to workflow actions, pipeline, and instruction text should be made in `src/templates/workflow.md` first, then synced to `.specshift/WORKFLOW.md`. Skill-reference phrasing may intentionally differ between plugin template and project instance where a project-specific override is documented (e.g., `review.request_review: copilot` in this project's WORKFLOW.md vs `false` in the consumer template).
- **Agent instructions:** Project-level agent instructions live in `AGENTS.md` (the agnostic source of truth, read by Codex natively and by Claude Code via the `@AGENTS.md` import expanded from `CLAUDE.md`). `CLAUDE.md` is a one-line `@AGENTS.md` import stub; do not duplicate normative rules into it. Instructions use tool-agnostic language.
- **Tool-agnostic instructions:** Specs, skills, and templates MUST describe intent (e.g., "create a draft PR") rather than hardcoding specific CLI tools (e.g., `gh pr create`). The plugin runs across environments with different tooling. Concrete tool names may appear in parenthetical examples but MUST NOT be the sole instruction. **Compiled-into-skill files** (specs that `src/actions/*.md` link into) MUST stay tool-agnostic in a stronger sense: prose like "the plugin's `templates/` directory" instead of `${CLAUDE_PLUGIN_ROOT}`; product names only where the surrounding paragraph is target-scoped (e.g., describing Claude Code's `@AGENTS.md` memory-import behavior).
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
