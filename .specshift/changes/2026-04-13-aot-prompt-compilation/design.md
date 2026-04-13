---
has_decisions: true
---
# Technical Design: AOT Prompt Compilation for Action Skills

## Context

The router skill (`src/skills/specshift/SKILL.md`) currently resolves requirement anchor links at runtime by reading full spec files from `docs/specs/`. This JIT approach works but causes token overhead (~60% wasted context), prevents clean distribution (consumers don't have `docs/specs/`), and adds runtime latency. The change introduces an AOT compilation step that pre-extracts requirement blocks into per-action markdown files during finalize.

Affected layers: Layer 3 (Router dispatch in SKILL.md) and the finalize pipeline (Layer 2 instruction). The three-layer separation is preserved — the router remains generic, compilation is automated.

## Architecture & Components

### Compilation Flow

```
src/skills/specshift/SKILL.md ───┐
  (source + requirement links)   │
                                 │
src/templates/ ──────────────────┤
  (source templates)             │
                                 ├──→ scripts/compile-skills.sh ──→ .claude/skills/specshift/
docs/specs/*.md ─────────────────┤                                    ├── SKILL.md (copied)
  (requirement blocks)           │                                    ├── templates/ (copied)
                                 │                                    └── actions/
.specshift/WORKFLOW.md ──────────┘                                        ├── propose.md (compiled)
  (action instructions)                                                   ├── apply.md (compiled)
                                                                          ├── finalize.md (compiled)
                                                                          └── init.md (compiled)
```

**`src/`** = authoritative source (hand-edited). **`.claude/skills/specshift/`** = release artifact (generated). Claude Code auto-discovers the skill from `.claude/skills/`.

### Files Modified

| File | Change |
|------|--------|
| `src/skills/specshift/SKILL.md` | Step 4: read compiled files from `actions/` subdirectory instead of resolving links. Annotate link sections with `<!-- AOT-COMPILER-INPUT -->`. Update Step 5 dispatch language. |
| `.specshift/WORKFLOW.md` | Add compile step to finalize instruction (step 4). |
| `src/templates/workflow.md` | Same finalize instruction update. |
| `.specshift/CONSTITUTION.md` | Add architecture rule for release directory and compiled files; add dev convention for compile script. |
| `CLAUDE.md` | Add file ownership note for `.claude/skills/specshift/` as generated release directory. |
| `.claude-plugin/marketplace.json` | Update `source` to point to `.claude/skills/specshift` instead of `./src`. |

### Files Created

| File | Purpose |
|------|---------|
| `scripts/compile-skills.sh` | Standalone compilation script (~100-150 lines bash). Copies source + compiles actions. |
| `.claude/skills/specshift/SKILL.md` | Copied from `src/skills/specshift/SKILL.md` |
| `.claude/skills/specshift/templates/` | Copied from `src/templates/` |
| `.claude/skills/specshift/actions/propose.md` | Compiled: instruction + 8 requirement blocks |
| `.claude/skills/specshift/actions/apply.md` | Compiled: instruction + 10 requirement blocks |
| `.claude/skills/specshift/actions/finalize.md` | Compiled: instruction + 10 requirement blocks |
| `.claude/skills/specshift/actions/init.md` | Compiled: instruction + 8 requirement blocks |

### Compiler Algorithm (compile-skills.sh)

1. **Copy source files**: Copy `src/skills/specshift/SKILL.md` → `.claude/skills/specshift/SKILL.md`. Copy `src/templates/` → `.claude/skills/specshift/templates/`. This creates the release directory structure.
2. **Parse SKILL.md**: Extract text between `<!-- AOT-COMPILER-INPUT -->` and `<!-- /AOT-COMPILER-INPUT -->` markers for each `### Action: <name> — Requirements` section. Parse each markdown link to get (requirement_name, spec_file_path).
3. **Extract requirement blocks**: For each link, read the spec file, find the `### Requirement: <Name>` heading (match by link display text), extract everything until the next `### ` or `## ` heading.
4. **Read instructions**: For each action, read `.specshift/WORKFLOW.md`, extract `## Action: <name> ### Instruction` content.
5. **Read version**: Parse `version` from `src/.claude-plugin/plugin.json`.
6. **Assemble + write**: Generate each `.claude/skills/specshift/actions/<action>.md` with frontmatter + instruction + requirements.
7. **Report**: Print summary (actions compiled, requirements per action, warnings).

### Router Change (SKILL.md Step 4)

Before:
```
Read the target spec file and extract the referenced requirement section
```

After:
```
For built-in actions: read actions/<action>.md (compiled action file).
For custom actions: read ## Action: <name> instruction from WORKFLOW.md directly.
```

Fallback: If compiled file is missing, fall back to JIT resolution (read WORKFLOW.md + resolve links). Log a warning.

## Goals & Success Metrics

- **Token reduction**: Compiled propose action file < 300 lines (vs ~695 lines loaded by JIT). PASS/FAIL by line count comparison.
- **Self-contained release**: `.claude/skills/specshift/` contains everything needed at runtime (SKILL.md, templates, compiled actions). No `docs/specs/` access needed. PASS/FAIL by running propose in a project that only has `.claude/skills/specshift/`.
- **Compilation correctness**: Running `bash scripts/compile-skills.sh` produces 4 non-empty action files. Each file contains all linked requirements (count matches link count in SKILL.md). PASS/FAIL by count comparison.
- **Backwards compatibility**: Existing `specshift <action>` commands work identically after the change. No consumer action required. PASS/FAIL by running propose/apply/finalize cycle.

## Non-Goals

- Changing the markdown spec format itself
- Modifying Smart Template format or behavior
- Changing the `specshift <action>` CLI UX
- Compiling custom action instructions (they remain JIT)
- Adding a CI check for stale compiled files (future enhancement)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Hybrid: thin router + compiled action files | Preserves ~40 lines shared logic (Steps 1-3), keeps `specshift` skill registration, zero breaking change | Full standalone skills per action (breaks UX, duplicates logic) |
| Requirement links stay in SKILL.md as compiler input | Single source of truth for action-requirement mapping; no new files | Separate `requirements.md` manifest (extra file to maintain) |
| Bash-only compiler script | Matches tech stack (no runtime deps), specs use consistent format | Python/Node script (adds dependency, overkill for markdown extraction) |
| `<!-- AOT-COMPILER-INPUT -->` markers in SKILL.md | Clear boundary between runtime instructions and compiler input; parseable by script | YAML frontmatter in SKILL.md (SKILL.md doesn't have structured frontmatter for this), separate manifest file |
| Fallback to JIT if compiled file missing | Graceful degradation during development and for edge cases | Hard error if compiled file missing (too strict for dev workflow) |
| Custom actions remain JIT | No spec requirements to compile; instruction text is self-contained in WORKFLOW.md | Compile custom action instructions too (no benefit, adds complexity) |
| Release directory in `.claude/skills/specshift/` | Claude Code auto-discovers the skill; no plugin install needed; self-contained (SKILL.md + templates + compiled actions) | Keep output in `src/` (requires plugin install, no auto-discovery) |

## Risks & Trade-offs

- **Stale compiled files during development** → Mitigation: dev sync script (`scripts/compile-skills.sh`); finalize always recompiles; constitution convention reminds developers to run script after spec edits.
- **Bash markdown parsing fragility** → Mitigation: specs follow a very consistent format (`### Requirement:` blocks); compiler validates non-empty output; warnings on parse failures.
- **Two compilation entry points** (script + finalize) → Mitigation: finalize instruction delegates to the same script; single implementation.
- **Increased file count in `.claude/`** (SKILL.md + templates + 4 compiled files) → Acceptable trade-off for token savings, auto-discovery, and self-contained distribution.

## Open Questions

No open questions.

## Assumptions

- Spec files maintain the current consistent heading format (`### Requirement: <Name>` followed by content until next `### ` or `## `). <!-- ASSUMPTION: Consistent spec heading format -->
- The `scripts/` directory is an acceptable location for developer utilities in this project. <!-- ASSUMPTION: Scripts directory convention -->
