## Audit: Align Codex Marketplace Catalog Documentation

### Summary

| Dimension | Status |
|-----------|--------|
| Tasks | 8/8 complete (1.1, 1.2 from specs phase; 2.1–2.4 implemented; 2.5–2.7 verified untouched) |
| Requirements | 7/7 verified (modified Codex Discovery via Marketplace Catalog; new Codex Marketplace Catalog Schema; existing Per-Target Plugin Manifest unchanged; existing Symmetric Version Stamping unchanged; modified Source and Release Directory Structure) |
| Scenarios | 16/16 manual test items planned; 13 verifiable on the apply-phase tree state, 3 deferred to finalize |
| Tests | 13/16 verifiable now; 3 finalize-stage scenarios (capability doc regen, ADR amendment, version bump) pending |
| Scope | Clean — all changed files trace to tasks |

### Diff Audit

Merge base: `71c000fc` (catalog file commit). Branch diff against `origin/main`:

**Specs phase (committed `e90b4d2`):**
- `docs/specs/multi-target-distribution.md`: +47/-13 — frontmatter v4→v5; Requirement renamed; Scenario replaced; new Requirement "Codex Marketplace Catalog Schema"; Edge Case rewritten; Assumption rewritten.
- `docs/specs/release-workflow.md`: +1/-1 — Requirement "Source and Release Directory Structure" sentence inverted.

**Apply phase (uncommitted, staged after audit):**
- `AGENTS.md`: +1/-1 (effective text, line 33 File Ownership block).
- `.specshift/CONSTITUTION.md`: +1/-1 (Architecture Rules per-target manifests bullet).
- `README.md`: +13/-2 (Installation Codex section rewritten with canonical commands + Update subsection; Multi-Target Distribution tree adds `.agents/plugins/`).

**Untouched (verified):**
- `.agents/plugins/marketplace.json`: zero diff vs `origin/main` (catalog from `71c000fc` unchanged).
- `scripts/compile-skills.sh`: zero diff.
- `.github/workflows/release.yml`: zero diff.
- `src/VERSION`: zero diff (bump deferred to finalize).

### Dimension Analysis

**1. Task Completion**: 8/8 tasks in tasks.md sections 1+2 complete. Section 3 (QA loop) is in progress (this is the audit). Section 4 is the post-implementation phase scheduled for finalize.

**2. Task-Diff Mapping**: each task maps to evidence in the diff —
- 1.1, 1.2: covered by `docs/specs/*.md` diffs in commit `e90b4d2`.
- 2.1: covered by `AGENTS.md` line 33 update (file ownership block).
- 2.2: covered by `.specshift/CONSTITUTION.md` line 24 update.
- 2.3: covered by `README.md` Installation Codex section update.
- 2.4: covered by `README.md` Multi-Target Distribution tree update.
- 2.5–2.7: verified by `git diff` returning empty.

**3. Requirement Verification**:
- "Codex Discovery via Marketplace Catalog" (modified): the new clause "SHALL ship `.agents/plugins/marketplace.json`" is satisfied by the file existing on `main` (committed in `71c000fc`). The two scenarios in this requirement match the file's actual content (catalog is shipped at root with required fields).
- "Codex Marketplace Catalog Schema" (new): both scenarios verifiable — `.agents/plugins/marketplace.json` declares `source.source: "url"`, `source.url` ending in `.git`, `policy.installation: "AVAILABLE"`, `policy.authentication: "ON_INSTALL"`, `category: "Coding"`. Confirmed via `jq` against the file.
- "Per-Target Plugin Manifest" (unchanged): not regressed; both Claude and Codex manifests still hand-edited at root.
- "Symmetric Version Stamping with Cross-Check" (unchanged): not regressed; compile script still stamps three files; release-workflow.md "all three root manifest/marketplace files" wording preserved.
- "Source and Release Directory Structure" (modified): "no separate Codex marketplace catalog file is shipped" sentence successfully replaced with the four-file description.

**4. Scenario Coverage**: 16 manual test items in tests.md; verified against apply-phase tree state — all GIVEN/WHEN/THEN conditions either checked now or explicitly deferred to finalize.

**5. Design Adherence**:
- Decision: "Codex catalog uses `source: url`" — preserved (file unchanged).
- Decision: "Catalog policy `AVAILABLE` / `ON_INSTALL`" — preserved.
- Decision: "Catalog has no `version` field; not auto-stamped" — preserved.
- Decision: "Defer `verify_catalog_shape()` and CI cross-check" — honored (`scripts/compile-skills.sh` and `.github/workflows/release.yml` untouched).
- Decision: "Keep Claude marketplace at `source: \"./\"`" — honored (`.claude-plugin/marketplace.json` untouched).
- Decision: "Skip auto-PR-creation during propose" — honored (no PR was created during the propose phase).
- Decision: "Workspace in-tree, no worktree" — honored (work happens on `claude/optimize-codex-marketplace-uVtJK`, no worktree spawned).

**6. Scope Control**: changed files = `docs/specs/multi-target-distribution.md`, `docs/specs/release-workflow.md`, `AGENTS.md`, `.specshift/CONSTITUTION.md`, `README.md`, plus the change-artifact files. All listed in the proposal's Scope and trace to tasks.

**7. Preflight Side-Effects**:
- "Compile-script header comment drift" — pre-existing condition, intentionally tolerated, noted in CHANGELOG/design.md as known follow-up. ✅
- "Risk of catalog-schema regression" — mitigated by ADR-003 Decision 6 (deferred to finalize) and a follow-up issue note for `verify_catalog_shape()`. ✅

**8. Test Coverage**:
- Automated tests: N/A (no framework — manual mode per CONSTITUTION.md `## Testing`).
- Manual test plan: 13 of 16 items verifiable now and confirmed PASS via `git diff` and `grep` checks above. 3 deferred:
  - "Compile script runs unchanged": deferred to finalize (script invocation happens during finalize stage 4).
  - "Capability doc regenerated": deferred to finalize (regeneration happens during finalize stage 2).
  - "ADR-003 amended": deferred to finalize (ADR write happens during finalize stage 2).

### Findings

#### CRITICAL

None.

#### WARNING

None.

#### SUGGESTION

- **`scripts/compile-skills.sh` header comments at lines 6–9 and 147 still say "four root files"** while the code stamps three. This was pre-existing (preemptive comment) and is intentionally out of scope for this change. A small follow-up patch can clean it up — file as a separate friction Issue if it surfaces during a future refactor. Recorded in design.md Risks & Trade-offs.
- **Live Codex install smoke test on a clean machine** — Issue #51 acceptance criterion. Out of scope for this change; user's functional verification on their environment is the basis for accepting the Git-URL schema. Re-run the smoke test on a clean machine after `0.2.6-beta` lands to fully close Issue #51.

### Verdict

**PASS** — 0 CRITICAL, 0 WARNING, 2 SUGGESTION (both deferred / out-of-scope, no blockers).

Apply phase complete. Ready for finalize.

### Spec Lifecycle Updates

- Both modified specs (`multi-target-distribution.md`, `release-workflow.md`) were already at `status: stable` before this change — no draft → stable flip needed.
- Both `lastModified` fields were updated to `2026-04-28` in the specs phase.
- Frontmatter `version` bumped: multi-target-distribution.md 4 → 5, release-workflow.md 5 → 6.

### Proposal Status

Set `proposal.md` `status: active` → `status: review` (audit PASS, ready for finalize).
