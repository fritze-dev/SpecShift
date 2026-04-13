---
order: 3
category: reference
status: stable
version: 6
lastModified: 2026-04-13
---
## Purpose

Defines the WORKFLOW.md pipeline orchestration contract, Smart Template format, inline action definitions, custom actions, and the router dispatch pattern for pipeline configuration.

## Requirements

### Requirement: WORKFLOW.md Pipeline Orchestration

The system SHALL support an `.specshift/WORKFLOW.md` file as the pipeline orchestration contract. WORKFLOW.md SHALL use markdown-with-YAML-frontmatter format with a clear separation of concerns:

**YAML frontmatter** — structured configuration only:
- `template-version` (integer, for template merge detection during `specshift init`)
- `templates_dir` (path to Smart Templates directory)
- `pipeline` (ordered array of artifact step IDs — each generates a file)
- `actions` (array of action names, e.g., `[init, propose, apply, finalize]` — each has a corresponding `## Action: <name>` body section)
- `worktree` (optional object with `enabled`, `path_pattern`, `auto_cleanup`)
- `auto_approve` (optional boolean, defaults to `true` — when true, the full propose→apply→finalize flow runs end-to-end without checkpoints on success paths; when false, pauses at every checkpoint including design review, preflight, user testing, and cross-action transitions)
- `docs_language` (optional, defaults to English)

**Markdown body** — prose instructions as named sections:
- `## Context` — project-level behavioral context (e.g., constitution reference, language rules)

The `pipeline` array SHALL be the single source of truth for the artifact generation sequence. Frontmatter SHALL NOT contain multi-line prose instructions — these belong in body sections or in action `instruction` fields.

**User Story:** As a plugin maintainer I want a single WORKFLOW.md file for pipeline orchestration and action definitions, so that all workflow configuration lives in one place.

#### Scenario: Router reads WORKFLOW.md for pipeline configuration
- **GIVEN** a project with `.specshift/WORKFLOW.md` containing frontmatter and body sections
- **WHEN** any command is invoked
- **THEN** the router SHALL read frontmatter for `templates_dir`, `pipeline`, and `actions` configuration
- **AND** SHALL read the `## Context` body section for behavioral context

#### Scenario: WORKFLOW.md frontmatter contains required structured fields
- **GIVEN** a valid `.specshift/WORKFLOW.md`
- **WHEN** its frontmatter is inspected
- **THEN** it SHALL contain `templates_dir`, `pipeline`, `actions`, and `template-version` fields
- **AND** SHALL NOT contain multi-line prose instructions in frontmatter

#### Scenario: WORKFLOW.md body contains instruction sections
- **GIVEN** a valid `.specshift/WORKFLOW.md`
- **WHEN** its markdown body is inspected
- **THEN** it SHALL contain `## Context` and `## Action: <name>` sections with prose instructions

### Requirement: Smart Template Format

All template files SHALL use the Smart Template format: markdown with YAML frontmatter containing `id` (artifact identifier), `description` (brief purpose), `generates` (output file path relative to change directory), `requires` (array of dependency artifact IDs), `instruction` (AI behavioral constraints for artifact generation), and `template-version` (integer, monotonically increasing — bumped when the plugin changes the template content). The markdown body SHALL define the output structure for the generated artifact. The `instruction` field content SHALL NOT be copied into generated artifacts — it serves as constraints for the AI during generation. The `template-version` field enables `specshift init` to detect whether a local template has been customized by the user and to merge plugin updates with local customizations instead of overwriting them.

**User Story:** As a developer I want each template to be self-describing with its own instruction and metadata, so that I can understand what a template does without consulting a separate schema file.

#### Scenario: Smart Template contains required frontmatter fields
- **GIVEN** a Smart Template file (e.g., `.specshift/templates/changes/research.md`)
- **WHEN** its YAML frontmatter is inspected
- **THEN** it SHALL contain `id`, `description`, `generates`, `requires`, `instruction`, and `template-version` fields

