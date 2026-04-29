---
id: tasks
template-version: 5
description: Implementation checklist with QA loop
generates: tasks.md
requires: [tests]
instruction: |
  Create a clean implementation checklist based on design and pre-flight.
  Use `- [ ]` checkbox format — the apply phase parses these for tracking.
  Group tasks under semantic `## ` headings by dependency: foundational/shared work first, then features. Heading text SHALL be semantic (e.g., `## Foundation`, `## Implementation`); SHALL NOT begin with a numerical or alphabetic prefix.
  Tasks should be small enough to complete in one session.
  Mark parallelizable tasks with `[P]`.
  Where applicable, place test tasks before their implementation tasks.
  Carry over every Success Metric from design.md as a PASS/FAIL checkbox
  in the QA Loop (before Auto-Verify).
  Add the QA loop with an explicit human approval gate.

  Reference generated test files from tests.md. Implementation tasks
  should make failing tests pass. Additional test tasks may be added
  for cases not covered by Gherkin scenarios.

  Definition of Done is emergent from artifacts — there is no
  separate DoD checklist. Gherkin scenarios define functional
  completeness, success metrics define quality targets, preflight
  findings define risk resolution, and explicit user approval
  gates implementation completeness.

  The apply phase covers Foundation through QA Loop & Human Approval.
  For documentation-only changes (no code), implementation sections may
  be empty — the QA loop alone is sufficient.

  Standard Tasks: The template includes a Standard Tasks (Post-Implementation)
  section with universal post-implementation steps (changelog, docs, version
  bump, push). Always include this section as-is. If the project constitution
  defines a "## Standard Tasks" section with a "### Pre-Merge" subsection,
  append those pre-merge items (as `- [ ]` checkboxes) after the universal
  steps in the Standard Tasks section.

  Post-Merge Reminders: If the constitution's Standard Tasks has a
  "### Post-Merge" subsection, evaluate each item's relevance to the
  current change. Check the proposal's "What Changes" and "Scope &
  Boundaries" sections to determine which files and areas are affected.
  Post-merge items may include a scope hint describing when they apply
  (e.g., "applies when src/ files change"). Only include items whose
  scope matches the change. Items without a scope hint are always
  included. When ambiguous, err on the side of inclusion. Strip scope
  hints from the output. Add matching items in a separate Post-Merge
  Reminders section as plain `- ` bullets (no checkbox, no numbering).
  These are not tracked tasks — just reminders for manual execution
  after the PR is merged. If no Post-Merge subsection exists, or no
  items are relevant to the change scope, omit the section entirely.
---
# Implementation Tasks: [Feature Name]

## Foundation
<!-- Shared infrastructure, setup, dependencies — must complete first -->
- [ ] [Task description]

## Implementation
<!-- Group by feature/story. Mark independent tasks with [P]. -->
- [ ] [P] [Task description]
- [ ] [Task description]

## QA Loop & Human Approval
- [ ] Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
- [ ] Auto-Verify: generate audit.md using the audit template.
- [ ] User Testing: **Stop here!** Ask the user for manual approval.
- [ ] Fix Loop: Classify each correction before fixing. Update all stale artifacts before re-implementing. Specs must match code before proceeding.
  - **Tweak**: wrong value/typo → fix in place
  - **Design Pivot**: wrong files/approach → update design.md + re-generate affected tasks + re-implement
  - **Scope Change**: wrong requirements → update specs + design + re-implement fully
- [ ] Final Verify: regenerate audit.md after all fixes to confirm consistency. Skip if Fix Loop was not entered.
- [ ] Approval: Only finish on explicit **"Approved"** by the user.

## Standard Tasks (Post-Implementation)
<!-- Universal post-implementation steps. Always include this section.
     If the constitution defines ## Standard Tasks > ### Pre-Merge, append those items after these. -->
- [ ] Run `specshift finalize` (generates changelog and updates docs)
- [ ] Bump version
- [ ] Commit and push to remote

## Post-Merge Reminders
<!-- Not tracked as tasks. Executed manually after the PR is merged.
     If the constitution defines ## Standard Tasks > ### Post-Merge, include relevant items here as plain bullets.
     Only include items whose scope matches the change. Omit this section if there is no Post-Merge subsection
     or if no items are relevant. -->
