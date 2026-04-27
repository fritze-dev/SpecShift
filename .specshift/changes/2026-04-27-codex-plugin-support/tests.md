# Tests: Codex Plugin Support (Multi-Target Distribution)

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none — per CONSTITUTION `## Testing`: plugin is Markdown/YAML artifacts) |
| Test directory | (none) |
| File pattern | (none) |

## Automated Tests

*(none — no framework configured)*

## Manual Test Plan

### multi-target-distribution

#### Per-Target Plugin Manifest

- [ ] **Scenario: Both manifests emitted at repo root**
  - Setup: sources at `src/.claude-plugin/plugin.json` and `src/.codex-plugin/plugin.json` exist
  - Action: run `bash scripts/compile-skills.sh`
  - Verify: `.claude-plugin/plugin.json` exists at repo root; `.codex-plugin/plugin.json` exists at repo root; `version` field matches in both files

- [ ] **Scenario: Codex manifest contains required Codex schema fields**
  - Setup: source `src/.codex-plugin/plugin.json` is present
  - Action: inspect the file content
  - Verify: contains keys `name`, `version`, `description`, `skills`, `interface`; `interface` contains at least `displayName`, `shortDescription`, `category`

- [ ] **Scenario: Claude manifest schema preserved**
  - Setup: migration to multi-target completed
  - Action: inspect `.claude-plugin/plugin.json` after compilation
  - Verify: contains `name`, `description`, `version`, `author`, `repository`, `license`, `keywords`; does NOT contain a Codex `interface` block

- [ ] **Scenario: Version mismatch in sources is rejected**
  - Setup: edit `src/.claude-plugin/plugin.json` to version `0.3.0` and `src/.codex-plugin/plugin.json` to version `0.2.5`
  - Action: run `bash scripts/compile-skills.sh`
  - Verify: emitted `.codex-plugin/plugin.json` contains `0.3.0` (Claude version stamped onto Codex output)

#### Shared Skill Tree at Repository Root

- [ ] **Scenario: Skill compiled to repo root**
  - Setup: sources under `src/skills/specshift/`, `src/templates/`, `src/actions/`
  - Action: run `bash scripts/compile-skills.sh`
  - Verify: `./skills/specshift/SKILL.md`, `./skills/specshift/templates/`, `./skills/specshift/actions/` all exist

- [ ] **Scenario: Both manifests reference the shared tree**
  - Setup: compiled output present
  - Action: inspect both manifests
  - Verify: `.claude-plugin/marketplace.json` declares `source: "./"`; `.codex-plugin/plugin.json` declares `skills: "./skills/"`; both resolve to the same SKILL.md

- [ ] **Scenario: Legacy skill location removed**
  - Setup: a previous build at `.claude/skills/specshift/` exists
  - Action: run `bash scripts/compile-skills.sh`
  - Verify: `.claude/skills/` no longer exists; only `./skills/specshift/` is present

- [ ] **Scenario: Skill frontmatter portable across targets**
  - Setup: source `src/skills/specshift/SKILL.md` is present
  - Action: inspect frontmatter
  - Verify: contains only `name` and `description`; no `allowed-tools` or other Claude-specific fields

#### Codex Marketplace Entry

- [ ] **Scenario: Codex marketplace file generated**
  - Setup: compile script ready
  - Action: run `bash scripts/compile-skills.sh`
  - Verify: `.agents/plugins/marketplace.json` exists at repo root and references `.codex-plugin/plugin.json`

- [ ] **Scenario: Codex marketplace version stamped**
  - Setup: `src/.claude-plugin/plugin.json` declares version `0.3.0`
  - Action: run `bash scripts/compile-skills.sh`
  - Verify: `.agents/plugins/marketplace.json` declares plugin version `0.3.0`

- [ ] **Scenario: Independent marketplace updates**
  - Setup: edit only `.claude-plugin/marketplace.json` content (e.g., metadata field)
  - Action: re-run compile script
  - Verify: `.agents/plugins/marketplace.json` is unaffected

#### Bootstrap Single Source of Truth Pattern

- [ ] **Scenario: agents.md contains full bootstrap content**
  - Setup: source `src/templates/agents.md` is present
  - Action: inspect the file
  - Verify: contains sections covering `## Workflow`, `## Planning`, `## Knowledge Management`, `## File Ownership`

