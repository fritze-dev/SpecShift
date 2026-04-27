# Research: Multi-Target Distribution (Claude Code + Codex CLI)

## 1. Current State

SpecShift currently distributes only as a Claude Code plugin:

- **Plugin source:** `src/.claude-plugin/plugin.json`, `src/skills/specshift/SKILL.md`, `src/templates/`, `src/actions/`
- **Compile script:** `scripts/compile-skills.sh` builds the release into `.claude/skills/specshift/` (plugin root for the Claude marketplace)
- **Distribution:** `.claude-plugin/marketplace.json` with `source: "./.claude"`, install via `claude plugin marketplace add fritze-dev/specshift`
- **Skill router:** Single `specshift` skill with five built-in actions (init, propose, apply, finalize, review) dispatched via the first argument
- **SKILL.md frontmatter:** Only `name` + `description` — no Claude-specific keys (e.g. `allowed-tools`)
- **Bootstrap template:** `src/templates/claude.md` generates `CLAUDE.md` in consumer projects
- **Workflow-routing rule:** Lives as plain Markdown text in `src/templates/claude.md` and consumer `CLAUDE.md` — no settings.json hook
- **Version source of truth:** `src/.claude-plugin/plugin.json` `version` field; `.claude-plugin/marketplace.json` carries a `plugins[0].version` field that the maintainer hand-syncs at finalize time
- **Constitution rules** (`.specshift/CONSTITUTION.md`): Three-layer architecture, release directory immutability, AOT compilation, template-version discipline, plugin source layout, version-bump convention

## 2. External Research

**Codex CLI plugin model** (verified via developers.openai.com/codex):
- Plugin manifest at `.codex-plugin/plugin.json` with schema `{name, version, description, skills, interface}`
- `interface` block: `displayName`, `shortDescription`, `longDescription`, `developerName`, `category`, `capabilities`, `websiteURL`, `defaultPrompt`, `brandColor`, `screenshots`
- Skill discovery paths include `$REPO_ROOT/skills/`
- Skills: folder with `SKILL.md` (required, frontmatter `name` + `description`) plus optional `scripts/`, `references/`, `assets/`
- Custom prompts (`~/.codex/prompts/`) are upstream-deprecated in favor of skills
- Hooks (`SessionStart`, `PreToolUse`, `PostToolUse`, etc.) live in `~/.codex/config.toml`; not shippable from a plugin
- Marketplace: `.agents/plugins/marketplace.json` (repo or user); install via `codex /plugins`

