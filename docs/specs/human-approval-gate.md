---
order: 10
category: development
status: stable
version: 4
lastModified: 2026-04-13
---
## Purpose

Defines the QA loop with mandatory explicit human approval before finalizing, including success metric validation, fix-verify cycles, and bidirectional feedback between code and specs. The QA loop now produces a `audit.md` artifact in the change directory (replacing the previous transient verify report) as the approval gate.

## Requirements

### Requirement: QA Loop with Mandatory Approval

The system SHALL require explicit human approval before a change can proceed to the post-apply workflow, unless `auto_approve: true` is set in WORKFLOW.md and the audit.md verdict is PASS (no CRITICAL or WARNING issues). When auto_approve is true and review passes cleanly, the system SHALL auto-approve and proceed without pausing. The QA loop consists of: (1) generating `audit.md` in the change directory using the review template to produce a persisted verification report, (2) presenting findings to the user, and (3) waiting for an explicit "Approved" response. The system SHALL NOT proceed without receiving explicit human approval. Approval SHALL only be requested after verification has been run and all CRITICAL issues have been resolved. The tasks.md template SHALL include a QA Loop section with an explicit human approval checkbox that MUST be checked before proceeding. Every Success Metric from design.md SHALL be carried over as a PASS/FAIL checkbox in the QA Loop section.

Approval SHALL be gated by a final verification pass. After the Fix Loop completes (all CRITICAL issues resolved, code and specs in sync), a final `audit.md` SHALL be regenerated (Final Verify step) before the user is asked for approval. This ensures that all changes made during the Fix Loop — including spec updates, design changes, and code fixes — are verified as consistent before finalizing. If the Fix Loop was not entered (first verify was clean), the Final Verify step can be marked complete immediately.

The QA Loop SHALL include the following steps in order: Metric Check, Auto-Verify, User Testing, Fix Loop, Final Verify, and Approval. The exact step numbering is a template concern defined in the tasks Smart Template. Implementation changes are committed and pushed before User Testing via the `apply.instruction` in WORKFLOW.md (not as a template step).

**User Story:** As a developer I want a mandatory human approval step before finalizing, so that no change is finalized without my explicit review and sign-off.

#### Scenario: Approval after clean verification

- **GIVEN** a change "add-user-auth" has been implemented and all tasks are complete
- **AND** apply generates `audit.md` which shows no CRITICAL or WARNING issues
- **AND** all success metric checkboxes in the QA Loop section are marked PASS
- **WHEN** the system presents the verification report
- **THEN** the system asks for explicit approval
- **AND** the user responds "Approved"
- **AND** the system proceeds to allow the post-apply workflow

#### Scenario: Approval blocked by critical issues

- **GIVEN** a verification report contains 2 CRITICAL issues
- **WHEN** the system presents the findings to the user
- **THEN** the system SHALL NOT request approval
- **AND** SHALL state that CRITICAL issues must be resolved first
- **AND** SHALL list the specific issues that need resolution

#### Scenario: Approval with warnings acknowledged

- **GIVEN** a verification report contains 0 CRITICAL issues but 3 WARNING issues
- **WHEN** the system presents the findings
- **THEN** the system SHALL request approval while highlighting the warnings
- **AND** the user may respond "Approved" to accept the warnings
- **AND** the system SHALL proceed to allow the post-apply workflow

#### Scenario: Success metrics carried into QA loop

- **GIVEN** a design.md containing 3 success metrics: "Auth response time < 200ms", "All endpoints require valid JWT", "Session expiry after 30 min idle"
- **WHEN** tasks.md is generated
- **THEN** the QA Loop section SHALL contain 3 PASS/FAIL checkboxes, one for each success metric
- **AND** each checkbox SHALL be marked by the user or verifier during the QA phase
- **AND** all checkboxes MUST be marked PASS before approval can be granted

#### Scenario: Final verify after fix loop