- [ ] **Scenario: claude.md is reduced to an import stub**
  - Setup: source `src/templates/claude.md` is present
  - Action: inspect the file
  - Verify: contains a line invoking `@AGENTS.md`; does NOT duplicate normative rules from agents.md; body length ≤ 10 lines (excluding frontmatter)

- [ ] **Scenario: Updating a shared rule touches only agents.md**
  - Setup: simulate an update to the workflow-routing rule
  - Action: edit only `src/templates/agents.md`; run compile
  - Verify: change is reflected in compiled `skills/specshift/templates/agents.md`; no edit needed in `claude.md`

- [ ] **Scenario: Both templates are Smart Templates**
  - Setup: source templates present
  - Action: inspect frontmatter of each
  - Verify: `agents.md` declares `template-version` and `generates: AGENTS.md`; `claude.md` declares `template-version` and `generates: CLAUDE.md`

#### Multi-Target Install Documentation

- [ ] **Scenario: README contains both install sections**
  - Setup: README updated as part of this change
  - Action: open `README.md`
  - Verify: contains "Claude Code" install section showing marketplace add + update commands; contains "Codex" install section showing `codex /plugins` discovery flow; both at the same heading level

- [ ] **Scenario: Future target addition follows the same pattern**
  - Setup: hypothetical Cursor target
  - Action: imagine adding a Cursor section
  - Verify: README structure supports adding a third section at the same heading level without restructuring existing sections (visual / structural inspection — no code change required for this scenario)

### project-init

#### Bootstrap Files Generation (modified requirement)

- [ ] **Scenario: Both files generated on fresh init**
  - Setup: a fresh test project with no `AGENTS.md` and no `CLAUDE.md`; SpecShift plugin installed
  - Action: run `specshift init`
  - Verify: `AGENTS.md` exists at project root with `## Workflow`, `## Planning`, `## Knowledge Management`, `## File Ownership` sections; `CLAUDE.md` exists with an `@AGENTS.md` import directive

- [ ] **Scenario: AGENTS.md exists but CLAUDE.md missing**
  - Setup: test project where AGENTS.md is present but CLAUDE.md is absent
  - Action: run `specshift init`
  - Verify: CLAUDE.md is created as an import stub; AGENTS.md is unchanged; standard-sections check on existing AGENTS.md is reported

- [ ] **Scenario: CLAUDE.md exists but AGENTS.md missing**
  - Setup: test project initialized by an older plugin version (CLAUDE.md present, no AGENTS.md)
  - Action: run `specshift init`
  - Verify: AGENTS.md is created with full body; CLAUDE.md is NOT overwritten; init suggests reducing CLAUDE.md to an import stub manually

- [ ] **Scenario: Both files exist**
  - Setup: project where both files already exist
  - Action: run `specshift init`
  - Verify: neither file is overwritten; init reports "AGENTS.md and CLAUDE.md already exist — skipped"

- [ ] **Scenario: AGENTS.md missing standard section detected on re-init**
  - Setup: existing AGENTS.md with `## Workflow` only (no `## Planning` or `## Knowledge Management`)
  - Action: run `specshift init`
  - Verify: AGENTS.md is NOT modified; init reports WARNING per missing section; suggests manual addition

- [ ] **Scenario: AGENTS.md includes project-specific rules**
  - Setup: project with detectable conventions during codebase scan
  - Action: run `specshift init` on a fresh project
  - Verify: generated AGENTS.md includes project-specific agent rules beyond standard sections; uncertain items have `<!-- REVIEW -->` markers

- [ ] **Scenario: CLAUDE.md import directive resolves correctly**
  - Setup: project with generated AGENTS.md and CLAUDE.md import-stub
  - Action: open the project in Claude Code; check `/memory` output
  - Verify: CLAUDE.md is loaded; `@AGENTS.md` import is expanded; AGENTS.md content appears in session context

#### Install Workflow (re-verify after edit)

- [ ] **Scenario: Bootstrap templates excluded from .specshift/templates/ copy**
  - Setup: fresh project without `.specshift/`
  - Action: run `specshift init`
  - Verify: `.specshift/templates/` does NOT contain `agents.md` or `claude.md` (these are bootstrap-only); does contain pipeline templates (research, proposal, etc.)

