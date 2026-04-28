# Implementation Tasks: Add Codex Marketplace Catalog File

## 1. Foundation

- [ ] 1.1. Create `.agents/plugins/marketplace.json` at the repo root with the documented Codex schema:
  - top-level `name: "specshift"`, `interface.displayName: "SpecShift"`
  - `plugins` array with one entry: `name: "specshift"`, `description` (matching `.codex-plugin/plugin.json`'s description), `source: { "source": "local", "path": "../../.codex-plugin" }`, `policy: { "installation": "user-required", "authentication": "none" }`, `category: "Coding"`
  - no `version` field on the entry

## 2. Implementation

- [ ] 2.1. [P] Update `scripts/compile-skills.sh`:
  - add `CODEX_MARKETPLACE="$PLUGIN_ROOT/.agents/plugins/marketplace.json"` next to the existing path constants
  - extend the preflight `for f in ...` loop to require the catalog file
  - after the three `stamp_version` calls, add a `verify_catalog_shape` helper that uses `jq -e` to assert: top-level `name == "specshift"`, `interface.displayName` is a string, `plugins | length == 1`, `plugins[0].source.source == "local"`, `plugins[0].source.path | endswith(".codex-plugin")`, `plugins[0] | has("version") | not`
  - add the catalog file to the summary output
- [ ] 2.2. [P] Update `.github/workflows/release.yml`:
  - add a fourth entry to the cross-check loop tagged with a `shape-only` mode
  - in the shape-only branch, verify the file exists and `jq -e '.plugins | length == 1'` holds; skip the version-equality check
  - update the success log line to reflect "all four root files agree" / "catalog shape verified"
- [ ] 2.3. [P] Update `docs/decisions/adr-003-shopify-flat-multi-target-distribution.md`:
  - in `## Decision`, add a Decision 6 mandating `.agents/plugins/marketplace.json` with the documented Codex schema; cite the user-observed install failure as the falsifying observation
  - in `## Alternatives Considered`, rewrite the prior "Ship a `.agents/plugins/marketplace.json` catalog file" paragraph from a rejected alternative to a "decision history" note pointing forward to Decision 6
  - in `## Consequences > Negative`, add an entry covering "the maintainer must keep the catalog's `plugins[].source.path` aligned with `.codex-plugin/`'s repository-root location"
  - update the "Live install verification" Negative consequence: replace "deferred" with the concrete observation "verified post-merge by the user who reported the install failure"
- [ ] 2.4. [P] Update `README.md` Codex install section:
  - replace the `codex /plugins` block with the canonical two-step install (`codex plugin marketplace add github:fritze-dev/specshift` then `codex plugin install specshift`)
  - add an "Update" subsection mirroring Claude's, using `codex plugin marketplace update specshift && codex plugin update specshift`
  - keep both Installation subsections at the same heading level
- [ ] 2.5. [P] Update `AGENTS.md` File Ownership entry for `.codex-plugin/plugin.json`:
  - flip the "no separate Codex marketplace catalog file is shipped" sentence to acknowledge the catalog at `.agents/plugins/marketplace.json` with the documented Codex schema
  - mention that the catalog references `.codex-plugin/plugin.json` via `plugins[].source.path` and that the per-plugin manifest remains the version-bearing file
- [ ] 2.6. [P] Update `.specshift/CONSTITUTION.md` Architecture Rules paragraph that asserts the same "no catalog file" claim — same edit, mirroring AGENTS.md.

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
  - Catalog file exists with documented schema (jq probe) — PASS/FAIL
  - `bash scripts/compile-skills.sh` succeeds and lists four root files in summary — PASS/FAIL
  - `.github/workflows/release.yml` cross-check loop covers four files (one shape-only) — PASS/FAIL
  - Spec frontmatter `version: 5`, `lastModified: 2026-04-28` — PASS/FAIL (already done in specs phase)
  - ADR-003 has Decision 6 referencing the falsifying observation — PASS/FAIL
  - README Codex install section shows correct commands plus Update subsection — PASS/FAIL
  - AGENTS.md and CONSTITUTION.md no longer claim "no catalog file is shipped" — PASS/FAIL
- [ ] 3.2. Auto-Verify: generate audit.md using the audit template.
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval. (Skipped when auto_approve is true and audit verdict is PASS.)
- [ ] 3.4. Fix Loop: Classify each correction before fixing. Update all stale artifacts before re-implementing. Specs must match code before proceeding.
  - **Tweak**: wrong value/typo → fix in place
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks + re-implement
  - **Scope Change**: wrong requirements → update specs + design + re-implement fully
- [ ] 3.5. Final Verify: regenerate audit.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user. (Auto-skipped when audit verdict is PASS under auto_approve.)

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version (`src/VERSION`: `0.2.5-beta` → `0.2.6-beta`, then re-run `bash scripts/compile-skills.sh` to stamp into the three version-bearing root files; the catalog file is shape-checked in the same run)
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and `Closes #51`
- [ ] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`) — applies when change modifies files under `src/` or `.claude/skills/`
- Verify Codex install path: re-run `codex plugin marketplace add github:fritze-dev/specshift` and confirm the plugin is found and `codex plugin install specshift` succeeds (this is the live datum that closes issue #51's verification criterion)
