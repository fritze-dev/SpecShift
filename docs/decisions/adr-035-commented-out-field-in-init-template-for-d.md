# ADR-035: Commented-out Field in Init Template for Discoverability

## Status

Accepted (2026-03-05)

## Context

With the introduction of the `docs_language` config field (ADR-034), the team needed a strategy for surfacing the feature to new projects without forcing it on them. An active field defaulting to English would add unnecessary noise to every new config file and could confuse users who never intend to change the language. Separate configuration documentation would not be discoverable at the point where users actually edit their config. The feature needed to be visible enough that users encounter it naturally during project setup, yet inactive by default so that existing behaviour is preserved. A commented-out entry in the init template strikes this balance: it appears directly in the generated config.yaml where users will see it, includes a brief inline comment explaining its purpose, and does not activate unless the user explicitly uncomments it. This ensures that existing projects created before the feature are completely unaffected.

## Decision

Include the `docs_language` field as a commented-out entry in the project-setup init template, with an inline comment describing its purpose and accepted values.

## Rationale

Users discover the feature organically while editing config.yaml, without requiring external documentation. The commented-out form has no runtime effect, so new and existing projects behave identically until a user opts in.

## Alternatives Considered

- Active field defaulting to English: adds unnecessary noise in config for users who never change the language
- Separate config documentation outside the template: not discoverable at the point of use; users may never find it

## Consequences

### Positive

- Zero-friction discoverability — users see the option exactly where they configure their project
- No behavioural change for projects that do not opt in
- Self-documenting: the inline comment explains the field without requiring external references

### Negative

- Commented-out fields can accumulate over time, cluttering the template if many optional features follow the same pattern
- Users unfamiliar with YAML comment syntax may not realise the field is inactive

## References

- ../../openspec/specs/project-setup/spec.md
- adr-034-single-docs-language-field-in-configyaml.md
