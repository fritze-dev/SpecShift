---
title: "Project Setup"
capability: "project-setup"
description: "One-time project initialization via /opsx:init"
lastUpdated: "2026-03-05"
---

# Project Setup

The `/opsx:init` command handles one-time project initialization, installing the OpenSpec CLI, setting up the schema, creating configuration files, and validating the result.

## Why This Exists

Without a single initialization command, you would need to manually install the OpenSpec CLI, register the schema, copy template files, and create configuration -- each step prone to mistakes and version mismatches. This capability ensures every project starts from a consistent, validated foundation so you can focus on spec-driven development instead of environment setup.

## Design Rationale

The init command generates config.yaml from a built-in template rather than copying the plugin's own config file. This prevents project-specific rules from leaking into consumer projects. The command deliberately avoids running `openspec init --tools claude` because that would create duplicate skill files that conflict with the plugin's own commands. Schema initialization uses `openspec schema init` directly, which works independently.

## Features

- Installs the OpenSpec CLI globally via npm if not already present
- Registers the opsx-enhanced schema via the OpenSpec CLI
- Copies custom schema files and templates into the project
- Creates a minimal config.yaml with schema reference and constitution pointer
- Creates a constitution placeholder if none exists
- Validates the setup after all steps complete
- Runs idempotently -- safe to re-run on already-initialized projects
- Checks CLI version compatibility (requires ^1.2.0)

## Behavior

### First-Time Initialization

When you run `/opsx:init` on a fresh project, the system installs the OpenSpec CLI (if needed), registers the schema, copies schema files, creates config.yaml, and creates a constitution placeholder. After all steps, it runs validation to confirm everything is working and reports the results.

### Re-Running Init

If you run `/opsx:init` on an already-initialized project, the system skips completed steps. It preserves your existing constitution.md and config.yaml, and reports which components were already in place.

### CLI Installation

If the OpenSpec CLI is not installed and npm is available, the system installs it automatically. If the CLI is installed but at an incompatible version (below 1.2.0), the system upgrades it. If npm is not available, the system reports a clear error with installation guidance.

### Validation

After setup, the system confirms that the CLI is accessible, the schema directory contains a valid schema.yaml, and config.yaml is present. If any check fails, it reports exactly which validation step failed.

## Known Limitations

- Requires Node.js and npm to be installed on the system
- Global npm installs may fail without appropriate permissions (e.g., may need `sudo` or npm prefix configuration)
- Version constraint (^1.2.0) means any CLI version from 1.2.0 up to (but not including) 2.0.0 is accepted

## Edge Cases

- If the project directory is read-only, init fails before making any changes and reports the permission issue.
- If network connectivity is unavailable during npm install, the system reports a network error with a retry suggestion.
- If the plugin's own config.yaml has project-specific rules, consumer projects still get a clean template because the init template is hardcoded in the skill.
