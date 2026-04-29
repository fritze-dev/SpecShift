---
title: "Test Generation"
capability: "test-generation"
description: "Apply-phase automated test generation driven by Constitution § Testing; direct scenario verification when no framework is configured"
lastUpdated: "2026-04-29"
---

# Test Generation

Generates tests during the apply phase as part of implementation tasks. When the project Constitution declares a test framework in `## Testing`, the apply phase produces automated test stubs in the configured directory; when "None" or absent, scenario verification happens directly in `audit.md` against the Gherkin scenarios in the affected specs. Test generation is no longer a separate pipeline stage producing a `tests.md` artifact.

## Purpose

Gherkin scenarios in specs define testable behavior, but a separate Tests pipeline stage that reformatted those scenarios into a manual checklist added overhead without adding information — and projects without a test framework derived no automation value from it. Folding test generation into the apply phase keeps automated test scaffolding close to implementation tasks for framework-configured projects, and lets framework-less projects rely on direct scenario verification in audit.

## Rationale

Test generation belongs in the apply phase because automated tests ARE code — they belong with the implementation tasks that produce them, not in a separate planning stage. Constitution § Testing is the single source of truth for framework configuration: it already captures the project's test stack at the constitution layer (per the three-layer architecture). For framework-less projects, the audit phase already verifies scenario coverage against the diff and code as part of its standard dimensions; reformatting scenarios into a separate manual checklist duplicated this work. Backward compatibility is preserved: legacy change directories that contain a `tests.md` from the previous Tests stage retain that file unchanged — tooling tolerates the legacy shape gracefully.

## Features

- **Framework Configuration via Constitution**: Test framework, directory, file naming pattern, import style, and conventions are declared in the project Constitution's `## Testing` section. "None" or absent means no framework.
- **Apply-Phase Automated Test Generation**: When a framework is configured, the apply phase generates automated test stubs as part of implementation tasks. Each stub maps GIVEN→arrange, WHEN→act, THEN→assert. Tests are grouped by capability and requirement and include traceability comments linking back to source scenarios.
- **Scenario Verification Without a Framework**: When Constitution § Testing declares "None" (or is absent), the apply phase does not generate automated tests; instead, the audit phase verifies each Gherkin scenario directly against the implementation. No `tests.md` artifact is produced.
- **Manual Edit Preservation**: When regenerating tests for a change that modifies existing scenarios, test cases marked with `@manual` (language-appropriate comment syntax) are preserved unchanged.
- **Backward Compatibility With Legacy `tests.md`**: Legacy change directories that contain a `tests.md` from the previous Tests stage retain that file. Tooling that reads change artifacts (audit cross-checks, capability-doc enrichment) tolerates the legacy shape; new changes do not produce `tests.md`.

## Behavior

### Framework-Driven Test Generation During Apply

When Constitution § Testing declares a framework, apply-phase implementation tasks include generating automated test stubs in the configured test directory. Each stub initially fails or is marked pending (TDD red-phase) using the framework's convention (e.g., `test.todo()` for Vitest, `pytest.mark.skip` for pytest). Stubs include traceability comments referencing source scenarios.

### Direct Scenario Verification When No Framework

When Constitution § Testing is "None" or absent, the apply phase does not produce test files. The audit phase's scenario-coverage dimension verifies each Gherkin scenario from the affected specs directly against the implementation diff and code. No standalone `tests.md` checklist is produced.

### Edge-Case Test Generation

When a framework is configured, apply-phase test generation includes test cases for items in each spec's `## Edge Cases` section. When a spec has no scenarios for a requirement (a format violation), apply notes the gap in the audit's findings rather than silently skipping.

### Manual Edit Preservation During Regeneration

When apply runs against a change that modifies existing scenarios, test files matching the framework's discovery rules are scanned for `@manual` markers. Marked test cases are preserved unchanged; unmarked tests are regenerated to match the current scenarios.

### Legacy `tests.md` Tolerance

Legacy change directories that contain a `tests.md` are accepted by audit cross-checks and capability-doc enrichment. The current pipeline does not produce new `tests.md` files; the audit Test Coverage dimension verifies scenarios directly against specs for both legacy and new changes.

## Known Limitations

- Apply-phase test generation produces stubs; the apply phase does not run the test suite.
- The distinction between automatable and non-automatable scenarios relies on LLM heuristics — visual or judgment-based scenarios may still need manual verification outside the test framework.
- Regeneration replaces all unmarked tests during apply when a change modifies scenarios; only `@manual`-marked tests survive.

## Edge Cases

- If a requirement has no scenarios, apply skips test generation for that requirement and notes the gap in audit findings.
- If two scenarios across different requirements share the same name, apply disambiguates by prefixing with the requirement name.
- If the test directory does not exist, apply creates it.
- If the proposal lists no capabilities, apply skips test generation entirely.
- If the constitution specifies an unknown framework, apply falls back to generic test stubs with comments indicating the intended framework.
- Legacy change directories that contain `tests.md` retain the file; new changes do not.