- **GIVEN** a change where Auto-Verify found CRITICAL issues
- **AND** the developer completed the Fix Loop, fixing all issues
- **WHEN** the Fix Loop is complete
- **THEN** the system SHALL regenerate `audit.md` one final time (Final Verify)
- **AND** the final verify report SHALL confirm 0 CRITICAL issues
- **AND** only then SHALL the system proceed to request Approval

#### Scenario: Auto-approve bypasses user testing when PASS and auto_approve true

- **GIVEN** `auto_approve: true` in WORKFLOW.md
- **AND** apply generates `audit.md` with verdict PASS and 0 CRITICAL / 0 WARNING issues
- **WHEN** the QA loop reaches the User Testing step
- **THEN** the system SHALL skip the user testing pause
- **AND** SHALL auto-mark the Approval checkbox as complete
- **AND** SHALL proceed to the post-apply workflow

#### Scenario: Auto-approve does NOT bypass when warnings present

- **GIVEN** `auto_approve: true` in WORKFLOW.md
- **AND** apply generates `audit.md` with verdict PASS WITH WARNINGS
- **WHEN** the QA loop reaches the User Testing step
- **THEN** the system SHALL pause for user review of the warnings
- **AND** SHALL NOT auto-approve

#### Scenario: Final verify skipped when first verify is clean

- **GIVEN** a change where Auto-Verify found no CRITICAL or WARNING issues
- **AND** User Testing found no bugs
- **AND** the Fix Loop was not entered
- **WHEN** the QA loop reaches Final Verify
- **THEN** the Final Verify step SHALL be marked complete immediately
- **AND** the system SHALL proceed to Approval

#### Scenario: Final verify finds new issues from fix loop changes

- **GIVEN** a Fix Loop where the developer updated specs and code
- **WHEN** Final Verify is run
- **AND** it discovers that a spec update introduced an inconsistency
- **THEN** the system SHALL report the new issue
- **AND** the developer SHALL return to the Fix Loop to resolve it
- **AND** SHALL re-run Final Verify after the fix

### Requirement: Fix Loop

Verify issues and user correction requests SHALL be resolved via a tiered re-entry process before re-verification. Before applying any fix, the system SHALL classify the correction into one of three tiers and apply the matching re-entry depth:

**Tier 1 — Tweak**: The correction changes a value, line, or detail *within* the current approach (wrong value, typo, missing line, formatting error). Re-entry depth: fix in place, then regenerate `audit.md`.

**Tier 2 — Design Pivot**: The correction changes *which files are modified* or *which approach/abstraction is used*, but requirements are still correct (wrong file edited, wrong architectural pattern, wrong abstraction level). Re-entry depth: update `design.md` to reflect the corrected approach, discard and re-generate the affected task sections in `tasks.md`, re-implement from the updated design, then regenerate `audit.md`.

**Tier 3 — Scope Change**: The correction changes *which requirements apply* or *who the target audience is* (wrong capability scope, missing requirement, wrong consumer model). Re-entry depth: update `docs/specs/<capability>.md` and `proposal.md` to reflect the corrected scope, update `design.md`, re-generate affected tasks, re-implement fully, then regenerate `audit.md`.

**Detection signals** — the system SHALL check these before classifying a correction:
- A completed task needs to be reverted or undone → Design Pivot or Scope Change
- A success metric from `design.md` no longer applies to the corrected implementation → Design Pivot or Scope Change
- A design decision in `design.md` is factually reversed by the correction → Design Pivot
- The correction touches files outside those listed in `design.md` Architecture & Components → Design Pivot
- The correction reveals that a listed requirement does not apply to the correct audience → Scope Change
- More than two incremental fix commits on the same issue → heuristic signal; treat as Design Pivot or Scope Change unless the agent can confirm each commit was a genuine independent Tweak

**Artifact staleness rule**: For Tier 2 and Tier 3 corrections, ALL stale change artifacts SHALL be updated before re-implementing. A stale artifact is any change file (design.md, tasks.md, preflight.md, audit.md) that still describes the original (wrong) approach. The system SHALL NOT leave stale artifacts in the change directory that contradict the corrected implementation.

