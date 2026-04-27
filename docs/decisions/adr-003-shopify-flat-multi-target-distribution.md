# ADR-003: Shopify-flat multi-target distribution with agnostic version SoT

**Status:** Accepted (2026-04-27)

## Context

SpecShift was distributed only as a Claude Code plugin, with `src/.claude-plugin/plugin.json` doubling as both Claude per-target metadata and the repository's version source of truth, and the compiled skill tree at `.claude/skills/specshift/` referenced by `marketplace.json` via `source: "./.claude"`. OpenAI Codex CLI introduced a comparable plugin model (`.codex-plugin/plugin.json`, skill folder discovery, marketplace at `.agents/plugins/marketplace.json`, install via `codex /plugins`), and the SpecShift skill body was already tool-portable (SKILL.md frontmatter is Codex-compatible, prose is largely tool-agnostic). The Shopify-AI-Toolkit (https://github.com/Shopify/Shopify-AI-Toolkit) demonstrated a clean working precedent for multi-target distribution from a single repository: side-by-side per-target manifest dirs and a shared `skills/` tree at the repo root.

Three problems shaped the decision space:

1. **Reach**: SpecShift content is portable; adding Codex doubles the addressable user base for a packaging-only effort.
2. **Symmetry**: With Codex added, the "Claude manifest is also the version SoT" arrangement becomes asymmetric — Codex's version comes from "somewhere else" rather than from a shared agnostic source.
3. **Bootstrap duplication**: Codex reads `AGENTS.md` natively; Claude Code reads `CLAUDE.md`. Maintaining identical bootstrap content in two templates produces drift over time.

## Decision

1. **Adopt the Shopify-flat layout.** Compiled skill tree moves to `./skills/specshift/` at the repo root. Both per-target manifests live hand-edited at the root: `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`. The Claude marketplace at `.claude-plugin/marketplace.json` declares `source: "./"`. Codex consumers install via `codex plugin marketplace add github:fritze-dev/specshift` which auto-discovers `.codex-plugin/plugin.json` — no `.agents/plugins/marketplace.json` catalog file is shipped (the documented Codex single-plugin auto-discovery path; see the "Codex marketplace catalog file not shipped" alternative below). The `src/.claude-plugin/` source-indirection layer is removed entirely — manifests are not built from source, they are authored at the root and only their `version` field is touched by automation.

