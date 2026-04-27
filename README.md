# SpecShift

A lightweight, spec-driven workflow for autonomous AI agents using Claude Code and Codex.

Claude Code support remains the original path; Codex support is additive and ships as a separate generated plugin release.

> *Every feature produces research, specs, architecture, quality checks, changelogs, and user docs alongside code.*

*Inspired by [OpenSpec](https://openspec.dev) and GitHub's [Spec-Kit](https://github.com/github/spec-kit).*

## Claude Code Installation

```bash
# Add the marketplace
claude plugin marketplace add fritze-dev/specshift

# Install the plugin
claude plugin install specshift
```

## Claude Code Update

```bash
claude plugin marketplace update specshift && claude plugin update specshift@specshift
```

## Codex Installation

SpecShift also ships a generated Codex plugin using the root-level layout from the Codex plugin system: `.codex-plugin/plugin.json` plus `skills/specshift/`.

In the Codex CLI, run `/plugins`, add `https://github.com/fritze-dev/SpecShift` as a source, and select **SpecShift**. The installed skill is named `specshift`.

## Codex Update

Use `/plugins` in the Codex CLI and update/reinstall **SpecShift** when Codex reports an available plugin update.

## Quick Start

```bash
# Initialize a project
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
└── CLAUDE.md or AGENTS.md          # Agent entry point
```

## Architecture

**Three layers:**

| Layer | File | Purpose |
|-------|------|---------|
| Rules | `.specshift/CONSTITUTION.md` | Project-specific conventions |
| Pipeline | `.specshift/WORKFLOW.md` + Templates | Artifact generation |
| Router | `SKILL.md` (via plugin) | Action dispatch |

## Development

Plugin source lives under `src/`. Run the compiler before testing or publishing:

```bash
bash scripts/compile-skills.sh
```

The compiler regenerates both release targets:

- Claude Code: `.claude/`
- Codex: `.codex-plugin/` and `skills/specshift/`
