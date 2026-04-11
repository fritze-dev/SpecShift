# ADR-053: SessionStart Hook Fallback for Plugin Auto-Install

## Status

Accepted (2026-04-11)

## Context

The declarative plugin installation mechanism (`extraKnownMarketplaces` + `enabledPlugins` in `.claude/settings.json`) was introduced in ADR-050 as the primary way to auto-install the opsx plugin in Claude Code Web sessions. However, a race condition in Claude Code (tracked as anthropics/claude-code#10997) prevents `enabledPlugins` from resolving correctly when the marketplace async-fetch has not completed by the time the plugin system processes the settings. This results in `installed_plugins.json` remaining empty and the `/opsx:workflow` skill being unavailable, requiring manual `claude plugin install` intervention every session.

The `devcontainer.json` `postCreateCommand` handles this for Codespaces/devcontainer environments via explicit `claude plugin install`, but has no effect in Claude Code Web sessions. Three approaches were considered: a SessionStart hook with the install command, waiting for the upstream fix, and adding a sleep delay before the install. The hook approach provides the best balance of simplicity and effectiveness as a temporary workaround.

## Decision

1. **Add a `SessionStart` hook with `matcher: "startup"` that runs `claude plugin install opsx@opsx-enhanced-flow 2>/dev/null || true`** — the plugin only needs installation on new sessions (not resume/clear/compact), and the `startup` matcher avoids unnecessary overhead on session resumption.

2. **No sleep delay before the install command** — keeps session startup fast; if the marketplace hasn't been fetched on the very first run, the hook fails silently (`|| true`) and succeeds on the next session when the marketplace is cached.

3. **Keep the hook as a fallback alongside the declarative fields** — `extraKnownMarketplaces` and `enabledPlugins` remain the primary mechanism. When Claude Code fixes the upstream race condition, the hook becomes a harmless no-op rather than the sole installation path.

## Alternatives Considered

- **No matcher (fires on all session types)** — unnecessary overhead on resume/clear/compact where the plugin is already loaded
- **`sleep 2` before the install command** — would slow every session start; the no-sleep approach is acceptable because second-session success is guaranteed via marketplace caching
- **Replace declarative fields with hook-only approach** — loses the correct long-term mechanism; the declarative approach is architecturally right, just buggy upstream

## Consequences

### Positive

- Plugin auto-installs in Claude Code Web sessions (after first marketplace fetch)
- Zero impact when the upstream bug is eventually fixed — hook becomes a no-op
- Minimal session startup overhead (one fast, idempotent command)

### Negative

- Very first session may still fail if the marketplace hasn't been fetched yet (user needs to start a second session)
- Introduces a tension with ADR-050 which chose declarative over hooks — mitigated by keeping the hook explicitly as a fallback

## References

- [ADR-050: Declarative Plugin Install via Marketplace Fields](adr-050-declarative-plugin-install-via-marketplace.md)
- [Change: session-start-hook-fallback](../../openspec/changes/2026-04-11-session-start-hook-fallback/)
- [GitHub Issue #112](https://github.com/fritze-dev/opsx-enhanced-flow/issues/112)
- [Upstream Issue: anthropics/claude-code#10997](https://github.com/anthropics/claude-code/issues/10997)
