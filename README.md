# SpecShift

A lightweight, spec-driven workflow for autonomous AI agents — works with both Claude Code and OpenAI Codex CLI.

> *Every feature produces research, specs, architecture, quality checks, changelogs, and user docs alongside code.*

*Inspired by [OpenSpec](https://openspec.dev) and GitHub's [Spec-Kit](https://github.com/github/spec-kit).*

## Installation

SpecShift ships as a multi-target plugin. Pick the install path for your tool of choice (or install both — they share the same skill body and bootstrap rules).

### Claude Code

```bash
# Add the marketplace
claude plugin marketplace add fritze-dev/specshift

# Install the plugin
claude plugin install specshift
```

Update:

```bash
claude plugin marketplace update specshift && claude plugin update specshift@specshift
```

### Codex (OpenAI Codex CLI)

```bash
# Discover and install via the Codex plugin marketplace
codex /plugins
```

Search for `specshift` in the resulting list and install. The plugin manifest lives at `.codex-plugin/plugin.json` in this repo, and the marketplace entry at `.agents/plugins/marketplace.json`.

## Quick Start

```bash
# Initialize a project — generates AGENTS.md (full body, agnostic single source of truth)
specshift init

# Propose a new feature
specshift propose my-feature

# Implement the tasks
specshift apply

# Finalize (changelog, docs, version bump)
specshift finalize
```

By default, `auto_approve` is enabled — the pipeline runs end-to-end from propose through apply to finalize without manual checkpoints. Disable it in `.specshift/WORKFLOW.md` if you prefer to review each phase.

## How It Works

SpecShift runs an 8-stage pipeline for every change:

**Research** → **Propose** → **Specs** → **Design** → **Preflight** → **Tests** → **Tasks** → **Review**

Each stage produces a Markdown artifact. The pipeline is driven by Smart Templates and configured via `.specshift/WORKFLOW.md`.

## Project Structure

After `specshift init`, your project gets:

```
your-project/
├── .specshift/                    # Infrastructure (hidden)
│   ├── WORKFLOW.md                # Pipeline & action config
│   ├── CONSTITUTION.md            # Project rules for the agent
│   ├── templates/                 # Local blueprints (customizable)
│   └── changes/                   # Active & historical workspaces
├── docs/                          # Project knowledge
│   ├── specs/                     # Requirements (flat .md files)
│   ├── capabilities/              # Generated documentation
│   └── decisions/                 # Architecture Decision Records
└── AGENTS.md                      # Agent directives (read by Codex natively;
                                   #   Claude Code reads via the @AGENTS.md
                                   #   import in a hand-maintained CLAUDE.md
                                   #   if you want the documented memory pattern.
                                   #   Init does not auto-generate CLAUDE.md.)
```

## Architecture

**Three layers:**

| Layer | File | Purpose |
|-------|------|---------|
| Rules | `.specshift/CONSTITUTION.md` | Project-specific conventions |
| Pipeline | `.specshift/WORKFLOW.md` + Templates | Artifact generation |
| Router | `SKILL.md` (via plugin) | Action dispatch |

**Multi-target distribution:**

One agnostic plugin source serves both Claude Code and OpenAI Codex CLI from the same repository:

- `.claude-plugin/plugin.json` (Claude manifest, hand-edited at the root, version source of truth) + `.claude-plugin/marketplace.json`
- `.codex-plugin/plugin.json` (Codex manifest, hand-edited at the root; version stamped by the compile script) + `.agents/plugins/marketplace.json` (generated)
- `./skills/specshift/` (one shared skill tree, served to both targets)

The compile script (`bash scripts/compile-skills.sh`) builds the shared skill tree from `src/`, stamps the Claude version into the Codex manifest and Codex marketplace, and produces compiled action requirement files. Bootstrap content lives once in `src/templates/agents.md`. Codex consumers read AGENTS.md natively; Claude Code consumers can opt in to the documented `@AGENTS.md` memory-import pattern by hand-maintaining a one-line CLAUDE.md (the plugin ships `templates/claude.md` as a copy-paste template).
