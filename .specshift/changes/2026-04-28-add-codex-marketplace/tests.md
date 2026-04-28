# Tests: Add Codex Marketplace Catalog File

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none — plugin is Markdown/YAML/Bash, no executable test framework per CONSTITUTION ## Testing) |
| Test directory | (none) |
| File pattern | (none) |

The CONSTITUTION's `## Testing` section explicitly states: "Framework: None (plugin is Markdown/YAML artifacts, no executable tests). Validation: Gherkin scenarios verified via audit.md during apply." Therefore all scenarios in this change are manual-only and will be verified by audit.md.

## Manual Test Plan

### multi-target-distribution

#### Codex Discovery via Marketplace Add

- [ ] **Scenario: Codex install resolves via catalog**
  - Setup: a Codex user runs `codex plugin marketplace add github:fritze-dev/specshift` after this change is merged
  - Action: Codex resolves the repository
  - Verify: Codex reads `.agents/plugins/marketplace.json` at the repository root, follows `plugins[].source.path` to `.codex-plugin/plugin.json`, and `codex plugin install specshift` succeeds
  - Verification surface: re-run by the user who reported the original failure (post-merge); audit.md verifies the catalog file's existence and shape

- [ ] **Scenario: Codex marketplace catalog file shipped**
  - Setup: working tree on the change branch after implementation
  - Action: inspect the repository root layout
  - Verify: `.agents/plugins/marketplace.json` exists at the repo root and declares exactly one entry whose `source.path` resolves to `.codex-plugin/`
  - Verification surface: `test -f .agents/plugins/marketplace.json && jq '.plugins | length' .agents/plugins/marketplace.json` (audit step)

#### Codex Marketplace Catalog Schema

- [ ] **Scenario: Catalog file declares the documented top-level fields**
  - Setup: `.agents/plugins/marketplace.json` exists
  - Action: inspect top-level fields
  - Verify: object contains `name` (string `"specshift"`), `interface.displayName` (non-empty string), and `plugins` array with one entry
  - Verification surface: `jq -e '.name == "specshift" and (.interface.displayName | type == "string") and (.plugins | length == 1)' .agents/plugins/marketplace.json` (audit step)

- [ ] **Scenario: Catalog plugin entry uses object-form source**
  - Setup: `.agents/plugins/marketplace.json` exists with one plugin entry
  - Action: inspect `plugins[0].source`
  - Verify: object containing `source: "local"` and `path` (non-empty string ending in `.codex-plugin`)
  - Verification surface: `jq -e '.plugins[0].source | (type == "object") and (.source == "local") and (.path | endswith(".codex-plugin"))' .agents/plugins/marketplace.json` (audit step)

- [ ] **Scenario: Catalog plugin entry omits version field**
  - Setup: `.agents/plugins/marketplace.json` exists with one plugin entry
  - Action: inspect `plugins[0]`
  - Verify: no `version` key
  - Verification surface: `jq -e '.plugins[0] | has("version") | not' .agents/plugins/marketplace.json` (audit step)

#### Symmetric Version Stamping with Cross-Check

- [ ] **Scenario: All three version-bearing files stamped from one source**
  - Setup: `src/VERSION` contains a SemVer string; the three version-bearing files declare possibly-arbitrary prior versions
  - Action: run `bash scripts/compile-skills.sh`
  - Verify: all three files declare the same version as `src/VERSION`; non-version keys preserved semantically
  - Verification surface: existing CI test, retained

- [ ] **Scenario: Post-stamp cross-check fails on drift**
  - Setup: simulated stamp failure on `.codex-plugin/plugin.json`
  - Action: cross-check step runs
  - Verify: script exits non-zero with an error naming `.codex-plugin/plugin.json`
  - Verification surface: existing behavior, retained — no regression check needed beyond reading the script

- [ ] **Scenario: Codex catalog file shape-checked but not version-stamped**
  - Setup: `.agents/plugins/marketplace.json` exists with the documented Codex schema; `src/VERSION` contains `0.2.6-beta`
  - Action: run `bash scripts/compile-skills.sh`
  - Verify: script does not add or modify any `plugins[].version` field; script logs a "catalog shape verified" line; top-level `name`, `interface.displayName`, and `plugins[0].source` shape are confirmed; build fails if file is absent or malformed
  - Verification surface: audit step runs the compile script in dry-mode (or post-run inspection); jq verifies no `version` field was introduced

