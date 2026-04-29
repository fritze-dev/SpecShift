# Pre-Flight Check: Workflow/Spec-Hygiene Bundle (#59 + #58)

## A. Traceability Matrix

| Story (proposal) | Scenario (spec) | Component (file) |
|---|---|---|
| Templates: numeric/letter prefixes → semantic | `Tasks template uses semantic headings` (artifact-pipeline.md, NEW) | `src/templates/changes/{tasks,research,preflight}.md` |
| Templates: numeric/letter prefixes → semantic | `Cross-reference in spec uses semantic name` (artifact-pipeline.md, NEW) | `src/templates/changes/audit.md` instruction; `docs/specs/artifact-pipeline.md` |
| Templates: numeric/letter prefixes → semantic | `Reordering sections does not break cross-references` (artifact-pipeline.md, NEW) | All five touched templates |
| Specs: stale numeric cross-refs → semantic | `Universal standard tasks always included` (artifact-pipeline.md, MODIFIED — now uses semantic name) | `docs/specs/artifact-pipeline.md` Standard Tasks Directive scenarios |
| Specs: stale numeric cross-refs → semantic | `WORKFLOW.md defines the pipeline order` (three-layer-architecture.md, MODIFIED — now references the semantic stage set) | `docs/specs/three-layer-architecture.md` Schema Layer scenario |
| Pipeline-Count resolved | `Pipeline Stages and Dependencies` (artifact-pipeline.md, RENAMED from "Eight-Stage Pipeline") | `docs/specs/artifact-pipeline.md`, `docs/specs/three-layer-architecture.md`, `README.md` |
| Self-check enforcement (#58) | `Self-check invoked after fix commit` (review-lifecycle.md, NEW) | `src/templates/workflow.md` `## Action: review` Self-check bullet |
| Self-check enforcement (#58) | `Self-check after fixes catches regression` (review-lifecycle.md, NEW) | `src/templates/workflow.md` `## Action: review` Self-check bullet |
| Self-check enforcement (#58) | `Pre-merge summary refuses without self-check marker` (review-lifecycle.md, NEW) | `src/templates/workflow.md` `## Action: review` Pre-merge summary bullet |
| Self-check enforcement (#58) | `Stale self-check marker forces re-invocation` (review-lifecycle.md, NEW) | `src/templates/workflow.md` `## Action: review` Self-check bullet |
| Self-check enforcement (#58) | `Pre-Merge Summary Comment` requirement gate (review-lifecycle.md, MODIFIED) | `src/templates/workflow.md` `## Action: review` Pre-merge summary bullet |
| Mirrors stay in sync | (no scenario; constitution-driven `Template synchronization` convention) | `.specshift/WORKFLOW.md`, `.specshift/templates/changes/*.md` |

All capability changes mapped. The proposal's `capabilities.modified` field lists three specs (`artifact-pipeline`, `three-layer-architecture`, `review-lifecycle`); each has corresponding edits in this change. No `capabilities.new` entries — no orphan specs to create.

## B. Gap Analysis

- **Edge case: Self-check marker posted but later edited externally** — covered indirectly: spec scenarios anchor on the literal marker `<!-- specshift:self-check -->` plus the HEAD commit SHA. Manual editing that removes the marker triggers the missing-marker stop path. Manual editing that changes the SHA falls under the existing "Stale self-check marker forces re-invocation" scenario. **No additional scenario needed.**
- **Edge case: Self-check is invoked but the comment-post fails** — analogous to the existing "Summary comment failure does not block merge" pattern in Pre-Merge Summary Comment. The new requirement should adopt the same graceful-degradation: log warning, continue. **GAP — not currently in scope; design.md does not define the failure-mode.** Mitigation: classified as ACCEPTABLE — if the comment post fails, the gate refuses merge, and the user sees an explicit "self-check missing" stop. No silent skip. The spec's stop-and-report path covers it.
- **Edge case: Two consumer projects share a template version but customize differently** — out of scope; consumer customization is handled by `specshift init`'s merge prompts, not by this change.
- **Edge case: Numerical prefix accidentally added back during a future template edit** — no automated enforcement (the new requirement is descriptive, not a CI check). Possible future friction. **Documented as residual risk; not blocking.**
- **Empty states**: change has no UI, no APIs — empty-state coverage N/A.
- **Error handling**: pure markdown edits — error handling N/A. `bash scripts/compile-skills.sh` handles bump-validation failure (existing).

## C. Side-Effect Analysis

**Affected systems:**
- `bash scripts/compile-skills.sh` — receives five bumped templates; existing version-validation logic already handles arbitrary numbers. **No regression.**
- `specshift init` (consumer projects) — sees five `template-version` differences on next run; existing merge-prompt logic handles N templates. **No regression.**
- `specshift apply` for future changes — generated `tasks.md` will now have semantic headings; `tasks.md` parsing in apply uses `- [ ]` / `- [x]` checkboxes, not headings. **No regression.**
- `specshift review` for this PR — will produce the new `<!-- specshift:self-check -->` marker. First-use validation. **Self-validating.**
- Existing PRs in flight (other branches): unaffected — they use the templates as they existed when their workspace was created. New templates apply only to new `specshift propose` invocations after this change merges.

**Regression risks:**
- Cross-references in third-party docs (e.g., team wikis, blog posts) referring to "section 4 of tasks.md" or "the 8-stage pipeline" become subtly wrong. **ACCEPTABLE** — these external refs already had the rot risk; the change merely speeds up the day they go stale.
- Skills-cache (`/root/.claude/plugins/cache/specshift/specshift/0.2.5-beta/`) caches old templates locally; first `specshift init` after this change merges will refresh. **Already handled by existing cache logic.**

## D. Constitution Check

Reviewed `.specshift/CONSTITUTION.md` Conventions:
- **Template-version discipline** — change bumps five `template-version`s as required. ✓
- **Template synchronization** — `src/templates/workflow.md` is authoritative; `.specshift/WORKFLOW.md` synced parallel; intentional project override (extra `Compile` step) preserved. ✓
- **No ADR references in specs** — change adds cross-spec references (artifact-pipeline → three-layer-architecture) but no ADR refs. ✓
- **Tool-agnostic instructions** — new self-check requirement says "the built-in review skill" rather than `/review` literal; mention of `/review` is bounded to a parenthetical example in workflow.md instruction. ✓
- **Workflow friction** — change addresses two `friction`-labeled issues (#59, #58); this is the canonical path. ✓
- **Standard Tasks Pre-merge / Post-merge** — change touches files under `src/`, so the `claude plugin marketplace update specshift && claude plugin update specshift@specshift` post-merge reminder applies; will be inherited from constitution by tasks template.

No constitutional rules require updating for this change.

## E. Duplication & Consistency

- **Self-Check requirement vs. existing Review Comment Processing** — existing requirement carried advisory wording ("then run the built-in review skill for self-check"); change replaces with normative reference to the new requirement. No duplication. ✓
- **Pre-Merge Summary gate** — defined in NEW Self-Check Mandatory After Comment Processing requirement; cross-referenced from existing Pre-Merge Summary Comment requirement. Single SoT for the gate, single see-also pointer. ✓
- **Pipeline stage list** — single SoT now in `artifact-pipeline.md` Pipeline Stages and Dependencies; `three-layer-architecture.md` Schema Layer references it. README will say "the artifact pipeline" without enumerating stages. No duplicate stage lists. ✓
- **Heading-discipline rule** — single SoT in NEW `artifact-pipeline.md` Semantic Heading Structure requirement; not also stated in `spec-format.md` (which governs spec files, not change templates). No duplication. ✓
- **Drift check Lines 30 vs 37 of three-layer-architecture.md** — the existing "7-stage" (Line 30) vs "exactly 8" (Line 37) drift IS a known inconsistency that this change resolves. Documented in design.md. ✓

## F. Assumption Audit

Three assumptions in design.md, each with visible text:

| Assumption | Rating | Note |
|---|---|---|
| `PR-comment-marker-tooling`: GitHub tooling can post and search PR comments | Acceptable Risk | Shared with existing `<!-- specshift:review-summary -->` requirement; no new capability needed. |
| `compile-script-template-version-validation`: compile script continues to enforce bumps against `main` | Acceptable Risk | Existing behavior; no script changes in this bundle. |
| `consumer-merge-prompt-batches-by-init-run`: one `specshift init` run produces one batched prompt for all five templates | Acceptable Risk | Existing behavior verified during prior multi-template bumps (e.g., 2026-04-15-conditional-merge-reminders). |

No `<!-- ASSUMPTION -->` tags without visible text. No assumption rated Blocking or Needs Clarification.

## G. Review Marker Audit

Grep across change artifacts for `<!-- REVIEW` and `<!-- REVIEW:`:

- `.specshift/changes/2026-04-28-workflow-spec-hygiene-bundle/research.md` — zero matches.
- `.specshift/changes/2026-04-28-workflow-spec-hygiene-bundle/proposal.md` — zero matches.
- `.specshift/changes/2026-04-28-workflow-spec-hygiene-bundle/design.md` — zero matches.
- `.specshift/changes/2026-04-28-workflow-spec-hygiene-bundle/preflight.md` — zero matches (this file).
- `docs/specs/artifact-pipeline.md` — zero matches.
- `docs/specs/three-layer-architecture.md` — zero matches.
- `docs/specs/review-lifecycle.md` — zero matches.

No unresolved REVIEW markers. ✓

## Verdict

**PASS** — 0 blockers, 0 warnings.

Traceability complete (eleven story-to-scenario mappings). One minor gap (self-check comment post failure) classified ACCEPTABLE because the spec's stop-and-report path covers it. No constitution conflicts. No duplication. All assumptions visible and rated Acceptable Risk. No REVIEW markers.

Proceed to tests + tasks generation.
