# SpecShift

A lightweight, spec-driven workflow for autonomous AI coding agents — distributed as a plugin for Claude Code and OpenAI Codex CLI from a single repository.

> *Every feature produces research, specs, architecture, quality checks, changelogs, and user docs alongside code.*

*Inspired by [OpenSpec](https://openspec.dev) and GitHub's [Spec-Kit](https://github.com/github/spec-kit).*

## Installation

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

### OpenAI Codex CLI

```bash
# Add the marketplace
codex plugin marketplace add fritze-dev/SpecShift
```

Then open `/plugins` in your Codex session to install or enable SpecShift.

Update:

```bash
codex plugin marketplace upgrade specshift
```

> **Existing Claude Code installs:** the `0.2.5-beta` release moves the marketplace `source` from `./.claude` to `./` and the compiled skill from `.claude/skills/specshift/` to `./skills/specshift/`. Run `claude plugin marketplace update specshift && claude plugin update specshift@specshift` once after upgrading to pick up the new layout.

## Quick Start

```bash
# Initialize a project (generates AGENTS.md + CLAUDE.md import stub)
specshift init

# Propose a new feature
specshift propose my-feature

# Implement the tasks
specshift apply

# Finalize (changelog, docs, version bump, recompile)
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
├── AGENTS.md                      # Agent entry point (agnostic SoT)
└── CLAUDE.md                      # Claude Code @AGENTS.md import stub
```

`AGENTS.md` is the single source of truth: Codex reads it natively, Claude Code reads it via the `@AGENTS.md` import expanded from `CLAUDE.md`.

## Architecture

**Three layers:**

| Layer | File | Purpose |
|-------|------|---------|
| Rules | `.specshift/CONSTITUTION.md` | Project-specific conventions |
| Pipeline | `.specshift/WORKFLOW.md` + Templates | Artifact generation |
| Router | `SKILL.md` (via plugin) | Action dispatch |

## Multi-Target Distribution

SpecShift ships from a single repository to both Claude Code and Codex CLI via a Shopify-flat layout:

```
.
├── src/                           # Hand-edited plugin source
│   ├── VERSION                    # Agnostic version source of truth
│   ├── skills/specshift/SKILL.md
│   ├── templates/                 # Smart Templates incl. agents.md + claude.md
│   └── actions/                   # Compilation manifests
├── .claude-plugin/                # Claude target (hand-edited at root)
│   ├── plugin.json
│   └── marketplace.json
├── .codex-plugin/                 # Codex target (hand-edited at root)
│   └── plugin.json
├── .agents/plugins/               # Codex marketplace catalog (hand-edited at root)
│   └── marketplace.json           # resolved by `codex plugin marketplace add owner/repo`
├── skills/specshift/              # Compiled, shared skill tree (both targets)
│   ├── SKILL.md
│   ├── templates/
│   └── actions/
└── scripts/compile-skills.sh
```

`src/VERSION` is the agnostic version source of truth. The compile script reads it and stamps the value into all three root manifest/marketplace files via `jq`, preserving all non-version fields and values (JSON formatting may be normalized by `jq`), and cross-checks each post-stamp; any drift fails the build. To bump the plugin version, edit `src/VERSION` and re-run `bash scripts/compile-skills.sh`.

## License

MIT
