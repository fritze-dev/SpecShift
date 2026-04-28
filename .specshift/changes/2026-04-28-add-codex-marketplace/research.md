# Research: Add Codex Marketplace Catalog File

## 1. Current State

PR #46 (merged as 5fe9d66, "Multi-Target Distribution") shipped Codex CLI plugin support based on the documented Codex auto-discovery pattern. The current state is:

- `.codex-plugin/plugin.json` exists at the repository root, hand-edited, containing the Codex `interface` block (`displayName`, `shortDescription`, `category`, etc.).
- `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` exist for Claude Code.
- The shared compiled skill tree lives at `./skills/specshift/`.
- `scripts/compile-skills.sh` stamps `src/VERSION` into three files: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`. (The compile script's header comment at line 8 already mentions `.agents/plugins/marketplace.json` — aspirational, the code does not currently touch that path.)
- `.github/workflows/release.yml` cross-checks the same three files at push-to-main.
- `docs/specs/multi-target-distribution.md` (Requirement "Codex Discovery via Marketplace Add") explicitly forbids shipping `.agents/plugins/marketplace.json` and asserts auto-discovery is the supported path. ADR-003 records the rejected-alternative reasoning.
- `README.md` Codex install section currently shows `codex /plugins`, which is the in-session browse command, not the install command (also flagged in issue #51).
- `AGENTS.md` File Ownership section states "Codex consumers install via `codex plugin marketplace add github:fritze-dev/specshift` which auto-discovers `.codex-plugin/plugin.json` — no separate Codex marketplace catalog file is shipped."

The user has now reported (issue #51 origin and the current request) that running `codex plugin marketplace add github:fritze-dev/specshift` does not find the plugin. This falsifies the auto-discovery assumption captured in `multi-target-distribution.md` Assumptions section ("Codex single-plugin auto-discovery"). Issue #51 acceptance criterion branch (b) applies: ship `.agents/plugins/marketplace.json`.

## 2. External Research

The Codex plugin documentation at https://developers.openai.com/codex/plugins/build documents the marketplace catalog file schema. Per ADR-003 "Alternatives Considered" and `multi-target-distribution.md` Requirement "Codex Discovery via Marketplace Add" (the conditional fallback paragraph), the documented schema fields are:

- Top-level: `name`, `interface.displayName`
- Per-plugin entries: `plugins[].source: { source, path }` (object form, not bare string), `plugins[].policy` (object with `installation`, `authentication`), `plugins[].category`

Distinct from the Claude marketplace schema, which uses `owner.name`, `metadata.description`, `plugins[].source` as a bare string, and `plugins[].version`. The Codex schema does not carry a `plugins[].version` field — version comes from the per-plugin manifest (`.codex-plugin/plugin.json`).

The Shopify-AI-Toolkit reference repository (used during PR #46) does not ship `.agents/plugins/marketplace.json`. Either Shopify has a different install path, or single-plugin auto-discovery genuinely works for them but not for SpecShift, or their flow is verified on a private/internal Codex build. The user-observed failure for fritze-dev/specshift is the authoritative datum for this change.

The `developers.openai.com/codex/plugins/build` URL was not fetchable from the build environment (host not in allowlist), so the schema reference relied on already-collected documentary excerpts in `multi-target-distribution.md` and ADR-003's rejected-alternative paragraph (which explicitly enumerated the schema).

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| Ship `.agents/plugins/marketplace.json` with the documented schema; keep `.codex-plugin/plugin.json`; flip spec + ADR | Direct response to user-observed failure; one new file + edits to spec/ADR/README/AGENTS.md/scripts/CI; symmetric with Claude marketplace; future multi-plugin growth already covered | Adds a fourth root file to keep version-symmetric; spec + ADR-003 rejected-alternative paragraph must be flipped (small doc churn) |
| Investigate Codex CLI version differences before adding the file | Avoids "extra file we may not need" | The user cannot install today; spec already documents this fallback; the file is cheap and the schema is known — investigating buys nothing actionable |
| Restructure to multi-plugin layout with subfolders | Gives a future-proofing argument for the catalog | Massive over-engineering for a one-plugin repo; contradicts current `src/skills/specshift/` layout |

Selected approach: ship `.agents/plugins/marketplace.json` with the documented schema, version-stamp it as a fourth file, flip the spec and ADR to mandate it, and correct the README + AGENTS.md narrative.

## 4. Risks & Constraints

- **Codex schema drift**: the official Codex schema may evolve. Mitigation: jq-stamp only `version` if the schema gains a per-plugin version field; preserve all other keys verbatim. The current schema does not have `plugins[].version`, so initially nothing is stamped into this file — but the cross-check still verifies `.codex-plugin/plugin.json` and the new catalog reference each other consistently.
- **Live install verification**: per issue #51, an acceptance criterion is a live smoke test. Out of scope per user instruction (the user is the live datum — the failure they observed is what we are responding to). If the catalog file alone does not unblock install on the next attempt, that is a follow-up change, not a blocker for this one.
- **Backward compatibility for Claude install**: none — this change only touches the Codex distribution surface plus the spec/ADR/README narrative. Claude marketplace and skill tree are untouched.
- **`scripts/compile-skills.sh` and `.github/workflows/release.yml`**: must add a fourth entry to the stamp + cross-check loops. Both files currently iterate over a hardcoded list of three; the addition is mechanical (one extra `stamp_version` call, one extra entry in the CI loop). Header comment at line 8 of the compile script already mentions four files — bringing implementation into agreement with that comment.
- **Codex catalog `plugins[].version` field absence**: since the documented Codex catalog schema does not include `plugins[].version`, the cross-check on this file is a presence-and-shape check, not a version equality check. Distinct from the other three files.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Add catalog file, flip spec/ADR, fix README/AGENTS.md, extend compile script + CI cross-check |
| Behavior | Clear | New file shape is defined by Codex's documented schema and pre-existing spec text |
| Data Model | Clear | JSON object: top-level `name` + `interface.displayName`; `plugins[]` with `source: {source, path}`, `policy`, `category` |
| UX | Clear | Codex consumer runs `codex plugin marketplace add github:fritze-dev/specshift` and `codex plugin install specshift` — same install path the spec already documented |
| Integration | Clear | Compile script + release CI both need a fourth entry; everything else is doc edits |
| Edge Cases | Clear | The compile script preserves non-version keys; absence of `plugins[].version` in the catalog means cross-check is shape-only for that file |
| Constraints | Clear | Per-target manifests stay hand-edited; only `version` and per-target metadata are touched by automation |
| Terminology | Clear | "Codex marketplace catalog file" = `.agents/plugins/marketplace.json` (Codex's term); "per-plugin manifest" = `.codex-plugin/plugin.json` |
| Non-Functional | Clear | No runtime cost; build adds one jq read per release |

## 6. Open Questions

All categories Clear — no questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Ship `.agents/plugins/marketplace.json` with the Codex-documented schema | User-observed install failure falsifies the auto-discovery assumption; spec already pre-documented this fallback path; one-file fix | Investigate Codex version (no actionable artifact); restructure to multi-plugin (over-engineering) |
| 2 | Add the catalog file to compile-script stamping + CI cross-check, but as a shape check only (no `plugins[].version` field in the documented schema) | The catalog references the per-plugin manifest by `source.path`, not by a redundant version copy; preventing presence-only drift still catches "file deleted" or "shape mangled" foot-guns | Stamp a `plugins[].version` we invent ourselves (would diverge from documented schema and break Codex consumers) |
| 3 | Flip ADR-003's rejected alternative ("Ship a `.agents/plugins/marketplace.json` catalog file") into the accepted decision and record the falsifying user observation | Keep ADR honest about decision history; future maintainers should see why the decision changed | Leave ADR-003 untouched (silent reversal is worse than recorded reversal) |
| 4 | Tighten the spec's conditional language (drop "only if multi-plugin or policy/ordering") and mandate the catalog | The conditional was speculative; the user's report is observational evidence | Keep conditional alongside catalog (creates ambiguity about whether the catalog is required) |
| 5 | Out of scope: live smoke test on a real Codex install machine | The user's failed-install report IS the live datum; gating on a separate smoke test machine adds delay without information | Block on smoke test (defers user unblock indefinitely) |
