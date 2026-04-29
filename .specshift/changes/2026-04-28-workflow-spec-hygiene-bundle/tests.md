# Tests: Workflow/Spec-Hygiene Bundle (#59 + #58)

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

Per `.specshift/CONSTITUTION.md` Testing section: "Framework: None (plugin is Markdown/YAML artifacts, no executable tests). Validation: Gherkin scenarios verified via audit.md during apply." This change is text-only — manual verification via grep + spec inspection is the canonical pattern.

## Manual Test Plan

### artifact-pipeline (modified)

#### Pipeline Stages and Dependencies (renamed from "Eight-Stage Pipeline")

- [ ] **Scenario: Pipeline stages execute in dependency order**
  - Setup: a new change workspace with no artifacts generated.
  - Action: progress through the pipeline.
  - Verify: the order is research → proposal → specs → design → preflight → tests → tasks → audit. Confirm by inspecting `.specshift/changes/2026-04-28-workflow-spec-hygiene-bundle/` — files appear in that commit order.

- [ ] **Scenario: All stages produce verifiable artifacts**
  - Setup: a completed pipeline run.
  - Action: inspect the change workspace.
  - Verify: it contains research.md, proposal.md, design.md, preflight.md, tests.md, tasks.md (and audit.md after apply); plus modified docs/specs files for this change.

- [ ] **Scenario: Requirement title contains no count**
  - Setup: `docs/specs/artifact-pipeline.md` after this change is merged.
  - Action: grep `^### Requirement: Eight-Stage Pipeline`.
  - Verify: zero matches. Grep `^### Requirement: Pipeline Stages and Dependencies` returns one match.

#### Standard Tasks Directive in Task Generation (modified)

- [ ] **Scenario: Universal standard tasks always included**
  - Setup: a future `specshift propose` run uses the bumped tasks template.
  - Action: generate `tasks.md`.
  - Verify: `tasks.md` contains a section titled `## Standard Tasks (Post-Implementation)` (no leading number). Grep `^## [0-9]+\. Standard Tasks` returns zero matches.

- [ ] **Scenario: Constitution extras appended to universal steps**
  - Setup: project constitution with `## Standard Tasks` section containing 1 extra item.
  - Action: generate `tasks.md` via `specshift propose`.
  - Verify: the Standard Tasks section contains the universal steps followed by the extra item.

- [ ] **Scenario: Template includes universal standard tasks**
  - Setup: tasks template at `.specshift/templates/changes/tasks.md` and `src/templates/changes/tasks.md` after this change.
  - Action: read template body.
  - Verify: `## Standard Tasks (Post-Implementation)` heading present, no leading `## 4.` prefix.

#### Semantic Heading Structure in Pipeline Artifact Templates (NEW)

- [ ] **Scenario: Tasks template uses semantic headings**
  - Setup: `src/templates/changes/tasks.md` after this change.
  - Action: `grep -nE '^##+\s+([0-9]+|[A-Z])\.' src/templates/changes/tasks.md`.
  - Verify: zero matches. Body headings begin with words (Foundation, Implementation, QA Loop & Human Approval, Standard Tasks (Post-Implementation), Post-Merge Reminders).

- [ ] **Scenario: Cross-reference in spec uses semantic name**
  - Setup: `docs/specs/artifact-pipeline.md` after this change.
  - Action: grep `section 4`, `section 3` in artifact-pipeline.md.
  - Verify: zero matches. Cross-references use phrases like "Standard Tasks section" or "QA Loop section".

- [ ] **Scenario: Reordering sections does not break cross-references**
  - Setup: a future contributor reorders sections in `src/templates/changes/tasks.md` (e.g., moves Implementation before Foundation).
  - Action: regenerate `tasks.md` for any change.
  - Verify: spec cross-references like "Standard Tasks section" still resolve. Grep returns the section unchanged.

### three-layer-architecture (modified)

#### Schema Layer (modified)

- [ ] **Scenario: WORKFLOW.md defines the pipeline order**
  - Setup: `.specshift/WORKFLOW.md` and `src/templates/workflow.md` after this change.
  - Action: read frontmatter `pipeline:` array.
  - Verify: array contains the same eight artifact IDs (research, proposal, specs, design, preflight, tests, tasks, audit) declared by the Pipeline Stages and Dependencies requirement in artifact-pipeline.md.

- [ ] **Scenario: No hardcoded stage count in spec body**
  - Setup: `docs/specs/three-layer-architecture.md` after this change.
  - Action: grep `7-stage`, `eight-stage`, `8-stage`, `exactly 8`, `exactly 7`.
  - Verify: zero matches.

