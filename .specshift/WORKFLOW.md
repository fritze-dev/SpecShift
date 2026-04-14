---
template-version: 4
plugin-version: 0.1.6-beta
templates_dir: .specshift/templates
pipeline: [research, proposal, specs, design, preflight, tests, tasks, review]

actions: [init, propose, apply, finalize]
# Add custom actions here (e.g. qa-review) and define matching
# ## Action: <name> sections in the body below.

worktree:
  enabled: true
  path_pattern: .claude/worktrees/{change}
  auto_cleanup: true
  stale_days: 14

auto_approve: true

# docs_language: English
---

# Workflow

Research → Propose → Specs → Design → Pre-Flight → Tests → Tasks → Apply → Review → Finalize

## Context

Always read and follow .specshift/CONSTITUTION.md before proceeding.
All workflow artifacts (research, proposal, specs, design, preflight, tasks, review)
must be written in English regardless of docs_language.

## Action: propose

### Instruction

Create change workspace if needed, then traverse the pipeline generating artifacts.
If no change exists: ask user what to build, derive kebab-case name, create workspace (with worktree if enabled).
Lazy worktree cleanup: before creating, check for stale worktrees. Auto-clean completed proposals and merged PRs. For closed PRs or branches inactive beyond stale_days, prompt the user before cleanup. Read proposals from worktree filesystem paths.
Checkpoint/resume: skip completed artifacts, resume from first incomplete step.
Design review checkpoint: when auto_approve is false, pause after design for user alignment. When auto_approve is true, skip the design checkpoint and continue.
Preflight checkpoint: PASS → continue, PASS WITH WARNINGS → pause for acknowledgment, BLOCKED → stop.
review artifact: stop before review and suggest running the specshift skill with `apply`.

## Action: init

### Instruction

Project initialization and health check.
Mode detection:
- Fresh (no WORKFLOW.md): install templates, scan codebase, generate constitution and CLAUDE.md
- Update (templates outdated): merge plugin template updates with local customizations
- Re-sync (all installed): detect spec drift (code vs specs) + docs drift (docs vs specs)
Report findings, suggest running the specshift skill with `propose` for changes needed.

## Action: apply

### Instruction

Implement tasks from tasks.md, then generate review.md.
QA loop: implement → generate review.md → fix if FAIL → regenerate review.md → until PASS.
Delete existing review.md before starting implementation.
When auto_approve is false, pause at user testing gate. When auto_approve is true and review.md verdict is PASS, skip user testing pause.
Fix loop: before applying any fix, classify the correction — Tweak (wrong value/typo/missing line → fix in place), Design Pivot (wrong files/approach/abstraction → update design.md + discard affected tasks → re-implement), or Scope Change (wrong requirements/target audience → update specs + design → full re-implementation). After any fix, regenerate review.md before presenting to user.
Artifact staleness: for Design Pivot or Scope Change corrections, update ALL stale change artifacts (design.md, tasks.md affected sections, preflight.md if needed) before re-implementing. A stale artifact is one that still describes the original wrong approach. Specs must match implementation before proceeding.
Standard Tasks (post-implementation section) are NOT part of apply.
Constitution standard tasks: pre-merge executed during post-apply, post-merge remain as reminders.
Before committing, mark all standard task checkboxes as complete except post-merge.
After review.md PASS, commit and push implementation.

## Action: finalize

### Instruction

Post-approval finalization, executed sequentially:
1. Changelog: incremental entries from completed change
2. Docs: regenerate affected capability docs, ADRs, README
3. Version-bump: if the constitution defines a version-bump convention, follow it; otherwise skip
4. Compile: run `bash scripts/compile-skills.sh` to regenerate the release directory at `.claude/skills/specshift/` — compilation validates that modified templates have bumped `template-version`
On error in one step: continue with next, report failures at end.
Check review.md exists with verdict PASS before proceeding.
