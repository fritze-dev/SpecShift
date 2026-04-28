---
has_decisions: true
---
# Technical Design: Add Codex Marketplace Catalog File

## Context

The user-observed install failure on `codex plugin marketplace add fritze-dev/SpecShift` falsifies the auto-discovery assumption underlying PR #46's distribution layout. The spec already describes the fallback (`.agents/plugins/marketplace.json` with the documented Codex schema) as a conditional. Local verification on `codex-cli 0.125.0` further showed that `/plugins` rejects root-path catalog entries, so this design realises the fallback as a concrete catalog file plus a generated `plugins/specshift/` payload and the necessary changes to keep build automation, CI, spec, ADR, README, AGENTS.md, and constitution self-consistent.

The change is packaging-only — no behavioral change to the SpecShift workflow or skill body. It touches the Codex distribution surface, the version-check loops in `scripts/compile-skills.sh` and `.github/workflows/release.yml`, and the documentary trail (spec, ADR, README, AGENTS.md, constitution).

## Architecture & Components

**New file**:

- `.agents/plugins/marketplace.json` — Codex marketplace catalog. Top-level: `name: "specshift"`, `interface.displayName: "SpecShift"`. `plugins` array with one entry: `name: "specshift"`, `description`, `source: { source: "local", path: "./plugins/specshift" }`, `policy: { installation: "AVAILABLE", authentication: "ON_INSTALL" }`, `category: "Coding"`. No `version` field on the entry — version is sourced from `plugins/specshift/.codex-plugin/plugin.json`.
- `plugins/specshift/` — generated Codex marketplace payload. Contains `.codex-plugin/plugin.json` copied from the stamped root Codex manifest and `skills/specshift/` copied from the compiled shared skill tree.

**Modified files**:

- `scripts/compile-skills.sh` — preflight loop adds `.agents/plugins/marketplace.json` to the required-files check. New `verify_catalog_shape()` helper validates the catalog's structure (top-level `name`, `interface.displayName`, `plugins[0].source.source` and `.path`, absence of `plugins[0].version`). The function is called once after the three `stamp_version` calls. Summary output adds the catalog file. Existing top-of-file comment (lines 6–9) already mentions four files — no comment churn needed.
- `.github/workflows/release.yml` — extends the for-entry loop with a fourth entry tagged `shape-only` so the loop body skips the version-equality assertion for the catalog and only verifies presence + shape (top-level keys + plugins-array length).
- `docs/specs/multi-target-distribution.md` — Requirement "Codex Discovery via Marketplace Add" flipped, new Requirement "Codex Marketplace Catalog Schema" added, scenarios under "Symmetric Version Stamping with Cross-Check" extended for the four-file loop, Edge Case "Codex auto-discovery semantics change" rewritten as "Codex marketplace catalog schema change", Assumption "Codex single-plugin auto-discovery" rewritten as "Codex catalog-driven install". (Already done during specs phase.)
- `docs/decisions/adr-003-shopify-flat-multi-target-distribution.md` — flip the rejected alternative ("Ship a `.agents/plugins/marketplace.json` catalog file") into an explicit Decision 6 capturing the falsifying observation and the new mandate.
- `README.md` — replace the wrong `codex /plugins` line with `codex plugin marketplace add fritze-dev/SpecShift` plus a `/plugins` install/enable instruction. Add Codex Update subsection: `codex plugin marketplace upgrade specshift`.
- `AGENTS.md` — File Ownership paragraph for `.codex-plugin/plugin.json` flips: now describes the catalog as the install entry point and the per-plugin manifest as the entry it references.
- `.specshift/CONSTITUTION.md` — Architecture Rules paragraph mirrors the AGENTS.md change.

**Unchanged**:

- `.claude-plugin/` (manifest + marketplace) — Claude install path unaffected.
- `.codex-plugin/plugin.json` — content unchanged; remains the version-bearing per-plugin manifest. The catalog references it via relative path.
- `src/skills/`, `src/templates/`, `src/actions/`, `src/VERSION` — skill body and version SoT untouched.
- `./skills/specshift/` — compiled skill tree unchanged.

## Goals & Success Metrics

- `.agents/plugins/marketplace.json` exists at the repo root with the documented Codex schema (top-level `name`, `interface.displayName`, `plugins[]` with object-form `source`, `policy`, `category`). Verifiable via `jq -e` shape probe in audit. **PASS/FAIL**.
- `scripts/compile-skills.sh` succeeds on a clean build, prints "Catalog file shape verified" (or equivalent), and the post-build summary lists four root files. **PASS/FAIL**.
- `.github/workflows/release.yml` cross-check loop includes `.agents/plugins/marketplace.json` with shape-only verification. Verifiable by reading the workflow file. **PASS/FAIL**.
- `docs/specs/multi-target-distribution.md` no longer asserts "shall not ship catalog"; it now mandates the catalog. Spec frontmatter `version` bumped from 4 to 5; `lastModified: 2026-04-28`. (Done in specs phase.) **PASS/FAIL**.
- ADR-003 Decision 6 entry exists and references the falsifying observation; the rejected-alternative paragraph either is removed or is rewritten into a "decision history" note. **PASS/FAIL**.
- `README.md` Codex install section shows the correct two-step install (marketplace add + plugin install) plus an Update subsection. **PASS/FAIL**.
- `AGENTS.md` and `.specshift/CONSTITUTION.md` no longer claim "no separate Codex marketplace catalog file is shipped". **PASS/FAIL**.
- All four root files cross-check passes in CI for the next push to `main` that bumps `src/VERSION`. **PASS/FAIL** (verifiable at finalize-time when the version bump runs through compile-skills.sh).

