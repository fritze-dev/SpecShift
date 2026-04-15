# Tests: fix-version-drift

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) — plugin is Markdown/YAML artifacts |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### release-workflow

#### Changelog Version Headers

- [ ] **Scenario: Single change produces versioned header**
  - Setup: A completed change is finalized with `plugin.json` version `0.2.3-beta`
  - Action: `specshift finalize` generates the changelog entry
  - Verify: Header is `## [v0.2.3-beta] — 2026-04-15` with change title as `### ` sub-header

- [ ] **Scenario: release.yml extracts versioned block correctly**
  - Setup: CHANGELOG.md has `## [v0.2.3-beta] — 2026-04-15` as the first entry with content and `### ` sub-headers
  - Action: Run `sed -n '/^## /{p;:a;n;/^## /q;p;ba}' CHANGELOG.md`
  - Verify: Output captures the entire `## [v0.2.3-beta]` block including all `### ` sub-headers up to the next `## ` header

- [ ] **Scenario: Multi-change version groups entries under one header**
  - Setup: Two orphan changelog entries exist between v0.2.1-beta and v0.2.2-beta
  - Action: Consolidate under `## [v0.2.2-beta] — 2026-04-15`
  - Verify: Both changes appear as separate `### ` sub-headers under the single version header

#### Generate Changelog from Completed Changes

- [ ] **Scenario: Existing changelog preserved**
  - Setup: CHANGELOG.md has existing version-headered entries
  - Action: Add new entry at top
  - Verify: All existing entries remain unchanged

#### Automated GitHub Release via CI

- [ ] **Scenario: Release created after version bump push**
  - Setup: Push to main with new version in `plugin.json` and versioned CHANGELOG header
  - Action: GitHub Actions workflow triggers
  - Verify: Release body matches the first `## [version]` block from CHANGELOG

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 5 |
| Automated tests | 0 |
| Manual test items | 5 |
| Preserved (@manual) | 0 |
| Edge case tests | 0 |
| Warnings | 0 |
