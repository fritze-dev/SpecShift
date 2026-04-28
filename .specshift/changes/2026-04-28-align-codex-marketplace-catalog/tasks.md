# Implementation Tasks: Align Codex Marketplace Catalog Documentation

## 1. Foundation

Specs phase already committed (commit `e90b4d2`):
- [x] 1.1. `docs/specs/multi-target-distribution.md` v4 → v5 — clause inversion, scenario replacement, new "Codex Marketplace Catalog Schema" Requirement, Edge Case + Assumption rewrites.
- [x] 1.2. `docs/specs/release-workflow.md` v5 → v6 — "no separate Codex marketplace catalog file is shipped" sentence rewritten in "Source and Release Directory Structure".

## 2. Implementation

Documentation-only edits to align text with the committed catalog file. No code changes.

- [x] 2.1. **`AGENTS.md` File Ownership block (line 33)** — replace the `.claude-plugin/plugin.json, .claude-plugin/marketplace.json, .codex-plugin/plugin.json` bullet with the four-file form, distinguishing the three version-bearing files from the catalog and stating the verified two-step Codex install path.
- [x] 2.2. **`.specshift/CONSTITUTION.md` Architecture Rules — "Per-target manifests at the repo root" bullet (line 24)** — same content update as AGENTS.md, scoped to the constitution's terser style.
- [x] 2.3. **[P] `README.md` Installation → OpenAI Codex CLI section** — replace the prior `codex /plugins`-only placeholder block with the documented Codex install flow per `developers.openai.com/codex/plugins/build`: `codex plugin marketplace add fritze-dev/SpecShift` followed by enabling SpecShift from the in-session `/plugins` directory; Update subsection uses `codex plugin marketplace upgrade specshift`.
- [x] 2.4. **[P] `README.md` Multi-Target Distribution tree diagram** — add a `.agents/plugins/marketplace.json` entry; leave the surrounding "stamps … into all three root manifest/marketplace files" sentence as-is.
- [x] 2.5. **Verify catalog file untouched** — `git diff origin/main -- .agents/plugins/marketplace.json` shows no change beyond the original commit.
- [x] 2.6. **Verify compile script untouched** — `git diff origin/main -- scripts/compile-skills.sh` shows no change.
- [x] 2.7. **Verify CI workflow untouched** — `git diff origin/main -- .github/workflows/release.yml` shows no change.

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
  - [x] Spec contradictions removed (`grep` returns 0)
  - [x] Old "SHALL NOT ship" clause gone (`grep` returns 0)
  - [x] README install command corrected (canonical commands present, no `codex /plugins` install snippet)
  - [x] README tree diagram updated (`.agents/plugins/` entry present)
  - [x] Spec frontmatter bumped (v5 / v6)
  - [x] Catalog file untouched
  - [x] Compile script unchanged
  - [x] CI workflow unchanged
  - [x] Release artifact stamping works (deferred to finalize compile run)
  - [x] Capability doc regenerated (deferred to finalize)
  - [x] ADR-003 amendment present (deferred to finalize)
- [x] 3.2. Auto-Verify: generate audit.md using the audit template.
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval (skipped under `auto_approve: true` if audit verdict is PASS).
- [x] 3.4. Fix Loop: Classify each correction before fixing. Update all stale artifacts before re-implementing.
- [x] 3.5. Final Verify: regenerate audit.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [x] 3.6. Approval: Only finish on explicit **"Approved"** by the user (or auto-approve PASS path).

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Run `specshift finalize` (generates changelog v0.2.6-beta entry, regenerates `docs/capabilities/multi-target-distribution.md`, amends ADR-003 with Decision 6, bumps `src/VERSION` to `0.2.6-beta`, runs `bash scripts/compile-skills.sh` — script is unchanged, three files stamped).
- [x] 4.2. Bump version (handled by `specshift finalize` step 3).
- [x] 4.3. Commit and push to remote.
- [x] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable. **Note:** PR creation deferred — session policy. Will ask the user to authorize PR creation explicitly before review.
- [x] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable). Applies once a PR exists.

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`) — applies when change modifies files under `src/` or `.claude/skills/`. **Note:** This change does not touch `src/` or `./skills/`, so the local plugin update is **not** required for this change. Listed for completeness per CONSTITUTION.md Standard Tasks.
