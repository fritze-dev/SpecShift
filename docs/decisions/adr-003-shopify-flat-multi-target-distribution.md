# ADR-003: Shopify-flat multi-target distribution with agnostic version SoT

**Status:** Accepted (2026-04-27); amended 2026-04-28 with Decision 6 (ship Codex marketplace catalog with Git-URL source).

## Context

SpecShift was distributed only as a Claude Code plugin, with `src/.claude-plugin/plugin.json` doubling as both Claude per-target metadata and the repository's version source of truth, and the compiled skill tree at `.claude/skills/specshift/` referenced by `marketplace.json` via `source: "./.claude"`. OpenAI Codex CLI introduced a comparable plugin model (`.codex-plugin/plugin.json`, skill folder discovery, marketplace at `.agents/plugins/marketplace.json`, install via `codex /plugins`), and the SpecShift skill body was already tool-portable (SKILL.md frontmatter is Codex-compatible, prose is largely tool-agnostic). The Shopify-AI-Toolkit (https://github.com/Shopify/Shopify-AI-Toolkit) demonstrated a clean working precedent for multi-target distribution from a single repository: side-by-side per-target manifest dirs and a shared `skills/` tree at the repo root.

Three problems shaped the decision space:

1. **Reach**: SpecShift content is portable; adding Codex doubles the addressable user base for a packaging-only effort.
2. **Symmetry**: With Codex added, the "Claude manifest is also the version SoT" arrangement becomes asymmetric — Codex's version comes from "somewhere else" rather than from a shared agnostic source.
3. **Bootstrap duplication**: Codex reads `AGENTS.md` natively; Claude Code reads `CLAUDE.md`. Maintaining identical bootstrap content in two templates produces drift over time.

## Decision

1. **Adopt the Shopify-flat layout.** Compiled skill tree moves to `./skills/specshift/` at the repo root. Both per-target manifests live hand-edited at the root: `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`. The Claude marketplace at `.claude-plugin/marketplace.json` declares `source: "./"`. Codex consumers install via `codex plugin marketplace add github:fritze-dev/specshift` followed by `codex plugin install specshift`; Codex resolves the plugin via the marketplace catalog at `.agents/plugins/marketplace.json` (see Decision 6 below — the prior "no catalog file shipped" framing was falsified against a live Codex install). The `src/.claude-plugin/` source-indirection layer is removed entirely — manifests are not built from source, they are authored at the root and only their `version` field is touched by automation.