#### Scenario: Instruction applied as constraints not content
- **GIVEN** a Smart Template with an `instruction` field in its frontmatter
- **WHEN** a skill generates an artifact using this template
- **THEN** the skill SHALL apply the instruction as behavioral constraints
- **AND** SHALL NOT copy the instruction text into the generated artifact file

#### Scenario: Template body defines output structure
- **GIVEN** a Smart Template with markdown headings in its body
- **WHEN** a skill generates an artifact using this template
- **THEN** the generated artifact SHALL follow the section structure defined in the template body

#### Scenario: All templates use Smart Template format
- **GIVEN** the `.specshift/templates/` directory
- **WHEN** all template files are inspected
- **THEN** every template (pipeline artifacts, docs, constitution) SHALL have YAML frontmatter with at minimum `id` and `description` fields

### Requirement: Inline Action Definitions

WORKFLOW.md frontmatter SHALL contain `actions` as an array of action names. The array SHALL include the 4 built-in actions (`init`, `propose`, `apply`, `finalize`) and MAY include additional consumer-defined custom actions (e.g., `actions: [init, propose, apply, qa-review, finalize]`). Each action SHALL have a corresponding `## Action: <name>` section in the WORKFLOW.md markdown body containing only `### Instruction` (procedural guidance for the AI agent). For built-in actions, requirement links (clickable markdown links to specific spec requirements using the format `[Requirement Name](docs/specs/<spec>.md#requirement-<slug>)`) SHALL live in the SKILL.md file as compiler input (annotated with `<!-- AOT-COMPILER-INPUT -->`), NOT in WORKFLOW.md. These links are consumed by the AOT compiler to produce compiled action files — they are NOT resolved at runtime. Custom actions do not have requirement links in SKILL.md — their instruction text in WORKFLOW.md SHALL be self-contained. This structure ensures prose stays out of frontmatter, the sub-agent receives focused context, and requirement wiring is managed at the skill level for built-in actions. Actions are NOT pipeline steps — they do not generate artifacts in the pipeline sequence. Actions are invoked by the router when the user calls the corresponding command.

For built-in actions, the router SHALL read the compiled action file at `actions/<action>.md` (relative to the skill directory), which contains the pre-extracted instruction and requirement blocks. The router SHALL spawn a sub-agent with the instruction text as primary directive and the pre-extracted requirements as behavioral context. For custom actions, the router SHALL read the `### Instruction` from the WORKFLOW.md body section and execute it directly — the executing agent decides whether to handle it inline or spawn a sub-agent based on the instruction content. Custom actions do not receive spec requirement links or compiled files.

The system SHALL provide 4 built-in actions: `init` (project initialization and health check), `propose` (pipeline traversal for artifact generation), `apply` (task implementation with review.md generation), and `finalize` (post-approval changelog, docs, and version-bump). Consumer projects MAY define additional custom actions by adding them to the `actions` array and providing corresponding `## Action: <name>` body sections.

**User Story:** As a consumer project maintainer I want to define custom actions in my WORKFLOW.md alongside the built-in ones, so that I can extend the workflow with project-specific steps without modifying the plugin.

#### Scenario: Action defined as body section with instruction
- **GIVEN** a WORKFLOW.md with a `## Action: apply` body section
- **WHEN** the section is inspected
- **THEN** it SHALL contain `### Instruction` with procedural guidance text
- **AND** it SHALL NOT contain requirement links (those live in the SKILL.md)

#### Scenario: Router executes built-in action via compiled action file
- **GIVEN** a user invokes `specshift apply`
- **WHEN** the router processes the command
- **THEN** it SHALL read the compiled action file at `actions/apply.md` (relative to the skill directory)
- **AND** the compiled file SHALL contain the pre-extracted instruction and requirement blocks
- **AND** the router SHALL spawn a sub-agent with the instruction as primary directive and requirements as behavioral context
- **AND** the sub-agent SHALL NOT receive the router's full conversation history

#### Scenario: Router executes custom action as sub-agent
- **GIVEN** a WORKFLOW.md with `actions: [init, propose, apply, qa-review, finalize]`
- **AND** a `## Action: qa-review` body section with `### Instruction`
- **WHEN** a user invokes `specshift qa-review`
- **THEN** the router SHALL read the `### Instruction` from the `## Action: qa-review` body section
- **AND** SHALL execute the instruction directly (the agent decides whether to handle it inline or spawn a sub-agent)
- **AND** SHALL NOT look for requirement links in the SKILL.md for this action

