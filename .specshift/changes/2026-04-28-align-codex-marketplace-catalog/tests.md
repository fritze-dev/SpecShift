# Tests: Align Codex Marketplace Catalog Documentation

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

The plugin is Markdown/YAML; no executable test framework. Per CONSTITUTION.md `## Testing`: validation is done via Gherkin scenarios verified during apply's audit.md.

## Manual Test Plan

### Capability: multi-target-distribution

#### Requirement: Codex Discovery via Marketplace Catalog

- [ ] **Scenario: Codex install resolves the plugin via the catalog**
  - Setup: A Codex user runs `codex plugin marketplace add fritze-dev/SpecShift`
  - Action: Codex resolves the repository
  - Verify: Codex reads `.agents/plugins/marketplace.json` at the repository root, follows the declared `plugins[0].source` to fetch the plugin, and the consumer can subsequently install/enable SpecShift from the in-session `/plugins` directory
  - **Note:** Live verification deferred to Issue #51 acceptance — out of scope for this change. This change only verifies that the catalog file is present at the documented path with the documented schema.

- [ ] **Scenario: Codex marketplace catalog file shipped at root**
  - Setup: The repository on `claude/optimize-codex-marketplace-uVtJK`
  - Action: Inspect the root layout
  - Verify: `.agents/plugins/marketplace.json` exists as a hand-edited file; contains `name`, `interface.displayName`, and a single-entry `plugins[]` array; `plugins[]` entries contain no `version` field

#### Requirement: Codex Marketplace Catalog Schema (NEW)

- [ ] **Scenario: Catalog declares a Git-URL source**
  - Setup: The catalog at `.agents/plugins/marketplace.json`
  - Action: Inspect the file
  - Verify: `plugins[0].source.source == "url"`; `plugins[0].source.url` is a string ending in `.git`

- [ ] **Scenario: Catalog declares the install policy**
  - Setup: The catalog at `.agents/plugins/marketplace.json`
  - Action: Inspect the file
  - Verify: `plugins[0].policy.installation == "AVAILABLE"`; `plugins[0].policy.authentication == "ON_INSTALL"`; `plugins[0].category` is a non-empty string

#### Requirement: Per-Target Plugin Manifest (existing — unchanged)

- [ ] **Scenario: Manifests authored at repo root**
  - Setup: The repository
  - Action: Inspect the root layout
  - Verify: `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` still exist at the repository root; both still hand-edited (no `src/.claude-plugin/` or `src/.codex-plugin/` source counterparts)

#### Requirement: Symmetric Version Stamping with Cross-Check (existing — unchanged)

- [ ] **Scenario: All three files stamped from one source**
  - Setup: `src/VERSION` contains `0.2.6-beta` (post-finalize)
  - Action: `bash scripts/compile-skills.sh` runs
  - Verify: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json` all declare version `0.2.6-beta`; the catalog file is untouched

### Capability: release-workflow

#### Requirement: Source and Release Directory Structure (modified — file count updated)

- [ ] **Scenario: Four root files coexist with three-file version stamping**
  - Setup: The repository after this change
  - Action: List root manifest/marketplace files
  - Verify: Four files exist (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`); only the first three carry a `version` field; `bash scripts/compile-skills.sh` stamps only the first three

### Capability: Documentation truth (cross-cutting verification)

#### File-level checks (apply phase output)

- [ ] **Scenario: Old "no catalog file" claims removed**
  - Setup: The repository after apply
  - Action: `grep -r "no separate Codex marketplace catalog file is shipped" AGENTS.md docs/specs/ .specshift/CONSTITUTION.md`
  - Verify: Zero matches

- [ ] **Scenario: Old "SHALL NOT ship" clause removed**
  - Setup: The repository after apply
  - Action: `grep -r "SHALL NOT ship a \`.agents/plugins/marketplace.json\`" docs/specs/`
  - Verify: Zero matches

