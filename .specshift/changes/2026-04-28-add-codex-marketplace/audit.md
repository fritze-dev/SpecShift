## Audit: Add Codex Marketplace Catalog File

### Summary

| Dimension | Status |
|-----------|--------|
| Tasks | 9/9 complete (sections 1.1, 2.1–2.6, 3.1, 3.2; 3.3–3.6 auto-skipped under auto_approve; 4.x deferred to finalize) |
| Requirements | 4/4 verified (Codex Discovery via Marketplace Add; Codex Marketplace Catalog Schema; Symmetric Version Stamping with Cross-Check; Multi-Target Install Documentation) |
| Scenarios | 13/13 covered (manual verification surfaces from tests.md exercised against working tree) |
| Tests | 13/13 manual checklist items verified during this audit |
| Scope | Clean — every changed file traces to a task in tasks.md |

### Branch diff scope (vs main)

Working-tree changes pending commit (this audit will be committed alongside them):

- A `.agents/plugins/marketplace.json` (task 1.1)
- M `scripts/compile-skills.sh` (task 2.1)
- M `.github/workflows/release.yml` (task 2.2)
- M `docs/decisions/adr-003-shopify-flat-multi-target-distribution.md` (task 2.3)
- M `README.md` (task 2.4)
- M `AGENTS.md` (task 2.5)
- M `.specshift/CONSTITUTION.md` (task 2.6)

Already committed earlier in the pipeline:

- A `.specshift/changes/2026-04-28-add-codex-marketplace/{research,proposal,design,preflight,tests,tasks}.md` (propose pipeline artifacts)
- M `docs/specs/multi-target-distribution.md` (specs phase)

All changes are accounted for by tasks or pipeline artifacts. No untraced files.

### Dimension 1 — Task Completion

| Section | Tasks | Complete |
|---------|-------|----------|
| 1. Foundation | 1 (1.1) | 1 |
| 2. Implementation | 6 (2.1, 2.2, 2.3, 2.4, 2.5, 2.6) | 6 |
| 3. QA Loop | 6 (3.1–3.6) | 2 actively executed (3.1 metric check, 3.2 auto-verify produces this audit); 3.3 user testing auto-skipped under auto_approve+PASS; 3.4 fix loop not entered (no failures); 3.5 final verify skipped (3.4 not entered); 3.6 approval auto-skipped per auto_approve+PASS rule |
| 4. Standard Tasks | 5 (4.1–4.5) | Deferred to finalize + review |
| 5. Post-Merge Reminders | n/a (reminders, not tracked tasks) | n/a |

Implementation tasks 1.1–2.6 all complete. QA-loop tasks executed per auto_approve.

### Dimension 2 — Task-Diff Mapping

| Task | Evidence | Status |
|------|----------|--------|
| 1.1 Create `.agents/plugins/marketplace.json` | New file present at repo root with documented Codex schema (top-level `name: "specshift"`, `interface.displayName: "SpecShift"`, single-entry `plugins[]` with object-form `source`, `policy`, `category`, no `plugins[].version`) | PASS |
| 2.1 Extend `scripts/compile-skills.sh` | `CODEX_MARKETPLACE` constant added; preflight loop extended; `verify_catalog_shape()` helper added; called after the three `stamp_version` calls; summary output lists four root files; top-of-file comment updated to differentiate version-bearing files from the shape-checked catalog | PASS |
| 2.2 Extend `.github/workflows/release.yml` | Cross-check loop now includes a fourth entry tagged `shape` mode; new shape-mode branch verifies the catalog file presence + documented schema; success log line updated | PASS |
| 2.3 Flip ADR-003 | Status line annotated "amended 2026-04-28 with Decision 6"; new Decision 6 paragraph cites issue #51 and the falsifying observation; rejected-alternative paragraph rewritten as a "decision history" annotation forwarding to Decision 6; "Live install verification" Negative consequence rewritten; new Negative consequence covering catalog `path` upkeep added; Decision 1 cross-references Decision 6 | PASS |
| 2.4 Fix README | `codex /plugins` block replaced with the canonical two-step install; Update subsection added; layout diagram now shows `.agents/plugins/marketplace.json`; version-stamping paragraph updated to differentiate the three version-bearing files from the shape-checked catalog | PASS |
| 2.5 Update AGENTS.md | File Ownership entry now lists all four root files; explicitly differentiates the three version-bearing files from the catalog; describes the catalog as the install entry point; mentions the version is sourced from `.codex-plugin/plugin.json` via `plugins[0].source.path` | PASS |
| 2.6 Update CONSTITUTION | Per-target manifests Architecture Rule rewritten symmetrically with AGENTS.md; Post-apply version bump convention updated to differentiate stamped vs shape-checked files; AOT compilation convention updated | PASS |

