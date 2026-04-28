# Implementation Tasks: Workflow/Spec-Hygiene Bundle (#59 + #58)

## 1. Foundation

<!-- No shared scaffolding — all tasks edit independent files. Foundation intentionally empty for this text-only change. -->
- [ ] 1.1. (no foundation tasks — change is text-only across templates, specs, mirrors)

## 2. Implementation

<!-- Group: Templates first (semantic headings), then specs already done in propose, then mirrors, then compile. -->

### Templates (drop positional prefixes, sharpen Action: review)

- [ ] 2.1. [P] Edit `src/templates/changes/tasks.md`: remove leading `## 1.` … `## 5.` numerals (keep heading text). Rewrite the `instruction:` block (Lines 28–44) to replace self-references "sections 1-3", "section 4", "section 5" with named sections ("Foundation through QA Loop", "Standard Tasks", "Post-Merge Reminders"). Bump `template-version` 4 → 5.
- [ ] 2.2. [P] Edit `src/templates/changes/research.md`: remove leading `## 1. Current State` … `## 7. Decisions` numerals. Bump `template-version` 1 → 2.
- [ ] 2.3. [P] Edit `src/templates/changes/preflight.md`: remove leading `## A.` … `## G.` letters. Bump `template-version` 1 → 2.
- [ ] 2.4. [P] Edit `src/templates/changes/audit.md`: rewrite the `instruction:` block to refer to the eight dimensions namentlich (Task Completion, Spec Coverage, Constitution Compliance, Code Quality, Side Effects, Cleanup, Documentation, Test Coverage) instead of "dimension 1–8" or "the 8 dimensions". Bump `template-version` 2 → 3.
- [ ] 2.5. Edit `src/templates/workflow.md` `## Action: finalize` `### Instruction`: replace numbered list (`1. Changelog ... 2. Docs ... 3. Version-bump`) with semantic bullets (`- **Changelog**: …`, `- **Docs**: …`, `- **Version-bump**: …`). Also edit `## Action: review` `### Instruction`: (a) Self-check bullet — explicitly state HOW (Skill tool with skill=review, or subagent invoking `/review` on the current branch) and WHICH marker (`<!-- specshift:self-check -->` PR comment containing HEAD commit SHA + findings summary PASS/FIX); (b) Pre-merge summary bullet — refuse to post when no `<!-- specshift:self-check -->` marker exists for current HEAD; on missing marker, stop and report. Bump `template-version` 11 → 12.

### Manifests / docs

- [ ] 2.6. Edit `src/actions/review.md`: append a link to the new "Self-Check Mandatory After Comment Processing" requirement in `docs/specs/review-lifecycle.md`.
- [ ] 2.7. [P] Edit `README.md:64`: replace "**8-stage pipeline**" with "**artifact pipeline**" (no count).

### Mirrors (parallel updates)

- [ ] 2.8. Edit `.specshift/WORKFLOW.md`: mirror the `## Action: finalize` bullets and `## Action: review` Self-check + Pre-merge gate sharpening from task 2.5. Preserve the project-specific extra `Compile` bullet under `## Action: finalize`. Bump `template-version` 9 → 10.
- [ ] 2.9. [P] Re-sync `.specshift/templates/changes/{tasks,research,preflight,audit}.md` from `src/templates/changes/`: copy the updated files (including bumped `template-version` values from tasks 2.1–2.4) into the `.specshift/templates/` mirror. The compile-skills.sh script does NOT touch `.specshift/templates/` — these files are project-local mirrors, hand-synced.

### Compile + verify

- [ ] 2.10. Run `bash scripts/compile-skills.sh`. The script SHALL regenerate `skills/specshift/**`. The script's existing template-version validation against `main` SHALL pass for all five bumped templates (workflow.md 11→12, tasks.md 4→5, research.md 1→2, preflight.md 1→2, audit.md 2→3). Verify exit code 0.
- [ ] 2.11. Verify `diff -r src/templates/ skills/specshift/templates/` returns no output (no drift between source and compiled).

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
  - Zero `^##+\s+([0-9]+|[A-Z])\.` matches in `src/templates/changes/{tasks,research,preflight}.md`.
  - Zero `\b[0-9]+-stage\b|\beight-stage\b|exactly [0-9]+ (artifact|stage|pipeline)` matches in `README.md`, `docs/specs/`, `src/templates/`.
  - Zero stale `section [0-9]+` / `step [0-9]+` cross-references in `docs/specs/{artifact-pipeline,three-layer-architecture,review-lifecycle}.md`.
  - `bash scripts/compile-skills.sh` exits 0.
  - `diff -r src/templates/ skills/specshift/templates/` zero output.
  - New `Self-Check Mandatory After Comment Processing` requirement contains the four listed scenarios.
- [ ] 3.2. Auto-Verify: generate `audit.md` using the audit template. Run all eight dimensions; verdict SHALL be PASS.
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval before proceeding to Standard Tasks.
- [ ] 3.4. Fix Loop: Classify each correction before fixing. Update all stale artifacts before re-implementing. Specs must match code before proceeding.
  - **Tweak**: wrong value/typo → fix in place.
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks + re-implement.
  - **Scope Change**: wrong requirements → update specs + design + re-implement fully.
- [ ] 3.5. Final Verify: regenerate `audit.md` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

<!-- Universal post-implementation steps. Constitution Pre-Merge extras appended after. -->
- [ ] 4.1. Run `specshift finalize` (generates changelog incremental entry; regenerates `docs/capabilities/{artifact-pipeline,three-layer-architecture,review-lifecycle}.md`; bumps `src/VERSION`; runs `bash scripts/compile-skills.sh` to propagate version into `.claude-plugin/`, `.codex-plugin/` manifests).
- [ ] 4.2. Bump version (handled automatically by finalize per constitution's Post-apply version bump convention; record the new version).
- [ ] 4.3. Commit and push to remote (the finalize step's compile output, capability docs, CHANGELOG entry, and version bump go in one commit).
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references (`Closes #59`, `Closes #58`).
- [ ] 4.5. Reply to and resolve all PR review comments (fixed/declined with reason/not applicable).

## 5. Post-Merge Reminders

<!-- Not tracked as tasks. Plain bullets — execute manually after PR merge. -->
- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`) — applies because this change modifies files under `src/`.
