# Pre-Flight Check: Fix Squash-Merge Commit Messages

## A. Traceability Matrix

- [x] Merge Execution (review-lifecycle) → Scenario: Squash merge uses clean commit message → `src/templates/workflow.md` (step 8), `.specshift/WORKFLOW.md` (step 8)
- [x] Merge Execution (review-lifecycle) → Edge case: Proposal missing sections → same instruction files (fallback behavior)
- [x] Post-Artifact Commit (artifact-pipeline) → Scenarios: First/subsequent artifact commit → `src/skills/specshift/SKILL.md` (step 4)
- [x] Post-Implementation Commit (artifact-pipeline) → Scenario: Implementation committed → `.specshift/WORKFLOW.md` (apply instruction), `src/templates/workflow.md` (apply instruction)
- [x] Implementation commit naming (artifact-pipeline) → Scenario: Implementation commit does not replace final commit → no instruction change needed (scenario-only update)

## B. Gap Analysis

No gaps found. The change covers:
- Squash merge message composition (title + body + issue refs)
- Fallback chain for missing proposal sections
- Pipeline commit format for both artifact and implementation phases
- All scenarios updated with new format

## C. Side-Effect Analysis

- **Compile script**: No impact — `scripts/compile-skills.sh` extracts requirements by section header, not by content. The updated text will be extracted correctly.
- **Existing completed changes**: No impact — the format change only affects future commits.
- **Consumer projects**: Will see the new commit format after `specshift init` detects the template-version bump (6 → 7) and merges the updated workflow template.
- **SKILL.md copy**: The compile script copies `src/skills/specshift/SKILL.md` to `.claude/skills/specshift/SKILL.md`. The updated propose step 4 will be included.

No regression risks identified.

## D. Constitution Check

- **Commits convention**: "Imperative present tense with category prefix" — the new `specshift(<scope>): <description>` format is compatible. Pipeline commits are a distinct category from user-facing commits (which use `Fix:`, `Refactor:`, etc.).
- **Template-version discipline**: `src/templates/workflow.md` modification requires version bump (6 → 7). Covered in design.
- **Template synchronization**: `src/templates/workflow.md` is authoritative; `.specshift/WORKFLOW.md` is synced from it. Both will be updated.
- **Tool-agnostic instructions**: The spec says "using available GitHub tooling" — no tool-specific commands. Compliant.

No constitution updates needed.

## E. Duplication & Consistency

- The commit format `specshift(<change-name>): <artifact-id>` is defined in `artifact-pipeline.md` (spec) and referenced in `SKILL.md` (instruction). Both will use the same format — consistent.
- The squash commit message composition is defined in `review-lifecycle.md` (spec) and referenced in `workflow.md` step 8 (instruction). Both will describe the same behavior — consistent.
- No contradictions with other specs.

## F. Assumption Audit

- **design.md**: "No assumptions made." — No markers to audit.
- **review-lifecycle.md**: 3 existing assumptions (GitHub tooling capabilities, built-in review availability, thread resolution capability). None are affected by this change.
- **artifact-pipeline.md**: Existing assumptions unchanged by this change.

No new assumptions introduced.

## G. Review Marker Audit

Scanned all change artifacts and modified specs for `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers:
- research.md: None
- proposal.md: None
- design.md: None
- review-lifecycle.md: None
- artifact-pipeline.md: None

No blocking REVIEW markers found.

---

**Verdict: PASS** — 0 blockers, 0 warnings. All requirements traced, no gaps, no side-effect risks, constitution-compliant, no stale assumptions or review markers.