**Shopify-AI-Toolkit** (https://github.com/Shopify/Shopify-AI-Toolkit, verified via gh api):
- Multi-target single repo: `.claude-plugin/`, `.codex-plugin/`, `.cursor-plugin/`, `gemini-extension.json` side by side at the repo root
- Shared `skills/<name>/SKILL.md` tree consumed by all targets unchanged (frontmatter portable across targets)
- No AOT compile step (skill bodies authored directly), unlike SpecShift which needs compilation for template-version enforcement and requirement extraction
- `.codex-plugin/plugin.json` example: `{name, version, description, skills: "./skills/", interface: {...}}`

**Claude Code AGENTS.md interop** (https://code.claude.com/docs/de/memory#agents-md):
- Claude Code reads `CLAUDE.md`, NOT `AGENTS.md` natively
- Recommended pattern when both tools must read the same instructions: `CLAUDE.md` contains a `@AGENTS.md` import. Claude expands the import at session start and loads AGENTS.md content into context.
- Claude-specific instructions can be appended below the import

**Version-file conventions** (industry survey):
- Plain-text `VERSION` file (uppercase, no extension, single line, semver) is the most-recognized convention — Linux kernel, many Python/Go/Ruby tools, Docker images expose `/VERSION`
- Alternative: embed version in language-native manifests (`package.json`, `Cargo.toml`, `pyproject.toml`) — only sensible when a language manifest already exists
- Alternative: derive from git tags at build time — cleaner for CI-driven projects but adds indirection for an explicit `propose → finalize` flow
- Format standard for the value: SemVer 2.0 — already in use here

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **Shopify-flat (chosen):** `skills/` at repo root, both manifests side-by-side | Symmetry with the verified multi-target reference; single source of truth for skill body; matches working precedent | Migrates Claude marketplace source from `./.claude` to `./` — existing Claude installs must run a marketplace update |
| Additive sibling: `.codex-plugin/` next to unchanged `.claude/` | No migration of Claude distribution | Codex manifest references `.claude/skills/` — semantically crooked, unusual layout |
| Two release dirs: `.claude/` + `.codex/` parallel | Clear separation, each target independent | Disk duplication; two build outputs to keep in sync |
| Single AGENTS.md (no CLAUDE.md): consolidate to one file | Maximally consolidated | Breaks existing Claude installs (CLAUDE.md expected); Claude does not read AGENTS.md natively |
| Two bootstrap templates with identical body: agents.md + claude.md kept in parallel | Detection clarity | Duplicate maintenance: workflow rules need updating in two places — code rot |
| **Version SoT in `src/VERSION`** (chosen) | Decouples versioning from per-target metadata; symmetric stamping for all 4 root manifests/marketplaces; trivially-readable plain text | One additional file in `src/` |
| Version SoT remains in Claude `plugin.json` | No new file | Claude manifest carries dual responsibility ("Claude metadata" + "repo version SoT"); Codex side reads version *from* the Claude file — asymmetric |
| Version SoT at repo root (`./VERSION`) | Consumer-visible; classic convention | Conflicts with the `src/` ownership rule (`src/` = plugin source; root = compiled output); SoT is internal, not consumer-facing |

## 4. Risks & Constraints

- **Marketplace migration risk:** Changing `.claude-plugin/marketplace.json` source from `./.claude` to `./` requires existing installs to run `claude plugin marketplace update`. No technical breakage, just a re-pull.
- **Codex marketplace API maturity:** Codex plugin/marketplace API is young — schema details may shift. Plan to verify against live Codex docs at implementation time.
- **Constitution conflict — release directory:** CONSTITUTION.md Architecture Rules currently states "`.claude/skills/specshift/` is the generated release artifact". This rule must be updated as part of this change.
- **Constitution conflict — plugin source layout:** Conventions section currently states `marketplace.json` uses `source: "./.claude"`. This rule must be updated.
- **Constitution conflict — version-bump convention:** Conventions section names `src/.claude-plugin/plugin.json` as version SoT. With the new `src/VERSION` SoT, this rule changes.
- **Compile script semantics:** `compile-skills.sh` currently writes the manifest and skill into `.claude/`. Splitting into `.claude-plugin/` (Claude manifest, root), `.codex-plugin/` (Codex manifest, root), `.agents/plugins/` (Codex marketplace, root), and `skills/` (shared body, root) requires careful path adjustments and symmetric version-stamping across all three root files.
- **Workflow-routing hook misconception:** Verified that the workflow-routing rule is text-only in CLAUDE.md/claude.md template — no settings.json hook exists. Codex parity is therefore trivial (the same text in AGENTS.md, reachable by Claude via `@AGENTS.md` import).
- **Branding assets out of scope:** Codex `interface.logo`, `composerIcon` not provided in this change — Codex listing will work without a logo but look less polished.
- **Cursor/Gemini parity not in scope:** Shopify ships those too; SpecShift stops at Claude + Codex for this change.
- **Version-stamping silent drift risk:** With the version SoT moved to `src/VERSION`, the compile script must verify that ALL four root files (`{.claude-plugin,.codex-plugin}/plugin.json`, `.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json`) carry the stamped version after the build. Without a post-stamp cross-check, a silent jq failure on one file would produce inconsistent published versions.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | In/out of scope explicitly enumerated; Codex as second target plus version SoT consolidation. |
| Behavior | Clear | Compile reads `src/VERSION`, stamps four root files, writes shared skill tree to `./skills/`; init writes AGENTS.md (full body) + CLAUDE.md (`@AGENTS.md` stub). |
| Data Model | Clear | Codex manifest schema verified; version-file format is plain semver text. |
| UX | Clear | Two install commands in README: `claude plugin marketplace add ...` and `codex /plugins`. |
| Integration | Clear | No external services required. GitHub release process unchanged. |
| Edge Cases | Clear | Mixed Claude+Codex projects: both files generated unconditionally. Existing Claude installs: marketplace re-pull. Stale version in any of the three root files: post-stamp cross-check fails the build. |
| Constraints | Clear | Constitution updates needed (release dir path, plugin source layout, version-bump convention). |
| Terminology | Clear | "Multi-target distribution" as the new capability name; "shared skill tree" as the layout pattern; "version source of truth" as the file. |
| Non-Functional | Clear | Same compile-time guarantees (template-version, plugin-version stamping) apply to both targets symmetrically. |

## 6. Open Questions

All categories Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Adopt Shopify-flat layout (`skills/` at repo root, both manifests side-by-side) | Matches verified multi-target reference; eliminates duplication; cleanest symmetry | Additive sibling, two release dirs |
| 2 | Single bootstrap template `agents.md` (full content) + `claude.md` reduced to `@AGENTS.md` import stub | Eliminates content duplication; uses Claude Code's documented AGENTS.md interop pattern | Two parallel templates with identical bodies, AGENTS.md only |
| 3 | No env-detection in init — always write both AGENTS.md and CLAUDE.md | CLAUDE.md becomes a trivially-small import stub that cannot drift; both tools work out of the box | Detect Claude vs Codex environment, ask user when ambiguous |
| 4 | Plugin manifests and marketplace files are hand-edited at the repo root (no `src/` indirection) | Manifests carry per-target metadata that has no source/output relationship; the `src/` layer added rendering overhead with zero gain after Shopify-flat migration | Keep `src/.claude-plugin/`, `src/.codex-plugin/`, render into root at compile time |
| 5 | Version source of truth is `src/VERSION` (plain text, single line, semver) | Decouples versioning from per-target metadata; symmetric stamping into all three root files; classic convention; no tool dependency for read | Keep version in Claude manifest; embed in language manifest; derive from git tags; root-level `./VERSION` |
| 6 | Compile script stamps version into all three root files (`{.claude-plugin,.codex-plugin}/plugin.json` + `.claude-plugin/marketplace.json` + `.agents/plugins/marketplace.json`) and cross-checks each post-stamp | Eliminates silent drift; previously the Claude marketplace version was hand-edited and unchecked | Stamp only the manifests; trust hand-edits on marketplaces |
| 7 | Workflow-routing rule lives only in agents.md | Single source; CLAUDE.md inherits via `@`-import | Duplicate rule in both templates |
| 8 | Codex hook setup out of scope (text-only enforcement via AGENTS.md) | Codex hooks live in user config.toml, not plugin-installable; plain-text rule already proven sufficient on Claude side | Ship copy-paste config.toml snippet in README |
| 9 | Branding assets (logo, screenshots) deferred to follow-up change | Codex plugin works without them; keeps scope tight | Include logo SVG and brand color now |
