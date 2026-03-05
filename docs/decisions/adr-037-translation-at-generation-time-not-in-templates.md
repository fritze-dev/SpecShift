# ADR-037: Translation at Generation Time, Not in Templates

## Status

Accepted (2026-03-05)

## Context

Documentation skills use Markdown templates as structural guides that define section headings, ordering, and placeholder content. The team needed to decide where language translation should occur: in the templates themselves or during generation. Maintaining per-language template sets was evaluated first but rejected due to template proliferation — every supported language would require a full copy of every template, and any structural change would need to be replicated across all copies. This creates a significant maintenance burden that scales multiplicatively with the number of languages and templates. By contrast, translating at generation time keeps a single canonical set of English templates and delegates translation to the LLM during the documentation-generation step. The LLM reads the template structure, produces content in the configured `docs_language`, and translates headings and prose accordingly. This approach requires no additional template files and naturally supports any language the LLM can handle, without the team needing to pre-translate anything.

## Decision

Perform language translation during documentation generation rather than maintaining separate translated template sets. Templates remain in English as structural guides; the generating LLM translates headings and content into the configured `docs_language` at runtime.

## Rationale

A single set of English templates eliminates the maintenance burden of per-language copies. Structural changes to templates propagate automatically to all languages. The LLM handles translation as part of the generation step, supporting any language without pre-work.

## Alternatives Considered

- Per-language template sets: causes template proliferation, each structural change must be replicated across all language copies, maintenance burden scales with number of supported languages

## Consequences

### Positive

- One canonical template set — structural changes are made once and apply to all languages
- No upfront translation effort; new languages are supported immediately via the LLM
- Templates remain readable and reviewable in a single language (English)

### Negative

- LLM translation quality varies by language — major languages produce high-quality results, exotic languages may require manual review
- Heading translation depends on LLM consistency; slight variations in translated headings across documents are possible
- No way to override a specific translated heading without post-generation editing

## References

- ../../openspec/specs/user-docs/spec.md
- adr-034-single-docs-language-field-in-config-yaml.md