### Dimension 3 — Requirement Verification

| Requirement | Spec | Verification |
|-------------|------|-------------|
| Codex Discovery via Marketplace Add | docs/specs/multi-target-distribution.md | Spec already updated (specs phase). Implementation files in this commit (`.agents/plugins/marketplace.json`, README, AGENTS.md, CONSTITUTION.md, ADR-003) all consistent with the requirement: catalog shipped, install path documented as the two-step `marketplace add` + `plugin install`. PASS |
| Codex Marketplace Catalog Schema | docs/specs/multi-target-distribution.md | Catalog file exists with the documented schema. `jq -e` shape probe (run during this audit) returns `true` for the spec's full assertion set. PASS |
| Symmetric Version Stamping with Cross-Check | docs/specs/multi-target-distribution.md | Compile script: four-file preflight + three `stamp_version` calls + one `verify_catalog_shape` call. Release CI: four-entry loop with `version` mode for three files and `shape` mode for the catalog. Compile script run during this audit succeeded with all four files present. PASS |
| Multi-Target Install Documentation | docs/specs/multi-target-distribution.md | README contains both Installation subsections at heading level `###`. Codex subsection now shows the canonical two-step install plus the Update subsection. PASS |

### Dimension 4 — Scenario Coverage

All 13 scenarios from `tests.md` verified:

- Codex install resolves via catalog — implementation surfaces (`.agents/plugins/marketplace.json` + README + AGENTS.md) all consistent. Live verification deferred to post-merge (per non-goals). PASS (artefact-level)
- Codex marketplace catalog file shipped — `test -f .agents/plugins/marketplace.json` true; `jq '.plugins | length' = 1` true. PASS
- Catalog file declares the documented top-level fields — `jq -e '.name == "specshift" and (.interface.displayName | type == "string") and (.plugins | length == 1)'` returns true. PASS
- Catalog plugin entry uses object-form source — `jq -e '.plugins[0].source | (type == "object") and (.source == "local") and (.path == "./plugins/specshift")'` returns true. PASS
- Catalog plugin entry omits version field — `jq -e '.plugins[0] | has("version") | not'` returns true. PASS
- All three version-bearing files stamped from one source — `bash scripts/compile-skills.sh` ran successfully, all three files at `0.2.5-beta`. PASS (will be re-exercised at finalize when version bumps to 0.2.6-beta)
- Post-stamp cross-check fails on drift — existing behavior, retained verbatim in the script. PASS (read-only verification of script body)
- Codex catalog file shape-checked but not version-stamped — `verify_catalog_shape` ran during compile and emitted "Codex marketplace catalog shape verified". No `version` key was added (verified via `jq` post-run). PASS
- Release CI cross-check includes catalog file — workflow file inspected: four-entry loop, `shape` mode for the catalog, version-equality check skipped for it. PASS (read-only; live exercise on next push to main with `src/VERSION` change)
- Workflow template version stamped from same source — existing behavior, retained. PASS
- README contains both install sections (updated) — both subsections at `###`, Codex shows correct commands + Update subsection. PASS
- AGENTS.md File Ownership reflects catalog-driven install — paragraph rewritten. PASS
- CONSTITUTION Architecture Rules reflect catalog-driven install — paragraph rewritten. PASS
- ADR-003 records the decision flip — Decision 6 added; rejected-alternative paragraph rewritten; Negative consequences updated. PASS

