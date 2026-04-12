# SpecShift

A lightweight, spec-driven workflow for autonomous AI agents using Claude Code.

> *Every feature produces research, specs, architecture, quality checks, changelogs, and user docs alongside code.*

## Installation

```bash
claude plugin install specshift
```

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
└── CLAUDE.md                      # Agent entry point
```

## Architecture

**Three layers:**

| Layer | File | Purpose |
|-------|------|---------|
| Rules | `.specshift/CONSTITUTION.md` | Project-specific conventions |
| Pipeline | `.specshift/WORKFLOW.md` + Templates | Artifact generation |
| Router | `SKILL.md` (via plugin) | Action dispatch |

## License

MIT
