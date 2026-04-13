# Research: AOT Prompt Compilation for Action Skills

## 1. Current State

The `specshift` router skill (`src/skills/specshift/SKILL.md`) uses a JIT (Just-in-Time) approach to assemble LLM context for each action. In Step 4, the router:

1. Reads `## Action: <name>` instruction from `.specshift/WORKFLOW.md`
2. Parses requirement anchor links listed per action (lines 46-93 in SKILL.md), e.g.:
   ```
   - [Eight-Stage Pipeline](docs/specs/artifact-pipeline.md#requirement-eight-stage-pipeline)
   ```
3. For each link, reads the full spec file from `docs/specs/` and extracts the `### Requirement: <Name>` block (description + user story + Gherkin scenarios)
4. Concatenates extracted blocks into a bounded context for the implementing agent

**Affected architecture layer**: Layer 3 (Router). The three-layer architecture (Constitution → Workflow+Templates → Router) remains intact — only the router's context-loading mechanism changes.

**Key files**:
- `src/skills/specshift/SKILL.md` — router with requirement link mappings (lines 46-93)
- `.specshift/WORKFLOW.md` — action instructions (`## Action: <name> ### Instruction`)
- `docs/specs/*.md` — 14 spec files, source of truth for requirements
- `src/.claude-plugin/plugin.json` — plugin manifest (v0.1.1-beta)

**Current requirement link counts**:
- propose: 8 requirements from 2 spec files
- apply: 10 requirements from 4 spec files
- finalize: 10 requirements from 3 spec files
- init: 8 requirements from 3 spec files

## 2. External Research

No external dependencies. The compilation is a pure markdown extraction + assembly task. The approach mirrors common "prompt baking" patterns in LLM frameworks where dynamic prompt templates are pre-rendered for production use.

The Claude Code plugin system loads skills from `src/skills/<name>/SKILL.md`. Additional files in the skill directory (e.g., `actions/propose.md`) can be referenced by the skill via relative paths.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| 1. **Status Quo (JIT)** | Single source of truth, no build step, specs always fresh | Token bloat (~60% overhead from loading full spec files), consumers need `docs/specs/` (currently not shipped via `source: "./src"`), multiple file reads per action |
| 2. **AOT Compilation in finalize** | Focused context (~280 vs ~695 lines for propose), clean distribution (only `src/` shipped), single file read per action, provenance tracking via frontmatter | Requires compile step after spec edits, compiled files can go stale during dev, adds ~4 generated files to `src/` |
| 3. **Full skill split (4 standalone skills)** | Each skill completely self-contained, no router needed | Breaks `specshift <action>` UX, duplicates ~40 lines shared logic (context detection, WORKFLOW.md loading), breaks consumer registration |

## 4. Risks & Constraints

- **Stale compilation**: If specs are edited without recompiling, runtime skills use outdated requirements. Mitigation: finalize always recompiles; dev script for local iteration; init health check could detect staleness.
- **Bash extraction reliability**: Markdown heading extraction via bash/awk is fragile. Mitigation: specs use a very consistent format (`### Requirement: <Name>` blocks); compiler validates output is non-empty.
- **Backwards compatibility**: Consumers have the current router. Migration is zero-breaking: same `specshift` skill name, same `specshift <action>` UX. Compiled action files are new additions under the skill directory.
- **Router immutability principle**: CONSTITUTION.md states SKILL.md must not be modified per-project. AOT changes the router behavior generically (all consumers benefit), not per-project. Compiled action files are generated artifacts, not hand-written overrides.
- **Custom actions**: Custom actions (defined in WORKFLOW.md) have no spec requirements — they remain JIT. The router must handle the split: built-in actions use compiled files, custom actions read WORKFLOW.md directly.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Compile step in finalize, router reads compiled files, dev script for local iteration |
| Behavior | Clear | Extraction algorithm well-defined (parse links → read spec → extract block → assemble) |
| Data Model | Clear | Compiled files are markdown with YAML frontmatter (compiled-at, sources, version) |
| UX | Clear | No consumer-facing UX change — same `specshift <action>` commands |
| Integration | Clear | Fits into existing finalize pipeline; dev script is standalone bash |
| Edge Cases | Clear | Stale compilation, unresolved links, empty blocks, custom actions |
| Constraints | Clear | Must stay bash-only (no Node/Python deps), must not break consumer installations |
| Terminology | Clear | AOT compilation, compiled action files, compilation manifest |
| Non-Functional | Clear | ~60% token reduction per action, single file read instead of multi-file resolution |

## 6. Open Questions

All categories are Clear. No open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Approach 2: AOT Compilation in finalize | Token savings (~60%), clean distribution, minimal dev friction, zero breaking changes | Approach 1 (status quo), Approach 3 (full skill split) |
| 2 | Hybrid: thin router + compiled action files | Preserves shared logic (Steps 1-3), keeps `specshift` skill name, avoids duplicating ~40 lines | Full standalone skills per action |
| 3 | Requirement links stay in SKILL.md as compiler input | Single source of truth for which requirements belong to which action; annotated with compiler marker | Separate requirements.md manifest file |
| 4 | Custom actions remain JIT | Custom actions have no spec requirements; no benefit from compilation | Force-compile custom action instructions |