- [ ] **Scenario: README install command corrected**
  - Setup: The repository after apply
  - Action: Read `README.md` Installation → OpenAI Codex CLI section
  - Verify: Section contains `codex plugin marketplace add fritze-dev/SpecShift` and an in-session `/plugins`-UI install/enable step; Update subsection contains `codex plugin marketplace upgrade specshift`; no `codex plugin install <name>` line

- [ ] **Scenario: README tree diagram updated**
  - Setup: The repository after apply
  - Action: Read `README.md` Multi-Target Distribution tree diagram
  - Verify: Tree diagram contains a `.agents/plugins/` directory entry with `marketplace.json`

- [ ] **Scenario: Spec frontmatter bumped**
  - Setup: The repository after specs phase
  - Action: Read frontmatter of `docs/specs/multi-target-distribution.md` and `docs/specs/release-workflow.md`
  - Verify: `multi-target-distribution.md` declares `version: 5`, `release-workflow.md` declares `version: 6`; both declare `lastModified: 2026-04-28`

- [ ] **Scenario: Catalog file untouched**
  - Setup: The repository after apply
  - Action: `git diff origin/main -- .agents/plugins/marketplace.json`
  - Verify: Diff shows no modification beyond the original `71c000fc` introduction

- [ ] **Scenario: Compile script unchanged**
  - Setup: The repository after apply
  - Action: `git diff origin/main -- scripts/compile-skills.sh`
  - Verify: Diff is empty

- [ ] **Scenario: CI workflow unchanged**
  - Setup: The repository after apply
  - Action: `git diff origin/main -- .github/workflows/release.yml`
  - Verify: Diff is empty

#### Finalize-stage checks

- [ ] **Scenario: Compile script runs unchanged**
  - Setup: After finalize stages 1–3 complete (changelog, capability docs, version bump)
  - Action: `bash scripts/compile-skills.sh`
  - Verify: Exits 0 with no warnings; output reports three version-stamped files (Claude manifest, Claude marketplace, Codex manifest); the catalog is not in the output summary

- [ ] **Scenario: Capability doc regenerated**
  - Setup: After finalize stage 2 (docs regeneration)
  - Action: Read `docs/capabilities/multi-target-distribution.md`
  - Verify: Reflects v5 spec content (mentions catalog file, Git-URL source, four root files)

- [ ] **Scenario: ADR-003 amended**
  - Setup: After finalize stage 2
  - Action: `grep "Decision 6" docs/decisions/adr-003-shopify-flat-multi-target-distribution.md`
  - Verify: At least one match; the amendment records the falsification of the auto-discovery assumption and the Git-URL source choice

- [ ] **Scenario: Version bumped to 0.2.6-beta**
  - Setup: After finalize stage 3 (version bump)
  - Action: `cat src/VERSION`
  - Verify: Output is `0.2.6-beta`

- [ ] **Scenario: CHANGELOG entry added**
  - Setup: After finalize stage 1
  - Action: Read top of `CHANGELOG.md`
  - Verify: Contains `## [v0.2.6-beta] — 2026-04-28` header with `### Codex Marketplace Catalog` sub-heading; Added/Changed sections describe the catalog ship, spec/AGENTS/CONSTITUTION/README updates, ADR amendment

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 16 |
| Automated tests | 0 |
| Manual test items | 16 |
| Preserved (@manual) | 0 |
| Edge case tests | 0 |
| Warnings | 0 |

The 16 manual scenarios cover: 4 spec scenarios from `multi-target-distribution.md` (1 from existing Requirement, 0 from existing schema, 2 from new Requirement, 1 from existing parent Requirement carried forward); 1 from `release-workflow.md` Requirement update; 8 file-level cross-cutting checks (apply-phase output verification); 3 finalize-stage checks. All manual — the plugin has no executable test framework. Live Codex install verification is deferred to Issue #51 acceptance.