2. **Introduce `src/VERSION` as the single agnostic version source of truth.** Plain text, single line, SemVer (validated against the SemVer 2.0 regex by the compile script). The compile script reads it and stamps the value into the three root manifest/marketplace files (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`) via `jq`, preserving all non-version fields and values semantically (JSON formatting may be normalized by `jq`'s pretty-printer; consumers depend on semantic content, not byte-level formatting). After stamping, the script re-reads each file and verifies the stamped value equals `src/VERSION`; any mismatch fails the build with an error naming the offending file. The same cross-check is also enforced in CI (`.github/workflows/release.yml`) before tag creation, so a maintainer who edits `src/VERSION` and pushes without recompiling is caught at push time. The `specshift finalize` version-bump step now edits only `src/VERSION`.

3. **Bootstrap content lives once in `AGENTS.md`.** The plugin maintains `src/templates/agents.md` (full body) and `src/templates/claude.md` (one-line `@AGENTS.md` import stub). On fresh `specshift init`, both files are generated unconditionally. Codex reads `AGENTS.md` natively at session start; Claude Code reads `CLAUDE.md` and expands the documented `@AGENTS.md` memory-import. The stub is a pointer, not a content duplicate — single source of truth is preserved.

4. **One shared, tool-agnostic compiled skill tree.** No per-target SKILL variants, no token-substitution rewrite passes. Skill body avoids `${CLAUDE_PLUGIN_ROOT}` and other runtime-specific environment variables; product names appear only where the surrounding paragraph is target-scoped. Worktree path patterns avoid hardcoded `.claude/worktrees/...` strings — the default is `.specshift/worktrees/{change}` (project-configurable).

5. **`jq` becomes a hard build dependency.** The compile script preflights `command -v jq` and fails with a descriptive error if missing. Reliable structured version stamping in JSON requires `jq`; falling back to `sed`/`awk` would be brittle (regex-based JSON editing is error-prone for nested or quoted strings) and could accidentally corrupt or mis-edit the manifests.

## Alternatives Considered

- **Additive sibling layout** (`.codex-plugin/` next to unchanged `.claude/`): no migration of Claude distribution, but the Codex manifest would reference `.claude/skills/`, which is semantically crooked and an unusual layout for a Codex consumer.
- **Two parallel release directories** (`.claude/` + `.codex/`): clear separation but doubles disk usage and creates two build outputs to keep in sync.
- **Single `AGENTS.md` (no `CLAUDE.md`)**: maximally consolidated but breaks existing Claude installs that expect `CLAUDE.md` and forces consumers to manually wire the import; Claude Code does not read `AGENTS.md` natively.
- **Two parallel bootstrap templates with identical body** (`agents.md` + `claude.md` both full): detection clarity, but duplicate maintenance — workflow rules need updating in two places, leading to code rot.
- **Keep version SoT in the Claude manifest**: no new file, but the Claude per-target manifest carries dual responsibility ("Claude metadata" plus "repo version SoT"), and Codex reads its version *from* the Claude file — asymmetric and fragile.
- **Embed version in a language-native manifest** (`package.json`, `pyproject.toml`): only useful if a language manifest already exists; SpecShift is Markdown/YAML/Bash, no language manifest applies.
- **Derive version from git tags at build time**: cleaner for CI-driven projects but adds indirection for an explicit `propose → finalize` workflow; the maintainer wants a single small edit, not a tag-then-derive pipeline.
- **Root-level `./VERSION`** (instead of `src/VERSION`): consumer-visible classic convention, but conflicts with the `src/` ownership rule (`src/` = plugin source; root = compiled output and per-target metadata). The SoT is internal — consumers read the version from the marketplace entry.
- **Stamp only the manifests, trust hand-edits on marketplaces**: the prior arrangement; the Claude marketplace's `version` was previously hand-edited and unchecked, and the codex-plugin-support precursor's CHANGELOG reveals it had drifted between iterations. Symmetric stamping eliminates this class of bug.
- **Ship a `.agents/plugins/marketplace.json` catalog file**: an earlier iteration of this PR added the file, but Shopify-AI-Toolkit (the canonical multi-target reference) does not ship one, and the documented Codex CLI behavior states that `codex plugin marketplace add github:owner/repo` auto-discovers a single-plugin repo's `.codex-plugin/plugin.json` directly without requiring the catalog file. The catalog format is also schema-distinct from the Claude marketplace format we initially patterned it after (`name` + `interface.displayName` instead of `owner.name` + `metadata.description`; `plugins[].source` as `{source: "local", path}` object instead of bare string; `plugins[].policy.installation`/`authentication`; no `plugins[].version` field). Shipping a wrong-schema file is worse than not shipping one. **Decision: do not ship `.agents/plugins/marketplace.json`.** If a future change introduces multiple plugins from this repo or needs to control installation policy, add the file at that time using the official schema.

## Consequences

### Positive

- **Doubled reach**: SpecShift now ships to both Claude Code and Codex CLI consumers from one repository.
- **Symmetric versioning**: All three root manifest/marketplace files always agree on the plugin version; the compile-time cross-check makes drift impossible at build time, and the CI cross-check catches the "pushed VERSION without recompile" foot-gun before a tag is ever created.
- **Single bootstrap source**: workflow rules and other agent directives are authored once in `AGENTS.md`; the `CLAUDE.md` stub is a pointer.
- **Future targets are cheap**: adding Cursor or Gemini requires a new manifest and marketplace entry, not a per-target rewrite of the skill body.
- **Cleaner separation of source and per-target metadata**: `src/` holds plugin source (incl. version SoT); root holds per-target manifests/marketplaces and compiled output. No `src/` indirection for hand-edited per-target files.
- **The version-bump UX is now a single small edit** to `src/VERSION` — no jq invocation needed by the maintainer.

### Negative

- **BREAKING for existing Claude Code consumers**: `marketplace.json` `source` changed from `./.claude` to `./`, and the compiled skill moved from `.claude/skills/specshift/` to `./skills/specshift/`. Mitigation: one-step `claude plugin marketplace update specshift && claude plugin update specshift@specshift`. Documented in CHANGELOG and README.
- **`jq` is now a hard build requirement**: compile script preflights and fails fast if absent. Documented in spec edge case and CONSTITUTION Tech Stack.
- **Codex CLI plugin schema is still maturing**: future schema changes (new required `interface` fields, marketplace location changes) may require compile-script updates. Mitigation: jq-stamping preserves all non-version fields verbatim, so additive schema changes Just Work.
- **Manifest non-version fields are not enforced for parity across targets**: hand-edited descriptions, keywords, etc. may drift between `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`. This is a maintainer-review concern, not a compile-time error.
- **Live install verification on a real Codex installation deferred**: spec scenarios cover the install flow but execution against an actual `codex /plugins` install will be a follow-up step.

## References

- [Change: 2026-04-27-multi-target-distribution](../../.specshift/changes/2026-04-27-multi-target-distribution/)
- [Spec: multi-target-distribution](../../docs/specs/multi-target-distribution.md)
- [Spec: project-init](../../docs/specs/project-init.md)
- [Spec: release-workflow](../../docs/specs/release-workflow.md)
- [Shopify-AI-Toolkit](https://github.com/Shopify/Shopify-AI-Toolkit) — multi-target reference layout
- Codex CLI plugin docs: https://developers.openai.com/codex
- Claude Code memory-import / `@AGENTS.md`: https://code.claude.com/docs/de/memory#agents-md