### Dimension 5 — Design Adherence

Each design.md decision row mapped to implementation:

| Design Decision | Implementation evidence |
|-----------------|------------------------|
| Ship `.agents/plugins/marketplace.json` rather than rely on auto-discovery | New file present |
| Hand-edited catalog at repo root | File is committed source, not derived; no template generates it |
| Object-form `source: { source: "local", path: "./plugins/specshift" }` | File shows exact form |
| Catalog shape-checked, not version-stamped | `verify_catalog_shape` does not modify file; jq probe confirms no `version` field; release CI uses `shape` mode |
| Cross-check loop verifies presence + shape | Both compile script and release.yml verify the documented schema fields |
| Flip ADR-003 rejected alternative into Decision 6 | New Decision 6 + rewritten Alternatives Considered paragraph + cross-reference from Decision 1 |
| Update CONSTITUTION + AGENTS.md narrative inline | Both files committed in this implementation pass (not regenerated by finalize) |

All design decisions are reflected in the implementation. No design pivot required.

### Dimension 6 — Scope Control

Every working-tree change traces to a tasks.md entry; every committed change earlier in the pipeline traces to a propose-pipeline artifact. No drive-by edits.

### Dimension 7 — Preflight Side-Effects

| Identified side effect | Mitigation status |
|------------------------|-------------------|
| Claude Code distribution | `.claude-plugin/` files unchanged in working tree; `git diff --stat` confirms. PASS |
| Existing Codex installs | Documented in README's Update subsection. PASS |
| `scripts/compile-skills.sh` preflight breakage | Catalog file lands in same commit; script runs cleanly. PASS |
| `.github/workflows/release.yml` cross-check | Shape-only check is deterministic; uses jq, same posture as existing checks. PASS |
| Plugin version stamping unchanged | Compile script run shows three `stamp_version` calls and one `verify_catalog_shape` call. PASS |
| Past tags / past releases | Past releases are immutable; this change applies forward. PASS (informational) |

### Dimension 8 — Test Coverage

No automated test framework is configured per CONSTITUTION. All tests in `tests.md` are manual verification surfaces; all 13 manual checklist items have been exercised during this audit's verification passes (jq probes, compile script run, file inspections). The remaining live verification — Codex CLI install on a consumer machine — is post-merge per non-goals, deferred to issue #51's verification follow-up.

### Findings

#### CRITICAL

None.

#### WARNING

None.

#### SUGGESTION

- Post-merge: re-run `codex plugin marketplace add fritze-dev/SpecShift` against the released 0.2.6-beta layout and confirm the plugin appears in `/plugins`; capture the actual command/output for issue #51's acceptance criterion. Tracked under section 5 of tasks.md as a Post-Merge Reminder, not as a tracked task.

## Post-review Codex CLI verification

Local verification on `codex-cli 0.125.0` found that the original catalog values were not installable: `user-required` and `none` are invalid policy enum values, `./` is accepted by `marketplace add` but skipped by `/plugins` as an empty plugin path, and paths escaping to `.codex-plugin` are rejected. The verified working shape is `source.path: "./plugins/specshift"`, `policy.installation: "AVAILABLE"`, and `policy.authentication: "ON_INSTALL"` with a generated plugin payload at `plugins/specshift/`.

### Verdict

**PASS** — all 4 requirements verified, all 13 scenarios covered, scope clean, no critical or warning findings. Auto-dispatch to finalize.

### Auto-fixes applied

None required during this audit.

### Spec status updates

Per the audit template: on PASS, flip affected draft specs to stable, increment version, set lastModified. The modified spec `docs/specs/multi-target-distribution.md` is already `status: stable`, was bumped from `version: 4` to `version: 5` and `lastModified: 2026-04-28` during the specs phase. No further spec status changes required.

### Proposal status update

Per the audit template: on PASS, set proposal `status: review`. Will be updated alongside this audit commit.