- [ ] **Scenario: Release CI cross-check includes catalog file**
  - Setup: `.github/workflows/release.yml` reflects this change
  - Action: inspect the cross-check loop in the workflow file
  - Verify: loop entries include `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json` (all version-equality), AND `.agents/plugins/marketplace.json` (presence-only); the workflow fails before tag creation if any entry is missing or mismatched
  - Verification surface: read-only inspection of `.github/workflows/release.yml` during audit; full live verification happens on the next push to `main` that bumps `src/VERSION`

- [ ] **Scenario: Workflow template version stamped from same source**
  - Setup: `src/VERSION` contains a SemVer string
  - Action: run `bash scripts/compile-skills.sh`
  - Verify: `./skills/specshift/templates/workflow.md` frontmatter declares `plugin-version: <src/VERSION>`
  - Verification surface: existing behavior, retained

#### Multi-Target Install Documentation

- [ ] **Scenario: README contains both install sections (updated)**
  - Setup: `README.md` after this change is applied
  - Action: inspect the Installation section
  - Verify: Claude Code subsection unchanged; Codex subsection shows `codex plugin marketplace add github:fritze-dev/specshift` followed by `codex plugin install specshift`; Codex Update subsection shows `codex plugin marketplace update specshift && codex plugin update specshift`; both subsections at the same heading level
  - Verification surface: read-only inspection of README.md during audit

#### File Ownership / Constitution Narrative

- [ ] **Scenario: AGENTS.md File Ownership reflects catalog-driven install**
  - Setup: `AGENTS.md` after this change is applied
  - Action: inspect the File Ownership entry covering `.codex-plugin/`
  - Verify: paragraph mentions `.agents/plugins/marketplace.json` as the install entry point; describes `.codex-plugin/plugin.json` as referenced by the catalog rather than as the auto-discovered surface
  - Verification surface: read-only inspection of AGENTS.md during audit

- [ ] **Scenario: CONSTITUTION Architecture Rules reflect catalog-driven install**
  - Setup: `.specshift/CONSTITUTION.md` after this change is applied
  - Action: inspect the Architecture Rules paragraph that previously asserted "no separate Codex marketplace catalog file is shipped"
  - Verify: paragraph now mentions the catalog file is shipped at `.agents/plugins/marketplace.json`
  - Verification surface: read-only inspection during audit

#### ADR-003

- [ ] **Scenario: ADR-003 records the decision flip**
  - Setup: `docs/decisions/adr-003-shopify-flat-multi-target-distribution.md` after this change is applied
  - Action: inspect Decisions and Alternatives Considered sections
  - Verify: a Decision-6 entry exists explicitly mandating `.agents/plugins/marketplace.json` and citing the user-observed install failure as the falsifying observation; the prior rejected-alternative paragraph is rewritten or annotated to reflect the reversal
  - Verification surface: read-only inspection during audit

## Edge-Case Tests

| Edge Case | Verification |
|-----------|-------------|
| Codex marketplace catalog schema change | Manual inspection: scripts/compile-skills.sh's shape verifier preserves any field present in the file beyond the documented schema verbatim. Tested by adding a stub extra field locally and re-running compile to confirm it is preserved (manual smoke). |
| Catalog file absent at compile time | scripts/compile-skills.sh preflight loop fails with a maintainer-actionable error. Tested by temporarily renaming the file and confirming compile fails (manual smoke). |
| Catalog file malformed JSON | jq invocation in the shape verifier exits non-zero. Tested by inserting a syntax error locally and confirming compile fails (manual smoke). |
| Catalog `plugins[]` array with zero entries | Shape verifier's `plugins | length == 1` check fails. Tested by manually removing the entry and confirming compile fails (manual smoke). |
| Codex CLI install still fails after merge | Out-of-scope per non-goals — recorded in design.md Risks & Trade-offs as the next-change trigger. No proactive test at this layer. |

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 13 |
| Automated tests | 0 (no framework configured) |
| Manual test items | 13 |
| Preserved (@manual) | 0 |
| Edge case tests | 5 |
| Warnings | 0 |
