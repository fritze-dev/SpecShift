# Pre-Flight Check: Codex Plugin Support

## A. Traceability Matrix

- Codex plugin source and manifest -> `src/.codex-plugin/plugin.json`, compiler copy step.
- Codex root plugin manifest -> `.codex-plugin/plugin.json`.
- Codex bootstrap file -> `src/codex/templates/agents.md`, compiler Codex template step.
- Release drift prevention -> `scripts/compile-skills.sh` builds both platforms.
- User install docs -> `README.md`.

## B. Gap Analysis

No blocking gaps. The implementation should include validation scans because text rewriting is easy to regress.

## C. Side-Effect Analysis

The compiler currently deletes/rebuilds `.claude/skills/specshift` and `.claude/.claude-plugin`. The change will additionally delete/rebuild root `skills/specshift` and `.codex-plugin`. It must not delete unrelated plugin files.

## D. Constitution Check

The constitution should describe additive Claude/Codex support, with Claude marketplace output unchanged and Codex output using Shopify-style root plugin layout.

## E. Duplication & Consistency

The Codex release must not become a second source of truth. All generated Codex artifacts should be derived from `src/` and committed only as release artifacts.

## F. Assumption Audit

- `codex-root-plugin-layout`: Acceptable Risk. Shopify AI Toolkit uses root `.codex-plugin/plugin.json` and `skills/`, which is the reference layout requested by review.

## G. Review Marker Audit

No `REVIEW` markers introduced.
