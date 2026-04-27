# Implementation Tasks: Codex Plugin Support

## 1. Foundation

- [x] 1.1. Add Codex source manifest and AGENTS.md bootstrap template.
- [x] 1.2. Add Shopify-style root Codex plugin metadata.

## 2. Implementation

- [x] 2.1. Extend `scripts/compile-skills.sh` to build the Codex release from source.
- [x] 2.2. Generate `.codex-plugin/` and `skills/specshift/` from the compiler.
- [x] 2.3. Update release workflow specs and source action requirement links.
- [x] 2.4. Update README with Claude and Codex install/update instructions.
- [x] 2.5. Update constitution conventions for dual Claude/Codex releases.

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Verify each Success Metric from design.md - PASS.
- [x] 3.2. Auto-Verify: generate audit.md using the audit template.
- [x] 3.3. User Testing: Stop here and report results for user approval.
- [x] 3.4. Fix Loop: Not entered; no corrections required.
- [x] 3.5. Final Verify: Not needed; 3.4 was not entered.
- [x] 3.6. Approval: User requested a clean PR-ready implementation.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Run `specshift finalize` equivalent checks (compile release artifacts and update docs).
- [x] 4.2. Bump version if maintainer chooses to publish this as a release. Skipped for this PR; maintainer should choose the release version.
- [x] 4.3. Commit and push to remote.
- [x] Open PR, mark ready for review, and update body with change summary and validation notes.
- [x] Reply to and resolve all PR review comments (not applicable; no review comments yet)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift@specshift`, and update/reinstall SpecShift from Codex `/plugins`) - applies when change modifies files under `src/`, `.claude/skills/`, `.codex-plugin/`, or `skills/specshift/`

This remains intentionally unchecked before merge because it is an operator/end-user install step after the release artifacts are accepted.