2. **Introduce `src/VERSION` as the single agnostic version source of truth.** Plain text, single line, SemVer (validated against the SemVer 2.0 regex by the compile script). The compile script reads it and stamps the value into the three root manifest/marketplace files (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`) via `jq`, preserving all non-version fields and values semantically (JSON formatting may be normalized by `jq`'s pretty-printer; consumers depend on semantic content, not byte-level formatting). After stamping, the script re-reads each file and verifies the stamped value equals `src/VERSION`; any mismatch fails the build with an error naming the offending file. The same cross-check is also enforced in CI (`.github/workflows/release.yml`) before tag creation, so a maintainer who edits `src/VERSION` and pushes without recompiling is caught at push time. The `specshift finalize` version-bump step now edits only `src/VERSION`.

3. **Bootstrap content lives once in `AGENTS.md`.** The plugin maintains `src/templates/agents.md` (full body) and `src/templates/claude.md` (one-line `@AGENTS.md` import stub). On fresh `specshift init`, both files are generated unconditionally. Codex reads `AGENTS.md` natively at session start; Claude Code reads `CLAUDE.md` and expands the documented `@AGENTS.md` memory-import. The stub is a pointer, not a content duplicate — single source of truth is preserved.

4. **One shared, tool-agnostic compiled skill tree.** No per-target SKILL variants, no token-substitution rewrite passes. Skill body avoids `${CLAUDE_PLUGIN_ROOT}` and other runtime-specific environment variables; product names appear only where the surrounding paragraph is target-scoped. Worktree path patterns avoid hardcoded `.claude/worktrees/...` strings — the default is `.specshift/worktrees/{change}` (project-configurable).

5. **`jq` becomes a hard build dependency.** The compile script preflights `command -v jq` and fails with a descriptive error if missing. Reliable structured version stamping in JSON requires `jq`; falling back to `sed`/`awk` would be brittle (regex-based JSON editing is error-prone for nested or quoted strings) and could accidentally corrupt or mis-edit the manifests.

6. **Ship the Codex marketplace catalog at `.agents/plugins/marketplace.json` with a Git-URL source (amended 2026-04-28).** The `0.2.5-beta` release relied on the documented Codex auto-discovery pattern — `codex plugin marketplace add github:owner/repo` resolves a single-plugin repo's `.codex-plugin/plugin.json` directly without a catalog file. This was based on documentary evidence (OpenAI Codex docs + Shopify-AI-Toolkit precedent) and was not verified on a live Codex install. Issue #51 reported that the install path actually fails — Codex requires a catalog file at `.agents/plugins/marketplace.json` (the assumption was falsified). The catalog file was committed in `71c000fc` with the schema: `name`, `interface.displayName`, `plugins[].source: { source: "url", url: "https://github.com/fritze-dev/SpecShift.git" }`, `plugins[].policy: { installation: "AVAILABLE", authentication: "ON_INSTALL" }`, `plugins[].category: "Coding"`. The catalog has no `plugins[].version` field — the version source of truth at `src/VERSION` is propagated only to the three plugin manifest files that declare their own version. The Git-URL source form was chosen over a `local`-path source because Codex re-clones the URL during install and resolves the existing `.codex-plugin/plugin.json` and `./skills/specshift/` at the repo root — no generated sub-payload directory is needed (parallel attempts in PR #52 and PR #53 used `local` paths and required generating a replicated sub-payload under `plugins/specshift/`). The catalog file is hand-edited; its presence and schema are not enforced by the build script in this release (defense-in-depth deferred to a follow-up issue if relevant).

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
- **Ship a `.agents/plugins/marketplace.json` catalog file**: this was originally rejected on documentary evidence (Shopify-AI-Toolkit does not ship one; documented Codex auto-discovery behavior). The rejection was falsified on 2026-04-28 against a live Codex install (Issue #51) — Codex actually requires the catalog. **Decision: ship the catalog.** See Decision 6 above for the schema details and the Git-URL-vs-`local`-path choice rationale. This entry is retained as a decision-history record of the original rejection and its later reversal.

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
- **Live install verification on a real Codex installation deferred**: spec scenarios cover the install flow but execution against an actual `codex /plugins` install will be a follow-up step. **Update (2026-04-28):** the auto-discovery assumption was falsified on a live Codex install, which led to Decision 6 (ship the catalog file). A clean-machine smoke test of the new catalog-mediated path is still pending (Issue #51 acceptance).
- **Codex catalog schema is hand-maintained, not build-enforced (added 2026-04-28)**: `.agents/plugins/marketplace.json` is not version-stamped or shape-verified by `bash scripts/compile-skills.sh`. A maintainer who edits the catalog incorrectly (wrong `source.source` value, missing `policy` field) discovers the regression only via a live Codex install. Mitigation: a follow-up `verify_catalog_shape()` issue can add jq-based shape verification and a CI cross-check loop entry without changing the catalog file's format.

## References

- [Change: 2026-04-28-align-codex-marketplace-catalog](../../.specshift/changes/2026-04-28-align-codex-marketplace-catalog/) (Decision 6 amendment)
- [Change: 2026-04-27-multi-target-distribution](../../.specshift/changes/2026-04-27-multi-target-distribution/)
- [Spec: multi-target-distribution](../../docs/specs/multi-target-distribution.md)
- [Spec: project-init](../../docs/specs/project-init.md)
- [Spec: release-workflow](../../docs/specs/release-workflow.md)
- [Shopify-AI-Toolkit](https://github.com/Shopify/Shopify-AI-Toolkit) — multi-target reference layout
- Codex CLI plugin docs: https://developers.openai.com/codex
- Claude Code memory-import / `@AGENTS.md`: https://code.claude.com/docs/de/memory#agents-md
