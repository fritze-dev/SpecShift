# Implementation Tasks: AOT Prompt Compilation

## 1. Foundation

- [ ] 1.1. Create `scripts/compile-skills.sh` — the AOT compiler script:
  - Parse `### Action: <name> — Requirements` sections from `src/skills/specshift/SKILL.md`
  - For each link, extract `### Requirement:` block from target spec file
  - Read `### Instruction` from `.specshift/WORKFLOW.md` per action
  - Read version from `src/.claude-plugin/plugin.json`
  - Copy `src/skills/specshift/SKILL.md` → `.claude/skills/specshift/SKILL.md`
  - Copy `src/templates/` → `.claude/skills/specshift/templates/`
  - Copy `src/.claude-plugin/` → `.claude/skills/specshift/.claude-plugin/` (preflight gap fix)
  - Write compiled action files to `.claude/skills/specshift/actions/<action>.md`
  - Validate: count extracted requirements vs link count, warn on mismatch
  - Print summary report
- [ ] 1.2. Run `bash scripts/compile-skills.sh` and verify output:
  - 4 compiled action files (propose, apply, finalize, init)
  - Each has YAML frontmatter (compiled-at, specshift-version, sources)
  - Each has `## Instruction` + `## Requirements` sections
  - Requirement count matches SKILL.md link count per action

## 2. Implementation

- [ ] 2.1. [P] Update `src/skills/specshift/SKILL.md` — Step 4:
  - Built-in actions: read `actions/<action>.md` (compiled file)
  - Missing compiled file: hard error with message to run `scripts/compile-skills.sh`
  - Custom actions: read `## Action: <name>` instruction from WORKFLOW.md directly
  - Remove JIT resolution logic for built-in actions from Step 5
- [ ] 2.2. [P] Update `.specshift/WORKFLOW.md` — finalize instruction:
  - Add step 4: "Compile: run `bash scripts/compile-skills.sh` to regenerate the release directory"
- [ ] 2.3. [P] Update `src/templates/workflow.md` — same finalize instruction change
- [ ] 2.4. [P] Update `.gitignore`:
  - Add `!/.claude/skills/` whitelist under existing `/.claude/*` rule
- [ ] 2.5. [P] Update `.claude-plugin/marketplace.json`:
  - Change `source` from `"./src"` to `"./.claude/skills/specshift"`
- [ ] 2.6. [P] Update `.specshift/CONSTITUTION.md`:
  - Architecture Rules: `.claude/skills/specshift/` is the generated release directory, committed to Git
  - Conventions: `bash scripts/compile-skills.sh` after editing specs for local development
- [ ] 2.7. [P] Update `CLAUDE.md`:
  - File Ownership: `.claude/skills/specshift/` = generated release, do not edit directly

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - Token reduction: compiled propose.md < 300 lines (vs ~695 JIT) — PASS / FAIL
  - Self-contained release: `.claude/skills/specshift/` contains SKILL.md, templates, actions, .claude-plugin — PASS / FAIL
  - Compilation correctness: 4 action files, count matches links — PASS / FAIL
  - Backwards compatibility: `specshift propose/apply/finalize` cycle works — PASS / FAIL
- [ ] 3.2. Auto-Verify: generate review.md using the review template.
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before proceeding.
- [ ] 3.5. Final Verify: regenerate review.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references (Closes #9)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`)
