---
order: 9
category: development
status: stable
version: 2
lastModified: 2026-04-29
---
## Purpose

Defines apply-phase test generation behavior: when a project's constitution declares an automated test framework, the apply phase generates automated tests as part of implementation tasks. When no framework is declared, scenario verification is handled directly by audit.md against the Gherkin scenarios in the affected specs. Test generation is no longer a separate pipeline stage producing a tests.md artifact.

## Requirements

### Requirement: Framework Configuration via Constitution

The system SHALL read test framework configuration from the project constitution's `## Testing` section. The configuration SHALL include: framework name, test directory path, file naming pattern, import style, and conventions. If the `## Testing` section is absent or declares the framework as "None", the system SHALL treat the project as having no automated test framework and SHALL handle scenario verification via audit.md against the Gherkin scenarios in the affected specs.

**User Story:** As a project maintainer I want to declare my test framework once in the constitution, so that the apply phase generates tests using my project's tooling without per-change configuration.

#### Scenario: Constitution declares a test framework
- **GIVEN** a constitution with a `## Testing` section specifying `vitest` as framework and `src/__tests__` as test directory
- **WHEN** the apply phase begins implementation
- **THEN** the system SHALL include automated test generation as part of the implementation tasks
- **AND** SHALL write generated test files to `src/__tests__/`

#### Scenario: Constitution declares no framework
- **GIVEN** a constitution with `## Testing` declaring framework "None" (or no `## Testing` section at all)
- **WHEN** the apply phase begins implementation
- **THEN** the system SHALL NOT generate automated test files
- **AND** scenario verification SHALL be handled by audit.md against Gherkin scenarios in the affected specs

#### Scenario: Testing section with partial configuration
- **GIVEN** a constitution with `## Testing` specifying only framework name and test directory
- **WHEN** the apply phase begins
- **THEN** the system SHALL use the provided values and infer missing values (file pattern, import style) from the framework's conventions

### Requirement: Apply-Phase Automated Test Generation

When Constitution § Testing declares a framework, the apply phase SHALL generate automated tests as part of implementation tasks rather than as a dedicated pipeline stage. The system SHALL parse all `#### Scenario:` blocks from the spec files listed in the proposal's `capabilities` frontmatter (or, as a fallback, the parsed Capabilities section). For each scenario, the system SHALL extract the GIVEN clause (preconditions), WHEN clause (trigger/action), and THEN/AND clauses (expected outcomes). Each generated test SHALL map GIVEN to test setup (arrange), WHEN to test action (act), and THEN/AND to assertions (assert). Tests SHALL be grouped by capability and requirement.

Each generated test SHALL include a traceability comment in the source file linking back to the originating scenario. For most languages this takes the form `// Spec: <capability> > Requirement: <name> > Scenario: <scenario-name>`; the comment syntax SHALL match the target language (e.g., `#` for Python).

**User Story:** As a developer I want automated tests generated alongside my implementation when my project has a test framework, so that scenario coverage is enforced by code rather than by a separate manual checklist.

#### Scenario: Apply phase generates Vitest tests
- **GIVEN** a constitution with framework `vitest` and file pattern `{name}.test.ts`
- **AND** affected specs declaring 3 scenarios for capability `user-auth`
- **WHEN** the apply phase generates automated tests
- **THEN** the system SHALL create `user-auth.test.ts` in the configured test directory
- **AND** the file SHALL contain 3 tests mapping GIVEN/WHEN/THEN to arrange/act/assert
- **AND** each test SHALL include a traceability comment to its source scenario

#### Scenario: Apply phase generates pytest tests
- **GIVEN** a constitution with framework `pytest` and file pattern `test_{name}.py`
- **AND** affected specs declaring 2 scenarios for capability `data-export`
- **WHEN** the apply phase generates automated tests
- **THEN** the system SHALL create `test_data_export.py` in the configured test directory
- **AND** each test SHALL include a `#`-prefixed traceability comment

#### Scenario: Edge Cases produce additional tests
- **GIVEN** an affected spec whose `## Edge Cases` section lists 3 boundary conditions
- **WHEN** the apply phase generates automated tests
- **THEN** the system SHALL produce additional test cases for each documented edge case

#### Scenario: Multiple capabilities in scope
- **GIVEN** a proposal listing 2 new capabilities and 1 modified capability
- **WHEN** the apply phase generates automated tests
- **THEN** the system SHALL parse scenarios from all 3 capability specs and produce tests for each