### Edge Cases (from new spec)

- [ ] **Edge: Codex manifest with extra fields preserved**
  - Setup: add a custom non-stamped field (e.g., `metadata.author`) to `src/.codex-plugin/plugin.json`
  - Action: run compile
  - Verify: emitted `.codex-plugin/plugin.json` retains the custom field

- [ ] **Edge: Existing Claude install marketplace update**
  - Setup: a system that previously installed SpecShift via the old marketplace source `./.claude`
  - Action: `claude plugin marketplace update specshift && claude plugin update specshift@specshift`
  - Verify: new layout resolves; skill works post-update; no manual reinstall required

- [ ] **Edge: Branding assets absent**
  - Setup: `src/.codex-plugin/plugin.json` without `interface.logo`, `composerIcon`, `brandColor`
  - Action: install via `codex /plugins`
  - Verify: install succeeds; plugin lists without branding (no error)

- [ ] **Edge: Mixed-target consumer project**
  - Setup: project with both Claude Code and Codex installed; both bootstrap files generated
  - Action: open in Claude Code, then in Codex
  - Verify: both tools see the same workflow rules without conflict

- [ ] **Edge: agents.md template missing from plugin**
  - Setup: simulate a broken plugin install where `agents.md` template is missing
  - Action: run `specshift init`
  - Verify: AGENTS.md generation is skipped with a warning; init does not block; CLAUDE.md generation may also be skipped (since stub references non-existent agents.md)

## Manual Test Plan — Scope Extension (2026-04-27)

### multi-target-distribution (revised)

#### Per-Target Plugin Manifest (manifests at root)

- [ ] **Scenario: Manifests authored at repo root**
  - Setup: repo as-is
  - Action: `ls .claude-plugin/plugin.json .codex-plugin/plugin.json` and confirm no `src/.claude-plugin/` or `src/.codex-plugin/` directories
  - Verify: both plugin.json files exist at the root; `src/` no longer carries manifest sources

- [ ] **Scenario: Codex manifest enriched fields present**
  - Setup: `.codex-plugin/plugin.json` after enrichment
  - Action: `jq -r '.author, .repository, .license, .keywords, .interface.longDescription, .interface.developerName, .interface.websiteURL, .interface.defaultPrompt, .interface.brandColor, .interface.screenshots' .codex-plugin/plugin.json`
  - Verify: each field returns a non-null value matching the design spec

- [ ] **Scenario: Version mismatch corrected by compile script**
  - Setup: temporarily edit `.codex-plugin/plugin.json` to a wrong version (e.g., `0.0.0-test`)
  - Action: run `bash scripts/compile-skills.sh`
  - Verify: `.codex-plugin/plugin.json` is restamped to the Claude manifest version; `.agents/plugins/marketplace.json` matches; non-version fields preserved

#### Agnostic Skill Body (NEW)

- [ ] **Scenario: Source has no Claude-specific environment variables**
  - Setup: post-extension source tree
  - Action: `grep -rn "\${CLAUDE_PLUGIN_ROOT}" src/skills src/templates src/actions docs/specs/project-init.md docs/specs/release-workflow.md docs/specs/multi-target-distribution.md`
  - Verify: zero matches in compiled-into-skill files

- [ ] **Scenario: Compiled skill tree is the same for both targets**
  - Setup: post-compile state
  - Action: `find ./skills/specshift -type f | sort` and confirm only one tree
  - Verify: no per-target variants; both manifests reference `./skills/specshift/`

- [ ] **Scenario: Product names appear only where target-scoped**
  - Setup: post-extension source
  - Action: `grep -rn "Claude Code" src/skills src/templates src/actions` (compiled-into-skill files)
  - Verify: any remaining `Claude Code` mention is paired with a paragraph that explicitly describes Claude Code-specific behavior (e.g., the `@AGENTS.md` import). The agnostic bootstrap template `agents.md` may still mention "Claude Code" when describing the import pattern — this is intentional.

#### Bootstrap SSOT (revised — manual-copy stub)