The bidirectional feedback principle applies at all tiers: updating a spec or design to match the intended implementation is always a valid resolution path.

After all fixes are applied at the appropriate re-entry depth, the system SHALL regenerate `audit.md` to confirm resolution. The system SHALL support iterative fix-verify cycles until all CRITICAL issues are resolved and the user is satisfied with remaining warnings.

**User Story:** As a developer I want a structured fix-verify loop with explicit re-entry tiers, so that approach changes trigger artifact updates and clean re-implementation instead of patch commits on top of a wrong design.

#### Scenario: Classify correction as Tweak — fix in place

- **GIVEN** a review correction that changes a wrong value in an edited file (e.g., wrong version string, missing newline)
- **AND** the approach and affected files remain the same
- **WHEN** the system classifies the correction
- **THEN** it SHALL identify this as Tier 1 — Tweak
- **AND** SHALL fix the value in place
- **AND** SHALL regenerate `audit.md` after the fix

#### Scenario: Classify correction as Design Pivot — update design and re-implement

- **GIVEN** a review correction that points out the wrong file was edited (e.g., `CONSTITUTION.md` was changed instead of `src/templates/constitution.md`)
- **AND** the requirements are still correct, only the implementation target changed
- **WHEN** the system checks detection signals and finds "correction touches files outside those listed in design.md Architecture & Components"
- **THEN** it SHALL identify this as Tier 2 — Design Pivot
- **AND** SHALL update `design.md` Architecture & Components to reflect the correct file targets
- **AND** SHALL discard and re-generate the affected task sections
- **AND** SHALL re-implement the affected tasks from the corrected design
- **AND** SHALL regenerate `audit.md` after re-implementation

#### Scenario: Design Pivot updates all stale artifacts

- **GIVEN** a Design Pivot correction has occurred
- **AND** the existing `audit.md` in the change directory still shows PASS against the original (wrong) approach
- **WHEN** the system applies the Tier 2 re-entry
- **THEN** it SHALL update `design.md` to reflect the corrected approach
- **AND** SHALL update `tasks.md` affected sections to remove old tasks and add corrected ones
- **AND** SHALL delete `audit.md` (stale) before re-implementing
- **AND** SHALL generate a new `audit.md` from the corrected implementation

#### Scenario: Classify correction as Scope Change — update specs and re-implement

- **GIVEN** a review correction that reveals the wrong capability scope was targeted (e.g., a requirement listed in the proposal does not apply to the correct audience)
- **AND** the implementation approach may be sound, but the requirements themselves need revision
- **WHEN** the system checks detection signals and finds "correction reveals that a listed requirement does not apply to the correct audience"
- **THEN** it SHALL identify this as Tier 3 — Scope Change
- **AND** SHALL update `docs/specs/<capability>.md` and `proposal.md` to reflect the corrected scope
- **AND** SHALL update `design.md` to align with the corrected requirements
- **AND** SHALL re-generate affected task sections in `tasks.md`
- **AND** SHALL re-implement fully from the corrected design
- **AND** SHALL regenerate `audit.md` after re-implementation

#### Scenario: Fix code to resolve critical issue

- **GIVEN** a verification report with CRITICAL issue "Requirement not found: Session Timeout"
- **WHEN** the developer implements session timeout logic in the auth module
- **AND** regenerates `audit.md`
- **THEN** the new verification report no longer lists the session timeout issue as CRITICAL
- **AND** the Completeness dimension reflects the additional requirement coverage

#### Scenario: Update spec to resolve warning

- **GIVEN** a verification report with WARNING "Implementation may diverge from spec: auth uses session cookies, spec requires JWT"
- **AND** the developer intentionally chose session cookies over JWT
- **WHEN** the developer updates the spec to reflect session cookie authentication
- **AND** regenerates `audit.md`
- **THEN** the new verification report no longer lists the divergence warning
- **AND** the spec accurately reflects the implementation

#### Scenario: Multiple fix-verify iterations