### review-lifecycle (modified + new requirement)

#### Review Comment Processing (modified — advisory → normative reference)

- [ ] **Scenario: Actionable review comment processed and resolved**
  - Setup: an unresolved review thread requesting a concrete code change on a PR.
  - Action: invoke `specshift review`.
  - Verify: the change is implemented, a reply is posted, the thread is resolved, the fix is committed and pushed. Then verify the requirement text references the new Self-Check requirement (no longer carries advisory wording).

- [ ] **Scenario: Wording sanity check (modified requirement)**
  - Setup: `docs/specs/review-lifecycle.md` Review Comment Processing requirement after this change.
  - Action: read the requirement text.
  - Verify: it says "run the self-check defined by the Self-Check Mandatory After Comment Processing requirement" rather than "run the built-in review skill for self-check".

#### Self-Check Mandatory After Comment Processing (NEW)

- [ ] **Scenario: Self-check invoked after fix commit**
  - Setup: a PR with review comments processed, fixes committed and pushed by `specshift review`.
  - Action: observe what the action does next.
  - Verify: the action invokes the built-in review skill (Skill tool with skill=review, or subagent with /review). A PR comment is posted containing `<!-- specshift:self-check -->` plus the current HEAD commit SHA plus a findings summary.

- [ ] **Scenario: Self-check after fixes catches regression**
  - Setup: review action committed/pushed fixes; self-check is invoked.
  - Action: self-check finds an issue introduced by the fixes.
  - Verify: the marker comment reports FIX with the finding listed. The action then commits a regression fix, pushes, and re-invokes self-check until the marker reports PASS.

- [ ] **Scenario: Pre-merge summary refuses without self-check marker**
  - Setup: a PR where the review action has reached the Pre-Merge Summary Comment phase but no `<!-- specshift:self-check -->` marker exists for the current HEAD commit.
  - Action: action attempts to post the pre-merge summary.
  - Verify: action stops with "Self-check missing for HEAD <sha> — invoke the review skill on this branch before merging". No pre-merge summary is posted. No merge confirmation is offered.

- [ ] **Scenario: Stale self-check marker forces re-invocation**
  - Setup: a `<!-- specshift:self-check -->` marker comment points at commit `abc123`. New commits push, advancing HEAD to `def456`.
  - Action: action checks for the self-check marker.
  - Verify: the marker is treated as stale (HEAD mismatch). Self-check is re-invoked before the action proceeds to the pre-merge summary.

#### Pre-Merge Summary Comment (modified — gate added)

- [ ] **Scenario: Summary comment posted before merge confirmation (still works after gate)**
  - Setup: review action processed 4 threads, resolved all, implemented 3 fixes across 2 cycles. Self-check marker for current HEAD reports PASS.
  - Action: action reaches the pre-merge phase.
  - Verify: gate passes (marker exists for HEAD). Summary is posted with "4 threads resolved, 3 fixes applied, self-check passed". Merge confirmation is offered.

- [ ] **Scenario: Summary refuses when marker is missing**
  - Setup: as above, but no self-check marker exists for HEAD.
  - Action: action attempts to post the summary.
  - Verify: action stops without posting summary, reporting the missing marker (covered by the new requirement's normative path).

### Edge Cases (from preflight Gap Analysis)

- [ ] **Edge: Self-check comment post fails (tooling error)**
  - Setup: GitHub tooling rejects the comment-post call (e.g., transient error, permission issue).
  - Action: review action attempts to post the marker comment.
  - Verify: action does NOT silently skip self-check. Either the comment retries successfully OR the missing-marker stop path triggers and the user sees an explicit error. No false-positive merge.

- [ ] **Edge: Multiple consumers share the bumped templates**
  - Setup: a consumer project running `specshift init` after this change merges.
  - Action: `specshift init` reads new template-versions.
  - Verify: a single batched merge prompt covers all five templates (workflow.md, changes/tasks.md, changes/research.md, changes/preflight.md, changes/audit.md). Existing consumer customizations are preserved per existing merge-prompt logic.

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios (new + modified-coverage) | 16 |
| Automated tests | 0 |
| Manual test items | 16 |
| Preserved (@manual) | 0 |
| Edge case tests | 2 |
| Warnings | 0 |

All 16 manual test items map back to either a new scenario added by this change or a modified scenario whose verification semantics changed. Existing scenarios that remain unchanged are not duplicated here.
