# Research: Codex Plugin Support (Multi-Target Distribution)

## 1. Current State

SpecShift currently distributes only as a Claude Code plugin:

- **Plugin source:** `src/.claude-plugin/plugin.json`, `src/skills/specshift/SKILL.md`, `src/templates/`, `src/actions/`
- **Compile script:** `scripts/compile-skills.sh` builds release into `.claude/skills/specshift/` (plugin root for Claude marketplace)
- **Distribution:** `.claude-plugin/marketplace.json` with `source: "./.claude"`, install via `claude plugin marketplace add fritze-dev/specshift`
- **Skill router:** Single `specshift` skill with five built-in actions (init, propose, apply, finalize, review) dispatched via first argument
- **SKILL.md frontmatter:** Only `name` + `description` — no Claude-specific keys like `allowed-tools`
- **Bootstrap template:** `src/templates/claude.md` generates `CLAUDE.md` in consumer projects (template-version 4 since commit 3d3f89f)
- **Workflow-routing rule:** Lives as plain Markdown text in `src/templates/claude.md` (line ~28) and `CLAUDE.md` (line 18) — no settings.json hook
- **Constitution rules** (`.specshift/CONSTITUTION.md`): Three-layer architecture, release directory immutability, AOT compilation, template-version discipline, plugin source layout

## 2. External Research

**Codex CLI plugin model** (verified via developers.openai.com/codex):
- Plugin manifest at `.codex-plugin/plugin.json` with schema `{name, version, description, skills, interface}`
- `interface` block: `displayName`, `shortDescription`, `category`, `capabilities`, `logo`, `composerIcon`, `brandColor`, `defaultPrompt`
- Skill discovery paths: `$CWD/.agents/skills`, `$REPO_ROOT/.agents/skills`, `$HOME/.agents/skills`, `/etc/codex/skills`
- Skills: folder with `SKILL.md` (required, frontmatter `name` + `description`) plus optional `scripts/`, `references/`, `assets/`
- Custom prompts (`~/.codex/prompts/`) are upstream-deprecated in favor of skills
- Hooks (`SessionStart`, `PreToolUse`, `PostToolUse`, etc.) live in `~/.codex/config.toml`; not shippable from a plugin
- Marketplace: `.agents/plugins/marketplace.json` (repo or user); install via `codex /plugins`

