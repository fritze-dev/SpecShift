# ADR-034: Single `docs_language` Field in config.yaml

## Status

Accepted (2026-03-05)

## Context

All generated documentation (capability docs, ADRs, README, CHANGELOG) was English-only. Non-English-speaking teams could not use documentation in their preferred language, which limited adoption and usability in multilingual organisations. The team investigated three approaches to introduce configurable documentation language: a central `docs_language` field in config.yaml, a constitution-based language setting, and per-skill language parameters. The constitution approach was rejected because it mixes operational concerns with governance concerns. Per-skill parameters were rejected due to duplication — every skill would need its own language parameter, increasing maintenance burden and the risk of inconsistency. Central config was chosen because it provides a single source of truth, is read by all skills via the existing config-loading mechanism, and requires changes to only three skill files (docs, changelog, init). When the field is absent, the system defaults to English, maintaining full backward compatibility with existing projects.

## Decision

Introduce a single `docs_language` field in config.yaml that is read by all documentation-generating skills to determine the output language.

## Rationale

A central config field avoids duplication across skills, leverages the existing config-loading infrastructure, and is backward-compatible — missing field defaults to English. This is the minimal-change approach that satisfies the requirement with a single addition to the config schema.

## Alternatives Considered

- Per-skill parameter: would duplicate the language setting across every documentation skill, increasing maintenance burden and risk of drift
- Environment variable: not persistent across sessions and not captured in the project repository
- Constitution entry: mixes documentation-language concerns with governance and operational rules

## Consequences

### Positive

- Single source of truth for documentation language across all skills
- Fully backward-compatible — existing projects without the field continue to produce English docs
- Minimal implementation surface: one new config field, three skill-file updates

### Negative

- LLM translation quality varies by language — major languages produce high-quality results, but exotic languages may need manual review
- No runtime validation of the `docs_language` value — LLMs handle fuzzy language names well, but worst case falls back to English
- Language change mid-project leaves a mixed-language changelog — existing entries are preserved, new entries use the new language

## References

- ../../openspec/specs/user-docs/spec.md
- ../../openspec/specs/architecture-docs/spec.md
- ../../openspec/specs/decision-docs/spec.md
- ../../openspec/specs/release-workflow/spec.md
