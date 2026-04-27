# ADR-003: Shopify-Flat Layout for Multi-Target Distribution

## Status

Accepted (2026-04-27)

## Context

SpecShift originally distributed only as a Claude Code plugin. The Claude marketplace consumed `./.claude/` as the plugin source root, with the compiled skill tree at `.claude/skills/specshift/` and the manifest under `.claude/.claude-plugin/plugin.json`. Adding a second target (OpenAI Codex CLI, which has its own plugin manifest schema, marketplace file format, and skill discovery rules) raised three structural questions: where does the Codex manifest live, where does the shared skill body live, and how do the two manifests stay in sync on version. The Shopify-AI-Toolkit (Shopify/Shopify-AI-Toolkit) was the only verified working multi-target plugin reference at the time of the decision — it places `.claude-plugin/`, `.codex-plugin/`, `.cursor-plugin/`, and other manifest dirs side-by-side at the repo root, with a single shared `skills/` tree consumed by every target unchanged. Codex's own plugin documentation expects manifests under `.codex-plugin/plugin.json` and a `skills` field pointing to the shared tree, which lines up exactly with the Shopify pattern. Investigated alternatives included keeping `./.claude/` as the Claude plugin root and putting Codex artifacts in a sibling `.codex/` (semantic asymmetry, manifest path looks odd) and producing two parallel release directories (disk duplication, drift risk). Existing Claude consumers needed to keep working through a single `claude plugin marketplace update` rather than a manual reinstall.

## Decision

1. **Adopt the Shopify-flat layout** — move the compiled skill tree from `.claude/skills/specshift/` to `./skills/specshift/` at the repo root, and place both target manifests (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`) side-by-side at the repo root — because this matches the only verified working multi-target reference and gives every target a symmetric path to the same skill body without duplication.

2. **Designate `src/.claude-plugin/plugin.json` as the version source of truth** — the compile script reads the version from this file and stamps it into every other generated manifest and marketplace entry — because a single source field cannot disagree with itself, eliminating any chance of releasing inconsistent versions across targets.

3. **Use a bootstrap single source of truth pattern** — `src/templates/agents.md` carries the full body of agent directives, `src/templates/claude.md` is reduced to a `@AGENTS.md` import stub — because Claude Code's documented memory system expands `@AGENTS.md` imports at session start, so both Claude Code and Codex (which reads AGENTS.md natively) load the same workflow rules from one authored file.

4. **Generate both bootstrap files unconditionally** in `specshift init` rather than detecting the environment — because CLAUDE.md is a one-line stub that cannot drift, so writing both unconditionally is simpler than detection logic and safer against false negatives.

## Alternatives Considered

- **Additive sibling layout** — keep `.claude/skills/specshift/` as the Claude plugin root and add `.codex-plugin/plugin.json` next to it pointing back to `.claude/skills/`. Rejected because the Codex manifest's `skills` field would reference a `.claude`-prefixed directory, which is semantically misleading and not the pattern documented in any Codex example.
- **Two release directories** — produce parallel outputs at `.claude/skills/` and `.codex/skills/` (or `skills/`), each consumed by its own target. Rejected because it duplicates compiled artifacts on disk for no benefit; both targets accept the same skill body unchanged.
- **Two parallel bootstrap templates with identical bodies** — keep `claude.md` with full content and add `agents.md` with the same content. Rejected because workflow-rule updates (such as the recent `enforce-plan-workflow-routing` change) would have to be applied twice, creating code-rot risk and an obvious maintenance tax.
- **Eliminate CLAUDE.md entirely; use only AGENTS.md** — simpler, but Claude Code does not natively read AGENTS.md and would lose all workflow rules on existing installs. Rejected as breaking.
- **Environment detection in `specshift init`** — detect Codex vs Claude environment and write only the matching file. Rejected because the detection signals (`$CODEX_HOME`, `~/.codex/`, etc.) are fragile, mixed environments are common, and the trade-off (one extra one-line file in the project) is trivial.

## Consequences

### Positive

- Adding a third target (Cursor, Gemini, etc.) requires only a new manifest file plus a marketplace entry — the skill body and bootstrap content are reused unchanged.
- Workflow rule updates touch one file and propagate automatically to every supported AI tool.
- Plugin versions across all target manifests are guaranteed consistent because they all derive from the same source field at compile time.
- The release directory location is target-agnostic; the project's mental model becomes "one plugin, multiple manifests" instead of "one plugin per tool".
- Existing Claude consumers continue working with a standard `claude plugin marketplace update specshift` — no manual reinstall.

### Negative

- The Claude marketplace source path moves from `./.claude` to `./`, which requires existing installs to refresh once. The refresh is automatic via the documented update flow, but until they run it, those installs continue resolving the old path until the marketplace cache is invalidated.
- The Codex CLI plugin schema is still relatively young; if upstream introduces breaking schema changes, the compile script and manifest source will need updating. This risk is captured in the spec's assumptions and addressed by keeping all Codex-specific surface in two small files (`src/.codex-plugin/plugin.json`, `src/marketplace/codex.json`).
- Codex hooks are not auto-installable from a plugin (they live in user `~/.codex/config.toml`), so the workflow-routing rule on Codex relies on the AGENTS.md text rule rather than a hard PreToolUse block. Users wanting hard enforcement must add the snippet manually.
- The legacy `.claude/skills/` directory is removed during this change; if a downstream consumer had pinned imports or scripts to that path, they break. The constitutional rule about release directory location is updated accordingly to surface the change.

## References

- [Spec: multi-target-distribution](../../docs/specs/multi-target-distribution.md)
- [Spec: project-init](../../docs/specs/project-init.md)
- [Change: 2026-04-27-codex-plugin-support](../../.specshift/changes/2026-04-27-codex-plugin-support/)