#### Scenario: Actions are not pipeline steps
- **GIVEN** a WORKFLOW.md with `pipeline: [research, proposal, specs, design, preflight, tasks, review]`
- **AND** `actions: [init, propose, apply, qa-review, finalize]`
- **WHEN** the pipeline is traversed
- **THEN** actions SHALL NOT be included in the pipeline artifact sequence
- **AND** SHALL only be invoked via direct command

### Requirement: Router Dispatch Pattern

The system SHALL provide a single router skill that handles all user-facing commands. The router SHALL validate commands against the `actions` array from WORKFLOW.md frontmatter. If WORKFLOW.md is missing, the router SHALL fall back to the built-in actions: `init`, `propose`, `apply`, `finalize`. The router SHALL implement shared orchestration logic once:
1. **Intent recognition**: Determine which command was invoked and validate it against the `actions` array
2. **Change context detection** (for all actions except `init`): Get current branch via `git rev-parse --abbrev-ref HEAD`, scan `.specshift/changes/*/proposal.md` for a proposal whose `branch` frontmatter field matches, fall back to worktree convention if inside a worktree
3. **WORKFLOW.md loading**: Read frontmatter for `templates_dir`, `pipeline`, and `actions`
4. **Dispatch**: For `propose` — traverse the pipeline, generate artifacts, handle checkpoint/resume. For `apply`/`finalize`/`init` — read compiled action file at `actions/<action>.md`, spawn sub-agent with pre-extracted instruction + requirements. For custom actions — read action definition from WORKFLOW.md, execute instruction directly with change context (no compiled files, agent decides execution mode).

**User Story:** As a developer I want a single entry point that handles built-in and custom actions with shared logic, so that change detection and context loading happen once and consumer projects can extend the workflow.

#### Scenario: Router detects change from branch
- **GIVEN** the user is on branch `my-feature`
- **AND** `.specshift/changes/2026-04-09-my-feature/proposal.md` has `branch: my-feature` in frontmatter
- **WHEN** the user invokes `specshift apply`
- **THEN** the router SHALL auto-detect the change and announce "Detected change context: using change '2026-04-09-my-feature'"

#### Scenario: Router dispatches propose to pipeline traversal
- **GIVEN** the user invokes `specshift propose my-feature`
- **WHEN** the router processes the command
- **THEN** it SHALL create the change workspace if needed
- **AND** SHALL traverse the `pipeline` array, generating artifacts in sequence
- **AND** SHALL support checkpoint/resume (skip completed artifacts)

#### Scenario: Router dispatches apply via compiled action file
- **GIVEN** the user invokes `specshift apply`
- **AND** the compiled action file `actions/apply.md` exists in the skill directory
- **WHEN** the router detects the change and reads the compiled file
- **THEN** it SHALL spawn a sub-agent with the pre-extracted instruction and requirement blocks from the compiled file

#### Scenario: Init runs without change context
- **GIVEN** the user invokes `specshift init`
- **WHEN** the router processes the command
- **THEN** it SHALL skip change context detection
- **AND** SHALL execute the init action directly

#### Scenario: Router dispatches custom action via generic fallback
- **GIVEN** a WORKFLOW.md with `actions: [init, propose, apply, qa-review, finalize]`
- **AND** a `## Action: qa-review` body section with `### Instruction`
- **WHEN** a user invokes `specshift qa-review`
- **THEN** the router SHALL validate `qa-review` against the `actions` array
- **AND** SHALL read the `### Instruction` from the `## Action: qa-review` section
- **AND** SHALL execute the instruction directly (agent decides execution mode)
- **AND** SHALL NOT look for requirement links in SKILL.md