- **GIVEN** a first verification finds 3 CRITICAL and 2 WARNING issues
- **WHEN** the developer fixes all 3 CRITICAL issues and regenerates `audit.md`
- **THEN** the second report shows 0 CRITICAL issues
- **AND** may show the same 2 warnings plus any new issues introduced by the fixes
- **AND** the developer may choose to address warnings or approve with acknowledged warnings

#### Scenario: Fix introduces new issue

- **GIVEN** a developer fixes a CRITICAL issue by refactoring the auth module
- **AND** the refactoring removes a function that another requirement depends on
- **WHEN** the developer regenerates `audit.md`
- **THEN** the original CRITICAL issue is resolved
- **BUT** a new CRITICAL issue appears for the broken dependency
- **AND** the developer must address the new issue before approval

#### Scenario: Bidirectional feedback -- update design

- **GIVEN** a verification finds that the implementation uses a different architectural pattern than design.md specifies
- **AND** the new pattern is superior and the developer wants to keep it
- **WHEN** the developer updates design.md to document the actual architecture
- **AND** regenerates `audit.md`
- **THEN** the coherence check passes because design.md now matches the implementation

## Edge Cases

- **Approval without running verify**: If `audit.md` has never been generated for the current change, the QA Loop approval checkbox in tasks.md will not be checked. The system SHALL warn that verification has not been performed.
- **Stale verification**: If code changes are made after the last verify run, the verification report may be stale. The system does not enforce re-verification automatically but SHALL note the timestamp of the last verify run relative to the most recent code changes when the user proceeds with the post-apply workflow.
- **No design.md success metrics**: If design.md does not contain explicit success metrics, the QA Loop section SHALL still include the mandatory human approval checkbox but will have no PASS/FAIL metric checkboxes.
- **User provides partial approval**: If the user responds with something ambiguous (e.g., "looks ok" or "seems fine"), the system SHALL clarify that it needs an explicit "Approved" and SHALL NOT treat ambiguous responses as approval.
- **All issues are suggestions only**: If verification produces only SUGGESTION-level findings and no CRITICAL or WARNING issues, the system SHALL proceed directly to requesting approval without requiring fixes.
- **Fix loop with no code changes needed**: If a CRITICAL issue is a false positive (e.g., keyword search matched unrelated code), the user may update the verify heuristics or acknowledge the false positive. Re-running verify with the same code is a valid fix loop iteration.
- **Commit step after fix loop**: If the Fix Loop produces additional changes, those changes are committed during the Fix Loop's re-verify cycle. The initial Commit and Push captures the implementation state at first verify pass; subsequent Fix Loop commits are incremental.
- **Ambiguous tier classification**: If the system cannot determine whether a correction is Tier 1 or Tier 2, it SHALL err toward the higher tier (Design Pivot) to ensure artifact freshness. Over-classifying produces clean artifacts; under-classifying produces stale ones.
- **Tier 3 mid-implementation**: If a Scope Change is identified after partial implementation, the system SHALL update the spec first, then re-generate design + tasks before continuing. Partial work that conflicts with the new scope SHALL be reverted.
- **Tier escalation within fix loop**: If applying a Tier 1 fix reveals that the underlying problem is a Tier 2 or Tier 3 issue (e.g., fixing a value exposes that the wrong file was targeted), the system SHALL re-classify at the higher tier and apply the corresponding re-entry depth. The initial Tier 1 fix may be kept or reverted depending on whether it conflicts with the higher-tier correction.

## Assumptions

- The user is available to provide approval in a timely manner within the same session or a subsequent session. <!-- ASSUMPTION: User availability -->
- Spec updates during the fix loop do not require re-running the full artifact pipeline (preflight is not re-triggered automatically). <!-- ASSUMPTION: No auto-retrigger -->
- The human reviewer is the same person who initiated the change or has sufficient context to approve. <!-- ASSUMPTION: Reviewer context -->
- "Approved" is the canonical approval token; the system recognizes it case-insensitively. <!-- ASSUMPTION: Approval token -->
- The fix loop does not have a maximum iteration count; it continues until the user is satisfied. <!-- ASSUMPTION: Unbounded fix loop -->