### Requirement: Scenario Verification Without a Framework

When Constitution § Testing declares no framework, the apply phase SHALL NOT produce a separate manual test checklist artifact. Instead, audit.md SHALL verify each Gherkin scenario in the affected specs against implementation evidence (diff content as primary, codebase keyword search as fallback). This is the verification path defined by the quality-gates spec's Testing dimension. Manual verification checklists are no longer part of the standard flow.

**User Story:** As a developer on a project without an automated test framework I want scenario coverage verified directly from my specs during audit, so that I do not need to maintain a separate tests.md checklist.

#### Scenario: No-framework project relies on audit scenario verification
- **GIVEN** a project whose Constitution § Testing declares "None"
- **AND** affected specs containing 5 Gherkin scenarios
- **WHEN** the apply phase produces audit.md
- **THEN** audit.md's Testing dimension SHALL verify each of the 5 scenarios against implementation evidence
- **AND** no tests.md artifact SHALL be produced for the change

#### Scenario: Manual checklist not produced
- **GIVEN** any change progressing through the pipeline under the current six-stage flow
- **WHEN** the apply phase completes
- **THEN** no `tests.md` checklist artifact SHALL be produced

### Requirement: Manual Edit Preservation for Generated Tests

When the apply phase regenerates tests for a change that modifies existing scenarios, the system SHALL check existing test files for an `@manual` marker (language-appropriate: `// @manual`, `# @manual`). Test cases marked with `@manual` SHALL be preserved as-is during regeneration.

#### Scenario: Preserve manually edited test
- **GIVEN** an existing test file with a test case containing `// @manual` at the top of the test block
- **WHEN** the apply phase regenerates tests for the same capability
- **THEN** the marked test case SHALL be preserved unchanged

#### Scenario: Regenerate unmarked test
- **GIVEN** an existing test file with a test case that has no `@manual` marker
- **WHEN** the apply phase regenerates tests for the same capability
- **THEN** the test case SHALL be regenerated from the current scenario

### Requirement: Backward Compatibility With Legacy tests.md

Legacy change directories that contain a `tests.md` artifact (created under the previous eight-stage pipeline that included a Tests stage) SHALL retain that file unchanged. The current pipeline SHALL NOT produce new `tests.md` files. Tooling that reads change artifacts (e.g., audit cross-checks) SHALL handle the legacy shape gracefully by accepting the presence of `tests.md` without requiring it.

#### Scenario: Legacy change retains tests.md
- **GIVEN** a completed change directory that contains a `tests.md` file produced by the previous Tests stage
- **WHEN** downstream tooling reads the change
- **THEN** the tooling SHALL accept the legacy file without requiring migration
- **AND** SHALL NOT regenerate or overwrite it

#### Scenario: New change does not produce tests.md
- **GIVEN** a new change progressing through the current six-stage pipeline
- **WHEN** the apply phase completes
- **THEN** no `tests.md` file SHALL be created in the change directory

## Edge Cases

- **Spec with no scenarios**: If a requirement has no scenarios (spec format violation), the apply phase SHALL skip that requirement and note it as a warning in audit.md.
- **Empty Edge Cases section**: If a spec's Edge Cases section contains no items, no additional edge case tests are generated.
- **Duplicate scenario names**: If two scenarios across different requirements have the same name, the system SHALL disambiguate by prefixing with the requirement name in the test function name.
- **Very long scenario names**: Test function names derived from scenario names SHALL be truncated or abbreviated to fit language conventions (e.g., max identifier length).
- **Test directory does not exist**: The system SHALL create the test directory if it does not exist.
- **Existing test file with unrelated tests**: When writing to an existing test file, the system SHALL append new tests without modifying existing unrelated test cases.
- **No capabilities in proposal**: If the proposal lists no capabilities, the apply phase SHALL skip automated test generation entirely.
- **Framework not recognized**: If the constitution specifies an unknown framework name, the system SHALL fall back to generating generic test stubs with comments indicating the intended framework.

## Assumptions

- Gherkin scenarios in specs follow the format defined in the spec-format spec (`#### Scenario:` heading with GIVEN/WHEN/THEN clauses). <!-- ASSUMPTION: Gherkin format compliance -->
- The agent generating tests has sufficient knowledge of mainstream test frameworks to produce syntactically correct code. <!-- ASSUMPTION: Framework knowledge -->
- The constitution's `## Testing` section is authoritative for whether automated test generation is in scope for a project. <!-- ASSUMPTION: Constitution authority over test mode -->