#### Scenario: Router auto-dispatches propose→apply→finalize when auto_approve is true
- **GIVEN** `auto_approve: true` in WORKFLOW.md
- **AND** the user invokes `specshift propose my-feature`
- **WHEN** propose completes successfully (all pipeline artifacts generated)
- **THEN** the router SHALL automatically dispatch apply without pausing
- **AND** when apply completes with review.md verdict PASS, SHALL automatically dispatch finalize
- **AND** SHALL only pause if a FAIL verdict, BLOCKED preflight, or genuine clarification question occurs

#### Scenario: Router pauses at each transition when auto_approve is false
- **GIVEN** `auto_approve: false` in WORKFLOW.md
- **AND** the user invokes `specshift propose my-feature`
- **WHEN** propose completes
- **THEN** the router SHALL stop and suggest `specshift apply`
- **AND** SHALL NOT auto-dispatch subsequent actions

#### Scenario: Router rejects action not in actions array
- **GIVEN** a WORKFLOW.md with `actions: [init, propose, apply, finalize]`
- **WHEN** a user invokes `specshift deploy`
- **THEN** the router SHALL report that `deploy` is not a recognized action
- **AND** SHALL list the available actions from the `actions` array

### Requirement: Compiled Action File Contract

The `.claude/skills/specshift/` directory SHALL serve as the self-contained release artifact. It is built by the compiler from `src/` source files and compiled spec extracts, and SHALL contain: the router (`SKILL.md`, copied from `src/skills/specshift/`), templates (copied from `src/templates/`), and compiled action files. Each built-in action (propose, apply, finalize, init) SHALL have a corresponding compiled action file at `.claude/skills/specshift/actions/<action>.md`. The compiled file SHALL use markdown-with-YAML-frontmatter format containing:

**YAML frontmatter**:
- `compiled-at` (ISO 8601 timestamp of compilation)
- `specshift-version` (version string from `src/.claude-plugin/plugin.json`)
- `sources` (array of spec file paths that contributed requirement blocks)

**Markdown body**:
- `## Instruction` — the action's procedural instruction text, extracted from `.specshift/WORKFLOW.md` `## Action: <name> ### Instruction`
- `## Requirements` — concatenated requirement blocks, each as `### Requirement: <Name>` with description, optional user story, and Gherkin scenarios

Compiled action files are generated artifacts produced by the AOT compiler (`scripts/compile-skills.sh` or the finalize compilation step). They SHALL NOT be hand-edited. The requirement link lists in SKILL.md (annotated with `<!-- AOT-COMPILER-INPUT -->`) serve as the compilation manifest — they define which requirements belong to which action.

**User Story:** As a plugin consumer I want pre-compiled action files shipped with the plugin, so that the router loads focused context from a single file instead of resolving links against spec files I don't have.

#### Scenario: Compiled action file contains instruction and requirements

- **GIVEN** a compiled action file `.claude/skills/specshift/actions/propose.md`
- **WHEN** its content is inspected
- **THEN** it SHALL contain YAML frontmatter with `compiled-at`, `specshift-version`, and `sources`
- **AND** SHALL contain `## Instruction` with the propose action's instruction text
- **AND** SHALL contain `## Requirements` with one `### Requirement:` block per linked requirement

#### Scenario: Router reads compiled file instead of resolving links

- **GIVEN** a user invokes `specshift apply` in a consumer project without `docs/specs/` files
- **AND** the compiled action file `actions/apply.md` exists in the skill directory
- **WHEN** the router loads the action context
- **THEN** it SHALL read the compiled file for instruction and requirements
- **AND** SHALL NOT attempt to read `docs/specs/` files

#### Scenario: Compiled file missing triggers hard error

- **GIVEN** the compiled action file `actions/apply.md` does not exist
- **WHEN** the router attempts to load the action context for a built-in action
- **THEN** it SHALL abort with an error message: "Compiled action file missing. Run `bash scripts/compile-skills.sh` to generate it."
- **AND** SHALL NOT attempt JIT resolution as a fallback

### Requirement: Dev Sync Utility

The project SHALL provide a standalone bash script at `scripts/compile-skills.sh` that performs the same AOT compilation as the finalize step. The script SHALL be runnable from the repository root without requiring the full finalize pipeline. The script SHALL:

1. Read requirement link sections from `src/skills/specshift/SKILL.md` (between `<!-- AOT-COMPILER-INPUT -->` markers)
2. For each built-in action, extract the requirement links, resolve them against `docs/specs/` files, and read the action instruction from `.specshift/WORKFLOW.md`
3. Copy `src/skills/specshift/SKILL.md` → `.claude/skills/specshift/SKILL.md` and `src/templates/` → `.claude/skills/specshift/templates/`
4. Write compiled action files to `.claude/skills/specshift/actions/`
5. Print a summary: number of actions compiled, total requirements extracted, any warnings

The script SHALL use only bash and standard POSIX utilities (awk, sed, grep) — no external runtime dependencies (no Node.js, Python, etc.). This constraint matches the project's tech stack (Markdown, YAML, Bash).

**User Story:** As a plugin developer I want a quick script to recompile action files after editing specs, so that I can test changes locally without running the full finalize pipeline.

#### Scenario: Dev script compiles all built-in actions

- **GIVEN** the developer runs `bash scripts/compile-skills.sh` from the repository root
- **WHEN** the script completes
- **THEN** it SHALL have written 4 compiled action files (propose.md, apply.md, finalize.md, init.md) to `.claude/skills/specshift/actions/`
- **AND** SHALL print a summary of actions compiled and requirements extracted

#### Scenario: Dev script uses no external runtimes

- **GIVEN** a developer machine with bash but without Node.js or Python installed
- **WHEN** the developer runs `bash scripts/compile-skills.sh`
- **THEN** the script SHALL complete successfully using only bash and POSIX utilities

## Edge Cases

- **WORKFLOW.md missing**: Router SHALL report an error and suggest running `specshift init`.
- **Smart Template missing frontmatter**: Router SHALL treat the file as a plain template (no instruction, no metadata) and report a warning.
- **Smart Template missing template-version field**: Init SHALL treat the template as version 0 (always eligible for update).
- **WORKFLOW.md with malformed YAML**: Router SHALL report a parse error and stop.
- **Empty `pipeline` array**: Router SHALL report that no artifacts are defined and stop.
- **`templates_dir` points to nonexistent directory**: Router SHALL report the missing directory and suggest running `specshift init`.
- **Unknown action referenced**: If an action name does not match any entry in the `actions` array from WORKFLOW.md frontmatter, the router SHALL report the error and list available actions.
- **Action with missing spec**: If a spec listed in the SKILL.md's requirement links does not exist at the referenced path, the sub-agent SHALL proceed without it and note the missing spec.
- **Custom action without body section**: If a custom action is listed in the `actions` array but has no corresponding `## Action: <name>` body section in WORKFLOW.md, the router SHALL report the missing instruction and stop.
- **Custom action with init skip**: Custom actions SHALL go through change context detection (like apply/finalize), not skip it like init. If a custom action does not need change context, the instruction text should handle that.
- **Compiled action file missing**: If a compiled action file does not exist for a built-in action, the router SHALL abort with a hard error directing the user to run `bash scripts/compile-skills.sh`. No JIT fallback — since consumers lack `docs/specs/`, a fallback would fail anyway.
- **Compiled file has no requirements section**: If a compiled file contains only the instruction (no requirements), the router SHALL proceed with the instruction only — this is valid for actions with no requirement links.
- **Dev script run outside repo root**: The script SHALL detect that it is not in the repo root (no `src/skills/specshift/SKILL.md` found) and exit with an error message.

## Assumptions

- Claude natively parses YAML frontmatter from markdown files when instructed to read and interpret them. <!-- ASSUMPTION: Claude YAML frontmatter parsing -->
- The Agent tool is available in the execution environment and supports spawning sub-agents with custom prompts and bounded context. <!-- ASSUMPTION: Agent tool availability -->
- Sub-agents spawned via the Agent tool can read and write files in the same working directory as the router. <!-- ASSUMPTION: Sub-agent file access -->
- Compiled action files are kept in sync with specs via the finalize compilation step and/or the dev sync script. Stale compiled files are a developer responsibility between finalize runs. <!-- ASSUMPTION: Compiled file freshness -->