- [ ] **Scenario: claude.md is the import-stub template (manual copy)**
  - Setup: post-extension source
  - Action: inspect `src/templates/claude.md`
  - Verify: contains the `@AGENTS.md` import line; surrounding documentation/comment in the template describes that init does not auto-generate CLAUDE.md and that the stub is for manual copy

### release-workflow (revised, multi-target)

- [ ] **Scenario: Auto-bump after change completion (4-file matrix)**
  - Setup: working tree with `.claude-plugin/plugin.json` at `1.0.3`, all other versioned manifests at `1.0.3`
  - Action: trigger the auto-bump convention
  - Verify: all four files (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`) updated to `1.0.4`

- [ ] **Scenario: Manual minor release via push includes Codex artifacts**
  - Setup: maintainer ready to bump to `1.1.0`
  - Action: edit `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to `1.1.0`; run `bash scripts/compile-skills.sh`; commit + push
  - Verify: pushed commit contains `1.1.0` in `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json`

- [ ] **Scenario: Plugin root resolves to repo root (both targets, prose-based asset references)**
  - Setup: install plugin in test projects (one Claude Code, one Codex)
  - Action: invoke a skill action that references "the plugin's `templates/workflow.md`"
  - Verify: both runtimes locate and read the file successfully without environment-variable interpolation

- [ ] **Scenario: Compiled action file contains multi-target requirements**
  - Setup: post-compile state
  - Action: `grep -c "^### Requirement:" ./skills/specshift/actions/finalize.md`
  - Verify: count includes Source-and-Release-Directory-Structure, Marketplace-Source-Configuration, AOT-Skill-Compilation, Compiled-Action-File-Contract, Dev-Sync-Script (the requirement-link extension applied to `src/actions/finalize.md`)

- [ ] **Scenario: jq missing on dev machine**
  - Setup: temporarily rename `jq` binary or run script in a container without `jq`
  - Action: `bash scripts/compile-skills.sh`
  - Verify: script exits with a clear error message naming `jq` as the missing dependency

### project-init (revised — Option A bootstrap)

- [ ] **Scenario: Fresh init generates only AGENTS.md**
  - Setup: fresh test project with no `AGENTS.md` and no `CLAUDE.md`
  - Action: run `specshift init`
  - Verify: `AGENTS.md` exists with `## Workflow`, `## Planning`, `## Knowledge Management` sections; `CLAUDE.md` does NOT exist; init output mentions that a one-line `@AGENTS.md` `CLAUDE.md` may be added manually

- [ ] **Scenario: AGENTS.md exists, CLAUDE.md missing (no auto-create)**
  - Setup: test project where AGENTS.md is present but CLAUDE.md is absent
  - Action: run `specshift init`
  - Verify: AGENTS.md unchanged; CLAUDE.md is NOT created; standard-sections check on AGENTS.md reported

- [ ] **Scenario: User-maintained CLAUDE.md import directive resolves correctly**
  - Setup: project with generated `AGENTS.md`; user manually creates `CLAUDE.md` with the line `@AGENTS.md`
  - Action: open the project in Claude Code; check `/memory` output
  - Verify: CLAUDE.md is loaded; `@AGENTS.md` import is expanded; AGENTS.md content appears in session context

### Replaced/Superseded Scenarios

The following first-pass scenarios are superseded by the extension and SHALL be considered replaced by the revised scenarios above:

- "Both files generated on fresh init" → replaced by "Fresh init generates only AGENTS.md"
- "AGENTS.md exists but CLAUDE.md missing" → replaced by "AGENTS.md exists, CLAUDE.md missing (no auto-create)"
- "CLAUDE.md import directive resolves correctly" → replaced by "User-maintained CLAUDE.md import directive resolves correctly"
- "Both manifests emitted at repo root" (compile-driven) → replaced by "Manifests authored at repo root" (hand-edited)
- "Codex manifest contains required Codex schema fields" — still applicable but now also enriched fields covered by "Codex manifest enriched fields present"

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios (first-pass + extension) | 38 |
| First-pass scenarios still applicable | 19 |
| First-pass scenarios superseded by extension | 6 |
| New extension scenarios | 13 |
| Automated tests | 0 |
| Manual test items | 38 (32 active after supersession) |
| Edge case tests | 5 (unchanged) |
| Warnings | 0 |
