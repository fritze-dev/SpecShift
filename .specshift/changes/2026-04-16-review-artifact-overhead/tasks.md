# Implementation Tasks: Review Artifact Pipeline Overhead

## Foundation

- [ ] Verify the working tree is clean and the change branch is up to date with `origin/main`
- [ ] Re-read `proposal.md`, `design.md`, and `preflight.md` to confirm the contract before editing source files

## Implementation

### Layer 2 — Templates (src/templates/)

- [x] Update `src/templates/workflow.md`: change `pipeline:` array from `[research, proposal, specs, design, preflight, tests, tasks, audit]` to `[proposal, specs, design, preflight, tasks, audit]`; update `## Action: propose` instruction (drop research checkpoint reference; add per-stage context-contract language); update `## Action: apply` instruction (add apply-context-contract clause: read only proposal+design+tasks+affected specs); update `## Action: finalize` instruction (capability-list passthrough); bump `template-version`
- [x] Update `src/templates/changes/proposal.md`: absorb Discovery sections from research template (Current State, External Research, Approaches, Coverage Assessment, Decisions) as fixed body sections; change `requires:` from `[research]` to `[]`; bump `template-version` 3 → 4
- [x] Delete `src/templates/changes/research.md`
- [x] Delete `src/templates/changes/tests.md`
- [x] Update `src/templates/changes/design.md`: refine Non-Goals instruction (capability-limitations only, reference Proposal § Scope for change-level boundaries); bump `template-version` 1 → 2
- [x] Update `src/templates/changes/tasks.md`: change `requires:` from `[tests]` to `[preflight]`; add apply-phase test guidance section in instruction (driven by Constitution § Testing — framework configured → generate automated tests; "None" → verify Gherkin scenarios in audit); add Conditional Validation Notes section guidance (when design is skipped, tasks gains a Validation Notes section); bump `template-version` 5 → 6
- [x] Update `src/templates/changes/audit.md`: replace references to `preflight.md` with "design.md § Validation when preflight present, else tasks.md § Validation Notes"; replace references to `tests.md` with "specs (direct scenario verification)"; bump `template-version`
- [x] Update `src/templates/docs/adr.md`: change Context minimum from 4-6 sentences to 2-6 sentences (with anti-padding guidance); make Consequences section optional for straightforward decisions; bump `template-version`
- [x] Update `src/templates/docs/capability.md`: change enrichment-source language from `research.md` (or `research.md + design.md`) to `proposal.md § Discovery + design.md`, with backward-compat note honoring legacy `research.md`; bump `template-version`

### Layer 3 — Router (src/skills/)

- [x] Update `src/skills/specshift/SKILL.md`: replace "Read all change artifacts (if change exists)" in propose dispatch with "Read only the change artifacts named by the next stage's `requires:` chain"; update apply dispatch to read only proposal (capabilities), design, tasks, and affected specs from `proposal.md` frontmatter `capabilities:`; update finalize dispatch to receive capability list and read only proposal + design + audit + listed specs; add a `### Sub-Agent Dispatch` section documenting the optional sub-agent dispatch pattern in tool-agnostic language for apply, finalize, and propose-internal stage generation, referencing the proven review-self-check pattern

### Project mirror (.specshift/)

- [x] Mirror `src/templates/workflow.md` → `.specshift/WORKFLOW.md`, preserving the documented overrides (`review.request_review: copilot`; the `Compile` step in finalize action)
- [x] Mirror `src/templates/changes/*.md` → `.specshift/templates/changes/*.md`, including the deletions of research.md and tests.md from the project mirror
- [x] Mirror `src/templates/docs/*.md` → `.specshift/templates/docs/*.md`

### Spec consistency cleanups (in scope per preflight findings)

- [x] Update `docs/specs/project-init.md` lines 80-91: replace `research.md` with a different illustrative template (e.g., `proposal.md` or `audit.md`) in both scenarios ("Unchanged template updated silently", "User-customized template preserved") so the examples remain valid after research.md is deleted
- [x] Update `docs/specs/change-workspace.md` line 157: remove `research.md` from the active-change detection example (use only `proposal.md (status: active) but no tasks.md`) so the standard-layout example matches the new pipeline

### Compilation

- [x] Run `bash scripts/compile-skills.sh` to regenerate `./skills/specshift/` from `src/`; verify exit code 0
- [x] Verify the script's template-version-bump check passed (every modified template has a higher `template-version` than `main`)
- [x] Verify `./skills/specshift/templates/changes/` no longer contains `research.md` or `tests.md`
- [x] Verify `./skills/specshift/SKILL.md` reflects the new dispatch language and Sub-Agent Dispatch section

## QA Loop & Human Approval

- [ ] Metric Check — verify each Success Metric from design.md:
  - [ ] `bash scripts/compile-skills.sh` exits 0 — PASS / FAIL
  - [ ] All five modified specs free of stale references (research.md, tests.md, "Eight-Stage", `step 3.2`, `step 3.5`) — PASS / FAIL
  - [ ] `.specshift/WORKFLOW.md` `pipeline:` array equals `[proposal, specs, design, preflight, tasks, audit]` — PASS / FAIL
  - [ ] `src/templates/changes/research.md`, `src/templates/changes/tests.md`, `.specshift/templates/changes/research.md`, `.specshift/templates/changes/tests.md` all deleted — PASS / FAIL
  - [ ] Every modified template under `src/templates/` has incremented `template-version` — PASS / FAIL
  - [ ] `src/skills/specshift/SKILL.md` no longer contains "Read all change artifacts" in propose, apply, or finalize dispatch sections — PASS / FAIL
  - [ ] `src/skills/specshift/SKILL.md` documents sub-agent dispatch for apply, finalize, and propose-internal stage generation in tool-agnostic language — PASS / FAIL
  - [ ] `docs/specs/quality-gates.md` contains zero positional task-step references (`step N.M`) — PASS / FAIL
- [ ] Auto-Verify: generate audit.md using the audit template
- [ ] User Testing: **Stop here!** Ask the user for manual approval. (Skipped automatically when auto_approve is true and audit verdict is PASS.)
- [ ] Fix Loop: Classify each correction before fixing. Update all stale artifacts before re-implementing. Specs must match code before proceeding.
  - **Tweak**: wrong value/typo → fix in place
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks + re-implement
  - **Scope Change**: wrong requirements → update specs + design + re-implement fully
- [ ] Final Verify: regenerate audit.md after all fixes to confirm consistency. Skip if Fix Loop was not entered.
- [ ] Approval: Only finish on explicit **"Approved"** by the user. (Auto-dispatched by auto_approve when audit PASS.)

## Standard Tasks (Post-Implementation)

- [x] Run `specshift finalize` (generates changelog, regenerates affected capability docs, conditional ADR generation, version bump, compile)
- [x] Bump version (per Constitution § Conventions § Post-apply version bump — patch increment in `src/VERSION`; compile-skills.sh propagates to per-target manifests)
- [ ] Commit and push to remote
- [ ] Update PR: mark ready for review, update body with change summary and `Closes #15`
- [ ] Reply to and resolve all PR review comments (fixed / declined with reason / not applicable)

## Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`) — applies because this change modifies files under `src/`
