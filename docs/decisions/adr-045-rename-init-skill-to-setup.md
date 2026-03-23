# ADR-045: Rename init skill to setup

## Status

Accepted (2026-03-23)

## Context

The `init` skill name conflicts with Claude Code's built-in `/init` command, which creates CLAUDE.md files. This makes `/opsx:init` unavailable to users while all other `/opsx:*` skills work fine. Research confirmed the conflict is specific to the `init` name. The rename affects the skill directory, frontmatter, and references across specs, docs, skills, and the README. Historical records (archives, CHANGELOG, ADRs) must be handled carefully since they document what was true at the time.

## Decision

Rename the skill from `init` to `setup`:
- Use `setup` as the new name (descriptive, avoids conflict, proposed in issue #31)
- Use `git mv` for the directory rename (preserves git history)
- Leave archives, CHANGELOG, and ADRs unchanged (historical records reflect state at time of creation)

## Rationale

`setup` accurately describes what the skill does and avoids the built-in conflict. `git mv` preserves file history that would be lost with a manual delete-and-recreate. Historical records are point-in-time documents — rewriting them would be misleading and lose the original context of past decisions.

## Alternatives Considered

- `install` as new name — too narrow, the skill does more than install
- Keep `init` and request upstream fix — depends on Claude Code team, indefinite timeline
- Update archives/CHANGELOG/ADRs too — rewrites history, misleading
- `rm` + `mkdir` + `cp` instead of `git mv` — loses git history for the skill file

## Consequences

### Positive

- `/opsx:setup` is discoverable and usable via the plugin system
- Git history preserved for the skill file
- Historical records remain accurate for their point in time

### Negative

- Breaking change for existing users who memorized `/opsx:init` — mitigated by the fact that the old command was not working anyway

## References

- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
- [Spec: three-layer-architecture](../../openspec/specs/three-layer-architecture/spec.md)
- [GitHub Issue #31](https://github.com/fritze-dev/opsx-enhanced-flow/issues/31)