## Non-Goals

- Live Codex CLI smoke test on a separate install machine. The user-observed install failure is the live datum driving this change; a follow-up smoke test is not gating.
- Changing the Claude Code install path or marketplace schema.
- Renaming, splitting, or restructuring the plugin or its skill tree.
- Adding `policy.installation` / `policy.authentication` enforcement beyond the documented baseline values.
- Adding `plugins[].version` to the catalog (the documented Codex schema does not have this field; adding it would diverge from the schema and is the wrong response to the cross-check requirement).
- Auto-generating the catalog file from the per-plugin manifest. The catalog is a hand-edited per-target file, like `.claude-plugin/marketplace.json` is for Claude.

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Ship `.agents/plugins/marketplace.json` rather than rely on auto-discovery | User-observed install failure on the released layout; spec already pre-described this fallback | Wait for Codex CLI bug fix (no actionable artifact, blocks user); switch to a different distribution channel (over-engineering) |
| Hand-edited catalog at the repo root, not generated from `.codex-plugin/plugin.json` | Symmetry with `.claude-plugin/marketplace.json`; per-target metadata stays per-target; only `version` is automated | Auto-generate from manifest (couples two files; complicates schema drift handling) |
| Catalog entry uses `source: { source: "local", path: "./plugins/specshift" }` | Verified working with Codex app-server `/plugins` resolution; Codex rejects empty/root paths and paths escaping the marketplace root | `source: "../../.codex-plugin"` (outside marketplace-root rules), `source: "./"` (rejected as empty), bare-string source (Claude marketplace form, not Codex's) |
| Catalog file is shape-checked, not version-stamped, in compile + CI | Documented Codex schema does not include `plugins[].version`; adding one would break consumers | Stamp an invented version field (schema divergence); skip the catalog from the loop entirely (regression risk on accidental delete) |
| Cross-check loop verifies catalog presence + shape (top-level keys + plugins-array length + source object form) | Catches the high-impact failure modes (file deleted; shape mangled by editor; wrong source form); minimal jq invocations | Full schema validation against an external JSON schema (over-engineering for a 5-field file) |
| Flip ADR-003 rejected alternative into Decision 6 with the falsifying observation recorded inline | Keeps decision history honest and discoverable; future maintainers see why the decision changed | Silently delete the rejected alternative paragraph (loses decision history); add a separate ADR (over-formal for a packaging fix to an existing decision) |
| Update CONSTITUTION + AGENTS.md narrative inline rather than via finalize doc-regen | Both files are hand-edited under the project rules ownership table; finalize regenerates derived docs (capabilities/), not these | Defer to finalize (would not work — these files are sources of truth, not derived) |

## Risks & Trade-offs

- **Catalog `path` resolves wrong on consumer machines** → Mitigation: use `./plugins/specshift`, a non-empty path under the marketplace root verified with `codex-cli 0.125.0` and app-server `plugin/install`. The compile script and CI assert the path and generated payload files.
- **Codex CLI documented schema differs subtly from what's actually accepted** → Mitigation: catalog is hand-edited; if a future Codex CLI version requires schema tweaks, edit the file directly. The compile script preserves any field present in the file beyond the documented schema verbatim.
- **Compile script changes break Claude-only consumers** → Mitigation: changes are purely additive (one extra preflight check, one extra shape verification); existing three stamp calls are untouched. Audit verifies the script still completes cleanly on a build that already has all four files in place.
- **CI workflow change introduces a flaky failure** → Mitigation: the new entry uses shape-only verification (no version equality check), so it can only fail on absence/malformed JSON — both deterministic conditions.
- **Spec/ADR narrative drift from CONSTITUTION/AGENTS.md** → Mitigation: this change updates all four narrative surfaces in one commit pass. Audit's traceability check confirms each narrative source agrees with the spec.

## Migration Plan

No consumer-side migration required. Existing Claude Code installs are unaffected. New Codex installs that previously failed will now succeed by re-running `codex plugin marketplace add fritze-dev/SpecShift`, then installing or enabling SpecShift from `/plugins`. Codex consumers who had an aborted/partial install from the previous release should re-run the add command after this change is merged.

The plugin version bumps from `0.2.5-beta` to `0.2.6-beta` at finalize time (per the constitution's post-apply patch-bump convention). The release workflow will create the `v0.2.6-beta` tag automatically when `src/VERSION` lands on `main`.

## Open Questions

No open questions.

## Assumptions

- The Codex marketplace catalog schema documented at https://developers.openai.com/codex/plugins/build is authoritative for the `name`, `interface.displayName`, `plugins[].source: {source, path}`, `plugins[].policy`, `plugins[].category` fields used by this design. <!-- ASSUMPTION: Codex catalog schema authoritative -->
- The `policy.installation` baseline value `"AVAILABLE"` and `policy.authentication` baseline value `"ON_INSTALL"` are the accepted values for `codex-cli 0.125.0`. <!-- ASSUMPTION: Codex policy defaults -->
- Relative paths in `plugins[].source.path` are resolved from the marketplace root and must stay within it; root/empty paths are skipped by `/plugins`, so the catalog uses `./plugins/specshift`. <!-- ASSUMPTION: Codex relative-path resolution -->
- A re-run of `codex plugin marketplace add fritze-dev/SpecShift` after this change lands on `main` will succeed for the user who reported the original failure. <!-- ASSUMPTION: Catalog file unblocks install -->