**Shopify-AI-Toolkit** (https://github.com/Shopify/Shopify-AI-Toolkit, verified via gh api):
- Multi-target single repo: `.claude-plugin/`, `.codex-plugin/`, `.cursor-plugin/`, `gemini-extension.json` side by side at repo root
- Shared `skills/<name>/SKILL.md` tree consumed by all targets unchanged (frontmatter portable across targets)
- No AOT compile step (skill bodies authored directly), unlike SpecShift which needs compilation for template-version enforcement and requirement extraction
- `.codex-plugin/plugin.json` example: `{name, version, description, skills: "./skills/", interface: {...}}`

**Claude Code AGENTS.md interop** (https://code.claude.com/docs/de/memory#agents-md):
- Claude Code reads `CLAUDE.md`, NOT `AGENTS.md` natively
- Recommended pattern when both tools must read same instructions: `CLAUDE.md` contains `@AGENTS.md` import. Claude expands the import at session start and loads AGENTS.md content into context
- Claude-specific instructions can be appended below the import

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **Shopify-flat (chosen):** skills/ at repo root, both manifests side-by-side | Symmetry with reference; single source of truth for skill body; matches verified working multi-target example | Migrates Claude marketplace source from `./.claude` to `./` — bestehende Claude-Installs müssen Update ziehen |
| **Additive sibling:** `.codex-plugin/` neben unverändertem `.claude/` | Keine Migration der Claude-Distribution | Codex-Manifest verweist auf `.claude/skills/` — semantisch krumm; ungewöhnliches Layout |
| **Two release dirs:** `.claude/` + `.codex/` parallel | Klare Trennung, beide Targets unabhängig | Disk-Verdopplung; zwei Build-Outputs synchron halten |
| **Single AGENTS.md (no CLAUDE.md):** Konsolidieren auf nur eine Datei | Maximal konsolidiert | Bricht bestehende Claude-Installs (CLAUDE.md erwartet); Claude liest AGENTS.md nicht nativ |
| **Two bootstrap templates with identical body:** agents.md + claude.md getrennt gepflegt | Detection-Klarheit | Duplikat-Pflege: Workflow-Regeln (wie Commit 3d3f89f) müssten zweimal aktualisiert werden — Code-Rot |

## 4. Risks & Constraints

- **Marketplace migration risk:** Changing `.claude-plugin/marketplace.json` source from `./.claude` to `./` may require existing installs to run `claude plugin marketplace update`. No technical breakage, just a re-pull.
- **Codex marketplace API maturity:** Codex plugin/marketplace API is young — schema details (e.g., exact `marketplace.json` location for Codex, `interface` field requirements) may shift. Plan to verify against live Codex docs at implementation time.
- **Constitution conflict — release directory:** CONSTITUTION.md Architecture Rules currently states "`.claude/skills/specshift/` is the generated release artifact". This rule must be updated as part of this change to reference the new `skills/specshift/` location.
- **Constitution conflict — plugin source layout:** Conventions section currently states `marketplace.json` uses `source: "./.claude"`. This rule must be updated.
- **Compile script semantics:** `compile-skills.sh` currently writes both manifest and skill into `.claude/`. Splitting into `.claude-plugin/` (Claude manifest), `.codex-plugin/` (Codex manifest), and `skills/` (shared body) at repo root requires careful path adjustments.
- **Workflow-routing hook misconception:** Originally suspected that commit 3d3f89f added a settings.json hook. Verified: it is text-only in CLAUDE.md/claude.md template. No real hook exists — Codex parity therefore trivial (just put the same text in AGENTS.md, which is the via @AGENTS.md import already done in the chosen approach).
- **Branding assets out of scope:** Codex `interface.logo`, `composerIcon`, `brandColor` not provided in Phase 1 — Codex listing will work without logo but look less polished.
- **Cursor/Gemini parity not in scope:** Shopify ships those too; SpecShift will stop at Claude + Codex for Phase 1.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | In/out of scope explicitly enumerated in approved plan (Shopify-flat layout + Codex-only as second target). |
| Behavior | Clear | Compile produces both manifests at root; init writes AGENTS.md (full body) + CLAUDE.md (`@AGENTS.md` stub); skill body shared. |
| Data Model | Clear | Codex manifest schema verified (name, version, description, skills, interface block). |
| UX | Clear | Two install commands in README: `claude plugin marketplace add ...` and `codex /plugins`. |
| Integration | Clear | No external services required. GitHub release process unchanged. |
| Edge Cases | Clear | Mixed Claude+Codex projects: both files generated unconditionally, no detection logic needed. Existing Claude installs: marketplace re-pull. |
| Constraints | Clear | Constitution updates needed (release dir path, plugin source layout convention) — captured below. |
| Terminology | Clear | "Multi-target distribution" as the new capability name; "shared skill tree" as the layout pattern. |
| Non-Functional | Clear | Same compile-time guarantees (template-version, plugin-version stamping) apply to both targets. |

## 6. Open Questions

All categories Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Adopt Shopify-flat layout (`skills/` at repo root, both manifests side-by-side) | Matches verified multi-target reference; eliminates duplication; cleanest symmetry | Additive sibling, two release dirs |
| 2 | Single bootstrap template `agents.md` (full content) + `claude.md` reduced to `@AGENTS.md` import stub | Eliminates content duplication; Claude Code's documented AGENTS.md interop pattern | Two parallel templates with identical bodies, AGENTS.md only |
| 3 | No env-detection in init — always write both AGENTS.md and CLAUDE.md | CLAUDE.md becomes a trivially-small import stub that cannot drift; both tools work without setup | Detect Claude vs Codex environment, ask user when ambiguous |
| 4 | Workflow-routing rule lives only in agents.md | Single source; CLAUDE.md inherits via @-import | Duplicate rule in both templates |
| 5 | Codex hook setup out of scope (text-only enforcement via AGENTS.md) | Codex hooks live in user config.toml, not plugin-installable; plain-text rule already proven sufficient on Claude side | Ship copy-paste config.toml snippet in README |
| 6 | Branding assets (logo, brandColor) deferred to follow-up change | Codex plugin works without them; keeps scope tight | Include logo SVG and brand color now |
