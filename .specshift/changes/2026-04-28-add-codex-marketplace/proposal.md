---
status: review
branch: claude/add-codex-marketplace-SATku
capabilities:
  new: []
  modified: [multi-target-distribution]
  removed: []
---

## Why

The Codex install path documented in the spec (`codex plugin marketplace add github:fritze-dev/specshift`) does not find the plugin in practice — a user reported the failure on PR #46's merged distribution. This falsifies the "Codex single-plugin auto-discovery" assumption baked into `multi-target-distribution.md` and ADR-003 and leaves Codex consumers unable to install. Issue #51's acceptance branch (b) is the response: ship the documented `.agents/plugins/marketplace.json` catalog file, flip the spec and ADR to mandate it, and correct the README/AGENTS.md narrative.

## What Changes

- **NEW** `.agents/plugins/marketplace.json` at the repository root, hand-edited, populated with the Codex-documented schema (`name`, `interface.displayName`, `plugins[].source: { source: "local", path: "../../.codex-plugin" }`, `plugins[].policy`, `plugins[].category`).
- **MODIFIED** `scripts/compile-skills.sh` extends the stamp + cross-check loop to four files (`.agents/plugins/marketplace.json` is shape-checked, not version-stamped, since the documented Codex catalog schema does not include `plugins[].version`). The compile script's existing line-8 header comment already mentions four files; this brings the implementation into agreement.
- **MODIFIED** `.github/workflows/release.yml` adds the catalog file to the cross-check loop with the same shape-only behavior.
- **MODIFIED** `docs/specs/multi-target-distribution.md` Requirement "Codex Discovery via Marketplace Add" — drop the "no `.agents/plugins/marketplace.json` shipped" assertion, mandate the catalog instead. Update the "No Codex marketplace catalog file shipped" scenario into "Codex marketplace catalog file shipped". Update the related Edge Case ("Codex auto-discovery semantics change") and Assumption ("Codex single-plugin auto-discovery") to reflect the falsification. Add a new Requirement "Codex Marketplace Catalog Schema" that pins the file's shape. Add scenarios under "Symmetric Version Stamping with Cross-Check" covering the four-file loop and the catalog's shape-only check.
- **MODIFIED** `docs/decisions/adr-003-shopify-flat-multi-target-distribution.md` — flip the rejected alternative ("Ship a `.agents/plugins/marketplace.json` catalog file") into a Decision-6 entry and record the user-observed falsification. Add a Negative consequence covering "the maintainer must keep the catalog's `plugins[].source.path` aligned with `.codex-plugin/`'s location".
- **MODIFIED** `README.md` — replace the wrong `codex /plugins` line with the canonical `codex plugin marketplace add github:fritze-dev/specshift` + `codex plugin install specshift`. Add a Codex "Update" subsection mirroring Claude's.
- **MODIFIED** `AGENTS.md` File Ownership — flip the "no separate Codex marketplace catalog file is shipped" sentence to acknowledge the catalog now exists, sourced via the documented schema.
- **MODIFIED** `.specshift/CONSTITUTION.md` Architecture Rules paragraph mirrors AGENTS.md update.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `multi-target-distribution`: Requirement "Codex Discovery via Marketplace Add" flips from "do not ship catalog" to "ship catalog with documented schema". A new Requirement "Codex Marketplace Catalog Schema" pins the file's shape. Scenarios under "Symmetric Version Stamping with Cross-Check" extend the loop from three files to four, with the catalog file under shape-only verification. The corresponding Edge Case and Assumption are updated to record the falsification.

### Removed Capabilities

None.

### Consolidation Check

1. Existing specs reviewed: `multi-target-distribution.md` (the only spec describing per-target distribution surfaces) — confirmed the change belongs inside this spec, not as a new capability. All other specs (`workflow-contract`, `quality-gates`, `release-workflow`, `documentation`, `project-init`, etc.) are unrelated to the Codex install path.
2. Overlap assessment: no new capabilities proposed; the change adds requirements to an existing capability.
3. Merge assessment: N/A — single existing capability modified, no new capabilities to merge.

## Impact

- **Code**: `scripts/compile-skills.sh` (extend version stamp + cross-check loop), `.github/workflows/release.yml` (extend cross-check loop).
- **Distribution**: NEW root file `.agents/plugins/marketplace.json`. Codex consumers that previously failed to install will now succeed via `codex plugin marketplace add github:fritze-dev/specshift` because the catalog file is present.
- **Specs**: `docs/specs/multi-target-distribution.md` (modified — Requirement flip + new Requirement + scenario updates + edge case + assumption).
- **ADR**: `docs/decisions/adr-003-shopify-flat-multi-target-distribution.md` (modified — flip rejected alternative to Decision 6).
- **Docs**: `README.md` (Codex install + Codex update sections), `AGENTS.md` File Ownership, `.specshift/CONSTITUTION.md` Architecture Rules.
- **Dependencies**: none (jq already required by the compile script).
- **Versioning**: this is a packaging fix for the existing `0.2.5-beta` distribution; finalize will bump to `0.2.6-beta`.

## Scope & Boundaries

**In scope**:
- Add `.agents/plugins/marketplace.json` with the documented Codex schema.
- Extend `scripts/compile-skills.sh` and `.github/workflows/release.yml` to include the new file in the cross-check (shape-only — no `plugins[].version` field).
- Flip Requirement "Codex Discovery via Marketplace Add" + add new Requirement "Codex Marketplace Catalog Schema" in `docs/specs/multi-target-distribution.md`; update related scenarios, Edge Case, and Assumption.
- Flip ADR-003's rejected alternative into Decision 6 and record the falsifying observation.
- Fix README install/update commands for Codex.
- Update AGENTS.md File Ownership and `.specshift/CONSTITUTION.md` Architecture Rules paragraph that asserts "no catalog file is shipped".

**Out of scope** (non-goals):
- Live smoke test on a separate Codex install machine — the user's failed-install report is the live datum driving this change.
- Any change to the Claude Code distribution surface (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, install path).
- Renaming, restructuring, or splitting the plugin or its skill tree.
- Bumping plugin features or workflow behavior — this change is packaging-only.
- Adding `policy.installation` / `policy.authentication` enforcement beyond the documented baseline; the catalog ships with policy fields present at the documented baseline values.
